part of '../pr_comment_renderer.dart';

final class FindingsSection {
  void render(
    MarkdownBuilder md,
    AicrReport report, {
    required String locale,
    required int Function(AicrSeverity) sevRank,
    required bool Function(AicrFinding) isAi,
    required String Function(AicrFinding) confTag,
    required String Function(AicrFinding, String) msg,
  }) {
    md.h3('All findings');

    final grouped = _groupByCategory(report.findings);
    if (grouped.isEmpty) {
      md.p('No findings ✅');
      return;
    }

    for (final entry in grouped.entries) {
      md.p('**${entry.key.name}**');

      final items = [...entry.value]
        ..sort((a, b) => sevRank(b.severity).compareTo(sevRank(a.severity)));

      for (final f in items) {
        final tag = isAi(f) ? ' (AI${confTag(f)})' : '';
        md.bullet(
          '`${f.severity.name}` **${f.title}**$tag — ${msg(f, locale)}',
        );
      }
      md.nl();
    }
  }
}

Map<AicrCategory, List<AicrFinding>> _groupByCategory(
  List<AicrFinding> findings,
) {
  final m = <AicrCategory, List<AicrFinding>>{};
  for (final f in findings) {
    (m[f.category] ??= <AicrFinding>[]).add(f);
  }
  return m;
}


