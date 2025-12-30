// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_review.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AiReviewHighlightImpl _$$AiReviewHighlightImplFromJson(
  Map<String, dynamic> json,
) => _$AiReviewHighlightImpl(
  severity: $enumDecode(_$AiSeverityEnumMap, json['severity']),
  title: json['title'] as String,
  detail: json['detail'] as String,
  ruleId: json['rule_id'] as String?,
  area: json['area'] as String?,
  risk: json['risk'] as String?,
  reason: json['reason'] as String?,
  suggestedAction: json['suggested_action'] as String?,
  confidence: (json['confidence'] as num?)?.toDouble(),
);

Map<String, dynamic> _$$AiReviewHighlightImplToJson(
  _$AiReviewHighlightImpl instance,
) => <String, dynamic>{
  'severity': _$AiSeverityEnumMap[instance.severity]!,
  'title': instance.title,
  'detail': instance.detail,
  'rule_id': instance.ruleId,
  'area': instance.area,
  'risk': instance.risk,
  'reason': instance.reason,
  'suggested_action': instance.suggestedAction,
  'confidence': instance.confidence,
};

const _$AiSeverityEnumMap = {
  AiSeverity.info: 'info',
  AiSeverity.warn: 'warn',
  AiSeverity.error: 'error',
};

_$AiSuggestedActionImpl _$$AiSuggestedActionImplFromJson(
  Map<String, dynamic> json,
) => _$AiSuggestedActionImpl(
  priority: $enumDecode(_$AiActionPriorityEnumMap, json['priority']),
  action: json['action'] as String,
);

Map<String, dynamic> _$$AiSuggestedActionImplToJson(
  _$AiSuggestedActionImpl instance,
) => <String, dynamic>{
  'priority': _$AiActionPriorityEnumMap[instance.priority]!,
  'action': instance.action,
};

const _$AiActionPriorityEnumMap = {
  AiActionPriority.p0: 'p0',
  AiActionPriority.p1: 'p1',
  AiActionPriority.p2: 'p2',
};

_$AiReviewImpl _$$AiReviewImplFromJson(Map<String, dynamic> json) =>
    _$AiReviewImpl(
      status: $enumDecode(_$AiReviewStatusEnumMap, json['status']),
      language: $enumDecode(_$AiLanguageEnumMap, json['language']),
      summary: json['summary'] as String,
      highlights: (json['highlights'] as List<dynamic>)
          .map((e) => AiReviewHighlight.fromJson(e as Map<String, dynamic>))
          .toList(),
      suggestedActions: (json['suggested_actions'] as List<dynamic>)
          .map((e) => AiSuggestedAction.fromJson(e as Map<String, dynamic>))
          .toList(),
      limitations: (json['limitations'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$$AiReviewImplToJson(_$AiReviewImpl instance) =>
    <String, dynamic>{
      'status': _$AiReviewStatusEnumMap[instance.status]!,
      'language': _$AiLanguageEnumMap[instance.language]!,
      'summary': instance.summary,
      'highlights': instance.highlights,
      'suggested_actions': instance.suggestedActions,
      'limitations': instance.limitations,
    };

const _$AiReviewStatusEnumMap = {
  AiReviewStatus.skipped: 'skipped',
  AiReviewStatus.generated: 'generated',
  AiReviewStatus.notConfigured: 'notConfigured',
  AiReviewStatus.error: 'error',
};

const _$AiLanguageEnumMap = {AiLanguage.tr: 'tr', AiLanguage.en: 'en'};
