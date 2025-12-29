// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'ai_review.freezed.dart';
part 'ai_review.g.dart';

enum AiReviewStatus {
  skipped,
  generated,

  // Keep legacy JSON string exactly as before (`AiReviewStatus.notConfigured.name`).
  @JsonValue('notConfigured')
  notConfigured,
  error,
}

enum AiSeverity { info, warn, error }

enum AiLanguage {
  @JsonValue('tr')
  tr,
  @JsonValue('en')
  en,
}

extension AiLanguageParsing on AiLanguage {
  static AiLanguage fromCode(String code) => switch (code) {
    'tr' => AiLanguage.tr,
    _ => AiLanguage.en,
  };

  String get code => switch (this) {
    AiLanguage.tr => 'tr',
    AiLanguage.en => 'en',
  };
}

enum AiActionPriority {
  @JsonValue('p0')
  p0,
  @JsonValue('p1')
  p1,
  @JsonValue('p2')
  p2,
}

@freezed
class AiReviewHighlight with _$AiReviewHighlight {
  const factory AiReviewHighlight({
    required AiSeverity severity,
    required String title,
    required String detail,
    @JsonKey(name: 'rule_id') String? ruleId,
  }) = _AiReviewHighlight;

  factory AiReviewHighlight.fromJson(Map<String, dynamic> json) =>
      _$AiReviewHighlightFromJson(json);
}

@freezed
class AiSuggestedAction with _$AiSuggestedAction {
  const factory AiSuggestedAction({
    required AiActionPriority priority,
    required String action,
  }) = _AiSuggestedAction;

  factory AiSuggestedAction.fromJson(Map<String, dynamic> json) =>
      _$AiSuggestedActionFromJson(json);
}

@freezed
class AiReview with _$AiReview {
  const factory AiReview({
    required AiReviewStatus status,
    required AiLanguage language,
    required String summary,
    required List<AiReviewHighlight> highlights,
    @JsonKey(name: 'suggested_actions')
    required List<AiSuggestedAction> suggestedActions,
    required List<String> limitations,
  }) = _AiReview;

  factory AiReview.fromJson(Map<String, dynamic> json) => _$AiReviewFromJson(json);
}


