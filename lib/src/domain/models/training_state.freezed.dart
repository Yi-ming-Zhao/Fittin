// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'training_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

TrainingState _$TrainingStateFromJson(Map<String, dynamic> json) {
  return _TrainingState.fromJson(json);
}

/// @nodoc
mixin _$TrainingState {
  String get workoutId => throw _privateConstructorUsedError;
  String get exerciseId => throw _privateConstructorUsedError;
  String get exerciseName => throw _privateConstructorUsedError;
  double get baseWeight => throw _privateConstructorUsedError;
  String get currentStageId => throw _privateConstructorUsedError;
  List<String> get history => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $TrainingStateCopyWith<TrainingState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TrainingStateCopyWith<$Res> {
  factory $TrainingStateCopyWith(
          TrainingState value, $Res Function(TrainingState) then) =
      _$TrainingStateCopyWithImpl<$Res, TrainingState>;
  @useResult
  $Res call(
      {String workoutId,
      String exerciseId,
      String exerciseName,
      double baseWeight,
      String currentStageId,
      List<String> history});
}

/// @nodoc
class _$TrainingStateCopyWithImpl<$Res, $Val extends TrainingState>
    implements $TrainingStateCopyWith<$Res> {
  _$TrainingStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? workoutId = null,
    Object? exerciseId = null,
    Object? exerciseName = null,
    Object? baseWeight = null,
    Object? currentStageId = null,
    Object? history = null,
  }) {
    return _then(_value.copyWith(
      workoutId: null == workoutId
          ? _value.workoutId
          : workoutId // ignore: cast_nullable_to_non_nullable
              as String,
      exerciseId: null == exerciseId
          ? _value.exerciseId
          : exerciseId // ignore: cast_nullable_to_non_nullable
              as String,
      exerciseName: null == exerciseName
          ? _value.exerciseName
          : exerciseName // ignore: cast_nullable_to_non_nullable
              as String,
      baseWeight: null == baseWeight
          ? _value.baseWeight
          : baseWeight // ignore: cast_nullable_to_non_nullable
              as double,
      currentStageId: null == currentStageId
          ? _value.currentStageId
          : currentStageId // ignore: cast_nullable_to_non_nullable
              as String,
      history: null == history
          ? _value.history
          : history // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TrainingStateImplCopyWith<$Res>
    implements $TrainingStateCopyWith<$Res> {
  factory _$$TrainingStateImplCopyWith(
          _$TrainingStateImpl value, $Res Function(_$TrainingStateImpl) then) =
      __$$TrainingStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String workoutId,
      String exerciseId,
      String exerciseName,
      double baseWeight,
      String currentStageId,
      List<String> history});
}

/// @nodoc
class __$$TrainingStateImplCopyWithImpl<$Res>
    extends _$TrainingStateCopyWithImpl<$Res, _$TrainingStateImpl>
    implements _$$TrainingStateImplCopyWith<$Res> {
  __$$TrainingStateImplCopyWithImpl(
      _$TrainingStateImpl _value, $Res Function(_$TrainingStateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? workoutId = null,
    Object? exerciseId = null,
    Object? exerciseName = null,
    Object? baseWeight = null,
    Object? currentStageId = null,
    Object? history = null,
  }) {
    return _then(_$TrainingStateImpl(
      workoutId: null == workoutId
          ? _value.workoutId
          : workoutId // ignore: cast_nullable_to_non_nullable
              as String,
      exerciseId: null == exerciseId
          ? _value.exerciseId
          : exerciseId // ignore: cast_nullable_to_non_nullable
              as String,
      exerciseName: null == exerciseName
          ? _value.exerciseName
          : exerciseName // ignore: cast_nullable_to_non_nullable
              as String,
      baseWeight: null == baseWeight
          ? _value.baseWeight
          : baseWeight // ignore: cast_nullable_to_non_nullable
              as double,
      currentStageId: null == currentStageId
          ? _value.currentStageId
          : currentStageId // ignore: cast_nullable_to_non_nullable
              as String,
      history: null == history
          ? _value._history
          : history // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TrainingStateImpl implements _TrainingState {
  const _$TrainingStateImpl(
      {required this.workoutId,
      required this.exerciseId,
      required this.exerciseName,
      required this.baseWeight,
      required this.currentStageId,
      final List<String> history = const []})
      : _history = history;

  factory _$TrainingStateImpl.fromJson(Map<String, dynamic> json) =>
      _$$TrainingStateImplFromJson(json);

  @override
  final String workoutId;
  @override
  final String exerciseId;
  @override
  final String exerciseName;
  @override
  final double baseWeight;
  @override
  final String currentStageId;
  final List<String> _history;
  @override
  @JsonKey()
  List<String> get history {
    if (_history is EqualUnmodifiableListView) return _history;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_history);
  }

  @override
  String toString() {
    return 'TrainingState(workoutId: $workoutId, exerciseId: $exerciseId, exerciseName: $exerciseName, baseWeight: $baseWeight, currentStageId: $currentStageId, history: $history)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TrainingStateImpl &&
            (identical(other.workoutId, workoutId) ||
                other.workoutId == workoutId) &&
            (identical(other.exerciseId, exerciseId) ||
                other.exerciseId == exerciseId) &&
            (identical(other.exerciseName, exerciseName) ||
                other.exerciseName == exerciseName) &&
            (identical(other.baseWeight, baseWeight) ||
                other.baseWeight == baseWeight) &&
            (identical(other.currentStageId, currentStageId) ||
                other.currentStageId == currentStageId) &&
            const DeepCollectionEquality().equals(other._history, _history));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      workoutId,
      exerciseId,
      exerciseName,
      baseWeight,
      currentStageId,
      const DeepCollectionEquality().hash(_history));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$TrainingStateImplCopyWith<_$TrainingStateImpl> get copyWith =>
      __$$TrainingStateImplCopyWithImpl<_$TrainingStateImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TrainingStateImplToJson(
      this,
    );
  }
}

abstract class _TrainingState implements TrainingState {
  const factory _TrainingState(
      {required final String workoutId,
      required final String exerciseId,
      required final String exerciseName,
      required final double baseWeight,
      required final String currentStageId,
      final List<String> history}) = _$TrainingStateImpl;

  factory _TrainingState.fromJson(Map<String, dynamic> json) =
      _$TrainingStateImpl.fromJson;

  @override
  String get workoutId;
  @override
  String get exerciseId;
  @override
  String get exerciseName;
  @override
  double get baseWeight;
  @override
  String get currentStageId;
  @override
  List<String> get history;
  @override
  @JsonKey(ignore: true)
  _$$TrainingStateImplCopyWith<_$TrainingStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SessionSetState _$SessionSetStateFromJson(Map<String, dynamic> json) {
  return _SessionSetState.fromJson(json);
}

/// @nodoc
mixin _$SessionSetState {
  String get id => throw _privateConstructorUsedError;
  String get role => throw _privateConstructorUsedError;
  int get targetReps => throw _privateConstructorUsedError;
  int get completedReps => throw _privateConstructorUsedError;
  double get targetWeight => throw _privateConstructorUsedError;
  double get weight => throw _privateConstructorUsedError;
  bool get isAmrap => throw _privateConstructorUsedError;
  bool get isCompleted => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $SessionSetStateCopyWith<SessionSetState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SessionSetStateCopyWith<$Res> {
  factory $SessionSetStateCopyWith(
          SessionSetState value, $Res Function(SessionSetState) then) =
      _$SessionSetStateCopyWithImpl<$Res, SessionSetState>;
  @useResult
  $Res call(
      {String id,
      String role,
      int targetReps,
      int completedReps,
      double targetWeight,
      double weight,
      bool isAmrap,
      bool isCompleted});
}

/// @nodoc
class _$SessionSetStateCopyWithImpl<$Res, $Val extends SessionSetState>
    implements $SessionSetStateCopyWith<$Res> {
  _$SessionSetStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? role = null,
    Object? targetReps = null,
    Object? completedReps = null,
    Object? targetWeight = null,
    Object? weight = null,
    Object? isAmrap = null,
    Object? isCompleted = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
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
abstract class _$$SessionSetStateImplCopyWith<$Res>
    implements $SessionSetStateCopyWith<$Res> {
  factory _$$SessionSetStateImplCopyWith(_$SessionSetStateImpl value,
          $Res Function(_$SessionSetStateImpl) then) =
      __$$SessionSetStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String role,
      int targetReps,
      int completedReps,
      double targetWeight,
      double weight,
      bool isAmrap,
      bool isCompleted});
}

/// @nodoc
class __$$SessionSetStateImplCopyWithImpl<$Res>
    extends _$SessionSetStateCopyWithImpl<$Res, _$SessionSetStateImpl>
    implements _$$SessionSetStateImplCopyWith<$Res> {
  __$$SessionSetStateImplCopyWithImpl(
      _$SessionSetStateImpl _value, $Res Function(_$SessionSetStateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? role = null,
    Object? targetReps = null,
    Object? completedReps = null,
    Object? targetWeight = null,
    Object? weight = null,
    Object? isAmrap = null,
    Object? isCompleted = null,
  }) {
    return _then(_$SessionSetStateImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
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
class _$SessionSetStateImpl implements _SessionSetState {
  const _$SessionSetStateImpl(
      {required this.id,
      required this.role,
      required this.targetReps,
      required this.completedReps,
      required this.targetWeight,
      required this.weight,
      this.isAmrap = false,
      this.isCompleted = false});

  factory _$SessionSetStateImpl.fromJson(Map<String, dynamic> json) =>
      _$$SessionSetStateImplFromJson(json);

  @override
  final String id;
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
    return 'SessionSetState(id: $id, role: $role, targetReps: $targetReps, completedReps: $completedReps, targetWeight: $targetWeight, weight: $weight, isAmrap: $isAmrap, isCompleted: $isCompleted)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SessionSetStateImpl &&
            (identical(other.id, id) || other.id == id) &&
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
  int get hashCode => Object.hash(runtimeType, id, role, targetReps,
      completedReps, targetWeight, weight, isAmrap, isCompleted);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$SessionSetStateImplCopyWith<_$SessionSetStateImpl> get copyWith =>
      __$$SessionSetStateImplCopyWithImpl<_$SessionSetStateImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SessionSetStateImplToJson(
      this,
    );
  }
}

abstract class _SessionSetState implements SessionSetState {
  const factory _SessionSetState(
      {required final String id,
      required final String role,
      required final int targetReps,
      required final int completedReps,
      required final double targetWeight,
      required final double weight,
      final bool isAmrap,
      final bool isCompleted}) = _$SessionSetStateImpl;

  factory _SessionSetState.fromJson(Map<String, dynamic> json) =
      _$SessionSetStateImpl.fromJson;

  @override
  String get id;
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
  _$$SessionSetStateImplCopyWith<_$SessionSetStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ExerciseSessionState _$ExerciseSessionStateFromJson(Map<String, dynamic> json) {
  return _ExerciseSessionState.fromJson(json);
}

/// @nodoc
mixin _$ExerciseSessionState {
  String get id => throw _privateConstructorUsedError;
  String get exerciseId => throw _privateConstructorUsedError;
  String get exerciseName => throw _privateConstructorUsedError;
  String get tier => throw _privateConstructorUsedError;
  int get restSeconds => throw _privateConstructorUsedError;
  String get stageId => throw _privateConstructorUsedError;
  List<SessionSetState> get sets => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ExerciseSessionStateCopyWith<ExerciseSessionState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ExerciseSessionStateCopyWith<$Res> {
  factory $ExerciseSessionStateCopyWith(ExerciseSessionState value,
          $Res Function(ExerciseSessionState) then) =
      _$ExerciseSessionStateCopyWithImpl<$Res, ExerciseSessionState>;
  @useResult
  $Res call(
      {String id,
      String exerciseId,
      String exerciseName,
      String tier,
      int restSeconds,
      String stageId,
      List<SessionSetState> sets});
}

/// @nodoc
class _$ExerciseSessionStateCopyWithImpl<$Res,
        $Val extends ExerciseSessionState>
    implements $ExerciseSessionStateCopyWith<$Res> {
  _$ExerciseSessionStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? exerciseId = null,
    Object? exerciseName = null,
    Object? tier = null,
    Object? restSeconds = null,
    Object? stageId = null,
    Object? sets = null,
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
      exerciseName: null == exerciseName
          ? _value.exerciseName
          : exerciseName // ignore: cast_nullable_to_non_nullable
              as String,
      tier: null == tier
          ? _value.tier
          : tier // ignore: cast_nullable_to_non_nullable
              as String,
      restSeconds: null == restSeconds
          ? _value.restSeconds
          : restSeconds // ignore: cast_nullable_to_non_nullable
              as int,
      stageId: null == stageId
          ? _value.stageId
          : stageId // ignore: cast_nullable_to_non_nullable
              as String,
      sets: null == sets
          ? _value.sets
          : sets // ignore: cast_nullable_to_non_nullable
              as List<SessionSetState>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ExerciseSessionStateImplCopyWith<$Res>
    implements $ExerciseSessionStateCopyWith<$Res> {
  factory _$$ExerciseSessionStateImplCopyWith(_$ExerciseSessionStateImpl value,
          $Res Function(_$ExerciseSessionStateImpl) then) =
      __$$ExerciseSessionStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String exerciseId,
      String exerciseName,
      String tier,
      int restSeconds,
      String stageId,
      List<SessionSetState> sets});
}

/// @nodoc
class __$$ExerciseSessionStateImplCopyWithImpl<$Res>
    extends _$ExerciseSessionStateCopyWithImpl<$Res, _$ExerciseSessionStateImpl>
    implements _$$ExerciseSessionStateImplCopyWith<$Res> {
  __$$ExerciseSessionStateImplCopyWithImpl(_$ExerciseSessionStateImpl _value,
      $Res Function(_$ExerciseSessionStateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? exerciseId = null,
    Object? exerciseName = null,
    Object? tier = null,
    Object? restSeconds = null,
    Object? stageId = null,
    Object? sets = null,
  }) {
    return _then(_$ExerciseSessionStateImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      exerciseId: null == exerciseId
          ? _value.exerciseId
          : exerciseId // ignore: cast_nullable_to_non_nullable
              as String,
      exerciseName: null == exerciseName
          ? _value.exerciseName
          : exerciseName // ignore: cast_nullable_to_non_nullable
              as String,
      tier: null == tier
          ? _value.tier
          : tier // ignore: cast_nullable_to_non_nullable
              as String,
      restSeconds: null == restSeconds
          ? _value.restSeconds
          : restSeconds // ignore: cast_nullable_to_non_nullable
              as int,
      stageId: null == stageId
          ? _value.stageId
          : stageId // ignore: cast_nullable_to_non_nullable
              as String,
      sets: null == sets
          ? _value._sets
          : sets // ignore: cast_nullable_to_non_nullable
              as List<SessionSetState>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ExerciseSessionStateImpl implements _ExerciseSessionState {
  const _$ExerciseSessionStateImpl(
      {required this.id,
      required this.exerciseId,
      required this.exerciseName,
      required this.tier,
      required this.restSeconds,
      required this.stageId,
      required final List<SessionSetState> sets})
      : _sets = sets;

  factory _$ExerciseSessionStateImpl.fromJson(Map<String, dynamic> json) =>
      _$$ExerciseSessionStateImplFromJson(json);

  @override
  final String id;
  @override
  final String exerciseId;
  @override
  final String exerciseName;
  @override
  final String tier;
  @override
  final int restSeconds;
  @override
  final String stageId;
  final List<SessionSetState> _sets;
  @override
  List<SessionSetState> get sets {
    if (_sets is EqualUnmodifiableListView) return _sets;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_sets);
  }

  @override
  String toString() {
    return 'ExerciseSessionState(id: $id, exerciseId: $exerciseId, exerciseName: $exerciseName, tier: $tier, restSeconds: $restSeconds, stageId: $stageId, sets: $sets)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ExerciseSessionStateImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.exerciseId, exerciseId) ||
                other.exerciseId == exerciseId) &&
            (identical(other.exerciseName, exerciseName) ||
                other.exerciseName == exerciseName) &&
            (identical(other.tier, tier) || other.tier == tier) &&
            (identical(other.restSeconds, restSeconds) ||
                other.restSeconds == restSeconds) &&
            (identical(other.stageId, stageId) || other.stageId == stageId) &&
            const DeepCollectionEquality().equals(other._sets, _sets));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, exerciseId, exerciseName,
      tier, restSeconds, stageId, const DeepCollectionEquality().hash(_sets));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ExerciseSessionStateImplCopyWith<_$ExerciseSessionStateImpl>
      get copyWith =>
          __$$ExerciseSessionStateImplCopyWithImpl<_$ExerciseSessionStateImpl>(
              this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ExerciseSessionStateImplToJson(
      this,
    );
  }
}

abstract class _ExerciseSessionState implements ExerciseSessionState {
  const factory _ExerciseSessionState(
      {required final String id,
      required final String exerciseId,
      required final String exerciseName,
      required final String tier,
      required final int restSeconds,
      required final String stageId,
      required final List<SessionSetState> sets}) = _$ExerciseSessionStateImpl;

  factory _ExerciseSessionState.fromJson(Map<String, dynamic> json) =
      _$ExerciseSessionStateImpl.fromJson;

  @override
  String get id;
  @override
  String get exerciseId;
  @override
  String get exerciseName;
  @override
  String get tier;
  @override
  int get restSeconds;
  @override
  String get stageId;
  @override
  List<SessionSetState> get sets;
  @override
  @JsonKey(ignore: true)
  _$$ExerciseSessionStateImplCopyWith<_$ExerciseSessionStateImpl>
      get copyWith => throw _privateConstructorUsedError;
}

WorkoutSessionState _$WorkoutSessionStateFromJson(Map<String, dynamic> json) {
  return _WorkoutSessionState.fromJson(json);
}

/// @nodoc
mixin _$WorkoutSessionState {
  String get instanceId => throw _privateConstructorUsedError;
  String get templateId => throw _privateConstructorUsedError;
  String get workoutId => throw _privateConstructorUsedError;
  String get workoutName => throw _privateConstructorUsedError;
  String get dayLabel => throw _privateConstructorUsedError;
  int get estimatedDurationMinutes => throw _privateConstructorUsedError;
  List<ExerciseSessionState> get exercises =>
      throw _privateConstructorUsedError;
  int get currentExerciseIndex => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $WorkoutSessionStateCopyWith<WorkoutSessionState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WorkoutSessionStateCopyWith<$Res> {
  factory $WorkoutSessionStateCopyWith(
          WorkoutSessionState value, $Res Function(WorkoutSessionState) then) =
      _$WorkoutSessionStateCopyWithImpl<$Res, WorkoutSessionState>;
  @useResult
  $Res call(
      {String instanceId,
      String templateId,
      String workoutId,
      String workoutName,
      String dayLabel,
      int estimatedDurationMinutes,
      List<ExerciseSessionState> exercises,
      int currentExerciseIndex});
}

/// @nodoc
class _$WorkoutSessionStateCopyWithImpl<$Res, $Val extends WorkoutSessionState>
    implements $WorkoutSessionStateCopyWith<$Res> {
  _$WorkoutSessionStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? instanceId = null,
    Object? templateId = null,
    Object? workoutId = null,
    Object? workoutName = null,
    Object? dayLabel = null,
    Object? estimatedDurationMinutes = null,
    Object? exercises = null,
    Object? currentExerciseIndex = null,
  }) {
    return _then(_value.copyWith(
      instanceId: null == instanceId
          ? _value.instanceId
          : instanceId // ignore: cast_nullable_to_non_nullable
              as String,
      templateId: null == templateId
          ? _value.templateId
          : templateId // ignore: cast_nullable_to_non_nullable
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
      estimatedDurationMinutes: null == estimatedDurationMinutes
          ? _value.estimatedDurationMinutes
          : estimatedDurationMinutes // ignore: cast_nullable_to_non_nullable
              as int,
      exercises: null == exercises
          ? _value.exercises
          : exercises // ignore: cast_nullable_to_non_nullable
              as List<ExerciseSessionState>,
      currentExerciseIndex: null == currentExerciseIndex
          ? _value.currentExerciseIndex
          : currentExerciseIndex // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$WorkoutSessionStateImplCopyWith<$Res>
    implements $WorkoutSessionStateCopyWith<$Res> {
  factory _$$WorkoutSessionStateImplCopyWith(_$WorkoutSessionStateImpl value,
          $Res Function(_$WorkoutSessionStateImpl) then) =
      __$$WorkoutSessionStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String instanceId,
      String templateId,
      String workoutId,
      String workoutName,
      String dayLabel,
      int estimatedDurationMinutes,
      List<ExerciseSessionState> exercises,
      int currentExerciseIndex});
}

/// @nodoc
class __$$WorkoutSessionStateImplCopyWithImpl<$Res>
    extends _$WorkoutSessionStateCopyWithImpl<$Res, _$WorkoutSessionStateImpl>
    implements _$$WorkoutSessionStateImplCopyWith<$Res> {
  __$$WorkoutSessionStateImplCopyWithImpl(_$WorkoutSessionStateImpl _value,
      $Res Function(_$WorkoutSessionStateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? instanceId = null,
    Object? templateId = null,
    Object? workoutId = null,
    Object? workoutName = null,
    Object? dayLabel = null,
    Object? estimatedDurationMinutes = null,
    Object? exercises = null,
    Object? currentExerciseIndex = null,
  }) {
    return _then(_$WorkoutSessionStateImpl(
      instanceId: null == instanceId
          ? _value.instanceId
          : instanceId // ignore: cast_nullable_to_non_nullable
              as String,
      templateId: null == templateId
          ? _value.templateId
          : templateId // ignore: cast_nullable_to_non_nullable
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
      estimatedDurationMinutes: null == estimatedDurationMinutes
          ? _value.estimatedDurationMinutes
          : estimatedDurationMinutes // ignore: cast_nullable_to_non_nullable
              as int,
      exercises: null == exercises
          ? _value._exercises
          : exercises // ignore: cast_nullable_to_non_nullable
              as List<ExerciseSessionState>,
      currentExerciseIndex: null == currentExerciseIndex
          ? _value.currentExerciseIndex
          : currentExerciseIndex // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$WorkoutSessionStateImpl implements _WorkoutSessionState {
  const _$WorkoutSessionStateImpl(
      {required this.instanceId,
      required this.templateId,
      required this.workoutId,
      required this.workoutName,
      required this.dayLabel,
      required this.estimatedDurationMinutes,
      required final List<ExerciseSessionState> exercises,
      this.currentExerciseIndex = 0})
      : _exercises = exercises;

  factory _$WorkoutSessionStateImpl.fromJson(Map<String, dynamic> json) =>
      _$$WorkoutSessionStateImplFromJson(json);

  @override
  final String instanceId;
  @override
  final String templateId;
  @override
  final String workoutId;
  @override
  final String workoutName;
  @override
  final String dayLabel;
  @override
  final int estimatedDurationMinutes;
  final List<ExerciseSessionState> _exercises;
  @override
  List<ExerciseSessionState> get exercises {
    if (_exercises is EqualUnmodifiableListView) return _exercises;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_exercises);
  }

  @override
  @JsonKey()
  final int currentExerciseIndex;

  @override
  String toString() {
    return 'WorkoutSessionState(instanceId: $instanceId, templateId: $templateId, workoutId: $workoutId, workoutName: $workoutName, dayLabel: $dayLabel, estimatedDurationMinutes: $estimatedDurationMinutes, exercises: $exercises, currentExerciseIndex: $currentExerciseIndex)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WorkoutSessionStateImpl &&
            (identical(other.instanceId, instanceId) ||
                other.instanceId == instanceId) &&
            (identical(other.templateId, templateId) ||
                other.templateId == templateId) &&
            (identical(other.workoutId, workoutId) ||
                other.workoutId == workoutId) &&
            (identical(other.workoutName, workoutName) ||
                other.workoutName == workoutName) &&
            (identical(other.dayLabel, dayLabel) ||
                other.dayLabel == dayLabel) &&
            (identical(
                    other.estimatedDurationMinutes, estimatedDurationMinutes) ||
                other.estimatedDurationMinutes == estimatedDurationMinutes) &&
            const DeepCollectionEquality()
                .equals(other._exercises, _exercises) &&
            (identical(other.currentExerciseIndex, currentExerciseIndex) ||
                other.currentExerciseIndex == currentExerciseIndex));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      instanceId,
      templateId,
      workoutId,
      workoutName,
      dayLabel,
      estimatedDurationMinutes,
      const DeepCollectionEquality().hash(_exercises),
      currentExerciseIndex);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$WorkoutSessionStateImplCopyWith<_$WorkoutSessionStateImpl> get copyWith =>
      __$$WorkoutSessionStateImplCopyWithImpl<_$WorkoutSessionStateImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$WorkoutSessionStateImplToJson(
      this,
    );
  }
}

abstract class _WorkoutSessionState implements WorkoutSessionState {
  const factory _WorkoutSessionState(
      {required final String instanceId,
      required final String templateId,
      required final String workoutId,
      required final String workoutName,
      required final String dayLabel,
      required final int estimatedDurationMinutes,
      required final List<ExerciseSessionState> exercises,
      final int currentExerciseIndex}) = _$WorkoutSessionStateImpl;

  factory _WorkoutSessionState.fromJson(Map<String, dynamic> json) =
      _$WorkoutSessionStateImpl.fromJson;

  @override
  String get instanceId;
  @override
  String get templateId;
  @override
  String get workoutId;
  @override
  String get workoutName;
  @override
  String get dayLabel;
  @override
  int get estimatedDurationMinutes;
  @override
  List<ExerciseSessionState> get exercises;
  @override
  int get currentExerciseIndex;
  @override
  @JsonKey(ignore: true)
  _$$WorkoutSessionStateImplCopyWith<_$WorkoutSessionStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

TodayWorkoutSummary _$TodayWorkoutSummaryFromJson(Map<String, dynamic> json) {
  return _TodayWorkoutSummary.fromJson(json);
}

/// @nodoc
mixin _$TodayWorkoutSummary {
  String get instanceId => throw _privateConstructorUsedError;
  String get workoutId => throw _privateConstructorUsedError;
  String get workoutName => throw _privateConstructorUsedError;
  String get dayLabel => throw _privateConstructorUsedError;
  String get primaryExerciseId => throw _privateConstructorUsedError;
  String get primaryExerciseName => throw _privateConstructorUsedError;
  int get estimatedDurationMinutes => throw _privateConstructorUsedError;
  int get exerciseCount => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $TodayWorkoutSummaryCopyWith<TodayWorkoutSummary> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TodayWorkoutSummaryCopyWith<$Res> {
  factory $TodayWorkoutSummaryCopyWith(
          TodayWorkoutSummary value, $Res Function(TodayWorkoutSummary) then) =
      _$TodayWorkoutSummaryCopyWithImpl<$Res, TodayWorkoutSummary>;
  @useResult
  $Res call(
      {String instanceId,
      String workoutId,
      String workoutName,
      String dayLabel,
      String primaryExerciseId,
      String primaryExerciseName,
      int estimatedDurationMinutes,
      int exerciseCount});
}

/// @nodoc
class _$TodayWorkoutSummaryCopyWithImpl<$Res, $Val extends TodayWorkoutSummary>
    implements $TodayWorkoutSummaryCopyWith<$Res> {
  _$TodayWorkoutSummaryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? instanceId = null,
    Object? workoutId = null,
    Object? workoutName = null,
    Object? dayLabel = null,
    Object? primaryExerciseId = null,
    Object? primaryExerciseName = null,
    Object? estimatedDurationMinutes = null,
    Object? exerciseCount = null,
  }) {
    return _then(_value.copyWith(
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
      primaryExerciseId: null == primaryExerciseId
          ? _value.primaryExerciseId
          : primaryExerciseId // ignore: cast_nullable_to_non_nullable
              as String,
      primaryExerciseName: null == primaryExerciseName
          ? _value.primaryExerciseName
          : primaryExerciseName // ignore: cast_nullable_to_non_nullable
              as String,
      estimatedDurationMinutes: null == estimatedDurationMinutes
          ? _value.estimatedDurationMinutes
          : estimatedDurationMinutes // ignore: cast_nullable_to_non_nullable
              as int,
      exerciseCount: null == exerciseCount
          ? _value.exerciseCount
          : exerciseCount // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TodayWorkoutSummaryImplCopyWith<$Res>
    implements $TodayWorkoutSummaryCopyWith<$Res> {
  factory _$$TodayWorkoutSummaryImplCopyWith(_$TodayWorkoutSummaryImpl value,
          $Res Function(_$TodayWorkoutSummaryImpl) then) =
      __$$TodayWorkoutSummaryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String instanceId,
      String workoutId,
      String workoutName,
      String dayLabel,
      String primaryExerciseId,
      String primaryExerciseName,
      int estimatedDurationMinutes,
      int exerciseCount});
}

/// @nodoc
class __$$TodayWorkoutSummaryImplCopyWithImpl<$Res>
    extends _$TodayWorkoutSummaryCopyWithImpl<$Res, _$TodayWorkoutSummaryImpl>
    implements _$$TodayWorkoutSummaryImplCopyWith<$Res> {
  __$$TodayWorkoutSummaryImplCopyWithImpl(_$TodayWorkoutSummaryImpl _value,
      $Res Function(_$TodayWorkoutSummaryImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? instanceId = null,
    Object? workoutId = null,
    Object? workoutName = null,
    Object? dayLabel = null,
    Object? primaryExerciseId = null,
    Object? primaryExerciseName = null,
    Object? estimatedDurationMinutes = null,
    Object? exerciseCount = null,
  }) {
    return _then(_$TodayWorkoutSummaryImpl(
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
      primaryExerciseId: null == primaryExerciseId
          ? _value.primaryExerciseId
          : primaryExerciseId // ignore: cast_nullable_to_non_nullable
              as String,
      primaryExerciseName: null == primaryExerciseName
          ? _value.primaryExerciseName
          : primaryExerciseName // ignore: cast_nullable_to_non_nullable
              as String,
      estimatedDurationMinutes: null == estimatedDurationMinutes
          ? _value.estimatedDurationMinutes
          : estimatedDurationMinutes // ignore: cast_nullable_to_non_nullable
              as int,
      exerciseCount: null == exerciseCount
          ? _value.exerciseCount
          : exerciseCount // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TodayWorkoutSummaryImpl implements _TodayWorkoutSummary {
  const _$TodayWorkoutSummaryImpl(
      {required this.instanceId,
      required this.workoutId,
      required this.workoutName,
      required this.dayLabel,
      required this.primaryExerciseId,
      required this.primaryExerciseName,
      required this.estimatedDurationMinutes,
      required this.exerciseCount});

  factory _$TodayWorkoutSummaryImpl.fromJson(Map<String, dynamic> json) =>
      _$$TodayWorkoutSummaryImplFromJson(json);

  @override
  final String instanceId;
  @override
  final String workoutId;
  @override
  final String workoutName;
  @override
  final String dayLabel;
  @override
  final String primaryExerciseId;
  @override
  final String primaryExerciseName;
  @override
  final int estimatedDurationMinutes;
  @override
  final int exerciseCount;

  @override
  String toString() {
    return 'TodayWorkoutSummary(instanceId: $instanceId, workoutId: $workoutId, workoutName: $workoutName, dayLabel: $dayLabel, primaryExerciseId: $primaryExerciseId, primaryExerciseName: $primaryExerciseName, estimatedDurationMinutes: $estimatedDurationMinutes, exerciseCount: $exerciseCount)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TodayWorkoutSummaryImpl &&
            (identical(other.instanceId, instanceId) ||
                other.instanceId == instanceId) &&
            (identical(other.workoutId, workoutId) ||
                other.workoutId == workoutId) &&
            (identical(other.workoutName, workoutName) ||
                other.workoutName == workoutName) &&
            (identical(other.dayLabel, dayLabel) ||
                other.dayLabel == dayLabel) &&
            (identical(other.primaryExerciseId, primaryExerciseId) ||
                other.primaryExerciseId == primaryExerciseId) &&
            (identical(other.primaryExerciseName, primaryExerciseName) ||
                other.primaryExerciseName == primaryExerciseName) &&
            (identical(
                    other.estimatedDurationMinutes, estimatedDurationMinutes) ||
                other.estimatedDurationMinutes == estimatedDurationMinutes) &&
            (identical(other.exerciseCount, exerciseCount) ||
                other.exerciseCount == exerciseCount));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      instanceId,
      workoutId,
      workoutName,
      dayLabel,
      primaryExerciseId,
      primaryExerciseName,
      estimatedDurationMinutes,
      exerciseCount);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$TodayWorkoutSummaryImplCopyWith<_$TodayWorkoutSummaryImpl> get copyWith =>
      __$$TodayWorkoutSummaryImplCopyWithImpl<_$TodayWorkoutSummaryImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TodayWorkoutSummaryImplToJson(
      this,
    );
  }
}

abstract class _TodayWorkoutSummary implements TodayWorkoutSummary {
  const factory _TodayWorkoutSummary(
      {required final String instanceId,
      required final String workoutId,
      required final String workoutName,
      required final String dayLabel,
      required final String primaryExerciseId,
      required final String primaryExerciseName,
      required final int estimatedDurationMinutes,
      required final int exerciseCount}) = _$TodayWorkoutSummaryImpl;

  factory _TodayWorkoutSummary.fromJson(Map<String, dynamic> json) =
      _$TodayWorkoutSummaryImpl.fromJson;

  @override
  String get instanceId;
  @override
  String get workoutId;
  @override
  String get workoutName;
  @override
  String get dayLabel;
  @override
  String get primaryExerciseId;
  @override
  String get primaryExerciseName;
  @override
  int get estimatedDurationMinutes;
  @override
  int get exerciseCount;
  @override
  @JsonKey(ignore: true)
  _$$TodayWorkoutSummaryImplCopyWith<_$TodayWorkoutSummaryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
