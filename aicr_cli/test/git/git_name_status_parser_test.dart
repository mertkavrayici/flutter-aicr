import 'package:aicr_cli/src/git/git.dart';
import 'package:test/test.dart';

void main() {
  test('parses added, modified, deleted', () {
    final input =
        'A\u0000lib/a.dart\u0000M\u0000lib/b.dart\u0000D\u0000lib/c.dart\u0000';
    final parser = GitNameStatusParser();

    final result = parser.parseZOutput(input);

    expect(result.length, 3);
    expect(result[0].changeType.name, 'added');
    expect(result[1].changeType.name, 'modified');
    expect(result[2].changeType.name, 'deleted');
  });

  test('parses renamed file', () {
    final input = 'R100\u0000lib/old.dart\u0000lib/new.dart\u0000';
    final parser = GitNameStatusParser();

    final result = parser.parseZOutput(input);

    expect(result.length, 1);
    expect(result.first.path, 'lib/new.dart');
    expect(result.first.changeType.name, 'renamed');
  });

  test('handles malformed input gracefully', () {
    final parser = GitNameStatusParser();

    // Truncated R status (missing tokens)
    final truncatedR = 'R100\u0000lib/old.dart\u0000';
    final result1 = parser.parseZOutput(truncatedR);
    expect(result1, isEmpty);

    // Truncated regular status (missing path)
    final truncatedStatus = 'A\u0000';
    final result2 = parser.parseZOutput(truncatedStatus);
    expect(result2, isEmpty);

    // Empty input
    final result3 = parser.parseZOutput('');
    expect(result3, isEmpty);
  });
}
