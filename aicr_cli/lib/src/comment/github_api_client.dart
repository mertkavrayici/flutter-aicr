import 'dart:convert';
import 'dart:io';

/// HTTP client for GitHub API calls.
///
/// Provides methods for:
/// - Listing PR issue comments
/// - Creating comments
/// - Updating comments
final class GitHubApiClient {
  final HttpClient? _client;
  static const String _baseUrl = 'https://api.github.com';

  GitHubApiClient({HttpClient? client}) : _client = client;

  Future<String> listIssueComments({
    required String owner,
    required String repo,
    required int issueNumber,
    required String token,
  }) async {
    final url = '$_baseUrl/repos/$owner/$repo/issues/$issueNumber/comments';
    return _request(url: url, method: 'GET', token: token);
  }

  Future<String> createComment({
    required String owner,
    required String repo,
    required int issueNumber,
    required String body,
    required String token,
  }) async {
    final url = '$_baseUrl/repos/$owner/$repo/issues/$issueNumber/comments';
    final payload = jsonEncode({'body': body});
    return _request(url: url, method: 'POST', token: token, body: payload);
  }

  Future<String> updateComment({
    required String owner,
    required String repo,
    required int commentId,
    required String body,
    required String token,
  }) async {
    final url = '$_baseUrl/repos/$owner/$repo/issues/comments/$commentId';
    final payload = jsonEncode({'body': body});
    return _request(url: url, method: 'PATCH', token: token, body: payload);
  }

  Future<String> _request({
    required String url,
    required String method,
    required String token,
    String? body,
  }) async {
    // ✅ Fail-fast: JSON payload yanlışlıkla URL diye buraya gelirse bu blok patlatsın.
    final uri = _safeParseGitHubUrl(url);

    final client = _client ?? HttpClient();
    final shouldCloseClient = _client == null;

    try {
      final request = await _createRequest(
        client,
        uri,
        method,
      ).timeout(const Duration(seconds: 30));

      // Auth + headers
      request.headers.set('Authorization', 'Bearer $token');
      request.headers.set('Accept', 'application/vnd.github+json');
      request.headers.set('User-Agent', 'AICR/1.0');
      request.headers.set('X-GitHub-Api-Version', '2022-11-28');

      // Only set content-type when sending a body
      if (body != null) {
        request.headers.set('Content-Type', 'application/json; charset=utf-8');
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
        // ✅ Daha okunaklı hata
        throw HttpException(
          'GitHub API failed: HTTP ${response.statusCode} for $method $uri\n$responseBody',
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

  static Uri _safeParseGitHubUrl(String url) {
    // URL değilse (örn JSON string geldiyse) burada net patlasın:
    // "Contains invalid characters" gibi belirsiz hata yerine açıklama.
    if (!url.startsWith(_baseUrl)) {
      throw ArgumentError(
        'GitHubApiClient expected a GitHub API URL starting with "$_baseUrl", got: $url',
      );
    }

    final uri = Uri.parse(url);

    if (uri.scheme != 'https' || uri.host.isEmpty) {
      throw ArgumentError('Invalid GitHub API URL: $url');
    }

    return uri;
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
