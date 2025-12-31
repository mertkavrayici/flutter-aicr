import 'package:aicr_cli/src/finding/models/aicr_finding.dart';
import 'package:aicr_cli/src/report/aicr_report.dart';
import 'package:aicr_cli/src/render/aicr_markdown_renderer.dart';
import 'package:test/test.dart';

void main() {
  test('markdown hides legacy rules by default', () {
    final report = AicrReport(
      meta: Meta.fromFlat(
        toolVersion: '0.1.0',
        runId: 'run',
        createdAt: 'now',
        repoName: 'repo',
        aiEnabled: false,
        aiMode: 'noop',
        diffHash: 'hash',
        fileCount: 0,
      ),
      summary: Summary.fromStringStatus(
        status: 'pass',
        ruleResults: Counts(pass: 0, warn: 0, fail: 0),
        contractResults: Counts(pass: 0, warn: 0, fail: 0),
        fileFindings: FileCounts(info: 0, warn: 0, error: 0),
      ),
      rules: [RuleResult.pass(ruleId: 'x', title: 't', tr: 'tr', en: 'en')],
      findings: const [
        AicrFinding(
          id: 'f1',
          category: AicrCategory.quality,
          severity: AicrSeverity.info,
          title: 'Info',
          messageTr: 'tr',
          messageEn: 'en',
        ),
      ],
      files: const [],
      contracts: const [],
      recommendations: const [],
      aiReview: null,
    );

    final md = AicrMarkdownRenderer().render(report);

    expect(md.contains('Legacy rule results (debug)'), isFalse);
    expect(md.contains('## Findings'), isTrue);
  });

  test('markdown can include legacy rules when enabled', () {
    final report = AicrReport(
      meta: Meta.fromFlat(
        toolVersion: '0.1.0',
        runId: 'run',
        createdAt: 'now',
        repoName: 'repo',
        aiEnabled: false,
        aiMode: 'noop',
        diffHash: 'hash',
        fileCount: 0,
      ),
      summary: Summary.fromStringStatus(
        status: 'pass',
        ruleResults: Counts(pass: 1, warn: 0, fail: 0),
        contractResults: Counts(pass: 0, warn: 0, fail: 0),
        fileFindings: FileCounts(info: 0, warn: 0, error: 0),
      ),
      rules: [RuleResult.pass(ruleId: 'x', title: 't', tr: 'tr', en: 'en')],
      findings: const [],
      files: const [],
      contracts: const [],
      recommendations: const [],
      aiReview: null,
    );

    final md = AicrMarkdownRenderer(includeLegacyRules: true).render(report);

    expect(md.contains('Legacy rule results (debug)'), isTrue);
    expect(md.contains('**t** (`x`)'), isTrue);
  });
}
