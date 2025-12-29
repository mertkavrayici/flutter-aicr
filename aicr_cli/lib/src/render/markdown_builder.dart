final class MarkdownBuilder {
  final _b = StringBuffer();

  void h2(String text) => _b.writeln('## $text\n');
  void h3(String text) => _b.writeln('### $text\n');

  void p(String text) => _b.writeln('$text\n');

  void bullet(String text) => _b.writeln('- $text');
  void nl() => _b.writeln();

  void codeBlock(String code, {String lang = ''}) {
    _b.writeln('```$lang');
    _b.writeln(code);
    _b.writeln('```\n');
  }

  void table(List<String> header, List<List<String>> rows) {
    _b.writeln('| ${header.join(' | ')} |');
    _b.writeln('| ${List.filled(header.length, '---').join(' | ')} |');
    for (final r in rows) {
      _b.writeln('| ${r.join(' | ')} |');
    }
    _b.writeln();
  }

  @override
  String toString() => _b.toString();
}
