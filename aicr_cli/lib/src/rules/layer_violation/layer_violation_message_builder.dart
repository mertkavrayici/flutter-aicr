part of '../layer_violation_rule.dart';

// ----------------------------
// Mesaj & örnekler: why/what + direction + where/what examples
// ----------------------------

final class _ViolationDescription {
  final String tr;
  final String en;

  _ViolationDescription({required this.tr, required this.en});
}

final class _Examples {
  final String tr;
  final String en;

  _Examples({required this.tr, required this.en});
}

final class _LayerViolationMessageBuilder {
  _ViolationDescription build(
    Set<String> violationTypes, {
    required List<_LayerHit> hits,
  }) {
    // Reuse existing messaging style: direction + examples + why/what.
    // Keep behavior the same, only structure changes.
    final violations = violationTypes.toList();
    final hasMultiple = violations.length > 1;

    String trReason;
    String enReason;
    String trAction;
    String enAction;

    if (violations.contains('PRESENTATION_TO_DATA')) {
      trReason =
          'Presentation katmanından data katmanına doğrudan import tespit edildi. ';
      enReason = 'Direct imports from presentation to data layer detected. ';
      trAction =
          'Clean Architecture prensiplerine göre, presentation katmanı sadece domain katmanına bağımlı olmalıdır. Data katmanına erişim domain katmanı üzerinden (repository interface) yapılmalıdır.';
      enAction =
          'According to Clean Architecture principles, presentation layer should only depend on domain layer. Data layer access should be done through domain layer (repository interface).';
    } else if (violations.contains('PRESENTATION_TO_DOMAIN')) {
      trReason =
          'Presentation katmanından domain katmanına (entity/value object dışı) import tespit edildi. ';
      enReason =
          'Imports from presentation to domain (non-entity/value-object code) detected. ';
      trAction =
          'Allowed olanlar: domain entities / value objects gibi saf tipler. Not allowed olanlar: domain “implementation” detayları veya feature-specific logic. Presentation katmanında use case arayüzleri üzerinden ilerle ve bağımlılığı sadeleştir.';
      enAction =
          'Allowed: pure domain types like entities/value objects. Not allowed: domain implementation details or feature-specific logic. Prefer depending on use case abstractions and keep boundaries clean.';
    } else if (violations.contains('CORE_TO_FEATURE')) {
      trReason =
          'Core katmanından feature katmanına doğrudan import tespit edildi. ';
      enReason = 'Direct imports from core layer to feature layer detected. ';
      trAction =
          'Core katmanı shared utilities, constants ve common functionality içerir ve feature\'lardan bağımsız olmalıdır. Feature\'lar core\'a bağımlı olabilir, ancak core feature\'lara bağımlı olmamalıdır. Bu bağımlılığı kaldır veya feature-specific kodu core\'dan çıkar.';
      enAction =
          'Core layer contains shared utilities, constants and common functionality and should be independent of features. Features can depend on core, but core should not depend on features. Remove this dependency or extract feature-specific code from core.';
    } else {
      trReason = 'Mimari katman ihlali tespit edildi. ';
      enReason = 'Architecture layer violation detected. ';
      trAction =
          'Clean Architecture sınırlarını korumak için dependency yönünü gözden geçir. Katmanlar arası bağımlılıklar dıştan içe doğru olmalıdır (presentation -> domain -> data).';
      enAction =
          'Review dependency direction to preserve Clean Architecture boundaries. Inter-layer dependencies should flow outward to inward (presentation -> domain -> data).';
    }

    if (hasMultiple) {
      trReason = 'Birden fazla mimari katman ihlali tespit edildi. ';
      enReason = 'Multiple architecture layer violations detected. ';
    }

    final direction = _describeDirections(violationTypes);
    final examples = _formatExamples(hits, limit: 5);

    return _ViolationDescription(
      tr:
          'İhlal yönü: $direction\n\n'
          'Nerede/Ne: ${examples.tr}\n\n'
          'Neden bu kural var: ${trReason}Clean Architecture, kodun bakımını ve test edilebilirliğini artırmak için katmanlar arası bağımlılıkları kontrol eder. Katman ihlalleri, kodun sıkı bağlanmasına (tight coupling) ve değişikliklerin yayılmasına (ripple effects) neden olur.\n\n'
          'Ne yapmalısın: $trAction',
      en:
          'Violation direction: $direction\n\n'
          'Where/What: ${examples.en}\n\n'
          'Why this rule exists: ${enReason}Clean Architecture controls inter-layer dependencies to improve code maintainability and testability. Layer violations cause tight coupling and ripple effects when making changes.\n\n'
          'What to do: $enAction',
    );
  }

  String _describeDirections(Set<String> violationTypes) {
    final parts = <String>[];
    if (violationTypes.contains('PRESENTATION_TO_DATA')) {
      parts.add('presentation -> data');
    }
    if (violationTypes.contains('PRESENTATION_TO_DOMAIN')) {
      parts.add('presentation -> domain');
    }
    if (violationTypes.contains('CORE_TO_FEATURE')) {
      parts.add('core -> feature');
    }
    if (violationTypes.contains('DENYLIST')) {
      parts.add('denylist');
    }
    return parts.isEmpty ? 'unknown' : parts.join(', ');
  }

  _Examples _formatExamples(List<_LayerHit> hits, {required int limit}) {
    final seen = <String>{};
    final items = <_LayerHit>[];

    for (final h in hits) {
      final p = h.filePath;
      if (p == null || p.trim().isEmpty) continue;
      final dir = _LayerViolationEvidenceFormatter.directionForViolation(
        h.violationType,
      );
      final key = '$p|${h.importLine}|$dir';
      if (!seen.add(key)) continue;
      items.add(h);
      if (items.length >= limit) break;
    }

    if (items.isEmpty) return _Examples(tr: '—', en: '—');

    final lines = items.map((h) {
      final p = h.filePath!;
      final dir = _LayerViolationEvidenceFormatter.directionForViolation(
        h.violationType,
      );
      return '\n- `$p` ($dir): `${h.importLine}`';
    }).join();

    return _Examples(tr: lines, en: lines);
  }
}
