import 'package:test/test.dart';

import 'package:aicr_cli/src/ai/ai.dart';

void main() {
  test('secret pattern içeren diff -> en az 1 AI finding', () async {
    const diff = r'''
diff --git a/lib/a.dart b/lib/a.dart
index 111..222 100644
--- a/lib/a.dart
+++ b/lib/a.dart
@@ -1,1 +1,2 @@
 class A {}
+const token = "abc"; // token=
''';

    const reviewer = FakeAiReviewer();

    final result = await reviewer.review(
      const AiReviewRequest(
        repoName: 'repo',
        diffHash: 'hash',
        diffText: diff,
        maxFindings: 10,
        language: 'en',
        maxInputChars: 10000,
        maxOutputTokens: 500,
        timeoutMs: 1000,
      ),
    );

    expect(result.errorMessage, isNull);
    expect(result.findings, isNotEmpty);
  });
}
