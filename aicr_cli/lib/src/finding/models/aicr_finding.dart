// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'aicr_finding.freezed.dart';
part 'aicr_finding.g.dart';

enum AicrCategory {
  architecture,
  quality,
  bugRisk,
  performance,
  security,
  testing,
  dx,
  nitpick,
}

enum AicrSeverity { info, suggestion, warning, critical }

@freezed
class AicrFinding with _$AicrFinding {
  const AicrFinding._();

  const factory AicrFinding({
    required String id,
    required AicrCategory category,
    required AicrSeverity severity,
    required String title,
    // Keep public API stable (call sites still pass messageTr/messageEn),
    // but preserve legacy JSON shape: `"message": {"tr": ..., "en": ...}`.
    required String messageTr,
    required String messageEn,
    String? filePath,
    int? lineStart,
    int? lineEnd,
    String? sourceId,
    double? confidence,
  }) = _AicrFinding;

  factory AicrFinding.fromJson(Map<String, dynamic> json) {
    final dto = AicrFindingDto.fromJson(json);
    return AicrFinding(
      id: dto.id,
      category: dto.category,
      severity: dto.severity,
      title: dto.title,
      messageTr: dto.message['tr'] ?? '',
      messageEn: dto.message['en'] ?? '',
      filePath: dto.filePath,
      lineStart: dto.lineStart,
      lineEnd: dto.lineEnd,
      sourceId: dto.sourceId,
      confidence: dto.confidence,
    );
  }

  Map<String, dynamic> toJson() => AicrFindingDto(
    id: id,
    category: category,
    severity: severity,
    title: title,
    message: {'tr': messageTr, 'en': messageEn},
    filePath: filePath,
    lineStart: lineStart,
    lineEnd: lineEnd,
    sourceId: sourceId,
    confidence: confidence,
  ).toJson();
}

@JsonSerializable(includeIfNull: false)
class AicrFindingDto {
  final String id;
  final AicrCategory category;
  final AicrSeverity severity;
  final String title;
  final Map<String, String> message;
  @JsonKey(name: 'file_path')
  final String? filePath;
  @JsonKey(name: 'line_start')
  final int? lineStart;
  @JsonKey(name: 'line_end')
  final int? lineEnd;
  @JsonKey(name: 'source_id')
  final String? sourceId;
  final double? confidence;

  const AicrFindingDto({
    required this.id,
    required this.category,
    required this.severity,
    required this.title,
    required this.message,
    this.filePath,
    this.lineStart,
    this.lineEnd,
    this.sourceId,
    this.confidence,
  });

  factory AicrFindingDto.fromJson(Map<String, dynamic> json) =>
      _$AicrFindingDtoFromJson(json);

  Map<String, dynamic> toJson() => _$AicrFindingDtoToJson(this);
}
