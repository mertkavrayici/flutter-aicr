import 'aicr_rule.dart';
import '../report/aicr_report.dart';

final class UiChangeSuggestsGoldenTestsRule implements AicrRule {
  @override
  String get ruleId => 'ui_change_suggests_golden_tests';

  @override
  String get title => 'UI changes may benefit from golden tests';

  @override
  RuleResult evaluate({
    required List<String> changedFiles,
    String? diffText, // ✅ yeni ama kullanılmıyor
  }) {
    final uiFiles = changedFiles.where(_isUiRelated).toList(growable: false);

    if (uiFiles.isEmpty) {
      return RuleResult.pass(
        ruleId: ruleId,
        title: title,
        tr: 'UI ile ilgili değişiklik tespit edilmedi.',
        en: 'No UI-related changes detected.',
      );
    }

    return RuleResult.warn(
      ruleId: ruleId,
      title: title,
      tr: 'UI bileşenlerinde değişiklik var. Golden test veya widget test ile kritik ekranları sabitlemeyi düşünebilirsin.',
      en: 'UI components changed. Consider adding golden/widget tests to lock down critical screens.',
      evidenceFiles: uiFiles.take(5).toList(),
    );
  }

  bool _isUiRelated(String path) {
    final p = path.replaceAll('\\', '/').toLowerCase();
    if (!p.endsWith('.dart')) return false;

    if (p.contains('/presentation/')) return true;
    if (p.contains('/widgets/')) return true;
    if (p.contains('/components/')) return true;
    if (p.endsWith('_page.dart')) return true;
    if (p.endsWith('_screen.dart')) return true;

    return false;
  }
}
