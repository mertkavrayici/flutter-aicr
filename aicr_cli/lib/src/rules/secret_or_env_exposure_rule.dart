import 'aicr_rule.dart';
import '../report/aicr_report.dart';

/// Security: diff içinde secret/token/password vb. sızıntı kokusu arar.
/// - false-positive olabileceği için WARN üretir
/// - sadece + ile eklenen satırlara bakar (gürültüyü azaltır)
final class SecretOrEnvExposureRule implements AicrRule {
  @override
  String get ruleId => 'secret_or_env_exposure';

  @override
  String get title => 'Potential secret/env exposure in diff';

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

    final hits = _scan(text);

    if (hits.isEmpty) {
      return RuleResult.pass(
        ruleId: ruleId,
        title: title,
        tr: 'Secret/env sızıntısı tespit edilmedi.',
        en: 'No secret/env exposure detected.',
      );
    }

    final evidenceFiles = hits
        .map((h) => h.filePath)
        .whereType<String>()
        .where((p) => p.trim().isNotEmpty)
        .toSet()
        .toList(growable: false);

    return RuleResult.warn(
      ruleId: ruleId,
      title: title,
      tr: 'Diff içinde secret/token/password benzeri ifadeler bulundu. Hardcode credential veya log sızıntısı olmadığını doğrula.',
      en: 'Diff contains secret/token/password-like terms. Verify nothing is hardcoded and nothing leaks to logs.',
      evidenceFiles: evidenceFiles.isNotEmpty
          ? evidenceFiles
          : changedFiles.take(3).toList(),
    );
  }

  List<_SecretHit> _scan(String diffText) {
    final lines = diffText.split('\n');

    // Token listesi: case-insensitive çalışacağımız için küçük yazmak yeterli.
    final keyTokens = <String>[
      'api_key',
      'apikey',
      'api-key',
      'secret',
      'token',
      'password',
      'passwd',
      'pwd',
      'private_key',
      'private-key',
      'client_secret',
      'client-secret',
    ].join('|');

    // API_KEY=..., secret: "...", token = '...'
    // - : veya = sonrası opsiyonel quote
    // - value: whitespace/quote/backtick dışı en az 6 char
    final assignmentPattern =
        '\\b($keyTokens)\\b\\s*[:=]\\s*["\\\']?([^\\s"\\\'`]{6,})';

    // Authorization: Bearer eyJ...
    final bearerPattern = '\\bbearer\\b\\s+([a-z0-9\\-\\._~\\+\\/]+=*)';

    final patterns = <RegExp>[
      RegExp(r'AKIA[0-9A-Z]{16}'),
      RegExp(r'-----BEGIN (RSA|EC|OPENSSH) PRIVATE KEY-----'),
      // ✅ Kritik fix: case-insensitive
      RegExp(assignmentPattern, caseSensitive: false),
      RegExp(bearerPattern, caseSensitive: false),
    ];

    String? currentFile;
    final hits = <_SecretHit>[];

    for (final raw in lines) {
      final line = raw.trimRight();

      if (line.startsWith('+++ ')) {
        final p = line.replaceFirst('+++ ', '').trim();
        if (p.startsWith('b/')) currentFile = p.substring(2);
        if (p == '/dev/null') currentFile = null;
        continue;
      }

      // sadece eklenen satırlar (+) ve header hariç
      if (!line.startsWith('+') || line.startsWith('+++')) continue;

      for (final re in patterns) {
        if (re.hasMatch(line)) {
          final snippet = line.length > 180
              ? '${line.substring(0, 180)}…'
              : line;
          hits.add(_SecretHit(filePath: currentFile, snippet: snippet));
          break;
        }
      }
    }

    return hits;
  }
}

final class _SecretHit {
  final String? filePath;
  final String? snippet;

  _SecretHit({required this.filePath, required this.snippet});
}
