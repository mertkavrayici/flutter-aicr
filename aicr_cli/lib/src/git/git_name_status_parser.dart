import '../report/aicr_report.dart';

final class GitNameStatusParser {
  const GitNameStatusParser();

  List<FileEntry> parseZOutput(String stdout) {
    if (stdout.isEmpty) return const [];

    // -z => NUL (\u0000) separated
    final tokens = stdout.split('\u0000')..removeWhere((e) => e.isEmpty);

    final entries = <FileEntry>[];
    var i = 0;

    while (i < tokens.length) {
      final status = tokens[i];

      // R100 old new
      if (status.startsWith('R')) {
        if (i + 2 >= tokens.length) {
          // Malformed: R status without enough tokens
          break;
        }
        final newPath = tokens[i + 2];
        entries.add(FileEntry.fromStringChangeType(
            path: newPath, changeType: 'renamed'));
        i += 3;
        continue;
      }

      // C100 old new (copy)
      if (status.startsWith('C')) {
        if (i + 2 >= tokens.length) {
          // Malformed: C status without enough tokens
          break;
        }
        final newPath = tokens[i + 2];
        entries.add(FileEntry.fromStringChangeType(
            path: newPath, changeType: 'modified'));
        i += 3;
        continue;
      }

      // A / M / D / T / U
      if (i + 1 >= tokens.length) {
        // Malformed: status without path
        break;
      }
      final path = tokens[i + 1];
      entries.add(FileEntry.fromStringChangeType(
          path: path, changeType: _mapStatus(status)));
      i += 2;
    }

    return entries;
  }

  String _mapStatus(String status) {
    switch (status) {
      case 'A':
        return 'added';
      case 'D':
        return 'deleted';
      case 'M':
      case 'T':
      case 'U':
      default:
        return 'modified';
    }
  }
}
