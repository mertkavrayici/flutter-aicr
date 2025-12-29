import '../ai/ai.dart';
import '../diff/diff_parser.dart';
import '../finding/aicr_finding.dart';
import '../report/aicr_report.dart';
import '../report/aicr_report_builder.dart';
import '../rules/rules.dart';

final class AicrEngine {
  static Future<AicrReport> analyze({
    required String diffText,
    required bool aiEnabled,
    required String repoName,
    required AiLanguage language,
    List<FileEntry>? files, // ✅ CLI’dan gelebilir
    AiReviewer? aiReviewer, // ✅ opsiyonel, default Noop (legacy)
    AiReviewService?
    aiReviewService, // ✅ opsiyonel, default DeterministicAiReviewService
  }) async {
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
    final changedFiles = resolvedFiles
        .map((e) => e.path)
        .toList(growable: false);

    // 3) Rules (deterministic)
    final rules = <AicrRule>[
      BlocChangeRequiresTestsRule(),
      SecretOrEnvExposureRule(),
      LargeChangeSetRule(warnFileThreshold: 15),
      UiChangeSuggestsGoldenTestsRule(),
      LayerViolationRule(),
      LargeDiffSuggestsSplitRule(),
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
      ruleResults: ruleResults,
      aiFindings: const [], // Will be populated from AiReview if enabled
    );

    final reportWithoutAi = builder.build();

    // 6) Generate AI review if enabled
    AiReview? aiReview;
    List<AicrFinding> aiFindings = const [];

    if (aiEnabled) {
      final service = aiReviewService ?? DeterministicAiReviewService();
      try {
        aiReview = await service.generate(
          diffText: diffText,
          report: reportWithoutAi,
          language: language,
        );
        // Convert AiReview to findings for compatibility
        aiFindings = AiReviewMapper.toFindings(aiReview);

        // Also keep legacy AiReviewer findings if provided (for backward compatibility)
        if (aiReviewer != null && aiReviewer is! NoopAiReviewer) {
          final legacyFindings = await _safeAiReview(
            reviewer: aiReviewer,
            input: AiReviewInput(
              repoName: repoName,
              diffText: diffText,
              changedFiles: changedFiles,
            ),
          );
          // Merge with AiReview findings
          aiFindings = [...aiFindings, ...legacyFindings];
        }
      } catch (_) {
        // AI review generation failed, continue without it
      }
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

  static Future<List<AicrFinding>> _safeAiReview({
    required AiReviewer reviewer,
    required AiReviewInput input,
  }) async {
    try {
      return await reviewer.review(input);
    } catch (_) {
      // AI katmanı "best effort": analyze'ı asla patlatmasın.
      return const <AicrFinding>[];
    }
  }

  static List<AicrFinding> _mergeFindings({
    required List<AicrFinding> deterministic,
    required List<AicrFinding> ai,
  }) {
    // deterministic önce: ana "gerçeklik" bu; AI tamamlayıcı.
    final merged = <AicrFinding>[...deterministic, ...ai];

    return _dedupeById(merged);
  }

  static List<AicrFinding> _dedupeById(List<AicrFinding> items) {
    final seen = <String>{};
    final out = <AicrFinding>[];

    for (final f in items) {
      if (seen.add(f.id)) {
        out.add(f);
      }
    }

    return out;
  }
}
