import '../ai/ai.dart';
import '../diff/diff_parser.dart';
import '../finding/aicr_finding.dart';
import '../report/aicr_report.dart';
import '../report/aicr_report_builder.dart';
import '../rules/rules.dart';

final class AicrEngine {
  static bool _isGeneratedDartFilePath(String path) {
    final p = path.replaceAll('\\', '/').toLowerCase().trim();
    // Generated Dart sources should not influence heuristic rules.
    return p.endsWith('.g.dart') || p.endsWith('.freezed.dart');
  }

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
      HighEntropySecretRule(),
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
    // Start with deterministic findings (source of truth)
    final merged = <AicrFinding>[...deterministic];

    // Process each AI finding
    for (final aiFinding in ai) {
      // AI cannot create FAIL alone - skip critical severity findings
      if (aiFinding.severity == AicrSeverity.critical) {
        continue;
      }

      // Try to find matching deterministic finding to enrich
      bool enriched = false;
      for (int i = 0; i < merged.length; i++) {
        final detFinding = merged[i];

        // Check if AI finding matches deterministic finding
        if (aiFinding.isSimilarTo(detFinding)) {
          // Enrich deterministic finding with AI structured fields
          merged[i] = _enrichFinding(detFinding, aiFinding);
          enriched = true;
          break;
        }
      }

      // If no match found, add AI finding as new (only if WARN or lower)
      if (!enriched && aiFinding.severity != AicrSeverity.critical) {
        merged.add(aiFinding);
      }
    }

    // Final deduplication by ID (fallback)
    return _dedupeById(merged);
  }

  /// Enriches a deterministic finding with AI structured fields.
  /// Preserves deterministic severity and other fields, adds AI's structured data.
  static AicrFinding _enrichFinding(AicrFinding deterministic, AicrFinding ai) {
    return deterministic.copyWith(
      // Preserve deterministic severity - AI cannot change it
      // Add AI structured fields if not already present
      area: deterministic.area ?? ai.area,
      risk: deterministic.risk ?? ai.risk,
      reason: deterministic.reason ?? ai.reason,
      suggestedAction: deterministic.suggestedAction ?? ai.suggestedAction,
      confidence: deterministic.confidence ?? ai.confidence,
      // Optionally enrich messages if AI provides better context
      // (but keep deterministic messages as primary)
    );
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
