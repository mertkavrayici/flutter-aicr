import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';

import '../../bin/aicr_cli.dart' as cli;

void main() {
  group('CLI --ai / --ai-mode', () {
    test(
      '--ai --ai-mode fake -> meta.ai enabled+mode and AI findings produced',
      () async {
        final tmpDir = Directory('tmp/cli_tests')..createSync(recursive: true);
        final diffFile = File('${tmpDir.path}/todo.diff');
        final outFile = File('${tmpDir.path}/out.json');

        diffFile.writeAsStringSync(r'''
diff --git a/lib/a.dart b/lib/a.dart
index 111..222 100644
--- a/lib/a.dart
+++ b/lib/a.dart
@@ -1,1 +1,2 @@
 class A {}
+const token = "abc"; // token=
''');

        await cli.main([
          '--repo',
          'repo',
          '--diff',
          diffFile.path,
          '--out',
          outFile.path,
          '--format',
          'json',
          '--ai',
          '--ai-mode',
          'fake',
        ]);

        final json =
            jsonDecode(outFile.readAsStringSync()) as Map<String, dynamic>;
        final meta = json['meta'] as Map<String, dynamic>;
        final ai = meta['ai'] as Map<String, dynamic>;

        expect(ai['enabled'], true);
        expect(ai['mode'], 'fake');

        final findings = (json['findings'] as List<dynamic>);
        expect(findings.length, greaterThanOrEqualTo(1));
      },
    );

    test(
      '--ai-mode fake (without --ai) -> ignored; meta.ai OFF and no findings',
      () async {
        final tmpDir = Directory('tmp/cli_tests')..createSync(recursive: true);
        final diffFile = File('${tmpDir.path}/todo_noai.diff');
        final outFile = File('${tmpDir.path}/out_noai.json');

        diffFile.writeAsStringSync(r'''
diff --git a/lib/a.dart b/lib/a.dart
index 111..222 100644
--- a/lib/a.dart
+++ b/lib/a.dart
@@ -1,1 +1,2 @@
 class A {}
+// TODO: refactor this later
''');

        await cli.main([
          '--repo',
          'repo',
          '--diff',
          diffFile.path,
          '--out',
          outFile.path,
          '--format',
          'json',
          '--ai-mode',
          'fake',
        ]);

        final json =
            jsonDecode(outFile.readAsStringSync()) as Map<String, dynamic>;
        final meta = json['meta'] as Map<String, dynamic>;
        final ai = meta['ai'] as Map<String, dynamic>;

        expect(ai['enabled'], false);
        expect(ai['mode'], 'noop');

        final findings = (json['findings'] as List<dynamic>);
        expect(findings, isEmpty);
      },
    );

    test('--ai --ai-mode noop -> meta.ai ON but findings empty', () async {
      final tmpDir = Directory('tmp/cli_tests')..createSync(recursive: true);
      final diffFile = File('${tmpDir.path}/todo_noop.diff');
      final outFile = File('${tmpDir.path}/out_noop_ai.json');

      diffFile.writeAsStringSync(r'''
diff --git a/lib/a.dart b/lib/a.dart
index 111..222 100644
--- a/lib/a.dart
+++ b/lib/a.dart
@@ -1,1 +1,2 @@
 class A {}
+// TODO: refactor this later
''');

      await cli.main([
        '--repo',
        'repo',
        '--diff',
        diffFile.path,
        '--out',
        outFile.path,
        '--format',
        'json',
        '--ai',
        '--ai-mode',
        'noop',
      ]);

      final json =
          jsonDecode(outFile.readAsStringSync()) as Map<String, dynamic>;
      final meta = json['meta'] as Map<String, dynamic>;
      final ai = meta['ai'] as Map<String, dynamic>;

      expect(ai['enabled'], true);
      expect(ai['mode'], 'noop');

      final findings = (json['findings'] as List<dynamic>);
      expect(findings, isEmpty);
    });

    test('--ai --ai-mode openai -> meta.ai ON and mode openai (safe when key missing)', () async {
      final tmpDir = Directory('tmp/cli_tests')..createSync(recursive: true);
      final diffFile = File('${tmpDir.path}/todo_openai.diff');
      final outFile = File('${tmpDir.path}/out_openai.json');

      // Keep diff intentionally harmless so deterministic rules produce no findings.
      diffFile.writeAsStringSync(r'''
diff --git a/lib/a.dart b/lib/a.dart
index 111..222 100644
--- a/lib/a.dart
+++ b/lib/a.dart
@@ -1,1 +1,2 @@
 class A {}
+class B {}
''');

      await cli.main([
        '--repo',
        'repo',
        '--diff',
        diffFile.path,
        '--out',
        outFile.path,
        '--format',
        'json',
        '--ai',
        '--ai-mode',
        'openai',
      ]);

      final json =
          jsonDecode(outFile.readAsStringSync()) as Map<String, dynamic>;
      final meta = json['meta'] as Map<String, dynamic>;
      final ai = meta['ai'] as Map<String, dynamic>;

      expect(ai['enabled'], true);
      expect(ai['mode'], 'openai');

      final findings = (json['findings'] as List<dynamic>);
      expect(findings, isEmpty);
    });
  });
}
