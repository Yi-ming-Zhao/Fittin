// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'training_plan.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

PlanTemplate _$PlanTemplateFromJson(Map<String, dynamic> json) {
  return _PlanTemplate.fromJson(json);
}

/// @nodoc
mixin _$PlanTemplate {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  Map<String, String> get localizedName => throw _privateConstructorUsedError;
  Map<String, String> get localizedDescription =>
      throw _privateConstructorUsedError;
  String get engineFamily => throw _privateConstructorUsedError;
  List<String> get requiredTrainingMaxKeys =>
      throw _privateConstructorUsedError;
  Map<String, dynamic> get engineConfig => throw _privateConstructorUsedError;
  List<Phase> get phases => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $PlanTemplateCopyWith<PlanTemplate> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PlanTemplateCopyWith<$Res> {
  factory $PlanTemplateCopyWith(
          PlanTemplate value, $Res Function(PlanTemplate) then) =
      _$PlanTemplateCopyWithImpl<$Res, PlanTemplate>;
  @useResult
  $Res call(
      {String id,
      String name,
      String description,
      Map<String, String> localizedName,
      Map<String, String> localizedDescription,
      String engineFamily,
      List<String> requiredTrainingMaxKeys,
      Map<String, dynamic> engineConfig,
      List<Phase> phases});
}

/// @nodoc
class _$PlanTemplateCopyWithImpl<$Res, $Val extends PlanTemplate>
    implements $PlanTemplateCopyWith<$Res> {
  _$PlanTemplateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = null,
    Object? localizedName = null,
    Object? localizedDescription = null,
    Object? engineFamily = null,
    Object? requiredTrainingMaxKeys = null,
    Object? engineConfig = null,
    Object? phases = null,
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
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      localizedName: null == localizedName
          ? _value.localizedName
          : localizedName // ignore: cast_nullable_to_non_nullable
              as Map<String, String>,
      localizedDescription: null == localizedDescription
          ? _value.localizedDescription
          : localizedDescription // ignore: cast_nullable_to_non_nullable
              as Map<String, String>,
      engineFamily: null == engineFamily
          ? _value.engineFamily
          : engineFamily // ignore: cast_nullable_to_non_nullable
              as String,
      requiredTrainingMaxKeys: null == requiredTrainingMaxKeys
          ? _value.requiredTrainingMaxKeys
          : requiredTrainingMaxKeys // ignore: cast_nullable_to_non_nullable
              as List<String>,
      engineConfig: null == engineConfig
          ? _value.engineConfig
          : engineConfig // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      phases: null == phases
          ? _value.phases
          : phases // ignore: cast_nullable_to_non_nullable
              as List<Phase>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PlanTemplateImplCopyWith<$Res>
    implements $PlanTemplateCopyWith<$Res> {
  factory _$$PlanTemplateImplCopyWith(
          _$PlanTemplateImpl value, $Res Function(_$PlanTemplateImpl) then) =
      __$$PlanTemplateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      String description,
      Map<String, String> localizedName,
      Map<String, String> localizedDescription,
      String engineFamily,
      List<String> requiredTrainingMaxKeys,
      Map<String, dynamic> engineConfig,
      List<Phase> phases});
}

/// @nodoc
class __$$PlanTemplateImplCopyWithImpl<$Res>
    extends _$PlanTemplateCopyWithImpl<$Res, _$PlanTemplateImpl>
    implements _$$PlanTemplateImplCopyWith<$Res> {
  __$$PlanTemplateImplCopyWithImpl(
      _$PlanTemplateImpl _value, $Res Function(_$PlanTemplateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = null,
    Object? localizedName = null,
    Object? localizedDescription = null,
    Object? engineFamily = null,
    Object? requiredTrainingMaxKeys = null,
    Object? engineConfig = null,
    Object? phases = null,
  }) {
    return _then(_$PlanTemplateImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      localizedName: null == localizedName
          ? _value._localizedName
          : localizedName // ignore: cast_nullable_to_non_nullable
              as Map<String, String>,
      localizedDescription: null == localizedDescription
          ? _value._localizedDescription
          : localizedDescription // ignore: cast_nullable_to_non_nullable
              as Map<String, String>,
      engineFamily: null == engineFamily
          ? _value.engineFamily
          : engineFamily // ignore: cast_nullable_to_non_nullable
              as String,
      requiredTrainingMaxKeys: null == requiredTrainingMaxKeys
          ? _value._requiredTrainingMaxKeys
          : requiredTrainingMaxKeys // ignore: cast_nullable_to_non_nullable
              as List<String>,
      engineConfig: null == engineConfig
          ? _value._engineConfig
          : engineConfig // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      phases: null == phases
          ? _value._phases
          : phases // ignore: cast_nullable_to_non_nullable
              as List<Phase>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PlanTemplateImpl implements _PlanTemplate {
  const _$PlanTemplateImpl(
      {required this.id,
      required this.name,
      required this.description,
      final Map<String, String> localizedName = const <String, String>{},
      final Map<String, String> localizedDescription = const <String, String>{},
      this.engineFamily = 'legacy',
      final List<String> requiredTrainingMaxKeys = const [],
      final Map<String, dynamic> engineConfig = const <String, dynamic>{},
      required final List<Phase> phases})
      : _localizedName = localizedName,
        _localizedDescription = localizedDescription,
        _requiredTrainingMaxKeys = requiredTrainingMaxKeys,
        _engineConfig = engineConfig,
        _phases = phases;

  factory _$PlanTemplateImpl.fromJson(Map<String, dynamic> json) =>
      _$$PlanTemplateImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String description;
  final Map<String, String> _localizedName;
  @override
  @JsonKey()
  Map<String, String> get localizedName {
    if (_localizedName is EqualUnmodifiableMapView) return _localizedName;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_localizedName);
  }

  final Map<String, String> _localizedDescription;
  @override
  @JsonKey()
  Map<String, String> get localizedDescription {
    if (_localizedDescription is EqualUnmodifiableMapView)
      return _localizedDescription;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_localizedDescription);
  }

  @override
  @JsonKey()
  final String engineFamily;
  final List<String> _requiredTrainingMaxKeys;
  @override
  @JsonKey()
  List<String> get requiredTrainingMaxKeys {
    if (_requiredTrainingMaxKeys is EqualUnmodifiableListView)
      return _requiredTrainingMaxKeys;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_requiredTrainingMaxKeys);
  }

  final Map<String, dynamic> _engineConfig;
  @override
  @JsonKey()
  Map<String, dynamic> get engineConfig {
    if (_engineConfig is EqualUnmodifiableMapView) return _engineConfig;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_engineConfig);
  }

  final List<Phase> _phases;
  @override
  List<Phase> get phases {
    if (_phases is EqualUnmodifiableListView) return _phases;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_phases);
  }

  @override
  String toString() {
    return 'PlanTemplate(id: $id, name: $name, description: $description, localizedName: $localizedName, localizedDescription: $localizedDescription, engineFamily: $engineFamily, requiredTrainingMaxKeys: $requiredTrainingMaxKeys, engineConfig: $engineConfig, phases: $phases)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PlanTemplateImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            const DeepCollectionEquality()
                .equals(other._localizedName, _localizedName) &&
            const DeepCollectionEquality()
                .equals(other._localizedDescription, _localizedDescription) &&
            (identical(other.engineFamily, engineFamily) ||
                other.engineFamily == engineFamily) &&
            const DeepCollectionEquality().equals(
                other._requiredTrainingMaxKeys, _requiredTrainingMaxKeys) &&
            const DeepCollectionEquality()
                .equals(other._engineConfig, _engineConfig) &&
            const DeepCollectionEquality().equals(other._phases, _phases));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      name,
      description,
      const DeepCollectionEquality().hash(_localizedName),
      const DeepCollectionEquality().hash(_localizedDescription),
      engineFamily,
      const DeepCollectionEquality().hash(_requiredTrainingMaxKeys),
      const DeepCollectionEquality().hash(_engineConfig),
      const DeepCollectionEquality().hash(_phases));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$PlanTemplateImplCopyWith<_$PlanTemplateImpl> get copyWith =>
      __$$PlanTemplateImplCopyWithImpl<_$PlanTemplateImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PlanTemplateImplToJson(
      this,
    );
  }
}

