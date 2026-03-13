import 'package:freezed_annotation/freezed_annotation.dart';

part 'training_state.freezed.dart';
part 'training_state.g.dart';

@freezed
class TrainingState with _$TrainingState {
  const factory TrainingState({
    required String workoutId,
    required String exerciseId,
    required String exerciseName,
    required double baseWeight,
    required String currentStageId,
    @Default([]) List<String> history,
  }) = _TrainingState;

  factory TrainingState.fromJson(Map<String, dynamic> json) =>
      _$TrainingStateFromJson(json);
}

@freezed
class SessionSetState with _$SessionSetState {
  const factory SessionSetState({
    required String id,
    required String role,
    required int targetReps,
    required int completedReps,
    required double targetWeight,
    required double weight,
    @Default(false) bool isAmrap,
    @Default(false) bool isCompleted,
  }) = _SessionSetState;

  factory SessionSetState.fromJson(Map<String, dynamic> json) =>
      _$SessionSetStateFromJson(json);
}

@freezed
class ExerciseSessionState with _$ExerciseSessionState {
  const factory ExerciseSessionState({
    required String id,
    required String exerciseId,
    required String exerciseName,
    required String tier,
    required int restSeconds,
    required String stageId,
    required List<SessionSetState> sets,
  }) = _ExerciseSessionState;

  factory ExerciseSessionState.fromJson(Map<String, dynamic> json) =>
      _$ExerciseSessionStateFromJson(json);
}

@freezed
class WorkoutSessionState with _$WorkoutSessionState {
  const factory WorkoutSessionState({
    required String instanceId,
    required String templateId,
    required String workoutId,
    required String workoutName,
    required String dayLabel,
    required int estimatedDurationMinutes,
    required List<ExerciseSessionState> exercises,
    @Default(0) int currentExerciseIndex,
  }) = _WorkoutSessionState;

  factory WorkoutSessionState.fromJson(Map<String, dynamic> json) =>
      _$WorkoutSessionStateFromJson(json);
}

@freezed
class TodayWorkoutSummary with _$TodayWorkoutSummary {
  const factory TodayWorkoutSummary({
    required String instanceId,
    required String workoutId,
    required String workoutName,
    required String dayLabel,
    required String primaryExerciseId,
    required String primaryExerciseName,
    required int estimatedDurationMinutes,
    required int exerciseCount,
  }) = _TodayWorkoutSummary;

  factory TodayWorkoutSummary.fromJson(Map<String, dynamic> json) =>
      _$TodayWorkoutSummaryFromJson(json);
}
