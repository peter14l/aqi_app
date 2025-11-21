// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'purifier_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

PurifierState _$PurifierStateFromJson(Map<String, dynamic> json) {
  return _PurifierState.fromJson(json);
}

/// @nodoc
mixin _$PurifierState {
  @HiveField(1)
  String get id => throw _privateConstructorUsedError;
  @HiveField(2)
  String get name => throw _privateConstructorUsedError;
  @HiveField(3)
  String get status => throw _privateConstructorUsedError;
  @HiveField(4)
  String get mode => throw _privateConstructorUsedError;
  @HiveField(5)
  int get fanSpeed => throw _privateConstructorUsedError;
  @HiveField(6)
  bool get isConnected => throw _privateConstructorUsedError;
  @HiveField(7)
  DateTime get lastUpdated => throw _privateConstructorUsedError;
  @HiveField(8)
  int? get currentAqi => throw _privateConstructorUsedError;
  @HiveField(9)
  String? get location => throw _privateConstructorUsedError;
  @HiveField(10)
  double? get filterLifeRemaining => throw _privateConstructorUsedError;
  @HiveField(11)
  bool get isAutoAdjust => throw _privateConstructorUsedError;

  /// Serializes this PurifierState to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PurifierState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PurifierStateCopyWith<PurifierState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PurifierStateCopyWith<$Res> {
  factory $PurifierStateCopyWith(
          PurifierState value, $Res Function(PurifierState) then) =
      _$PurifierStateCopyWithImpl<$Res, PurifierState>;
  @useResult
  $Res call(
      {@HiveField(1) String id,
      @HiveField(2) String name,
      @HiveField(3) String status,
      @HiveField(4) String mode,
      @HiveField(5) int fanSpeed,
      @HiveField(6) bool isConnected,
      @HiveField(7) DateTime lastUpdated,
      @HiveField(8) int? currentAqi,
      @HiveField(9) String? location,
      @HiveField(10) double? filterLifeRemaining,
      @HiveField(11) bool isAutoAdjust});
}

/// @nodoc
class _$PurifierStateCopyWithImpl<$Res, $Val extends PurifierState>
    implements $PurifierStateCopyWith<$Res> {
  _$PurifierStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PurifierState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? status = null,
    Object? mode = null,
    Object? fanSpeed = null,
    Object? isConnected = null,
    Object? lastUpdated = null,
    Object? currentAqi = freezed,
    Object? location = freezed,
    Object? filterLifeRemaining = freezed,
    Object? isAutoAdjust = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      mode: null == mode
          ? _value.mode
          : mode // ignore: cast_nullable_to_non_nullable
              as String,
      fanSpeed: null == fanSpeed
          ? _value.fanSpeed
          : fanSpeed // ignore: cast_nullable_to_non_nullable
              as int,
      isConnected: null == isConnected
          ? _value.isConnected
          : isConnected // ignore: cast_nullable_to_non_nullable
              as bool,
      lastUpdated: null == lastUpdated
          ? _value.lastUpdated
          : lastUpdated // ignore: cast_nullable_to_non_nullable
              as DateTime,
      currentAqi: freezed == currentAqi
          ? _value.currentAqi
          : currentAqi // ignore: cast_nullable_to_non_nullable
              as int?,
      location: freezed == location
          ? _value.location
          : location // ignore: cast_nullable_to_non_nullable
              as String?,
      filterLifeRemaining: freezed == filterLifeRemaining
          ? _value.filterLifeRemaining
          : filterLifeRemaining // ignore: cast_nullable_to_non_nullable
              as double?,
      isAutoAdjust: null == isAutoAdjust
          ? _value.isAutoAdjust
          : isAutoAdjust // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PurifierStateImplCopyWith<$Res>
    implements $PurifierStateCopyWith<$Res> {
  factory _$$PurifierStateImplCopyWith(
          _$PurifierStateImpl value, $Res Function(_$PurifierStateImpl) then) =
      __$$PurifierStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@HiveField(1) String id,
      @HiveField(2) String name,
      @HiveField(3) String status,
      @HiveField(4) String mode,
      @HiveField(5) int fanSpeed,
      @HiveField(6) bool isConnected,
      @HiveField(7) DateTime lastUpdated,
      @HiveField(8) int? currentAqi,
      @HiveField(9) String? location,
      @HiveField(10) double? filterLifeRemaining,
      @HiveField(11) bool isAutoAdjust});
}

