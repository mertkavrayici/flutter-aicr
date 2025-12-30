part of '../pr_comment_renderer.dart';

final class TopActionsSection {
  void render(
    MarkdownBuilder md,
    AicrReport report, {
    required String locale,
    required List<AicrFinding> top,
    required bool Function(AicrFinding) isAi,
    required String Function(AicrFinding) confTag,
    required String Function(AicrFinding, String) msg,
  }) {
    if (top.isEmpty) return;

    md.h3('Top actions');
    for (final f in top) {
      final tag = isAi(f) ? ' (AI${confTag(f)})' : '';
      md.bullet('**${f.title}**$tag — ${msg(f, locale)}');
    }
    md.nl();
  }
}