abstract class _PlanTemplate implements PlanTemplate {
  const factory _PlanTemplate(
      {required final String id,
      required final String name,
      required final String description,
      final Map<String, String> localizedName,
      final Map<String, String> localizedDescription,
      final String engineFamily,
      final List<String> requiredTrainingMaxKeys,
      final Map<String, dynamic> engineConfig,
      required final List<Phase> phases}) = _$PlanTemplateImpl;

  factory _PlanTemplate.fromJson(Map<String, dynamic> json) =
      _$PlanTemplateImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String get description;
  @override
  Map<String, String> get localizedName;
  @override
  Map<String, String> get localizedDescription;
  @override
  String get engineFamily;
  @override
  List<String> get requiredTrainingMaxKeys;
  @override
  Map<String, dynamic> get engineConfig;
  @override
  List<Phase> get phases;
  @override
  @JsonKey(ignore: true)
  _$$PlanTemplateImplCopyWith<_$PlanTemplateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Phase _$PhaseFromJson(Map<String, dynamic> json) {
  return _Phase.fromJson(json);
}

/// @nodoc
mixin _$Phase {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  List<Workout> get workouts => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $PhaseCopyWith<Phase> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PhaseCopyWith<$Res> {
  factory $PhaseCopyWith(Phase value, $Res Function(Phase) then) =
      _$PhaseCopyWithImpl<$Res, Phase>;
  @useResult
  $Res call({String id, String name, List<Workout> workouts});
}

/// @nodoc
class _$PhaseCopyWithImpl<$Res, $Val extends Phase>
    implements $PhaseCopyWith<$Res> {
  _$PhaseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? workouts = null,
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
      workouts: null == workouts
          ? _value.workouts
          : workouts // ignore: cast_nullable_to_non_nullable
              as List<Workout>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PhaseImplCopyWith<$Res> implements $PhaseCopyWith<$Res> {
  factory _$$PhaseImplCopyWith(
          _$PhaseImpl value, $Res Function(_$PhaseImpl) then) =
      __$$PhaseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String id, String name, List<Workout> workouts});
}

/// @nodoc
class __$$PhaseImplCopyWithImpl<$Res>
    extends _$PhaseCopyWithImpl<$Res, _$PhaseImpl>
    implements _$$PhaseImplCopyWith<$Res> {
  __$$PhaseImplCopyWithImpl(
      _$PhaseImpl _value, $Res Function(_$PhaseImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? workouts = null,
  }) {
    return _then(_$PhaseImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      workouts: null == workouts
          ? _value._workouts
          : workouts // ignore: cast_nullable_to_non_nullable
              as List<Workout>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PhaseImpl implements _Phase {
  const _$PhaseImpl(
      {required this.id,
      required this.name,
      required final List<Workout> workouts})
      : _workouts = workouts;

  factory _$PhaseImpl.fromJson(Map<String, dynamic> json) =>
      _$$PhaseImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  final List<Workout> _workouts;
  @override
  List<Workout> get workouts {
    if (_workouts is EqualUnmodifiableListView) return _workouts;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_workouts);
  }

  @override
  String toString() {
    return 'Phase(id: $id, name: $name, workouts: $workouts)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PhaseImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            const DeepCollectionEquality().equals(other._workouts, _workouts));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType, id, name, const DeepCollectionEquality().hash(_workouts));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$PhaseImplCopyWith<_$PhaseImpl> get copyWith =>
      __$$PhaseImplCopyWithImpl<_$PhaseImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PhaseImplToJson(
      this,
    );
  }
}

abstract class _Phase implements Phase {
  const factory _Phase(
      {required final String id,
      required final String name,
      required final List<Workout> workouts}) = _$PhaseImpl;

  factory _Phase.fromJson(Map<String, dynamic> json) = _$PhaseImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  List<Workout> get workouts;
  @override
  @JsonKey(ignore: true)
  _$$PhaseImplCopyWith<_$PhaseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Workout _$WorkoutFromJson(Map<String, dynamic> json) {
  return _Workout.fromJson(json);
}

/// @nodoc
mixin _$Workout {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  Map<String, String> get localizedName => throw _privateConstructorUsedError;
  String get dayLabel => throw _privateConstructorUsedError;
  Map<String, String> get localizedDayLabel =>
      throw _privateConstructorUsedError;
  int get estimatedDurationMinutes => throw _privateConstructorUsedError;
  List<Exercise> get exercises => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $WorkoutCopyWith<Workout> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WorkoutCopyWith<$Res> {
  factory $WorkoutCopyWith(Workout value, $Res Function(Workout) then) =
      _$WorkoutCopyWithImpl<$Res, Workout>;
  @useResult
  $Res call(
      {String id,
      String name,
      Map<String, String> localizedName,
      String dayLabel,
      Map<String, String> localizedDayLabel,
      int estimatedDurationMinutes,
      List<Exercise> exercises});
}

/// @nodoc
class _$WorkoutCopyWithImpl<$Res, $Val extends Workout>
    implements $WorkoutCopyWith<$Res> {
  _$WorkoutCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? localizedName = null,
    Object? dayLabel = null,
    Object? localizedDayLabel = null,
    Object? estimatedDurationMinutes = null,
    Object? exercises = null,
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
      localizedName: null == localizedName
          ? _value.localizedName
          : localizedName // ignore: cast_nullable_to_non_nullable
              as Map<String, String>,
      dayLabel: null == dayLabel
          ? _value.dayLabel
          : dayLabel // ignore: cast_nullable_to_non_nullable
              as String,
      localizedDayLabel: null == localizedDayLabel
          ? _value.localizedDayLabel
          : localizedDayLabel // ignore: cast_nullable_to_non_nullable
              as Map<String, String>,
      estimatedDurationMinutes: null == estimatedDurationMinutes
          ? _value.estimatedDurationMinutes
          : estimatedDurationMinutes // ignore: cast_nullable_to_non_nullable
              as int,
      exercises: null == exercises
          ? _value.exercises
          : exercises // ignore: cast_nullable_to_non_nullable
              as List<Exercise>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$WorkoutImplCopyWith<$Res> implements $WorkoutCopyWith<$Res> {
  factory _$$WorkoutImplCopyWith(
          _$WorkoutImpl value, $Res Function(_$WorkoutImpl) then) =
      __$$WorkoutImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      Map<String, String> localizedName,
      String dayLabel,
      Map<String, String> localizedDayLabel,
      int estimatedDurationMinutes,
      List<Exercise> exercises});
}

/// @nodoc
class __$$WorkoutImplCopyWithImpl<$Res>
    extends _$WorkoutCopyWithImpl<$Res, _$WorkoutImpl>
    implements _$$WorkoutImplCopyWith<$Res> {
  __$$WorkoutImplCopyWithImpl(
      _$WorkoutImpl _value, $Res Function(_$WorkoutImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? localizedName = null,
    Object? dayLabel = null,
    Object? localizedDayLabel = null,
    Object? estimatedDurationMinutes = null,
    Object? exercises = null,
  }) {
    return _then(_$WorkoutImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      localizedName: null == localizedName
          ? _value._localizedName
          : localizedName // ignore: cast_nullable_to_non_nullable
              as Map<String, String>,
      dayLabel: null == dayLabel
          ? _value.dayLabel
          : dayLabel // ignore: cast_nullable_to_non_nullable
              as String,
      localizedDayLabel: null == localizedDayLabel
          ? _value._localizedDayLabel
          : localizedDayLabel // ignore: cast_nullable_to_non_nullable
              as Map<String, String>,
      estimatedDurationMinutes: null == estimatedDurationMinutes
          ? _value.estimatedDurationMinutes
          : estimatedDurationMinutes // ignore: cast_nullable_to_non_nullable
              as int,
      exercises: null == exercises
          ? _value._exercises
          : exercises // ignore: cast_nullable_to_non_nullable
              as List<Exercise>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$WorkoutImpl implements _Workout {
  const _$WorkoutImpl(
      {required this.id,
      required this.name,
      final Map<String, String> localizedName = const <String, String>{},
      this.dayLabel = '',
      final Map<String, String> localizedDayLabel = const <String, String>{},
      this.estimatedDurationMinutes = 45,
      required final List<Exercise> exercises})
      : _localizedName = localizedName,
        _localizedDayLabel = localizedDayLabel,
        _exercises = exercises;

  factory _$WorkoutImpl.fromJson(Map<String, dynamic> json) =>
      _$$WorkoutImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  final Map<String, String> _localizedName;
  @override
  @JsonKey()
  Map<String, String> get localizedName {
    if (_localizedName is EqualUnmodifiableMapView) return _localizedName;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_localizedName);
  }

  @override
  @JsonKey()
  final String dayLabel;
  final Map<String, String> _localizedDayLabel;
  @override
  @JsonKey()
  Map<String, String> get localizedDayLabel {
    if (_localizedDayLabel is EqualUnmodifiableMapView)
      return _localizedDayLabel;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_localizedDayLabel);
  }

  @override
  @JsonKey()
  final int estimatedDurationMinutes;
  final List<Exercise> _exercises;
  @override
  List<Exercise> get exercises {
    if (_exercises is EqualUnmodifiableListView) return _exercises;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_exercises);
  }

  @override
  String toString() {
    return 'Workout(id: $id, name: $name, localizedName: $localizedName, dayLabel: $dayLabel, localizedDayLabel: $localizedDayLabel, estimatedDurationMinutes: $estimatedDurationMinutes, exercises: $exercises)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WorkoutImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            const DeepCollectionEquality()
                .equals(other._localizedName, _localizedName) &&
            (identical(other.dayLabel, dayLabel) ||
                other.dayLabel == dayLabel) &&
            const DeepCollectionEquality()
                .equals(other._localizedDayLabel, _localizedDayLabel) &&
            (identical(
                    other.estimatedDurationMinutes, estimatedDurationMinutes) ||
                other.estimatedDurationMinutes == estimatedDurationMinutes) &&
            const DeepCollectionEquality()
                .equals(other._exercises, _exercises));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      name,
      const DeepCollectionEquality().hash(_localizedName),
      dayLabel,
      const DeepCollectionEquality().hash(_localizedDayLabel),
      estimatedDurationMinutes,
      const DeepCollectionEquality().hash(_exercises));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$WorkoutImplCopyWith<_$WorkoutImpl> get copyWith =>
      __$$WorkoutImplCopyWithImpl<_$WorkoutImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$WorkoutImplToJson(
      this,
    );
  }
}

abstract class _Workout implements Workout {
  const factory _Workout(
      {required final String id,
      required final String name,
      final Map<String, String> localizedName,
      final String dayLabel,
      final Map<String, String> localizedDayLabel,
      final int estimatedDurationMinutes,
      required final List<Exercise> exercises}) = _$WorkoutImpl;

  factory _Workout.fromJson(Map<String, dynamic> json) = _$WorkoutImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  Map<String, String> get localizedName;
  @override
  String get dayLabel;
  @override
  Map<String, String> get localizedDayLabel;
  @override
  int get estimatedDurationMinutes;
  @override
  List<Exercise> get exercises;
  @override
  @JsonKey(ignore: true)
  _$$WorkoutImplCopyWith<_$WorkoutImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Exercise _$ExerciseFromJson(Map<String, dynamic> json) {
  return _Exercise.fromJson(json);
}

/// @nodoc
mixin _$Exercise {
  String get id => throw _privateConstructorUsedError;
  String get exerciseId =>
      throw _privateConstructorUsedError; // global ID like 'squat', 'bench_press'
  String get name => throw _privateConstructorUsedError;
  Map<String, String> get localizedName => throw _privateConstructorUsedError;
  double get initialBaseWeight => throw _privateConstructorUsedError;
  String get tier => throw _privateConstructorUsedError;
  int get restSeconds => throw _privateConstructorUsedError;
  String? get trainingMaxLift => throw _privateConstructorUsedError;
  double get trainingMaxMultiplier => throw _privateConstructorUsedError;
  double get roundingIncrement => throw _privateConstructorUsedError;
  Map<String, dynamic> get engineConfig => throw _privateConstructorUsedError;
  List<SetScheme> get stages => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ExerciseCopyWith<Exercise> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ExerciseCopyWith<$Res> {
  factory $ExerciseCopyWith(Exercise value, $Res Function(Exercise) then) =
      _$ExerciseCopyWithImpl<$Res, Exercise>;
  @useResult
  $Res call(
      {String id,
      String exerciseId,
      String name,
      Map<String, String> localizedName,
      double initialBaseWeight,
      String tier,
      int restSeconds,
      String? trainingMaxLift,
      double trainingMaxMultiplier,
      double roundingIncrement,
      Map<String, dynamic> engineConfig,
      List<SetScheme> stages});
}

/// @nodoc
class _$ExerciseCopyWithImpl<$Res, $Val extends Exercise>
    implements $ExerciseCopyWith<$Res> {
  _$ExerciseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? exerciseId = null,
    Object? name = null,
    Object? localizedName = null,
    Object? initialBaseWeight = null,
    Object? tier = null,
    Object? restSeconds = null,
    Object? trainingMaxLift = freezed,
    Object? trainingMaxMultiplier = null,
    Object? roundingIncrement = null,
    Object? engineConfig = null,
    Object? stages = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      exerciseId: null == exerciseId
          ? _value.exerciseId
          : exerciseId // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      localizedName: null == localizedName
          ? _value.localizedName
          : localizedName // ignore: cast_nullable_to_non_nullable
              as Map<String, String>,
      initialBaseWeight: null == initialBaseWeight
          ? _value.initialBaseWeight
          : initialBaseWeight // ignore: cast_nullable_to_non_nullable
              as double,
      tier: null == tier
          ? _value.tier
          : tier // ignore: cast_nullable_to_non_nullable
              as String,
      restSeconds: null == restSeconds
          ? _value.restSeconds
          : restSeconds // ignore: cast_nullable_to_non_nullable
              as int,
      trainingMaxLift: freezed == trainingMaxLift
          ? _value.trainingMaxLift
          : trainingMaxLift // ignore: cast_nullable_to_non_nullable
              as String?,
      trainingMaxMultiplier: null == trainingMaxMultiplier
          ? _value.trainingMaxMultiplier
          : trainingMaxMultiplier // ignore: cast_nullable_to_non_nullable
              as double,
      roundingIncrement: null == roundingIncrement
          ? _value.roundingIncrement
          : roundingIncrement // ignore: cast_nullable_to_non_nullable
              as double,
      engineConfig: null == engineConfig
          ? _value.engineConfig
          : engineConfig // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      stages: null == stages
          ? _value.stages
          : stages // ignore: cast_nullable_to_non_nullable
              as List<SetScheme>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ExerciseImplCopyWith<$Res>
    implements $ExerciseCopyWith<$Res> {
  factory _$$ExerciseImplCopyWith(
          _$ExerciseImpl value, $Res Function(_$ExerciseImpl) then) =
      __$$ExerciseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String exerciseId,
      String name,
      Map<String, String> localizedName,
      double initialBaseWeight,
      String tier,
      int restSeconds,
      String? trainingMaxLift,
      double trainingMaxMultiplier,
      double roundingIncrement,
      Map<String, dynamic> engineConfig,
      List<SetScheme> stages});
}

/// @nodoc
class __$$ExerciseImplCopyWithImpl<$Res>
    extends _$ExerciseCopyWithImpl<$Res, _$ExerciseImpl>
    implements _$$ExerciseImplCopyWith<$Res> {
  __$$ExerciseImplCopyWithImpl(
      _$ExerciseImpl _value, $Res Function(_$ExerciseImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? exerciseId = null,
    Object? name = null,
    Object? localizedName = null,
    Object? initialBaseWeight = null,
    Object? tier = null,
    Object? restSeconds = null,
    Object? trainingMaxLift = freezed,
    Object? trainingMaxMultiplier = null,
    Object? roundingIncrement = null,
    Object? engineConfig = null,
    Object? stages = null,
  }) {
    return _then(_$ExerciseImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      exerciseId: null == exerciseId
          ? _value.exerciseId
          : exerciseId // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      localizedName: null == localizedName
          ? _value._localizedName
          : localizedName // ignore: cast_nullable_to_non_nullable
              as Map<String, String>,
      initialBaseWeight: null == initialBaseWeight
          ? _value.initialBaseWeight
          : initialBaseWeight // ignore: cast_nullable_to_non_nullable
              as double,
      tier: null == tier
          ? _value.tier
          : tier // ignore: cast_nullable_to_non_nullable
              as String,
      restSeconds: null == restSeconds
          ? _value.restSeconds
          : restSeconds // ignore: cast_nullable_to_non_nullable
              as int,
      trainingMaxLift: freezed == trainingMaxLift
          ? _value.trainingMaxLift
          : trainingMaxLift // ignore: cast_nullable_to_non_nullable
              as String?,
      trainingMaxMultiplier: null == trainingMaxMultiplier
          ? _value.trainingMaxMultiplier
          : trainingMaxMultiplier // ignore: cast_nullable_to_non_nullable
              as double,
      roundingIncrement: null == roundingIncrement
          ? _value.roundingIncrement
          : roundingIncrement // ignore: cast_nullable_to_non_nullable
              as double,
      engineConfig: null == engineConfig
          ? _value._engineConfig
          : engineConfig // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      stages: null == stages
          ? _value._stages
          : stages // ignore: cast_nullable_to_non_nullable
              as List<SetScheme>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ExerciseImpl implements _Exercise {
  const _$ExerciseImpl(
      {required this.id,
      required this.exerciseId,
      required this.name,
      final Map<String, String> localizedName = const <String, String>{},
      this.initialBaseWeight = 0,
      this.tier = 'T2',
      this.restSeconds = 120,
      this.trainingMaxLift,
      this.trainingMaxMultiplier = 1.0,
      this.roundingIncrement = 2.5,
      final Map<String, dynamic> engineConfig = const <String, dynamic>{},
      required final List<SetScheme> stages})
      : _localizedName = localizedName,
        _engineConfig = engineConfig,
        _stages = stages;

  factory _$ExerciseImpl.fromJson(Map<String, dynamic> json) =>
      _$$ExerciseImplFromJson(json);

  @override
  final String id;
  @override
  final String exerciseId;
// global ID like 'squat', 'bench_press'
  @override
  final String name;
  final Map<String, String> _localizedName;
  @override
  @JsonKey()
  Map<String, String> get localizedName {
    if (_localizedName is EqualUnmodifiableMapView) return _localizedName;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_localizedName);
  }

  @override
  @JsonKey()
  final double initialBaseWeight;
  @override
  @JsonKey()
  final String tier;
  @override
  @JsonKey()
  final int restSeconds;
  @override
  final String? trainingMaxLift;
  @override
  @JsonKey()
  final double trainingMaxMultiplier;
  @override
  @JsonKey()
  final double roundingIncrement;
  final Map<String, dynamic> _engineConfig;
  @override
  @JsonKey()
  Map<String, dynamic> get engineConfig {
    if (_engineConfig is EqualUnmodifiableMapView) return _engineConfig;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_engineConfig);
  }

  final List<SetScheme> _stages;
  @override
  List<SetScheme> get stages {
    if (_stages is EqualUnmodifiableListView) return _stages;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_stages);
  }

  @override
  String toString() {
    return 'Exercise(id: $id, exerciseId: $exerciseId, name: $name, localizedName: $localizedName, initialBaseWeight: $initialBaseWeight, tier: $tier, restSeconds: $restSeconds, trainingMaxLift: $trainingMaxLift, trainingMaxMultiplier: $trainingMaxMultiplier, roundingIncrement: $roundingIncrement, engineConfig: $engineConfig, stages: $stages)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ExerciseImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.exerciseId, exerciseId) ||
                other.exerciseId == exerciseId) &&
            (identical(other.name, name) || other.name == name) &&
            const DeepCollectionEquality()
                .equals(other._localizedName, _localizedName) &&
            (identical(other.initialBaseWeight, initialBaseWeight) ||
                other.initialBaseWeight == initialBaseWeight) &&
            (identical(other.tier, tier) || other.tier == tier) &&
            (identical(other.restSeconds, restSeconds) ||
                other.restSeconds == restSeconds) &&
            (identical(other.trainingMaxLift, trainingMaxLift) ||
                other.trainingMaxLift == trainingMaxLift) &&
            (identical(other.trainingMaxMultiplier, trainingMaxMultiplier) ||
                other.trainingMaxMultiplier == trainingMaxMultiplier) &&
            (identical(other.roundingIncrement, roundingIncrement) ||
                other.roundingIncrement == roundingIncrement) &&
            const DeepCollectionEquality()
                .equals(other._engineConfig, _engineConfig) &&
            const DeepCollectionEquality().equals(other._stages, _stages));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      exerciseId,
      name,
      const DeepCollectionEquality().hash(_localizedName),
      initialBaseWeight,
      tier,
      restSeconds,
      trainingMaxLift,
      trainingMaxMultiplier,
      roundingIncrement,
      const DeepCollectionEquality().hash(_engineConfig),
      const DeepCollectionEquality().hash(_stages));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ExerciseImplCopyWith<_$ExerciseImpl> get copyWith =>
      __$$ExerciseImplCopyWithImpl<_$ExerciseImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ExerciseImplToJson(
      this,
    );
  }
}

