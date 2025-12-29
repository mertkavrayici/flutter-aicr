import 'package:aicr_cli/src/finding/models/aicr_finding.dart';

import 'ai_review_input.dart';
import 'ai_reviewer.dart';

final class NoopAiReviewer implements AiReviewer {
  const NoopAiReviewer();

  @override
  Future<List<AicrFinding>> review(AiReviewInput input) async {
    return const <AicrFinding>[];
  }
}
