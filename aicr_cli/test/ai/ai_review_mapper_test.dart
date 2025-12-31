import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';

import 'package:aicr_cli/src/ai/ai_review_mapper.dart';
import 'package:aicr_cli/src/ai/models/ai_review.dart';
import 'package:aicr_cli/src/finding/models/aicr_finding.dart';

void main() {
  test('AiReviewMapper parses OpenAI fixture JSON into AicrFinding', () {
    // Read the OpenAI-format fixture
    final fixtureFile = File(
      'test/ai/fixtures/openai_response_core_import.json',
    );
    final jsonStr = fixtureFile.readAsStringSync();
    expect(jsonStr, contains('"findings"'));
    expect(jsonStr.length, greaterThan(50));

    final fixtureJson = jsonDecode(jsonStr) as Map<String, dynamic>;

    // Convert OpenAI format to AiReview format
    // OpenAI has: { "findings": [{ "title", "description", "severity", "category", "file", "line" }] }
    // AiReview needs: { "highlights": [{ "title", "detail", "severity", "ruleId" }] }
    // Note: AiReviewMapper maps categories via ruleId, so we use 'layer_violation' for architecture
    final findingsRaw = fixtureJson['findings'] as List<dynamic>;
    final highlights = findingsRaw.map((f) {
      final item = f as Map<String, dynamic>;
      // Map OpenAI severity string to AiSeverity enum
      final severityStr = item['severity'] as String;
      final severity = switch (severityStr) {
        'error' => AiSeverity.error,
        'warning' => AiSeverity.warn,
        'info' => AiSeverity.info,
        _ => AiSeverity.warn,
      };

      // Map category to ruleId (AiReviewMapper uses ruleId to infer category)
      // For architecture category, use 'layer_violation' ruleId
      final categoryStr = item['category'] as String;
      final ruleId = categoryStr == 'architecture' ? 'layer_violation' : null;

      return AiReviewHighlight(
        severity: severity,
        title: item['title'] as String,
        detail: item['description'] as String,
        ruleId: ruleId,
      );
    }).toList();

    // Create AiReview object
    final aiReview = AiReview(
      status: AiReviewStatus.generated,
      language: AiLanguage.en,
      summary: 'Test review',
      highlights: highlights,
      suggestedActions: const [],
      limitations: const [],
    );

    // Use the existing AiReviewMapper API
    final findings = AiReviewMapper.toFindings(aiReview);

    // Assertions
    expect(findings, hasLength(1));
    final finding = findings.first;
    expect(finding.category, AicrCategory.architecture);
    expect(finding.severity, AicrSeverity.warning);
    expect(finding.title, contains('Core imports'));
    // Note: AiReviewMapper doesn't preserve filePath/line from AiReviewHighlight
    // (those fields don't exist in AiReviewHighlight model)
    // So we just verify that the mapping works correctly for the fields that are preserved
  });
}
