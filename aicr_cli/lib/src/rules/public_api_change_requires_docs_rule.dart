import 'aicr_rule.dart';
import '../report/aicr_report.dart';

/// Architecture/DX: heuristic warning when "public API" under `lib/src/**`
/// changes but README/CHANGELOG are not touched.
///
/// This repo exports many `lib/src/**` symbols via the package barrel, so
/// changes there may impact downstream consumers.
final class PublicApiChangeRequiresDocsRule implements AicrRule {
  @override
  String get ruleId => 'public_api_change_requires_docs';

  @override
  String get title => 'Public API change may require docs/changelog update';

  @override
  RuleResult evaluate({required List<String> changedFiles, String? diffText}) {
    final normalized = changedFiles
        .map((p) => p.replaceAll('\\', '/').toLowerCase().trim())
        .where((p) => p.isNotEmpty)
        .toList(growable: false);

    final touchesLibSrc = normalized.any((p) => p.startsWith('lib/src/'));

    if (!touchesLibSrc) {
      return RuleResult.pass(
        ruleId: ruleId,
        title: title,
        tr: 'Public API değişikliği şüphesi yok.',
        en: 'No public API change suspicion.',
      );
    }

    final touchesDocs = normalized.any(
      (p) => p.endsWith('readme.md') || p.endsWith('changelog.md'),
    );

    if (touchesDocs) {
      return RuleResult.pass(
        ruleId: ruleId,
        title: title,
        tr: 'Public API değişiklikleri için dokümantasyon dosyaları da güncellenmiş.',
        en: 'Docs/changelog were also updated alongside API changes.',
      );
    }

    final evidence = normalized
        .where((p) => p.startsWith('lib/src/'))
        .take(5)
        .toList(growable: false);

    return RuleResult.warn(
      ruleId: ruleId,
      title: title,
      tr: 'lib/src altında public API etkileyebilecek değişiklikler var ama README/CHANGELOG dokunulmamış. Değişikliği dokümante etmeyi düşün.',
      en: 'Changes under lib/src may affect public API, but README/CHANGELOG were not updated. Consider documenting the change.',
      evidenceFiles: evidence.isNotEmpty
          ? evidence
          : changedFiles.take(3).toList(growable: false),
    );
  }
}
