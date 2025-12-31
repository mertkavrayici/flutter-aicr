import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';

import '../../bin/aicr_cli.dart' as cli;

void main() {
  group('analyze command', () {
    test('accepts --post-comment, --comment-mode, --comment-marker flags', () async {
      final tmpDir = Directory('tmp/cli_tests_analyze_command')
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

      // Test that the command accepts all three flags
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
        '--comment-marker',
        'TEST_MARKER',
      ]);

      final json = jsonDecode(outFile.readAsStringSync()) as Map<String, dynamic>;
      final meta = json['meta'] as Map<String, dynamic>;
      final ci = meta['ci'] as Map<String, dynamic>?;

      expect(ci, isNotNull);
      expect(ci!['post_comment'], true);
      expect(ci['comment_mode'], 'always_new');
      expect(ci['marker'], 'TEST_MARKER');
    });

    test('--post-comment sets postComment=true in output meta', () async {
      final tmpDir = Directory('tmp/cli_tests_post_comment_flag')
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
      ]);

      final json = jsonDecode(outFile.readAsStringSync()) as Map<String, dynamic>;
      final meta = json['meta'] as Map<String, dynamic>;
      final ci = meta['ci'] as Map<String, dynamic>?;

      expect(ci, isNotNull);
      expect(ci!['post_comment'], true);
    });
  });
}

