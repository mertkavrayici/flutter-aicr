import 'dart:convert';
import 'dart:io';

import '../util/aicr_logger.dart';
import 'github_api_client.dart';

/// Posts PR comments to GitHub using environment variables.
///
/// Reads from:
/// - GITHUB_TOKEN: authentication token
/// - GITHUB_REPOSITORY: owner/repo format (e.g., "owner/repo")
/// - GITHUB_EVENT_PATH: path to JSON file containing pull_request.number
///
/// Supports idempotency via hidden marker comments.
final class GitHubPrCommentPoster {
  final GitHubApiClient _client;
  final AicrLogger? _logger;
  final String? _token;
  final String? _repository;
  final String? _eventPath;

  GitHubPrCommentPoster({
    GitHubApiClient? client,
    AicrLogger? logger,
    String? token,
    String? repository,
    String? eventPath,
  })  : _client = client ?? GitHubApiClient(),
        _logger = logger,
        _token = token,
        _repository = repository,
        _eventPath = eventPath;

  /// Posts a comment to the current PR.
  ///
  /// Returns true on success, false on failure or missing env vars.
  /// Logs warnings for missing env vars or API errors (does not throw).
  Future<bool> post({
    required String bodyMarkdown,
    required String marker,
    required String commentMode, // 'update' | 'always_new'
  }) async {
    // Read environment variables (use provided values or fallback to env vars)
    final token = _token ?? Platform.environment['GITHUB_TOKEN'];
    final repository = _repository ?? Platform.environment['GITHUB_REPOSITORY'];
    final eventPath = _eventPath ?? Platform.environment['GITHUB_EVENT_PATH'];

    // Validate required env vars
    if (token == null || token.isEmpty) {
      _logger?.warn(
        'GitHub PR comment posting skipped: GITHUB_TOKEN not set',
      );
      return false;
    }

    if (repository == null || repository.isEmpty) {
      _logger?.warn(
        'GitHub PR comment posting skipped: GITHUB_REPOSITORY not set',
      );
      return false;
    }

    if (eventPath == null || eventPath.isEmpty) {
      _logger?.warn(
        'GitHub PR comment posting skipped: GITHUB_EVENT_PATH not set',
      );
      return false;
    }

    // Parse repository (owner/repo)
    final repoParts = repository.split('/');
    if (repoParts.length != 2) {
      _logger?.warn(
        'GitHub PR comment posting skipped: invalid GITHUB_REPOSITORY format (expected owner/repo)',
      );
      return false;
    }
    final owner = repoParts[0];
    final repo = repoParts[1];

    // Read PR number from GITHUB_EVENT_PATH
    int? prNumber;
    try {
      final eventFile = File(eventPath);
      if (!eventFile.existsSync()) {
        _logger?.warn(
          'GitHub PR comment posting skipped: GITHUB_EVENT_PATH file not found: $eventPath',
        );
        return false;
      }

      final eventJson = jsonDecode(eventFile.readAsStringSync()) as Map<String, dynamic>;
      final pullRequest = eventJson['pull_request'] as Map<String, dynamic>?;
      if (pullRequest == null) {
        _logger?.warn(
          'GitHub PR comment posting skipped: pull_request not found in GITHUB_EVENT_PATH',
        );
        return false;
      }

      prNumber = pullRequest['number'] as int?;
      if (prNumber == null) {
        _logger?.warn(
          'GitHub PR comment posting skipped: pull_request.number not found in GITHUB_EVENT_PATH',
        );
        return false;
      }
    } catch (e) {
      _logger?.warn(
        'GitHub PR comment posting skipped: failed to read GITHUB_EVENT_PATH: $e',
      );
      return false;
    }

    // Append hidden marker
    final bodyWithMarker = '$bodyMarkdown\n\n<!-- $marker -->';

    try {
      if (commentMode == 'always_new') {
        // Always create new comment
        await _client.createComment(
          owner: owner,
          repo: repo,
          issueNumber: prNumber,
          body: bodyWithMarker,
          token: token,
        );
        _logger?.info('Created new GitHub PR comment (mode: always_new)');
        return true;
      } else {
        // Default: update mode - find existing comment with marker
        final existingCommentId = await _findExistingComment(
          owner: owner,
          repo: repo,
          issueNumber: prNumber,
          marker: marker,
          token: token,
        );

        if (existingCommentId != null) {
          // Update existing comment
          await _client.updateComment(
            owner: owner,
            repo: repo,
            commentId: existingCommentId,
            body: bodyWithMarker,
            token: token,
          );
          _logger?.info('Updated existing GitHub PR comment (id: $existingCommentId)');
          return true;
        } else {
          // Create new comment
          await _client.createComment(
            owner: owner,
            repo: repo,
            issueNumber: prNumber,
            body: bodyWithMarker,
            token: token,
          );
          _logger?.info('Created new GitHub PR comment (mode: update)');
          return true;
        }
      }
    } catch (e) {
      _logger?.warn('Failed to post GitHub PR comment: $e');
      return false;
    }
  }

  /// Finds existing comment with matching marker.
  ///
  /// Returns comment ID if found, null otherwise.
  Future<int?> _findExistingComment({
    required String owner,
    required String repo,
    required int issueNumber,
    required String marker,
    required String token,
  }) async {
    try {
      final responseBody = await _client.listIssueComments(
        owner: owner,
        repo: repo,
        issueNumber: issueNumber,
        token: token,
      );

      final comments = jsonDecode(responseBody) as List<dynamic>;
      final markerPattern = RegExp(r'<!--\s*([^\s<>]+?)\s*-->');

      for (final comment in comments) {
        final commentMap = comment as Map<String, dynamic>;
        final commentBody = commentMap['body'] as String? ?? '';
        final match = markerPattern.firstMatch(commentBody);
        if (match != null && match.group(1) == marker) {
          final commentId = commentMap['id'] as int;
          return commentId;
        }
      }

      return null;
    } catch (e) {
      _logger?.warn('Failed to list GitHub comments: $e');
      return null;
    }
  }
}

