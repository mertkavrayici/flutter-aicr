// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'aicr_report.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ToolInfo _$ToolInfoFromJson(Map<String, dynamic> json) {
  return _ToolInfo.fromJson(json);
}

/// @nodoc
mixin _$ToolInfo {
  @JsonKey(name: 'name')
  String get name => throw _privateConstructorUsedError;
  @JsonKey(name: 'version')
  String get version => throw _privateConstructorUsedError;

  /// Serializes this ToolInfo to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ToolInfo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ToolInfoCopyWith<ToolInfo> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ToolInfoCopyWith<$Res> {
  factory $ToolInfoCopyWith(ToolInfo value, $Res Function(ToolInfo) then) =
      _$ToolInfoCopyWithImpl<$Res, ToolInfo>;
  @useResult
  $Res call({
    @JsonKey(name: 'name') String name,
    @JsonKey(name: 'version') String version,
  });
}

/// @nodoc
class _$ToolInfoCopyWithImpl<$Res, $Val extends ToolInfo>
    implements $ToolInfoCopyWith<$Res> {
  _$ToolInfoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ToolInfo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? name = null, Object? version = null}) {
    return _then(
      _value.copyWith(
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            version: null == version
                ? _value.version
                : version // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ToolInfoImplCopyWith<$Res>
    implements $ToolInfoCopyWith<$Res> {
  factory _$$ToolInfoImplCopyWith(
    _$ToolInfoImpl value,
    $Res Function(_$ToolInfoImpl) then,
  ) = __$$ToolInfoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'name') String name,
    @JsonKey(name: 'version') String version,
  });
}

