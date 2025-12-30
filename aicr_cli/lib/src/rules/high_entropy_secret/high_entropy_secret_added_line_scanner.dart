part of '../high_entropy_secret_rule.dart';

// ----------------------------
// satır tarama: diff “added lines” scanner (sadece '+')
// ----------------------------

// Magic numbers extracted
const int _hunkLineNumberGroup = 1;
final RegExp _hunkHeaderNewLineRegex = RegExp(
  r'@@\s*-\d+(?:,\d+)?\s+\+(\d+)(?:,\d+)?\s*@@',
);

final class _AddedLine {
  final String? filePath;
  final String? hunkHeader;
  final int? lineNumber;
  final String content; // '+' without prefix

  const _AddedLine({
    required this.filePath,
    required this.hunkHeader,
    required this.lineNumber,
    required this.content,
  });
}

final class _AddedLineScanner {
  final IgnorePolicy ignorePolicy;

  const _AddedLineScanner({required this.ignorePolicy});

  List<_AddedLine> scan(String diffText) {
    final lines = diffText.split('\n');

    String? currentFile;
    String? currentHunkHeader;
    int? currentNewLine;

    final out = <_AddedLine>[];

    for (final raw in lines) {
      final line = raw.trimRight();

      if (line.startsWith('diff --git ')) {
        currentNewLine = null;
        currentHunkHeader = null;
      }

      if (line.startsWith('+++ ')) {
        final p = line.replaceFirst('+++ ', '').trim();
        if (p.startsWith('b/')) currentFile = p.substring(2);
        if (p == '/dev/null') currentFile = null;
        continue;
      }

      if (line.startsWith('@@')) {
        currentHunkHeader = line;
        final m = _hunkHeaderNewLineRegex.firstMatch(line);
        if (m != null) {
          currentNewLine = int.tryParse(m.group(_hunkLineNumberGroup) ?? '');
        }
        continue;
      }

      // new-file line tracking within hunk
      if (currentNewLine != null) {
        if (line.startsWith(' ')) {
          currentNewLine = currentNewLine + 1;
          continue;
        }
        if (line.startsWith('-') && !line.startsWith('---')) {
          continue;
        }
      }

      // added lines only
      if (!line.startsWith('+') || line.startsWith('+++')) continue;

      // ignore policy applies per file (rule-specific)
      if (currentFile != null && ignorePolicy.isIgnored(currentFile)) {
        if (currentNewLine != null) currentNewLine = currentNewLine + 1;
        continue;
      }

      final content = line.substring(1);
      out.add(
        _AddedLine(
          filePath: currentFile,
          hunkHeader: currentHunkHeader,
          lineNumber: currentNewLine,
          content: content,
        ),
      );

      if (currentNewLine != null) currentNewLine = currentNewLine + 1;
    }

    return out;
  }
}


