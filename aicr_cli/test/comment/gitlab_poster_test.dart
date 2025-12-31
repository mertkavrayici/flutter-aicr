import 'dart:convert';

import 'package:test/test.dart';

import 'package:aicr_cli/src/comment/comment.dart';
import 'package:aicr_cli/src/util/aicr_logger.dart';

void main() {
  group('GitLabPoster', () {
    test('creates new note when no existing note with marker', () async {
      final calls = <String>[];
      final transport = _mockTransport(
        responses: [
          // List notes - empty
          GitLabTransportResponse(
            statusCode: 200,
            body: jsonEncode([]),
          ),
          // Create note
          GitLabTransportResponse(
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

      final poster = GitLabPoster(transport: transport);
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

      // Verify correct endpoints called (project ID is URL encoded)
      expect(calls[0], contains('/projects/'));
      expect(calls[0], contains('/merge_requests/42/notes'));
      expect(calls[0], contains('GET'));

      expect(calls[1], contains('/projects/'));
      expect(calls[1], contains('/merge_requests/42/notes'));
      expect(calls[1], contains('POST'));

      // Verify payload contains marker
      final createCallIndex = calls.indexWhere((c) => c.contains('POST'));
      expect(createCallIndex, greaterThan(-1));
      final bodyCall = calls[createCallIndex + 1];
      expect(bodyCall, contains('Test comment'));
      expect(bodyCall, contains('<!-- AICR_MARKER: sha256:abc123 -->'));

      expect(logger.warnings, isEmpty);
    });

    test('updates existing note when marker found', () async {
      final calls = <String>[];
      final transport = _mockTransport(
        responses: [
          // List notes - one with matching marker
          GitLabTransportResponse(
            statusCode: 200,
            body: jsonEncode([
              {
                'id': 456,
                'body':
                    'Old comment\n\n<!-- AICR_MARKER: sha256:abc123 -->',
              },
            ]),
          ),
          // Update note
          GitLabTransportResponse(
            statusCode: 200,
            body: jsonEncode({'id': 456}),
          ),
        ],
        onCall: (uri, method, body) {
          calls.add('$method $uri');
        },
      );

      final poster = GitLabPoster(transport: transport);
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

      // Verify GET for list, then PUT for update
      expect(calls.length, 2);
      expect(calls[0], contains('GET'));
      expect(calls[1], contains('PUT'));
      expect(calls[1], contains('/notes/456'));
    });

    test('does not update note with different marker', () async {
      final transport = _mockTransport(
        responses: [
          // List notes - one with different marker
          GitLabTransportResponse(
            statusCode: 200,
            body: jsonEncode([
              {
                'id': 789,
                'body':
                    'Old comment\n\n<!-- AICR_MARKER: sha256:different -->',
              },
            ]),
          ),
          // Create new note
          GitLabTransportResponse(
            statusCode: 201,
            body: jsonEncode({'id': 999}),
          ),
        ],
      );

      final poster = GitLabPoster(transport: transport);
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
          // List notes fails
          GitLabTransportResponse(
            statusCode: 500,
            body: 'Internal Server Error',
          ),
        ],
      );

      final poster = GitLabPoster(transport: transport);
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

    test('handles create note API error', () async {
      final transport = _mockTransport(
        responses: [
          // List notes - empty
          GitLabTransportResponse(
            statusCode: 200,
            body: jsonEncode([]),
          ),
          // Create note fails
          GitLabTransportResponse(
            statusCode: 403,
            body: 'Forbidden',
          ),
        ],
      );

      final poster = GitLabPoster(transport: transport);
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

      final poster = GitLabPoster(transport: transport);
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
      expect(logger.warnings.first, contains('Failed to post GitLab comment'));
    });

    test('uses correct PRIVATE-TOKEN header', () async {
      String? tokenHeader;
      final transport = _mockTransport(
        responses: [
          GitLabTransportResponse(statusCode: 200, body: jsonEncode([])),
          GitLabTransportResponse(statusCode: 201, body: jsonEncode({'id': 1})),
        ],
        onCall: (uri, method, body) {},
        onHeaders: (headers) {
          tokenHeader = headers['PRIVATE-TOKEN'];
        },
      );

      final poster = GitLabPoster(transport: transport);
      final repo = RepoInfo(owner: 'test-owner', name: 'test-repo');

      await poster.post(
        repo: repo,
        prOrMrNumber: 42,
        body: 'Test',
        diffHash: 'sha256:abc',
        token: 'my-token-123',
      );

      expect(tokenHeader, equals('my-token-123'));
    });

    test('URL encodes project ID correctly', () async {
      Uri? listUri;
      final transport = _mockTransport(
        responses: [
          GitLabTransportResponse(statusCode: 200, body: jsonEncode([])),
          GitLabTransportResponse(statusCode: 201, body: jsonEncode({'id': 1})),
        ],
        onCall: (uri, method, body) {
          if (method == 'GET') {
            listUri = uri;
          }
        },
      );

      final poster = GitLabPoster(transport: transport);
      final repo = RepoInfo(owner: 'test-owner', name: 'test-repo');

      await poster.post(
        repo: repo,
        prOrMrNumber: 42,
        body: 'Test',
        diffHash: 'sha256:abc',
        token: 'token',
      );

      expect(listUri, isNotNull);
      expect(listUri!.path, contains('test-owner%2Ftest-repo'));
    });

    test('supports custom base URL', () async {
      Uri? listUri;
      final transport = _mockTransport(
        responses: [
          GitLabTransportResponse(statusCode: 200, body: jsonEncode([])),
          GitLabTransportResponse(statusCode: 201, body: jsonEncode({'id': 1})),
        ],
        onCall: (uri, method, body) {
          if (method == 'GET') {
            listUri = uri;
          }
        },
      );

      final poster = GitLabPoster(
        transport: transport,
        baseUrl: 'https://custom-gitlab.example.com/api/v4',
      );
      final repo = RepoInfo(owner: 'test-owner', name: 'test-repo');

      await poster.post(
        repo: repo,
        prOrMrNumber: 42,
        body: 'Test',
        diffHash: 'sha256:abc',
        token: 'token',
      );

      expect(listUri, isNotNull);
      expect(listUri!.origin, equals('https://custom-gitlab.example.com'));
    });
  });
}

GitLabTransport _mockTransport({
  required List<GitLabTransportResponse> responses,
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

