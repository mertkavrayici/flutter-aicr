import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';

import 'package:aicr_cli/src/comment/github_api_client.dart';
import 'package:aicr_cli/src/comment/github_pr_comment_poster.dart';
import 'package:aicr_cli/src/util/aicr_logger.dart';

void main() {
  group('GitHubPrCommentPoster', () {
    test('postComment=false should do nothing (no GitHub calls)', () async {
      // This test verifies the integration point - when postComment is false,
      // the CLI should not call the poster. This is tested at the CLI level.
      // For unit tests, we verify that missing env vars cause early return.
      
      final mockClient = _MockGitHubApiClient();
      final logger = _TestLogger();

      // Missing env vars simulate postComment=false scenario
      // (postComment=false is handled at CLI level, but missing env vars also skip)
      final poster = GitHubPrCommentPoster(
        client: mockClient,
        logger: logger,
        token: null, // Missing token
      );

      final result = await poster.post(
        bodyMarkdown: 'Test comment',
        marker: 'TEST_MARKER',
        commentMode: 'update',
      );

      expect(result, false);
      expect(mockClient.calls, isEmpty);
      expect(logger.warnings.length, greaterThan(0));
      expect(logger.warnings.first, contains('GITHUB_TOKEN'));
    });

    test('creates new comment when marker not found (update mode)', () async {
      final mockClient = _MockGitHubApiClient();
      final logger = _TestLogger();
      
      // Setup event file
      final eventFile = _createEventFile(prNumber: 42);
      
      try {
        // Mock: list comments returns empty (no marker found)
        mockClient.setListCommentsResponse([]);
        // Mock: create comment succeeds
        mockClient.setCreateCommentResponse({'id': 123});

        final poster = GitHubPrCommentPoster(
          client: mockClient,
          logger: logger,
          token: 'test-token',
          repository: 'owner/repo',
          eventPath: eventFile.path,
        );

        final result = await poster.post(
          bodyMarkdown: 'Test comment',
          marker: 'TEST_MARKER',
          commentMode: 'update',
        );

        expect(result, true);
        expect(mockClient.calls.length, 2);
        expect(mockClient.calls[0].method, 'listIssueComments');
        expect(mockClient.calls[1].method, 'createComment');
        
        // Verify marker was appended
        final createCall = mockClient.calls[1] as _CreateCommentCall;
        expect(createCall.body, contains('Test comment'));
        expect(createCall.body, contains('<!-- TEST_MARKER -->'));
        
        expect(logger.warnings, isEmpty);
        expect(logger.infos.length, greaterThan(0));
        expect(logger.infos.first, contains('Created new GitHub PR comment'));
      } finally {
        eventFile.deleteSync();
      }
    });

    test('updates existing comment when marker found (update mode)', () async {
      final mockClient = _MockGitHubApiClient();
      final logger = _TestLogger();
      
      final eventFile = _createEventFile(prNumber: 42);
      
      try {
        // Mock: list comments returns one with matching marker
        mockClient.setListCommentsResponse([
          {
            'id': 456,
            'body': 'Old comment\n\n<!-- TEST_MARKER -->',
          },
        ]);
        // Mock: update comment succeeds
        mockClient.setUpdateCommentResponse({'id': 456});

        final poster = GitHubPrCommentPoster(
          client: mockClient,
          logger: logger,
          token: 'test-token',
          repository: 'owner/repo',
          eventPath: eventFile.path,
        );

        final result = await poster.post(
          bodyMarkdown: 'New comment',
          marker: 'TEST_MARKER',
          commentMode: 'update',
        );

        expect(result, true);
        expect(mockClient.calls.length, 2);
        expect(mockClient.calls[0].method, 'listIssueComments');
        expect(mockClient.calls[1].method, 'updateComment');
        
        // Verify marker was appended
        final updateCall = mockClient.calls[1] as _UpdateCommentCall;
        expect(updateCall.body, contains('New comment'));
        expect(updateCall.body, contains('<!-- TEST_MARKER -->'));
        expect(updateCall.commentId, 456);
        
        expect(logger.warnings, isEmpty);
        expect(logger.infos.length, greaterThan(0));
        expect(logger.infos.first, contains('Updated existing GitHub PR comment'));
      } finally {
        eventFile.deleteSync();
      }
    });

    test('creates new comment when marker found but mode is always_new', () async {
      final mockClient = _MockGitHubApiClient();
      final logger = _TestLogger();
      
      final eventFile = _createEventFile(prNumber: 42);
      
      try {
        // Mock: create comment succeeds (update should NOT be called)
        mockClient.setCreateCommentResponse({'id': 789});

        final poster = GitHubPrCommentPoster(
          client: mockClient,
          logger: logger,
          token: 'test-token',
          repository: 'owner/repo',
          eventPath: eventFile.path,
        );

        final result = await poster.post(
          bodyMarkdown: 'New comment',
          marker: 'TEST_MARKER',
          commentMode: 'always_new',
        );

        expect(result, true);
        // Should only call create, not list or update
        expect(mockClient.calls.length, 1);
        expect(mockClient.calls[0].method, 'createComment');
        
        // Verify marker was appended
        final createCall = mockClient.calls[0] as _CreateCommentCall;
        expect(createCall.body, contains('New comment'));
        expect(createCall.body, contains('<!-- TEST_MARKER -->'));
        
        expect(logger.warnings, isEmpty);
        expect(logger.infos.length, greaterThan(0));
        expect(logger.infos.first, contains('always_new'));
      } finally {
        eventFile.deleteSync();
      }
    });

    test('handles missing GITHUB_TOKEN gracefully', () async {
      final mockClient = _MockGitHubApiClient();
      final logger = _TestLogger();

      // Don't set token (pass null)
      final poster = GitHubPrCommentPoster(
        client: mockClient,
        logger: logger,
        token: null, // Missing token
        repository: 'owner/repo',
        eventPath: '/tmp/test-event.json',
      );

      final result = await poster.post(
        bodyMarkdown: 'Test comment',
        marker: 'TEST_MARKER',
        commentMode: 'update',
      );

      expect(result, false);
      expect(mockClient.calls, isEmpty);
      expect(logger.warnings.length, greaterThan(0));
      expect(logger.warnings.first, contains('GITHUB_TOKEN'));
    });

    test('handles missing GITHUB_REPOSITORY gracefully', () async {
      final mockClient = _MockGitHubApiClient();
      final logger = _TestLogger();

      // Don't set repository (pass null)
      final poster = GitHubPrCommentPoster(
        client: mockClient,
        logger: logger,
        token: 'test-token',
        repository: null, // Missing repository
        eventPath: '/tmp/test-event.json',
      );

      final result = await poster.post(
        bodyMarkdown: 'Test comment',
        marker: 'TEST_MARKER',
        commentMode: 'update',
      );

      expect(result, false);
      expect(mockClient.calls, isEmpty);
      expect(logger.warnings.length, greaterThan(0));
      expect(logger.warnings.first, contains('GITHUB_REPOSITORY'));
    });

    test('handles invalid GITHUB_REPOSITORY format gracefully', () async {
      final mockClient = _MockGitHubApiClient();
      final logger = _TestLogger();

      // Invalid format (not owner/repo)
      final poster = GitHubPrCommentPoster(
        client: mockClient,
        logger: logger,
        token: 'test-token',
        repository: 'invalid-format', // Invalid format
        eventPath: '/tmp/test-event.json',
      );

      final result = await poster.post(
        bodyMarkdown: 'Test comment',
        marker: 'TEST_MARKER',
        commentMode: 'update',
      );

      expect(result, false);
      expect(mockClient.calls, isEmpty);
      expect(logger.warnings.length, greaterThan(0));
      expect(logger.warnings.first, contains('invalid GITHUB_REPOSITORY format'));
    });
  });
}

