// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'aicr_finding.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AicrFindingDto _$AicrFindingDtoFromJson(Map<String, dynamic> json) =>
    AicrFindingDto(
      id: json['id'] as String,
      category: $enumDecode(_$AicrCategoryEnumMap, json['category']),
      severity: $enumDecode(_$AicrSeverityEnumMap, json['severity']),
      title: json['title'] as String,
      message: Map<String, String>.from(json['message'] as Map),
      filePath: json['file_path'] as String?,
      lineStart: (json['line_start'] as num?)?.toInt(),
      lineEnd: (json['line_end'] as num?)?.toInt(),
      sourceId: json['source_id'] as String?,
      confidence: (json['confidence'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$AicrFindingDtoToJson(AicrFindingDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'category': _$AicrCategoryEnumMap[instance.category]!,
      'severity': _$AicrSeverityEnumMap[instance.severity]!,
      'title': instance.title,
      'message': instance.message,
      if (instance.filePath case final value?) 'file_path': value,
      if (instance.lineStart case final value?) 'line_start': value,
      if (instance.lineEnd case final value?) 'line_end': value,
      if (instance.sourceId case final value?) 'source_id': value,
      if (instance.confidence case final value?) 'confidence': value,
    };

const _$AicrCategoryEnumMap = {
  AicrCategory.architecture: 'architecture',
  AicrCategory.quality: 'quality',
  AicrCategory.bugRisk: 'bugRisk',
  AicrCategory.performance: 'performance',
  AicrCategory.security: 'security',
  AicrCategory.testing: 'testing',
  AicrCategory.dx: 'dx',
  AicrCategory.nitpick: 'nitpick',
};

const _$AicrSeverityEnumMap = {
  AicrSeverity.info: 'info',
  AicrSeverity.suggestion: 'suggestion',
  AicrSeverity.warning: 'warning',
  AicrSeverity.critical: 'critical',
};
