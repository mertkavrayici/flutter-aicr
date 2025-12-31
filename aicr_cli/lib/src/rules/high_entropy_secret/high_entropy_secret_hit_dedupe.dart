part of '../high_entropy_secret_rule.dart';

// ----------------------------
// tekrarları engelleme: dedupe (file + pattern + snippet)
// ----------------------------

final class _HitDedupe {
  const _HitDedupe();

  List<_SecretHit> dedupe(List<_SecretHit> hits) {
    // Aynı snippet tekrarlarını tekilleştir (file + pattern + snippet)
    final seen = <String, _SecretHit>{};

    for (final h in hits) {
      final p = h.filePath ?? '';
      final sn = h.snippet ?? '';
      final key = '$p|${h.patternType}|$sn';

      final existing = seen[key];
      if (existing == null) {
        seen[key] = h;
        continue;
      }

      // Prefer earlier line number if available
      final a = existing.lineNumber;
      final b = h.lineNumber;
      if (a == null && b != null) {
        seen[key] = h;
      } else if (a != null && b != null && b < a) {
        seen[key] = h;
      }
    }

    return seen.values.toList(growable: false);
  }
}
