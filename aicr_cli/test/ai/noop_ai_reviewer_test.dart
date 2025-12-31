import 'package:test/test.dart';

import 'package:aicr_cli/src/ai/ai.dart';

void main() {
  test('NoopAiReviewer.review -> empty result', () async {
    const reviewer = NoopAiReviewer();

    final out = await reviewer.review(
      const AiReviewRequest(
        repoName: 'repo',
        diffHash: 'hash',
        diffText: '',
        maxFindings: 10,
        language: 'en',
        maxInputChars: 1000,
        maxOutputTokens: 500,
        timeoutMs: 1000,
      ),
    );

    expect(out.errorMessage, isNull);
    expect(out.findings, isEmpty);
  });
}
