import 'dart:convert';

import 'package:crypto/crypto.dart';

import '../ai/ai.dart';
import '../diff/diff_parser.dart';
import '../finding/aicr_finding.dart';
import '../report/aicr_report.dart';
import '../report/aicr_report_builder.dart';
import '../rules/rules.dart';
import '../util/aicr_logger.dart';
import '../profile/aicr_project_profile.dart';

final class AicrEngine {
  static bool _isGeneratedDartFilePath(String path) {
    final p = path.replaceAll('\\', '/').toLowerCase().trim();
    // Generated Dart sources should not influence heuristic rules.
    return p.endsWith('.g.dart') || p.endsWith('.freezed.dart');
  }

  static Future<AicrReport> analyze({
    required String diffText,
    required bool aiEnabled,
    AiMode aiMode = AiMode.noop,
    required String repoName,
    required AiLanguage language,
    List<FileEntry>? files, // ✅ CLI'dan gelebilir
    AiReviewer? aiReviewer,
    AiReviewService?
    aiReviewService, // ✅ opsiyonel, default DeterministicAiReviewService
    AicrLogger logger = const AicrLogger.none(),
    AicrProjectProfile projectProfile = AicrProjectProfile.empty,
    bool postComment = false,
    String commentMode = 'update',
    String commentMarker = 'AICR_COMMENT',
  }) async {
    final effectiveAiMode = aiEnabled ? aiMode : AiMode.noop;
    final reviewer = aiReviewer ??
        AiReviewerFactory().create(
          effectiveAiMode,
          logger: logger,
          projectProfile: projectProfile,
        );
    // 1) Files’ı belirle: CLI verdiyse gerçek, yoksa diffText fallback
    final resolvedFiles = (files != null && files.isNotEmpty)
        ? files
        : DiffParser.parseChangedFiles(diffText)
              .map(
                (p) => FileEntry.fromStringChangeType(
                  path: p,
                  changeType: 'modified',
                ),
              )
              .toList(growable: false);

    // 2) Rule’ların istediği format: List<String> changedFiles
    final changedFilesAll = resolvedFiles
        .map((e) => e.path)
        .toList(growable: false);

    // Generated sources (e.g. *.g.dart, *.freezed.dart) should not be targets
    // of heuristic rules; filter them out of the rules' changedFiles list.
    // Report/meta still keeps original file list for transparency.
    final changedFiles = changedFilesAll
        .where((p) => !_isGeneratedDartFilePath(p))
        .toList(growable: false);

    // 3) Rules (deterministic)
    final rules = <AicrRule>[
      BlocChangeRequiresTestsRule(),
      SecretOrEnvExposureRule(),
      DiffSecretPatternsRule(),
      HighEntropySecretRule(),
      LargeChangeSetRule(warnFileThreshold: 15),
      UiChangeSuggestsGoldenTestsRule(),
      LayerViolationRule(),
      LargeDiffSuggestsSplitRule(),
      PublicApiChangeRequiresDocsRule(),
    ];

    // 4) Evaluate rules -> RuleResult listesi
    final ruleResults = rules
        .map((r) => r.evaluate(changedFiles: changedFiles, diffText: diffText))
        .toList(growable: false);

    // 5) Build initial report (without AI review)
    final builder = AicrReportBuilder(
      repoName: repoName,
      diffText: diffText,
      files: resolvedFiles,
      aiEnabled: aiEnabled,
      aiMode: effectiveAiMode.name,
      ruleResults: ruleResults,
      aiFindings: const [], // Will be populated from AiReview if enabled
      postComment: postComment,
      commentMode: commentMode,
      commentMarker: commentMarker,
    );

    final reportWithoutAi = builder.build();

    // 6) Generate AI review if enabled
    AiReview? aiReview;
    List<AicrFinding> aiFindings = const [];

    if (aiEnabled) {
      // AI findings must ONLY come from AiReviewer.
      // (Noop mode => empty list)
      //
      // We may still compute `aiReview` (report-level summary) for non-noop
      // modes, but we DO NOT map it into AicrFinding list.
      if (effectiveAiMode != AiMode.noop) {
        final service = aiReviewService ?? DeterministicAiReviewService();
        try {
          aiReview = await service.generate(
            diffText: diffText,
            report: reportWithoutAi,
            language: language,
          );
        } catch (e) {
          logger.warn('AiReviewService failed: $e');
          aiReview = null;
        }
      } else {
        aiReview = null;
      }

      final diffHash = sha256.convert(utf8.encode(diffText)).toString();

      final result = await _safeAiReview(
        reviewer: reviewer,
        request: AiReviewRequest(
          repoName: repoName,
          diffHash: diffHash,
          diffText: diffText,
          maxFindings: 10,
          language: language.code,
          maxInputChars: 120_000,
          maxOutputTokens: 2_000,
          timeoutMs: 15_000,
        ),
        logger: logger,
      );

      final aiCount = result.findings.length;
      logger.info('AI: $aiCount findings (mode: ${effectiveAiMode.name})');
      if (logger.verbose) {
        logger.info('AI: truncated=${result.truncated}');
        final err = result.errorMessage;
        if (err != null && err.trim().isNotEmpty) {
          logger.info('AI: error=${_sanitizeAiError(err)}');
        }
      }

      aiFindings = result.findings;
    }

    // 7) Build final report with AI review and findings
    return AicrReport(
      meta: reportWithoutAi.meta,
      summary: reportWithoutAi.summary,
      rules: reportWithoutAi.rules,
      findings: _mergeFindings(
        deterministic: reportWithoutAi.findings,
        ai: aiFindings,
      ),
      contracts: reportWithoutAi.contracts,
      files: reportWithoutAi.files,
      recommendations: reportWithoutAi.recommendations,
      aiReview: aiReview,
    );
  }

