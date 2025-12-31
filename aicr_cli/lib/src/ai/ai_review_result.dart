import 'package:aicr_cli/src/finding/models/aicr_finding.dart';

/// Result contract for AI review.
///
/// "No throw" policy: implementations must never throw; failures should be
/// represented as `errorMessage` with `findings = []`.
final class AiReviewResult {
  final List<AicrFinding> findings;
  final String? model;
  final bool cacheHit;
  final String? errorMessage;
  final bool truncated;

  /// Optional usage details (provider specific). Keep it flexible.
  final Map<String, Object?>? usage;

  const AiReviewResult({
    required this.findings,
    this.model,
    this.cacheHit = false,
    this.errorMessage,
    this.truncated = false,
    this.usage,
  });

  const AiReviewResult.ok({
    required List<AicrFinding> findings,
    String? model,
    bool cacheHit = false,
    bool truncated = false,
    Map<String, Object?>? usage,
  }) : this(
          findings: findings,
          model: model,
          cacheHit: cacheHit,
          truncated: truncated,
          usage: usage,
        );

  const AiReviewResult.error({
    required String errorMessage,
    String? model,
    bool cacheHit = false,
    bool truncated = false,
    Map<String, Object?>? usage,
  }) : this(
          findings: const <AicrFinding>[],
          model: model,
          cacheHit: cacheHit,
          errorMessage: errorMessage,
          truncated: truncated,
          usage: usage,
        );
}


