part of '../pr_comment_renderer.dart';

final class _RiskLevelCalculator {
  final int Function(AicrSeverity) sevRank;

  const _RiskLevelCalculator({required this.sevRank});

  String calculate(AicrReport report) {
    final fail = report.summary.ruleResults.fail;
    final warn = report.summary.ruleResults.warn;
    final criticalCount =
        report.findings.where((f) => f.severity == AicrSeverity.critical).length;

    if (fail > 0 || criticalCount > 0) {
      return '🔴 **High**';
    }
    if (warn > 0) {
      final warningCount =
          report.findings.where((f) => f.severity == AicrSeverity.warning).length;
      if (warningCount >= 3) {
        return '🟡 **Medium**';
      }
      return '🟢 **Low**';
    }
    return '🟢 **Low**';
  }
}


