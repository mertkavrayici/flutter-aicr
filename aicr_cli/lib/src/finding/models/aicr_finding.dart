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

/// Where this finding originates from.
///
/// - `deterministic`: produced by deterministic rules/heuristics.
/// - `ai`: produced by AI review layer (best-effort, non-authoritative).
enum AicrFindingSource { deterministic, ai }

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
    AicrFindingSource? source,
    double? confidence,
    // AI finding structured fields
    String? area,
    String? risk,
    String? reason,
    String? suggestedAction,
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
      source: dto.source,
      confidence: dto.confidence,
      area: dto.area,
      risk: dto.risk,
      reason: dto.reason,
      suggestedAction: dto.suggestedAction,
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
    source: source,
    confidence: confidence,
    area: area,
    risk: risk,
    reason: reason,
    suggestedAction: suggestedAction,
  ).toJson();
}

/// Extension for stable key generation and finding matching.
extension AicrFindingExtensions on AicrFinding {
  /// Normalizes a string for comparison (lowercase, trim, remove extra spaces).
  static String _normalize(String s) {
    return s.toLowerCase().trim().replaceAll(RegExp(r'\s+'), ' ');
  }

  /// Generates a stable key for deduplication: area + normalized title.
  /// Used for "top actions" uniqueness calculation and finding matching.
  String get stableKey {
    final normalizedTitle = _normalize(title);
    final areaPart = area != null ? _normalize(area!) : '';
    return '$areaPart|$normalizedTitle';
  }

  /// Checks if two findings are similar based on area + normalized title/risk.
  /// Used for deduplication when merging AI findings with deterministic findings.
  bool isSimilarTo(AicrFinding other) {
    // Must have same area (or both null)
    if ((area == null) != (other.area == null)) return false;
    if (area != null && other.area != null) {
      if (_normalize(area!) != _normalize(other.area!)) return false;
    }

    // Check title similarity
    final thisTitle = _normalize(title);
    final otherTitle = _normalize(other.title);
    if (thisTitle == otherTitle) return true;

    // Check risk similarity if both have risk
    if (risk != null && other.risk != null) {
      final thisRisk = _normalize(risk!);
      final otherRisk = _normalize(other.risk!);
      if (thisRisk == otherRisk && thisRisk.isNotEmpty) return true;
    }

    // Check if titles are similar (contain same key words)
    final thisWords = thisTitle.split(' ').where((w) => w.length > 3).toSet();
    final otherWords = otherTitle.split(' ').where((w) => w.length > 3).toSet();
    if (thisWords.isNotEmpty && otherWords.isNotEmpty) {
      final intersection = thisWords.intersection(otherWords);
      // If more than 50% of words match, consider similar
      final similarity = intersection.length / thisWords.length;
      if (similarity > 0.5) return true;
    }

    return false;
  }
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
  final AicrFindingSource? source;
  final double? confidence;
  // AI finding structured fields
  final String? area;
  final String? risk;
  final String? reason;
  @JsonKey(name: 'suggested_action')
  final String? suggestedAction;

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
    this.source,
    this.confidence,
    this.area,
    this.risk,
    this.reason,
    this.suggestedAction,
  });

  factory AicrFindingDto.fromJson(Map<String, dynamic> json) =>
      _$AicrFindingDtoFromJson(json);

  Map<String, dynamic> toJson() => _$AicrFindingDtoToJson(this);
}
