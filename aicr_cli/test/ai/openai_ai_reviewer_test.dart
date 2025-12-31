import 'dart:convert';

import 'package:test/test.dart';

import 'package:aicr_cli/src/ai/ai.dart';
import 'package:aicr_cli/src/finding/models/aicr_finding.dart';

void main() {
  test('missing API key -> safe empty result', () async {
    final reviewer = OpenAiAiReviewer(
      transport: ({
        required uri,
        required headers,
        required body,
        required timeout,
      }) async {
        fail('transport must not be called when OPENAI_API_KEY is missing');
      },
    );

    final result = await reviewer.review(
      const AiReviewRequest(
        repoName: 'repo',
        diffHash: 'hash',
        diffText: 'diff',
        maxFindings: 3,
        maxInputChars: 1000,
        maxOutputTokens: 200,
        timeoutMs: 1000,
      ),
    );

    expect(result.findings, isEmpty);
    expect(result.errorMessage, isNotNull);
  });

  test('valid JSON -> findings parsed', () async {
    final reviewer = OpenAiAiReviewer(
      apiKeyOverride: 'test-key',
      transport: _fakeTransport(
        statusCode: 200,
        responseBody: jsonEncode({
          'model': 'gpt-4o-mini',
          'output_text': jsonEncode({
            'findings': [
              {
                'title': 'Use const constructors',
                'description': 'Consider making widgets const where possible.',
                'severity': 'info',
                'category': 'dx',
                'file': 'lib/a.dart',
                'line': 12,
              },
              {
                'title': 'Potential secret',
                'description': 'Looks like a token might be committed.',
                'severity': 'error',
                'category': 'security',
                'file': null,
                'line': null,
              },
            ],
          }),
          'usage': {'input_tokens': 1, 'output_tokens': 2},
        }),
      ),
    );

    final result = await reviewer.review(
      const AiReviewRequest(
        repoName: 'repo',
        diffHash: 'hash',
        diffText: 'diff --git a/lib/a.dart b/lib/a.dart',
        maxFindings: 10,
        maxInputChars: 1000,
        maxOutputTokens: 200,
        timeoutMs: 1000,
      ),
    );

    expect(result.errorMessage, isNull);
    expect(result.findings.length, 2);

    final first = result.findings.first;
    expect(first.category, AicrCategory.dx);
    expect(first.severity, AicrSeverity.info);
    expect(first.filePath, 'lib/a.dart');
    expect(first.lineStart, 12);
    expect(first.source, AicrFindingSource.ai);

    // error -> warning mapping (AI must not create critical alone)
    final second = result.findings.last;
    expect(second.category, AicrCategory.security);
    expect(second.severity, AicrSeverity.warning);
  });

  test('invalid JSON -> no crash, empty result', () async {
    final reviewer = OpenAiAiReviewer(
      apiKeyOverride: 'test-key',
      transport: _fakeTransport(
        statusCode: 200,
        responseBody: jsonEncode({
          'model': 'gpt-4o-mini',
          'output_text': 'NOT JSON',
        }),
      ),
    );

    final result = await reviewer.review(
      const AiReviewRequest(
        repoName: 'repo',
        diffHash: 'hash',
        diffText: 'diff',
        maxFindings: 3,
        maxInputChars: 1000,
        maxOutputTokens: 200,
        timeoutMs: 1000,
      ),
    );

    expect(result.findings, isEmpty);
    expect(result.errorMessage, isNotNull);
  });
}

Future<OpenAiTransportResponse> Function({
  required Uri uri,
  required Map<String, String> headers,
  required String body,
  required Duration timeout,
}) _fakeTransport({
  required int statusCode,
  required String responseBody,
}) {
  return ({
    required Uri uri,
    required Map<String, String> headers,
    required String body,
    required Duration timeout,
  }) async {
    return OpenAiTransportResponse(statusCode: statusCode, body: responseBody);
  };
}


