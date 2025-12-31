part of '../pr_comment_renderer.dart';

final class _OverallConfidenceHelper {
  final bool Function(AicrFinding) isAi;
  final int Function(AicrSeverity) sevRank;

  const _OverallConfidenceHelper({required this.isAi, required this.sevRank});

  /// Always returns a score in 0..1.
  ///
  /// - Deterministic: computed from pass/warn/fail distribution.
  /// - AI (fake): if AI mode is `fake`, low AI finding count yields low confidence.
  double calculate(AicrReport report) {
    final det = _deterministicConfidence(report);
    final ai = _aiHeuristicConfidence(report);
    if (ai == null) return det;

    // Deterministic is the source of truth; AI is a small modifier only.
    final combined = det * 0.85 + ai * 0.15;
    return combined.clamp(0.0, 1.0);
  }

  String format(double overallConfidence) {
    return '${(overallConfidence * 100).round()}%';
  }

  double _deterministicConfidence(AicrReport report) {
    final pass = report.summary.ruleResults.pass;
    final warn = report.summary.ruleResults.warn;
    final fail = report.summary.ruleResults.fail;
    final total = pass + warn + fail;
    if (total == 0) return 1.0;

    // Simple weighted score:
    // - pass: 1.0
    // - warn: 0.7
    // - fail: 0.1
    final score = (pass * 1.0 + warn * 0.7 + fail * 0.1) / total;
    return score.clamp(0.0, 1.0);
  }

  double? _aiHeuristicConfidence(AicrReport report) {
    if (!report.meta.aiEnabled) return null;
    if (report.meta.aiMode != 'fake') return null;

    // Fake reviewer is heuristic-based; low count => low confidence.
    final aiCount = report.findings.where(isAi).length;
    if (aiCount <= 0) return 0.20;
    if (aiCount == 1) return 0.30;
    if (aiCount == 2) return 0.40;
    return 0.50; // 3+
  }
}