  static Future<AiReviewResult> _safeAiReview({
    required AiReviewer reviewer,
    required AiReviewRequest request,
    AicrLogger logger = const AicrLogger.none(),
  }) async {
    try {
      return await reviewer.review(request);
    } catch (e) {
      logger.warn('AiReviewer failed: $e');
      // AI katmanı "best effort": analyze'ı asla patlatmasın.
      return AiReviewResult.error(errorMessage: e.toString());
    }
  }

  static String _sanitizeAiError(String input) {
    // Collapse whitespace (avoid multi-line logs).
    var s = input.replaceAll(RegExp(r'\s+'), ' ').trim();
    // Redact any accidental bearer token-looking fragments.
    s = s.replaceAll(
      RegExp(r'Bearer\s+[^\\s]+', caseSensitive: false),
      'Bearer ***REDACTED***',
    );
    // Clip to keep logs short.
    const maxLen = 300;
    if (s.length > maxLen) s = '${s.substring(0, maxLen)}...';
    return s;
  }

  /// Merges deterministic and AI findings with intelligent deduplication.
  ///
  /// Merge rules:
  /// - Deterministic findings are the source of truth (severity preserved)
  /// - AI findings can enrich existing deterministic findings (add area, risk, reason, suggestedAction, confidence)
  /// - AI findings can add new findings only if WARN or lower severity (AI cannot create FAIL alone)
  /// - Deduplication: same area + similar title/risk => single finding
  static List<AicrFinding> _mergeFindings({
    required List<AicrFinding> deterministic,
    required List<AicrFinding> ai,
  }) {
    // Deterministic findings are the source of truth.
    // AI findings are supplemental and must not duplicate deterministic topics.
    final det = deterministic;

    // AI cannot create FAIL alone:
    // if AI returns critical, downgrade to warning (deterministic critical stays as-is).
    final aiNormalized = ai
        .map(
          (f) => f.severity == AicrSeverity.critical
              ? f.copyWith(severity: AicrSeverity.warning)
              : f,
        )
        .toList(growable: false);

    // Topic dedupe (deterministic > AI):
    // - same ruleId (sourceId) OR same normalized title => keep deterministic, drop AI
    final merged = <AicrFinding>[
      ...det,
      ..._filterAiByTopicDedup(deterministic: det, ai: aiNormalized),
    ];

    // Duplicate control (NEVER by `id`):
    // signature key:
    // - source
    // - category, severity, title
    // - messageEn (normalized: trim/lowercase/collapse spaces)
    // - filePath (including null)
    //
    // This also applies to report-level findings where filePath is null
    // (e.g. `ai_review`, `ai_review_action`).
    return _dedupeBySignature(merged);
  }

  static String _normalizeTitle(String s) {
    // Lowercase, trim, strip punctuation into spaces, collapse whitespace.
    final lower = s.toLowerCase().trim();
    final noPunct = lower.replaceAll(RegExp(r'[^\w\s]+'), ' ');
    return noPunct.replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  static List<AicrFinding> _filterAiByTopicDedup({
    required List<AicrFinding> deterministic,
    required List<AicrFinding> ai,
  }) {
    final detRuleIds = deterministic
        .map((f) => (f.sourceId ?? '').trim())
        .where((s) => s.isNotEmpty)
        .toSet();

    final seenTitles = <String>{};
    for (final f in deterministic) {
      final t = _normalizeTitle(f.title);
      if (t.isNotEmpty) seenTitles.add(t);
    }

    final kept = <AicrFinding>[];
    for (final f in ai) {
      // If AI reuses a deterministic ruleId, deterministic must win.
      final sourceId = (f.sourceId ?? '').trim();
      if (sourceId.isNotEmpty && detRuleIds.contains(sourceId)) {
        continue;
      }

      final t = _normalizeTitle(f.title);
      if (t.isNotEmpty && seenTitles.contains(t)) {
        continue;
      }

      // Also dedupe within AI by normalized title (keep first).
      if (t.isNotEmpty && !seenTitles.add(t)) {
        continue;
      }

      kept.add(f);
    }

    return kept;
  }

  static String _normalizeMsgEn(String s) =>
      s.toLowerCase().trim().replaceAll(RegExp(r'\s+'), ' ');

  static String? _normalizePath(String? p) {
    if (p == null) return null;
    final n = p.replaceAll('\\', '/').trim();
    return n.isEmpty ? null : n.toLowerCase();
  }

  static List<AicrFinding> _dedupeBySignature(List<AicrFinding> items) {
    final seen = <String>{};
    final out = <AicrFinding>[];

    for (final f in items) {
      final source = f.source?.name ?? 'null';
      final category = f.category.name;
      final severity = f.severity.name;
      final title = f.title;
      final msgEn = _normalizeMsgEn(f.messageEn);
      final file = _normalizePath(f.filePath); // may be null

      final key = '$source|$category|$severity|$title|$msgEn|${file ?? 'null'}';

      if (seen.add(key)) {
        out.add(f);
      }
    }

    return out;
  }
}
