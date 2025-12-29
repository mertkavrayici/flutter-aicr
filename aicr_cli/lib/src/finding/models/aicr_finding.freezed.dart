// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'aicr_finding.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$AicrFinding {
  String get id => throw _privateConstructorUsedError;
  AicrCategory get category => throw _privateConstructorUsedError;
  AicrSeverity get severity => throw _privateConstructorUsedError;
  String get title =>
      throw _privateConstructorUsedError; // Keep public API stable (call sites still pass messageTr/messageEn),
  // but preserve legacy JSON shape: `"message": {"tr": ..., "en": ...}`.
  String get messageTr => throw _privateConstructorUsedError;
  String get messageEn => throw _privateConstructorUsedError;
  String? get filePath => throw _privateConstructorUsedError;
  int? get lineStart => throw _privateConstructorUsedError;
  int? get lineEnd => throw _privateConstructorUsedError;
  String? get sourceId => throw _privateConstructorUsedError;
  double? get confidence => throw _privateConstructorUsedError;

  /// Create a copy of AicrFinding
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AicrFindingCopyWith<AicrFinding> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AicrFindingCopyWith<$Res> {
  factory $AicrFindingCopyWith(
    AicrFinding value,
    $Res Function(AicrFinding) then,
  ) = _$AicrFindingCopyWithImpl<$Res, AicrFinding>;
  @useResult
  $Res call({
    String id,
    AicrCategory category,
    AicrSeverity severity,
    String title,
    String messageTr,
    String messageEn,
    String? filePath,
    int? lineStart,
    int? lineEnd,
    String? sourceId,
    double? confidence,
  });
}

/// @nodoc
class _$AicrFindingCopyWithImpl<$Res, $Val extends AicrFinding>
    implements $AicrFindingCopyWith<$Res> {
  _$AicrFindingCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AicrFinding
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? category = null,
    Object? severity = null,
    Object? title = null,
    Object? messageTr = null,
    Object? messageEn = null,
    Object? filePath = freezed,
    Object? lineStart = freezed,
    Object? lineEnd = freezed,
    Object? sourceId = freezed,
    Object? confidence = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            category: null == category
                ? _value.category
                : category // ignore: cast_nullable_to_non_nullable
                      as AicrCategory,
            severity: null == severity
                ? _value.severity
                : severity // ignore: cast_nullable_to_non_nullable
                      as AicrSeverity,
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            messageTr: null == messageTr
                ? _value.messageTr
                : messageTr // ignore: cast_nullable_to_non_nullable
                      as String,
            messageEn: null == messageEn
                ? _value.messageEn
                : messageEn // ignore: cast_nullable_to_non_nullable
                      as String,
            filePath: freezed == filePath
                ? _value.filePath
                : filePath // ignore: cast_nullable_to_non_nullable
                      as String?,
            lineStart: freezed == lineStart
                ? _value.lineStart
                : lineStart // ignore: cast_nullable_to_non_nullable
                      as int?,
            lineEnd: freezed == lineEnd
                ? _value.lineEnd
                : lineEnd // ignore: cast_nullable_to_non_nullable
                      as int?,
            sourceId: freezed == sourceId
                ? _value.sourceId
                : sourceId // ignore: cast_nullable_to_non_nullable
                      as String?,
            confidence: freezed == confidence
                ? _value.confidence
                : confidence // ignore: cast_nullable_to_non_nullable
                      as double?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$AicrFindingImplCopyWith<$Res>
    implements $AicrFindingCopyWith<$Res> {
  factory _$$AicrFindingImplCopyWith(
    _$AicrFindingImpl value,
    $Res Function(_$AicrFindingImpl) then,
  ) = __$$AicrFindingImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    AicrCategory category,
    AicrSeverity severity,
    String title,
    String messageTr,
    String messageEn,
    String? filePath,
    int? lineStart,
    int? lineEnd,
    String? sourceId,
    double? confidence,
  });
}

