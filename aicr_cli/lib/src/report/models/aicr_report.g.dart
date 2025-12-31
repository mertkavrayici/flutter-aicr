// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'aicr_report.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ToolInfoImpl _$$ToolInfoImplFromJson(Map<String, dynamic> json) =>
    _$ToolInfoImpl(
      name: json['name'] as String,
      version: json['version'] as String,
    );

Map<String, dynamic> _$$ToolInfoImplToJson(_$ToolInfoImpl instance) =>
    <String, dynamic>{'name': instance.name, 'version': instance.version};

_$RepoInfoImpl _$$RepoInfoImplFromJson(Map<String, dynamic> json) =>
    _$RepoInfoImpl(name: json['name'] as String);

Map<String, dynamic> _$$RepoInfoImplToJson(_$RepoInfoImpl instance) =>
    <String, dynamic>{'name': instance.name};

_$InputInfoImpl _$$InputInfoImplFromJson(Map<String, dynamic> json) =>
    _$InputInfoImpl(
      diffType: json['diff_type'] as String,
      diffHash: json['diff_hash'] as String,
      fileCount: (json['file_count'] as num).toInt(),
    );

Map<String, dynamic> _$$InputInfoImplToJson(_$InputInfoImpl instance) =>
    <String, dynamic>{
      'diff_type': instance.diffType,
      'diff_hash': instance.diffHash,
      'file_count': instance.fileCount,
    };

_$AiInfoImpl _$$AiInfoImplFromJson(Map<String, dynamic> json) => _$AiInfoImpl(
  enabled: json['enabled'] as bool,
  mode: json['mode'] as String? ?? 'noop',
);

Map<String, dynamic> _$$AiInfoImplToJson(_$AiInfoImpl instance) =>
    <String, dynamic>{'enabled': instance.enabled, 'mode': instance.mode};

_$CommentInfoImpl _$$CommentInfoImplFromJson(Map<String, dynamic> json) =>
    _$CommentInfoImpl(
      postComment: json['post_comment'] as bool? ?? false,
      commentMode: json['comment_mode'] as String? ?? 'update',
      marker: json['marker'] as String? ?? 'AICR_COMMENT',
    );

Map<String, dynamic> _$$CommentInfoImplToJson(_$CommentInfoImpl instance) =>
    <String, dynamic>{
      'post_comment': instance.postComment,
      'comment_mode': instance.commentMode,
      'marker': instance.marker,
    };

_$CiInfoImpl _$$CiInfoImplFromJson(Map<String, dynamic> json) => _$CiInfoImpl(
  postComment: json['post_comment'] as bool? ?? false,
  commentMode: json['comment_mode'] as String? ?? 'update',
  marker: json['marker'] as String? ?? 'AICR_COMMENT',
);

Map<String, dynamic> _$$CiInfoImplToJson(_$CiInfoImpl instance) =>
    <String, dynamic>{
      'post_comment': instance.postComment,
      'comment_mode': instance.commentMode,
      'marker': instance.marker,
    };

_$MetaImpl _$$MetaImplFromJson(Map<String, dynamic> json) => _$MetaImpl(
  tool: ToolInfo.fromJson(json['tool'] as Map<String, dynamic>),
  runId: json['run_id'] as String,
  createdAt: json['created_at'] as String,
  repo: RepoInfo.fromJson(json['repo'] as Map<String, dynamic>),
  input: InputInfo.fromJson(json['input'] as Map<String, dynamic>),
  ai: AiInfo.fromJson(json['ai'] as Map<String, dynamic>),
  comment: json['comment'] == null
      ? null
      : CommentInfo.fromJson(json['comment'] as Map<String, dynamic>),
  ci: json['ci'] == null
      ? null
      : CiInfo.fromJson(json['ci'] as Map<String, dynamic>),
);

Map<String, dynamic> _$$MetaImplToJson(_$MetaImpl instance) =>
    <String, dynamic>{
      'tool': instance.tool,
      'run_id': instance.runId,
      'created_at': instance.createdAt,
      'repo': instance.repo,
      'input': instance.input,
      'ai': instance.ai,
      'comment': instance.comment,
      'ci': instance.ci,
    };

_$CountsImpl _$$CountsImplFromJson(Map<String, dynamic> json) => _$CountsImpl(
  pass: (json['pass'] as num).toInt(),
  warn: (json['warn'] as num).toInt(),
  fail: (json['fail'] as num).toInt(),
);

