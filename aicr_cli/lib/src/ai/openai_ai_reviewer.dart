import 'dart:convert';
import 'dart:io';

import 'package:aicr_cli/src/finding/models/aicr_finding.dart';
import 'package:crypto/crypto.dart';

import '../util/aicr_logger.dart';
import 'ai_prompt_builder.dart';
import 'ai_review_request.dart';
import 'ai_review_result.dart';
import 'ai_reviewer.dart';
import 'diff_redactor.dart';
import 'diff_truncator.dart';
import '../profile/aicr_project_profile.dart';

typedef OpenAiTransport = Future<OpenAiTransportResponse> Function({
  required Uri uri,
  required Map<String, String> headers,
  required String body,
  required Duration timeout,
});

final class OpenAiTransportResponse {
  final int statusCode;
  final String body;

  const OpenAiTransportResponse({required this.statusCode, required this.body});
}

/// Real OpenAI-backed reviewer (minimum viable).
///
/// - Single request (no streaming, no retries).
/// - Strict JSON output enforced (best-effort).
/// - Never throws (returns `AiReviewResult.error` on failures).
final class OpenAiAiReviewer extends AiReviewer {
  final String model;
  final OpenAiTransport _transport;
  final String? _apiKeyOverride;
  final AicrLogger _logger;
  final DiffRedactor _redactor;
  final DiffTruncator _truncator;
  final AiPromptBuilder _promptBuilder;
  final AicrProjectProfile _projectProfile;

  /// Defaults to `gpt-4o-mini`.
  OpenAiAiReviewer({
    this.model = 'gpt-4o-mini',
    OpenAiTransport? transport,
    String? apiKeyOverride,
    AicrLogger logger = const AicrLogger.none(),
    DiffRedactor redactor = const DiffRedactor(),
    DiffTruncator truncator = const DiffTruncator(),
    AiPromptBuilder promptBuilder = const AiPromptBuilder(),
    AicrProjectProfile projectProfile = AicrProjectProfile.empty,
  }) : _transport = transport ?? _defaultTransport,
       _apiKeyOverride = apiKeyOverride,
       _logger = logger,
       _redactor = redactor,
       _truncator = truncator,
       _promptBuilder = promptBuilder,
       _projectProfile = projectProfile;

