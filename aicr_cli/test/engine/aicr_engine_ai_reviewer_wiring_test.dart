import 'package:test/test.dart';

import 'package:aicr_cli/aicr_cli.dart';
import 'package:aicr_cli/src/ai/ai.dart';

final class CountingAiReviewer implements AiReviewer {
  int calls = 0;
  final AiReviewResult Function(AiReviewRequest request) onReview;

  CountingAiReviewer({required this.onReview});

  @override
  Future<AiReviewResult> review(AiReviewRequest request) async {
    calls++;
    return onReview(request);
  }
}

final class EmptyAiReviewService implements AiReviewService {
  @override
  Future<AiReview> generate({
    required String diffText,
    required AicrReport report,
    required AiLanguage language,
  }) async {
    return AiReview(
      status: AiReviewStatus.generated,
      language: language,
      summary: '',
      highlights: const [],
      suggestedActions: const [],
      limitations: const [],
    );
  }
}

void main() {
  test('aiEnabled=false -> AiReviewer.review is not called', () async {
    final reviewer = CountingAiReviewer(
      onReview: (_) => const AiReviewResult.ok(findings: <AicrFinding>[]),
    );

    await AicrEngine.analyze(
      diffText: '',
      aiEnabled: false,
      repoName: 'test-repo',
      language: AiLanguage.en,
      aiReviewer: reviewer,
      aiReviewService: EmptyAiReviewService(),
    );

    expect(reviewer.calls, 0);
  });

  test(
    'aiEnabled=true -> AiReviewer.review is called and merged with dedupe',
    () async {
      const diff = r'''
diff --git a/lib/config.dart b/lib/config.dart
index 111..222 100644
--- a/lib/config.dart
+++ b/lib/config.dart
@@ -1,1 +1,2 @@
 class Config {}
+const API_KEY = "supersecretvalue123";
''';

      final reviewer = CountingAiReviewer(
        onReview: (request) {
          expect(request.repoName, 'test-repo');
          expect(request.diffHash, isNotEmpty);
          expect(request.diffText, isNotEmpty);
          expect(request.language, 'en');
          expect(request.maxFindings, greaterThan(0));

          // 1) Two AI findings with identical signature but different IDs (must dedupe by signature, not id)
          const dup1 = AicrFinding(
            id: 'ai:dup1',
            category: AicrCategory.quality,
            severity: AicrSeverity.suggestion,
            title: 'Dup finding',
            messageTr: 'TR dup',
            messageEn: 'EN dup',
            filePath: 'lib/config.dart',
            sourceId: 'ai_fake',
            source: AicrFindingSource.ai,
          );
          const dup2 = AicrFinding(
            id: 'ai:dup2',
            category: AicrCategory.quality,
            severity: AicrSeverity.suggestion,
            title: 'Dup finding',
            messageTr: 'TR dup',
            messageEn: 'EN dup',
            filePath: 'lib/config.dart',
            sourceId: 'ai_fake',
            source: AicrFindingSource.ai,
          );

          // 2) Similar-ish but different message (should remain)
          final unique = AicrFinding(
            id: 'ai:unique',
            category: AicrCategory.quality,
            severity: AicrSeverity.suggestion,
            title: 'Extra note',
            messageTr: 'TR dup (extra)',
            messageEn: 'EN dup (extra)',
            filePath: 'lib/config.dart',
            sourceId: 'ai_fake',
            source: AicrFindingSource.ai,
          );

          return AiReviewResult.ok(
            model: 'test',
            findings: [dup1, dup2, unique],
          );
        },
      );

      final report = await AicrEngine.analyze(
        diffText: diff,
        aiEnabled: true,
        repoName: 'test-repo',
        language: AiLanguage.en,
        aiReviewer: reviewer,
        aiReviewService: EmptyAiReviewService(),
        files: const [
          FileEntry(
            path: 'lib/config.dart',
            changeType: FileChangeType.modified,
          ),
        ],
      );

      expect(reviewer.calls, 1);

      // Should contain only one of the duplicates + the unique one.
      final dupCount = report.findings
          .where((f) => f.title == 'Dup finding' && f.messageEn == 'EN dup')
          .length;
      expect(dupCount, 1);
      expect(report.findings.where((f) => f.id == 'ai:unique'), isNotEmpty);
    },
  );
}
