import '../finding/models/aicr_finding.dart';
import 'models/ai_review.dart';

/// Maps AiReview to AicrFinding list for compatibility with existing findings system.
/// 
/// Severity mapping:
/// - AiSeverity.error -> AicrSeverity.critical
/// - AiSeverity.warn -> AicrSeverity.warning
/// - AiSeverity.info -> AicrSeverity.info
class AiReviewMapper {
  /// Converts AiReview highlights and suggested actions to AicrFinding list.
  static List<AicrFinding> toFindings(AiReview review) {
    final findings = <AicrFinding>[];

    // Map highlights to findings
    for (final highlight in review.highlights) {
      final severity = _mapSeverity(highlight.severity);
      final category = _inferCategory(highlight);

      // Use detail for both languages since AiReviewHighlight doesn't have separate tr/en
      findings.add(
        AicrFinding(
          id: _makeFindingId('highlight', highlight.title, highlight.ruleId),
          category: category,
          severity: severity,
          title: highlight.title,
          messageTr: highlight.detail,
          messageEn: highlight.detail,
          sourceId: highlight.ruleId ?? 'ai_review',
          confidence: null,
        ),
      );
    }

    // Map suggested actions to findings (as suggestions)
    for (final action in review.suggestedActions) {
      // Use action text for both languages since AiSuggestedAction doesn't have separate tr/en
      findings.add(
        AicrFinding(
          id: _makeFindingId('action', action.action, action.priority.name),
          category: AicrCategory.dx,
          severity: AicrSeverity.suggestion,
          title: 'Suggested action: ${action.priority.name}',
          messageTr: action.action,
          messageEn: action.action,
          sourceId: 'ai_review_action',
          confidence: null,
        ),
      );
    }

    return findings;
  }

  static AicrSeverity _mapSeverity(AiSeverity severity) => switch (severity) {
        AiSeverity.error => AicrSeverity.critical,
        AiSeverity.warn => AicrSeverity.warning,
        AiSeverity.info => AicrSeverity.info,
      };

  static AicrCategory _inferCategory(AiReviewHighlight highlight) {
    // Try to infer category from ruleId if present
    if (highlight.ruleId != null) {
      return _mapCategoryFromRuleId(highlight.ruleId!);
    }
    // Default based on severity
    return switch (highlight.severity) {
      AiSeverity.error => AicrCategory.security,
      AiSeverity.warn => AicrCategory.quality,
      AiSeverity.info => AicrCategory.dx,
    };
  }

  static AicrCategory _mapCategoryFromRuleId(String ruleId) => switch (ruleId) {
        'bloc_change_requires_tests' => AicrCategory.testing,
        'large_change_set' => AicrCategory.dx,
        'ui_change_suggests_golden_tests' => AicrCategory.quality,
        'secret_or_env_exposure' => AicrCategory.security,
        'layer_violation' => AicrCategory.architecture,
        'large_diff_suggests_split' => AicrCategory.performance,
        _ => AicrCategory.quality,
      };

  static String _makeFindingId(String type, String content, String? extra) {
    final seed = 'ai_review:$type:$content:${extra ?? ''}';
    final hash = seed.hashCode.toRadixString(16).substring(0, 12);
    return 'ai_review:$hash';
  }
}

