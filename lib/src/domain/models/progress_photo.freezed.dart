// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'progress_photo.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ProgressPhoto _$ProgressPhotoFromJson(Map<String, dynamic> json) {
  return _ProgressPhoto.fromJson(json);
}

/// @nodoc
mixin _$ProgressPhoto {
  String get photoId => throw _privateConstructorUsedError;
  DateTime get timestamp => throw _privateConstructorUsedError;
  String get filePath => throw _privateConstructorUsedError;
  String? get label => throw _privateConstructorUsedError;
  String? get metadataJson => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ProgressPhotoCopyWith<ProgressPhoto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProgressPhotoCopyWith<$Res> {
  factory $ProgressPhotoCopyWith(
          ProgressPhoto value, $Res Function(ProgressPhoto) then) =
      _$ProgressPhotoCopyWithImpl<$Res, ProgressPhoto>;
  @useResult
  $Res call(
      {String photoId,
      DateTime timestamp,
      String filePath,
      String? label,
      String? metadataJson});
}

/// @nodoc
class _$ProgressPhotoCopyWithImpl<$Res, $Val extends ProgressPhoto>
    implements $ProgressPhotoCopyWith<$Res> {
  _$ProgressPhotoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? photoId = null,
    Object? timestamp = null,
    Object? filePath = null,
    Object? label = freezed,
    Object? metadataJson = freezed,
  }) {
    return _then(_value.copyWith(
      photoId: null == photoId
          ? _value.photoId
          : photoId // ignore: cast_nullable_to_non_nullable
              as String,
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
      filePath: null == filePath
          ? _value.filePath
          : filePath // ignore: cast_nullable_to_non_nullable
              as String,
      label: freezed == label
          ? _value.label
          : label // ignore: cast_nullable_to_non_nullable
              as String?,
      metadataJson: freezed == metadataJson
          ? _value.metadataJson
          : metadataJson // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ProgressPhotoImplCopyWith<$Res>
    implements $ProgressPhotoCopyWith<$Res> {
  factory _$$ProgressPhotoImplCopyWith(
          _$ProgressPhotoImpl value, $Res Function(_$ProgressPhotoImpl) then) =
      __$$ProgressPhotoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String photoId,
      DateTime timestamp,
      String filePath,
      String? label,
      String? metadataJson});
}

/// @nodoc
class __$$ProgressPhotoImplCopyWithImpl<$Res>
    extends _$ProgressPhotoCopyWithImpl<$Res, _$ProgressPhotoImpl>
    implements _$$ProgressPhotoImplCopyWith<$Res> {
  __$$ProgressPhotoImplCopyWithImpl(
      _$ProgressPhotoImpl _value, $Res Function(_$ProgressPhotoImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? photoId = null,
    Object? timestamp = null,
    Object? filePath = null,
    Object? label = freezed,
    Object? metadataJson = freezed,
  }) {
    return _then(_$ProgressPhotoImpl(
      photoId: null == photoId
          ? _value.photoId
          : photoId // ignore: cast_nullable_to_non_nullable
              as String,
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
      filePath: null == filePath
          ? _value.filePath
          : filePath // ignore: cast_nullable_to_non_nullable
              as String,
      label: freezed == label
          ? _value.label
          : label // ignore: cast_nullable_to_non_nullable
              as String?,
      metadataJson: freezed == metadataJson
          ? _value.metadataJson
          : metadataJson // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ProgressPhotoImpl implements _ProgressPhoto {
  const _$ProgressPhotoImpl(
      {required this.photoId,
      required this.timestamp,
      required this.filePath,
      this.label,
      this.metadataJson});

  factory _$ProgressPhotoImpl.fromJson(Map<String, dynamic> json) =>
      _$$ProgressPhotoImplFromJson(json);

  @override
  final String photoId;
  @override
  final DateTime timestamp;
  @override
  final String filePath;
  @override
  final String? label;
  @override
  final String? metadataJson;

  @override
  String toString() {
    return 'ProgressPhoto(photoId: $photoId, timestamp: $timestamp, filePath: $filePath, label: $label, metadataJson: $metadataJson)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProgressPhotoImpl &&
            (identical(other.photoId, photoId) || other.photoId == photoId) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp) &&
            (identical(other.filePath, filePath) ||
                other.filePath == filePath) &&
            (identical(other.label, label) || other.label == label) &&
            (identical(other.metadataJson, metadataJson) ||
                other.metadataJson == metadataJson));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType, photoId, timestamp, filePath, label, metadataJson);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ProgressPhotoImplCopyWith<_$ProgressPhotoImpl> get copyWith =>
      __$$ProgressPhotoImplCopyWithImpl<_$ProgressPhotoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ProgressPhotoImplToJson(
      this,
    );
  }
}

abstract class _ProgressPhoto implements ProgressPhoto {
  const factory _ProgressPhoto(
      {required final String photoId,
      required final DateTime timestamp,
      required final String filePath,
      final String? label,
      final String? metadataJson}) = _$ProgressPhotoImpl;

  factory _ProgressPhoto.fromJson(Map<String, dynamic> json) =
      _$ProgressPhotoImpl.fromJson;

  @override
  String get photoId;
  @override
  DateTime get timestamp;
  @override
  String get filePath;
  @override
  String? get label;
  @override
  String? get metadataJson;
  @override
  @JsonKey(ignore: true)
  _$$ProgressPhotoImplCopyWith<_$ProgressPhotoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