/// @nodoc
class __$$ToolInfoImplCopyWithImpl<$Res>
    extends _$ToolInfoCopyWithImpl<$Res, _$ToolInfoImpl>
    implements _$$ToolInfoImplCopyWith<$Res> {
  __$$ToolInfoImplCopyWithImpl(
    _$ToolInfoImpl _value,
    $Res Function(_$ToolInfoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ToolInfo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? name = null, Object? version = null}) {
    return _then(
      _$ToolInfoImpl(
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        version: null == version
            ? _value.version
            : version // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ToolInfoImpl implements _ToolInfo {
  const _$ToolInfoImpl({
    @JsonKey(name: 'name') required this.name,
    @JsonKey(name: 'version') required this.version,
  });

  factory _$ToolInfoImpl.fromJson(Map<String, dynamic> json) =>
      _$$ToolInfoImplFromJson(json);

  @override
  @JsonKey(name: 'name')
  final String name;
  @override
  @JsonKey(name: 'version')
  final String version;

  @override
  String toString() {
    return 'ToolInfo(name: $name, version: $version)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ToolInfoImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.version, version) || other.version == version));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, name, version);

  /// Create a copy of ToolInfo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ToolInfoImplCopyWith<_$ToolInfoImpl> get copyWith =>
      __$$ToolInfoImplCopyWithImpl<_$ToolInfoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ToolInfoImplToJson(this);
  }
}

abstract class _ToolInfo implements ToolInfo {
  const factory _ToolInfo({
    @JsonKey(name: 'name') required final String name,
    @JsonKey(name: 'version') required final String version,
  }) = _$ToolInfoImpl;

  factory _ToolInfo.fromJson(Map<String, dynamic> json) =
      _$ToolInfoImpl.fromJson;

  @override
  @JsonKey(name: 'name')
  String get name;
  @override
  @JsonKey(name: 'version')
  String get version;

  /// Create a copy of ToolInfo
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ToolInfoImplCopyWith<_$ToolInfoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

RepoInfo _$RepoInfoFromJson(Map<String, dynamic> json) {
  return _RepoInfo.fromJson(json);
}

/// @nodoc
mixin _$RepoInfo {
  @JsonKey(name: 'name')
  String get name => throw _privateConstructorUsedError;

  /// Serializes this RepoInfo to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of RepoInfo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RepoInfoCopyWith<RepoInfo> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RepoInfoCopyWith<$Res> {
  factory $RepoInfoCopyWith(RepoInfo value, $Res Function(RepoInfo) then) =
      _$RepoInfoCopyWithImpl<$Res, RepoInfo>;
  @useResult
  $Res call({@JsonKey(name: 'name') String name});
}

/// @nodoc
class _$RepoInfoCopyWithImpl<$Res, $Val extends RepoInfo>
    implements $RepoInfoCopyWith<$Res> {
  _$RepoInfoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RepoInfo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? name = null}) {
    return _then(
      _value.copyWith(
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$RepoInfoImplCopyWith<$Res>
    implements $RepoInfoCopyWith<$Res> {
  factory _$$RepoInfoImplCopyWith(
    _$RepoInfoImpl value,
    $Res Function(_$RepoInfoImpl) then,
  ) = __$$RepoInfoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({@JsonKey(name: 'name') String name});
}

/// @nodoc
class __$$RepoInfoImplCopyWithImpl<$Res>
    extends _$RepoInfoCopyWithImpl<$Res, _$RepoInfoImpl>
    implements _$$RepoInfoImplCopyWith<$Res> {
  __$$RepoInfoImplCopyWithImpl(
    _$RepoInfoImpl _value,
    $Res Function(_$RepoInfoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of RepoInfo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? name = null}) {
    return _then(
      _$RepoInfoImpl(
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$RepoInfoImpl implements _RepoInfo {
  const _$RepoInfoImpl({@JsonKey(name: 'name') required this.name});

  factory _$RepoInfoImpl.fromJson(Map<String, dynamic> json) =>
      _$$RepoInfoImplFromJson(json);

  @override
  @JsonKey(name: 'name')
  final String name;

  @override
  String toString() {
    return 'RepoInfo(name: $name)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RepoInfoImpl &&
            (identical(other.name, name) || other.name == name));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, name);

  /// Create a copy of RepoInfo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RepoInfoImplCopyWith<_$RepoInfoImpl> get copyWith =>
      __$$RepoInfoImplCopyWithImpl<_$RepoInfoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RepoInfoImplToJson(this);
  }
}

abstract class _RepoInfo implements RepoInfo {
  const factory _RepoInfo({@JsonKey(name: 'name') required final String name}) =
      _$RepoInfoImpl;

  factory _RepoInfo.fromJson(Map<String, dynamic> json) =
      _$RepoInfoImpl.fromJson;

  @override
  @JsonKey(name: 'name')
  String get name;

  /// Create a copy of RepoInfo
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RepoInfoImplCopyWith<_$RepoInfoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

InputInfo _$InputInfoFromJson(Map<String, dynamic> json) {
  return _InputInfo.fromJson(json);
}

/// @nodoc
mixin _$InputInfo {
  @JsonKey(name: 'diff_type')
  String get diffType => throw _privateConstructorUsedError;
  @JsonKey(name: 'diff_hash')
  String get diffHash => throw _privateConstructorUsedError;
  @JsonKey(name: 'file_count')
  int get fileCount => throw _privateConstructorUsedError;

  /// Serializes this InputInfo to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of InputInfo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $InputInfoCopyWith<InputInfo> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $InputInfoCopyWith<$Res> {
  factory $InputInfoCopyWith(InputInfo value, $Res Function(InputInfo) then) =
      _$InputInfoCopyWithImpl<$Res, InputInfo>;
  @useResult
  $Res call({
    @JsonKey(name: 'diff_type') String diffType,
    @JsonKey(name: 'diff_hash') String diffHash,
    @JsonKey(name: 'file_count') int fileCount,
  });
}

/// @nodoc
class _$InputInfoCopyWithImpl<$Res, $Val extends InputInfo>
    implements $InputInfoCopyWith<$Res> {
  _$InputInfoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of InputInfo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? diffType = null,
    Object? diffHash = null,
    Object? fileCount = null,
  }) {
    return _then(
      _value.copyWith(
            diffType: null == diffType
                ? _value.diffType
                : diffType // ignore: cast_nullable_to_non_nullable
                      as String,
            diffHash: null == diffHash
                ? _value.diffHash
                : diffHash // ignore: cast_nullable_to_non_nullable
                      as String,
            fileCount: null == fileCount
                ? _value.fileCount
                : fileCount // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$InputInfoImplCopyWith<$Res>
    implements $InputInfoCopyWith<$Res> {
  factory _$$InputInfoImplCopyWith(
    _$InputInfoImpl value,
    $Res Function(_$InputInfoImpl) then,
  ) = __$$InputInfoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'diff_type') String diffType,
    @JsonKey(name: 'diff_hash') String diffHash,
    @JsonKey(name: 'file_count') int fileCount,
  });
}

/// @nodoc
class __$$InputInfoImplCopyWithImpl<$Res>
    extends _$InputInfoCopyWithImpl<$Res, _$InputInfoImpl>
    implements _$$InputInfoImplCopyWith<$Res> {
  __$$InputInfoImplCopyWithImpl(
    _$InputInfoImpl _value,
    $Res Function(_$InputInfoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of InputInfo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? diffType = null,
    Object? diffHash = null,
    Object? fileCount = null,
  }) {
    return _then(
      _$InputInfoImpl(
        diffType: null == diffType
            ? _value.diffType
            : diffType // ignore: cast_nullable_to_non_nullable
                  as String,
        diffHash: null == diffHash
            ? _value.diffHash
            : diffHash // ignore: cast_nullable_to_non_nullable
                  as String,
        fileCount: null == fileCount
            ? _value.fileCount
            : fileCount // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$InputInfoImpl implements _InputInfo {
  const _$InputInfoImpl({
    @JsonKey(name: 'diff_type') required this.diffType,
    @JsonKey(name: 'diff_hash') required this.diffHash,
    @JsonKey(name: 'file_count') required this.fileCount,
  });

  factory _$InputInfoImpl.fromJson(Map<String, dynamic> json) =>
      _$$InputInfoImplFromJson(json);

  @override
  @JsonKey(name: 'diff_type')
  final String diffType;
  @override
  @JsonKey(name: 'diff_hash')
  final String diffHash;
  @override
  @JsonKey(name: 'file_count')
  final int fileCount;

  @override
  String toString() {
    return 'InputInfo(diffType: $diffType, diffHash: $diffHash, fileCount: $fileCount)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$InputInfoImpl &&
            (identical(other.diffType, diffType) ||
                other.diffType == diffType) &&
            (identical(other.diffHash, diffHash) ||
                other.diffHash == diffHash) &&
            (identical(other.fileCount, fileCount) ||
                other.fileCount == fileCount));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, diffType, diffHash, fileCount);

  /// Create a copy of InputInfo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$InputInfoImplCopyWith<_$InputInfoImpl> get copyWith =>
      __$$InputInfoImplCopyWithImpl<_$InputInfoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$InputInfoImplToJson(this);
  }
}

abstract class _InputInfo implements InputInfo {
  const factory _InputInfo({
    @JsonKey(name: 'diff_type') required final String diffType,
    @JsonKey(name: 'diff_hash') required final String diffHash,
    @JsonKey(name: 'file_count') required final int fileCount,
  }) = _$InputInfoImpl;

  factory _InputInfo.fromJson(Map<String, dynamic> json) =
      _$InputInfoImpl.fromJson;

  @override
  @JsonKey(name: 'diff_type')
  String get diffType;
  @override
  @JsonKey(name: 'diff_hash')
  String get diffHash;
  @override
  @JsonKey(name: 'file_count')
  int get fileCount;

  /// Create a copy of InputInfo
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$InputInfoImplCopyWith<_$InputInfoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

AiInfo _$AiInfoFromJson(Map<String, dynamic> json) {
  return _AiInfo.fromJson(json);
}

/// @nodoc
mixin _$AiInfo {
  @JsonKey(name: 'enabled')
  bool get enabled => throw _privateConstructorUsedError;

  /// Serializes this AiInfo to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AiInfo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AiInfoCopyWith<AiInfo> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AiInfoCopyWith<$Res> {
  factory $AiInfoCopyWith(AiInfo value, $Res Function(AiInfo) then) =
      _$AiInfoCopyWithImpl<$Res, AiInfo>;
  @useResult
  $Res call({@JsonKey(name: 'enabled') bool enabled});
}

/// @nodoc
class _$AiInfoCopyWithImpl<$Res, $Val extends AiInfo>
    implements $AiInfoCopyWith<$Res> {
  _$AiInfoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AiInfo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? enabled = null}) {
    return _then(
      _value.copyWith(
            enabled: null == enabled
                ? _value.enabled
                : enabled // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$AiInfoImplCopyWith<$Res> implements $AiInfoCopyWith<$Res> {
  factory _$$AiInfoImplCopyWith(
    _$AiInfoImpl value,
    $Res Function(_$AiInfoImpl) then,
  ) = __$$AiInfoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({@JsonKey(name: 'enabled') bool enabled});
}

/// @nodoc
class __$$AiInfoImplCopyWithImpl<$Res>
    extends _$AiInfoCopyWithImpl<$Res, _$AiInfoImpl>
    implements _$$AiInfoImplCopyWith<$Res> {
  __$$AiInfoImplCopyWithImpl(
    _$AiInfoImpl _value,
    $Res Function(_$AiInfoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AiInfo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? enabled = null}) {
    return _then(
      _$AiInfoImpl(
        enabled: null == enabled
            ? _value.enabled
            : enabled // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$AiInfoImpl implements _AiInfo {
  const _$AiInfoImpl({@JsonKey(name: 'enabled') required this.enabled});

  factory _$AiInfoImpl.fromJson(Map<String, dynamic> json) =>
      _$$AiInfoImplFromJson(json);

  @override
  @JsonKey(name: 'enabled')
  final bool enabled;

  @override
  String toString() {
    return 'AiInfo(enabled: $enabled)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AiInfoImpl &&
            (identical(other.enabled, enabled) || other.enabled == enabled));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, enabled);

  /// Create a copy of AiInfo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AiInfoImplCopyWith<_$AiInfoImpl> get copyWith =>
      __$$AiInfoImplCopyWithImpl<_$AiInfoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AiInfoImplToJson(this);
  }
}

abstract class _AiInfo implements AiInfo {
  const factory _AiInfo({
    @JsonKey(name: 'enabled') required final bool enabled,
  }) = _$AiInfoImpl;

  factory _AiInfo.fromJson(Map<String, dynamic> json) = _$AiInfoImpl.fromJson;

  @override
  @JsonKey(name: 'enabled')
  bool get enabled;

  /// Create a copy of AiInfo
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AiInfoImplCopyWith<_$AiInfoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Meta _$MetaFromJson(Map<String, dynamic> json) {
  return _Meta.fromJson(json);
}

/// @nodoc
mixin _$Meta {
  @JsonKey(name: 'tool')
  ToolInfo get tool => throw _privateConstructorUsedError;
  @JsonKey(name: 'run_id')
  String get runId => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  String get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'repo')
  RepoInfo get repo => throw _privateConstructorUsedError;
  @JsonKey(name: 'input')
  InputInfo get input => throw _privateConstructorUsedError;
  @JsonKey(name: 'ai')
  AiInfo get ai => throw _privateConstructorUsedError;

  /// Serializes this Meta to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Meta
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MetaCopyWith<Meta> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MetaCopyWith<$Res> {
  factory $MetaCopyWith(Meta value, $Res Function(Meta) then) =
      _$MetaCopyWithImpl<$Res, Meta>;
  @useResult
  $Res call({
    @JsonKey(name: 'tool') ToolInfo tool,
    @JsonKey(name: 'run_id') String runId,
    @JsonKey(name: 'created_at') String createdAt,
    @JsonKey(name: 'repo') RepoInfo repo,
    @JsonKey(name: 'input') InputInfo input,
    @JsonKey(name: 'ai') AiInfo ai,
  });

  $ToolInfoCopyWith<$Res> get tool;
  $RepoInfoCopyWith<$Res> get repo;
  $InputInfoCopyWith<$Res> get input;
  $AiInfoCopyWith<$Res> get ai;
}

/// @nodoc
class _$MetaCopyWithImpl<$Res, $Val extends Meta>
    implements $MetaCopyWith<$Res> {
  _$MetaCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Meta
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? tool = null,
    Object? runId = null,
    Object? createdAt = null,
    Object? repo = null,
    Object? input = null,
    Object? ai = null,
  }) {
    return _then(
      _value.copyWith(
            tool: null == tool
                ? _value.tool
                : tool // ignore: cast_nullable_to_non_nullable
                      as ToolInfo,
            runId: null == runId
                ? _value.runId
                : runId // ignore: cast_nullable_to_non_nullable
                      as String,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as String,
            repo: null == repo
                ? _value.repo
                : repo // ignore: cast_nullable_to_non_nullable
                      as RepoInfo,
            input: null == input
                ? _value.input
                : input // ignore: cast_nullable_to_non_nullable
                      as InputInfo,
            ai: null == ai
                ? _value.ai
                : ai // ignore: cast_nullable_to_non_nullable
                      as AiInfo,
          )
          as $Val,
    );
  }

  /// Create a copy of Meta
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ToolInfoCopyWith<$Res> get tool {
    return $ToolInfoCopyWith<$Res>(_value.tool, (value) {
      return _then(_value.copyWith(tool: value) as $Val);
    });
  }

  /// Create a copy of Meta
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $RepoInfoCopyWith<$Res> get repo {
    return $RepoInfoCopyWith<$Res>(_value.repo, (value) {
      return _then(_value.copyWith(repo: value) as $Val);
    });
  }

  /// Create a copy of Meta
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $InputInfoCopyWith<$Res> get input {
    return $InputInfoCopyWith<$Res>(_value.input, (value) {
      return _then(_value.copyWith(input: value) as $Val);
    });
  }

  /// Create a copy of Meta
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $AiInfoCopyWith<$Res> get ai {
    return $AiInfoCopyWith<$Res>(_value.ai, (value) {
      return _then(_value.copyWith(ai: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$MetaImplCopyWith<$Res> implements $MetaCopyWith<$Res> {
  factory _$$MetaImplCopyWith(
    _$MetaImpl value,
    $Res Function(_$MetaImpl) then,
  ) = __$$MetaImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'tool') ToolInfo tool,
    @JsonKey(name: 'run_id') String runId,
    @JsonKey(name: 'created_at') String createdAt,
    @JsonKey(name: 'repo') RepoInfo repo,
    @JsonKey(name: 'input') InputInfo input,
    @JsonKey(name: 'ai') AiInfo ai,
  });

  @override
  $ToolInfoCopyWith<$Res> get tool;
  @override
  $RepoInfoCopyWith<$Res> get repo;
  @override
  $InputInfoCopyWith<$Res> get input;
  @override
  $AiInfoCopyWith<$Res> get ai;
}

/// @nodoc
class __$$MetaImplCopyWithImpl<$Res>
    extends _$MetaCopyWithImpl<$Res, _$MetaImpl>
    implements _$$MetaImplCopyWith<$Res> {
  __$$MetaImplCopyWithImpl(_$MetaImpl _value, $Res Function(_$MetaImpl) _then)
    : super(_value, _then);

  /// Create a copy of Meta
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? tool = null,
    Object? runId = null,
    Object? createdAt = null,
    Object? repo = null,
    Object? input = null,
    Object? ai = null,
  }) {
    return _then(
      _$MetaImpl(
        tool: null == tool
            ? _value.tool
            : tool // ignore: cast_nullable_to_non_nullable
                  as ToolInfo,
        runId: null == runId
            ? _value.runId
            : runId // ignore: cast_nullable_to_non_nullable
                  as String,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as String,
        repo: null == repo
            ? _value.repo
            : repo // ignore: cast_nullable_to_non_nullable
                  as RepoInfo,
        input: null == input
            ? _value.input
            : input // ignore: cast_nullable_to_non_nullable
                  as InputInfo,
        ai: null == ai
            ? _value.ai
            : ai // ignore: cast_nullable_to_non_nullable
                  as AiInfo,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$MetaImpl implements _Meta {
  const _$MetaImpl({
    @JsonKey(name: 'tool') required this.tool,
    @JsonKey(name: 'run_id') required this.runId,
    @JsonKey(name: 'created_at') required this.createdAt,
    @JsonKey(name: 'repo') required this.repo,
    @JsonKey(name: 'input') required this.input,
    @JsonKey(name: 'ai') required this.ai,
  });

  factory _$MetaImpl.fromJson(Map<String, dynamic> json) =>
      _$$MetaImplFromJson(json);

  @override
  @JsonKey(name: 'tool')
  final ToolInfo tool;
  @override
  @JsonKey(name: 'run_id')
  final String runId;
  @override
  @JsonKey(name: 'created_at')
  final String createdAt;
  @override
  @JsonKey(name: 'repo')
  final RepoInfo repo;
  @override
  @JsonKey(name: 'input')
  final InputInfo input;
  @override
  @JsonKey(name: 'ai')
  final AiInfo ai;

  @override
  String toString() {
    return 'Meta(tool: $tool, runId: $runId, createdAt: $createdAt, repo: $repo, input: $input, ai: $ai)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MetaImpl &&
            (identical(other.tool, tool) || other.tool == tool) &&
            (identical(other.runId, runId) || other.runId == runId) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.repo, repo) || other.repo == repo) &&
            (identical(other.input, input) || other.input == input) &&
            (identical(other.ai, ai) || other.ai == ai));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, tool, runId, createdAt, repo, input, ai);

  /// Create a copy of Meta
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MetaImplCopyWith<_$MetaImpl> get copyWith =>
      __$$MetaImplCopyWithImpl<_$MetaImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MetaImplToJson(this);
  }
}

abstract class _Meta implements Meta {
  const factory _Meta({
    @JsonKey(name: 'tool') required final ToolInfo tool,
    @JsonKey(name: 'run_id') required final String runId,
    @JsonKey(name: 'created_at') required final String createdAt,
    @JsonKey(name: 'repo') required final RepoInfo repo,
    @JsonKey(name: 'input') required final InputInfo input,
    @JsonKey(name: 'ai') required final AiInfo ai,
  }) = _$MetaImpl;

  factory _Meta.fromJson(Map<String, dynamic> json) = _$MetaImpl.fromJson;

  @override
  @JsonKey(name: 'tool')
  ToolInfo get tool;
  @override
  @JsonKey(name: 'run_id')
  String get runId;
  @override
  @JsonKey(name: 'created_at')
  String get createdAt;
  @override
  @JsonKey(name: 'repo')
  RepoInfo get repo;
  @override
  @JsonKey(name: 'input')
  InputInfo get input;
  @override
  @JsonKey(name: 'ai')
  AiInfo get ai;

  /// Create a copy of Meta
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MetaImplCopyWith<_$MetaImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Counts _$CountsFromJson(Map<String, dynamic> json) {
  return _Counts.fromJson(json);
}

/// @nodoc
mixin _$Counts {
  int get pass => throw _privateConstructorUsedError;
  int get warn => throw _privateConstructorUsedError;
  int get fail => throw _privateConstructorUsedError;

  /// Serializes this Counts to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Counts
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CountsCopyWith<Counts> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CountsCopyWith<$Res> {
  factory $CountsCopyWith(Counts value, $Res Function(Counts) then) =
      _$CountsCopyWithImpl<$Res, Counts>;
  @useResult
  $Res call({int pass, int warn, int fail});
}

/// @nodoc
class _$CountsCopyWithImpl<$Res, $Val extends Counts>
    implements $CountsCopyWith<$Res> {
  _$CountsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Counts
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? pass = null, Object? warn = null, Object? fail = null}) {
    return _then(
      _value.copyWith(
            pass: null == pass
                ? _value.pass
                : pass // ignore: cast_nullable_to_non_nullable
                      as int,
            warn: null == warn
                ? _value.warn
                : warn // ignore: cast_nullable_to_non_nullable
                      as int,
            fail: null == fail
                ? _value.fail
                : fail // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CountsImplCopyWith<$Res> implements $CountsCopyWith<$Res> {
  factory _$$CountsImplCopyWith(
    _$CountsImpl value,
    $Res Function(_$CountsImpl) then,
  ) = __$$CountsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int pass, int warn, int fail});
}

/// @nodoc
class __$$CountsImplCopyWithImpl<$Res>
    extends _$CountsCopyWithImpl<$Res, _$CountsImpl>
    implements _$$CountsImplCopyWith<$Res> {
  __$$CountsImplCopyWithImpl(
    _$CountsImpl _value,
    $Res Function(_$CountsImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Counts
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? pass = null, Object? warn = null, Object? fail = null}) {
    return _then(
      _$CountsImpl(
        pass: null == pass
            ? _value.pass
            : pass // ignore: cast_nullable_to_non_nullable
                  as int,
        warn: null == warn
            ? _value.warn
            : warn // ignore: cast_nullable_to_non_nullable
                  as int,
        fail: null == fail
            ? _value.fail
            : fail // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CountsImpl implements _Counts {
  const _$CountsImpl({
    required this.pass,
    required this.warn,
    required this.fail,
  });

  factory _$CountsImpl.fromJson(Map<String, dynamic> json) =>
      _$$CountsImplFromJson(json);

  @override
  final int pass;
  @override
  final int warn;
  @override
  final int fail;

  @override
  String toString() {
    return 'Counts(pass: $pass, warn: $warn, fail: $fail)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CountsImpl &&
            (identical(other.pass, pass) || other.pass == pass) &&
            (identical(other.warn, warn) || other.warn == warn) &&
            (identical(other.fail, fail) || other.fail == fail));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, pass, warn, fail);

  /// Create a copy of Counts
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CountsImplCopyWith<_$CountsImpl> get copyWith =>
      __$$CountsImplCopyWithImpl<_$CountsImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CountsImplToJson(this);
  }
}

abstract class _Counts implements Counts {
  const factory _Counts({
    required final int pass,
    required final int warn,
    required final int fail,
  }) = _$CountsImpl;

  factory _Counts.fromJson(Map<String, dynamic> json) = _$CountsImpl.fromJson;

  @override
  int get pass;
  @override
  int get warn;
  @override
  int get fail;

  /// Create a copy of Counts
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CountsImplCopyWith<_$CountsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

FileCounts _$FileCountsFromJson(Map<String, dynamic> json) {
  return _FileCounts.fromJson(json);
}

/// @nodoc
mixin _$FileCounts {
  int get info => throw _privateConstructorUsedError;
  int get warn => throw _privateConstructorUsedError;
  int get error => throw _privateConstructorUsedError;

  /// Serializes this FileCounts to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of FileCounts
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FileCountsCopyWith<FileCounts> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FileCountsCopyWith<$Res> {
  factory $FileCountsCopyWith(
    FileCounts value,
    $Res Function(FileCounts) then,
  ) = _$FileCountsCopyWithImpl<$Res, FileCounts>;
  @useResult
  $Res call({int info, int warn, int error});
}

/// @nodoc
class _$FileCountsCopyWithImpl<$Res, $Val extends FileCounts>
    implements $FileCountsCopyWith<$Res> {
  _$FileCountsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FileCounts
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? info = null, Object? warn = null, Object? error = null}) {
    return _then(
      _value.copyWith(
            info: null == info
                ? _value.info
                : info // ignore: cast_nullable_to_non_nullable
                      as int,
            warn: null == warn
                ? _value.warn
                : warn // ignore: cast_nullable_to_non_nullable
                      as int,
            error: null == error
                ? _value.error
                : error // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$FileCountsImplCopyWith<$Res>
    implements $FileCountsCopyWith<$Res> {
  factory _$$FileCountsImplCopyWith(
    _$FileCountsImpl value,
    $Res Function(_$FileCountsImpl) then,
  ) = __$$FileCountsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int info, int warn, int error});
}

/// @nodoc
class __$$FileCountsImplCopyWithImpl<$Res>
    extends _$FileCountsCopyWithImpl<$Res, _$FileCountsImpl>
    implements _$$FileCountsImplCopyWith<$Res> {
  __$$FileCountsImplCopyWithImpl(
    _$FileCountsImpl _value,
    $Res Function(_$FileCountsImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of FileCounts
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? info = null, Object? warn = null, Object? error = null}) {
    return _then(
      _$FileCountsImpl(
        info: null == info
            ? _value.info
            : info // ignore: cast_nullable_to_non_nullable
                  as int,
        warn: null == warn
            ? _value.warn
            : warn // ignore: cast_nullable_to_non_nullable
                  as int,
        error: null == error
            ? _value.error
            : error // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$FileCountsImpl implements _FileCounts {
  const _$FileCountsImpl({
    required this.info,
    required this.warn,
    required this.error,
  });

  factory _$FileCountsImpl.fromJson(Map<String, dynamic> json) =>
      _$$FileCountsImplFromJson(json);

  @override
  final int info;
  @override
  final int warn;
  @override
  final int error;

  @override
  String toString() {
    return 'FileCounts(info: $info, warn: $warn, error: $error)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FileCountsImpl &&
            (identical(other.info, info) || other.info == info) &&
            (identical(other.warn, warn) || other.warn == warn) &&
            (identical(other.error, error) || other.error == error));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, info, warn, error);

  /// Create a copy of FileCounts
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FileCountsImplCopyWith<_$FileCountsImpl> get copyWith =>
      __$$FileCountsImplCopyWithImpl<_$FileCountsImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$FileCountsImplToJson(this);
  }
}

abstract class _FileCounts implements FileCounts {
  const factory _FileCounts({
    required final int info,
    required final int warn,
    required final int error,
  }) = _$FileCountsImpl;

  factory _FileCounts.fromJson(Map<String, dynamic> json) =
      _$FileCountsImpl.fromJson;

  @override
  int get info;
  @override
  int get warn;
  @override
  int get error;

  /// Create a copy of FileCounts
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FileCountsImplCopyWith<_$FileCountsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Summary _$SummaryFromJson(Map<String, dynamic> json) {
  return _Summary.fromJson(json);
}

/// @nodoc
mixin _$Summary {
  ReportStatus get status => throw _privateConstructorUsedError;
  @JsonKey(name: 'rule_results')
  Counts get ruleResults => throw _privateConstructorUsedError;
  @JsonKey(name: 'contract_results')
  Counts get contractResults => throw _privateConstructorUsedError;
  @JsonKey(name: 'file_findings')
  FileCounts get fileFindings => throw _privateConstructorUsedError;

  /// Serializes this Summary to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Summary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SummaryCopyWith<Summary> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SummaryCopyWith<$Res> {
  factory $SummaryCopyWith(Summary value, $Res Function(Summary) then) =
      _$SummaryCopyWithImpl<$Res, Summary>;
  @useResult
  $Res call({
    ReportStatus status,
    @JsonKey(name: 'rule_results') Counts ruleResults,
    @JsonKey(name: 'contract_results') Counts contractResults,
    @JsonKey(name: 'file_findings') FileCounts fileFindings,
  });

  $CountsCopyWith<$Res> get ruleResults;
  $CountsCopyWith<$Res> get contractResults;
  $FileCountsCopyWith<$Res> get fileFindings;
}

/// @nodoc
class _$SummaryCopyWithImpl<$Res, $Val extends Summary>
    implements $SummaryCopyWith<$Res> {
  _$SummaryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Summary
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? status = null,
    Object? ruleResults = null,
    Object? contractResults = null,
    Object? fileFindings = null,
  }) {
    return _then(
      _value.copyWith(
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as ReportStatus,
            ruleResults: null == ruleResults
                ? _value.ruleResults
                : ruleResults // ignore: cast_nullable_to_non_nullable
                      as Counts,
            contractResults: null == contractResults
                ? _value.contractResults
                : contractResults // ignore: cast_nullable_to_non_nullable
                      as Counts,
            fileFindings: null == fileFindings
                ? _value.fileFindings
                : fileFindings // ignore: cast_nullable_to_non_nullable
                      as FileCounts,
          )
          as $Val,
    );
  }

  /// Create a copy of Summary
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $CountsCopyWith<$Res> get ruleResults {
    return $CountsCopyWith<$Res>(_value.ruleResults, (value) {
      return _then(_value.copyWith(ruleResults: value) as $Val);
    });
  }

  /// Create a copy of Summary
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $CountsCopyWith<$Res> get contractResults {
    return $CountsCopyWith<$Res>(_value.contractResults, (value) {
      return _then(_value.copyWith(contractResults: value) as $Val);
    });
  }

  /// Create a copy of Summary
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $FileCountsCopyWith<$Res> get fileFindings {
    return $FileCountsCopyWith<$Res>(_value.fileFindings, (value) {
      return _then(_value.copyWith(fileFindings: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$SummaryImplCopyWith<$Res> implements $SummaryCopyWith<$Res> {
  factory _$$SummaryImplCopyWith(
    _$SummaryImpl value,
    $Res Function(_$SummaryImpl) then,
  ) = __$$SummaryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    ReportStatus status,
    @JsonKey(name: 'rule_results') Counts ruleResults,
    @JsonKey(name: 'contract_results') Counts contractResults,
    @JsonKey(name: 'file_findings') FileCounts fileFindings,
  });

  @override
  $CountsCopyWith<$Res> get ruleResults;
  @override
  $CountsCopyWith<$Res> get contractResults;
  @override
  $FileCountsCopyWith<$Res> get fileFindings;
}

/// @nodoc
class __$$SummaryImplCopyWithImpl<$Res>
    extends _$SummaryCopyWithImpl<$Res, _$SummaryImpl>
    implements _$$SummaryImplCopyWith<$Res> {
  __$$SummaryImplCopyWithImpl(
    _$SummaryImpl _value,
    $Res Function(_$SummaryImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Summary
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? status = null,
    Object? ruleResults = null,
    Object? contractResults = null,
    Object? fileFindings = null,
  }) {
    return _then(
      _$SummaryImpl(
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as ReportStatus,
        ruleResults: null == ruleResults
            ? _value.ruleResults
            : ruleResults // ignore: cast_nullable_to_non_nullable
                  as Counts,
        contractResults: null == contractResults
            ? _value.contractResults
            : contractResults // ignore: cast_nullable_to_non_nullable
                  as Counts,
        fileFindings: null == fileFindings
            ? _value.fileFindings
            : fileFindings // ignore: cast_nullable_to_non_nullable
                  as FileCounts,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SummaryImpl implements _Summary {
  const _$SummaryImpl({
    required this.status,
    @JsonKey(name: 'rule_results') required this.ruleResults,
    @JsonKey(name: 'contract_results') required this.contractResults,
    @JsonKey(name: 'file_findings') required this.fileFindings,
  });

  factory _$SummaryImpl.fromJson(Map<String, dynamic> json) =>
      _$$SummaryImplFromJson(json);

  @override
  final ReportStatus status;
  @override
  @JsonKey(name: 'rule_results')
  final Counts ruleResults;
  @override
  @JsonKey(name: 'contract_results')
  final Counts contractResults;
  @override
  @JsonKey(name: 'file_findings')
  final FileCounts fileFindings;

  @override
  String toString() {
    return 'Summary(status: $status, ruleResults: $ruleResults, contractResults: $contractResults, fileFindings: $fileFindings)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SummaryImpl &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.ruleResults, ruleResults) ||
                other.ruleResults == ruleResults) &&
            (identical(other.contractResults, contractResults) ||
                other.contractResults == contractResults) &&
            (identical(other.fileFindings, fileFindings) ||
                other.fileFindings == fileFindings));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    status,
    ruleResults,
    contractResults,
    fileFindings,
  );

  /// Create a copy of Summary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SummaryImplCopyWith<_$SummaryImpl> get copyWith =>
      __$$SummaryImplCopyWithImpl<_$SummaryImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SummaryImplToJson(this);
  }
}

abstract class _Summary implements Summary {
  const factory _Summary({
    required final ReportStatus status,
    @JsonKey(name: 'rule_results') required final Counts ruleResults,
    @JsonKey(name: 'contract_results') required final Counts contractResults,
    @JsonKey(name: 'file_findings') required final FileCounts fileFindings,
  }) = _$SummaryImpl;

  factory _Summary.fromJson(Map<String, dynamic> json) = _$SummaryImpl.fromJson;

  @override
  ReportStatus get status;
  @override
  @JsonKey(name: 'rule_results')
  Counts get ruleResults;
  @override
  @JsonKey(name: 'contract_results')
  Counts get contractResults;
  @override
  @JsonKey(name: 'file_findings')
  FileCounts get fileFindings;

  /// Create a copy of Summary
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SummaryImplCopyWith<_$SummaryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

RuleResult _$RuleResultFromJson(Map<String, dynamic> json) {
  return _RuleResult.fromJson(json);
}

/// @nodoc
mixin _$RuleResult {
  @JsonKey(name: 'rule_id')
  String get ruleId => throw _privateConstructorUsedError;
  ReportStatus get status => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  Map<String, String> get message => throw _privateConstructorUsedError;
  List<Map<String, dynamic>> get evidence => throw _privateConstructorUsedError;

  /// Serializes this RuleResult to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of RuleResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RuleResultCopyWith<RuleResult> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RuleResultCopyWith<$Res> {
  factory $RuleResultCopyWith(
    RuleResult value,
    $Res Function(RuleResult) then,
  ) = _$RuleResultCopyWithImpl<$Res, RuleResult>;
  @useResult
  $Res call({
    @JsonKey(name: 'rule_id') String ruleId,
    ReportStatus status,
    String title,
    Map<String, String> message,
    List<Map<String, dynamic>> evidence,
  });
}

/// @nodoc
class _$RuleResultCopyWithImpl<$Res, $Val extends RuleResult>
    implements $RuleResultCopyWith<$Res> {
  _$RuleResultCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RuleResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? ruleId = null,
    Object? status = null,
    Object? title = null,
    Object? message = null,
    Object? evidence = null,
  }) {
    return _then(
      _value.copyWith(
            ruleId: null == ruleId
                ? _value.ruleId
                : ruleId // ignore: cast_nullable_to_non_nullable
                      as String,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as ReportStatus,
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            message: null == message
                ? _value.message
                : message // ignore: cast_nullable_to_non_nullable
                      as Map<String, String>,
            evidence: null == evidence
                ? _value.evidence
                : evidence // ignore: cast_nullable_to_non_nullable
                      as List<Map<String, dynamic>>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$RuleResultImplCopyWith<$Res>
    implements $RuleResultCopyWith<$Res> {
  factory _$$RuleResultImplCopyWith(
    _$RuleResultImpl value,
    $Res Function(_$RuleResultImpl) then,
  ) = __$$RuleResultImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'rule_id') String ruleId,
    ReportStatus status,
    String title,
    Map<String, String> message,
    List<Map<String, dynamic>> evidence,
  });
}

/// @nodoc
class __$$RuleResultImplCopyWithImpl<$Res>
    extends _$RuleResultCopyWithImpl<$Res, _$RuleResultImpl>
    implements _$$RuleResultImplCopyWith<$Res> {
  __$$RuleResultImplCopyWithImpl(
    _$RuleResultImpl _value,
    $Res Function(_$RuleResultImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of RuleResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? ruleId = null,
    Object? status = null,
    Object? title = null,
    Object? message = null,
    Object? evidence = null,
  }) {
    return _then(
      _$RuleResultImpl(
        ruleId: null == ruleId
            ? _value.ruleId
            : ruleId // ignore: cast_nullable_to_non_nullable
                  as String,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as ReportStatus,
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        message: null == message
            ? _value._message
            : message // ignore: cast_nullable_to_non_nullable
                  as Map<String, String>,
        evidence: null == evidence
            ? _value._evidence
            : evidence // ignore: cast_nullable_to_non_nullable
                  as List<Map<String, dynamic>>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$RuleResultImpl implements _RuleResult {
  const _$RuleResultImpl({
    @JsonKey(name: 'rule_id') required this.ruleId,
    required this.status,
    required this.title,
    required final Map<String, String> message,
    required final List<Map<String, dynamic>> evidence,
  }) : _message = message,
       _evidence = evidence;

  factory _$RuleResultImpl.fromJson(Map<String, dynamic> json) =>
      _$$RuleResultImplFromJson(json);

  @override
  @JsonKey(name: 'rule_id')
  final String ruleId;
  @override
  final ReportStatus status;
  @override
  final String title;
  final Map<String, String> _message;
  @override
  Map<String, String> get message {
    if (_message is EqualUnmodifiableMapView) return _message;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_message);
  }

  final List<Map<String, dynamic>> _evidence;
  @override
  List<Map<String, dynamic>> get evidence {
    if (_evidence is EqualUnmodifiableListView) return _evidence;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_evidence);
  }

  @override
  String toString() {
    return 'RuleResult(ruleId: $ruleId, status: $status, title: $title, message: $message, evidence: $evidence)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RuleResultImpl &&
            (identical(other.ruleId, ruleId) || other.ruleId == ruleId) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.title, title) || other.title == title) &&
            const DeepCollectionEquality().equals(other._message, _message) &&
            const DeepCollectionEquality().equals(other._evidence, _evidence));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    ruleId,
    status,
    title,
    const DeepCollectionEquality().hash(_message),
    const DeepCollectionEquality().hash(_evidence),
  );

  /// Create a copy of RuleResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RuleResultImplCopyWith<_$RuleResultImpl> get copyWith =>
      __$$RuleResultImplCopyWithImpl<_$RuleResultImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RuleResultImplToJson(this);
  }
}

abstract class _RuleResult implements RuleResult {
  const factory _RuleResult({
    @JsonKey(name: 'rule_id') required final String ruleId,
    required final ReportStatus status,
    required final String title,
    required final Map<String, String> message,
    required final List<Map<String, dynamic>> evidence,
  }) = _$RuleResultImpl;

  factory _RuleResult.fromJson(Map<String, dynamic> json) =
      _$RuleResultImpl.fromJson;

  @override
  @JsonKey(name: 'rule_id')
  String get ruleId;
  @override
  ReportStatus get status;
  @override
  String get title;
  @override
  Map<String, String> get message;
  @override
  List<Map<String, dynamic>> get evidence;

  /// Create a copy of RuleResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RuleResultImplCopyWith<_$RuleResultImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

FileEntry _$FileEntryFromJson(Map<String, dynamic> json) {
  return _FileEntry.fromJson(json);
}

/// @nodoc
mixin _$FileEntry {
  String get path => throw _privateConstructorUsedError;
  @JsonKey(name: 'change_type')
  FileChangeType get changeType => throw _privateConstructorUsedError;

  /// Serializes this FileEntry to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of FileEntry
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FileEntryCopyWith<FileEntry> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FileEntryCopyWith<$Res> {
  factory $FileEntryCopyWith(FileEntry value, $Res Function(FileEntry) then) =
      _$FileEntryCopyWithImpl<$Res, FileEntry>;
  @useResult
  $Res call({
    String path,
    @JsonKey(name: 'change_type') FileChangeType changeType,
  });
}

/// @nodoc
class _$FileEntryCopyWithImpl<$Res, $Val extends FileEntry>
    implements $FileEntryCopyWith<$Res> {
  _$FileEntryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FileEntry
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? path = null, Object? changeType = null}) {
    return _then(
      _value.copyWith(
            path: null == path
                ? _value.path
                : path // ignore: cast_nullable_to_non_nullable
                      as String,
            changeType: null == changeType
                ? _value.changeType
                : changeType // ignore: cast_nullable_to_non_nullable
                      as FileChangeType,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$FileEntryImplCopyWith<$Res>
    implements $FileEntryCopyWith<$Res> {
  factory _$$FileEntryImplCopyWith(
    _$FileEntryImpl value,
    $Res Function(_$FileEntryImpl) then,
  ) = __$$FileEntryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String path,
    @JsonKey(name: 'change_type') FileChangeType changeType,
  });
}

/// @nodoc
class __$$FileEntryImplCopyWithImpl<$Res>
    extends _$FileEntryCopyWithImpl<$Res, _$FileEntryImpl>
    implements _$$FileEntryImplCopyWith<$Res> {
  __$$FileEntryImplCopyWithImpl(
    _$FileEntryImpl _value,
    $Res Function(_$FileEntryImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of FileEntry
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? path = null, Object? changeType = null}) {
    return _then(
      _$FileEntryImpl(
        path: null == path
            ? _value.path
            : path // ignore: cast_nullable_to_non_nullable
                  as String,
        changeType: null == changeType
            ? _value.changeType
            : changeType // ignore: cast_nullable_to_non_nullable
                  as FileChangeType,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$FileEntryImpl implements _FileEntry {
  const _$FileEntryImpl({
    required this.path,
    @JsonKey(name: 'change_type') required this.changeType,
  });

  factory _$FileEntryImpl.fromJson(Map<String, dynamic> json) =>
      _$$FileEntryImplFromJson(json);

  @override
  final String path;
  @override
  @JsonKey(name: 'change_type')
  final FileChangeType changeType;

  @override
  String toString() {
    return 'FileEntry(path: $path, changeType: $changeType)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FileEntryImpl &&
            (identical(other.path, path) || other.path == path) &&
            (identical(other.changeType, changeType) ||
                other.changeType == changeType));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, path, changeType);

  /// Create a copy of FileEntry
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FileEntryImplCopyWith<_$FileEntryImpl> get copyWith =>
      __$$FileEntryImplCopyWithImpl<_$FileEntryImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$FileEntryImplToJson(this);
  }
}

abstract class _FileEntry implements FileEntry {
  const factory _FileEntry({
    required final String path,
    @JsonKey(name: 'change_type') required final FileChangeType changeType,
  }) = _$FileEntryImpl;

  factory _FileEntry.fromJson(Map<String, dynamic> json) =
      _$FileEntryImpl.fromJson;

  @override
  String get path;
  @override
  @JsonKey(name: 'change_type')
  FileChangeType get changeType;

  /// Create a copy of FileEntry
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FileEntryImplCopyWith<_$FileEntryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

AicrReport _$AicrReportFromJson(Map<String, dynamic> json) {
  return _AicrReport.fromJson(json);
}

/// @nodoc
mixin _$AicrReport {
  Meta get meta => throw _privateConstructorUsedError;
  Summary get summary => throw _privateConstructorUsedError;
  List<RuleResult> get rules => throw _privateConstructorUsedError;
  List<AicrFinding> get findings => throw _privateConstructorUsedError;
  List<dynamic> get contracts => throw _privateConstructorUsedError;
  List<FileEntry> get files => throw _privateConstructorUsedError;
  List<dynamic> get recommendations => throw _privateConstructorUsedError;
  @JsonKey(name: 'ai_review')
  AiReview? get aiReview => throw _privateConstructorUsedError;

  /// Serializes this AicrReport to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AicrReport
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AicrReportCopyWith<AicrReport> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AicrReportCopyWith<$Res> {
  factory $AicrReportCopyWith(
    AicrReport value,
    $Res Function(AicrReport) then,
  ) = _$AicrReportCopyWithImpl<$Res, AicrReport>;
  @useResult
  $Res call({
    Meta meta,
    Summary summary,
    List<RuleResult> rules,
    List<AicrFinding> findings,
    List<dynamic> contracts,
    List<FileEntry> files,
    List<dynamic> recommendations,
    @JsonKey(name: 'ai_review') AiReview? aiReview,
  });

  $MetaCopyWith<$Res> get meta;
  $SummaryCopyWith<$Res> get summary;
  $AiReviewCopyWith<$Res>? get aiReview;
}

/// @nodoc
class _$AicrReportCopyWithImpl<$Res, $Val extends AicrReport>
    implements $AicrReportCopyWith<$Res> {
  _$AicrReportCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AicrReport
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? meta = null,
    Object? summary = null,
    Object? rules = null,
    Object? findings = null,
    Object? contracts = null,
    Object? files = null,
    Object? recommendations = null,
    Object? aiReview = freezed,
  }) {
    return _then(
      _value.copyWith(
            meta: null == meta
                ? _value.meta
                : meta // ignore: cast_nullable_to_non_nullable
                      as Meta,
            summary: null == summary
                ? _value.summary
                : summary // ignore: cast_nullable_to_non_nullable
                      as Summary,
            rules: null == rules
                ? _value.rules
                : rules // ignore: cast_nullable_to_non_nullable
                      as List<RuleResult>,
            findings: null == findings
                ? _value.findings
                : findings // ignore: cast_nullable_to_non_nullable
                      as List<AicrFinding>,
            contracts: null == contracts
                ? _value.contracts
                : contracts // ignore: cast_nullable_to_non_nullable
                      as List<dynamic>,
            files: null == files
                ? _value.files
                : files // ignore: cast_nullable_to_non_nullable
                      as List<FileEntry>,
            recommendations: null == recommendations
                ? _value.recommendations
                : recommendations // ignore: cast_nullable_to_non_nullable
                      as List<dynamic>,
            aiReview: freezed == aiReview
                ? _value.aiReview
                : aiReview // ignore: cast_nullable_to_non_nullable
                      as AiReview?,
          )
          as $Val,
    );
  }

  /// Create a copy of AicrReport
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $MetaCopyWith<$Res> get meta {
    return $MetaCopyWith<$Res>(_value.meta, (value) {
      return _then(_value.copyWith(meta: value) as $Val);
    });
  }

  /// Create a copy of AicrReport
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SummaryCopyWith<$Res> get summary {
    return $SummaryCopyWith<$Res>(_value.summary, (value) {
      return _then(_value.copyWith(summary: value) as $Val);
    });
  }

  /// Create a copy of AicrReport
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $AiReviewCopyWith<$Res>? get aiReview {
    if (_value.aiReview == null) {
      return null;
    }

    return $AiReviewCopyWith<$Res>(_value.aiReview!, (value) {
      return _then(_value.copyWith(aiReview: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$AicrReportImplCopyWith<$Res>
    implements $AicrReportCopyWith<$Res> {
  factory _$$AicrReportImplCopyWith(
    _$AicrReportImpl value,
    $Res Function(_$AicrReportImpl) then,
  ) = __$$AicrReportImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    Meta meta,
    Summary summary,
    List<RuleResult> rules,
    List<AicrFinding> findings,
    List<dynamic> contracts,
    List<FileEntry> files,
    List<dynamic> recommendations,
    @JsonKey(name: 'ai_review') AiReview? aiReview,
  });

  @override
  $MetaCopyWith<$Res> get meta;
  @override
  $SummaryCopyWith<$Res> get summary;
  @override
  $AiReviewCopyWith<$Res>? get aiReview;
}

/// @nodoc
class __$$AicrReportImplCopyWithImpl<$Res>
    extends _$AicrReportCopyWithImpl<$Res, _$AicrReportImpl>
    implements _$$AicrReportImplCopyWith<$Res> {
  __$$AicrReportImplCopyWithImpl(
    _$AicrReportImpl _value,
    $Res Function(_$AicrReportImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AicrReport
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? meta = null,
    Object? summary = null,
    Object? rules = null,
    Object? findings = null,
    Object? contracts = null,
    Object? files = null,
    Object? recommendations = null,
    Object? aiReview = freezed,
  }) {
    return _then(
      _$AicrReportImpl(
        meta: null == meta
            ? _value.meta
            : meta // ignore: cast_nullable_to_non_nullable
                  as Meta,
        summary: null == summary
            ? _value.summary
            : summary // ignore: cast_nullable_to_non_nullable
                  as Summary,
        rules: null == rules
            ? _value._rules
            : rules // ignore: cast_nullable_to_non_nullable
                  as List<RuleResult>,
        findings: null == findings
            ? _value._findings
            : findings // ignore: cast_nullable_to_non_nullable
                  as List<AicrFinding>,
        contracts: null == contracts
            ? _value._contracts
            : contracts // ignore: cast_nullable_to_non_nullable
                  as List<dynamic>,
        files: null == files
            ? _value._files
            : files // ignore: cast_nullable_to_non_nullable
                  as List<FileEntry>,
        recommendations: null == recommendations
            ? _value._recommendations
            : recommendations // ignore: cast_nullable_to_non_nullable
                  as List<dynamic>,
        aiReview: freezed == aiReview
            ? _value.aiReview
            : aiReview // ignore: cast_nullable_to_non_nullable
                  as AiReview?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$AicrReportImpl implements _AicrReport {
  const _$AicrReportImpl({
    required this.meta,
    required this.summary,
    required final List<RuleResult> rules,
    required final List<AicrFinding> findings,
    final List<dynamic> contracts = const [],
    final List<FileEntry> files = const [],
    final List<dynamic> recommendations = const [],
    @JsonKey(name: 'ai_review') this.aiReview,
  }) : _rules = rules,
       _findings = findings,
       _contracts = contracts,
       _files = files,
       _recommendations = recommendations;

  factory _$AicrReportImpl.fromJson(Map<String, dynamic> json) =>
      _$$AicrReportImplFromJson(json);

  @override
  final Meta meta;
  @override
  final Summary summary;
  final List<RuleResult> _rules;
  @override
  List<RuleResult> get rules {
    if (_rules is EqualUnmodifiableListView) return _rules;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_rules);
  }

  final List<AicrFinding> _findings;
  @override
  List<AicrFinding> get findings {
    if (_findings is EqualUnmodifiableListView) return _findings;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_findings);
  }

  final List<dynamic> _contracts;
  @override
  @JsonKey()
  List<dynamic> get contracts {
    if (_contracts is EqualUnmodifiableListView) return _contracts;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_contracts);
  }

  final List<FileEntry> _files;
  @override
  @JsonKey()
  List<FileEntry> get files {
    if (_files is EqualUnmodifiableListView) return _files;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_files);
  }

  final List<dynamic> _recommendations;
  @override
  @JsonKey()
  List<dynamic> get recommendations {
    if (_recommendations is EqualUnmodifiableListView) return _recommendations;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_recommendations);
  }

  @override
  @JsonKey(name: 'ai_review')
  final AiReview? aiReview;

  @override
  String toString() {
    return 'AicrReport(meta: $meta, summary: $summary, rules: $rules, findings: $findings, contracts: $contracts, files: $files, recommendations: $recommendations, aiReview: $aiReview)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AicrReportImpl &&
            (identical(other.meta, meta) || other.meta == meta) &&
            (identical(other.summary, summary) || other.summary == summary) &&
            const DeepCollectionEquality().equals(other._rules, _rules) &&
            const DeepCollectionEquality().equals(other._findings, _findings) &&
            const DeepCollectionEquality().equals(
              other._contracts,
              _contracts,
            ) &&
            const DeepCollectionEquality().equals(other._files, _files) &&
            const DeepCollectionEquality().equals(
              other._recommendations,
              _recommendations,
            ) &&
            (identical(other.aiReview, aiReview) ||
                other.aiReview == aiReview));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    meta,
    summary,
    const DeepCollectionEquality().hash(_rules),
    const DeepCollectionEquality().hash(_findings),
    const DeepCollectionEquality().hash(_contracts),
    const DeepCollectionEquality().hash(_files),
    const DeepCollectionEquality().hash(_recommendations),
    aiReview,
  );

  /// Create a copy of AicrReport
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AicrReportImplCopyWith<_$AicrReportImpl> get copyWith =>
      __$$AicrReportImplCopyWithImpl<_$AicrReportImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AicrReportImplToJson(this);
  }
}

abstract class _AicrReport implements AicrReport {
  const factory _AicrReport({
    required final Meta meta,
    required final Summary summary,
    required final List<RuleResult> rules,
    required final List<AicrFinding> findings,
    final List<dynamic> contracts,
    final List<FileEntry> files,
    final List<dynamic> recommendations,
    @JsonKey(name: 'ai_review') final AiReview? aiReview,
  }) = _$AicrReportImpl;

  factory _AicrReport.fromJson(Map<String, dynamic> json) =
      _$AicrReportImpl.fromJson;

  @override
  Meta get meta;
  @override
  Summary get summary;
  @override
  List<RuleResult> get rules;
  @override
  List<AicrFinding> get findings;
  @override
  List<dynamic> get contracts;
  @override
  List<FileEntry> get files;
  @override
  List<dynamic> get recommendations;
  @override
  @JsonKey(name: 'ai_review')
  AiReview? get aiReview;

  /// Create a copy of AicrReport
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AicrReportImplCopyWith<_$AicrReportImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
