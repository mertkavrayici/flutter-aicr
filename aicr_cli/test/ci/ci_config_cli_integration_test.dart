import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';

import '../../bin/aicr_cli.dart' as cli;

void main() {
  group('CI config CLI integration', () {
    test('config missing -> defaults used in meta output', () async {
      final tmpDir = Directory('tmp/cli_tests_ci_config')..createSync(recursive: true);
      final diffFile = File('${tmpDir.path}/test.diff');
      final outFile = File('${tmpDir.path}/out.json');

      diffFile.writeAsStringSync(r'''
diff --git a/lib/a.dart b/lib/a.dart
index 111..222 100644
--- a/lib/a.dart
+++ b/lib/a.dart
@@ -1,1 +1,2 @@
 class A {}
+const x = 1;
''');

      await cli.main([
        'analyze',
        '--repo',
        'test-repo',
        '--repo-path',
        tmpDir.path,
        '--diff',
        diffFile.path,
        '--out',
        outFile.path,
        '--format',
        'json',
      ]);

      final json = jsonDecode(outFile.readAsStringSync()) as Map<String, dynamic>;
      final meta = json['meta'] as Map<String, dynamic>;
      final ci = meta['ci'] as Map<String, dynamic>?;

      expect(ci, isNotNull);
      expect(ci!['post_comment'], false);
      expect(ci['comment_mode'], 'update');
      expect(ci['marker'], 'AICR_COMMENT');
    });

    test('config present -> values loaded and exposed in meta', () async {
      final tmpDir = Directory('tmp/cli_tests_ci_config_present')
        ..createSync(recursive: true);
      final aicrDir = Directory('${tmpDir.path}/.aicr')..createSync(recursive: true);
      final configFile = File('${aicrDir.path}/ci.yaml');
      final diffFile = File('${tmpDir.path}/test.diff');
      final outFile = File('${tmpDir.path}/out.json');

      configFile.writeAsStringSync('''
postComment: true
commentMode: always_new
marker: "CUSTOM_MARKER"
''');

      diffFile.writeAsStringSync(r'''
diff --git a/lib/a.dart b/lib/a.dart
index 111..222 100644
--- a/lib/a.dart
+++ b/lib/a.dart
@@ -1,1 +1,2 @@
 class A {}
+const x = 1;
''');

      await cli.main([
        'analyze',
        '--repo',
        'test-repo',
        '--repo-path',
        tmpDir.path,
        '--diff',
        diffFile.path,
        '--out',
        outFile.path,
        '--format',
        'json',
      ]);

      final json = jsonDecode(outFile.readAsStringSync()) as Map<String, dynamic>;
      final meta = json['meta'] as Map<String, dynamic>;
      final ci = meta['ci'] as Map<String, dynamic>?;

      expect(ci, isNotNull);
      expect(ci!['post_comment'], true);
      expect(ci['comment_mode'], 'always_new');
      expect(ci['marker'], 'CUSTOM_MARKER');
    });

    test('CLI flags override config values', () async {
      final tmpDir = Directory('tmp/cli_tests_ci_config_override')
        ..createSync(recursive: true);
      final aicrDir = Directory('${tmpDir.path}/.aicr')..createSync(recursive: true);
      final configFile = File('${aicrDir.path}/ci.yaml');
      final diffFile = File('${tmpDir.path}/test.diff');
      final outFile = File('${tmpDir.path}/out.json');

      // Config says: postComment=true, always_new, CUSTOM_MARKER
      configFile.writeAsStringSync('''
postComment: true
commentMode: always_new
marker: "CUSTOM_MARKER"
''');

      diffFile.writeAsStringSync(r'''
diff --git a/lib/a.dart b/lib/a.dart
index 111..222 100644
--- a/lib/a.dart
+++ b/lib/a.dart
@@ -1,1 +1,2 @@
 class A {}
+const x = 1;
''');

      // CLI flags override: postComment=false (via --no-post-comment), update, CLI_MARKER
      await cli.main([
        'analyze',
        '--repo',
        'test-repo',
        '--repo-path',
        tmpDir.path,
        '--diff',
        diffFile.path,
        '--out',
        outFile.path,
        '--format',
        'json',
        '--no-post-comment',
        '--comment-mode',
        'update',
        '--comment-marker',
        'CLI_MARKER',
      ]);

      final json = jsonDecode(outFile.readAsStringSync()) as Map<String, dynamic>;
      final meta = json['meta'] as Map<String, dynamic>;
      final ci = meta['ci'] as Map<String, dynamic>?;

      expect(ci, isNotNull);
      expect(ci!['post_comment'], false); // CLI override
      expect(ci['comment_mode'], 'update'); // CLI override
      expect(ci['marker'], 'CLI_MARKER'); // CLI override
    });

    test('CLI flag --post-comment enables posting', () async {
      final tmpDir = Directory('tmp/cli_tests_ci_config_flag')
        ..createSync(recursive: true);
      final diffFile = File('${tmpDir.path}/test.diff');
      final outFile = File('${tmpDir.path}/out.json');

      diffFile.writeAsStringSync(r'''
diff --git a/lib/a.dart b/lib/a.dart
index 111..222 100644
--- a/lib/a.dart
+++ b/lib/a.dart
@@ -1,1 +1,2 @@
 class A {}
+const x = 1;
''');

      await cli.main([
        'analyze',
        '--repo',
        'test-repo',
        '--repo-path',
        tmpDir.path,
        '--diff',
        diffFile.path,
        '--out',
        outFile.path,
        '--format',
        'json',
        '--post-comment',
        '--comment-mode',
        'always_new',
      ]);

      final json = jsonDecode(outFile.readAsStringSync()) as Map<String, dynamic>;
      final meta = json['meta'] as Map<String, dynamic>;
      final ci = meta['ci'] as Map<String, dynamic>?;

      expect(ci, isNotNull);
      expect(ci!['post_comment'], true);
      expect(ci['comment_mode'], 'always_new');
    });

    test('pr_comment format includes CI line with resolved values', () async {
      final tmpDir = Directory('tmp/cli_tests_ci_config_pr_comment')
        ..createSync(recursive: true);
      final aicrDir = Directory('${tmpDir.path}/.aicr')..createSync(recursive: true);
      final configFile = File('${aicrDir.path}/ci.yaml');
      final diffFile = File('${tmpDir.path}/test.diff');
      final outFile = File('${tmpDir.path}/out.md');

      configFile.writeAsStringSync('''
postComment: true
commentMode: always_new
marker: "CONFIG_MARKER"
''');

      diffFile.writeAsStringSync(r'''
diff --git a/lib/a.dart b/lib/a.dart
index 111..222 100644
--- a/lib/a.dart
+++ b/lib/a.dart
@@ -1,1 +1,2 @@
class A {}
+const x = 1;
''');

      await cli.main([
        'analyze',
        '--repo',
        'test-repo',
        '--repo-path',
        tmpDir.path,
        '--diff',
        diffFile.path,
        '--out',
        outFile.path,
        '--format',
        'pr_comment',
      ]);

      final markdown = outFile.readAsStringSync();

      // Verify CI line appears with config values
      expect(markdown, contains('**CI:** postComment=true · mode=always_new · marker=CONFIG_MARKER'));
    });

    test('pr_comment format: CLI flags override config values', () async {
      final tmpDir = Directory('tmp/cli_tests_ci_config_pr_comment_override')
        ..createSync(recursive: true);
      final aicrDir = Directory('${tmpDir.path}/.aicr')..createSync(recursive: true);
      final configFile = File('${aicrDir.path}/ci.yaml');
      final diffFile = File('${tmpDir.path}/test.diff');
      final outFile = File('${tmpDir.path}/out.md');

      configFile.writeAsStringSync('''
postComment: true
commentMode: always_new
marker: "CONFIG_MARKER"
''');

      diffFile.writeAsStringSync(r'''
diff --git a/lib/a.dart b/lib/a.dart
index 111..222 100644
--- a/lib/a.dart
+++ b/lib/a.dart
@@ -1,1 +1,2 @@
class A {}
+const x = 1;
''');

      await cli.main([
        'analyze',
        '--repo',
        'test-repo',
        '--repo-path',
        tmpDir.path,
        '--diff',
        diffFile.path,
        '--out',
        outFile.path,
        '--format',
        'pr_comment',
        '--no-post-comment',
        '--comment-mode',
        'update',
        '--comment-marker',
        'CLI_MARKER',
      ]);

      final markdown = outFile.readAsStringSync();

      // Verify CI line shows CLI overrides
      expect(markdown, contains('**CI:** postComment=false · mode=update · marker=CLI_MARKER'));
    });
  });
}

