part of '../pr_comment_renderer.dart';

final class MetaSection {
  void render(
    MarkdownBuilder md,
    AicrReport report, {
    required String riskLevel,
    required double? overallConfidence,
    required String overallConfidenceText,
  }) {
    SharedMarkdownBlocks.metaHeaderBlock(md, report);
    SharedMarkdownBlocks.riskConfidenceSummaryBlock(
      md,
      riskLevel: riskLevel,
      overallConfidenceText: overallConfidenceText,
    );
  }
}


