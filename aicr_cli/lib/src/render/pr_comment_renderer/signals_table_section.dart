part of '../pr_comment_renderer.dart';

final class SignalsTableSection {
  void render(MarkdownBuilder md, AicrReport report, {required int aiCount}) {
    SharedMarkdownBlocks.signalsTableBlock(md, report, aiCount: aiCount);
  }
}


