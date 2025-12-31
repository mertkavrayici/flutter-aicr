import 'package:test/test.dart';

import 'package:aicr_cli/aicr_cli.dart';
import 'package:aicr_cli/src/ai/ai.dart';

final class _CriticalAiReviewer implements AiReviewer {
  @override
  Future<AiReviewResult> review(AiReviewRequest request) async {
    return const AiReviewResult.ok(
      model: 'test',
      findings: [
        AicrFinding(
          id: 'ai:crit',
          category: AicrCategory.security,
          severity: AicrSeverity.critical,
          title: 'AI critical',
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
  const diff = r'''
diff --git a/lib/config.dart b/lib/config.dart
index 111..222 100644
--- a/lib/config.dart
+++ b/lib/config.dart
@@ -1,1 +1,2 @@
 class Config {}
+const API_KEY = "supersecretvalue123";
''';

  test('ai off -> only deterministic findings (no AI source)', () async {
    final report = await AicrEngine.analyze(
      diffText: diff,
      aiEnabled: false,
      repoName: 'repo',
      language: AiLanguage.en,
      files: const [
        FileEntry(path: 'lib/config.dart', changeType: FileChangeType.modified),
      ],
    );

    expect(report.findings, isNotEmpty);
    expect(report.findings.where((f) => f.source == AicrFindingSource.ai), isEmpty);
  });

  test('ai fake -> deterministic + ai findings merged', () async {
    final report = await AicrEngine.analyze(
      diffText: diff,
      aiEnabled: true,
      aiMode: AiMode.fake,
      repoName: 'repo',
      language: AiLanguage.en,
      aiReviewer: const FakeAiReviewer(),
      files: const [
        FileEntry(path: 'lib/config.dart', changeType: FileChangeType.modified),
      ],
    );

    expect(report.findings, isNotEmpty);
    expect(report.findings.where((f) => f.source == AicrFindingSource.ai), isNotEmpty);
    expect(report.findings.where((f) => f.source != AicrFindingSource.ai), isNotEmpty);
  });

  test('ai severity guard -> AI critical downgraded to warning', () async {
    final report = await AicrEngine.analyze(
      diffText: diff,
      aiEnabled: true,
      aiMode: AiMode.fake,
      repoName: 'repo',
      language: AiLanguage.en,
      aiReviewer: _CriticalAiReviewer(),
      files: const [
        FileEntry(path: 'lib/config.dart', changeType: FileChangeType.modified),
      ],
    );

    final aiFinding = report.findings.firstWhere((f) => f.id == 'ai:crit');
    expect(aiFinding.severity, AicrSeverity.warning);
  });
}


