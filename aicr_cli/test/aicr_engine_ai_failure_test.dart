import 'package:test/test.dart';

import 'package:aicr_cli/aicr_cli.dart';
import 'package:aicr_cli/src/ai/ai.dart';

final class ThrowingAiReviewer implements AiReviewer {
  @override
  Future<List<AicrFinding>> review(AiReviewInput input) async {
    throw Exception('boom');
  }
}

void main() {
  test('AI reviewer throws -> analyze still returns report', () async {
    const diffText = r'''
diff --git a/lib/a.dart b/lib/a.dart
index 111..222 100644
--- a/lib/a.dart
+++ b/lib/a.dart
@@ -1,1 +1,2 @@
 class A {}
+class B {}
''';

    final report = await AicrEngine.analyze(
      diffText: diffText,
      aiEnabled: true,
      repoName: 'test-repo',
      language: AiLanguage.en,
      aiReviewer: ThrowingAiReviewer(),
    );

    expect(report.meta.repoName, 'test-repo');
    // deterministic rules yine çalışmış olmalı (findings olabilir/olmayabilir).
    expect(report.rules, isNotEmpty);
  });
}
