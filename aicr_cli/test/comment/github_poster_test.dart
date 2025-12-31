import 'dart:convert';

import 'package:test/test.dart';

import 'package:aicr_cli/src/comment/comment.dart';
import 'package:aicr_cli/src/util/aicr_logger.dart';

void main() {
  group('GitHubPoster', () {
    test('creates new comment when no existing comment with marker', () async {
      final calls = <String>[];
      final transport = _mockTransport(
        responses: [
          // List comments - empty
          GitHubTransportResponse(
            statusCode: 200,
            body: jsonEncode([]),
          ),
          // Create comment
          GitHubTransportResponse(
            statusCode: 201,
            body: jsonEncode({'id': 123}),
          ),
        ],
        onCall: (uri, method, body) {
          calls.add('$method $uri');
          if (body != null) {
            calls.add('body: $body');
          }
        },
      );

      final poster = GitHubPoster(transport: transport);
      final repo = RepoInfo(owner: 'test-owner', name: 'test-repo');
      final logger = _TestLogger();

      final result = await poster.post(
        repo: repo,
        prOrMrNumber: 42,
        body: 'Test comment',
        diffHash: 'sha256:abc123',
        token: 'test-token',
        logger: logger,
      );

      expect(result, isA<CommentPostSuccess>());
      final success = result as CommentPostSuccess;
      expect(success.wasUpdated, false);

      // Verify correct endpoints called
      expect(
        calls[0],
        contains('/repos/test-owner/test-repo/issues/42/comments'),
      );
      expect(calls[0], contains('GET'));

      expect(
        calls[1],
        contains('/repos/test-owner/test-repo/issues/42/comments'),
      );
      expect(calls[1], contains('POST'));

      // Verify payload contains marker
      final createCallIndex = calls.indexWhere((c) => c.contains('POST'));
      expect(createCallIndex, greaterThan(-1));
      final bodyCall = calls[createCallIndex + 1];
      expect(bodyCall, contains('Test comment'));
      expect(bodyCall, contains('<!-- AICR_MARKER: sha256:abc123 -->'));

      // Verify no warnings (info messages are expected)
      expect(logger.warnings, isEmpty);
    });

    test('updates existing comment when marker found', () async {
      final calls = <String>[];
      final transport = _mockTransport(
        responses: [
          // List comments - one with matching marker
          GitHubTransportResponse(
            statusCode: 200,
            body: jsonEncode([
              {
                'id': 456,
                'body':
                    'Old comment\n\n<!-- AICR_MARKER: sha256:abc123 -->',
              },
            ]),
          ),
          // Update comment
          GitHubTransportResponse(
            statusCode: 200,
            body: jsonEncode({'id': 456}),
          ),
        ],
        onCall: (uri, method, body) {
          calls.add('$method $uri');
        },
      );

      final poster = GitHubPoster(transport: transport);
      final repo = RepoInfo(owner: 'test-owner', name: 'test-repo');
      final logger = _TestLogger();

      final result = await poster.post(
        repo: repo,
        prOrMrNumber: 42,
        body: 'New comment',
        diffHash: 'sha256:abc123',
        token: 'test-token',
        logger: logger,
      );

      expect(result, isA<CommentPostSuccess>());
      final success = result as CommentPostSuccess;
      expect(success.wasUpdated, true);

      // Verify GET for list, then PATCH for update
      expect(calls.length, 2);
      expect(calls[0], contains('GET'));
      expect(calls[1], contains('PATCH'));
      expect(calls[1], contains('/issues/comments/456'));
    });

    test('does not update comment with different marker', () async {
      final transport = _mockTransport(
        responses: [
          // List comments - one with different marker
          GitHubTransportResponse(
            statusCode: 200,
            body: jsonEncode([
              {
                'id': 789,
                'body':
                    'Old comment\n\n<!-- AICR_MARKER: sha256:different -->',
              },
            ]),
          ),
          // Create new comment
          GitHubTransportResponse(
            statusCode: 201,
            body: jsonEncode({'id': 999}),
          ),
        ],
      );

      final poster = GitHubPoster(transport: transport);
      final repo = RepoInfo(owner: 'test-owner', name: 'test-repo');

      final result = await poster.post(
        repo: repo,
        prOrMrNumber: 42,
        body: 'New comment',
        diffHash: 'sha256:abc123',
        token: 'test-token',
      );

      expect(result, isA<CommentPostSuccess>());
      final success = result as CommentPostSuccess;
      expect(success.wasUpdated, false);
    });

    test('handles API errors gracefully', () async {
      final transport = _mockTransport(
        responses: [
          // List comments fails
          GitHubTransportResponse(
            statusCode: 500,
            body: 'Internal Server Error',
          ),
        ],
      );

      final poster = GitHubPoster(transport: transport);
      final repo = RepoInfo(owner: 'test-owner', name: 'test-repo');
      final logger = _TestLogger();

      final result = await poster.post(
        repo: repo,
        prOrMrNumber: 42,
        body: 'Test comment',
        diffHash: 'sha256:abc123',
        token: 'test-token',
        logger: logger,
      );

      expect(result, isA<CommentPostFailure>());
      expect(logger.warnings.length, greaterThan(0));
    });

    test('handles create comment API error', () async {
      final transport = _mockTransport(
        responses: [
          // List comments - empty
          GitHubTransportResponse(
            statusCode: 200,
            body: jsonEncode([]),
          ),
          // Create comment fails
          GitHubTransportResponse(
            statusCode: 403,
            body: 'Forbidden',
          ),
        ],
      );

      final poster = GitHubPoster(transport: transport);
      final repo = RepoInfo(owner: 'test-owner', name: 'test-repo');
      final logger = _TestLogger();

      final result = await poster.post(
        repo: repo,
        prOrMrNumber: 42,
        body: 'Test comment',
        diffHash: 'sha256:abc123',
        token: 'test-token',
        logger: logger,
      );

      expect(result, isA<CommentPostFailure>());
      final failure = result as CommentPostFailure;
      expect(failure.error, contains('403'));
    });

    test('handles exceptions gracefully', () async {
      final transport = ({
        required uri,
        required headers,
        required body,
        required method,
      }) async {
        throw Exception('Network error');
      };

      final poster = GitHubPoster(transport: transport);
      final repo = RepoInfo(owner: 'test-owner', name: 'test-repo');
      final logger = _TestLogger();

      final result = await poster.post(
        repo: repo,
        prOrMrNumber: 42,
        body: 'Test comment',
        diffHash: 'sha256:abc123',
        token: 'test-token',
        logger: logger,
      );

      expect(result, isA<CommentPostFailure>());
      expect(logger.warnings.length, greaterThan(0));
      expect(logger.warnings.first, contains('Failed to post GitHub comment'));
    });

    test('uses correct Authorization header', () async {
      String? authHeader;
      final transport = _mockTransport(
        responses: [
          GitHubTransportResponse(statusCode: 200, body: jsonEncode([])),
          GitHubTransportResponse(statusCode: 201, body: jsonEncode({'id': 1})),
        ],
        onCall: (uri, method, body) {},
        onHeaders: (headers) {
          authHeader = headers['Authorization'];
        },
      );

      final poster = GitHubPoster(transport: transport);
      final repo = RepoInfo(owner: 'test-owner', name: 'test-repo');

      await poster.post(
        repo: repo,
        prOrMrNumber: 42,
        body: 'Test',
        diffHash: 'sha256:abc',
        token: 'my-token-123',
      );

      expect(authHeader, equals('Bearer my-token-123'));
    });
  });
}

GitHubTransport _mockTransport({
  required List<GitHubTransportResponse> responses,
  void Function(Uri uri, String method, String? body)? onCall,
  void Function(Map<String, String> headers)? onHeaders,
}) {
  var callIndex = 0;
  return ({
    required Uri uri,
    required Map<String, String> headers,
    required String? body,
    required String method,
  }) async {
    if (onHeaders != null) {
      onHeaders(headers);
    }
    if (onCall != null) {
      onCall(uri, method, body);
    }
    if (callIndex >= responses.length) {
      throw StateError('Unexpected call: $method $uri');
    }
    return responses[callIndex++];
  };
}

final class _TestLogger implements AicrLogger {
  final List<String> warnings = [];
  final List<String> infos = [];

  @override
  bool get verbose => true;

  @override
  void warn(String message) {
    warnings.add(message);
  }

  @override
  void info(String message) {
    infos.add(message);
  }

  @override
  void debug(String message) {
    // Not used in tests
  }

  List<String> get messages => [...warnings, ...infos];
}

