// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ai_review.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

AiReviewHighlight _$AiReviewHighlightFromJson(Map<String, dynamic> json) {
  return _AiReviewHighlight.fromJson(json);
}

/// @nodoc
mixin _$AiReviewHighlight {
  AiSeverity get severity => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get detail => throw _privateConstructorUsedError;
  @JsonKey(name: 'rule_id')
  String? get ruleId => throw _privateConstructorUsedError; // AI finding structured fields
  String? get area => throw _privateConstructorUsedError;
  String? get risk => throw _privateConstructorUsedError;
  String? get reason => throw _privateConstructorUsedError;
  @JsonKey(name: 'suggested_action')
  String? get suggestedAction => throw _privateConstructorUsedError;
  double? get confidence => throw _privateConstructorUsedError;

  /// Serializes this AiReviewHighlight to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AiReviewHighlight
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AiReviewHighlightCopyWith<AiReviewHighlight> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AiReviewHighlightCopyWith<$Res> {
  factory $AiReviewHighlightCopyWith(
    AiReviewHighlight value,
    $Res Function(AiReviewHighlight) then,
  ) = _$AiReviewHighlightCopyWithImpl<$Res, AiReviewHighlight>;
  @useResult
  $Res call({
    AiSeverity severity,
    String title,
    String detail,
    @JsonKey(name: 'rule_id') String? ruleId,
    String? area,
    String? risk,
    String? reason,
    @JsonKey(name: 'suggested_action') String? suggestedAction,
    double? confidence,
  });
}

/// @nodoc
class _$AiReviewHighlightCopyWithImpl<$Res, $Val extends AiReviewHighlight>
    implements $AiReviewHighlightCopyWith<$Res> {
  _$AiReviewHighlightCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AiReviewHighlight
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? severity = null,
    Object? title = null,
    Object? detail = null,
    Object? ruleId = freezed,
    Object? area = freezed,
    Object? risk = freezed,
    Object? reason = freezed,
    Object? suggestedAction = freezed,
    Object? confidence = freezed,
  }) {
    return _then(
      _value.copyWith(
            severity: null == severity
                ? _value.severity
                : severity // ignore: cast_nullable_to_non_nullable
                      as AiSeverity,
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            detail: null == detail
                ? _value.detail
                : detail // ignore: cast_nullable_to_non_nullable
                      as String,
            ruleId: freezed == ruleId
                ? _value.ruleId
                : ruleId // ignore: cast_nullable_to_non_nullable
                      as String?,
            area: freezed == area
                ? _value.area
                : area // ignore: cast_nullable_to_non_nullable
                      as String?,
            risk: freezed == risk
                ? _value.risk
                : risk // ignore: cast_nullable_to_non_nullable
                      as String?,
            reason: freezed == reason
                ? _value.reason
                : reason // ignore: cast_nullable_to_non_nullable
                      as String?,
            suggestedAction: freezed == suggestedAction
                ? _value.suggestedAction
                : suggestedAction // ignore: cast_nullable_to_non_nullable
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
abstract class _$$AiReviewHighlightImplCopyWith<$Res>
    implements $AiReviewHighlightCopyWith<$Res> {
  factory _$$AiReviewHighlightImplCopyWith(
    _$AiReviewHighlightImpl value,
    $Res Function(_$AiReviewHighlightImpl) then,
  ) = __$$AiReviewHighlightImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    AiSeverity severity,
    String title,
    String detail,
    @JsonKey(name: 'rule_id') String? ruleId,
    String? area,
    String? risk,
    String? reason,
    @JsonKey(name: 'suggested_action') String? suggestedAction,
    double? confidence,
  });
}

/// @nodoc
class __$$AiReviewHighlightImplCopyWithImpl<$Res>
    extends _$AiReviewHighlightCopyWithImpl<$Res, _$AiReviewHighlightImpl>
    implements _$$AiReviewHighlightImplCopyWith<$Res> {
  __$$AiReviewHighlightImplCopyWithImpl(
    _$AiReviewHighlightImpl _value,
    $Res Function(_$AiReviewHighlightImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AiReviewHighlight
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? severity = null,
    Object? title = null,
    Object? detail = null,
    Object? ruleId = freezed,
    Object? area = freezed,
    Object? risk = freezed,
    Object? reason = freezed,
    Object? suggestedAction = freezed,
    Object? confidence = freezed,
  }) {
    return _then(
      _$AiReviewHighlightImpl(
        severity: null == severity
            ? _value.severity
            : severity // ignore: cast_nullable_to_non_nullable
                  as AiSeverity,
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        detail: null == detail
            ? _value.detail
            : detail // ignore: cast_nullable_to_non_nullable
                  as String,
        ruleId: freezed == ruleId
            ? _value.ruleId
            : ruleId // ignore: cast_nullable_to_non_nullable
                  as String?,
        area: freezed == area
            ? _value.area
            : area // ignore: cast_nullable_to_non_nullable
                  as String?,
        risk: freezed == risk
            ? _value.risk
            : risk // ignore: cast_nullable_to_non_nullable
                  as String?,
        reason: freezed == reason
            ? _value.reason
            : reason // ignore: cast_nullable_to_non_nullable
                  as String?,
        suggestedAction: freezed == suggestedAction
            ? _value.suggestedAction
            : suggestedAction // ignore: cast_nullable_to_non_nullable
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
@JsonSerializable()
class _$AiReviewHighlightImpl implements _AiReviewHighlight {
  const _$AiReviewHighlightImpl({
    required this.severity,
    required this.title,
    required this.detail,
    @JsonKey(name: 'rule_id') this.ruleId,
    this.area,
    this.risk,
    this.reason,
    @JsonKey(name: 'suggested_action') this.suggestedAction,
    this.confidence,
  });

  factory _$AiReviewHighlightImpl.fromJson(Map<String, dynamic> json) =>
      _$$AiReviewHighlightImplFromJson(json);

  @override
  final AiSeverity severity;
  @override
  final String title;
  @override
  final String detail;
  @override
  @JsonKey(name: 'rule_id')
  final String? ruleId;
  // AI finding structured fields
  @override
  final String? area;
  @override
  final String? risk;
  @override
  final String? reason;
  @override
  @JsonKey(name: 'suggested_action')
  final String? suggestedAction;
  @override
  final double? confidence;

  @override
  String toString() {
    return 'AiReviewHighlight(severity: $severity, title: $title, detail: $detail, ruleId: $ruleId, area: $area, risk: $risk, reason: $reason, suggestedAction: $suggestedAction, confidence: $confidence)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AiReviewHighlightImpl &&
            (identical(other.severity, severity) ||
                other.severity == severity) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.detail, detail) || other.detail == detail) &&
            (identical(other.ruleId, ruleId) || other.ruleId == ruleId) &&
            (identical(other.area, area) || other.area == area) &&
            (identical(other.risk, risk) || other.risk == risk) &&
            (identical(other.reason, reason) || other.reason == reason) &&
            (identical(other.suggestedAction, suggestedAction) ||
                other.suggestedAction == suggestedAction) &&
            (identical(other.confidence, confidence) ||
                other.confidence == confidence));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    severity,
    title,
    detail,
    ruleId,
    area,
    risk,
    reason,
    suggestedAction,
    confidence,
  );

  /// Create a copy of AiReviewHighlight
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AiReviewHighlightImplCopyWith<_$AiReviewHighlightImpl> get copyWith =>
      __$$AiReviewHighlightImplCopyWithImpl<_$AiReviewHighlightImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$AiReviewHighlightImplToJson(this);
  }
}

abstract class _AiReviewHighlight implements AiReviewHighlight {
  const factory _AiReviewHighlight({
    required final AiSeverity severity,
    required final String title,
    required final String detail,
    @JsonKey(name: 'rule_id') final String? ruleId,
    final String? area,
    final String? risk,
    final String? reason,
    @JsonKey(name: 'suggested_action') final String? suggestedAction,
    final double? confidence,
  }) = _$AiReviewHighlightImpl;

  factory _AiReviewHighlight.fromJson(Map<String, dynamic> json) =
      _$AiReviewHighlightImpl.fromJson;

  @override
  AiSeverity get severity;
  @override
  String get title;
  @override
  String get detail;
  @override
  @JsonKey(name: 'rule_id')
  String? get ruleId; // AI finding structured fields
  @override
  String? get area;
  @override
  String? get risk;
  @override
  String? get reason;
  @override
  @JsonKey(name: 'suggested_action')
  String? get suggestedAction;
  @override
  double? get confidence;

  /// Create a copy of AiReviewHighlight
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AiReviewHighlightImplCopyWith<_$AiReviewHighlightImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

AiSuggestedAction _$AiSuggestedActionFromJson(Map<String, dynamic> json) {
  return _AiSuggestedAction.fromJson(json);
}

/// @nodoc
mixin _$AiSuggestedAction {
  AiActionPriority get priority => throw _privateConstructorUsedError;
  String get action => throw _privateConstructorUsedError;

  /// Serializes this AiSuggestedAction to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AiSuggestedAction
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AiSuggestedActionCopyWith<AiSuggestedAction> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AiSuggestedActionCopyWith<$Res> {
  factory $AiSuggestedActionCopyWith(
    AiSuggestedAction value,
    $Res Function(AiSuggestedAction) then,
  ) = _$AiSuggestedActionCopyWithImpl<$Res, AiSuggestedAction>;
  @useResult
  $Res call({AiActionPriority priority, String action});
}

/// @nodoc
class _$AiSuggestedActionCopyWithImpl<$Res, $Val extends AiSuggestedAction>
    implements $AiSuggestedActionCopyWith<$Res> {
  _$AiSuggestedActionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AiSuggestedAction
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? priority = null, Object? action = null}) {
    return _then(
      _value.copyWith(
            priority: null == priority
                ? _value.priority
                : priority // ignore: cast_nullable_to_non_nullable
                      as AiActionPriority,
            action: null == action
                ? _value.action
                : action // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$AiSuggestedActionImplCopyWith<$Res>
    implements $AiSuggestedActionCopyWith<$Res> {
  factory _$$AiSuggestedActionImplCopyWith(
    _$AiSuggestedActionImpl value,
    $Res Function(_$AiSuggestedActionImpl) then,
  ) = __$$AiSuggestedActionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({AiActionPriority priority, String action});
}

/// @nodoc
class __$$AiSuggestedActionImplCopyWithImpl<$Res>
    extends _$AiSuggestedActionCopyWithImpl<$Res, _$AiSuggestedActionImpl>
    implements _$$AiSuggestedActionImplCopyWith<$Res> {
  __$$AiSuggestedActionImplCopyWithImpl(
    _$AiSuggestedActionImpl _value,
    $Res Function(_$AiSuggestedActionImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AiSuggestedAction
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? priority = null, Object? action = null}) {
    return _then(
      _$AiSuggestedActionImpl(
        priority: null == priority
            ? _value.priority
            : priority // ignore: cast_nullable_to_non_nullable
                  as AiActionPriority,
        action: null == action
            ? _value.action
            : action // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$AiSuggestedActionImpl implements _AiSuggestedAction {
  const _$AiSuggestedActionImpl({required this.priority, required this.action});

  factory _$AiSuggestedActionImpl.fromJson(Map<String, dynamic> json) =>
      _$$AiSuggestedActionImplFromJson(json);

  @override
  final AiActionPriority priority;
  @override
  final String action;

  @override
  String toString() {
    return 'AiSuggestedAction(priority: $priority, action: $action)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AiSuggestedActionImpl &&
            (identical(other.priority, priority) ||
                other.priority == priority) &&
            (identical(other.action, action) || other.action == action));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, priority, action);

  /// Create a copy of AiSuggestedAction
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AiSuggestedActionImplCopyWith<_$AiSuggestedActionImpl> get copyWith =>
      __$$AiSuggestedActionImplCopyWithImpl<_$AiSuggestedActionImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$AiSuggestedActionImplToJson(this);
  }
}

abstract class _AiSuggestedAction implements AiSuggestedAction {
  const factory _AiSuggestedAction({
    required final AiActionPriority priority,
    required final String action,
  }) = _$AiSuggestedActionImpl;

  factory _AiSuggestedAction.fromJson(Map<String, dynamic> json) =
      _$AiSuggestedActionImpl.fromJson;

  @override
  AiActionPriority get priority;
  @override
  String get action;

  /// Create a copy of AiSuggestedAction
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AiSuggestedActionImplCopyWith<_$AiSuggestedActionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

AiReview _$AiReviewFromJson(Map<String, dynamic> json) {
  return _AiReview.fromJson(json);
}

/// @nodoc
mixin _$AiReview {
  AiReviewStatus get status => throw _privateConstructorUsedError;
  AiLanguage get language => throw _privateConstructorUsedError;
  String get summary => throw _privateConstructorUsedError;
  List<AiReviewHighlight> get highlights => throw _privateConstructorUsedError;
  @JsonKey(name: 'suggested_actions')
  List<AiSuggestedAction> get suggestedActions =>
      throw _privateConstructorUsedError;
  List<String> get limitations => throw _privateConstructorUsedError;

  /// Serializes this AiReview to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AiReview
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AiReviewCopyWith<AiReview> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AiReviewCopyWith<$Res> {
  factory $AiReviewCopyWith(AiReview value, $Res Function(AiReview) then) =
      _$AiReviewCopyWithImpl<$Res, AiReview>;
  @useResult
  $Res call({
    AiReviewStatus status,
    AiLanguage language,
    String summary,
    List<AiReviewHighlight> highlights,
    @JsonKey(name: 'suggested_actions')
    List<AiSuggestedAction> suggestedActions,
    List<String> limitations,
  });
}

/// @nodoc
class _$AiReviewCopyWithImpl<$Res, $Val extends AiReview>
    implements $AiReviewCopyWith<$Res> {
  _$AiReviewCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AiReview
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? status = null,
    Object? language = null,
    Object? summary = null,
    Object? highlights = null,
    Object? suggestedActions = null,
    Object? limitations = null,
  }) {
    return _then(
      _value.copyWith(
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as AiReviewStatus,
            language: null == language
                ? _value.language
                : language // ignore: cast_nullable_to_non_nullable
                      as AiLanguage,
            summary: null == summary
                ? _value.summary
                : summary // ignore: cast_nullable_to_non_nullable
                      as String,
            highlights: null == highlights
                ? _value.highlights
                : highlights // ignore: cast_nullable_to_non_nullable
                      as List<AiReviewHighlight>,
            suggestedActions: null == suggestedActions
                ? _value.suggestedActions
                : suggestedActions // ignore: cast_nullable_to_non_nullable
                      as List<AiSuggestedAction>,
            limitations: null == limitations
                ? _value.limitations
                : limitations // ignore: cast_nullable_to_non_nullable
                      as List<String>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$AiReviewImplCopyWith<$Res>
    implements $AiReviewCopyWith<$Res> {
  factory _$$AiReviewImplCopyWith(
    _$AiReviewImpl value,
    $Res Function(_$AiReviewImpl) then,
  ) = __$$AiReviewImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    AiReviewStatus status,
    AiLanguage language,
    String summary,
    List<AiReviewHighlight> highlights,
    @JsonKey(name: 'suggested_actions')
    List<AiSuggestedAction> suggestedActions,
    List<String> limitations,
  });
}

/// @nodoc
class __$$AiReviewImplCopyWithImpl<$Res>
    extends _$AiReviewCopyWithImpl<$Res, _$AiReviewImpl>
    implements _$$AiReviewImplCopyWith<$Res> {
  __$$AiReviewImplCopyWithImpl(
    _$AiReviewImpl _value,
    $Res Function(_$AiReviewImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AiReview
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? status = null,
    Object? language = null,
    Object? summary = null,
    Object? highlights = null,
    Object? suggestedActions = null,
    Object? limitations = null,
  }) {
    return _then(
      _$AiReviewImpl(
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as AiReviewStatus,
        language: null == language
            ? _value.language
            : language // ignore: cast_nullable_to_non_nullable
                  as AiLanguage,
        summary: null == summary
            ? _value.summary
            : summary // ignore: cast_nullable_to_non_nullable
                  as String,
        highlights: null == highlights
            ? _value._highlights
            : highlights // ignore: cast_nullable_to_non_nullable
                  as List<AiReviewHighlight>,
        suggestedActions: null == suggestedActions
            ? _value._suggestedActions
            : suggestedActions // ignore: cast_nullable_to_non_nullable
                  as List<AiSuggestedAction>,
        limitations: null == limitations
            ? _value._limitations
            : limitations // ignore: cast_nullable_to_non_nullable
                  as List<String>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$AiReviewImpl implements _AiReview {
  const _$AiReviewImpl({
    required this.status,
    required this.language,
    required this.summary,
    required final List<AiReviewHighlight> highlights,
    @JsonKey(name: 'suggested_actions')
    required final List<AiSuggestedAction> suggestedActions,
    required final List<String> limitations,
  }) : _highlights = highlights,
       _suggestedActions = suggestedActions,
       _limitations = limitations;

  factory _$AiReviewImpl.fromJson(Map<String, dynamic> json) =>
      _$$AiReviewImplFromJson(json);

  @override
  final AiReviewStatus status;
  @override
  final AiLanguage language;
  @override
  final String summary;
  final List<AiReviewHighlight> _highlights;
  @override
  List<AiReviewHighlight> get highlights {
    if (_highlights is EqualUnmodifiableListView) return _highlights;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_highlights);
  }

  final List<AiSuggestedAction> _suggestedActions;
  @override
  @JsonKey(name: 'suggested_actions')
  List<AiSuggestedAction> get suggestedActions {
    if (_suggestedActions is EqualUnmodifiableListView)
      return _suggestedActions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_suggestedActions);
  }

  final List<String> _limitations;
  @override
  List<String> get limitations {
    if (_limitations is EqualUnmodifiableListView) return _limitations;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_limitations);
  }

  @override
  String toString() {
    return 'AiReview(status: $status, language: $language, summary: $summary, highlights: $highlights, suggestedActions: $suggestedActions, limitations: $limitations)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AiReviewImpl &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.language, language) ||
                other.language == language) &&
            (identical(other.summary, summary) || other.summary == summary) &&
            const DeepCollectionEquality().equals(
              other._highlights,
              _highlights,
            ) &&
            const DeepCollectionEquality().equals(
              other._suggestedActions,
              _suggestedActions,
            ) &&
            const DeepCollectionEquality().equals(
              other._limitations,
              _limitations,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    status,
    language,
    summary,
    const DeepCollectionEquality().hash(_highlights),
    const DeepCollectionEquality().hash(_suggestedActions),
    const DeepCollectionEquality().hash(_limitations),
  );

  /// Create a copy of AiReview
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AiReviewImplCopyWith<_$AiReviewImpl> get copyWith =>
      __$$AiReviewImplCopyWithImpl<_$AiReviewImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AiReviewImplToJson(this);
  }
}

abstract class _AiReview implements AiReview {
  const factory _AiReview({
    required final AiReviewStatus status,
    required final AiLanguage language,
    required final String summary,
    required final List<AiReviewHighlight> highlights,
    @JsonKey(name: 'suggested_actions')
    required final List<AiSuggestedAction> suggestedActions,
    required final List<String> limitations,
  }) = _$AiReviewImpl;

  factory _AiReview.fromJson(Map<String, dynamic> json) =
      _$AiReviewImpl.fromJson;

  @override
  AiReviewStatus get status;
  @override
  AiLanguage get language;
  @override
  String get summary;
  @override
  List<AiReviewHighlight> get highlights;
  @override
  @JsonKey(name: 'suggested_actions')
  List<AiSuggestedAction> get suggestedActions;
  @override
  List<String> get limitations;

  /// Create a copy of AiReview
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AiReviewImplCopyWith<_$AiReviewImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
