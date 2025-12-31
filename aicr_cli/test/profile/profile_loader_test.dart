import 'dart:io';

import 'package:test/test.dart';

import 'package:aicr_cli/src/profile/profile_loader.dart';

void main() {
  test('missing file -> default profile, profileLoaded=false', () {
    final dir = Directory('tmp/test_profile_missing')..createSync(recursive: true);
    final loader = ProfileLoader();

    final profile = loader.load(dir.path);
    expect(profile.isEmpty, isTrue);
    expect(loader.lastProfileLoaded, isFalse);
    expect(loader.lastProfilePath, isNull);
  });

  test('present profile -> loads fields correctly (priority .aicr/profile.yaml)', () {
    final dir = Directory('tmp/test_profile_present')..createSync(recursive: true);
    final aicrDir = Directory('${dir.path}/.aicr')..createSync(recursive: true);
    final file = File('${aicrDir.path}/profile.yaml');

    file.writeAsStringSync('''
projectName: Budgetment
architecture: Clean-ish (feature-first)
stateManagement: bloc
routing: go_router
models: freezed/json_serializable
testing: unit + widget
language: en
forbiddenImports:
  - "package:budgetment/features/transactions/* from core"
  - "dart:io in UI"
''');

    final loader = ProfileLoader();
    final profile = loader.load(dir.path);

    expect(loader.lastProfileLoaded, isTrue);
    expect(loader.lastProfilePath, file.path);

    expect(profile.projectName, 'Budgetment');
    expect(profile.stateManagement, 'bloc');
    expect(profile.language, 'en');
    expect(profile.forbiddenImports.length, 2);
  });
}



