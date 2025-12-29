import 'aicr_rule.dart';
import '../report/aicr_report.dart';

final class BlocChangeRequiresTestsRule implements AicrRule {
  @override
  String get ruleId => 'bloc_change_requires_tests';

  @override
  String get title => 'BLoC changes should include tests';

  @override
  RuleResult evaluate({
    required List<String> changedFiles,
    String? diffText, // ✅ yeni ama kullanılmıyor
  }) {
    final blocChanged = changedFiles.any(_isBlocRelated);
    final testChanged = changedFiles.any((p) => p.startsWith('test/'));

    if (!blocChanged) {
      return RuleResult.pass(
        ruleId: ruleId,
        title: title,
        tr: 'BLoC ile ilgili değişiklik tespit edilmedi.',
        en: 'No BLoC-related change detected.',
      );
    }

    if (testChanged) {
      return RuleResult.pass(
        ruleId: ruleId,
        title: title,
        tr: 'BLoC değişiklikleri için test değişikliği tespit edildi.',
        en: 'Test changes detected for BLoC changes.',
      );
    }

    final evidenceFiles = changedFiles.where(_isBlocRelated).toList();

    return RuleResult.warn(
      ruleId: ruleId,
      title: title,
      tr: 'BLoC dosyalarında değişiklik var ancak test değişikliği tespit edilmedi.',
      en: 'BLoC files changed but no test change was detected.',
      evidenceFiles: evidenceFiles,
    );
  }

  bool _isBlocRelated(String path) {
    final p = path.toLowerCase();
    return p.endsWith('_bloc.dart') ||
        p.endsWith('_event.dart') ||
        p.endsWith('_state.dart');
  }
}