/// @nodoc
class __$$AicrFindingImplCopyWithImpl<$Res>
    extends _$AicrFindingCopyWithImpl<$Res, _$AicrFindingImpl>
    implements _$$AicrFindingImplCopyWith<$Res> {
  __$$AicrFindingImplCopyWithImpl(
    _$AicrFindingImpl _value,
    $Res Function(_$AicrFindingImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AicrFinding
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? category = null,
    Object? severity = null,
    Object? title = null,
    Object? messageTr = null,
    Object? messageEn = null,
    Object? filePath = freezed,
    Object? lineStart = freezed,
    Object? lineEnd = freezed,
    Object? sourceId = freezed,
    Object? confidence = freezed,
  }) {
    return _then(
      _$AicrFindingImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        category: null == category
            ? _value.category
            : category // ignore: cast_nullable_to_non_nullable
                  as AicrCategory,
        severity: null == severity
            ? _value.severity
            : severity // ignore: cast_nullable_to_non_nullable
                  as AicrSeverity,
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        messageTr: null == messageTr
            ? _value.messageTr
            : messageTr // ignore: cast_nullable_to_non_nullable
                  as String,
        messageEn: null == messageEn
            ? _value.messageEn
            : messageEn // ignore: cast_nullable_to_non_nullable
                  as String,
        filePath: freezed == filePath
            ? _value.filePath
            : filePath // ignore: cast_nullable_to_non_nullable
                  as String?,
        lineStart: freezed == lineStart
            ? _value.lineStart
            : lineStart // ignore: cast_nullable_to_non_nullable
                  as int?,
        lineEnd: freezed == lineEnd
            ? _value.lineEnd
            : lineEnd // ignore: cast_nullable_to_non_nullable
                  as int?,
        sourceId: freezed == sourceId
            ? _value.sourceId
            : sourceId // ignore: cast_nullable_to_non_nullable
                  as String?,
        confidence: freezed == confidence
            ? _value.confidence
            : confidence // ignore: cast_nullable_to_non_nullable
                  as double?,
      ),
    );
  }
}

/// @nodoc

class _$AicrFindingImpl extends _AicrFinding {
  const _$AicrFindingImpl({
    required this.id,
    required this.category,
    required this.severity,
    required this.title,
    required this.messageTr,
    required this.messageEn,
    this.filePath,
    this.lineStart,
    this.lineEnd,
    this.sourceId,
    this.confidence,
  }) : super._();

  @override
  final String id;
  @override
  final AicrCategory category;
  @override
  final AicrSeverity severity;
  @override
  final String title;
  // Keep public API stable (call sites still pass messageTr/messageEn),
  // but preserve legacy JSON shape: `"message": {"tr": ..., "en": ...}`.
  @override
  final String messageTr;
  @override
  final String messageEn;
  @override
  final String? filePath;
  @override
  final int? lineStart;
  @override
  final int? lineEnd;
  @override
  final String? sourceId;
  @override
  final double? confidence;

  @override
  String toString() {
    return 'AicrFinding(id: $id, category: $category, severity: $severity, title: $title, messageTr: $messageTr, messageEn: $messageEn, filePath: $filePath, lineStart: $lineStart, lineEnd: $lineEnd, sourceId: $sourceId, confidence: $confidence)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AicrFindingImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.severity, severity) ||
                other.severity == severity) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.messageTr, messageTr) ||
                other.messageTr == messageTr) &&
            (identical(other.messageEn, messageEn) ||
                other.messageEn == messageEn) &&
            (identical(other.filePath, filePath) ||
                other.filePath == filePath) &&
            (identical(other.lineStart, lineStart) ||
                other.lineStart == lineStart) &&
            (identical(other.lineEnd, lineEnd) || other.lineEnd == lineEnd) &&
            (identical(other.sourceId, sourceId) ||
                other.sourceId == sourceId) &&
            (identical(other.confidence, confidence) ||
                other.confidence == confidence));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    category,
    severity,
    title,
    messageTr,
    messageEn,
    filePath,
    lineStart,
    lineEnd,
    sourceId,
    confidence,
  );

  /// Create a copy of AicrFinding
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AicrFindingImplCopyWith<_$AicrFindingImpl> get copyWith =>
      __$$AicrFindingImplCopyWithImpl<_$AicrFindingImpl>(this, _$identity);
}

abstract class _AicrFinding extends AicrFinding {
  const factory _AicrFinding({
    required final String id,
    required final AicrCategory category,
    required final AicrSeverity severity,
    required final String title,
    required final String messageTr,
    required final String messageEn,
    final String? filePath,
    final int? lineStart,
    final int? lineEnd,
    final String? sourceId,
    final double? confidence,
  }) = _$AicrFindingImpl;
  const _AicrFinding._() : super._();

  @override
  String get id;
  @override
  AicrCategory get category;
  @override
  AicrSeverity get severity;
  @override
  String get title; // Keep public API stable (call sites still pass messageTr/messageEn),
  // but preserve legacy JSON shape: `"message": {"tr": ..., "en": ...}`.
  @override
  String get messageTr;
  @override
  String get messageEn;
  @override
  String? get filePath;
  @override
  int? get lineStart;
  @override
  int? get lineEnd;
  @override
  String? get sourceId;
  @override
  double? get confidence;

  /// Create a copy of AicrFinding
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AicrFindingImplCopyWith<_$AicrFindingImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
