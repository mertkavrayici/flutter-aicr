import 'dart:io';

import 'package:aicr_cli/aicr_cli.dart';
import 'package:aicr_cli/src/ai/ai.dart';
import 'package:aicr_cli/src/git/git.dart';
import 'package:test/test.dart';

Future<void> _git(String repoPath, List<String> args) async {
  final r = await Process.run('git', args, workingDirectory: repoPath);
  if (r.exitCode != 0) {
    throw StateError(
      'git ${args.join(' ')} failed in $repoPath\n'
      'stdout: ${r.stdout}\n'
      'stderr: ${r.stderr}\n',
    );
  }
}

Future<Directory> _createRepo({
  required String prefix,
  required String fileName,
}) async {
  final dir = await Directory.systemTemp.createTemp(prefix);

  await _git(dir.path, ['init']);
  await _git(dir.path, ['config', 'user.email', 'aicr@test.local']);
  await _git(dir.path, ['config', 'user.name', 'AICR Test']);

  final f = File('${dir.path}/$fileName');
  await f.writeAsString('line1\n');
  await _git(dir.path, ['add', fileName]);
  await _git(dir.path, ['commit', '-m', 'init']);

  // Unstaged modification so `git diff` and `git diff --name-status` see it.
  await f.writeAsString('line1\nline2\n');

  return dir;
}

void main() {
  group('repo-path regression', () {
    test(
      'git commands use repoPath (not current directory) when repo-path is provided',
      () async {
        final originalCwd = Directory.current;

        final targetRepo = await _createRepo(
          prefix: 'aicr_target_',
          fileName: 'target.txt',
        );
        final decoyRepo = await _createRepo(
          prefix: 'aicr_decoy_',
          fileName: 'decoy.txt',
        );

        addTearDown(() async {
          Directory.current = originalCwd;
          try {
            await targetRepo.delete(recursive: true);
          } catch (_) {}
          try {
            await decoyRepo.delete(recursive: true);
          } catch (_) {}
        });

        // If git accidentally runs in current directory, it will see decoy.txt instead.
        Directory.current = decoyRepo;

        // Mimic CLI flow: get diff + changed files using the git layer with repoPath.
        final runner = IoGitProcessRunner();
        final diff = await runner.run(
          repoPath: targetRepo.path,
          args: const ['git', 'diff'],
        );
        expect(diff.exitCode, 0);
        expect(diff.stdout, contains('diff --git a/target.txt b/target.txt'));
        expect(
          diff.stdout,
          isNot(contains('diff --git a/decoy.txt b/decoy.txt')),
        );

        final files =
            await GitChangedFilesService(
              runner: IoGitProcessRunner(),
              commandBuilder: const GitNameStatusCommandBuilder(),
              parser: const GitNameStatusParser(),
            ).getChangedFiles(
              repoPath: targetRepo.path,
              mode: GitDiffMode.workingTree,
            );

        expect(files.map((e) => e.path), contains('target.txt'));
        expect(files.map((e) => e.path), isNot(contains('decoy.txt')));

        // Engine should carry those files into the report.
        final report = await AicrEngine.analyze(
          diffText: diff.stdout,
          aiEnabled: false,
          repoName: 'tmp',
          language: AiLanguage.en,
          files: files,
        );

        expect(report.files.map((e) => e.path), contains('target.txt'));
        expect(report.files.map((e) => e.path), isNot(contains('decoy.txt')));
      },
    );
  });
}
