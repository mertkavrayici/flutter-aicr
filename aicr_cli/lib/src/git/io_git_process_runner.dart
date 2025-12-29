import 'dart:io';
import 'git_process_runner.dart';

final class IoGitProcessRunner implements GitProcessRunner {
  @override
  Future<GitProcessResult> run({
    required String repoPath,
    required List<String> args,
  }) async {
    final result = await Process.run(
      args.first,
      args.sublist(1),
      workingDirectory: repoPath,
    );

    return GitProcessResult(
      exitCode: result.exitCode,
      stdout: (result.stdout ?? '').toString(),
      stderr: (result.stderr ?? '').toString(),
    );
  }
}
