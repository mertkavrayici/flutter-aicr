import 'dart:io';

import 'package:args/args.dart';
import 'package:aicr_cli/src/ai/ai.dart';
import 'package:aicr_cli/src/engine/aicr_engine.dart';
import 'package:aicr_cli/src/git/git.dart';
import 'package:aicr_cli/src/render/pr_comment_renderer.dart';
import 'package:aicr_cli/src/report/aicr_report.dart';

enum CliMode { gitDiff, gitNameStatus }

enum CliFormat { json, prComment }

void main(List<String> args) async {
  final parser = ArgParser()
    ..addOption('repo', help: 'Repository name')
    ..addOption('repo-path', help: 'Local repository path')
    ..addOption(
      'mode',
      allowed: ['git_diff', 'git_name_status'],
      defaultsTo: 'git_diff',
      help: 'Mode: git_diff or git_name_status',
    )
    ..addOption('range', help: 'Git range (e.g., origin/main...HEAD)')
    ..addOption('diff', help: 'Path to diff text file')
    ..addOption('out', defaultsTo: 'tmp/report.json', help: 'Output file path')
    ..addOption(
      'format',
      allowed: ['json', 'pr_comment'],
      defaultsTo: 'json',
      help: 'Output format: json or pr_comment',
    )
    ..addFlag('ai', defaultsTo: false, help: 'Enable AI review')
    ..addOption(
      'lang',
      allowed: ['en', 'tr'],
      defaultsTo: 'en',
      help: 'Language: en or tr',
    );

  try {
    final results = parser.parse(args);

    // Parse mode
    final mode = results['mode'] == 'git_name_status'
        ? CliMode.gitNameStatus
        : CliMode.gitDiff;

    // Parse format
    final format = results['format'] == 'pr_comment'
        ? CliFormat.prComment
        : CliFormat.json;

    // Parse language
    final language = results['lang'] == 'tr' ? AiLanguage.tr : AiLanguage.en;

    // Get repo path (optional, defaults to current directory)
    final repoPath = results['repo-path'] as String? ?? Directory.current.path;

    // Get repo name (optional, defaults to directory name)
    final repoName =
        results['repo'] as String? ??
        Directory(
          repoPath,
        ).uri.pathSegments.where((s) => s.isNotEmpty).lastOrNull ??
        'unknown';

    // Get diff text
    String diffText;
    if (results['diff'] != null) {
      // Read from file
      final diffFile = File(results['diff'] as String);
      if (!diffFile.existsSync()) {
        stderr.writeln('Error: Diff file not found: ${results['diff']}');
        exit(1);
      }
      diffText = diffFile.readAsStringSync();
    } else {
      // Get from git command
      diffText = await _getGitDiffText(
        repoPath: repoPath,
        mode: mode,
        range: results['range'] as String?,
      );
    }

    // Get file list if mode is git_name_status and repo-path is provided
    List<FileEntry>? files;
    if (mode == CliMode.gitNameStatus && results['repo-path'] != null) {
      files = await _getChangedFiles(
        repoPath: repoPath,
        range: results['range'] as String?,
      );
    }

    // Run analysis
    final report = await AicrEngine.analyze(
      diffText: diffText,
      aiEnabled: results['ai'] as bool,
      repoName: repoName,
      language: language,
      files: files,
    );

    // Generate output
    final output = format == CliFormat.json
        ? report.toPrettyJson()
        : PrCommentRenderer().render(report, locale: results['lang'] as String);

    // Write to file
    final outFile = File(results['out'] as String);
    outFile.parent.createSync(recursive: true);
    outFile.writeAsStringSync(output);

    // Also print to stdout for convenience
    stdout.writeln(output);
  } on FormatException catch (e) {
    stderr.writeln('Error: ${e.message}');
    stderr.writeln('');
    stderr.writeln(parser.usage);
    exit(1);
  } catch (e, stackTrace) {
    stderr.writeln('Error: $e');
    if (e is! StateError) {
      // Only print stack trace for unexpected errors
      stderr.writeln('Stack trace: $stackTrace');
    }
    exit(1);
  }
}

/// Gets git diff text (not just file list)
Future<String> _getGitDiffText({
  required String repoPath,
  required CliMode mode,
  String? range,
}) async {
  final runner = IoGitProcessRunner();
  final args = <String>['git', 'diff'];

  if (mode == CliMode.gitNameStatus) {
    // For git_name_status mode, we still need the diff text
    // but we might want to use a different approach
    // For now, just get the diff
  }

  if (range != null) {
    args.add(range);
  }

  final result = await runner.run(repoPath: repoPath, args: args);

  if (result.exitCode != 0) {
    throw StateError('git diff failed: ${result.stderr}');
  }

  return result.stdout;
}

/// Gets changed files using GitChangedFilesService
Future<List<FileEntry>> _getChangedFiles({
  required String repoPath,
  String? range,
}) async {
  final runner = IoGitProcessRunner();
  final commandBuilder = GitNameStatusCommandBuilder();
  final parser = GitNameStatusParser();
  final service = GitChangedFilesService(
    runner: runner,
    commandBuilder: commandBuilder,
    parser: parser,
  );

  final gitMode = range != null ? GitDiffMode.range : GitDiffMode.workingTree;

  return await service.getChangedFiles(
    repoPath: repoPath,
    mode: gitMode,
    range: range,
  );
}
