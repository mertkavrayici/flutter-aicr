import 'package:test/test.dart';
import 'package:aicr_cli/src/rules/rules.dart';

void main() {
  group('DiffSecretPatternsRule', () {
    test('warns when token= pattern is added in diff', () {
      const diff = r'''
diff --git a/lib/config.dart b/lib/config.dart
index 111..222 100644
--- a/lib/config.dart
+++ b/lib/config.dart
@@ -1,1 +1,2 @@
 class Config {}
+final token = "abc"; // token=
''';

      final r = DiffSecretPatternsRule().evaluate(
        changedFiles: const ['lib/config.dart'],
        diffText: diff,
      );

      expect(r.status.name, 'warn');
    });

    test('passes when no secret-ish patterns exist', () {
      const diff = r'''
diff --git a/lib/a.dart b/lib/a.dart
index 111..222 100644
--- a/lib/a.dart
+++ b/lib/a.dart
@@ -1,1 +1,2 @@
 class A {}
+// normal change
''';

      final r = DiffSecretPatternsRule().evaluate(
        changedFiles: const ['lib/a.dart'],
        diffText: diff,
      );

      expect(r.status.name, 'pass');
    });
  });
}
