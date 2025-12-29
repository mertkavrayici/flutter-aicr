import 'package:test/test.dart';
import 'package:aicr_cli/src/rules/rules.dart';

void main() {
  test('secret rule warns when token-like assignment exists', () {
    const diff = r'''
diff --git a/lib/config.dart b/lib/config.dart
index 111..222 100644
--- a/lib/config.dart
+++ b/lib/config.dart
@@ -1,1 +1,2 @@
 class Config {}
+const API_KEY = "supersecretvalue123";
''';

    final r = SecretOrEnvExposureRule().evaluate(
      changedFiles: const ['lib/config.dart'],
      diffText: diff,
    );

    expect(r.status.name, 'warn');
  });
}
