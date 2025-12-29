import 'package:test/test.dart';
import 'package:aicr_cli/src/rules/rules.dart';

void main() {
  test('warns when diff is very large', () {
    final b = StringBuffer()
      ..writeln('diff --git a/lib/a.dart b/lib/a.dart')
      ..writeln('index 111..222 100644')
      ..writeln('--- a/lib/a.dart')
      ..writeln('+++ b/lib/a.dart')
      ..writeln('@@ -1,1 +1,1 @@');

    for (var i = 0; i < 700; i++) {
      b.writeln('+line $i');
    }

    final r = LargeDiffSuggestsSplitRule(
      warnChangedLineThreshold: 600,
    ).evaluate(changedFiles: const ['lib/a.dart'], diffText: b.toString());

    expect(r.status.name, 'warn');
  });

  test('passes when diff is small', () {
    const diff = r'''
diff --git a/lib/a.dart b/lib/a.dart
index 111..222 100644
--- a/lib/a.dart
+++ b/lib/a.dart
@@ -1,1 +1,2 @@
 class A {}
+class B {}
''';

    final r = LargeDiffSuggestsSplitRule(
      warnChangedLineThreshold: 600,
    ).evaluate(changedFiles: const ['lib/a.dart'], diffText: diff);

    expect(r.status.name, 'pass');
  });
}
