import '../../aicr_cli.dart';
import 'markdown_builder.dart';

final class PrCommentRenderer {
  String render(AicrReport report, {String locale = 'en'}) {
    final md = MarkdownBuilder();

    final status = report.summary.status.name.toUpperCase();
    md.h2('AICR — $status');

    final runIdShort = report.meta.runId.length > 14
        ? report.meta.runId.substring(0, 14)
        : report.meta.runId;

    md.p(
      '**Repo:** ${report.meta.repoName} · '
      '**Run:** $runIdShort · '
      '**Files:** ${report.meta.fileCount} · '
      '**AI:** ${report.meta.aiEnabled ? 'ON' : 'OFF'}',
    );

    md.table(
      const ['Signal', 'Pass', 'Warn', 'Fail'],
      [
        [
          'Deterministic',
          report.summary.ruleResults.pass.toString(),
          report.summary.ruleResults.warn.toString(),
          report.summary.ruleResults.fail.toString(),
        ],
        ['AI (findings)', '-', _aiCount(report).toString(), '-'],
      ],
    );

    md.h3('Review recommended');
    md.p(_reviewRecommendation(report));

    final top = _topFindings(report, limit: 5);
    if (top.isNotEmpty) {
      md.h3('Top actions');
      for (final f in top) {
        final tag = _isAi(f) ? ' (AI${_conf(f)})' : '';
        md.bullet('**${f.title}**$tag — ${_msg(f, locale)}');
      }
      md.nl();
    }

    md.h3('All findings');
    final grouped = _groupByCategory(report.findings);
    if (grouped.isEmpty) {
      md.p('No findings ✅');
      return md.toString();
    }

    for (final entry in grouped.entries) {
      md.p('**${entry.key.name}**');

      final items = [...entry.value]
        ..sort((a, b) => _sevRank(b.severity).compareTo(_sevRank(a.severity)));

      for (final f in items) {
        final tag = _isAi(f) ? ' (AI${_conf(f)})' : '';
        md.bullet(
          '`${f.severity.name}` **${f.title}**$tag — ${_msg(f, locale)}',
        );
      }
      md.nl();
    }

    return md.toString();
  }

  int _aiCount(AicrReport report) => report.findings.where(_isAi).length;

  bool _isAi(AicrFinding f) => (f.sourceId ?? '').startsWith('ai');

  String _conf(AicrFinding f) =>
      f.confidence == null ? '' : ', ${(f.confidence! * 100).round()}%';

  String _msg(AicrFinding f, String locale) =>
      locale == 'tr' ? f.messageTr : f.messageEn;

  String _reviewRecommendation(AicrReport report) {
    final fail = report.summary.ruleResults.fail;
    final warn = report.summary.ruleResults.warn;
    final ai = _aiCount(report);

    if (fail > 0) return '🟥 **Required** — failing rules detected.';
    if (warn > 0) return '🟨 **Recommended** — warnings detected.';
    if (ai > 0) return '🟦 **Optional** — AI suggestions only.';
    return '🟩 **Not needed** — no signals detected.';
  }

  List<AicrFinding> _topFindings(AicrReport report, {required int limit}) {
    final sorted = [...report.findings]
      ..sort((a, b) {
        final sa = _sevRank(a.severity);
        final sb = _sevRank(b.severity);
        if (sa != sb) return sb.compareTo(sa);
        final aa = _isAi(a) ? 0 : 1; // deterministic önce
        final bb = _isAi(b) ? 0 : 1;
        return bb.compareTo(aa);
      });
    return sorted.take(limit).toList(growable: false);
  }

  int _sevRank(AicrSeverity s) => switch (s) {
    AicrSeverity.critical => 4,
    AicrSeverity.warning => 3,
    AicrSeverity.suggestion => 2,
    AicrSeverity.info => 1,
  };

  Map<AicrCategory, List<AicrFinding>> _groupByCategory(
    List<AicrFinding> findings,
  ) {
    final m = <AicrCategory, List<AicrFinding>>{};
    for (final f in findings) {
      (m[f.category] ??= <AicrFinding>[]).add(f);
    }
    return m;
  }
}
