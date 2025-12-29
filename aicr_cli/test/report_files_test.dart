import 'package:aicr_cli/src/report/aicr_report_builder.dart';
import 'package:aicr_cli/src/report/aicr_report.dart';
import 'package:test/test.dart';

void main() {
  test('report includes changed files list', () {
    final builder = AicrReportBuilder(
      repoName: 'repo',
      diffText: 'diff',
      aiEnabled: false,
      ruleResults: const [],
      files: [FileEntry.fromStringChangeType(path: 'lib/main.dart', changeType: 'modified')],
    );

    final report = builder.build();

    expect(report.files.length, greaterThan(0));
    expect(report.files.first.path, 'lib/main.dart');
  });
}
