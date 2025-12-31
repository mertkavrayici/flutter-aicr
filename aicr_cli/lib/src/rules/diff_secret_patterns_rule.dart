import 'aicr_rule.dart';
import '../report/aicr_report.dart';

/// Security: very small-scope heuristic for secret-ish patterns in diff.
///
/// Triggers WARN if diff contains (added lines only):
/// - `.env` mentions
/// - `token=` assignments
/// - `apiKey` / `api_key` / `apikey` mentions
/// - `secret` keyword
///
/// NOTE: This is intentionally shallow and may produce false positives.
final class DiffSecretPatternsRule implements AicrRule {
  @override
  String get ruleId => 'diff_secret_patterns';

  @override
  String get title => 'Potential secret patterns detected in diff';

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

    final hits = _scanAddedLines(text);
    if (hits.isEmpty) {
      return RuleResult.pass(
        ruleId: ruleId,
        title: title,
        tr: 'Secret pattern tespit edilmedi.',
        en: 'No secret pattern detected.',
      );
    }

    final evidenceFiles = hits
        .where((p) => p.trim().isNotEmpty)
        .toSet()
        .toList(growable: false);

    return RuleResult.warn(
      ruleId: ruleId,
      title: title,
      tr: 'Diff içinde `.env`/token/apiKey/secret benzeri ifadeler bulundu. Hardcode credential olmadığını ve loglara sızmadığını doğrula.',
      en: 'Diff contains `.env`/token/apiKey/secret-like patterns. Verify nothing is hardcoded and nothing leaks to logs.',
      evidenceFiles: evidenceFiles.isNotEmpty
          ? evidenceFiles
          : changedFiles.take(3).toList(growable: false),
    );
  }

  List<String> _scanAddedLines(String diffText) {
    final lines = diffText.split('\n');

    // Capture file context from unified diff headers.
    String? currentFile;

    // Patterns (case-insensitive):
    // - .env
    // - token =
    // - apiKey / api_key / apikey
    // - secret (word-ish)
    final patterns = <RegExp>[
      RegExp(r'\.env\b', caseSensitive: false),
      RegExp(r'\btoken\s*=', caseSensitive: false),
      RegExp(r'\bapi[_-]?key\b', caseSensitive: false),
      RegExp(r'\bsecret\b', caseSensitive: false),
    ];

    final hitFiles = <String>{};

    for (final raw in lines) {
      final line = raw.trimRight();

      if (line.startsWith('+++ ')) {
        final p = line.substring(4).trim();
        if (p == '/dev/null') {
          currentFile = null;
        } else if (p.startsWith('b/')) {
          currentFile = p.substring(2);
        } else {
          currentFile = p;
        }
        continue;
      }

      // Only added lines, excluding headers.
      if (!line.startsWith('+') || line.startsWith('+++')) continue;

      final content = line.substring(1); // remove leading '+'
      final matched = patterns.any((re) => re.hasMatch(content));
      if (matched) {
        if (currentFile != null) {
          hitFiles.add(currentFile);
        }
      }
    }

    return hitFiles.toList(growable: false);
  }
}
