import 'package:test/test.dart';
import 'package:aicr_cli/src/rules/rules.dart';

void main() {
  group('HighEntropySecretRule', () {
    test('warns when AWS access key pattern detected', () {
      const diff = r'''
diff --git a/lib/config.dart b/lib/config.dart
index 111..222 100644
--- a/lib/config.dart
+++ b/lib/config.dart
@@ -1,1 +1,2 @@
 class Config {}
+const AWS_ACCESS_KEY = "AKIAIOSFODNN7EXAMPLE";
''';

      final r = HighEntropySecretRule().evaluate(
        changedFiles: const ['lib/config.dart'],
        diffText: diff,
      );

      expect(r.status.name, 'warn');
      expect(r.title, 'High-entropy secret/token pattern detected');
      // Evidence should include triggering file + line number + snippet (from hunk)
      expect(r.evidence, isNotEmpty);
      final ev = r.evidence
          .where((e) => e['file_path'] == 'lib/config.dart')
          .cast<Map<String, dynamic>>()
          .first;
      expect(ev['line'], 2);
      expect((ev['snippet'] as String?) ?? '', contains('AKIA'));
      expect((ev['hunk'] as String?) ?? '', contains('@@'));
    });

    test('warns when JWT token pattern detected', () {
      const diff = r'''
diff --git a/lib/auth.dart b/lib/auth.dart
index 111..222 100644
--- a/lib/auth.dart
+++ b/lib/auth.dart
@@ -1,1 +1,2 @@
 class Auth {}
+const token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyfQ.SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c";
''';

      final r = HighEntropySecretRule().evaluate(
        changedFiles: const ['lib/auth.dart'],
        diffText: diff,
      );

      expect(r.status.name, 'warn');
    });

    test('warns when high-entropy string in assignment detected', () {
      const diff = r'''
diff --git a/lib/config.dart b/lib/config.dart
index 111..222 100644
--- a/lib/config.dart
+++ b/lib/config.dart
@@ -1,1 +1,2 @@
 class Config {}
+const API_KEY = "aB3dE5fG7hI9jK1lM3nO5pQ7rS9tU1vW3xY5zA7bC9dE1fG3hI5jK7lM9";
''';

      final r = HighEntropySecretRule().evaluate(
        changedFiles: const ['lib/config.dart'],
        diffText: diff,
      );

      expect(r.status.name, 'warn');
    });

    test('warns when base64-like token detected', () {
      const diff = r'''
diff --git a/lib/config.dart b/lib/config.dart
index 111..222 100644
--- a/lib/config.dart
+++ b/lib/config.dart
@@ -1,1 +1,2 @@
 class Config {}
+const secret = "dGhpc2lzYXZlcnlsb25nc3RyaW5ndGhhdGxvb2tzbGlrZWJhc2U2NA==";
''';

      final r = HighEntropySecretRule().evaluate(
        changedFiles: const ['lib/config.dart'],
        diffText: diff,
      );

      expect(r.status.name, 'warn');
    });

    test('passes when normal string detected (low entropy)', () {
      const diff = r'''
diff --git a/lib/config.dart b/lib/config.dart
index 111..222 100644
--- a/lib/config.dart
+++ b/lib/config.dart
@@ -1,1 +1,2 @@
 class Config {}
+const message = "Hello World This Is A Normal String";
''';

      final r = HighEntropySecretRule().evaluate(
        changedFiles: const ['lib/config.dart'],
        diffText: diff,
      );

      expect(r.status.name, 'pass');
    });

    test('passes when short string detected (< 20 chars)', () {
      const diff = r'''
diff --git a/lib/config.dart b/lib/config.dart
index 111..222 100644
--- a/lib/config.dart
+++ b/lib/config.dart
@@ -1,1 +1,2 @@
 class Config {}
+const short = "short123456789";
''';

      final r = HighEntropySecretRule().evaluate(
        changedFiles: const ['lib/config.dart'],
        diffText: diff,
      );

      expect(r.status.name, 'pass');
    });

    test('passes when UUID detected (false positive filter)', () {
      const diff = r'''
diff --git a/lib/config.dart b/lib/config.dart
index 111..222 100644
--- a/lib/config.dart
+++ b/lib/config.dart
@@ -1,1 +1,2 @@
 class Config {}
+const id = "550e8400-e29b-41d4-a716-446655440000";
''';

      final r = HighEntropySecretRule().evaluate(
        changedFiles: const ['lib/config.dart'],
        diffText: diff,
      );

      expect(r.status.name, 'pass');
    });

    test('passes when data URL detected (false positive filter)', () {
      const diff = r'''
diff --git a/lib/image.dart b/lib/image.dart
index 111..222 100644
--- a/lib/image.dart
+++ b/lib/image.dart
@@ -1,1 +1,2 @@
 class Image {}
+const imageData = "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==";
''';

      final r = HighEntropySecretRule().evaluate(
        changedFiles: const ['lib/image.dart'],
        diffText: diff,
      );

      expect(r.status.name, 'pass');
    });

    test('passes when comment line detected', () {
      const diff = r'''
diff --git a/lib/config.dart b/lib/config.dart
index 111..222 100644
--- a/lib/config.dart
+++ b/lib/config.dart
@@ -1,1 +1,2 @@
 class Config {}
+// This is a comment with AKIAIOSFODNN7EXAMPLE in it
''';

      final r = HighEntropySecretRule().evaluate(
        changedFiles: const ['lib/config.dart'],
        diffText: diff,
      );

      expect(r.status.name, 'pass');
    });

    test('warns when token in secret-like context detected', () {
      const diff = r'''
diff --git a/lib/config.dart b/lib/config.dart
index 111..222 100644
--- a/lib/config.dart
+++ b/lib/config.dart
@@ -1,1 +1,2 @@
 class Config {}
+const secret_token = "aB3dE5fG7hI9jK1lM3nO5pQ7rS9tU1vW3xY5zA7bC9dE1fG3hI5jK7lM9";
''';

      final r = HighEntropySecretRule().evaluate(
        changedFiles: const ['lib/config.dart'],
        diffText: diff,
      );

      expect(r.status.name, 'warn');
    });

    test('message contains risk, reason, and suggested action', () {
      const diff = r'''
diff --git a/lib/config.dart b/lib/config.dart
index 111..222 100644
--- a/lib/config.dart
+++ b/lib/config.dart
@@ -1,1 +1,2 @@
 class Config {}
+const API_KEY = "AKIAIOSFODNN7EXAMPLE123456";
''';

      final r = HighEntropySecretRule().evaluate(
        changedFiles: const ['lib/config.dart'],
        diffText: diff,
      );

      expect(r.status.name, 'warn');
      final messageEn = r.message['en'] ?? '';
      expect(messageEn, contains('Risk:'));
      expect(messageEn, contains('Reason:'));
      expect(messageEn, contains('Suggested action:'));
    });

    test('ignores generated dart files by default', () {
      const diff = r'''
diff --git a/lib/config.g.dart b/lib/config.g.dart
index 111..222 100644
--- a/lib/config.g.dart
+++ b/lib/config.g.dart
@@ -10,1 +10,2 @@
 class ConfigGen {}
+const AWS_ACCESS_KEY = "AKIAIOSFODNN7EXAMPLE";
''';

      final r = HighEntropySecretRule().evaluate(
        changedFiles: const ['lib/config.g.dart'],
        diffText: diff,
      );

      expect(r.status.name, 'pass');
    });

    test('ignores l10n arb files by default', () {
      const diff = r'''
diff --git a/lib/l10n/app_en.arb b/lib/l10n/app_en.arb
index 111..222 100644
--- a/lib/l10n/app_en.arb
+++ b/lib/l10n/app_en.arb
@@ -10,1 +10,2 @@
 {
+  "token": "AKIAIOSFODNN7EXAMPLE"
 }
''';

      final r = HighEntropySecretRule().evaluate(
        changedFiles: const ['lib/l10n/app_en.arb'],
        diffText: diff,
      );

      expect(r.status.name, 'pass');
    });

    test('ignores injection.config.dart by default', () {
      const diff = r'''
diff --git a/lib/di/injection.config.dart b/lib/di/injection.config.dart
index 111..222 100644
--- a/lib/di/injection.config.dart
+++ b/lib/di/injection.config.dart
@@ -10,1 +10,2 @@
 class InjectionConfig {}
+const token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.abc.def";
''';

      final r = HighEntropySecretRule().evaluate(
        changedFiles: const ['lib/di/injection.config.dart'],
        diffText: diff,
      );

      expect(r.status.name, 'pass');
    });

    test('ignores *.freezed.dart files by default', () {
      const diff = r'''
diff --git a/lib/models/user.freezed.dart b/lib/models/user.freezed.dart
index 111..222 100644
--- a/lib/models/user.freezed.dart
+++ b/lib/models/user.freezed.dart
@@ -10,1 +10,2 @@
 class UserFreezed {}
+const AWS_ACCESS_KEY = "AKIAIOSFODNN7EXAMPLE";
''';

      final r = HighEntropySecretRule().evaluate(
        changedFiles: const ['lib/models/user.freezed.dart'],
        diffText: diff,
      );

      expect(r.status.name, 'pass');
    });

    test('dedupes identical snippets within the same file', () {
      const diff = r'''
diff --git a/lib/config.dart b/lib/config.dart
index 111..222 100644
--- a/lib/config.dart
+++ b/lib/config.dart
@@ -1,1 +1,4 @@
 class Config {}
+const AWS_ACCESS_KEY = "AKIAIOSFODNN7EXAMPLE";
+const AWS_ACCESS_KEY = "AKIAIOSFODNN7EXAMPLE";
''';

      final r = HighEntropySecretRule().evaluate(
        changedFiles: const ['lib/config.dart'],
        diffText: diff,
      );

      expect(r.status.name, 'warn');
      final matches = r.evidence
          .where((e) => e['file_path'] == 'lib/config.dart')
          .where((e) => ((e['snippet'] as String?) ?? '').contains('AKIA'))
          .toList(growable: false);
      expect(matches.length, 1);
    });
  });
}
