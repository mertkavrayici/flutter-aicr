import '../report/aicr_report.dart';

abstract interface class AicrRule {
  String get ruleId;
  String get title;

  /// diffText opsiyonel. Eski rule’lar kullanmaz.
  RuleResult evaluate({required List<String> changedFiles, String? diffText});
}
