// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'body_metric.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

BodyMetric _$BodyMetricFromJson(Map<String, dynamic> json) {
  return _BodyMetric.fromJson(json);
}

/// @nodoc
mixin _$BodyMetric {
  String get metricId => throw _privateConstructorUsedError;
  DateTime get timestamp => throw _privateConstructorUsedError;
  double? get weightKg => throw _privateConstructorUsedError;
  double? get bodyFatPercent => throw _privateConstructorUsedError;
  double? get waistCm => throw _privateConstructorUsedError;
  String? get note => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $BodyMetricCopyWith<BodyMetric> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BodyMetricCopyWith<$Res> {
  factory $BodyMetricCopyWith(
          BodyMetric value, $Res Function(BodyMetric) then) =
      _$BodyMetricCopyWithImpl<$Res, BodyMetric>;
  @useResult
  $Res call(
      {String metricId,
      DateTime timestamp,
      double? weightKg,
      double? bodyFatPercent,
      double? waistCm,
      String? note});
}

/// @nodoc
class _$BodyMetricCopyWithImpl<$Res, $Val extends BodyMetric>
    implements $BodyMetricCopyWith<$Res> {
  _$BodyMetricCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? metricId = null,
    Object? timestamp = null,
    Object? weightKg = freezed,
    Object? bodyFatPercent = freezed,
    Object? waistCm = freezed,
    Object? note = freezed,
  }) {
    return _then(_value.copyWith(
      metricId: null == metricId
          ? _value.metricId
          : metricId // ignore: cast_nullable_to_non_nullable
              as String,
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
      weightKg: freezed == weightKg
          ? _value.weightKg
          : weightKg // ignore: cast_nullable_to_non_nullable
              as double?,
      bodyFatPercent: freezed == bodyFatPercent
          ? _value.bodyFatPercent
          : bodyFatPercent // ignore: cast_nullable_to_non_nullable
              as double?,
      waistCm: freezed == waistCm
          ? _value.waistCm
          : waistCm // ignore: cast_nullable_to_non_nullable
              as double?,
      note: freezed == note
          ? _value.note
          : note // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$BodyMetricImplCopyWith<$Res>
    implements $BodyMetricCopyWith<$Res> {
  factory _$$BodyMetricImplCopyWith(
          _$BodyMetricImpl value, $Res Function(_$BodyMetricImpl) then) =
      __$$BodyMetricImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String metricId,
      DateTime timestamp,
      double? weightKg,
      double? bodyFatPercent,
      double? waistCm,
      String? note});
}

/// @nodoc
class __$$BodyMetricImplCopyWithImpl<$Res>
    extends _$BodyMetricCopyWithImpl<$Res, _$BodyMetricImpl>
    implements _$$BodyMetricImplCopyWith<$Res> {
  __$$BodyMetricImplCopyWithImpl(
      _$BodyMetricImpl _value, $Res Function(_$BodyMetricImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? metricId = null,
    Object? timestamp = null,
    Object? weightKg = freezed,
    Object? bodyFatPercent = freezed,
    Object? waistCm = freezed,
    Object? note = freezed,
  }) {
    return _then(_$BodyMetricImpl(
      metricId: null == metricId
          ? _value.metricId
          : metricId // ignore: cast_nullable_to_non_nullable
              as String,
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
      weightKg: freezed == weightKg
          ? _value.weightKg
          : weightKg // ignore: cast_nullable_to_non_nullable
              as double?,
      bodyFatPercent: freezed == bodyFatPercent
          ? _value.bodyFatPercent
          : bodyFatPercent // ignore: cast_nullable_to_non_nullable
              as double?,
      waistCm: freezed == waistCm
          ? _value.waistCm
          : waistCm // ignore: cast_nullable_to_non_nullable
              as double?,
      note: freezed == note
          ? _value.note
          : note // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$BodyMetricImpl implements _BodyMetric {
  const _$BodyMetricImpl(
      {required this.metricId,
      required this.timestamp,
      this.weightKg,
      this.bodyFatPercent,
      this.waistCm,
      this.note});

  factory _$BodyMetricImpl.fromJson(Map<String, dynamic> json) =>
      _$$BodyMetricImplFromJson(json);

  @override
  final String metricId;
  @override
  final DateTime timestamp;
  @override
  final double? weightKg;
  @override
  final double? bodyFatPercent;
  @override
  final double? waistCm;
  @override
  final String? note;

  @override
  String toString() {
    return 'BodyMetric(metricId: $metricId, timestamp: $timestamp, weightKg: $weightKg, bodyFatPercent: $bodyFatPercent, waistCm: $waistCm, note: $note)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BodyMetricImpl &&
            (identical(other.metricId, metricId) ||
                other.metricId == metricId) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp) &&
            (identical(other.weightKg, weightKg) ||
                other.weightKg == weightKg) &&
            (identical(other.bodyFatPercent, bodyFatPercent) ||
                other.bodyFatPercent == bodyFatPercent) &&
            (identical(other.waistCm, waistCm) || other.waistCm == waistCm) &&
            (identical(other.note, note) || other.note == note));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, metricId, timestamp, weightKg,
      bodyFatPercent, waistCm, note);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$BodyMetricImplCopyWith<_$BodyMetricImpl> get copyWith =>
      __$$BodyMetricImplCopyWithImpl<_$BodyMetricImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BodyMetricImplToJson(
      this,
    );
  }
}

abstract class _BodyMetric implements BodyMetric {
  const factory _BodyMetric(
      {required final String metricId,
      required final DateTime timestamp,
      final double? weightKg,
      final double? bodyFatPercent,
      final double? waistCm,
      final String? note}) = _$BodyMetricImpl;

  factory _BodyMetric.fromJson(Map<String, dynamic> json) =
      _$BodyMetricImpl.fromJson;

  @override
  String get metricId;
  @override
  DateTime get timestamp;
  @override
  double? get weightKg;
  @override
  double? get bodyFatPercent;
  @override
  double? get waistCm;
  @override
  String? get note;
  @override
  @JsonKey(ignore: true)
  _$$BodyMetricImplCopyWith<_$BodyMetricImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
