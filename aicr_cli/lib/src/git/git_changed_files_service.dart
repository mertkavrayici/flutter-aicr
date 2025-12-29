import '../report/aicr_report.dart';
import 'git_name_status_command_builder.dart';
import 'git_name_status_parser.dart';
import 'git_process_runner.dart';

final class GitChangedFilesService {
  final GitProcessRunner runner;
  final GitNameStatusCommandBuilder commandBuilder;
  final GitNameStatusParser parser;

  const GitChangedFilesService({
    required this.runner,
    required this.commandBuilder,
    required this.parser,
  });

  Future<List<FileEntry>> getChangedFiles({
    required String repoPath,
    required GitDiffMode mode,
    String? range,
  }) async {
    final args = commandBuilder.build(mode: mode, range: range);
    final result = await runner.run(repoPath: repoPath, args: args);

    if (result.exitCode != 0) {
      throw StateError('git diff failed: ${result.stderr}');
    }

    return parser.parseZOutput(result.stdout);
  }
}
