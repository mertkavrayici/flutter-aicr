import 'package:test/test.dart';

import 'package:aicr_cli/aicr_cli.dart';
import 'package:aicr_cli/src/ai/ai.dart';

void main() {
  test('AiReviewRequest/AiReviewResult can be created', () {
    const req = AiReviewRequest(
      repoName: 'repo',
      diffHash: 'hash',
      diffText: 'diff --git ...',
      maxFindings: 5,
      language: 'en',
      maxInputChars: 1000,
      maxOutputTokens: 500,
      timeoutMs: 10_000,
    );

    const res = AiReviewResult.ok(
      findings: <AicrFinding>[],
      model: 'gpt-x',
      cacheHit: true,
      truncated: false,
      usage: {'prompt_tokens': 1, 'completion_tokens': 2},
    );

    expect(req.repoName, 'repo');
    expect(req.language, 'en');
    expect(res.findings, isEmpty);
    expect(res.model, 'gpt-x');
    expect(res.cacheHit, isTrue);
    expect(res.errorMessage, isNull);
  });

  test('engine merge does not crash when reviewer returns error/empty', () async {
    const diff = r'''
diff --git a/lib/config.dart b/lib/config.dart
index 111..222 100644
--- a/lib/config.dart
+++ b/lib/config.dart
@@ -1,1 +1,2 @@
 class Config {}
+const API_KEY = "supersecretvalue123";
''';

    final reportError = await AicrEngine.analyze(
      diffText: diff,
      aiEnabled: true,
      repoName: 'repo',
      language: AiLanguage.en,
      files: const [
        FileEntry(path: 'lib/config.dart', changeType: FileChangeType.modified),
      ],
      aiReviewer: _ErrorAiReviewer(),
    );

    final reportEmpty = await AicrEngine.analyze(
      diffText: diff,
      aiEnabled: true,
      repoName: 'repo',
      language: AiLanguage.en,
      files: const [
        FileEntry(path: 'lib/config.dart', changeType: FileChangeType.modified),
      ],
      aiReviewer: _EmptyAiReviewer(),
    );

    expect(reportError.rules, isNotEmpty);
    expect(reportEmpty.rules, isNotEmpty);

    // Deterministic findings should still be present, and AI should not add any.
    expect(reportError.findings, isNotEmpty);
    expect(reportEmpty.findings, isNotEmpty);
    expect(reportError.findings.where((f) => f.source == AicrFindingSource.ai),
        isEmpty);
    expect(reportEmpty.findings.where((f) => f.source == AicrFindingSource.ai),
        isEmpty);
  });
}

final class _ErrorAiReviewer implements AiReviewer {
  @override
  Future<AiReviewResult> review(AiReviewRequest request) async {
    return const AiReviewResult.error(errorMessage: 'boom');
  }
}

final class _EmptyAiReviewer implements AiReviewer {
  @override
  Future<AiReviewResult> review(AiReviewRequest request) async {
    return const AiReviewResult.ok(findings: <AicrFinding>[]);
  }
}


