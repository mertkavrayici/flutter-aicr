/// Builds prompts for AI reviewers.
///
/// Keep prompts small and deterministic to aid testing and caching.
import '../profile/aicr_project_profile.dart';

final class AiPromptBuilder {
  const AiPromptBuilder();

  static const String strictJsonSchema = r'''
{
  "findings": [
    {
      "title": "string",
      "description": "string",
      "severity": "info|warning|error",
      "category": "architecture|testing|security|performance|dx|quality",
      "file": "string or null",
      "line": "number or null"
    }
  ]
}
''';

  /// System prompt enforcing strict JSON-only output.
  String buildSystemPrompt({
    String language = 'en',
    AicrProjectProfile? profile,
  }) {
    // Language is a hint for the content inside JSON strings (not for format).
    // Keep default English to maximize model compliance.
    final p = profile;
    final context = (p != null && !p.isEmpty) ? _buildProjectContext(p) : null;
    final reviewRules = (p != null && !p.isEmpty) ? _buildReviewRules(p) : null;

    return '''
You are an automated code reviewer.
You must output ONLY valid JSON.
No markdown. No prose.

Write all human-readable strings in: $language

${context == null ? '' : 'Project context:\n$context\n'}
${reviewRules == null ? '' : 'Review rules:\n$reviewRules\n'}

Return STRICT JSON ONLY with this schema:
$strictJsonSchema
'''.trim();
  }

  /// User prompt including constraints and diff payload.
  String buildUserPrompt({
    required String repoName,
    required String diffText,
    required int maxFindings,
    AicrProjectProfile? profile,
  }) {
    final heuristics = (profile != null && !profile.isEmpty)
        ? _buildBudgetmentHeuristics(profile)
        : null;

    return '''
repoName: $repoName

You are reviewing a git diff. Produce at most $maxFindings findings.

Constraints:
- Prefer actionable suggestions with specific file/path references when possible
- No duplicates; pick top risks only
- file + line are optional but encouraged if present in diff

Allowed severity: info, warning, error
Allowed category: architecture, testing, security, performance, dx, quality

${heuristics == null ? '' : 'Budgetment-specific heuristics:\n$heuristics\n'}

Return STRICT JSON ONLY with this schema:
$strictJsonSchema

Diff:
$diffText
''';
  }

  static String _buildProjectContext(AicrProjectProfile p) {
    final lines = <String>[];
    void add(String label, String? value) {
      final v = value?.trim();
      if (v == null || v.isEmpty) return;
      lines.add('- $label: $v');
    }

    add('projectName', p.projectName);
    add('architecture', p.architecture);
    add('stateManagement', p.stateManagement);
    add('routing', p.routing);
    add('models', p.models);
    add('testing', p.testing);

    var text = lines.join('\n');
    const cap = 1200;
    if (text.length > cap) {
      text = '${text.substring(0, cap)}...';
    }
    return text;
  }

  static String _buildReviewRules(AicrProjectProfile p) {
    final lines = <String>[];

    if (p.forbiddenImports.isNotEmpty) {
      lines.add('- forbiddenImports:');
      for (final rule in p.forbiddenImports.take(20)) {
        lines.add('  - $rule');
      }
    }

    if (p.testing != null && p.testing!.trim().isNotEmpty) {
      lines.add('- testing: ${p.testing!.trim()}');
    }

    if (lines.isEmpty) return '';
    return lines.join('\n');
  }

  static String _buildBudgetmentHeuristics(AicrProjectProfile p) {
    final lines = <String>[];

    lines.add('- If core imports feature: recommend moving registrations to feature DI module, or introducing an abstraction in core.');
    lines.add('- If BLoC changed but tests missing: suggest bloc tests.');
    if (p.routing != null && p.routing!.trim().isNotEmpty) {
      lines.add('- If routing touched: suggest navigation tests/smoke checks.');
    }

    return lines.join('\n');
  }
}


