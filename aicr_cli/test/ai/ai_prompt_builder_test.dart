import 'package:test/test.dart';

import 'package:aicr_cli/src/ai/ai.dart';
import 'package:aicr_cli/src/profile/aicr_project_profile.dart';

void main() {
  test('system prompt includes JSON-only instruction and schema', () {
    const b = AiPromptBuilder();
    final system = b.buildSystemPrompt(language: 'en');

    expect(system, contains('ONLY valid JSON'));
    expect(system, contains('"findings"'));
    expect(system, contains('"severity"'));
    expect(system, contains('"category"'));
  });

  test('system prompt includes Project context when profile present', () {
    const b = AiPromptBuilder();
    const profile = AicrProjectProfile(
      projectName: 'Budgetment',
      architecture: 'feature-first',
      forbiddenImports: ['core must not import features/transactions'],
    );

    final system = b.buildSystemPrompt(language: 'en', profile: profile);
    expect(system, contains('Project context:'));
    expect(system, contains('projectName'));
    expect(system, contains('forbiddenImports'));
  });

  test('user prompt includes repo, diff and schema', () {
    const b = AiPromptBuilder();
    final user = b.buildUserPrompt(
      repoName: 'repo',
      diffText: 'diff --git ...',
      maxFindings: 3,
    );

    expect(user, contains('repoName: repo'));
    expect(user, contains('Produce at most 3 findings'));
    expect(user, contains('diff --git'));
    expect(user, contains('"findings"'));
  });
}


