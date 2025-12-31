/// Request contract for AI review.
///
/// This is intentionally small and OpenAI-ready:
/// - raw diff text
/// - stable diff hash (for caching)
/// - output budget controls
final class AiReviewRequest {
  final String repoName;
  final String diffHash;
  final String diffText;

  /// Maximum number of findings the reviewer should return.
  final int maxFindings;

  /// Language code (default: "en").
  ///
  /// Keep this a plain string so the contract is easy to serialize for
  /// integrations.
  final String language;

  /// Soft limit: reviewer should truncate input if it exceeds this size.
  final int maxInputChars;

  /// Target token budget for the model output (integration hint).
  final int maxOutputTokens;

  /// Time budget for the reviewer call (integration hint).
  final int timeoutMs;

  const AiReviewRequest({
    required this.repoName,
    required this.diffHash,
    required this.diffText,
    required this.maxFindings,
    this.language = 'en',
    required this.maxInputChars,
    required this.maxOutputTokens,
    required this.timeoutMs,
  });
}