  static String? _readApiKey({String? override}) {
    if (override != null && override.trim().isNotEmpty) return override.trim();
    final key = Platform.environment['OPENAI_API_KEY'];
    if (key == null) return null;
    final trimmed = key.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  @override
  Future<AiReviewResult> review(AiReviewRequest request) async {
    // IMPORTANT: only redact for AI provider input. Deterministic analyzers must
    // continue using raw diffs elsewhere.
    final redactedDiff = _redactor.redact(request.diffText);
    final didRedact = redactedDiff != request.diffText;
    if (_logger.verbose) {
      _logger.info('AI diff redacted=$didRedact');
    }

    final trunc = _truncator.truncate(redactedDiff, request.maxInputChars);
    final diffText = trunc.text;
    final truncated = trunc.truncated;

    try {
      if (request.maxOutputTokens <= 0) {
        return AiReviewResult.error(
          errorMessage: 'maxOutputTokens must be > 0',
          model: model,
          truncated: truncated,
        );
      }

      if (request.maxFindings <= 0) {
        return AiReviewResult.ok(
          findings: const <AicrFinding>[],
          model: model,
          truncated: truncated,
        );
      }

      final apiKey = _readApiKey(override: _apiKeyOverride);
      if (apiKey == null) {
        return AiReviewResult.error(
          errorMessage: 'OPENAI_API_KEY missing',
          model: model,
          truncated: truncated,
        );
      }

      final timeout = Duration(milliseconds: request.timeoutMs);
      final uri = Uri.parse('https://api.openai.com/v1/responses');

      final systemPrompt = _promptBuilder.buildSystemPrompt(
        language: _projectProfile.language ?? request.language,
        profile: _projectProfile,
      );

      final userPrompt = _promptBuilder.buildUserPrompt(
        repoName: request.repoName,
        diffText: diffText,
        maxFindings: request.maxFindings,
        profile: _projectProfile,
      );

      final bodyMap = <String, Object?>{
        'model': model,
        'input': [
          {
            'role': 'system',
            'content': [
              {'type': 'text', 'text': systemPrompt},
            ],
          },
          {
            'role': 'user',
            'content': [
              {'type': 'text', 'text': userPrompt},
            ],
          },
        ],
        'temperature': 0.2,
        'max_output_tokens': request.maxOutputTokens,
        // Strong hint to enforce strict JSON output.
        'text': {
          'format': {'type': 'json_object'},
        },
      };

      final headers = <String, String>{
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
      };

      if (_logger.verbose) {
        // Verbose mode MUST NOT print payloads, headers, or API keys.
        _logger.debug('OpenAI request: POST $uri');
        _logger.debug('OpenAI model: $model');
        _logger.debug(
          'OpenAI timeoutMs=${request.timeoutMs} maxOutputTokens=${request.maxOutputTokens} temperature=0.2 truncated=$truncated diffChars=${diffText.length}',
        );
      }

      final resp = await _transport(
        uri: uri,
        headers: headers,
        body: jsonEncode(bodyMap),
        timeout: timeout,
      );

      if (resp.statusCode < 200 || resp.statusCode >= 300) {
        final snippet = resp.body.length > 500
            ? '${resp.body.substring(0, 500)}...'
            : resp.body;
        return AiReviewResult.error(
          errorMessage: 'OpenAI HTTP ${resp.statusCode}: $snippet',
          model: model,
          truncated: truncated,
        );
      }

      Map<String, Object?> responseJson;
      try {
        final decoded = jsonDecode(resp.body);
        if (decoded is! Map) {
          return AiReviewResult.error(
            errorMessage: 'OpenAI response is not a JSON object',
            model: model,
            truncated: truncated,
          );
        }
        responseJson = decoded.cast<String, Object?>();
      } catch (e) {
        return AiReviewResult.error(
          errorMessage: 'OpenAI response JSON parse failed: $e',
          model: model,
          truncated: truncated,
        );
      }

      final usage = _extractUsage(responseJson);
      final responseModel = (responseJson['model'] as String?) ?? model;

      final text = _extractOutputText(responseJson);
      if (text == null || text.trim().isEmpty) {
        return AiReviewResult.error(
          errorMessage: 'OpenAI response missing output text',
          model: responseModel,
          truncated: truncated,
          usage: usage,
        );
      }

      Map<String, Object?> strictJson;
      try {
        final decoded = jsonDecode(text.trim());
        if (decoded is! Map) {
          return AiReviewResult.error(
            errorMessage: 'Model output is not a JSON object',
            model: responseModel,
            truncated: truncated,
            usage: usage,
          );
        }
        strictJson = decoded.cast<String, Object?>();
      } catch (e) {
        return AiReviewResult.error(
          errorMessage: 'Model output JSON parse failed: $e',
          model: responseModel,
          truncated: truncated,
          usage: usage,
        );
      }

      final mapped = _OpenAiJsonFindingMapper.fromStrictJson(
        strictJson: strictJson,
        diffHash: request.diffHash,
        maxFindings: request.maxFindings,
      );

      if (mapped.errorMessage != null) {
        return AiReviewResult.error(
          errorMessage: mapped.errorMessage!,
          model: responseModel,
          truncated: truncated,
          usage: usage,
        );
      }

      return AiReviewResult.ok(
        findings: mapped.findings,
        model: responseModel,
        truncated: truncated,
        usage: usage,
      );
    } catch (e) {
      // No-throw policy: return best-effort error.
      return AiReviewResult.error(
        errorMessage: e.toString(),
        model: model,
        truncated: truncated,
      );
    }
  }

  static Map<String, Object?>? _extractUsage(Map<String, Object?> response) {
    final u = response['usage'];
    if (u is Map) return u.cast<String, Object?>();
    return null;
  }

  /// Extracts model output text from the Responses API shape (best-effort),
  /// with a fallback to Chat Completions shape to keep this robust.
  static String? _extractOutputText(Map<String, Object?> response) {
    final direct = response['output_text'];
    if (direct is String) return direct;

    // Fallback: Chat Completions { choices: [{ message: { content: ... } }]}
    final choices = response['choices'];
    if (choices is List && choices.isNotEmpty) {
      final first = choices.first;
      if (first is Map) {
        final msg = first['message'];
        if (msg is Map) {
          final content = msg['content'];
          if (content is String) return content;
          if (content is List) {
            final buf = StringBuffer();
            for (final part in content) {
              if (part is Map && part['text'] is String) {
                buf.write(part['text']);
              }
            }
            final s = buf.toString();
            if (s.isNotEmpty) return s;
          }
        }
      }
    }

    // Fallback: Responses { output: [{ type: "message", content: [...] }]}
    final output = response['output'];
    if (output is List) {
      for (final item in output) {
        if (item is! Map) continue;
        if (item['type'] != 'message') continue;
        final content = item['content'];
        if (content is! List) continue;
        final buf = StringBuffer();
        for (final part in content) {
          if (part is! Map) continue;
          final t = part['text'];
          if (t is String) buf.write(t);
        }
        final s = buf.toString();
        if (s.isNotEmpty) return s;
      }
    }

    return null;
  }

  static Future<OpenAiTransportResponse> _defaultTransport({
    required Uri uri,
    required Map<String, String> headers,
    required String body,
    required Duration timeout,
  }) async {
    final client = HttpClient();
    try {
      final request = await client.postUrl(uri).timeout(timeout);
      headers.forEach(request.headers.set);
      request.write(body);

      final response = await request.close().timeout(timeout);
      final responseBody = await response.transform(utf8.decoder).join().timeout(
        timeout,
      );
      return OpenAiTransportResponse(
        statusCode: response.statusCode,
        body: responseBody,
      );
    } finally {
      client.close(force: true);
    }
  }
}

final class _MapperOutput {
  final List<AicrFinding> findings;
  final String? errorMessage;