abstract class _Exercise implements Exercise {
  const factory _Exercise(
      {required final String id,
      required final String exerciseId,
      required final String name,
      final Map<String, String> localizedName,
      final double initialBaseWeight,
      final String tier,
      final int restSeconds,
      final String? trainingMaxLift,
      final double trainingMaxMultiplier,
      final double roundingIncrement,
      final Map<String, dynamic> engineConfig,
      required final List<SetScheme> stages}) = _$ExerciseImpl;

  factory _Exercise.fromJson(Map<String, dynamic> json) =
      _$ExerciseImpl.fromJson;

  @override
  String get id;
  @override
  String get exerciseId;
  @override // global ID like 'squat', 'bench_press'
  String get name;
  @override
  Map<String, String> get localizedName;
  @override
  double get initialBaseWeight;
  @override
  String get tier;
  @override
  int get restSeconds;
  @override
  String? get trainingMaxLift;
  @override
  double get trainingMaxMultiplier;
  @override
  double get roundingIncrement;
  @override
  Map<String, dynamic> get engineConfig;
  @override
  List<SetScheme> get stages;
  @override
  @JsonKey(ignore: true)
  _$$ExerciseImplCopyWith<_$ExerciseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SetScheme _$SetSchemeFromJson(Map<String, dynamic> json) {
  return _SetScheme.fromJson(json);
}

/// @nodoc
mixin _$SetScheme {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  double get basePercent => throw _privateConstructorUsedError;
  int get order => throw _privateConstructorUsedError;
  Map<String, dynamic> get engineConfig => throw _privateConstructorUsedError;
  List<SetDefinition> get sets => throw _privateConstructorUsedError;
  List<ProgressionRule> get rules => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $SetSchemeCopyWith<SetScheme> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SetSchemeCopyWith<$Res> {
  factory $SetSchemeCopyWith(SetScheme value, $Res Function(SetScheme) then) =
      _$SetSchemeCopyWithImpl<$Res, SetScheme>;
  @useResult
  $Res call(
      {String id,
      String name,
      double basePercent,
      int order,
      Map<String, dynamic> engineConfig,
      List<SetDefinition> sets,
      List<ProgressionRule> rules});
}

/// @nodoc
class _$SetSchemeCopyWithImpl<$Res, $Val extends SetScheme>
    implements $SetSchemeCopyWith<$Res> {
  _$SetSchemeCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? basePercent = null,
    Object? order = null,
    Object? engineConfig = null,
    Object? sets = null,
    Object? rules = null,
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
      basePercent: null == basePercent
          ? _value.basePercent
          : basePercent // ignore: cast_nullable_to_non_nullable
              as double,
      order: null == order
          ? _value.order
          : order // ignore: cast_nullable_to_non_nullable
              as int,
      engineConfig: null == engineConfig
          ? _value.engineConfig
          : engineConfig // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      sets: null == sets
          ? _value.sets
          : sets // ignore: cast_nullable_to_non_nullable
              as List<SetDefinition>,
      rules: null == rules
          ? _value.rules
          : rules // ignore: cast_nullable_to_non_nullable
              as List<ProgressionRule>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SetSchemeImplCopyWith<$Res>
    implements $SetSchemeCopyWith<$Res> {
  factory _$$SetSchemeImplCopyWith(
          _$SetSchemeImpl value, $Res Function(_$SetSchemeImpl) then) =
      __$$SetSchemeImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      double basePercent,
      int order,
      Map<String, dynamic> engineConfig,
      List<SetDefinition> sets,
      List<ProgressionRule> rules});
}

/// @nodoc
class __$$SetSchemeImplCopyWithImpl<$Res>
    extends _$SetSchemeCopyWithImpl<$Res, _$SetSchemeImpl>
    implements _$$SetSchemeImplCopyWith<$Res> {
  __$$SetSchemeImplCopyWithImpl(
      _$SetSchemeImpl _value, $Res Function(_$SetSchemeImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? basePercent = null,
    Object? order = null,
    Object? engineConfig = null,
    Object? sets = null,
    Object? rules = null,
  }) {
    return _then(_$SetSchemeImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      basePercent: null == basePercent
          ? _value.basePercent
          : basePercent // ignore: cast_nullable_to_non_nullable
              as double,
      order: null == order
          ? _value.order
          : order // ignore: cast_nullable_to_non_nullable
              as int,
      engineConfig: null == engineConfig
          ? _value._engineConfig
          : engineConfig // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      sets: null == sets
          ? _value._sets
          : sets // ignore: cast_nullable_to_non_nullable
              as List<SetDefinition>,
      rules: null == rules
          ? _value._rules
          : rules // ignore: cast_nullable_to_non_nullable
              as List<ProgressionRule>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SetSchemeImpl implements _SetScheme {
  const _$SetSchemeImpl(
      {required this.id,
      required this.name,
      this.basePercent = 1.0,
      this.order = 0,
      final Map<String, dynamic> engineConfig = const <String, dynamic>{},
      required final List<SetDefinition> sets,
      required final List<ProgressionRule> rules})
      : _engineConfig = engineConfig,
        _sets = sets,
        _rules = rules;

  factory _$SetSchemeImpl.fromJson(Map<String, dynamic> json) =>
      _$$SetSchemeImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  @JsonKey()
  final double basePercent;
  @override
  @JsonKey()
  final int order;
  final Map<String, dynamic> _engineConfig;
  @override
  @JsonKey()
  Map<String, dynamic> get engineConfig {
    if (_engineConfig is EqualUnmodifiableMapView) return _engineConfig;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_engineConfig);
  }

  final List<SetDefinition> _sets;
  @override
  List<SetDefinition> get sets {
    if (_sets is EqualUnmodifiableListView) return _sets;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_sets);
  }

  final List<ProgressionRule> _rules;
  @override
  List<ProgressionRule> get rules {
    if (_rules is EqualUnmodifiableListView) return _rules;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_rules);
  }

  @override
  String toString() {
    return 'SetScheme(id: $id, name: $name, basePercent: $basePercent, order: $order, engineConfig: $engineConfig, sets: $sets, rules: $rules)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SetSchemeImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.basePercent, basePercent) ||
                other.basePercent == basePercent) &&
            (identical(other.order, order) || other.order == order) &&
            const DeepCollectionEquality()
                .equals(other._engineConfig, _engineConfig) &&
            const DeepCollectionEquality().equals(other._sets, _sets) &&
            const DeepCollectionEquality().equals(other._rules, _rules));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      name,
      basePercent,
      order,
      const DeepCollectionEquality().hash(_engineConfig),
      const DeepCollectionEquality().hash(_sets),
      const DeepCollectionEquality().hash(_rules));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$SetSchemeImplCopyWith<_$SetSchemeImpl> get copyWith =>
      __$$SetSchemeImplCopyWithImpl<_$SetSchemeImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SetSchemeImplToJson(
      this,
    );
  }
}

