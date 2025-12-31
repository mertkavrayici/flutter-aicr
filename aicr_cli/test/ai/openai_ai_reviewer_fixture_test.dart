import 'dart:convert';

import 'package:test/test.dart';

import 'package:aicr_cli/src/ai/ai.dart';
import 'package:aicr_cli/src/finding/models/aicr_finding.dart';
import 'package:aicr_cli/src/util/aicr_logger.dart';

/// Fixture test: validates that OpenAI reviewer correctly parses and maps
/// AI JSON responses, especially for Budgetment-specific issues like
/// core_module.dart importing transaction_seeder.dart.
void main() {
  test('OpenAI reviewer parses fixture JSON about core→feature import issue',
      () async {
    // Fixture AI response about core_module.dart importing transaction_seeder.dart
    final fixtureJson = {
      'findings': [
        {
          'title': 'Core module imports feature seeder',
          'description':
              'lib/core/di/core_module.dart imports features/transactions/data/seeding/transaction_seeder.dart. Core should not depend on features. Move seeder bindings to features/transactions/di/transactions_module.dart or introduce an abstraction in core.',
          'severity': 'error',
          'category': 'architecture',
          'file': 'lib/core/di/core_module.dart',
          'line': 15,
        },
        {
          'title': 'Missing feature DI module registration',
          'description':
              'TransactionsSeeder binding should be registered in features/transactions/di/transactions_module.dart, not in core_module.dart.',
          'severity': 'warning',
          'category': 'architecture',
          'file': 'lib/core/di/core_module.dart',
          'line': 18,
        },
        {
          'title': 'Layer violation: core depends on feature',
          'description':
              'Core module should not import feature-specific implementations. Consider introducing a Seeder interface in core and implementing it in the feature module.',
          'severity': 'warning',
          'category': 'architecture',
          'file': 'lib/core/di/core_module.dart',
          'line': 15,
        },
      ],
    };

    final reviewer = OpenAiAiReviewer(
      logger: const AicrLogger.none(),
      apiKeyOverride: 'test-key',
      transport: ({required uri, required headers, required body, required timeout}) async {
        // Return a mock response with our fixture JSON
        return OpenAiTransportResponse(
          statusCode: 200,
          body: jsonEncode({
            'model': 'gpt-4o-mini',
            'output_text': jsonEncode(fixtureJson),
            'usage': {'prompt_tokens': 100, 'completion_tokens': 200},
          }),
        );
      },
    );

    final result = await reviewer.review(
      AiReviewRequest(
        repoName: 'budgetment',
        diffHash: 'sha256:test',
        diffText: r'''
diff --git a/lib/core/di/core_module.dart b/lib/core/di/core_module.dart
index 111..222 100644
--- a/lib/core/di/core_module.dart
+++ b/lib/core/di/core_module.dart
@@ -12,6 +12,7 @@
 import 'package:budgetment/core/di/core_module.dart';
+import 'package:budgetment/features/transactions/data/seeding/transaction_seeder.dart';
 
 final class CoreModule {
   void register() {
+    GetIt.instance.registerLazySingleton<TransactionsSeeder>(() => TransactionsSeeder());
   }
 }
''',
        maxFindings: 10,
        language: 'en',
        maxInputChars: 120_000,
        maxOutputTokens: 2_000,
        timeoutMs: 15_000,
      ),
    );

    expect(result.errorMessage, isNull);
    expect(result.findings, hasLength(3));

    final first = result.findings.first;
    expect(first.title, 'Core module imports feature seeder');
    expect(first.category, AicrCategory.architecture);
    expect(first.severity, AicrSeverity.warning); // error -> warning (AI guard)
    expect(first.filePath, 'lib/core/di/core_module.dart');
    expect(first.lineStart, 15);
    expect(first.source, AicrFindingSource.ai);
    expect(first.sourceId, 'ai_openai');

    final second = result.findings[1];
    expect(second.title, 'Missing feature DI module registration');
    expect(second.category, AicrCategory.architecture);
    expect(second.filePath, 'lib/core/di/core_module.dart');
    expect(second.lineStart, 18);

    final third = result.findings[2];
    expect(third.title, 'Layer violation: core depends on feature');
    expect(third.category, AicrCategory.architecture);
  });

  test('OpenAI reviewer maps quality category correctly', () async {
    final fixtureJson = {
      'findings': [
        {
          'title': 'Code quality issue',
          'description': 'This is a quality finding',
          'severity': 'warning',
          'category': 'quality',
          'file': 'lib/test.dart',
          'line': 10,
        },
      ],
    };

    final reviewer = OpenAiAiReviewer(
      logger: const AicrLogger.none(),
      apiKeyOverride: 'test-key',
      transport: ({required uri, required headers, required body, required timeout}) async {
        return OpenAiTransportResponse(
          statusCode: 200,
          body: jsonEncode({
            'model': 'gpt-4o-mini',
            'output_text': jsonEncode(fixtureJson),
          }),
        );
      },
    );

    final result = await reviewer.review(
      AiReviewRequest(
        repoName: 'test',
        diffHash: 'sha256:test',
        diffText: 'diff',
        maxFindings: 10,
        language: 'en',
        maxInputChars: 120_000,
        maxOutputTokens: 2_000,
        timeoutMs: 15_000,
      ),
    );

    expect(result.findings, hasLength(1));
    expect(result.findings.first.category, AicrCategory.quality);
  });
}

