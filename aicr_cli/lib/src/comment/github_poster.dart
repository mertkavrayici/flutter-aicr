import 'dart:convert';
import 'dart:io';

import '../util/aicr_logger.dart';
import 'comment_poster.dart';

/// HTTP transport function for testing.
typedef GitHubTransport = Future<GitHubTransportResponse> Function({
  required Uri uri,
  required Map<String, String> headers,
  required String? body,
  required String method,
});

final class GitHubTransportResponse {
  final int statusCode;
  final String body;

  const GitHubTransportResponse({
    required this.statusCode,
    required this.body,
  });
}

/// Marker pattern for idempotency.
/// Format: <!-- AICR_MARKER: <diff_hash> -->
/// Matches hash like "sha256:abc123" or just "abc123"
final RegExp _markerPattern = RegExp(r'<!--\s*AICR_MARKER:\s*([^\s<>]+?)\s*-->');

/// Posts comments to GitHub PRs.
///
/// Implements idempotency by:
/// 1. Searching for existing comments with the diff hash marker
/// 2. Updating the comment if found
/// 3. Creating a new comment if not found
final class GitHubPoster implements CommentPoster {
  final GitHubTransport _transport;
  static const String _baseUrl = 'https://api.github.com';

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
      final headers = {
        'Authorization': 'Bearer $token',
        'Accept': 'application/vnd.github.v3+json',
        'Content-Type': 'application/json',
        'User-Agent': 'AICR/1.0',
      };

      // 1. List existing comments to find one with matching marker
      final existingCommentId = await _findExistingComment(
        repo: repo,
        prOrMrNumber: prOrMrNumber,
        diffHash: diffHash,
        token: token,
        headers: headers,
        logger: logger,
      );

      if (existingCommentId != null) {
        // 2. Update existing comment
        return await _updateComment(
          repo: repo,
          commentId: existingCommentId,
          body: bodyWithMarker,
          headers: headers,
          logger: logger,
        );
      } else {
        // 3. Create new comment
        return await _createComment(
          repo: repo,
          prOrMrNumber: prOrMrNumber,
          body: bodyWithMarker,
          headers: headers,
          logger: logger,
        );
      }
    } catch (e) {
      final error = 'Failed to post GitHub comment: $e';
      logger?.warn(error);
      return CommentPostFailure(error: error);
    }
  }

  Future<int?> _findExistingComment({
    required RepoInfo repo,
    required int prOrMrNumber,
    required String diffHash,
    required String token,
    required Map<String, String> headers,
    AicrLogger? logger,
  }) async {
    final uri = Uri.parse(
      '$_baseUrl/repos/${repo.owner}/${repo.name}/issues/$prOrMrNumber/comments',
    );

    final response = await _transport(
      uri: uri,
      headers: headers,
      body: null,
      method: 'GET',
    );

    if (response.statusCode != 200) {
      logger?.warn(
        'Failed to list GitHub comments: HTTP ${response.statusCode}',
      );
      return null;
    }

    final comments = jsonDecode(response.body) as List<dynamic>;
    for (final comment in comments) {
      final commentMap = comment as Map<String, dynamic>;
      final commentBody = commentMap['body'] as String? ?? '';
      final match = _markerPattern.firstMatch(commentBody);
      if (match != null && match.group(1) == diffHash) {
        final commentId = commentMap['id'] as int;
        logger?.info('Found existing comment with marker (id: $commentId)');
        return commentId;
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
    final uri = Uri.parse(
      '$_baseUrl/repos/${repo.owner}/${repo.name}/issues/$prOrMrNumber/comments',
    );

    final payload = jsonEncode({'body': body});

    final response = await _transport(
      uri: uri,
      headers: headers,
      body: payload,
      method: 'POST',
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      logger?.info('Created new GitHub comment');
      return const CommentPostSuccess(wasUpdated: false);
    } else {
      final error =
          'Failed to create GitHub comment: HTTP ${response.statusCode} - ${response.body}';
      logger?.warn(error);
      return CommentPostFailure(error: error);
    }
  }

  Future<CommentPostResult> _updateComment({
    required RepoInfo repo,
    required int commentId,
    required String body,
    required Map<String, String> headers,
    AicrLogger? logger,
  }) async {
    final uri = Uri.parse(
      '$_baseUrl/repos/${repo.owner}/${repo.name}/issues/comments/$commentId',
    );

    final payload = jsonEncode({'body': body});

    final response = await _transport(
      uri: uri,
      headers: headers,
      body: payload,
      method: 'PATCH',
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      logger?.info('Updated existing GitHub comment (id: $commentId)');
      return const CommentPostSuccess(wasUpdated: true);
    } else {
      final error =
          'Failed to update GitHub comment: HTTP ${response.statusCode} - ${response.body}';
      logger?.warn(error);
      return CommentPostFailure(error: error);
    }
  }

  String _addMarker(String body, String diffHash) {
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
      final request = await _createRequest(client, uri, method).timeout(
        const Duration(seconds: 30),
      );
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

