/// Redacts secrets from diff text before sending it to AI providers.
///
/// This is a best-effort safety layer. It aims to:
/// - preserve structure/context (keys, headers, hunks)
/// - replace sensitive VALUES with "***REDACTED***"
/// - be conservative and cheap (regex + line-based handling)
final class DiffRedactor {
  static const String redacted = '***REDACTED***';

  const DiffRedactor();

  String redact(String diff) {
    var out = diff;

    // 1) Authorization bearer token
    // e.g. "Authorization: Bearer abc123"
    out = out.replaceAllMapped(
      RegExp(
        r'^([+\-\s]*authorization\s*:\s*bearer\s+)(.+)$',
        caseSensitive: false,
        multiLine: true,
      ),
      (m) => '${m[1]}$redacted',
    );

    // 2) Private key blocks
    // -----BEGIN PRIVATE KEY----- ... -----END PRIVATE KEY-----
    out = out.replaceAllMapped(
      RegExp(
        r'(-----BEGIN PRIVATE KEY-----)(.*?)(-----END PRIVATE KEY-----)',
        dotAll: true,
      ),
      (m) => '${m[1]}\n$redacted\n${m[3]}',
    );

    // 3) Key/value patterns (case-insensitive), preserve key + separator
    out = _redactKeyValue(out, keys: const [
      'API_KEY',
      'SECRET',
      'TOKEN',
      'PRIVATE_KEY',
    ]);

    // 4) Prefix patterns (AWS_/GOOGLE_/FIREBASE_)
    out = _redactPrefixedKeyValue(out, prefixes: const [
      'AWS_',
      'GOOGLE_',
      'FIREBASE_',
    ]);

    // 5) .env file contents (diff-aware): if current file is .env, redact values.
    out = _redactDotEnvDiff(out);

    return out;
  }

  String _redactKeyValue(String text, {required List<String> keys}) {
    final alternation = keys.map(RegExp.escape).join('|');
    final re = RegExp(
      // KEY <spaces> [:|=] <spaces> [quote?] VALUE [quote?]
      '\\b($alternation)\\b(\\s*[:=]\\s*)([\'"]?)([^\'"\\r\\n]*)(\\3)',
      caseSensitive: false,
      multiLine: true,
    );
    return text.replaceAllMapped(
      re,
      (m) => '${m[1]}${m[2]}${m[3]}$redacted${m[5]}',
    );
  }

  String _redactPrefixedKeyValue(
    String text, {
    required List<String> prefixes,
  }) {
    final alternation = prefixes.map(RegExp.escape).join('|');
    final re = RegExp(
      '\\b(($alternation)[A-Z0-9_]+)\\b(\\s*[:=]\\s*)([\'"]?)([^\'"\\r\\n]*)(\\4)',
      caseSensitive: false,
      multiLine: true,
    );
    return text.replaceAllMapped(
      re,
      (m) => '${m[1]}${m[3]}${m[4]}$redacted${m[6]}',
    );
  }

  String _redactDotEnvDiff(String diff) {
    final lines = diff.split('\n');
    final out = StringBuffer();

    var inEnvFile = false;

    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];

      // Track which file we're in, based on patch headers.
      if (line.startsWith('--- ') || line.startsWith('+++ ')) {
        final p = line.substring(4).trim();
        // p can be "a/.env" or "b/.env"
        inEnvFile = p.endsWith('.env') || p.endsWith('/.env');
      }

      var current = line;
      if (inEnvFile && current.startsWith('+') && !current.startsWith('+++')) {
        // Redact "+KEY=value" while preserving KEY=
        final m = RegExp(r'^\+([A-Za-z_][A-Za-z0-9_]*)\s*=').firstMatch(current);
        if (m != null) {
          final key = m.group(1)!;
          current = '+$key=$redacted';
        }
      }

      if (i > 0) out.write('\n');
      out.write(current);
    }

    return out.toString();
  }
}


