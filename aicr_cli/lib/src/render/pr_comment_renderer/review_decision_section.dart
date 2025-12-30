part of '../pr_comment_renderer.dart';

final class ReviewDecisionSection {
  void render(
    MarkdownBuilder md,
    AicrReport report, {
    required double? overallConfidence,
    required String decisionText,
  }) {
    md.h3('Review recommended');
    md.p(decisionText);
  }
}


