import 'aicr_rule.dart';
import '../report/aicr_report.dart';

part 'high_entropy_secret/high_entropy_secret_added_line_scanner.dart';
part 'high_entropy_secret/high_entropy_secret_ignore_policy.dart';
part 'high_entropy_secret/high_entropy_secret_token_detector.dart';
part 'high_entropy_secret/high_entropy_secret_heuristics.dart';
part 'high_entropy_secret/high_entropy_secret_hit_dedupe.dart';
part 'high_entropy_secret/high_entropy_secret_evidence.dart';

/// Security: High-entropy string ve token pattern yakalama.
/// - 20+ karakter uzunluğunda high-entropy string'leri yakalar
/// - AWS key pattern, base64 benzeri token'ları tespit eder
/// - False positive azaltmak için sadece belirli pattern'leri kontrol eder
/// - WARN üretir (false positive riski nedeniyle)
final class HighEntropySecretRule implements AicrRule {
  static const int _snippetMaxLen = 160;
  final IgnorePolicy _ignorePolicy;
  final SecretHeuristics _heuristics;

  HighEntropySecretRule({
    IgnorePolicy? ignorePolicy,
    SecretHeuristics? heuristics,
  }) : _ignorePolicy = ignorePolicy ?? const IgnorePolicy(),
       _heuristics = heuristics ?? const SecretHeuristics();

  @override
  String get ruleId => 'high_entropy_secret';

  @override
  String get title => 'High-entropy secret/token pattern detected';

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

    // a) Diff “added lines” scanner: file/hunk/line + content (sadece '+')
    // c) Ignore policy (path bazlı) — sadece bu rule için
    final addedLines = _AddedLineScanner(
      ignorePolicy: _ignorePolicy,
    ).scan(text);

    // b) Token detector: AWS/JWT/base64-like/entropy checks (küçük fonksiyonlar)
    final rawHits = _TokenDetector(heuristics: _heuristics).detect(addedLines);

    // d) Hit dedupe (aynı dosya + aynı snippet tekrarlarını tekilleştir)
    final hits = const _HitDedupe().dedupe(rawHits);

    if (hits.isEmpty) {
      return RuleResult.pass(
        ruleId: ruleId,
        title: title,
        tr: 'High-entropy secret/token pattern tespit edilmedi.',
        en: 'No high-entropy secret/token pattern detected.',
      );
    }

    // Risk: Secret/token exposure riski
    // Neden: High-entropy string veya token pattern tespit edildi
    // Önerilen aksiyon: Secret'ları environment variable veya secure storage'a taşı
    // Evidence: sadece tetikleyen hunk/satırları
    // - Line number ve snippet ekle (diff hunk'tan)
    // - Aynı dosya tekrarlarını tekilleştir (aynı file+line+pattern aynıysa 1 kez)
    // Evidence temizliği: sadece tetikleyen satır/snippet’ler + kısaltma
    final evidence = _EvidenceBuilder(
      snippetMaxLen: _snippetMaxLen,
    ).build(hits);

    return RuleResult(
      ruleId: ruleId,
      status: ReportStatus.warn,
      title: title,
      message: {
        'tr':
            '''Risk: Secret/token sızıntısı riski. High-entropy string veya token pattern tespit edildi.
Neden: Diff içinde 20+ karakter uzunluğunda high-entropy string veya AWS key/JWT token/base64 benzeri pattern bulundu. Bu bir secret/token olabilir.
Önerilen aksiyon: Hardcode credential veya log sızıntısı olmadığını doğrula. Secret'ları environment variable veya secure storage'a taşı. Eğer test data ise, mock/placeholder kullan.''',
        'en':
            '''Risk: Secret/token exposure risk. High-entropy string or token pattern detected.
Reason: Diff contains 20+ character high-entropy string or AWS key/JWT token/base64-like pattern. This may be a secret/token.
Suggested action: Verify nothing is hardcoded and nothing leaks to logs. Move secrets to environment variables or secure storage. If it's test data, use mock/placeholder.''',
      },
      evidence: evidence.isNotEmpty
          ? evidence
          : changedFiles
                .take(3)
                .map((p) => {'file_path': p})
                .toList(growable: false),
    );
  }
}
