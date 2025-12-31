import 'package:test/test.dart';

import 'package:aicr_cli/src/ai/ai.dart';

void main() {
  test('redacts secrets while preserving structure', () {
    const diff = r'''
diff --git a/.env b/.env
index 111..222 100644
--- a/.env
+++ b/.env
@@ -1,3 +1,3 @@
-API_KEY=oldvalue
+API_KEY=newvalue
+TOKEN=abc123
+AWS_ACCESS_KEY_ID=AKIA123456789
+Authorization: Bearer sk-live-123
+-----BEGIN PRIVATE KEY-----
+abc
+def
+-----END PRIVATE KEY-----
''';

    const r = DiffRedactor();
    final out = r.redact(diff);

    expect(out, contains('diff --git a/.env b/.env'));
    expect(out, contains('+++ b/.env'));
    expect(out, contains('+API_KEY=***REDACTED***'));
    expect(out, contains('+TOKEN=***REDACTED***'));
    expect(out, contains('+AWS_ACCESS_KEY_ID=***REDACTED***'));
    expect(out, contains('Authorization: Bearer ***REDACTED***'));
    expect(out, contains('-----BEGIN PRIVATE KEY-----\n***REDACTED***\n-----END PRIVATE KEY-----'));
    expect(out, isNot(contains('sk-live-123')));
    expect(out, isNot(contains('AKIA123456789')));
    expect(out, isNot(contains('newvalue')));
  });

  test('normal diff unchanged', () {
    const diff = r'''
diff --git a/lib/a.dart b/lib/a.dart
index 111..222 100644
--- a/lib/a.dart
+++ b/lib/a.dart
@@ -1,1 +1,2 @@
 class A {}
+class B {}
''';

    const r = DiffRedactor();
    final out = r.redact(diff);
    expect(out, diff);
  });
}



