import 'package:test/test.dart';

import 'package:aicr_cli/src/ai/ai.dart';

void main() {
  test('AiReviewerFactory openai -> OpenAiAiReviewer', () {
    final reviewer = const AiReviewerFactory().create(AiMode.openai);
    expect(reviewer, isA<OpenAiAiReviewer>());
  });
}


