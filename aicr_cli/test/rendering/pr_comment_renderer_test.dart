import 'package:aicr_cli/src/finding/models/aicr_finding.dart';
import 'package:test/test.dart';

import 'package:aicr_cli/src/render/pr_comment_renderer.dart';
import 'package:aicr_cli/src/report/aicr_report.dart';

void main() {
  group('PrCommentRenderer', () {
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

    test('no deterministic warn/fail but AI finding exists -> Optional', () {
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
            source: AicrFindingSource.ai,
            confidence: 0.62,
          ),
        ],
        aiEnabled: true,
        fileCount: 1,
      );

      final md = PrCommentRenderer().render(report, locale: 'en');

      expect(md, contains('🟦 **Optional**'));
      expect(md, contains('Top actions'));
      expect(md, contains('[ai,62%]'));
    });

    test('renders upper block with Repo, Run id, Files, AI, Diff hash', () {
      final report = _makeReport(
        status: 'pass',
        pass: 6,
        warn: 0,
        fail: 0,
        findings: const [],
        aiEnabled: true,
        fileCount: 5,
      );

      final md = PrCommentRenderer().render(report, locale: 'en');

      expect(md, contains('**Repo:** flutter-aicr'));
      expect(md, contains('**Run:** aicr_123456789')); // Shortened to 14 chars
      expect(md, contains('**Files:** 5'));
      expect(md, contains('**AI:** ON (mode:'));
      expect(md, contains('**Diff:**'));
    });

    test('renders Risk level and Overall confidence', () {
      final report = _makeReport(
        status: 'pass',
        pass: 6,
        warn: 0,
        fail: 0,
        findings: const [
          AicrFinding(
            id: 'ai:123',
            category: AicrCategory.dx,
            severity: AicrSeverity.warning,
            title: 'Test finding',
            messageTr: 'TR',
            messageEn: 'EN',
            sourceId: 'ai_fake',
            source: AicrFindingSource.ai,
            confidence: 0.75,
          ),
        ],
        aiEnabled: true,
        aiMode: 'fake',
        fileCount: 1,
      );

      final md = PrCommentRenderer().render(report, locale: 'en');

      expect(md, contains('**Risk level:**'));
      expect(md, contains('**Overall confidence:**'));
      expect(md, contains('90%')); // Overall confidence: 85%*100 + 15%*30
    });

    test('FAIL present -> Recommended', () {
      final report = _makeReport(
        status: 'fail',
        pass: 4,
        warn: 1,
        fail: 1,
        findings: const [],
        aiEnabled: false,
        fileCount: 3,
      );

      final md = PrCommentRenderer().render(report, locale: 'en');

      expect(md, contains('🟨 **Recommended**'));
      expect(md, contains('deterministic signals detected'));
    });

    test('WARN present -> Recommended', () {
      final report = _makeReport(
        status: 'warn',
        pass: 4,
        warn: 2,
        fail: 0,
        findings: const [
          AicrFinding(
            id: 'rule:1',
            category: AicrCategory.security,
            severity: AicrSeverity.critical,
            title: 'Critical finding',
            messageTr: 'TR',
            messageEn: 'EN',
            sourceId: 'secret_rule',
          ),
        ],
        aiEnabled: false,
        fileCount: 3,
      );

      final md = PrCommentRenderer().render(report, locale: 'en');

      expect(md, contains('🟨 **Recommended**'));
      expect(md, contains('deterministic signals detected'));
    });

    test('WARN present -> Recommended (regardless of AI)', () {
      final report = _makeReport(
        status: 'warn',
        pass: 4,
        warn: 1,
        fail: 0,
        findings: const [
          AicrFinding(
            id: 'ai:1',
            category: AicrCategory.quality,
            severity: AicrSeverity.suggestion,
            title: 'AI finding',
            messageTr: 'TR',
            messageEn: 'EN',
            sourceId: 'ai_fake',
            source: AicrFindingSource.ai,
            confidence: 0.85,
          ),
        ],
        aiEnabled: true,
        fileCount: 2,
      );

      final md = PrCommentRenderer().render(report, locale: 'en');

      expect(md, contains('🟨 **Recommended**'));
      expect(md, isNot(contains('high confidence')));
    });

    test('AI OFF: does not reference confidence in recommendation text', () {
      final report = _makeReport(
        status: 'warn',
        pass: 4,
        warn: 1,
        fail: 0,
        findings: const [
          AicrFinding(
            id: 'rule:1',
            category: AicrCategory.security,
            severity: AicrSeverity.critical,
            title: 'Critical finding',
            messageTr: 'TR',
            messageEn: 'EN',
            sourceId: 'secret_rule',
          ),
        ],
        aiEnabled: false,
        fileCount: 1,
      );

      final md = PrCommentRenderer().render(report, locale: 'en');

      // Overall confidence should never be N/A.
      expect(md, contains('**Overall confidence:** 94%'));
      // And decision text must not use AI/confidence to escalate.
      expect(md, isNot(contains('high severity or confidence')));
      expect(md, isNot(contains('high confidence')));

      final confidenceMentions = RegExp(
        'confidence',
        caseSensitive: false,
      ).allMatches(md).length;
      expect(confidenceMentions, 1);
    });

    test('warn present -> recommended (explicit unit test)', () {
      final report = _makeReport(
        status: 'warn',
        pass: 3,
        warn: 1,
        fail: 0,
        findings: const [],
        aiEnabled: false,
        fileCount: 1,
      );

      final md = PrCommentRenderer().render(report, locale: 'en');
      expect(md, contains('🟨 **Recommended**'));
    });

    test('only suggestions -> Not needed', () {
      final report = _makeReport(
        status: 'pass',
        pass: 5,
        warn: 0,
        fail: 0,
        findings: const [
          AicrFinding(
            id: 'rule:1',
            category: AicrCategory.dx,
            severity: AicrSeverity.suggestion,
            title: 'Low severity finding',
            messageTr: 'TR',
            messageEn: 'EN',
            sourceId: 'dx_rule',
            confidence: 0.3,
          ),
        ],
        aiEnabled: false,
        fileCount: 1,
      );

      final md = PrCommentRenderer().render(report, locale: 'en');

      expect(md, contains('🟩 **Not needed**'));
    });

    test('Top actions uses uniqueness (same stable key only once)', () {
      final report = _makeReport(
        status: 'warn',
        pass: 4,
        warn: 2,
        fail: 0,
        findings: [
          // Same area and title - should only appear once
          const AicrFinding(
            id: 'ai:1',
            category: AicrCategory.quality,
            severity: AicrSeverity.warning,
            title: 'Test finding',
            messageTr: 'TR',
            messageEn: 'EN',
            sourceId: 'ai_fake',
            source: AicrFindingSource.ai,
            confidence: 0.8,
            area: 'security',
          ),
          const AicrFinding(
            id: 'ai:2',
            category: AicrCategory.quality,
            severity: AicrSeverity.warning,
            title: 'Test finding', // Same title
            messageTr: 'TR2',
            messageEn: 'EN2',
            sourceId: 'ai_fake2',
            source: AicrFindingSource.ai,
            confidence: 0.7,
            area: 'security', // Same area
          ),
          // Different finding
          const AicrFinding(
            id: 'ai:3',
            category: AicrCategory.security,
            severity: AicrSeverity.critical,
            title: 'Different finding',
            messageTr: 'TR3',
            messageEn: 'EN3',
            sourceId: 'ai_fake3',
            source: AicrFindingSource.ai,
            confidence: 0.9,
            area: 'performance',
          ),
        ],
        aiEnabled: true,
        fileCount: 3,
      );

      final md = PrCommentRenderer().render(report, locale: 'en');

      // Should contain "Top actions" section
      expect(md, contains('Top actions'));

      // Extract "Top actions" section
      final topActionsIndex = md.indexOf('### Top actions');
      final allFindingsIndex = md.indexOf('### All findings');

      if (topActionsIndex != -1 && allFindingsIndex != -1) {
        final topActionsSection = md.substring(
          topActionsIndex,
          allFindingsIndex,
        );

        // Count occurrences of "Test finding" in Top actions section - should be only once
        final testFindingCount = 'Test finding'
            .allMatches(topActionsSection)
            .length;
        expect(
          testFindingCount,
          lessThanOrEqualTo(1),
          reason: 'Same stable key should appear only once in Top actions',
        );
      }

      // Should contain the different finding
      expect(md, contains('Different finding'));
    });

    test('Top actions dedupes same rule findings with same title', () {
      final report = _makeReport(
        status: 'warn',
        pass: 4,
        warn: 2,
        fail: 0,
        findings: const [
          AicrFinding(
            id: 'rule:1',
            category: AicrCategory.security,
            severity: AicrSeverity.warning,
            title: 'Avoid hardcoded secrets',
            messageTr: 'TR',
            messageEn: 'EN',
            sourceId: 'high_entropy_secret',
            area: 'security',
          ),
          AicrFinding(
            id: 'rule:2',
            category: AicrCategory.security,
            severity: AicrSeverity.warning,
            title: 'Avoid hardcoded secrets', // same title
            messageTr: 'TR2',
            messageEn: 'EN2',
            sourceId: 'high_entropy_secret', // same rule
            area: 'security', // same area
          ),
        ],
        aiEnabled: false,
        fileCount: 1,
      );

      final md = PrCommentRenderer().render(report, locale: 'en');
      expect(md, contains('### Top actions'));

      final topActionsIndex = md.indexOf('### Top actions');
      final allFindingsIndex = md.indexOf('### All findings');
      if (topActionsIndex != -1 && allFindingsIndex != -1) {
        final topActionsSection = md.substring(
          topActionsIndex,
          allFindingsIndex,
        );
        final count = 'Avoid hardcoded secrets'
            .allMatches(topActionsSection)
            .length;
        expect(count, 1);
      }
    });

    test('Top actions sorted by severity desc, then confidence desc', () {
      final report = _makeReport(
        status: 'warn',
        pass: 4,
        warn: 3,
        fail: 0,
        findings: [
          // Lower severity, higher confidence
          const AicrFinding(
            id: 'ai:1',
            category: AicrCategory.dx,
            severity: AicrSeverity.suggestion,
            title: 'Suggestion finding',
            messageTr: 'TR',
            messageEn: 'EN',
            sourceId: 'ai_fake',
            source: AicrFindingSource.ai,
            confidence: 0.9,
            area: 'test1',
          ),
          // Higher severity, lower confidence
          const AicrFinding(
            id: 'ai:2',
            category: AicrCategory.security,
            severity: AicrSeverity.critical,
            title: 'Critical finding',
            messageTr: 'TR2',
            messageEn: 'EN2',
            sourceId: 'ai_fake2',
            source: AicrFindingSource.ai,
            confidence: 0.5,
            area: 'test2',
          ),
        ],
        aiEnabled: true,
        fileCount: 2,
      );

      final md = PrCommentRenderer().render(report, locale: 'en');

      // Critical should appear before Suggestion (severity desc)
      final criticalIndex = md.indexOf('Critical finding');
      final suggestionIndex = md.indexOf('Suggestion finding');

      if (criticalIndex != -1 && suggestionIndex != -1) {
        expect(
          criticalIndex,
          lessThan(suggestionIndex),
          reason: 'Critical severity should appear before Suggestion',
        );
      }
    });
  });
}

AicrReport _makeReport({
  required String status,
  required int pass,
  required int warn,
  required int fail,
  required List<AicrFinding> findings,
  required bool aiEnabled,
  String aiMode = 'noop',
  required int fileCount,
}) {
  final meta = Meta.fromFlat(
    toolVersion: '0.1.0',
    runId: 'aicr_123456789012345',
    createdAt: '2025-01-01T00:00:00.000Z',
    repoName: 'flutter-aicr',
    aiEnabled: aiEnabled,
    aiMode: aiMode,
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
