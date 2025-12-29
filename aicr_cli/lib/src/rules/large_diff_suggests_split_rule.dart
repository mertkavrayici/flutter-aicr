import 'aicr_rule.dart';
import '../report/aicr_report.dart';

/// Performance/Reviewability: Diff çok büyükse (satır bazında) PR'ı bölmeyi önerir.
/// - Heuristic: eklenen/silinen satır sayısını sayar.
/// - false-positive olabilir -> WARN
final class LargeDiffSuggestsSplitRule implements AicrRule {
  final int warnChangedLineThreshold;

  LargeDiffSuggestsSplitRule({this.warnChangedLineThreshold = 600});

  @override
  String get ruleId => 'large_diff_suggests_split';

  @override
  String get title => 'Large diff might be risky to review/performance';

  @override
  RuleResult evaluate({required List<String> changedFiles, String? diffText}) {
    final text = diffText;
    if (text == null || text.trim().isEmpty) {
      return RuleResult.pass(
        ruleId: ruleId,
        title: title,
        tr: 'Diff metni olmadığı için kontrol atlandı.',
        en: 'Diff text missing; check skipped.',
      );
    }

    final stats = _countChangedLines(text);
    final changed = stats.added + stats.removed;

    if (changed < warnChangedLineThreshold) {
      return RuleResult.pass(
        ruleId: ruleId,
        title: title,
        tr: 'Diff boyutu makul görünüyor.',
        en: 'Diff size looks reasonable.',
      );
    }

    return RuleResult.warn(
      ruleId: ruleId,
      title: title,
      tr: 'Diff çok büyük (+${stats.added}/-${stats.removed}, toplam $changed satır). PR’ı daha küçük parçalara bölmek review kalitesini ve risk yönetimini iyileştirebilir.',
      en: 'Diff is large (+${stats.added}/-${stats.removed}, total $changed lines). Splitting into smaller PRs may improve review quality and risk management.',
      evidenceFiles: changedFiles.take(5).toList(),
    );
  }

  _LineStats _countChangedLines(String diffText) {
    final lines = diffText.split('\n');

    var added = 0;
    var removed = 0;

    for (final raw in lines) {
      // headers ve file markers hariç
      if (raw.startsWith('+++') || raw.startsWith('---')) continue;

      if (raw.startsWith('+')) added++;
      if (raw.startsWith('-')) removed++;
    }

    return _LineStats(added: added, removed: removed);
  }
}

final class _LineStats {
  final int added;
  final int removed;

  const _LineStats({required this.added, required this.removed});
}
