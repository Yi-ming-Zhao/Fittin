import 'package:fittin_v2/src/domain/models/training_max.dart';
import 'package:fittin_v2/src/domain/models/training_state.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'workout_log.freezed.dart';
part 'workout_log.g.dart';

@freezed
class WorkoutLog with _$WorkoutLog {
  const factory WorkoutLog({
    @Default('') String logId,
    required String instanceId,
    required String workoutId,
    required String workoutName,
    required String dayLabel,
    required DateTime completedAt,
    required List<ExerciseLog> exercises,
    WorkoutProgressionSnapshot? preConclusionSnapshot,
    WorkoutProgressionSnapshot? postConclusionSnapshot,
  }) = _WorkoutLog;

  factory WorkoutLog.fromJson(Map<String, dynamic> json) =>
      _$WorkoutLogFromJson(json);
}

@freezed
class WorkoutProgressionSnapshot with _$WorkoutProgressionSnapshot {
  const factory WorkoutProgressionSnapshot({
    required String templateId,
    required int currentWorkoutIndex,
    required TrainingMaxProfile trainingMaxProfile,
    required Map<String, dynamic> engineState,
    required List<TrainingState> states,
  }) = _WorkoutProgressionSnapshot;

  factory WorkoutProgressionSnapshot.fromJson(Map<String, dynamic> json) =>
      _$WorkoutProgressionSnapshotFromJson(json);
}

@freezed
class ExerciseLog with _$ExerciseLog {
  const factory ExerciseLog({
    required String exerciseId,
    required String exerciseName,
    required String stageId,
    required List<SetLog> sets,
  }) = _ExerciseLog;

  factory ExerciseLog.fromJson(Map<String, dynamic> json) =>
      _$ExerciseLogFromJson(json);
}

@freezed
class SetLog with _$SetLog {
  const factory SetLog({
    required String role,
    required int targetReps,
    required int completedReps,
    required double targetWeight,
    required double weight,
    @Default(false) bool isAmrap,
    @Default(false) bool isCompleted,
  }) = _SetLog;

  factory SetLog.fromJson(Map<String, dynamic> json) => _$SetLogFromJson(json);
}
