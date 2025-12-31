import 'dart:convert';
import 'dart:io';

/// HTTP client for GitHub API calls.
///
/// Provides methods for:
/// - Listing PR issue comments
/// - Creating comments
/// - Updating comments
class GitHubApiClient {
  final HttpClient? _client;
  static const String _baseUrl = 'https://api.github.com';

  /// Creates a GitHubApiClient with optional HTTP client for testing.
  GitHubApiClient({HttpClient? client}) : _client = client;

  /// Lists all comments on an issue/PR.
  ///
  /// Returns the response body as JSON-encoded string.
  /// Throws on network errors or non-2xx status codes.
  Future<String> listIssueComments({
    required String owner,
    required String repo,
    required int issueNumber,
    required String token,
  }) async {
    final uri = Uri.parse(
      '$_baseUrl/repos/$owner/$repo/issues/$issueNumber/comments',
    );
    return _request(
      uri: uri,
      method: 'GET',
      token: token,
    );
  }

  /// Creates a new comment on an issue/PR.
  ///
  /// Returns the response body as JSON-encoded string.
  /// Throws on network errors or non-2xx status codes.
  Future<String> createComment({
    required String owner,
    required String repo,
    required int issueNumber,
    required String body,
    required String token,
  }) async {
    final uri = Uri.parse(
      '$_baseUrl/repos/$owner/$repo/issues/$issueNumber/comments',
    );
    final payload = jsonEncode({'body': body});
    return _request(
      uri: uri,
      method: 'POST',
      token: token,
      body: payload,
    );
  }

  /// Updates an existing comment.
  ///
  /// Returns the response body as JSON-encoded string.
  /// Throws on network errors or non-2xx status codes.
  Future<String> updateComment({
    required String owner,
    required String repo,
    required int commentId,
    required String body,
    required String token,
  }) async {
    final uri = Uri.parse(
      '$_baseUrl/repos/$owner/$repo/issues/comments/$commentId',
    );
    final payload = jsonEncode({'body': body});
    return _request(
      uri: uri,
      method: 'PATCH',
      token: token,
      body: payload,
    );
  }

  Future<String> _request({
    required Uri uri,
    required String method,
    required String token,
    String? body,
  }) async {
    final client = _client ?? HttpClient();
    final shouldCloseClient = _client == null;

    try {
      final request = await _createRequest(client, uri, method).timeout(
        const Duration(seconds: 30),
      );
      request.headers.set('Authorization', 'Bearer $token');
      request.headers.set('Accept', 'application/vnd.github+json');
      request.headers.set('Content-Type', 'application/json');
      request.headers.set('User-Agent', 'AICR/1.0');
      request.headers.set('X-GitHub-Api-Version', '2022-11-28');

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

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw HttpException(
          'HTTP ${response.statusCode}: $responseBody',
          uri: uri,
        );
      }

      return responseBody;
    } finally {
      if (shouldCloseClient) {
        client.close(force: true);
      }
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
      default:
        throw ArgumentError('Unsupported HTTP method: $method');
    }
  }
}

