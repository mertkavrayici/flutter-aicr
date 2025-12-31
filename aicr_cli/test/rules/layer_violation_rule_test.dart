import 'package:test/test.dart';
import 'package:aicr_cli/src/rules/rules.dart';

void main() {
  group('LayerViolationRule', () {
    test('warns when presentation imports data', () {
      const diff = r'''
diff --git a/lib/features/foo/presentation/foo_page.dart b/lib/features/foo/presentation/foo_page.dart
index 111..222 100644
--- a/lib/features/foo/presentation/foo_page.dart
+++ b/lib/features/foo/presentation/foo_page.dart
@@ -1,1 +1,2 @@
 import 'package:flutter/material.dart';
+import 'package:my_app/features/foo/data/foo_repository_impl.dart';
''';

      final r = LayerViolationRule().evaluate(
        changedFiles: const ['lib/features/foo/presentation/foo_page.dart'],
        diffText: diff,
      );

      expect(r.status.name, 'warn');
      expect(r.message['en'], contains('Why this rule exists'));
      expect(r.message['en'], contains('What to do'));
      expect(r.message['en'], contains('presentation -> data'));

      // Evidence should include triggering import line
      expect(r.evidence, isNotEmpty);
      final ev = r.evidence.first;
      expect(ev['file_path'], 'lib/features/foo/presentation/foo_page.dart');
      expect(
        (ev['import'] as String?) ?? '',
        contains(
          "import 'package:my_app/features/foo/data/foo_repository_impl.dart';",
        ),
      );
    });

    test('warns when presentation imports domain', () {
      const diff = r'''
diff --git a/lib/features/foo/presentation/foo_page.dart b/lib/features/foo/presentation/foo_page.dart
index 111..222 100644
--- a/lib/features/foo/presentation/foo_page.dart
+++ b/lib/features/foo/presentation/foo_page.dart
@@ -1,1 +1,2 @@
 import 'package:flutter/material.dart';
+import 'package:my_app/features/foo/domain/foo_repository_impl.dart';
''';

      final r = LayerViolationRule().evaluate(
        changedFiles: const ['lib/features/foo/presentation/foo_page.dart'],
        diffText: diff,
      );

      expect(r.status.name, 'warn');
      expect(r.message['en'], contains('presentation -> domain'));
    });

    test('warns when core imports feature', () {
      const diff = r'''
diff --git a/lib/core/di/injection.dart b/lib/core/di/injection.dart
index 111..222 100644
--- a/lib/core/di/injection.dart
+++ b/lib/core/di/injection.dart
@@ -1,1 +1,2 @@
+import 'package:my_app/features/foo/domain/foo_entity.dart';
''';

      final r = LayerViolationRule().evaluate(
        changedFiles: const ['lib/core/di/injection.dart'],
        diffText: diff,
      );

      expect(r.status.name, 'warn');
      expect(r.message['en'], contains('core -> feature'));
    });

    test('passes when presentation imports domain entity (allowed)', () {
      // Domain entities are typically allowed from presentation
      // But our rule flags it - this is a design decision
      // We can adjust the rule if needed
      const diff = r'''
diff --git a/lib/features/foo/presentation/foo_page.dart b/lib/features/foo/presentation/foo_page.dart
index 111..222 100644
--- a/lib/features/foo/presentation/foo_page.dart
+++ b/lib/features/foo/presentation/foo_page.dart
@@ -1,1 +1,2 @@
 import 'package:flutter/material.dart';
+import 'package:my_app/features/foo/domain/foo_entity.dart';
''';

      final r = LayerViolationRule().evaluate(
        changedFiles: const ['lib/features/foo/presentation/foo_page.dart'],
        diffText: diff,
      );

      expect(r.status.name, 'pass');
    });

    test('passes when allowlist import detected', () {
      const diff = r'''
diff --git a/lib/features/foo/presentation/foo_page.dart b/lib/features/foo/presentation/foo_page.dart
index 111..222 100644
--- a/lib/features/foo/presentation/foo_page.dart
+++ b/lib/features/foo/presentation/foo_page.dart
@@ -1,1 +1,2 @@
 import 'package:flutter/material.dart';
+import 'package:flutter/material.dart';
''';

      final r = LayerViolationRule().evaluate(
        changedFiles: const ['lib/features/foo/presentation/foo_page.dart'],
        diffText: diff,
      );

      expect(r.status.name, 'pass');
    });

    test('passes when no layer violation', () {
      const diff = r'''
diff --git a/lib/features/foo/presentation/foo_page.dart b/lib/features/foo/presentation/foo_page.dart
index 111..222 100644
--- a/lib/features/foo/presentation/foo_page.dart
+++ b/lib/features/foo/presentation/foo_page.dart
@@ -1,1 +1,2 @@
 import 'package:flutter/material.dart';
+import 'package:my_app/shared/widgets/button.dart';
''';

      final r = LayerViolationRule().evaluate(
        changedFiles: const ['lib/features/foo/presentation/foo_page.dart'],
        diffText: diff,
      );

      expect(r.status.name, 'pass');
    });

    test('message contains why and what to do', () {
      const diff = r'''
diff --git a/lib/features/foo/presentation/foo_page.dart b/lib/features/foo/presentation/foo_page.dart
index 111..222 100644
--- a/lib/features/foo/presentation/foo_page.dart
+++ b/lib/features/foo/presentation/foo_page.dart
@@ -1,1 +1,2 @@
 import 'package:flutter/material.dart';
+import 'package:my_app/features/foo/data/foo_repository_impl.dart';
''';

      final r = LayerViolationRule().evaluate(
        changedFiles: const ['lib/features/foo/presentation/foo_page.dart'],
        diffText: diff,
      );

      expect(r.status.name, 'warn');
      final messageEn = r.message['en'] ?? '';
      expect(messageEn, contains('Why this rule exists'));
      expect(messageEn, contains('What to do'));
      expect(messageEn, contains('Clean Architecture'));
    });
  });
}