abstract class _SetScheme implements SetScheme {
  const factory _SetScheme(
      {required final String id,
      required final String name,
      final double basePercent,
      final int order,
      final Map<String, dynamic> engineConfig,
      required final List<SetDefinition> sets,
      required final List<ProgressionRule> rules}) = _$SetSchemeImpl;

  factory _SetScheme.fromJson(Map<String, dynamic> json) =
      _$SetSchemeImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  double get basePercent;
  @override
  int get order;
  @override
  Map<String, dynamic> get engineConfig;
  @override
  List<SetDefinition> get sets;
  @override
  List<ProgressionRule> get rules;
  @override
  @JsonKey(ignore: true)
  _$$SetSchemeImplCopyWith<_$SetSchemeImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SetDefinition _$SetDefinitionFromJson(Map<String, dynamic> json) {
  return _SetDefinition.fromJson(json);
}

/// @nodoc
mixin _$SetDefinition {
  int get targetReps => throw _privateConstructorUsedError;
  double get intensity =>
      throw _privateConstructorUsedError; // multiplier of TM or base weight e.g. 0.85
  bool get isAmrap => throw _privateConstructorUsedError;
  String get kind => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $SetDefinitionCopyWith<SetDefinition> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SetDefinitionCopyWith<$Res> {
  factory $SetDefinitionCopyWith(
          SetDefinition value, $Res Function(SetDefinition) then) =
      _$SetDefinitionCopyWithImpl<$Res, SetDefinition>;
  @useResult
  $Res call({int targetReps, double intensity, bool isAmrap, String kind});
}

/// @nodoc
class _$SetDefinitionCopyWithImpl<$Res, $Val extends SetDefinition>
    implements $SetDefinitionCopyWith<$Res> {
  _$SetDefinitionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? targetReps = null,
    Object? intensity = null,
    Object? isAmrap = null,
    Object? kind = null,
  }) {
    return _then(_value.copyWith(
      targetReps: null == targetReps
          ? _value.targetReps
          : targetReps // ignore: cast_nullable_to_non_nullable
              as int,
      intensity: null == intensity
          ? _value.intensity
          : intensity // ignore: cast_nullable_to_non_nullable
              as double,
      isAmrap: null == isAmrap
          ? _value.isAmrap
          : isAmrap // ignore: cast_nullable_to_non_nullable
              as bool,
      kind: null == kind
          ? _value.kind
          : kind // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SetDefinitionImplCopyWith<$Res>
    implements $SetDefinitionCopyWith<$Res> {
  factory _$$SetDefinitionImplCopyWith(
          _$SetDefinitionImpl value, $Res Function(_$SetDefinitionImpl) then) =
      __$$SetDefinitionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int targetReps, double intensity, bool isAmrap, String kind});
}

/// @nodoc
class __$$SetDefinitionImplCopyWithImpl<$Res>
    extends _$SetDefinitionCopyWithImpl<$Res, _$SetDefinitionImpl>
    implements _$$SetDefinitionImplCopyWith<$Res> {
  __$$SetDefinitionImplCopyWithImpl(
      _$SetDefinitionImpl _value, $Res Function(_$SetDefinitionImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? targetReps = null,
    Object? intensity = null,
    Object? isAmrap = null,
    Object? kind = null,
  }) {
    return _then(_$SetDefinitionImpl(
      targetReps: null == targetReps
          ? _value.targetReps
          : targetReps // ignore: cast_nullable_to_non_nullable
              as int,
      intensity: null == intensity
          ? _value.intensity
          : intensity // ignore: cast_nullable_to_non_nullable
              as double,
      isAmrap: null == isAmrap
          ? _value.isAmrap
          : isAmrap // ignore: cast_nullable_to_non_nullable
              as bool,
      kind: null == kind
          ? _value.kind
          : kind // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SetDefinitionImpl implements _SetDefinition {
  const _$SetDefinitionImpl(
      {required this.targetReps,
      required this.intensity,
      this.isAmrap = false,
      this.kind = 'working'});

  factory _$SetDefinitionImpl.fromJson(Map<String, dynamic> json) =>
      _$$SetDefinitionImplFromJson(json);

  @override
  final int targetReps;
  @override
  final double intensity;
// multiplier of TM or base weight e.g. 0.85
  @override
  @JsonKey()
  final bool isAmrap;
  @override
  @JsonKey()
  final String kind;

  @override
  String toString() {
    return 'SetDefinition(targetReps: $targetReps, intensity: $intensity, isAmrap: $isAmrap, kind: $kind)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SetDefinitionImpl &&
            (identical(other.targetReps, targetReps) ||
                other.targetReps == targetReps) &&
            (identical(other.intensity, intensity) ||
                other.intensity == intensity) &&
            (identical(other.isAmrap, isAmrap) || other.isAmrap == isAmrap) &&
            (identical(other.kind, kind) || other.kind == kind));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, targetReps, intensity, isAmrap, kind);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$SetDefinitionImplCopyWith<_$SetDefinitionImpl> get copyWith =>
      __$$SetDefinitionImplCopyWithImpl<_$SetDefinitionImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SetDefinitionImplToJson(
      this,
    );
  }
}

abstract class _SetDefinition implements SetDefinition {
  const factory _SetDefinition(
      {required final int targetReps,
      required final double intensity,
      final bool isAmrap,
      final String kind}) = _$SetDefinitionImpl;

  factory _SetDefinition.fromJson(Map<String, dynamic> json) =
      _$SetDefinitionImpl.fromJson;

  @override
  int get targetReps;
  @override
  double get intensity;
  @override // multiplier of TM or base weight e.g. 0.85
  bool get isAmrap;
  @override
  String get kind;
  @override
  @JsonKey(ignore: true)
  _$$SetDefinitionImplCopyWith<_$SetDefinitionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ProgressionRule _$ProgressionRuleFromJson(Map<String, dynamic> json) {
  return _ProgressionRule.fromJson(json);
}

/// @nodoc
mixin _$ProgressionRule {
  String get condition =>
      throw _privateConstructorUsedError; // e.g. '${failed_sets} == 0'
  List<RuleAction> get actions => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ProgressionRuleCopyWith<ProgressionRule> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProgressionRuleCopyWith<$Res> {
  factory $ProgressionRuleCopyWith(
          ProgressionRule value, $Res Function(ProgressionRule) then) =
      _$ProgressionRuleCopyWithImpl<$Res, ProgressionRule>;
  @useResult
  $Res call({String condition, List<RuleAction> actions});
}

/// @nodoc
class _$ProgressionRuleCopyWithImpl<$Res, $Val extends ProgressionRule>
    implements $ProgressionRuleCopyWith<$Res> {
  _$ProgressionRuleCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? condition = null,
    Object? actions = null,
  }) {
    return _then(_value.copyWith(
      condition: null == condition
          ? _value.condition
          : condition // ignore: cast_nullable_to_non_nullable
              as String,
      actions: null == actions
          ? _value.actions
          : actions // ignore: cast_nullable_to_non_nullable
              as List<RuleAction>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ProgressionRuleImplCopyWith<$Res>
    implements $ProgressionRuleCopyWith<$Res> {
  factory _$$ProgressionRuleImplCopyWith(_$ProgressionRuleImpl value,
          $Res Function(_$ProgressionRuleImpl) then) =
      __$$ProgressionRuleImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String condition, List<RuleAction> actions});
}

/// @nodoc
class __$$ProgressionRuleImplCopyWithImpl<$Res>
    extends _$ProgressionRuleCopyWithImpl<$Res, _$ProgressionRuleImpl>
    implements _$$ProgressionRuleImplCopyWith<$Res> {
  __$$ProgressionRuleImplCopyWithImpl(
      _$ProgressionRuleImpl _value, $Res Function(_$ProgressionRuleImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? condition = null,
    Object? actions = null,
  }) {
    return _then(_$ProgressionRuleImpl(
      condition: null == condition
          ? _value.condition
          : condition // ignore: cast_nullable_to_non_nullable
              as String,
      actions: null == actions
          ? _value._actions
          : actions // ignore: cast_nullable_to_non_nullable
              as List<RuleAction>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ProgressionRuleImpl implements _ProgressionRule {
  const _$ProgressionRuleImpl(
      {required this.condition, required final List<RuleAction> actions})
      : _actions = actions;

  factory _$ProgressionRuleImpl.fromJson(Map<String, dynamic> json) =>
      _$$ProgressionRuleImplFromJson(json);

  @override
  final String condition;
// e.g. '${failed_sets} == 0'
  final List<RuleAction> _actions;
// e.g. '${failed_sets} == 0'
  @override
  List<RuleAction> get actions {
    if (_actions is EqualUnmodifiableListView) return _actions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_actions);
  }

  @override
  String toString() {
    return 'ProgressionRule(condition: $condition, actions: $actions)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProgressionRuleImpl &&
            (identical(other.condition, condition) ||
                other.condition == condition) &&
            const DeepCollectionEquality().equals(other._actions, _actions));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType, condition, const DeepCollectionEquality().hash(_actions));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ProgressionRuleImplCopyWith<_$ProgressionRuleImpl> get copyWith =>
      __$$ProgressionRuleImplCopyWithImpl<_$ProgressionRuleImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ProgressionRuleImplToJson(
      this,
    );
  }
}

abstract class _ProgressionRule implements ProgressionRule {
  const factory _ProgressionRule(
      {required final String condition,
      required final List<RuleAction> actions}) = _$ProgressionRuleImpl;

  factory _ProgressionRule.fromJson(Map<String, dynamic> json) =
      _$ProgressionRuleImpl.fromJson;

  @override
  String get condition;
  @override // e.g. '${failed_sets} == 0'
  List<RuleAction> get actions;
  @override
  @JsonKey(ignore: true)
  _$$ProgressionRuleImplCopyWith<_$ProgressionRuleImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

RuleAction _$RuleActionFromJson(Map<String, dynamic> json) {
  return _RuleAction.fromJson(json);
}

/// @nodoc
mixin _$RuleAction {
  String get type =>
      throw _privateConstructorUsedError; // 'ADD_WEIGHT', 'JUMP_TO_STAGE', 'STAY_STAGE', 'MULTIPLY_WEIGHT'
  double? get amount => throw _privateConstructorUsedError; // amount to add
  double? get multiplier => throw _privateConstructorUsedError; // multiplier
  String? get targetStageId => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $RuleActionCopyWith<RuleAction> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RuleActionCopyWith<$Res> {
  factory $RuleActionCopyWith(
          RuleAction value, $Res Function(RuleAction) then) =
      _$RuleActionCopyWithImpl<$Res, RuleAction>;
  @useResult
  $Res call(
      {String type, double? amount, double? multiplier, String? targetStageId});
}

/// @nodoc
class _$RuleActionCopyWithImpl<$Res, $Val extends RuleAction>
    implements $RuleActionCopyWith<$Res> {
  _$RuleActionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
    Object? amount = freezed,
    Object? multiplier = freezed,
    Object? targetStageId = freezed,
  }) {
    return _then(_value.copyWith(
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      amount: freezed == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as double?,
      multiplier: freezed == multiplier
          ? _value.multiplier
          : multiplier // ignore: cast_nullable_to_non_nullable
              as double?,
      targetStageId: freezed == targetStageId
          ? _value.targetStageId
          : targetStageId // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$RuleActionImplCopyWith<$Res>
    implements $RuleActionCopyWith<$Res> {
  factory _$$RuleActionImplCopyWith(
          _$RuleActionImpl value, $Res Function(_$RuleActionImpl) then) =
      __$$RuleActionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String type, double? amount, double? multiplier, String? targetStageId});
}

/// @nodoc
class __$$RuleActionImplCopyWithImpl<$Res>
    extends _$RuleActionCopyWithImpl<$Res, _$RuleActionImpl>
    implements _$$RuleActionImplCopyWith<$Res> {
  __$$RuleActionImplCopyWithImpl(
      _$RuleActionImpl _value, $Res Function(_$RuleActionImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
    Object? amount = freezed,
    Object? multiplier = freezed,
    Object? targetStageId = freezed,
  }) {
    return _then(_$RuleActionImpl(
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      amount: freezed == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as double?,
      multiplier: freezed == multiplier
          ? _value.multiplier
          : multiplier // ignore: cast_nullable_to_non_nullable
              as double?,
      targetStageId: freezed == targetStageId
          ? _value.targetStageId
          : targetStageId // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$RuleActionImpl implements _RuleAction {
  const _$RuleActionImpl(
      {required this.type, this.amount, this.multiplier, this.targetStageId});

  factory _$RuleActionImpl.fromJson(Map<String, dynamic> json) =>
      _$$RuleActionImplFromJson(json);

  @override
  final String type;
// 'ADD_WEIGHT', 'JUMP_TO_STAGE', 'STAY_STAGE', 'MULTIPLY_WEIGHT'
  @override
  final double? amount;
// amount to add
  @override
  final double? multiplier;
// multiplier
  @override
  final String? targetStageId;

  @override
  String toString() {
    return 'RuleAction(type: $type, amount: $amount, multiplier: $multiplier, targetStageId: $targetStageId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RuleActionImpl &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.multiplier, multiplier) ||
                other.multiplier == multiplier) &&
            (identical(other.targetStageId, targetStageId) ||
                other.targetStageId == targetStageId));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, type, amount, multiplier, targetStageId);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$RuleActionImplCopyWith<_$RuleActionImpl> get copyWith =>
      __$$RuleActionImplCopyWithImpl<_$RuleActionImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RuleActionImplToJson(
      this,
    );
  }
}

abstract class _RuleAction implements RuleAction {
  const factory _RuleAction(
      {required final String type,
      final double? amount,
      final double? multiplier,
      final String? targetStageId}) = _$RuleActionImpl;

  factory _RuleAction.fromJson(Map<String, dynamic> json) =
      _$RuleActionImpl.fromJson;

  @override
  String get type;
  @override // 'ADD_WEIGHT', 'JUMP_TO_STAGE', 'STAY_STAGE', 'MULTIPLY_WEIGHT'
  double? get amount;
  @override // amount to add
  double? get multiplier;
  @override // multiplier
  String? get targetStageId;
  @override
  @JsonKey(ignore: true)
  _$$RuleActionImplCopyWith<_$RuleActionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
