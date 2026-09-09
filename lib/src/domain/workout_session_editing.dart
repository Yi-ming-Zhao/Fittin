import 'package:fittin_v2/src/domain/models/training_state.dart';
import 'package:fittin_v2/src/domain/models/workout_log.dart';

/// Keeps trusted identity and progression metadata on the original log.
WorkoutSessionState sessionForHistory(WorkoutLog log) => WorkoutSessionState(
  instanceId: log.instanceId,
  templateId: log.preConclusionSnapshot?.templateId ?? '',
  workoutId: log.workoutId,
  workoutName: log.workoutName,
  dayLabel: log.dayLabel,
  estimatedDurationMinutes: 0,
  exercises: [
    for (var index = 0; index < log.exercises.length; index++)
      ExerciseSessionState(
        id: log.exercises[index].exerciseId,
        exerciseId: log.exercises[index].exerciseDefinitionId,
        exerciseName: log.exercises[index].exerciseName,
        tier: 'T3',
        restSeconds: 60,
        stageId: log.exercises[index].stageId,
        displayLoadUnit: log.exercises[index].displayLoadUnit,
        sets: [
          for (
            var setIndex = 0;
            setIndex < log.exercises[index].sets.length;
            setIndex++
          )
            SessionSetState.fromJson({
              ...log.exercises[index].sets[setIndex].toJson(),
              'id': 'history-$index-$setIndex',
            }),
        ],
      ),
  ],
);

WorkoutLog applySessionToHistory(
  WorkoutLog original,
  WorkoutSessionState session, {
  DateTime? completedAt,
}) => original.copyWith(
  completedAt: completedAt ?? original.completedAt,
  exercises: [
    for (final exercise in session.exercises)
      ExerciseLog(
        exerciseId: exercise.id,
        exerciseDefinitionId: exercise.exerciseId,
        exerciseName: exercise.exerciseName,
        stageId: exercise.stageId,
        displayLoadUnit: exercise.displayLoadUnit,
        sets: [for (final set in exercise.sets) SetLog.fromJson(set.toJson())],
      ),
  ],
);
