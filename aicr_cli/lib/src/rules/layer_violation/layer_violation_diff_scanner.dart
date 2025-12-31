part of '../layer_violation_rule.dart';

// ----------------------------
// Diff/import tarama: sadece diff'te eklenen import satırlarını çıkarır.
// ----------------------------

final class _LayerViolationDiffScanner {
  List<_AddedImport> scan(String diffText) {
    final lines = diffText.split('\n');

    String? currentFile;
    String? currentHunk;
    int? currentNewLine;

    final out = <_AddedImport>[];

    for (final raw in lines) {
      final line = raw.trimRight();

      if (line.startsWith('+++ ')) {
        final p = line.replaceFirst('+++ ', '').trim();
        if (p.startsWith('b/')) currentFile = p.substring(2);
        if (p == '/dev/null') currentFile = null;
        currentHunk = null;
        currentNewLine = null;
        continue;
      }

      if (line.startsWith('@@')) {
        currentHunk = line;
        final m = RegExp(
          r'@@\s*-\d+(?:,\d+)?\s+\+(\d+)(?:,\d+)?\s*@@',
        ).firstMatch(line);
        if (m != null) currentNewLine = int.tryParse(m.group(1) ?? '');
        continue;
      }

      // Hunk içi line tracking (new file tarafı)
      if (currentNewLine != null) {
        if (line.startsWith(' ')) {
          currentNewLine = currentNewLine + 1;
          continue;
        }
        if (line.startsWith('-') && !line.startsWith('---')) {
          continue;
        }
      }

      // Sadece eklenen satırlar (+) ve header hariç
      if (!line.startsWith('+') || line.startsWith('+++')) continue;

      final importLine = line.substring(1).trimLeft();
      if (!importLine.startsWith('import ')) {
        if (currentNewLine != null) currentNewLine = currentNewLine + 1;
        continue;
      }

      out.add(
        _AddedImport(
          filePath: currentFile,
          importLine: importLine,
          importPath: _extractImportPath(importLine),
          hunkHeader: currentHunk,
          lineNumber: currentNewLine,
        ),
      );

      if (currentNewLine != null) currentNewLine = currentNewLine + 1;
    }

    return out;
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

final class _AddedImport {
  final String? filePath;
  final String importLine;
  final String importPath;
  final String? hunkHeader;
  final int? lineNumber;

  const _AddedImport({
    required this.filePath,
    required this.importLine,
    required this.importPath,
    required this.hunkHeader,
    required this.lineNumber,
  });
}
