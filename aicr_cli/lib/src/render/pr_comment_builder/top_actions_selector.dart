part of '../pr_comment_builder.dart';

final class _TopActionsSelector {
  final bool Function(AicrFinding) isAi;
  final int Function(AicrSeverity) sevRank;

  const _TopActionsSelector({required this.isAi, required this.sevRank});

  static final RegExp _nonAlnum = RegExp(r'[^a-z0-9]');

  static String _normalizeKeyPart(String s) {
    // Spec: lowercase, trim, non-alnum removed
    return s.toLowerCase().trim().replaceAll(_nonAlnum, '');
  }

  static String _uniquenessKey(AicrFinding f) {
    final areaPart = f.area == null ? '' : _normalizeKeyPart(f.area!);
    final titlePart = _normalizeKeyPart(f.title);
    return '$areaPart|$titlePart';
  }

  List<AicrFinding> select(AicrReport report, {required int limit}) {
    final sorted = [...report.findings]
      ..sort((a, b) {
        final sa = sevRank(a.severity);
        final sb = sevRank(b.severity);
        if (sa != sb) return sb.compareTo(sa);

        // AI varsa confidence desc (deterministic için null => 0)
        final ca = a.confidence ?? 0.0;
        final cb = b.confidence ?? 0.0;
        if (ca != cb) return cb.compareTo(ca);

        final aa = isAi(a) ? 1 : 0;
        final bb = isAi(b) ? 1 : 0;
        return aa.compareTo(bb);
      });

    final seenKeys = <String>{};
    final unique = <AicrFinding>[];

    for (final f in sorted) {
      // Uniqueness: area + normalized title (lowercase, trim, non-alnum removed)
      final key = _uniquenessKey(f);
      if (seenKeys.add(key)) {
        unique.add(f);
        if (unique.length >= limit) break;
      }
    }

    return unique;
  }
}


