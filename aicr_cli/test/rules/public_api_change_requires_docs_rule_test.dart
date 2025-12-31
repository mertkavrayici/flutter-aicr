import 'package:test/test.dart';
import 'package:aicr_cli/src/rules/rules.dart';

void main() {
  group('PublicApiChangeRequiresDocsRule', () {
    test('warns when lib/src changes but README/CHANGELOG not touched', () {
      final r = PublicApiChangeRequiresDocsRule().evaluate(
        changedFiles: const ['lib/src/foo.dart', 'lib/src/bar/baz.dart'],
        diffText: 'diff',
      );

      expect(r.status.name, 'warn');
    });

    test('passes when README touched alongside lib/src changes', () {
      final r = PublicApiChangeRequiresDocsRule().evaluate(
        changedFiles: const ['lib/src/foo.dart', 'README.md'],
        diffText: 'diff',
      );

      expect(r.status.name, 'pass');
    });
  });
}