Map<String, dynamic> _$$CountsImplToJson(_$CountsImpl instance) =>
    <String, dynamic>{
      'pass': instance.pass,
      'warn': instance.warn,
      'fail': instance.fail,
    };

_$FileCountsImpl _$$FileCountsImplFromJson(Map<String, dynamic> json) =>
    _$FileCountsImpl(
      info: (json['info'] as num).toInt(),
      warn: (json['warn'] as num).toInt(),
      error: (json['error'] as num).toInt(),
    );

Map<String, dynamic> _$$FileCountsImplToJson(_$FileCountsImpl instance) =>
    <String, dynamic>{
      'info': instance.info,
      'warn': instance.warn,
      'error': instance.error,
    };

_$SummaryImpl _$$SummaryImplFromJson(Map<String, dynamic> json) =>
    _$SummaryImpl(
      status: $enumDecode(_$ReportStatusEnumMap, json['status']),
      ruleResults: Counts.fromJson(
        json['rule_results'] as Map<String, dynamic>,
      ),
      contractResults: Counts.fromJson(
        json['contract_results'] as Map<String, dynamic>,
      ),
      fileFindings: FileCounts.fromJson(
        json['file_findings'] as Map<String, dynamic>,
      ),
    );

Map<String, dynamic> _$$SummaryImplToJson(_$SummaryImpl instance) =>
    <String, dynamic>{
      'status': _$ReportStatusEnumMap[instance.status]!,
      'rule_results': instance.ruleResults,
      'contract_results': instance.contractResults,
      'file_findings': instance.fileFindings,
    };

const _$ReportStatusEnumMap = {
  ReportStatus.pass: 'pass',
  ReportStatus.warn: 'warn',
  ReportStatus.fail: 'fail',
};

_$RuleResultImpl _$$RuleResultImplFromJson(Map<String, dynamic> json) =>
    _$RuleResultImpl(
      ruleId: json['rule_id'] as String,
      status: $enumDecode(_$ReportStatusEnumMap, json['status']),
      title: json['title'] as String,
      message: Map<String, String>.from(json['message'] as Map),
      evidence: (json['evidence'] as List<dynamic>)
          .map((e) => e as Map<String, dynamic>)
          .toList(),
    );

Map<String, dynamic> _$$RuleResultImplToJson(_$RuleResultImpl instance) =>
    <String, dynamic>{
      'rule_id': instance.ruleId,
      'status': _$ReportStatusEnumMap[instance.status]!,
      'title': instance.title,
      'message': instance.message,
      'evidence': instance.evidence,
    };

_$FileEntryImpl _$$FileEntryImplFromJson(Map<String, dynamic> json) =>
    _$FileEntryImpl(
      path: json['path'] as String,
      changeType: $enumDecode(_$FileChangeTypeEnumMap, json['change_type']),
    );

Map<String, dynamic> _$$FileEntryImplToJson(_$FileEntryImpl instance) =>
    <String, dynamic>{
      'path': instance.path,
      'change_type': _$FileChangeTypeEnumMap[instance.changeType]!,
    };

const _$FileChangeTypeEnumMap = {
  FileChangeType.added: 'added',
  FileChangeType.deleted: 'deleted',
  FileChangeType.modified: 'modified',
  FileChangeType.renamed: 'renamed',
};

_$AicrReportImpl _$$AicrReportImplFromJson(Map<String, dynamic> json) =>
    _$AicrReportImpl(
      meta: Meta.fromJson(json['meta'] as Map<String, dynamic>),
      summary: Summary.fromJson(json['summary'] as Map<String, dynamic>),
      rules: (json['rules'] as List<dynamic>)
          .map((e) => RuleResult.fromJson(e as Map<String, dynamic>))
          .toList(),
      findings: (json['findings'] as List<dynamic>)
          .map((e) => AicrFinding.fromJson(e as Map<String, dynamic>))
          .toList(),
      contracts: json['contracts'] as List<dynamic>? ?? const [],
      files:
          (json['files'] as List<dynamic>?)
              ?.map((e) => FileEntry.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      recommendations: json['recommendations'] as List<dynamic>? ?? const [],
      aiReview: json['ai_review'] == null
          ? null
          : AiReview.fromJson(json['ai_review'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$AicrReportImplToJson(_$AicrReportImpl instance) =>
    <String, dynamic>{
      'meta': instance.meta,
      'summary': instance.summary,
      'rules': instance.rules,
      'findings': instance.findings,
      'contracts': instance.contracts,
      'files': instance.files,
      'recommendations': instance.recommendations,
      'ai_review': instance.aiReview,
    };
