import 'package:aicr_cli/src/rules/rules.dart';
import 'package:test/test.dart';

void main() {
  group('BlocChangeRequiresTestsRule', () {
    test('returns pass when no bloc files changed', () {
      final rule = BlocChangeRequiresTestsRule();

      final result = rule.evaluate(
        changedFiles: const [
          'lib/features/dashboard/presentation/pages/dashboard_page.dart',
        ],
      );

      expect(result.status.name, 'pass');
      expect(result.ruleId, 'bloc_change_requires_tests');
    });

    test('returns pass when bloc files changed and test files changed', () {
      final rule = BlocChangeRequiresTestsRule();

      final result = rule.evaluate(
        changedFiles: const [
          'lib/features/dashboard/presentation/bloc/dashboard_bloc.dart',
          'test/features/dashboard/dashboard_bloc_test.dart',
        ],
      );

      expect(result.status.name, 'pass');
    });

    test('returns warn when bloc files changed but no test changes', () {
      final rule = BlocChangeRequiresTestsRule();

      final result = rule.evaluate(
        changedFiles: const [
          'lib/features/dashboard/presentation/bloc/dashboard_bloc.dart',
        ],
      );

      expect(result.status.name, 'warn');
      expect(result.evidence, isNotEmpty);
      expect(
        result.evidence.first['file_path'],
        'lib/features/dashboard/presentation/bloc/dashboard_bloc.dart',
      );
    });
  });
}
