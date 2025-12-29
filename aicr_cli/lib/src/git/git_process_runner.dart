abstract interface class GitProcessRunner {
  Future<GitProcessResult> run({
    required String repoPath,
    required List<String> args,
  });
}

final class GitProcessResult {
  final int exitCode;
  final String stdout;
  final String stderr;

  const GitProcessResult({
    required this.exitCode,
    required this.stdout,
    required this.stderr,
  });
}
