import 'package:aicr_cli/src/finding/models/aicr_finding.dart';
import 'package:test/test.dart';

import 'package:aicr_cli/src/render/pr_comment_renderer.dart';
import 'package:aicr_cli/src/report/aicr_report.dart';

void main() {
  test('renders Not needed when no findings and no warn/fail', () {
    final report = _makeReport(
      status: 'pass',
      pass: 6,
      warn: 0,
      fail: 0,
      findings: const [],
      aiEnabled: false,
      fileCount: 2,
    );

    final md = PrCommentRenderer().render(report, locale: 'en');

    expect(md, contains('## AICR — PASS'));
    expect(md, contains('🟩 **Not needed**'));
    expect(md, contains('No findings ✅'));
    expect(md, contains('**Files:** 2'));
  });

  test('renders Optional when only AI findings exist', () {
    final report = _makeReport(
      status: 'pass',
      pass: 6,
      warn: 0,
      fail: 0,
      findings: const [
        AicrFinding(
          id: 'ai:123',
          category: AicrCategory.dx,
          severity: AicrSeverity.suggestion,
          title: 'Docs/Changelog gözden geçir',
          messageTr: 'TR',
          messageEn: 'EN',
          sourceId: 'ai_fake',
          confidence: 0.62,
        ),
      ],
      aiEnabled: true,
      fileCount: 1,
    );

    final md = PrCommentRenderer().render(report, locale: 'en');

    expect(md, contains('🟦 **Optional**'));
    expect(md, contains('Top actions'));
    expect(md, contains('(AI, 62%)'));
  });
}

AicrReport _makeReport({
  required String status,
  required int pass,
  required int warn,
  required int fail,
  required List<AicrFinding> findings,
  required bool aiEnabled,
  required int fileCount,
}) {
  final meta = Meta.fromFlat(
    toolVersion: '0.1.0',
    runId: 'aicr_123456789012345',
    createdAt: '2025-01-01T00:00:00.000Z',
    repoName: 'flutter-aicr',
    aiEnabled: aiEnabled,
    diffHash: 'sha256:abc',
    fileCount: fileCount,
  );

  final summary = Summary.fromStringStatus(
    status: status,
    ruleResults: Counts(pass: pass, warn: warn, fail: fail),
    contractResults: Counts(pass: 0, warn: 0, fail: 0),
    fileFindings: FileCounts(info: 0, warn: 0, error: 0),
  );

  return AicrReport(
    meta: meta,
    summary: summary,
    rules: const [],
    findings: findings,
    contracts: const [],
    files: const [],
    recommendations: const [],
    aiReview: null,
  );
}
