final class DiffParser {
  static List<String> parseChangedFiles(String diffText) {
    final lines = diffText.split('\n');
    final files = <String>{};

    for (final line in lines) {
      if (!line.startsWith('diff --git ')) continue;

      // diff --git a/path b/path
      final parts = line.split(' ');
      if (parts.length < 4) continue;

      final bPath = parts[3]; // b/...
      final normalized = bPath.startsWith('b/') ? bPath.substring(2) : bPath;
      files.add(normalized);
    }

    return files.toList()..sort();
  }
}
