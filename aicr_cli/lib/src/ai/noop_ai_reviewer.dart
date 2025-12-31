import 'package:aicr_cli/src/finding/models/aicr_finding.dart';

import 'ai_review_request.dart';
import 'ai_review_result.dart';
import 'ai_reviewer.dart';

final class NoopAiReviewer implements AiReviewer {
  const NoopAiReviewer();

  @override
  Future<AiReviewResult> review(AiReviewRequest request) async {
    return const AiReviewResult.ok(findings: <AicrFinding>[]);
  }
}
