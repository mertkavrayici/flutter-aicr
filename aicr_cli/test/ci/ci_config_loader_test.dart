import 'dart:io';

import 'package:test/test.dart';

import 'package:aicr_cli/src/ci/ci_config_loader.dart';

void main() {
  group('CiConfigLoader', () {
    test('missing file -> default config, lastConfigLoaded=false', () {
      final dir = Directory('tmp/test_ci_config_missing')..createSync(recursive: true);
      final loader = CiConfigLoader();

      final config = loader.load(dir.path);
      expect(config.postComment, false);
      expect(config.commentMode, 'update');
      expect(config.marker, 'AICR_COMMENT');
      expect(loader.lastConfigLoaded, isFalse);
      expect(loader.lastConfigPath, isNull);
    });

    test('present config -> loads fields correctly', () {
      final dir = Directory('tmp/test_ci_config_present')..createSync(recursive: true);
      final aicrDir = Directory('${dir.path}/.aicr')..createSync(recursive: true);
      final file = File('${aicrDir.path}/ci.yaml');

      file.writeAsStringSync('''
postComment: true
commentMode: always_new
marker: "CUSTOM_MARKER"
''');

      final loader = CiConfigLoader();
      final config = loader.load(dir.path);

      expect(loader.lastConfigLoaded, isTrue);
      expect(loader.lastConfigPath, file.path);

      expect(config.postComment, true);
      expect(config.commentMode, 'always_new');
      expect(config.marker, 'CUSTOM_MARKER');
    });

    test('config with defaults -> uses defaults for missing fields', () {
      final dir = Directory('tmp/test_ci_config_partial')..createSync(recursive: true);
      final aicrDir = Directory('${dir.path}/.aicr')..createSync(recursive: true);
      final file = File('${aicrDir.path}/ci.yaml');

      file.writeAsStringSync('''
postComment: true
# commentMode and marker missing, should use defaults
''');

      final loader = CiConfigLoader();
      final config = loader.load(dir.path);

      expect(config.postComment, true);
      expect(config.commentMode, 'update'); // default
      expect(config.marker, 'AICR_COMMENT'); // default
    });

    test('invalid commentMode -> falls back to update', () {
      final dir = Directory('tmp/test_ci_config_invalid_mode')..createSync(recursive: true);
      final aicrDir = Directory('${dir.path}/.aicr')..createSync(recursive: true);
      final file = File('${aicrDir.path}/ci.yaml');

      file.writeAsStringSync('''
postComment: true
commentMode: invalid_mode
marker: "TEST"
''');

      final loader = CiConfigLoader();
      final config = loader.load(dir.path);

      expect(config.postComment, true);
      expect(config.commentMode, 'update'); // invalid mode -> default
      expect(config.marker, 'TEST');
    });

    test('boolean parsing -> handles true/false strings', () {
      final dir = Directory('tmp/test_ci_config_bool')..createSync(recursive: true);
      final aicrDir = Directory('${dir.path}/.aicr')..createSync(recursive: true);
      final file = File('${aicrDir.path}/ci.yaml');

      file.writeAsStringSync('''
postComment: false
commentMode: update
marker: "TEST"
''');

      final loader = CiConfigLoader();
      final config = loader.load(dir.path);

      expect(config.postComment, false);
    });

    test('quoted strings -> strips quotes', () {
      final dir = Directory('tmp/test_ci_config_quoted')..createSync(recursive: true);
      final aicrDir = Directory('${dir.path}/.aicr')..createSync(recursive: true);
      final file = File('${aicrDir.path}/ci.yaml');

      file.writeAsStringSync('''
postComment: true
commentMode: "update"
marker: 'CUSTOM_MARKER'
''');

      final loader = CiConfigLoader();
      final config = loader.load(dir.path);

      expect(config.commentMode, 'update');
      expect(config.marker, 'CUSTOM_MARKER');
    });

    test('comments in YAML -> ignored', () {
      final dir = Directory('tmp/test_ci_config_comments')..createSync(recursive: true);
      final aicrDir = Directory('${dir.path}/.aicr')..createSync(recursive: true);
      final file = File('${aicrDir.path}/ci.yaml');

      file.writeAsStringSync('''
# This is a comment
postComment: true
commentMode: always_new  # inline comment
marker: "TEST"
''');

      final loader = CiConfigLoader();
      final config = loader.load(dir.path);

      expect(config.postComment, true);
      expect(config.commentMode, 'always_new');
      expect(config.marker, 'TEST');
    });
  });
}

