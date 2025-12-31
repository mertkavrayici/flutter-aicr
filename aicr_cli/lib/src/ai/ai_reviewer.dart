import 'ai_review_request.dart';
import 'ai_review_result.dart';

/// AI layer contract.
///
/// "No throw" policy:
/// - `review` must never throw.
/// - Failures must be reported via `AiReviewResult.error(...)`.
abstract class AiReviewer {
  const AiReviewer();

  Future<AiReviewResult> review(AiReviewRequest request);
}