/// @nodoc
class __$$PurifierStateImplCopyWithImpl<$Res>
    extends _$PurifierStateCopyWithImpl<$Res, _$PurifierStateImpl>
    implements _$$PurifierStateImplCopyWith<$Res> {
  __$$PurifierStateImplCopyWithImpl(
      _$PurifierStateImpl _value, $Res Function(_$PurifierStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of PurifierState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? status = null,
    Object? mode = null,
    Object? fanSpeed = null,
    Object? isConnected = null,
    Object? lastUpdated = null,
    Object? currentAqi = freezed,
    Object? location = freezed,
    Object? filterLifeRemaining = freezed,
    Object? isAutoAdjust = null,
  }) {
    return _then(_$PurifierStateImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      mode: null == mode
          ? _value.mode
          : mode // ignore: cast_nullable_to_non_nullable
              as String,
      fanSpeed: null == fanSpeed
          ? _value.fanSpeed
          : fanSpeed // ignore: cast_nullable_to_non_nullable
              as int,
      isConnected: null == isConnected
          ? _value.isConnected
          : isConnected // ignore: cast_nullable_to_non_nullable
              as bool,
      lastUpdated: null == lastUpdated
          ? _value.lastUpdated
          : lastUpdated // ignore: cast_nullable_to_non_nullable
              as DateTime,
      currentAqi: freezed == currentAqi
          ? _value.currentAqi
          : currentAqi // ignore: cast_nullable_to_non_nullable
              as int?,
      location: freezed == location
          ? _value.location
          : location // ignore: cast_nullable_to_non_nullable
              as String?,
      filterLifeRemaining: freezed == filterLifeRemaining
          ? _value.filterLifeRemaining
          : filterLifeRemaining // ignore: cast_nullable_to_non_nullable
              as double?,
      isAutoAdjust: null == isAutoAdjust
          ? _value.isAutoAdjust
          : isAutoAdjust // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
@HiveField(0)
class _$PurifierStateImpl implements _PurifierState {
  const _$PurifierStateImpl(
      {@HiveField(1) required this.id,
      @HiveField(2) required this.name,
      @HiveField(3) required this.status,
      @HiveField(4) required this.mode,
      @HiveField(5) required this.fanSpeed,
      @HiveField(6) required this.isConnected,
      @HiveField(7) required this.lastUpdated,
      @HiveField(8) this.currentAqi,
      @HiveField(9) this.location,
      @HiveField(10) this.filterLifeRemaining,
      @HiveField(11) this.isAutoAdjust = false});

  factory _$PurifierStateImpl.fromJson(Map<String, dynamic> json) =>
      _$$PurifierStateImplFromJson(json);

  @override
  @HiveField(1)
  final String id;
  @override
  @HiveField(2)
  final String name;
  @override
  @HiveField(3)
  final String status;
  @override
  @HiveField(4)
  final String mode;
  @override
  @HiveField(5)
  final int fanSpeed;
  @override
  @HiveField(6)
  final bool isConnected;
  @override
  @HiveField(7)
  final DateTime lastUpdated;
  @override
  @HiveField(8)
  final int? currentAqi;
  @override
  @HiveField(9)
  final String? location;
  @override
  @HiveField(10)
  final double? filterLifeRemaining;
  @override
  @JsonKey()
  @HiveField(11)
  final bool isAutoAdjust;

  @override
  String toString() {
    return 'PurifierState(id: $id, name: $name, status: $status, mode: $mode, fanSpeed: $fanSpeed, isConnected: $isConnected, lastUpdated: $lastUpdated, currentAqi: $currentAqi, location: $location, filterLifeRemaining: $filterLifeRemaining, isAutoAdjust: $isAutoAdjust)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PurifierStateImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.mode, mode) || other.mode == mode) &&
            (identical(other.fanSpeed, fanSpeed) ||
                other.fanSpeed == fanSpeed) &&
            (identical(other.isConnected, isConnected) ||
                other.isConnected == isConnected) &&
            (identical(other.lastUpdated, lastUpdated) ||
                other.lastUpdated == lastUpdated) &&
            (identical(other.currentAqi, currentAqi) ||
                other.currentAqi == currentAqi) &&
            (identical(other.location, location) ||
                other.location == location) &&
            (identical(other.filterLifeRemaining, filterLifeRemaining) ||
                other.filterLifeRemaining == filterLifeRemaining) &&
            (identical(other.isAutoAdjust, isAutoAdjust) ||
                other.isAutoAdjust == isAutoAdjust));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      name,
      status,
      mode,
      fanSpeed,
      isConnected,
      lastUpdated,
      currentAqi,
      location,
      filterLifeRemaining,
      isAutoAdjust);

  /// Create a copy of PurifierState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PurifierStateImplCopyWith<_$PurifierStateImpl> get copyWith =>
      __$$PurifierStateImplCopyWithImpl<_$PurifierStateImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PurifierStateImplToJson(
      this,
    );
  }
}

abstract class _PurifierState implements PurifierState {
  const factory _PurifierState(
      {@HiveField(1) required final String id,
      @HiveField(2) required final String name,
      @HiveField(3) required final String status,
      @HiveField(4) required final String mode,
      @HiveField(5) required final int fanSpeed,
      @HiveField(6) required final bool isConnected,
      @HiveField(7) required final DateTime lastUpdated,
      @HiveField(8) final int? currentAqi,
      @HiveField(9) final String? location,
      @HiveField(10) final double? filterLifeRemaining,
      @HiveField(11) final bool isAutoAdjust}) = _$PurifierStateImpl;

  factory _PurifierState.fromJson(Map<String, dynamic> json) =
      _$PurifierStateImpl.fromJson;

  @override
  @HiveField(1)
  String get id;
  @override
  @HiveField(2)
  String get name;
  @override
  @HiveField(3)
  String get status;
  @override
  @HiveField(4)
  String get mode;
  @override
  @HiveField(5)
  int get fanSpeed;
  @override
  @HiveField(6)
  bool get isConnected;
  @override
  @HiveField(7)
  DateTime get lastUpdated;
  @override
  @HiveField(8)
  int? get currentAqi;
  @override
  @HiveField(9)
  String? get location;
  @override
  @HiveField(10)
  double? get filterLifeRemaining;
  @override
  @HiveField(11)
  bool get isAutoAdjust;

  /// Create a copy of PurifierState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PurifierStateImplCopyWith<_$PurifierStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
