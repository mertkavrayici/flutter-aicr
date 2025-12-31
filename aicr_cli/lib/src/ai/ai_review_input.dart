/// Summary context of deterministic analysis (rules + findings).
///
/// Keep this small and stable so the AI layer can reason about the overall
/// risk without coupling to internal rule implementations.
final class AiDeterministicFindingsSummary {
  final int pass;
  final int warn;
  final int fail;
  final int findingCount;
  final Set<String> triggeredRuleIds;

  const AiDeterministicFindingsSummary({
    required this.pass,
    required this.warn,
    required this.fail,
    required this.findingCount,
    this.triggeredRuleIds = const <String>{},
  });
}

/// Input contract for AI reviewer.
///
/// Minimal and domain-oriented:
/// - repo name
/// - raw diff text
/// - changed files list
/// - deterministic findings summary (not the full findings list)
final class AiReviewInput {
  final String repoName;
  final String diffText;
  final List<String> changedFiles;
  final AiDeterministicFindingsSummary deterministic;

  /// Optional free-form metadata for integrations (CI context etc.).
  /// Avoid secrets.
  final Map<String, String> metadata;

  AiReviewInput({
    required this.repoName,
    required this.diffText,
    required this.changedFiles,
    required this.deterministic,
    Map<String, String>? metadata,
  }) : metadata = metadata ?? const {};
}
