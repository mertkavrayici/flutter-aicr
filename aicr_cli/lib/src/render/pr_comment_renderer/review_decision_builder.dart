part of '../pr_comment_renderer.dart';

final class _ReviewDecisionBuilder {
  final int Function(AicrReport) aiCount;
  final _OverallConfidenceHelper confidence;

  const _ReviewDecisionBuilder({
    required this.aiCount,
    required this.confidence,
  });

  String build(
    AicrReport report, {
    required double? overallConfidence,
  }) {
    final fail = report.summary.ruleResults.fail;
    final warn = report.summary.ruleResults.warn;
    final ai = aiCount(report);

    if (fail > 0) {
      return '🟥 **Required** — failing rules detected.';
    }

    if (warn > 0) {
      final hasHighSeverity = report.findings.any(
        (f) =>
            f.severity == AicrSeverity.critical ||
            f.severity == AicrSeverity.warning,
      );

      final hasConfidenceSignal =
          overallConfidence != null && overallConfidence > 0.6;

      if (hasHighSeverity || hasConfidenceSignal) {
        // Copy fix: confidence is only mentioned when we actually have a confidence signal.
        if (hasHighSeverity && hasConfidenceSignal) {
          return '🟨 **Recommended** — warnings detected with high severity or confidence.';
        }
        if (hasHighSeverity) {
          return '🟨 **Recommended** — warnings detected with high severity.';
        }
        return '🟨 **Recommended** — warnings detected with high confidence.';
      }

      return '🟦 **Optional** — low-severity warnings detected.';
    }

    if (ai > 0) {
      return '🟦 **Optional** — AI suggestions only.';
    }

    return '🟩 **Not needed** — no signals detected.';
  }
}


