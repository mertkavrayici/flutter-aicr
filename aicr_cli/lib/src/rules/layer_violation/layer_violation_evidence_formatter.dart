part of '../layer_violation_rule.dart';

// ----------------------------
// Evidence/format: hit -> RuleResult.evidence mapping + dedupe
// ----------------------------

final class _LayerHit {
  final String? filePath;
  final String importPath;
  final String importLine;
  final String violationType;
  final String? hunkHeader;
  final int? lineNumber;

  _LayerHit({
    required this.filePath,
    required this.importPath,
    required this.importLine,
    required this.violationType,
    this.hunkHeader,
    this.lineNumber,
  });
}

final class _LayerViolationEvidenceFormatter {
  List<Map<String, dynamic>> format(List<_LayerHit> hits) {
    final seen = <String>{};
    final out = <Map<String, dynamic>>[];

    for (final h in hits) {
      final p = h.filePath;
      if (p == null || p.trim().isEmpty) continue;

      final key =
          '$p|${h.importLine}|${h.violationType}|${h.lineNumber ?? ''}|${h.hunkHeader ?? ''}';
      if (!seen.add(key)) continue;

      final dir = directionForViolation(h.violationType);
      final m = <String, dynamic>{
        'file_path': p,
        // Required/new keys
        'import_line': h.importLine,
        'violation_direction': dir,
        // Backward compatible keys (don’t break existing assertions/consumers)
        'import': h.importLine,
        'direction': dir,
        'violation': h.violationType,
      };

      if (h.hunkHeader != null && h.hunkHeader!.trim().isNotEmpty) {
        m['hunk'] = h.hunkHeader;
      }
      if (h.lineNumber != null) {
        m['line'] = h.lineNumber;
      }

      out.add(m);
    }

    return out;
  }

  static String directionForViolation(String violationType) {
    return switch (violationType) {
      'PRESENTATION_TO_DATA' => 'presentation -> data',
      'PRESENTATION_TO_DOMAIN' => 'presentation -> domain',
      'CORE_TO_FEATURE' => 'core -> feature',
      'DENYLIST' => 'denylist',
      _ => 'unknown',
    };
  }
}


