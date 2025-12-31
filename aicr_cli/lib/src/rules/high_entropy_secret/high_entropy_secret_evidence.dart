part of '../high_entropy_secret_rule.dart';

// ----------------------------
// kanıt/snippet: hit model + evidence mapping + snippet utils
// ----------------------------

// Magic numbers extracted
const int _snippetContextChars = 30;

final class _SecretHit {
  final String? filePath;
  final int? lineNumber;
  final String? snippet;
  final String patternType;
  final String? hunkHeader;

  _SecretHit({
    required this.filePath,
    required this.lineNumber,
    required this.snippet,
    this.patternType = 'UNKNOWN',
    required this.hunkHeader,
  });
}

final class _EvidenceBuilder {
  final int snippetMaxLen;

  const _EvidenceBuilder({required this.snippetMaxLen});

  List<Map<String, dynamic>> build(List<_SecretHit> hits) {
    final out = <Map<String, dynamic>>[];
    for (final h in hits) {
      final p = h.filePath;
      if (p == null || p.trim().isEmpty) continue;
      final m = <String, dynamic>{'file_path': p, 'pattern': h.patternType};
      if (h.lineNumber != null) m['line'] = h.lineNumber;
      if (h.snippet != null && h.snippet!.trim().isNotEmpty) {
        m['snippet'] = _Snippet.truncate(h.snippet!, maxLen: snippetMaxLen);
      }
      if (h.hunkHeader != null && h.hunkHeader!.trim().isNotEmpty) {
        m['hunk'] = h.hunkHeader;
      }
      out.add(m);
    }
    return out;
  }
}

final class _Snippet {
  static String truncate(String s, {required int maxLen}) {
    final t = s.trimRight();
    if (t.length <= maxLen) return t;
    return '${t.substring(0, maxLen)}…';
  }

  static String makeAroundMatch(
    String line, {
    required int start,
    required int end,
    required int maxLen,
  }) {
    final snippetStart = (start - _snippetContextChars).clamp(0, line.length);
    final snippetEnd = (end + _snippetContextChars).clamp(0, line.length);
    final snippet = line.substring(snippetStart, snippetEnd);
    return truncate(snippet, maxLen: maxLen);
  }
}
