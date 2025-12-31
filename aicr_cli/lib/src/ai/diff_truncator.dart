/// Truncates diff text to a maximum character budget.
///
/// MVP behavior:
/// - If within budget -> return original text, truncated=false
/// - If over budget -> prefer keeping diff file headers and hunk headers
///   by skipping non-essential lines once budget becomes tight.
final class DiffTruncator {
  const DiffTruncator();

  ({String text, bool truncated}) truncate(String diffText, int maxChars) {
    if (maxChars <= 0) return (text: '', truncated: diffText.isNotEmpty);
    if (diffText.length <= maxChars) return (text: diffText, truncated: false);

    final lines = diffText.split('\n');
    final out = StringBuffer();
    var first = true;

    bool isImportant(String line) {
      // Keep file headers and hunk headers.
      return line.startsWith('diff --git ') ||
          line.startsWith('index ') ||
          line.startsWith('--- ') ||
          line.startsWith('+++ ') ||
          line.startsWith('@@ ');
    }

    for (final line in lines) {
      final chunk = first ? line : '\n$line';
      final wouldLen = out.length + chunk.length;

      if (wouldLen > maxChars) {
        // Skip non-essential lines to preserve key structure.
        if (!isImportant(line)) continue;

        // If even an important line doesn't fit, stop.
        break;
      }

      out.write(chunk);
      first = false;
    }

    // If we failed to include anything (e.g. very small maxChars), hard cut.
    var text = out.toString();
    if (text.isEmpty) {
      text = diffText.substring(0, maxChars);
    }

    return (text: text, truncated: true);
  }
}



