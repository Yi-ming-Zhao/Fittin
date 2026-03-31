// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'workout_log.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

WorkoutLog _$WorkoutLogFromJson(Map<String, dynamic> json) {
  return _WorkoutLog.fromJson(json);
}

/// @nodoc
mixin _$WorkoutLog {
  String get logId => throw _privateConstructorUsedError;
  String get instanceId => throw _privateConstructorUsedError;
  String get workoutId => throw _privateConstructorUsedError;
  String get workoutName => throw _privateConstructorUsedError;
  String get dayLabel => throw _privateConstructorUsedError;
  DateTime get completedAt => throw _privateConstructorUsedError;
  List<ExerciseLog> get exercises => throw _privateConstructorUsedError;
  WorkoutProgressionSnapshot? get preConclusionSnapshot =>
      throw _privateConstructorUsedError;
  WorkoutProgressionSnapshot? get postConclusionSnapshot =>
      throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $WorkoutLogCopyWith<WorkoutLog> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WorkoutLogCopyWith<$Res> {
  factory $WorkoutLogCopyWith(
          WorkoutLog value, $Res Function(WorkoutLog) then) =
      _$WorkoutLogCopyWithImpl<$Res, WorkoutLog>;
  @useResult
  $Res call(
      {String logId,
      String instanceId,
      String workoutId,
      String workoutName,
      String dayLabel,
      DateTime completedAt,
      List<ExerciseLog> exercises,
      WorkoutProgressionSnapshot? preConclusionSnapshot,
      WorkoutProgressionSnapshot? postConclusionSnapshot});

  $WorkoutProgressionSnapshotCopyWith<$Res>? get preConclusionSnapshot;
  $WorkoutProgressionSnapshotCopyWith<$Res>? get postConclusionSnapshot;
}

/// @nodoc
class _$WorkoutLogCopyWithImpl<$Res, $Val extends WorkoutLog>
    implements $WorkoutLogCopyWith<$Res> {
  _$WorkoutLogCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? logId = null,
    Object? instanceId = null,
    Object? workoutId = null,
    Object? workoutName = null,
    Object? dayLabel = null,
    Object? completedAt = null,
    Object? exercises = null,
    Object? preConclusionSnapshot = freezed,
    Object? postConclusionSnapshot = freezed,
  }) {
    return _then(_value.copyWith(
      logId: null == logId
          ? _value.logId
          : logId // ignore: cast_nullable_to_non_nullable
              as String,
      instanceId: null == instanceId
          ? _value.instanceId
          : instanceId // ignore: cast_nullable_to_non_nullable
              as String,
      workoutId: null == workoutId
          ? _value.workoutId
          : workoutId // ignore: cast_nullable_to_non_nullable
              as String,
      workoutName: null == workoutName
          ? _value.workoutName
          : workoutName // ignore: cast_nullable_to_non_nullable
              as String,
      dayLabel: null == dayLabel
          ? _value.dayLabel
          : dayLabel // ignore: cast_nullable_to_non_nullable
              as String,
      completedAt: null == completedAt
          ? _value.completedAt
          : completedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      exercises: null == exercises
          ? _value.exercises
          : exercises // ignore: cast_nullable_to_non_nullable
              as List<ExerciseLog>,
      preConclusionSnapshot: freezed == preConclusionSnapshot
          ? _value.preConclusionSnapshot
          : preConclusionSnapshot // ignore: cast_nullable_to_non_nullable
              as WorkoutProgressionSnapshot?,
      postConclusionSnapshot: freezed == postConclusionSnapshot
          ? _value.postConclusionSnapshot
          : postConclusionSnapshot // ignore: cast_nullable_to_non_nullable
              as WorkoutProgressionSnapshot?,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $WorkoutProgressionSnapshotCopyWith<$Res>? get preConclusionSnapshot {
    if (_value.preConclusionSnapshot == null) {
      return null;
    }

    return $WorkoutProgressionSnapshotCopyWith<$Res>(
        _value.preConclusionSnapshot!, (value) {
      return _then(_value.copyWith(preConclusionSnapshot: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $WorkoutProgressionSnapshotCopyWith<$Res>? get postConclusionSnapshot {
    if (_value.postConclusionSnapshot == null) {
      return null;
    }

    return $WorkoutProgressionSnapshotCopyWith<$Res>(
        _value.postConclusionSnapshot!, (value) {
      return _then(_value.copyWith(postConclusionSnapshot: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$WorkoutLogImplCopyWith<$Res>
    implements $WorkoutLogCopyWith<$Res> {
  factory _$$WorkoutLogImplCopyWith(
          _$WorkoutLogImpl value, $Res Function(_$WorkoutLogImpl) then) =
      __$$WorkoutLogImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String logId,
      String instanceId,
      String workoutId,
      String workoutName,
      String dayLabel,
      DateTime completedAt,
      List<ExerciseLog> exercises,
      WorkoutProgressionSnapshot? preConclusionSnapshot,
      WorkoutProgressionSnapshot? postConclusionSnapshot});

  @override
  $WorkoutProgressionSnapshotCopyWith<$Res>? get preConclusionSnapshot;
  @override
  $WorkoutProgressionSnapshotCopyWith<$Res>? get postConclusionSnapshot;
}

/// @nodoc
class __$$WorkoutLogImplCopyWithImpl<$Res>
    extends _$WorkoutLogCopyWithImpl<$Res, _$WorkoutLogImpl>
    implements _$$WorkoutLogImplCopyWith<$Res> {
  __$$WorkoutLogImplCopyWithImpl(
      _$WorkoutLogImpl _value, $Res Function(_$WorkoutLogImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? logId = null,
    Object? instanceId = null,
    Object? workoutId = null,
    Object? workoutName = null,
    Object? dayLabel = null,
    Object? completedAt = null,
    Object? exercises = null,
    Object? preConclusionSnapshot = freezed,
    Object? postConclusionSnapshot = freezed,
  }) {
    return _then(_$WorkoutLogImpl(
      logId: null == logId
          ? _value.logId
          : logId // ignore: cast_nullable_to_non_nullable
              as String,
      instanceId: null == instanceId
          ? _value.instanceId
          : instanceId // ignore: cast_nullable_to_non_nullable
              as String,
      workoutId: null == workoutId
          ? _value.workoutId
          : workoutId // ignore: cast_nullable_to_non_nullable
              as String,
      workoutName: null == workoutName
          ? _value.workoutName
          : workoutName // ignore: cast_nullable_to_non_nullable
              as String,
      dayLabel: null == dayLabel
          ? _value.dayLabel
          : dayLabel // ignore: cast_nullable_to_non_nullable
              as String,
      completedAt: null == completedAt
          ? _value.completedAt
          : completedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      exercises: null == exercises
          ? _value._exercises
          : exercises // ignore: cast_nullable_to_non_nullable
              as List<ExerciseLog>,
      preConclusionSnapshot: freezed == preConclusionSnapshot
          ? _value.preConclusionSnapshot
          : preConclusionSnapshot // ignore: cast_nullable_to_non_nullable
              as WorkoutProgressionSnapshot?,
      postConclusionSnapshot: freezed == postConclusionSnapshot
          ? _value.postConclusionSnapshot
          : postConclusionSnapshot // ignore: cast_nullable_to_non_nullable
              as WorkoutProgressionSnapshot?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$WorkoutLogImpl implements _WorkoutLog {
  const _$WorkoutLogImpl(
      {this.logId = '',
      required this.instanceId,
      required this.workoutId,
      required this.workoutName,
      required this.dayLabel,
      required this.completedAt,
      required final List<ExerciseLog> exercises,
      this.preConclusionSnapshot,
      this.postConclusionSnapshot})
      : _exercises = exercises;

  factory _$WorkoutLogImpl.fromJson(Map<String, dynamic> json) =>
      _$$WorkoutLogImplFromJson(json);

  @override
  @JsonKey()
  final String logId;
  @override
  final String instanceId;
  @override
  final String workoutId;
  @override
  final String workoutName;
  @override
  final String dayLabel;
  @override
  final DateTime completedAt;
  final List<ExerciseLog> _exercises;
  @override
  List<ExerciseLog> get exercises {
    if (_exercises is EqualUnmodifiableListView) return _exercises;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_exercises);
  }

  @override
  final WorkoutProgressionSnapshot? preConclusionSnapshot;
  @override
  final WorkoutProgressionSnapshot? postConclusionSnapshot;

  @override
  String toString() {
    return 'WorkoutLog(logId: $logId, instanceId: $instanceId, workoutId: $workoutId, workoutName: $workoutName, dayLabel: $dayLabel, completedAt: $completedAt, exercises: $exercises, preConclusionSnapshot: $preConclusionSnapshot, postConclusionSnapshot: $postConclusionSnapshot)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WorkoutLogImpl &&
            (identical(other.logId, logId) || other.logId == logId) &&
            (identical(other.instanceId, instanceId) ||
                other.instanceId == instanceId) &&
            (identical(other.workoutId, workoutId) ||
                other.workoutId == workoutId) &&
            (identical(other.workoutName, workoutName) ||
                other.workoutName == workoutName) &&
            (identical(other.dayLabel, dayLabel) ||
                other.dayLabel == dayLabel) &&
            (identical(other.completedAt, completedAt) ||
                other.completedAt == completedAt) &&
            const DeepCollectionEquality()
                .equals(other._exercises, _exercises) &&
            (identical(other.preConclusionSnapshot, preConclusionSnapshot) ||
                other.preConclusionSnapshot == preConclusionSnapshot) &&
            (identical(other.postConclusionSnapshot, postConclusionSnapshot) ||
                other.postConclusionSnapshot == postConclusionSnapshot));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      logId,
      instanceId,
      workoutId,
      workoutName,
      dayLabel,
      completedAt,
      const DeepCollectionEquality().hash(_exercises),
      preConclusionSnapshot,
      postConclusionSnapshot);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$WorkoutLogImplCopyWith<_$WorkoutLogImpl> get copyWith =>
      __$$WorkoutLogImplCopyWithImpl<_$WorkoutLogImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$WorkoutLogImplToJson(
      this,
    );
  }
}

abstract class _WorkoutLog implements WorkoutLog {
  const factory _WorkoutLog(
          {final String logId,
          required final String instanceId,
          required final String workoutId,
          required final String workoutName,
          required final String dayLabel,
          required final DateTime completedAt,
          required final List<ExerciseLog> exercises,
          final WorkoutProgressionSnapshot? preConclusionSnapshot,
          final WorkoutProgressionSnapshot? postConclusionSnapshot}) =
      _$WorkoutLogImpl;

  factory _WorkoutLog.fromJson(Map<String, dynamic> json) =
      _$WorkoutLogImpl.fromJson;

  @override
  String get logId;
  @override
  String get instanceId;
  @override
  String get workoutId;
  @override
  String get workoutName;
  @override
  String get dayLabel;
  @override
  DateTime get completedAt;
  @override
  List<ExerciseLog> get exercises;
  @override
  WorkoutProgressionSnapshot? get preConclusionSnapshot;
  @override
  WorkoutProgressionSnapshot? get postConclusionSnapshot;
  @override
  @JsonKey(ignore: true)
  _$$WorkoutLogImplCopyWith<_$WorkoutLogImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

WorkoutProgressionSnapshot _$WorkoutProgressionSnapshotFromJson(
    Map<String, dynamic> json) {
  return _WorkoutProgressionSnapshot.fromJson(json);
}

/// @nodoc
mixin _$WorkoutProgressionSnapshot {
  String get templateId => throw _privateConstructorUsedError;
  int get currentWorkoutIndex => throw _privateConstructorUsedError;
  TrainingMaxProfile get trainingMaxProfile =>
      throw _privateConstructorUsedError;
  Map<String, dynamic> get engineState => throw _privateConstructorUsedError;
  List<TrainingState> get states => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $WorkoutProgressionSnapshotCopyWith<WorkoutProgressionSnapshot>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WorkoutProgressionSnapshotCopyWith<$Res> {
  factory $WorkoutProgressionSnapshotCopyWith(WorkoutProgressionSnapshot value,
          $Res Function(WorkoutProgressionSnapshot) then) =
      _$WorkoutProgressionSnapshotCopyWithImpl<$Res,
          WorkoutProgressionSnapshot>;
  @useResult
  $Res call(
      {String templateId,
      int currentWorkoutIndex,
      TrainingMaxProfile trainingMaxProfile,
      Map<String, dynamic> engineState,
      List<TrainingState> states});
}

/// @nodoc
class _$WorkoutProgressionSnapshotCopyWithImpl<$Res,
        $Val extends WorkoutProgressionSnapshot>
    implements $WorkoutProgressionSnapshotCopyWith<$Res> {
  _$WorkoutProgressionSnapshotCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? templateId = null,
    Object? currentWorkoutIndex = null,
    Object? trainingMaxProfile = null,
    Object? engineState = null,
    Object? states = null,
  }) {
    return _then(_value.copyWith(
      templateId: null == templateId
          ? _value.templateId
          : templateId // ignore: cast_nullable_to_non_nullable
              as String,
      currentWorkoutIndex: null == currentWorkoutIndex
          ? _value.currentWorkoutIndex
          : currentWorkoutIndex // ignore: cast_nullable_to_non_nullable
              as int,
      trainingMaxProfile: null == trainingMaxProfile
          ? _value.trainingMaxProfile
          : trainingMaxProfile // ignore: cast_nullable_to_non_nullable
              as TrainingMaxProfile,
      engineState: null == engineState
          ? _value.engineState
          : engineState // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      states: null == states
          ? _value.states
          : states // ignore: cast_nullable_to_non_nullable
              as List<TrainingState>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$WorkoutProgressionSnapshotImplCopyWith<$Res>
    implements $WorkoutProgressionSnapshotCopyWith<$Res> {
  factory _$$WorkoutProgressionSnapshotImplCopyWith(
          _$WorkoutProgressionSnapshotImpl value,
          $Res Function(_$WorkoutProgressionSnapshotImpl) then) =
      __$$WorkoutProgressionSnapshotImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String templateId,
      int currentWorkoutIndex,
      TrainingMaxProfile trainingMaxProfile,
      Map<String, dynamic> engineState,
      List<TrainingState> states});
}

/// @nodoc
class __$$WorkoutProgressionSnapshotImplCopyWithImpl<$Res>
    extends _$WorkoutProgressionSnapshotCopyWithImpl<$Res,
        _$WorkoutProgressionSnapshotImpl>
    implements _$$WorkoutProgressionSnapshotImplCopyWith<$Res> {
  __$$WorkoutProgressionSnapshotImplCopyWithImpl(
      _$WorkoutProgressionSnapshotImpl _value,
      $Res Function(_$WorkoutProgressionSnapshotImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? templateId = null,
    Object? currentWorkoutIndex = null,
    Object? trainingMaxProfile = null,
    Object? engineState = null,
    Object? states = null,
  }) {
    return _then(_$WorkoutProgressionSnapshotImpl(
      templateId: null == templateId
          ? _value.templateId
          : templateId // ignore: cast_nullable_to_non_nullable
              as String,
      currentWorkoutIndex: null == currentWorkoutIndex
          ? _value.currentWorkoutIndex
          : currentWorkoutIndex // ignore: cast_nullable_to_non_nullable
              as int,
      trainingMaxProfile: null == trainingMaxProfile
          ? _value.trainingMaxProfile
          : trainingMaxProfile // ignore: cast_nullable_to_non_nullable
              as TrainingMaxProfile,
      engineState: null == engineState
          ? _value._engineState
          : engineState // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      states: null == states
          ? _value._states
          : states // ignore: cast_nullable_to_non_nullable
              as List<TrainingState>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$WorkoutProgressionSnapshotImpl implements _WorkoutProgressionSnapshot {
  const _$WorkoutProgressionSnapshotImpl(
      {required this.templateId,
      required this.currentWorkoutIndex,
      required this.trainingMaxProfile,
      required final Map<String, dynamic> engineState,
      required final List<TrainingState> states})
      : _engineState = engineState,
        _states = states;

  factory _$WorkoutProgressionSnapshotImpl.fromJson(
          Map<String, dynamic> json) =>
      _$$WorkoutProgressionSnapshotImplFromJson(json);

  @override
  final String templateId;
  @override
  final int currentWorkoutIndex;
  @override
  final TrainingMaxProfile trainingMaxProfile;
  final Map<String, dynamic> _engineState;
  @override
  Map<String, dynamic> get engineState {
    if (_engineState is EqualUnmodifiableMapView) return _engineState;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_engineState);
  }

  final List<TrainingState> _states;
  @override
  List<TrainingState> get states {
    if (_states is EqualUnmodifiableListView) return _states;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_states);
  }

  @override
  String toString() {
    return 'WorkoutProgressionSnapshot(templateId: $templateId, currentWorkoutIndex: $currentWorkoutIndex, trainingMaxProfile: $trainingMaxProfile, engineState: $engineState, states: $states)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WorkoutProgressionSnapshotImpl &&
            (identical(other.templateId, templateId) ||
                other.templateId == templateId) &&
            (identical(other.currentWorkoutIndex, currentWorkoutIndex) ||
                other.currentWorkoutIndex == currentWorkoutIndex) &&
            (identical(other.trainingMaxProfile, trainingMaxProfile) ||
                other.trainingMaxProfile == trainingMaxProfile) &&
            const DeepCollectionEquality()
                .equals(other._engineState, _engineState) &&
            const DeepCollectionEquality().equals(other._states, _states));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      templateId,
      currentWorkoutIndex,
      trainingMaxProfile,
      const DeepCollectionEquality().hash(_engineState),
      const DeepCollectionEquality().hash(_states));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$WorkoutProgressionSnapshotImplCopyWith<_$WorkoutProgressionSnapshotImpl>
      get copyWith => __$$WorkoutProgressionSnapshotImplCopyWithImpl<
          _$WorkoutProgressionSnapshotImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$WorkoutProgressionSnapshotImplToJson(
      this,
    );
  }
}

abstract class _WorkoutProgressionSnapshot
    implements WorkoutProgressionSnapshot {
  const factory _WorkoutProgressionSnapshot(
          {required final String templateId,
          required final int currentWorkoutIndex,
          required final TrainingMaxProfile trainingMaxProfile,
          required final Map<String, dynamic> engineState,
          required final List<TrainingState> states}) =
      _$WorkoutProgressionSnapshotImpl;

  factory _WorkoutProgressionSnapshot.fromJson(Map<String, dynamic> json) =
      _$WorkoutProgressionSnapshotImpl.fromJson;

  @override
  String get templateId;
  @override
  int get currentWorkoutIndex;
  @override
  TrainingMaxProfile get trainingMaxProfile;
  @override
  Map<String, dynamic> get engineState;
  @override
  List<TrainingState> get states;
  @override
  @JsonKey(ignore: true)
  _$$WorkoutProgressionSnapshotImplCopyWith<_$WorkoutProgressionSnapshotImpl>
      get copyWith => throw _privateConstructorUsedError;
}

ExerciseLog _$ExerciseLogFromJson(Map<String, dynamic> json) {
  return _ExerciseLog.fromJson(json);
}

/// @nodoc
mixin _$ExerciseLog {
  String get exerciseId => throw _privateConstructorUsedError;
  String get exerciseName => throw _privateConstructorUsedError;
  String get stageId => throw _privateConstructorUsedError;
  List<SetLog> get sets => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ExerciseLogCopyWith<ExerciseLog> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ExerciseLogCopyWith<$Res> {
  factory $ExerciseLogCopyWith(
          ExerciseLog value, $Res Function(ExerciseLog) then) =
      _$ExerciseLogCopyWithImpl<$Res, ExerciseLog>;
  @useResult
  $Res call(
      {String exerciseId,
      String exerciseName,
      String stageId,
      List<SetLog> sets});
}

/// @nodoc
class _$ExerciseLogCopyWithImpl<$Res, $Val extends ExerciseLog>
    implements $ExerciseLogCopyWith<$Res> {
  _$ExerciseLogCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? exerciseId = null,
    Object? exerciseName = null,
    Object? stageId = null,
    Object? sets = null,
  }) {
    return _then(_value.copyWith(
      exerciseId: null == exerciseId
          ? _value.exerciseId
          : exerciseId // ignore: cast_nullable_to_non_nullable
              as String,
      exerciseName: null == exerciseName
          ? _value.exerciseName
          : exerciseName // ignore: cast_nullable_to_non_nullable
              as String,
      stageId: null == stageId
          ? _value.stageId
          : stageId // ignore: cast_nullable_to_non_nullable
              as String,
      sets: null == sets
          ? _value.sets
          : sets // ignore: cast_nullable_to_non_nullable
              as List<SetLog>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ExerciseLogImplCopyWith<$Res>
    implements $ExerciseLogCopyWith<$Res> {
  factory _$$ExerciseLogImplCopyWith(
          _$ExerciseLogImpl value, $Res Function(_$ExerciseLogImpl) then) =
      __$$ExerciseLogImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String exerciseId,
      String exerciseName,
      String stageId,
      List<SetLog> sets});
}

/// @nodoc
class __$$ExerciseLogImplCopyWithImpl<$Res>
    extends _$ExerciseLogCopyWithImpl<$Res, _$ExerciseLogImpl>
    implements _$$ExerciseLogImplCopyWith<$Res> {
  __$$ExerciseLogImplCopyWithImpl(
      _$ExerciseLogImpl _value, $Res Function(_$ExerciseLogImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? exerciseId = null,
    Object? exerciseName = null,
    Object? stageId = null,
    Object? sets = null,
  }) {
    return _then(_$ExerciseLogImpl(
      exerciseId: null == exerciseId
          ? _value.exerciseId
          : exerciseId // ignore: cast_nullable_to_non_nullable
              as String,
      exerciseName: null == exerciseName
          ? _value.exerciseName
          : exerciseName // ignore: cast_nullable_to_non_nullable
              as String,
      stageId: null == stageId
          ? _value.stageId
          : stageId // ignore: cast_nullable_to_non_nullable
              as String,
      sets: null == sets
          ? _value._sets
          : sets // ignore: cast_nullable_to_non_nullable
              as List<SetLog>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ExerciseLogImpl implements _ExerciseLog {
  const _$ExerciseLogImpl(
      {required this.exerciseId,
      required this.exerciseName,
      required this.stageId,
      required final List<SetLog> sets})
      : _sets = sets;

  factory _$ExerciseLogImpl.fromJson(Map<String, dynamic> json) =>
      _$$ExerciseLogImplFromJson(json);

  @override
  final String exerciseId;
  @override
  final String exerciseName;
  @override
  final String stageId;
  final List<SetLog> _sets;
  @override
  List<SetLog> get sets {
    if (_sets is EqualUnmodifiableListView) return _sets;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_sets);
  }

  @override
  String toString() {
    return 'ExerciseLog(exerciseId: $exerciseId, exerciseName: $exerciseName, stageId: $stageId, sets: $sets)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ExerciseLogImpl &&
            (identical(other.exerciseId, exerciseId) ||
                other.exerciseId == exerciseId) &&
            (identical(other.exerciseName, exerciseName) ||
                other.exerciseName == exerciseName) &&
            (identical(other.stageId, stageId) || other.stageId == stageId) &&
            const DeepCollectionEquality().equals(other._sets, _sets));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, exerciseId, exerciseName,
      stageId, const DeepCollectionEquality().hash(_sets));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ExerciseLogImplCopyWith<_$ExerciseLogImpl> get copyWith =>
      __$$ExerciseLogImplCopyWithImpl<_$ExerciseLogImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ExerciseLogImplToJson(
      this,
    );
  }
}

abstract class _ExerciseLog implements ExerciseLog {
  const factory _ExerciseLog(
      {required final String exerciseId,
      required final String exerciseName,
      required final String stageId,
      required final List<SetLog> sets}) = _$ExerciseLogImpl;

  factory _ExerciseLog.fromJson(Map<String, dynamic> json) =
      _$ExerciseLogImpl.fromJson;

  @override
  String get exerciseId;
  @override
  String get exerciseName;
  @override
  String get stageId;
  @override
  List<SetLog> get sets;
  @override
  @JsonKey(ignore: true)
  _$$ExerciseLogImplCopyWith<_$ExerciseLogImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SetLog _$SetLogFromJson(Map<String, dynamic> json) {
  return _SetLog.fromJson(json);
}

/// @nodoc
mixin _$SetLog {
  String get role => throw _privateConstructorUsedError;
  int get targetReps => throw _privateConstructorUsedError;
  int get completedReps => throw _privateConstructorUsedError;
  double get targetWeight => throw _privateConstructorUsedError;
  double get weight => throw _privateConstructorUsedError;
  bool get isAmrap => throw _privateConstructorUsedError;
  bool get isCompleted => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $SetLogCopyWith<SetLog> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SetLogCopyWith<$Res> {
  factory $SetLogCopyWith(SetLog value, $Res Function(SetLog) then) =
      _$SetLogCopyWithImpl<$Res, SetLog>;
  @useResult
  $Res call(
      {String role,
      int targetReps,
      int completedReps,
      double targetWeight,
      double weight,
      bool isAmrap,
      bool isCompleted});
}

/// @nodoc
class _$SetLogCopyWithImpl<$Res, $Val extends SetLog>
    implements $SetLogCopyWith<$Res> {
  _$SetLogCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? role = null,
    Object? targetReps = null,
    Object? completedReps = null,
    Object? targetWeight = null,
    Object? weight = null,
    Object? isAmrap = null,
    Object? isCompleted = null,
  }) {
    return _then(_value.copyWith(
      role: null == role
          ? _value.role
          : role // ignore: cast_nullable_to_non_nullable
              as String,
      targetReps: null == targetReps
          ? _value.targetReps
          : targetReps // ignore: cast_nullable_to_non_nullable
              as int,
      completedReps: null == completedReps
          ? _value.completedReps
          : completedReps // ignore: cast_nullable_to_non_nullable
              as int,
      targetWeight: null == targetWeight
          ? _value.targetWeight
          : targetWeight // ignore: cast_nullable_to_non_nullable
              as double,
      weight: null == weight
          ? _value.weight
          : weight // ignore: cast_nullable_to_non_nullable
              as double,
      isAmrap: null == isAmrap
          ? _value.isAmrap
          : isAmrap // ignore: cast_nullable_to_non_nullable
              as bool,
      isCompleted: null == isCompleted
          ? _value.isCompleted
          : isCompleted // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SetLogImplCopyWith<$Res> implements $SetLogCopyWith<$Res> {
  factory _$$SetLogImplCopyWith(
          _$SetLogImpl value, $Res Function(_$SetLogImpl) then) =
      __$$SetLogImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String role,
      int targetReps,
      int completedReps,
      double targetWeight,
      double weight,
      bool isAmrap,
      bool isCompleted});
}

/// @nodoc
class __$$SetLogImplCopyWithImpl<$Res>
    extends _$SetLogCopyWithImpl<$Res, _$SetLogImpl>
    implements _$$SetLogImplCopyWith<$Res> {
  __$$SetLogImplCopyWithImpl(
      _$SetLogImpl _value, $Res Function(_$SetLogImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? role = null,
    Object? targetReps = null,
    Object? completedReps = null,
    Object? targetWeight = null,
    Object? weight = null,
    Object? isAmrap = null,
    Object? isCompleted = null,
  }) {
    return _then(_$SetLogImpl(
      role: null == role
          ? _value.role
          : role // ignore: cast_nullable_to_non_nullable
              as String,
      targetReps: null == targetReps
          ? _value.targetReps
          : targetReps // ignore: cast_nullable_to_non_nullable
              as int,
      completedReps: null == completedReps
          ? _value.completedReps
          : completedReps // ignore: cast_nullable_to_non_nullable
              as int,
      targetWeight: null == targetWeight
          ? _value.targetWeight
          : targetWeight // ignore: cast_nullable_to_non_nullable
              as double,
      weight: null == weight
          ? _value.weight
          : weight // ignore: cast_nullable_to_non_nullable
              as double,
      isAmrap: null == isAmrap
          ? _value.isAmrap
          : isAmrap // ignore: cast_nullable_to_non_nullable
              as bool,
      isCompleted: null == isCompleted
          ? _value.isCompleted
          : isCompleted // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SetLogImpl implements _SetLog {
  const _$SetLogImpl(
      {required this.role,
      required this.targetReps,
      required this.completedReps,
      required this.targetWeight,
      required this.weight,
      this.isAmrap = false,
      this.isCompleted = false});

  factory _$SetLogImpl.fromJson(Map<String, dynamic> json) =>
      _$$SetLogImplFromJson(json);

  @override
  final String role;
  @override
  final int targetReps;
  @override
  final int completedReps;
  @override
  final double targetWeight;
  @override
  final double weight;
  @override
  @JsonKey()
  final bool isAmrap;
  @override
  @JsonKey()
  final bool isCompleted;

  @override
  String toString() {
    return 'SetLog(role: $role, targetReps: $targetReps, completedReps: $completedReps, targetWeight: $targetWeight, weight: $weight, isAmrap: $isAmrap, isCompleted: $isCompleted)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SetLogImpl &&
            (identical(other.role, role) || other.role == role) &&
            (identical(other.targetReps, targetReps) ||
                other.targetReps == targetReps) &&
            (identical(other.completedReps, completedReps) ||
                other.completedReps == completedReps) &&
            (identical(other.targetWeight, targetWeight) ||
                other.targetWeight == targetWeight) &&
            (identical(other.weight, weight) || other.weight == weight) &&
            (identical(other.isAmrap, isAmrap) || other.isAmrap == isAmrap) &&
            (identical(other.isCompleted, isCompleted) ||
                other.isCompleted == isCompleted));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, role, targetReps, completedReps,
      targetWeight, weight, isAmrap, isCompleted);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$SetLogImplCopyWith<_$SetLogImpl> get copyWith =>
      __$$SetLogImplCopyWithImpl<_$SetLogImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SetLogImplToJson(
      this,
    );
  }
}

abstract class _SetLog implements SetLog {
  const factory _SetLog(
      {required final String role,
      required final int targetReps,
      required final int completedReps,
      required final double targetWeight,
      required final double weight,
      final bool isAmrap,
      final bool isCompleted}) = _$SetLogImpl;

  factory _SetLog.fromJson(Map<String, dynamic> json) = _$SetLogImpl.fromJson;

  @override
  String get role;
  @override
  int get targetReps;
  @override
  int get completedReps;
  @override
  double get targetWeight;
  @override
  double get weight;
  @override
  bool get isAmrap;
  @override
  bool get isCompleted;
  @override
  @JsonKey(ignore: true)
  _$$SetLogImplCopyWith<_$SetLogImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
