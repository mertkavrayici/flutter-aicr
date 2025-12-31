import 'dart:io';

import 'package:args/args.dart';
import 'package:aicr_cli/src/ai/ai.dart';
import 'package:aicr_cli/src/engine/aicr_engine.dart';
import 'package:aicr_cli/src/git/git.dart';
import 'package:aicr_cli/src/render/pr_comment_renderer.dart';
import 'package:aicr_cli/src/report/aicr_report.dart';
import 'package:aicr_cli/src/util/aicr_logger.dart';
import 'package:aicr_cli/src/profile/profile_loader.dart';
import 'package:aicr_cli/src/ci/ci_config_loader.dart';
import 'package:aicr_cli/src/comment/github_pr_comment_poster.dart';

enum CliMode { gitDiff, gitNameStatus }

enum CliFormat { json, prComment }

Future<void> main(List<String> args) async {
  final parser = ArgParser()
    ..addCommand('analyze', _createAnalyzeCommandParser());

  try {
    final results = parser.parse(args);
    final command = results.command;

    if (command != null && command.name == 'analyze') {
      await _runAnalyze(command);
    } else {
      stderr.writeln('Error: No command specified');
      stderr.writeln('');
      stderr.writeln(parser.usage);
      exit(1);
    }
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

ArgParser _createAnalyzeCommandParser() {
  return ArgParser()
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
      'ai-mode',
      allowed: ['noop', 'fake', 'openai'],
      defaultsTo: 'noop',
      help: 'AI mode: noop|fake|openai (ignored when --ai is false)',
    )
    ..addFlag(
      'verbose',
      defaultsTo: false,
      help: 'Verbose logging (sanitized; secrets redacted)',
    )
    ..addOption(
      'lang',
      allowed: ['en', 'tr'],
      defaultsTo: 'en',
      help: 'Language: en or tr',
    )
    ..addFlag(
      'post-comment',
      help:
          'Enable posting PR/MR comments (default from .aicr/ci.yaml or false)',
    )
    ..addOption(
      'comment-mode',
      allowed: ['update', 'always_new'],
      help:
          'Comment mode: update (default) or always_new (default from .aicr/ci.yaml)',
    )
    ..addOption(
      'comment-marker',
      help:
          'Comment marker string (default from .aicr/ci.yaml or "AICR_COMMENT")',
    );
}

Future<void> _runAnalyze(ArgResults results) async {
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

  // Parse AI options
  final aiEnabled = results['ai'] as bool;
  final requestedAiMode = results['ai-mode'] as String?;
  final aiMode = aiEnabled
      ? AiModeParsing.fromString(requestedAiMode)
      : AiMode.noop;
  final verbose = results['verbose'] as bool;

  // Get repo path (optional, defaults to current directory)
  final repoPath = results['repo-path'] as String? ?? Directory.current.path;

  // Get repo name (optional, defaults to directory name)
  final repoName =
      results['repo'] as String? ??
      Directory(
        repoPath,
      ).uri.pathSegments.where((s) => s.isNotEmpty).lastOrNull ??
      'unknown';

  // Load project profile (best-effort, no-throw).
  final profileLoader = ProfileLoader();
  final projectProfile = profileLoader.load(repoPath);
  if (verbose) {
    if (profileLoader.lastProfileLoaded &&
        profileLoader.lastProfilePath != null) {
      stderr.writeln(
        'AI: profileLoaded=true path=${profileLoader.lastProfilePath}',
      );
    } else {
      stderr.writeln('AI: profileLoaded=false');
    }
  }

  // Load CI config (best-effort, no-throw).
  final ciConfigLoader = CiConfigLoader();
  final ciConfig = ciConfigLoader.load(repoPath);

  // Merge CLI flags with config (CLI overrides config)
  final postComment = results.wasParsed('post-comment')
      ? (results['post-comment'] as bool)
      : ciConfig.postComment;
  final commentMode =
      results['comment-mode'] as String? ?? ciConfig.commentMode;
  final commentMarker = results['comment-marker'] as String? ?? ciConfig.marker;

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
    aiEnabled: aiEnabled,
    aiMode: aiMode,
    repoName: repoName,
    language: language,
    files: files,
    logger: StderrAicrLogger(verbose: verbose),
    projectProfile: projectProfile,
    postComment: postComment,
    commentMode: commentMode,
    commentMarker: commentMarker,
  );

  // Generate output
  final output = format == CliFormat.json
      ? report.toPrettyJson()
      : PrCommentRenderer().render(report, locale: results['lang'] as String);

  // Write to file
  final outFile = File(results['out'] as String);
  outFile.parent.createSync(recursive: true);
  outFile.writeAsStringSync(output);

  // Post comment to GitHub if enabled and format is pr_comment
  if (postComment && format == CliFormat.prComment) {
    final logger = StderrAicrLogger(verbose: verbose);
    final poster = GitHubPrCommentPoster(logger: logger);
    await poster.post(
      bodyMarkdown: output,
      marker: commentMarker,
      commentMode: commentMode,
    );
  }

  // Also print to stdout for convenience
  stdout.writeln(output);
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
