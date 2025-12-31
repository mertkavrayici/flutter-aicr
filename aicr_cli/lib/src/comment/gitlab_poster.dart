import 'dart:convert';
import 'dart:io';

import '../util/aicr_logger.dart';
import 'comment_poster.dart';

/// HTTP transport function for testing.
typedef GitLabTransport = Future<GitLabTransportResponse> Function({
  required Uri uri,
  required Map<String, String> headers,
  required String? body,
  required String method,
});

final class GitLabTransportResponse {
  final int statusCode;
  final String body;

  const GitLabTransportResponse({
    required this.statusCode,
    required this.body,
  });
}

/// Marker pattern for idempotency.
/// Format: <!-- AICR_MARKER: <diff_hash> -->
/// Matches hash like "sha256:abc123" or just "abc123"
final RegExp _markerPattern = RegExp(r'<!--\s*AICR_MARKER:\s*([^\s<>]+?)\s*-->');

/// Posts comments to GitLab MRs.
///
/// Implements idempotency by:
/// 1. Searching for existing notes with the diff hash marker
/// 2. Updating the note if found
/// 3. Creating a new note if not found
final class GitLabPoster implements CommentPoster {
  final GitLabTransport _transport;
  final String baseUrl;

  GitLabPoster({
    GitLabTransport? transport,
    String? baseUrl,
  })  : _transport = transport ?? _defaultTransport,
        baseUrl = baseUrl ?? 'https://gitlab.com/api/v4';

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
        'PRIVATE-TOKEN': token,
        'Content-Type': 'application/json',
      };

      // GitLab uses project ID (encoded repo path)
      final projectId = Uri.encodeComponent('${repo.owner}/${repo.name}');

      // 1. List existing notes to find one with matching marker
      final existingNoteId = await _findExistingNote(
        projectId: projectId,
        mrIid: prOrMrNumber,
        diffHash: diffHash,
        token: token,
        headers: headers,
        logger: logger,
      );

      if (existingNoteId != null) {
        // 2. Update existing note
        return await _updateNote(
          projectId: projectId,
          mrIid: prOrMrNumber,
          noteId: existingNoteId,
          body: bodyWithMarker,
          headers: headers,
          logger: logger,
        );
      } else {
        // 3. Create new note
        return await _createNote(
          projectId: projectId,
          mrIid: prOrMrNumber,
          body: bodyWithMarker,
          headers: headers,
          logger: logger,
        );
      }
    } catch (e) {
      final error = 'Failed to post GitLab comment: $e';
      logger?.warn(error);
      return CommentPostFailure(error: error);
    }
  }

  Future<int?> _findExistingNote({
    required String projectId,
    required int mrIid,
    required String diffHash,
    required String token,
    required Map<String, String> headers,
    AicrLogger? logger,
  }) async {
    final uri = Uri.parse(
      '$baseUrl/projects/$projectId/merge_requests/$mrIid/notes',
    );

    final response = await _transport(
      uri: uri,
      headers: headers,
      body: null,
      method: 'GET',
    );

    if (response.statusCode != 200) {
      logger?.warn('Failed to list GitLab notes: HTTP ${response.statusCode}');
      return null;
    }

    final notes = jsonDecode(response.body) as List<dynamic>;
    for (final note in notes) {
      final noteMap = note as Map<String, dynamic>;
      final noteBody = noteMap['body'] as String? ?? '';
      final match = _markerPattern.firstMatch(noteBody);
      if (match != null && match.group(1) == diffHash) {
        final noteId = noteMap['id'] as int;
        logger?.info('Found existing note with marker (id: $noteId)');
        return noteId;
      }
    }

    return null;
  }

  Future<CommentPostResult> _createNote({
    required String projectId,
    required int mrIid,
    required String body,
    required Map<String, String> headers,
    AicrLogger? logger,
  }) async {
    final uri = Uri.parse(
      '$baseUrl/projects/$projectId/merge_requests/$mrIid/notes',
    );

    final payload = jsonEncode({'body': body});

    final response = await _transport(
      uri: uri,
      headers: headers,
      body: payload,
      method: 'POST',
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      logger?.info('Created new GitLab note');
      return const CommentPostSuccess(wasUpdated: false);
    } else {
      final error =
          'Failed to create GitLab note: HTTP ${response.statusCode} - ${response.body}';
      logger?.warn(error);
      return CommentPostFailure(error: error);
    }
  }

  Future<CommentPostResult> _updateNote({
    required String projectId,
    required int mrIid,
    required int noteId,
    required String body,
    required Map<String, String> headers,
    AicrLogger? logger,
  }) async {
    final uri = Uri.parse(
      '$baseUrl/projects/$projectId/merge_requests/$mrIid/notes/$noteId',
    );

    final payload = jsonEncode({'body': body});

    final response = await _transport(
      uri: uri,
      headers: headers,
      body: payload,
      method: 'PUT',
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      logger?.info('Updated existing GitLab note (id: $noteId)');
      return const CommentPostSuccess(wasUpdated: true);
    } else {
      final error =
          'Failed to update GitLab note: HTTP ${response.statusCode} - ${response.body}';
      logger?.warn(error);
      return CommentPostFailure(error: error);
    }
  }

  String _addMarker(String body, String diffHash) {
    return '$body\n\n<!-- AICR_MARKER: $diffHash -->';
  }

  static Future<GitLabTransportResponse> _defaultTransport({
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

      return GitLabTransportResponse(
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

