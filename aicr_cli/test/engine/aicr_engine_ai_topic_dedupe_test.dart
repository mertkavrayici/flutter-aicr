import 'package:test/test.dart';

import 'package:aicr_cli/aicr_cli.dart';
import 'package:aicr_cli/src/ai/ai.dart';

final class _SameTitleAiReviewer implements AiReviewer {
  @override
  Future<AiReviewResult> review(AiReviewRequest request) async {
    // Intentionally match a deterministic rule title to ensure AI is dropped.
    return const AiReviewResult.ok(
      model: 'test',
      findings: [
        AicrFinding(
          id: 'ai:same_title',
          category: AicrCategory.security,
          severity: AicrSeverity.warning,
          title: 'Potential secret patterns detected in diff',
          messageTr: 'TR',
          messageEn: 'EN',
          filePath: 'lib/config.dart',
          sourceId: 'ai_fake',
          source: AicrFindingSource.ai,
        ),
      ],
    );
  }
}

void main() {
  test('topic dedupe: deterministic + AI same title -> only deterministic kept',
      () async {
    const diff = r'''
diff --git a/lib/config.dart b/lib/config.dart
index 111..222 100644
--- a/lib/config.dart
+++ b/lib/config.dart
@@ -1,1 +1,2 @@
 class Config {}
+final token = "abc"; // token=
''';

    final report = await AicrEngine.analyze(
      diffText: diff,
      aiEnabled: true,
      aiMode: AiMode.fake,
      repoName: 'repo',
      language: AiLanguage.en,
      aiReviewer: _SameTitleAiReviewer(),
      files: const [
        FileEntry(path: 'lib/config.dart', changeType: FileChangeType.modified),
      ],
    );

    // Deterministic rule DiffSecretPatternsRule should trigger this title.
    final matches = report.findings
        .where((f) => f.title == 'Potential secret patterns detected in diff')
        .toList(growable: false);
    expect(matches.length, 1);

    // Since deterministic > AI, the remaining one should not be AI.
    expect(matches.single.source, isNot(AicrFindingSource.ai));
  });
}


