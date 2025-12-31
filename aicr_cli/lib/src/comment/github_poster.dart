import 'dart:convert';
import 'dart:io';

import '../util/aicr_logger.dart';
import 'comment_poster.dart';

/// HTTP transport function for testing.
typedef GitHubTransport =
    Future<GitHubTransportResponse> Function({
      required Uri uri,
      required Map<String, String> headers,
      required String? body,
      required String method,
    });

final class GitHubTransportResponse {
  final int statusCode;
  final String body;

  const GitHubTransportResponse({required this.statusCode, required this.body});
}

/// Marker pattern for idempotency.
/// Format: <!-- AICR_MARKER: <diff_hash> -->
final RegExp _markerPattern = RegExp(
  r'<!--\s*AICR_MARKER:\s*([^\s<>]+?)\s*-->',
);

/// Posts comments to GitHub PRs using Issue Comments API.
///
/// Idempotency:
/// 1) List existing comments on the PR (issue)
/// 2) Find a comment containing the marker for this diff hash
/// 3) Update if found, create otherwise
final class GitHubPoster implements CommentPoster {
  static const String _baseUrl = 'https://api.github.com';

  final GitHubTransport _transport;

  GitHubPoster({GitHubTransport? transport})
    : _transport = transport ?? _defaultTransport;

  @override
  Future<CommentPostResult> post({
    required RepoInfo repo,
    required int prOrMrNumber,
    required String body,
    required String diffHash,
    required String token,
    AicrLogger? logger,
  }) async {
    try {
      final bodyWithMarker = _addMarker(body, diffHash);
      final headers = _buildHeaders(token);

      final existingCommentId = await _findExistingComment(
        repo: repo,
        prOrMrNumber: prOrMrNumber,
        diffHash: diffHash,
        headers: headers,
        logger: logger,
      );

      if (existingCommentId != null) {
        return _updateComment(
          repo: repo,
          commentId: existingCommentId,
          body: bodyWithMarker,
          headers: headers,
          logger: logger,
        );
      }

      return _createComment(
        repo: repo,
        prOrMrNumber: prOrMrNumber,
        body: bodyWithMarker,
        headers: headers,
        logger: logger,
      );
    } catch (e) {
      final error = 'Failed to post GitHub comment: $e';
      logger?.warn(error);
      return CommentPostFailure(error: error);
    }
  }

  Map<String, String> _buildHeaders(String token) => {
    // GitHub prefers Bearer for fine-grained tokens and GITHUB_TOKEN
    'Authorization': 'Bearer $token',
    'Accept': 'application/vnd.github+json',
    'User-Agent': 'AICR/1.0',
    'X-GitHub-Api-Version': '2022-11-28',
  };

  Uri _issueCommentsUri({required RepoInfo repo, required int prOrMrNumber}) {
    return Uri.parse(
      '$_baseUrl/repos/${repo.owner}/${repo.name}/issues/$prOrMrNumber/comments',
    );
  }

  Uri _singleCommentUri({required RepoInfo repo, required int commentId}) {
    return Uri.parse(
      '$_baseUrl/repos/${repo.owner}/${repo.name}/issues/comments/$commentId',
    );
  }

  Future<int?> _findExistingComment({
    required RepoInfo repo,
    required int prOrMrNumber,
    required String diffHash,
    required Map<String, String> headers,
    AicrLogger? logger,
  }) async {
    final uri = _issueCommentsUri(repo: repo, prOrMrNumber: prOrMrNumber);

    final response = await _transport(
      uri: uri,
      headers: headers,
      body: null,
      method: 'GET',
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      logger?.warn(
        'Failed to list GitHub comments: HTTP ${response.statusCode} - ${response.body}',
      );
      return null;
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! List) {
      logger?.warn(
        'Failed to list GitHub comments: unexpected JSON type (${decoded.runtimeType})',
      );
      return null;
    }

    for (final item in decoded) {
      if (item is! Map<String, dynamic>) continue;

      final commentBody = (item['body'] as String?) ?? '';
      final commentId = item['id'];

      if (commentId is! int) continue;

      // IMPORTANT: Look through all markers in the comment, not just the first.
      for (final m in _markerPattern.allMatches(commentBody)) {
        final foundHash = m.group(1);
        if (foundHash == diffHash) {
          logger?.info('Found existing comment with marker (id: $commentId)');
          return commentId;
        }
      }
    }

    return null;
  }

  Future<CommentPostResult> _createComment({
    required RepoInfo repo,
    required int prOrMrNumber,
    required String body,
    required Map<String, String> headers,
    AicrLogger? logger,
  }) async {
    final uri = _issueCommentsUri(repo: repo, prOrMrNumber: prOrMrNumber);

    final payload = jsonEncode({'body': body});
    final response = await _transport(
      uri: uri,
      headers: {...headers, 'Content-Type': 'application/json; charset=utf-8'},
      body: payload,
      method: 'POST',
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      logger?.info('Created new GitHub comment');
      return const CommentPostSuccess(wasUpdated: false);
    }

    final error =
        'Failed to create GitHub comment: HTTP ${response.statusCode} - ${response.body}';
    logger?.warn(error);
    return CommentPostFailure(error: error);
  }

  Future<CommentPostResult> _updateComment({
    required RepoInfo repo,
    required int commentId,
    required String body,
    required Map<String, String> headers,
    AicrLogger? logger,
  }) async {
    final uri = _singleCommentUri(repo: repo, commentId: commentId);

    final payload = jsonEncode({'body': body});
    final response = await _transport(
      uri: uri,
      headers: {...headers, 'Content-Type': 'application/json; charset=utf-8'},
      body: payload,
      method: 'PATCH',
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      logger?.info('Updated existing GitHub comment (id: $commentId)');
      return const CommentPostSuccess(wasUpdated: true);
    }

    final error =
        'Failed to update GitHub comment: HTTP ${response.statusCode} - ${response.body}';
    logger?.warn(error);
    return CommentPostFailure(error: error);
  }

  String _addMarker(String body, String diffHash) {
    // Keep the marker on its own line so it's easy to search and stable across edits.
    return '$body\n\n<!-- AICR_MARKER: $diffHash -->';
  }

  static Future<GitHubTransportResponse> _defaultTransport({
    required Uri uri,
    required Map<String, String> headers,
    required String? body,
    required String method,
  }) async {
    final client = HttpClient();
    try {
      final request = await _createRequest(
        client,
        uri,
        method,
      ).timeout(const Duration(seconds: 30));

      headers.forEach(request.headers.set);

      if (body != null) {
        request.write(body);
      }

      final response = await request.close().timeout(
        const Duration(seconds: 30),
      );

      final responseBody = await response
          .transform(utf8.decoder)
          .join()
          .timeout(const Duration(seconds: 30));

      return GitHubTransportResponse(
        statusCode: response.statusCode,
        body: responseBody,
      );
    } finally {
      client.close(force: true);
    }
  }

  static Future<HttpClientRequest> _createRequest(
    HttpClient client,
    Uri uri,
    String method,
  ) {
    switch (method.toUpperCase()) {
      case 'GET':
        return client.getUrl(uri);
      case 'POST':
        return client.postUrl(uri);
      case 'PATCH':
        return client.patchUrl(uri);
      case 'PUT':
        return client.putUrl(uri);
      default:
        throw ArgumentError('Unsupported HTTP method: $method');
    }
  }
}
