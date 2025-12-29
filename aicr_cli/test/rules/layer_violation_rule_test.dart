import 'package:test/test.dart';
import 'package:aicr_cli/src/rules/rules.dart';

void main() {
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
  });

  test('passes when no presentation->data import', () {
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
}
