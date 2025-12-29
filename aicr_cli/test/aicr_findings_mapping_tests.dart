import 'package:aicr_cli/src/finding/models/aicr_finding.dart';
import 'package:aicr_cli/src/report/aicr_report_builder.dart';
import 'package:aicr_cli/src/report/aicr_report.dart';
import 'package:test/test.dart';

void main() {
  test('maps bloc warn to Testing + warning finding', () {
    final ruleResults = <RuleResult>[
      RuleResult.warn(
        ruleId: 'bloc_change_requires_tests',
        title: 'BLoC changes should include tests',
        tr: 'warn-tr',
        en: 'warn-en',
        evidenceFiles: const [
          'lib/features/dashboard/presentation/bloc/dashboard_bloc.dart',
        ],
      ),
    ];

    final builder = AicrReportBuilder(
      repoName: 'x',
      diffText: 'diff',
      files: const [],
      aiEnabled: false,
      ruleResults: ruleResults,
    );

    final report = builder.build();

    expect(report.findings.length, 1);
    final f = report.findings.first;

    expect(f.category, AicrCategory.testing);
    expect(f.severity, AicrSeverity.warning);
    expect(
      f.filePath,
      'lib/features/dashboard/presentation/bloc/dashboard_bloc.dart',
    );
    expect(f.sourceId, 'bloc_change_requires_tests');
  });

  test('maps UI rule to Quality + suggestion finding', () {
    final ruleResults = <RuleResult>[
      RuleResult.warn(
        ruleId: 'ui_change_suggests_golden_tests',
        title: 'UI changes may benefit from golden tests',
        tr: 'ui-tr',
        en: 'ui-en',
        evidenceFiles: const [
          'lib/features/dashboard/presentation/components/dashboard_shell.dart',
          'lib/features/dashboard/presentation/pages/dashboard_page.dart',
        ],
      ),
    ];

    final builder = AicrReportBuilder(
      repoName: 'x',
      diffText: 'diff',
      files: const [],
      aiEnabled: false,
      ruleResults: ruleResults,
    );

    final report = builder.build();

    expect(report.findings.length, 1);
    final f = report.findings.first;

    expect(f.category, AicrCategory.quality);
    expect(f.severity, AicrSeverity.suggestion);
    expect(
      f.filePath,
      'lib/features/dashboard/presentation/components/dashboard_shell.dart',
    );
    expect(f.sourceId, 'ui_change_suggests_golden_tests');
  });
}
