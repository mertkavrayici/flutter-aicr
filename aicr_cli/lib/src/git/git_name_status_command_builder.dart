enum GitDiffMode { workingTree, staged, range }

final class GitNameStatusCommandBuilder {
  const GitNameStatusCommandBuilder();

  List<String> build({required GitDiffMode mode, String? range}) {
    final base = <String>['git', 'diff', '--name-status', '-z', '-M'];

    switch (mode) {
      case GitDiffMode.workingTree:
        return base;

      case GitDiffMode.staged:
        return [...base, '--staged'];

      case GitDiffMode.range:
        if (range == null) {
          throw ArgumentError('range is required for GitDiffMode.range');
        }
        return [...base, range];
    }
  }
}
