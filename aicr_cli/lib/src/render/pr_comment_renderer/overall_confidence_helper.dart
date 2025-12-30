part of '../pr_comment_renderer.dart';

final class _OverallConfidenceHelper {
  final bool Function(AicrFinding) isAi;
  final int Function(AicrSeverity) sevRank;

  const _OverallConfidenceHelper({
    required this.isAi,
    required this.sevRank,
  });

  double? calculate(AicrReport report) {
    final aiFindings = report.findings
        .where(isAi)
        .where((f) => f.confidence != null)
        .toList(growable: false);

    if (aiFindings.isEmpty) return null;

    double weightedSum = 0.0;
    double totalWeight = 0.0;

    for (final f in aiFindings) {
      final confidence = f.confidence!;
      final weight = sevRank(f.severity).toDouble();
      weightedSum += confidence * weight;
      totalWeight += weight;
    }

    if (totalWeight == 0) return null;
    return weightedSum / totalWeight;
  }

  String format(double? overallConfidence) {
    if (overallConfidence == null) return 'N/A';
    return '${(overallConfidence * 100).round()}%';
  }
}


