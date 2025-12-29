import 'aicr_rule.dart';
import '../report/aicr_report.dart';

final class LargeChangeSetRule implements AicrRule {
  final int warnFileThreshold;

  LargeChangeSetRule({this.warnFileThreshold = 15});

  @override
  String get ruleId => 'large_change_set';

  @override
  String get title => 'Large change set might be hard to review';

  @override
  RuleResult evaluate({
    required List<String> changedFiles,
    String? diffText, // ✅ yeni ama kullanılmıyor
  }) {
    final fileCount = changedFiles.length;

    if (fileCount < warnFileThreshold) {
      return RuleResult.pass(
        ruleId: ruleId,
        title: title,
        tr: 'Değişen dosya sayısı makul görünüyor.',
        en: 'Changed file count looks reasonable.',
      );
    }

    return RuleResult.warn(
      ruleId: ruleId,
      title: title,
      tr: 'Değişen dosya sayısı yüksek ($fileCount). PR’ı daha küçük parçalara bölmek review sürecini kolaylaştırabilir.',
      en: 'High number of changed files ($fileCount). Splitting into smaller PRs may improve review quality.',
      evidenceFiles: changedFiles.take(5).toList(),
    );
  }
}