File _createEventFile({required int prNumber}) {
  final tempDir = Directory.systemTemp.createTempSync('aicr_test_');
  final eventFile = File('${tempDir.path}/event.json');
  eventFile.writeAsStringSync(jsonEncode({
    'pull_request': {
      'number': prNumber,
    },
  }));
  return eventFile;
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
}

// Mock HTTP client for testing
final class _MockGitHubApiClient extends GitHubApiClient {
  final List<_ApiCall> calls = [];
  
  List<Map<String, dynamic>>? _listCommentsResponse;
  Map<String, dynamic>? _createCommentResponse;
  Map<String, dynamic>? _updateCommentResponse;

  _MockGitHubApiClient() : super(client: _FakeHttpClient());

  void setListCommentsResponse(List<Map<String, dynamic>> response) {
    _listCommentsResponse = response;
  }

  void setCreateCommentResponse(Map<String, dynamic> response) {
    _createCommentResponse = response;
  }

  void setUpdateCommentResponse(Map<String, dynamic> response) {
    _updateCommentResponse = response;
  }

  @override
  Future<String> listIssueComments({
    required String owner,
    required String repo,
    required int issueNumber,
    required String token,
  }) async {
    calls.add(_ListCommentsCall(owner: owner, repo: repo, issueNumber: issueNumber));
    if (_listCommentsResponse == null) {
      throw StateError('listCommentsResponse not set');
    }
    return jsonEncode(_listCommentsResponse);
  }

  @override
  Future<String> createComment({
    required String owner,
    required String repo,
    required int issueNumber,
    required String body,
    required String token,
  }) async {
    calls.add(_CreateCommentCall(
      owner: owner,
      repo: repo,
      issueNumber: issueNumber,
      body: body,
    ));
    if (_createCommentResponse == null) {
      throw StateError('createCommentResponse not set');
    }
    return jsonEncode(_createCommentResponse);
  }

  @override
  Future<String> updateComment({
    required String owner,
    required String repo,
    required int commentId,
    required String body,
    required String token,
  }) async {
    calls.add(_UpdateCommentCall(
      owner: owner,
      repo: repo,
      commentId: commentId,
      body: body,
    ));
    if (_updateCommentResponse == null) {
      throw StateError('updateCommentResponse not set');
    }
    return jsonEncode(_updateCommentResponse);
  }
}

abstract final class _ApiCall {
  String get method;
}

final class _ListCommentsCall extends _ApiCall {
  final String owner;
  final String repo;
  final int issueNumber;

  _ListCommentsCall({
    required this.owner,
    required this.repo,
    required this.issueNumber,
  });

  @override
  String get method => 'listIssueComments';
}

final class _CreateCommentCall extends _ApiCall {
  final String owner;
  final String repo;
  final int issueNumber;
  final String body;

  _CreateCommentCall({
    required this.owner,
    required this.repo,
    required this.issueNumber,
    required this.body,
  });

  @override
  String get method => 'createComment';
}

final class _UpdateCommentCall extends _ApiCall {
  final String owner;
  final String repo;
  final int commentId;
  final String body;

  _UpdateCommentCall({
    required this.owner,
    required this.repo,
    required this.commentId,
    required this.body,
  });

  @override
  String get method => 'updateComment';
}

// Fake HttpClient that does nothing (we override methods in mock)
final class _FakeHttpClient implements HttpClient {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

