import 'package:test/test.dart';

import 'package:aicr_cli/src/ai/ai.dart';

void main() {
  test('FakeAiReviewer returns a Large diff finding for large diffs', () async {
    final bigDiff = 'diff\n' + List.filled(700, '+line').join('\n');

    const reviewer = FakeAiReviewer();
    final out = await reviewer.review(
      AiReviewRequest(
        repoName: 'repo',
        diffHash: 'hash',
        diffText: bigDiff,
        maxFindings: 10,
        language: 'en',
        maxInputChars: 500000,
        maxOutputTokens: 500,
        timeoutMs: 1000,
      ),
    );

    expect(out.errorMessage, isNull);
    expect(
      out.findings.where((f) => f.title == 'Large diff—review recommended'),
      isNotEmpty,
    );
  });
}


