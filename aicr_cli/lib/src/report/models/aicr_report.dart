// ignore_for_file: invalid_annotation_target

import 'package:aicr_cli/src/finding/models/aicr_finding.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../ai/ai.dart';

part 'aicr_report.freezed.dart';
part 'aicr_report.g.dart';

// Enums for stringly-typed fields
enum ReportStatus {
  @JsonValue('pass')
  pass,
  @JsonValue('warn')
  warn,
  @JsonValue('fail')
  fail,
}

enum FileChangeType {
  @JsonValue('added')
  added,
  @JsonValue('deleted')
  deleted,
  @JsonValue('modified')
  modified,
  @JsonValue('renamed')
  renamed,
}

// Nested structures for Meta JSON
@freezed
class ToolInfo with _$ToolInfo {
  const factory ToolInfo({
    @JsonKey(name: 'name') required String name,
    @JsonKey(name: 'version') required String version,
  }) = _ToolInfo;

  factory ToolInfo.fromJson(Map<String, dynamic> json) =>
      _$ToolInfoFromJson(json);
}

@freezed
class RepoInfo with _$RepoInfo {
  const factory RepoInfo({@JsonKey(name: 'name') required String name}) =
      _RepoInfo;

  factory RepoInfo.fromJson(Map<String, dynamic> json) =>
      _$RepoInfoFromJson(json);
}

@freezed
class InputInfo with _$InputInfo {
  const factory InputInfo({
    @JsonKey(name: 'diff_type') required String diffType,
    @JsonKey(name: 'diff_hash') required String diffHash,
    @JsonKey(name: 'file_count') required int fileCount,
  }) = _InputInfo;

  factory InputInfo.fromJson(Map<String, dynamic> json) =>
      _$InputInfoFromJson(json);
}

// Helper factory for InputInfo
extension InputInfoFactory on InputInfo {
  static InputInfo create({
    String? diffType,
    required String diffHash,
    required int fileCount,
  }) => InputInfo(
    diffType: diffType ?? 'git_diff',
    diffHash: diffHash,
    fileCount: fileCount,
  );
}

@freezed
class AiInfo with _$AiInfo {
  const factory AiInfo({
    @JsonKey(name: 'enabled') required bool enabled,
    @Default('noop') String mode,
  }) = _AiInfo;

  factory AiInfo.fromJson(Map<String, dynamic> json) => _$AiInfoFromJson(json);
}

@freezed
class CommentInfo with _$CommentInfo {
  const factory CommentInfo({
    @JsonKey(name: 'post_comment') @Default(false) bool postComment,
    @JsonKey(name: 'comment_mode') @Default('update') String commentMode,
    @Default('AICR_COMMENT') String marker,
  }) = _CommentInfo;

  factory CommentInfo.fromJson(Map<String, dynamic> json) =>
      _$CommentInfoFromJson(json);
}

@freezed
class CiInfo with _$CiInfo {
  const factory CiInfo({
    @JsonKey(name: 'post_comment') @Default(false) bool postComment,
    @JsonKey(name: 'comment_mode') @Default('update') String commentMode,
    @Default('AICR_COMMENT') String marker,
  }) = _CiInfo;

  factory CiInfo.fromJson(Map<String, dynamic> json) => _$CiInfoFromJson(json);
}

// Meta model
@freezed
class Meta with _$Meta {
  const factory Meta({
    @JsonKey(name: 'tool') required ToolInfo tool,
    @JsonKey(name: 'run_id') required String runId,
    @JsonKey(name: 'created_at') required String createdAt,
    @JsonKey(name: 'repo') required RepoInfo repo,
    @JsonKey(name: 'input') required InputInfo input,
    @JsonKey(name: 'ai') required AiInfo ai,
    @JsonKey(name: 'comment') CommentInfo? comment,
    @JsonKey(name: 'ci') CiInfo? ci,
  }) = _Meta;

  // Helper factory for backward compatibility with flat constructor
  factory Meta.fromFlat({
    required String toolVersion,
    required String runId,
    required String createdAt,
    required String repoName,
    required bool aiEnabled,
    String aiMode = 'noop',
    required String diffHash,
    required int fileCount,
    bool postComment = false,
    String commentMode = 'update',
    String marker = 'AICR_COMMENT',
  }) => Meta(
    tool: ToolInfo(name: 'AICR', version: toolVersion),
    runId: runId,
    createdAt: createdAt,
    repo: RepoInfo(name: repoName),
    input: InputInfoFactory.create(diffHash: diffHash, fileCount: fileCount),
    ai: AiInfo(enabled: aiEnabled, mode: aiMode),
    comment: CommentInfo(
      postComment: postComment,
      commentMode: commentMode,
      marker: marker,
    ),
    ci: CiInfo(
      postComment: postComment,
      commentMode: commentMode,
      marker: marker,
    ),
  );

