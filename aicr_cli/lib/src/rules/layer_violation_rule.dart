import 'aicr_rule.dart';
import '../report/aicr_report.dart';

/// Architecture: Katman ihlali (heuristic)
/// - presentation -> data import görürsek WARN.
/// - Sadece diff'te eklenen import satırlarını tarar.
final class LayerViolationRule implements AicrRule {
  @override
  String get ruleId => 'layer_violation';

  @override
  String get title => 'Possible architecture layer violation';

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
        tr: 'Katman ihlali şüphesi tespit edilmedi.',
        en: 'No layer violation suspicion detected.',
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
      tr: 'Presentation katmanından data katmanına doğrudan import tespit edildi. Clean Architecture sınırlarını korumak için dependency yönünü gözden geçir.',
      en: 'Direct imports from presentation to data layer detected. Review dependency direction to preserve Clean Architecture boundaries.',
      evidenceFiles: evidenceFiles.isNotEmpty
          ? evidenceFiles
          : changedFiles.take(3).toList(),
    );
  }

  List<_LayerHit> _scan(String diffText) {
    final lines = diffText.split('\n');

    String? currentFile;
    final hits = <_LayerHit>[];

    for (final raw in lines) {
      final line = raw.trimRight();

      if (line.startsWith('+++ ')) {
        final p = line.replaceFirst('+++ ', '').trim();
        if (p.startsWith('b/')) currentFile = p.substring(2);
        if (p == '/dev/null') currentFile = null;
        continue;
      }

      // Sadece eklenen satırlar (+) ve header hariç
      if (!line.startsWith('+') || line.startsWith('+++')) continue;

      // Sadece import satırlarını incele
      final t = line.substring(1).trimLeft(); // '+' kaldır
      if (!t.startsWith('import ')) continue;

      // İhlal tanımı (heuristic):
      // - Dosya presentation içinde
      // - Import path'i data katmanını işaret ediyor
      final file = currentFile?.replaceAll('\\', '/').toLowerCase();
      if (file == null) continue;
      final isPresentation = file.contains('/presentation/');
      if (!isPresentation) continue;

      final importPath = _extractImportPath(t);
      final importLower = importPath.toLowerCase();

      final importsData =
          importLower.contains('/data/') ||
          importLower.contains('.data.') ||
          importLower.contains('data_');

      if (importsData) {
        hits.add(_LayerHit(filePath: currentFile, importPath: importPath));
      }
    }

    return hits;
  }

  String _extractImportPath(String importLine) {
    // import 'package:xxx/..../file.dart';
    final start = importLine.indexOf("'");
    if (start != -1) {
      final end = importLine.indexOf("'", start + 1);
      if (end != -1) return importLine.substring(start + 1, end);
    }
    final start2 = importLine.indexOf('"');
    if (start2 != -1) {
      final end2 = importLine.indexOf('"', start2 + 1);
      if (end2 != -1) return importLine.substring(start2 + 1, end2);
    }
    return importLine;
  }
}

final class _LayerHit {
  final String? filePath;
  final String importPath;

  _LayerHit({required this.filePath, required this.importPath});
}
