import 'aicr_rule.dart';
import '../report/aicr_report.dart';

part 'layer_violation/layer_violation_diff_scanner.dart';
part 'layer_violation/layer_violation_policy.dart';
part 'layer_violation/layer_violation_message_builder.dart';
part 'layer_violation/layer_violation_evidence_formatter.dart';

/// Architecture: Katman ihlali (heuristic)
/// - presentation -> data/domain import görürsek WARN.
///   - Not: presentation -> domain entities/value objects gibi saf tipler ALLOWED (warn etme).
/// - core -> feature import görürsek WARN.
/// - Allowlist/denylist desteği (hardcode, sonra config yapılır).
/// - Sadece diff'te eklenen import satırlarını tarar.
final class LayerViolationRule implements AicrRule {
  // Allowlist/denylist config edilebilir (şimdilik default hardcode).
  final List<String> _allowlist;
  final List<String> _denylist;
  final LayerViolationPolicy? _policyOverride;

  LayerViolationRule({
    LayerViolationPolicy? policy,
    List<String>? allowlist,
    List<String>? denylist,
  }) : _allowlist = allowlist ?? _defaultAllowlist,
       _denylist = denylist ?? _defaultDenylist,
       _policyOverride = policy;

  @override
  String get ruleId => 'layer_violation';

  @override
  String get title => 'Possible architecture layer violation';

  // Allowlist: Bu import'lar her zaman izin verilir (false positive azaltmak için)
  static const _defaultAllowlist = <String>[
    // Flutter/Dart standart kütüphaneleri
    'package:flutter/',
    'package:dart:',
    'dart:',
    // Test dosyaları
    '/test/',
    '.test.dart',
    '.test_',
    // Shared/common utilities (genellikle her yerden import edilebilir)
    '/shared/',
    '/common/',
    '/core/utils/',
    '/core/constants/',
  ];

  // Denylist: Bu pattern'ler her zaman reddedilir (ekstra güvenlik için)
  static const _defaultDenylist = <String>[
    // Örnek: Eğer bir pattern kesinlikle yasaksa buraya eklenebilir
  ];

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

    final policy =
        _policyOverride ??
        LayerViolationPolicy(allowlist: _allowlist, denylist: _denylist);
    final hits = policy._evaluate(_LayerViolationDiffScanner().scan(text));

    if (hits.isEmpty) {
      return RuleResult.pass(
        ruleId: ruleId,
        title: title,
        tr: 'Katman ihlali şüphesi tespit edilmedi.',
        en: 'No layer violation suspicion detected.',
      );
    }

    final violationTypes = hits.map((h) => h.violationType).toSet();
    final violationDescription = _LayerViolationMessageBuilder().build(
      violationTypes,
      hits: hits,
    );
    final evidence = _LayerViolationEvidenceFormatter().format(hits);

    return RuleResult(
      ruleId: ruleId,
      status: ReportStatus.warn,
      title: title,
      message: {'tr': violationDescription.tr, 'en': violationDescription.en},
      evidence: evidence.isNotEmpty
          ? evidence
          : changedFiles
                .take(3)
                .map((p) => {'file_path': p})
                .toList(growable: false),
    );
  }
}