  const _MapperOutput({required this.findings, this.errorMessage});
}

/// Maps strict JSON schema into `AicrFinding`.
final class _OpenAiJsonFindingMapper {
  static _MapperOutput fromStrictJson({
    required Map<String, Object?> strictJson,
    required String diffHash,
    required int maxFindings,
  }) {
    final findingsRaw = strictJson['findings'];
    if (findingsRaw == null) {
      return const _MapperOutput(
        findings: <AicrFinding>[],
        errorMessage: 'Strict JSON missing "findings"',
      );
    }
    if (findingsRaw is! List) {
      return const _MapperOutput(
        findings: <AicrFinding>[],
        errorMessage: '"findings" must be a list',
      );
    }

    final out = <AicrFinding>[];
    for (final item in findingsRaw) {
      if (out.length >= maxFindings) break;
      if (item is! Map) continue;

      final title = item['title'];
      final description = item['description'];
      final severityRaw = item['severity'];
      final categoryRaw = item['category'];
      final fileRaw = item['file'];
      final lineRaw = item['line'];

      if (title is! String || title.trim().isEmpty) continue;
      if (description is! String || description.trim().isEmpty) continue;
      if (severityRaw is! String) continue;
      if (categoryRaw is! String) continue;

      final category = _mapCategory(categoryRaw);
      if (category == null) continue;

      final severity = _mapSeverity(severityRaw) ?? AicrSeverity.warning;

      String? filePath;
      if (fileRaw == null) {
        filePath = null;
      } else if (fileRaw is String) {
        final trimmed = fileRaw.trim();
        filePath = trimmed.isEmpty ? null : trimmed;
      } else {
        continue;
      }

      int? line;
      if (lineRaw == null) {
        line = null;
      } else if (lineRaw is num) {
        line = lineRaw.toInt();
      } else {
        continue;
      }

      final idSeed =
          'openai|$diffHash|$title|$categoryRaw|$severityRaw|${filePath ?? 'null'}|${line ?? 'null'}';
      final digest = sha256.convert(utf8.encode(idSeed)).toString();
      final id = 'ai_openai:${digest.substring(0, 12)}';

      out.add(
        AicrFinding(
          id: id,
          category: category,
          severity: severity,
          title: title.trim(),
          messageTr: description,
          messageEn: description,
          filePath: filePath,
          lineStart: line,
          lineEnd: line,
          sourceId: 'ai_openai',
          source: AicrFindingSource.ai,
          confidence: null,
        ),
      );
    }

    return _MapperOutput(findings: out);
  }

  static AicrCategory? _mapCategory(String raw) => switch (raw.trim()) {
    'architecture' => AicrCategory.architecture,
    'testing' => AicrCategory.testing,
    'security' => AicrCategory.security,
    'performance' => AicrCategory.performance,
    'dx' => AicrCategory.dx,
    'quality' => AicrCategory.quality,
    _ => null,
  };

  static AicrSeverity? _mapSeverity(String raw) => switch (raw.trim()) {
    'info' => AicrSeverity.info,
    'warning' => AicrSeverity.warning,
    // AI must not create critical alone; map error -> warning.
    'error' => AicrSeverity.warning,
    _ => null,
  };
}


