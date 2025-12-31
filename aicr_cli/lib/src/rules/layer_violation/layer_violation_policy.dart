part of '../layer_violation_rule.dart';

// ----------------------------
// Policy/config: allowlist/denylist + layer heuristics
// ----------------------------

/// Injectable policy/config for `LayerViolationRule`.
///
/// Defaults match the rule's current behavior; callers may provide a custom
/// instance via `LayerViolationRule(policy: ...)`.
final class LayerViolationPolicy {
  final List<String> allowlist;
  final List<String> denylist;

  const LayerViolationPolicy({required this.allowlist, required this.denylist});

  // Library-private to avoid exposing private implementation types.
  List<_LayerHit> _evaluate(List<_AddedImport> imports) {
    final hits = <_LayerHit>[];
    for (final imp in imports) {
      final importLower = imp.importPath.toLowerCase();

      if (_isInList(importLower, allowlist)) continue;

      final file = imp.filePath?.replaceAll('\\', '/').toLowerCase();
      if (file == null) continue;

      if (_isInList(importLower, denylist)) {
        hits.add(
          _LayerHit(
            filePath: imp.filePath,
            importPath: imp.importPath,
            importLine: imp.importLine,
            violationType: 'DENYLIST',
            hunkHeader: imp.hunkHeader,
            lineNumber: imp.lineNumber,
          ),
        );
        continue;
      }

      if (_isPresentationLayer(file)) {
        if (_importsDataLayer(importLower)) {
          hits.add(
            _LayerHit(
              filePath: imp.filePath,
              importPath: imp.importPath,
              importLine: imp.importLine,
              violationType: 'PRESENTATION_TO_DATA',
              hunkHeader: imp.hunkHeader,
              lineNumber: imp.lineNumber,
            ),
          );
          continue;
        }
        if (_importsDomainLayer(importLower)) {
          // Presentation -> domain is generally allowed for entities/value objects,
          // but not for domain implementation details.
          if (_isAllowedPresentationToDomainImport(importLower)) {
            continue;
          }
          hits.add(
            _LayerHit(
              filePath: imp.filePath,
              importPath: imp.importPath,
              importLine: imp.importLine,
              violationType: 'PRESENTATION_TO_DOMAIN',
              hunkHeader: imp.hunkHeader,
              lineNumber: imp.lineNumber,
            ),
          );
          continue;
        }
      }

      if (_isCoreLayer(file)) {
        if (_importsFeatureLayer(importLower)) {
          hits.add(
            _LayerHit(
              filePath: imp.filePath,
              importPath: imp.importPath,
              importLine: imp.importLine,
              violationType: 'CORE_TO_FEATURE',
              hunkHeader: imp.hunkHeader,
              lineNumber: imp.lineNumber,
            ),
          );
          continue;
        }
      }
    }
    return hits;
  }

  bool _isInList(String value, List<String> patterns) {
    for (final p in patterns) {
      if (value.contains(p.toLowerCase())) return true;
    }
    return false;
  }

  bool _isPresentationLayer(String filePath) =>
      filePath.contains('/presentation/') ||
      filePath.contains('\\presentation\\') ||
      filePath.contains('/presentation') ||
      filePath.contains('\\presentation');

  bool _isCoreLayer(String filePath) =>
      filePath.contains('/core/') ||
      filePath.contains('\\core\\') ||
      filePath.contains('/core') ||
      filePath.contains('\\core');

  bool _importsDataLayer(String importPath) =>
      importPath.contains('/data/') ||
      importPath.contains('.data.') ||
      importPath.contains('data_') ||
      importPath.contains('\\data\\') ||
      importPath.contains('\\data');

  bool _importsDomainLayer(String importPath) =>
      importPath.contains('/domain/') ||
      importPath.contains('.domain.') ||
      importPath.contains('domain_') ||
      importPath.contains('\\domain\\') ||
      importPath.contains('\\domain');

  bool _isAllowedPresentationToDomainImport(String importPath) {
    final p = importPath.toLowerCase();

    // Heuristic allowlist for "domain entities / value objects / pure types".
    // We keep it intentionally small and path-based.
    if (p.contains('/domain/entities/') || p.contains('\\domain\\entities\\')) {
      return true;
    }
    if (p.contains('/domain/value_objects/') ||
        p.contains('\\domain\\value_objects\\')) {
      return true;
    }
    // File naming conventions commonly used for pure domain types.
    if (p.endsWith('_entity.dart') || p.endsWith('entity.dart')) return true;
    if (p.endsWith('_value_object.dart') || p.endsWith('value_object.dart')) {
      return true;
    }

    return false;
  }

  bool _importsFeatureLayer(String importPath) =>
      importPath.contains('/features/') ||
      importPath.contains('/feature/') ||
      importPath.contains('\\features\\') ||
      importPath.contains('\\feature\\') ||
      importPath.contains('.features.') ||
      importPath.contains('.feature.');
}
