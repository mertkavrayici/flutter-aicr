part of '../pr_comment_builder.dart';

final class _ReviewDecisionBuilder {
  final int Function(AicrReport) aiCount;
  final _OverallConfidenceHelper confidence;
  final bool Function(AicrFinding) isAi;

  const _ReviewDecisionBuilder({
    required this.aiCount,
    required this.confidence,
    required this.isAi,
  });

  String build(AicrReport report, {required double? overallConfidence}) {
    final fail = report.summary.ruleResults.fail;
    final warn = report.summary.ruleResults.warn;
    final ai = aiCount(report);

    // Net rules:
    // - Deterministic warn/fail => Recommended
    // - No deterministic warn/fail, but AI findings exist => Optional
    // - No findings => Not needed
    if (fail > 0 || warn > 0) {
      return '🟨 **Recommended** — deterministic signals detected.';
    }

    if (ai > 0) {
      return '🟦 **Optional** — AI findings only.';
    }

    return '🟩 **Not needed** — no findings.';
  }
}


