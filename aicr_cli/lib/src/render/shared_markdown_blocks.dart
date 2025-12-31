import '../report/aicr_report.dart';
import 'markdown_builder.dart';

/// Shared markdown blocks used by renderers.
///
/// Goal: reduce duplication while keeping output identical.
final class SharedMarkdownBlocks {
  static String _shorten(String s, int maxLen) =>
      s.length > maxLen ? s.substring(0, maxLen) : s;

  static void metaHeaderBlock(MarkdownBuilder md, AicrReport report) {
    final runIdShort = _shorten(report.meta.runId, 14);
    final diffHashShort = _shorten(report.meta.diffHash, 12);

    md.p(
      '**Repo:** ${report.meta.repoName} · '
      '**Run:** $runIdShort · '
      '**Files:** ${report.meta.fileCount} · '
      '**AI:** ${report.meta.aiEnabled ? 'ON' : 'OFF'} (mode: ${report.meta.aiMode}) · '
      '**Diff:** `$diffHashShort`',
    );
  }

  static void riskConfidenceSummaryBlock(
    MarkdownBuilder md, {
    required String riskLevel,
    required String overallConfidenceText,
  }) {
    md.p(
      '**Risk level:** $riskLevel · '
      '**Overall confidence:** $overallConfidenceText',
    );
  }

  static void signalsTableBlock(
    MarkdownBuilder md,
    AicrReport report, {
    required int aiCount,
  }) {
    md.table(
      const ['Signal', 'Pass', 'Warn', 'Fail'],
      [
        [
          'Deterministic',
          report.summary.ruleResults.pass.toString(),
          report.summary.ruleResults.warn.toString(),
          report.summary.ruleResults.fail.toString(),
        ],
        ['AI (findings)', '-', aiCount.toString(), '-'],
      ],
    );
  }
}