  factory Meta.fromJson(Map<String, dynamic> json) => _$MetaFromJson(json);
}

// Counts models
@freezed
class Counts with _$Counts {
  const factory Counts({
    required int pass,
    required int warn,
    required int fail,
  }) = _Counts;

  factory Counts.fromJson(Map<String, dynamic> json) => _$CountsFromJson(json);
}

@freezed
class FileCounts with _$FileCounts {
  const factory FileCounts({
    required int info,
    required int warn,
    required int error,
  }) = _FileCounts;

  factory FileCounts.fromJson(Map<String, dynamic> json) =>
      _$FileCountsFromJson(json);
}

// Summary model
@freezed
class Summary with _$Summary {
  const factory Summary({
    required ReportStatus status,
    @JsonKey(name: 'rule_results') required Counts ruleResults,
    @JsonKey(name: 'contract_results') required Counts contractResults,
    @JsonKey(name: 'file_findings') required FileCounts fileFindings,
  }) = _Summary;

  // Helper factory for backward compatibility with string status
  factory Summary.fromStringStatus({
    required String status,
    required Counts ruleResults,
    required Counts contractResults,
    required FileCounts fileFindings,
  }) => Summary(
    status: _statusFromString(status),
    ruleResults: ruleResults,
    contractResults: contractResults,
    fileFindings: fileFindings,
  );

  factory Summary.fromJson(Map<String, dynamic> json) =>
      _$SummaryFromJson(json);
}

ReportStatus _statusFromString(String status) => switch (status) {
  'pass' => ReportStatus.pass,
  'warn' => ReportStatus.warn,
  'fail' => ReportStatus.fail,
  _ => ReportStatus.pass,
};

// RuleResult model - preserve factory constructors
@freezed
class RuleResult with _$RuleResult {
  const factory RuleResult({
    @JsonKey(name: 'rule_id') required String ruleId,
    required ReportStatus status,
    required String title,
    required Map<String, String> message,
    required List<Map<String, dynamic>> evidence,
  }) = _RuleResult;

  factory RuleResult.pass({
    required String ruleId,
    required String title,
    required String tr,
    required String en,
  }) => RuleResult(
    ruleId: ruleId,
    status: ReportStatus.pass,
    title: title,
    message: {'tr': tr, 'en': en},
    evidence: const [],
  );

  factory RuleResult.warn({
    required String ruleId,
    required String title,
    required String tr,
    required String en,
    List<String> evidenceFiles = const [],
  }) => RuleResult(
    ruleId: ruleId,
    status: ReportStatus.warn,
    title: title,
    message: {'tr': tr, 'en': en},
    evidence: evidenceFiles.map((f) => {'file_path': f}).toList(),
  );

  factory RuleResult.fromJson(Map<String, dynamic> json) =>
      _$RuleResultFromJson(json);
}

// FileEntry model
@freezed
class FileEntry with _$FileEntry {
  const factory FileEntry({
    required String path,
    @JsonKey(name: 'change_type') required FileChangeType changeType,
  }) = _FileEntry;

  // Helper factory for backward compatibility with string changeType
  factory FileEntry.fromStringChangeType({
    required String path,
    required String changeType,
  }) => FileEntry(path: path, changeType: _changeTypeFromString(changeType));

  factory FileEntry.fromJson(Map<String, dynamic> json) =>
      _$FileEntryFromJson(json);
}

FileChangeType _changeTypeFromString(String changeType) => switch (changeType) {
  'added' => FileChangeType.added,
  'deleted' => FileChangeType.deleted,
  'modified' => FileChangeType.modified,
  'renamed' => FileChangeType.renamed,
  _ => FileChangeType.modified,
};

// Extension for backward compatibility - flat access to Meta fields
extension MetaExtensions on Meta {
  String get toolVersion => tool.version;
  String get repoName => repo.name;
  bool get aiEnabled => ai.enabled;
  String get aiMode => ai.mode;
  String get diffHash => input.diffHash;
  int get fileCount => input.fileCount;
}

// Note: ReportStatus and FileChangeType enums use @JsonValue for JSON serialization.
// The built-in enum `.name` property is used directly (no extension needed).

// Main AicrReport model
@freezed
class AicrReport with _$AicrReport {
  const factory AicrReport({
    required Meta meta,
    required Summary summary,
    required List<RuleResult> rules,
    required List<AicrFinding> findings,
    @Default([]) List<dynamic> contracts,
    @Default([]) List<FileEntry> files,
    @Default([]) List<dynamic> recommendations,
    @JsonKey(name: 'ai_review') AiReview? aiReview,
  }) = _AicrReport;

  factory AicrReport.fromJson(Map<String, dynamic> json) =>
      _$AicrReportFromJson(json);
}
