import 'dart:convert';
import 'dart:io';

import '../util/aicr_logger.dart';
import 'github_api_client.dart';

/// Posts PR comments to GitHub using environment variables.
///
/// Reads from:
/// - GITHUB_TOKEN or GH_TOKEN: authentication token
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
  }) : _client = client ?? GitHubApiClient(),
       _logger = logger,
       _token = token,
       _repository = repository,
       _eventPath = eventPath;

  String? _env(String key) => Platform.environment[key];

  bool _envTrue(String key) {
    final v = (_env(key) ?? '').toLowerCase().trim();
    return v == 'true' || v == '1' || v == 'yes';
  }

  Never _failCi(String message) {
    // If CI is configured to post a comment, failing silently is worse than failing loudly.
    throw StateError(message);
  }

  /// Posts a comment to the current PR.
  ///
  /// Returns true on success, false on failure or missing env vars.
  /// If AICR_POST_COMMENT=true, failures become fatal (throws) so CI is not green when no comment is posted.
  Future<bool> post({
    required String bodyMarkdown,
    required String marker,
    required String commentMode, // 'update' | 'always_new'
  }) async {
    final shouldPost = _envTrue('AICR_POST_COMMENT');

    // Read environment variables (use provided values or fallback to env vars)
    final token = _token ?? _env('GITHUB_TOKEN') ?? _env('GH_TOKEN');
    final repository = _repository ?? _env('GITHUB_REPOSITORY');
    final eventPath = _eventPath ?? _env('GITHUB_EVENT_PATH');

    // Validate required env vars
    if (token == null || token.isEmpty) {
      final msg =
          'GitHub PR comment failed: token missing (GITHUB_TOKEN / GH_TOKEN not set).';
      _logger?.warn(msg);
      if (shouldPost) _failCi(msg);
      return false;
    }

    if (repository == null || repository.isEmpty) {
      final msg = 'GitHub PR comment failed: GITHUB_REPOSITORY not set.';
      _logger?.warn(msg);
      if (shouldPost) _failCi(msg);
      return false;
    }

    if (eventPath == null || eventPath.isEmpty) {
      final msg = 'GitHub PR comment failed: GITHUB_EVENT_PATH not set.';
      _logger?.warn(msg);
      if (shouldPost) _failCi(msg);
      return false;
    }

    // Parse repository (owner/repo)
    final repoParts = repository.split('/');
    if (repoParts.length != 2) {
      final msg =
          'GitHub PR comment failed: invalid GITHUB_REPOSITORY="$repository" (expected owner/repo).';
      _logger?.warn(msg);
      if (shouldPost) _failCi(msg);
      return false;
    }
    final owner = repoParts[0];
    final repo = repoParts[1];

    // Read PR number from GITHUB_EVENT_PATH
    final prNumber = _readPrNumber(
      eventPath: eventPath,
      shouldPost: shouldPost,
    );
    if (prNumber == null) return false;

    // Append hidden marker (idempotency)
    final bodyWithMarker = '$bodyMarkdown\n\n<!-- $marker -->';

    try {
      if (commentMode == 'always_new') {
        await _client.createComment(
          owner: owner,
          repo: repo,
          issueNumber: prNumber,
          body: bodyWithMarker,
          token: token,
        );
        _logger?.info('Created new GitHub PR comment (mode: always_new)');
        return true;
      }

      // Default: update mode - find existing comment with marker
      final existingCommentId = await _findExistingComment(
        owner: owner,
        repo: repo,
        issueNumber: prNumber,
        marker: marker,
        token: token,
      );

      if (existingCommentId != null) {
        await _client.updateComment(
          owner: owner,
          repo: repo,
          commentId: existingCommentId,
          body: bodyWithMarker,
          token: token,
        );
        _logger?.info(
          'Updated existing GitHub PR comment (id: $existingCommentId)',
        );
        return true;
      }

      await _client.createComment(
        owner: owner,
        repo: repo,
        issueNumber: prNumber,
        body: bodyWithMarker,
        token: token,
      );
      _logger?.info('Created new GitHub PR comment (mode: update)');
      return true;
    } catch (e) {
      final msg =
          'GitHub PR comment failed while calling GitHub API (owner=$owner repo=$repo pr=$prNumber): $e';
      _logger?.warn(msg);
      if (shouldPost) _failCi(msg);
      return false;
    }
  }

  int? _readPrNumber({required String eventPath, required bool shouldPost}) {
    try {
      final eventFile = File(eventPath);
      if (!eventFile.existsSync()) {
        final msg =
            'GitHub PR comment failed: GITHUB_EVENT_PATH not found: $eventPath';
        _logger?.warn(msg);
        if (shouldPost) _failCi(msg);
        return null;
      }

      final raw = eventFile.readAsStringSync();
      final eventJson = jsonDecode(raw) as Map<String, dynamic>;

      final pullRequest = eventJson['pull_request'] as Map<String, dynamic>?;
      if (pullRequest == null) {
        final msg =
            'GitHub PR comment failed: pull_request not found in GITHUB_EVENT_PATH.';
        _logger?.warn(msg);
        if (shouldPost) _failCi(msg);
        return null;
      }

      final prNumber = pullRequest['number'] as int?;
      if (prNumber == null) {
        final msg =
            'GitHub PR comment failed: pull_request.number not found in GITHUB_EVENT_PATH.';
        _logger?.warn(msg);
        if (shouldPost) _failCi(msg);
        return null;
      }

      return prNumber;
    } catch (e) {
      final msg =
          'GitHub PR comment failed: could not read/parse GITHUB_EVENT_PATH ($eventPath): $e';
      _logger?.warn(msg);
      if (shouldPost) _failCi(msg);
      return null;
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

      // Match hidden markers like: <!-- AICR_COMMENT -->
      final markerPattern = RegExp(r'<!--\s*([^\s<>]+?)\s*-->');

      for (final comment in comments) {
        final commentMap = comment as Map<String, dynamic>;
        final commentBody = commentMap['body'] as String? ?? '';

        // IMPORTANT: search all markers, not just first
        for (final m in markerPattern.allMatches(commentBody)) {
          final found = m.group(1);
          if (found == marker) {
            final commentId = commentMap['id'] as int;
            return commentId;
          }
        }
      }

      return null;
    } catch (e) {
      _logger?.warn('Failed to list GitHub comments: $e');
      return null;
    }
  }
}
