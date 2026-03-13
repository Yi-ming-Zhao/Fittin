import 'package:fittin_v2/src/data/database_repository.dart';
import 'package:fittin_v2/src/domain/models/training_max.dart';
import 'package:fittin_v2/src/domain/models/training_plan.dart';
import 'package:fittin_v2/src/domain/models/training_state.dart';
import 'package:fittin_v2/src/domain/models/workout_log.dart';
import 'package:fittin_v2/src/domain/rule_engine.dart';

class ProgramEngineDispatcher {
  static ProgramEngine resolve(String engineFamily) {
    switch (engineFamily) {
      case 'linear_tm':
        return const LinearProgramEngine();
      case 'periodized_tm':
        return const PeriodizedProgramEngine();
      default:
        return const LinearProgramEngine();
    }
  }
}

abstract class ProgramEngine {
  const ProgramEngine();

  WorkoutSessionState buildSession({
    required PlanTemplate template,
    required StoredTrainingInstance instance,
    required Workout workout,
    required Map<String, TrainingState> stateByExerciseId,
  });

  ProgramEngineResult conclude({
    required PlanTemplate template,
    required StoredTrainingInstance instance,
    required WorkoutSessionState session,
    required Map<String, TrainingState> stateByExerciseId,
  });
}

class LinearProgramEngine extends ProgramEngine {
  const LinearProgramEngine();

  @override
  WorkoutSessionState buildSession({
    required PlanTemplate template,
    required StoredTrainingInstance instance,
    required Workout workout,
    required Map<String, TrainingState> stateByExerciseId,
  }) {
    return WorkoutSessionState(
      instanceId: instance.instanceId,
      templateId: template.id,
      workoutId: workout.id,
      workoutName: workout.name,
      dayLabel: workout.dayLabel,
      estimatedDurationMinutes: workout.estimatedDurationMinutes,
      exercises: [
        for (final exercise in workout.exercises)
          _buildExerciseSession(
            exercise: exercise,
            state: stateByExerciseId[exercise.id]!,
            baseWeight: stateByExerciseId[exercise.id]!.baseWeight,
          ),
      ],
    );
  }

  @override
  ProgramEngineResult conclude({
    required PlanTemplate template,
    required StoredTrainingInstance instance,
    required WorkoutSessionState session,
    required Map<String, TrainingState> stateByExerciseId,
  }) {
    final updatedStates = [...instance.states];
    final logs = <ExerciseLog>[];

    for (final exerciseSession in session.exercises) {
      final currentState = stateByExerciseId[exerciseSession.id]!;
      final templateExercise = template.findExerciseById(exerciseSession.id);
      final stage = templateExercise.stageById(currentState.currentStageId);
      final log = _exerciseLogFromSession(
        stageId: currentState.currentStageId,
        session: exerciseSession,
      );
      logs.add(log);

      final nextState = stage.rules.isEmpty
          ? currentState
          : RuleEngine.evaluateNextWorkout(currentState, log, stage.rules);

      final stateIndex = updatedStates.indexWhere(
        (state) => state.exerciseId == currentState.exerciseId,
      );
      updatedStates[stateIndex] = nextState.copyWith(
        history: [...currentState.history, session.workoutId],
      );
    }

    return ProgramEngineResult(
      nextWorkoutIndex:
          (instance.currentWorkoutIndex + 1) % template.workouts.length,
      updatedStates: updatedStates,
      logs: logs,
      updatedEngineState: instance.engineState,
    );
  }
}

class PeriodizedProgramEngine extends ProgramEngine {
  const PeriodizedProgramEngine();

  @override
  WorkoutSessionState buildSession({
    required PlanTemplate template,
    required StoredTrainingInstance instance,
    required Workout workout,
    required Map<String, TrainingState> stateByExerciseId,
  }) {
    return WorkoutSessionState(
      instanceId: instance.instanceId,
      templateId: template.id,
      workoutId: workout.id,
      workoutName: workout.name,
      dayLabel: workout.dayLabel,
      estimatedDurationMinutes: workout.estimatedDurationMinutes,
      exercises: [
        for (final exercise in workout.exercises)
          _buildExerciseSession(
            exercise: exercise,
            state: stateByExerciseId[exercise.id]!,
            baseWeight: _resolvePeriodizedBaseWeight(
              exercise: exercise,
              state: stateByExerciseId[exercise.id]!,
              trainingMaxProfile: instance.trainingMaxProfile,
            ),
          ),
      ],
    );
  }

  @override
  ProgramEngineResult conclude({
    required PlanTemplate template,
    required StoredTrainingInstance instance,
    required WorkoutSessionState session,
    required Map<String, TrainingState> stateByExerciseId,
  }) {
    final updatedStates = [...instance.states];
    final logs = <ExerciseLog>[];

    for (final exerciseSession in session.exercises) {
      final currentState = stateByExerciseId[exerciseSession.id]!;
      final exercise = template.findExerciseById(exerciseSession.id);
      final currentStage = exercise.stageById(currentState.currentStageId);
      final currentStageIndex = exercise.stages.indexOf(currentStage);
      final nextStageIndex =
          currentStageIndex + 1 < exercise.stages.length
          ? currentStageIndex + 1
          : currentStageIndex;
      final nextStage = exercise.stages[nextStageIndex];

      logs.add(
        _exerciseLogFromSession(
          stageId: currentState.currentStageId,
          session: exerciseSession,
        ),
      );

      final stateIndex = updatedStates.indexWhere(
        (state) => state.exerciseId == currentState.exerciseId,
      );
      updatedStates[stateIndex] = currentState.copyWith(
        baseWeight: _resolveStageBaseWeight(
          exercise: exercise,
          stage: nextStage,
          trainingMaxProfile: instance.trainingMaxProfile,
        ),
        currentStageId: nextStage.id,
        history: [...currentState.history, session.workoutId],
      );
    }

    final rawWeekIndex =
        (instance.engineState['currentWeekIndex'] as num?)?.toInt() ?? 0;
    final completedWeek = instance.currentWorkoutIndex == template.workouts.length - 1;
    final nextWeekIndex = completedWeek ? rawWeekIndex + 1 : rawWeekIndex;
    final cycleLengthWeeks =
        (instance.engineState['cycleLengthWeeks'] as num?)?.toInt() ??
        template.workoutByIndex(0).exercises.first.stages.length;

    return ProgramEngineResult(
      nextWorkoutIndex:
          (instance.currentWorkoutIndex + 1) % template.workouts.length,
      updatedStates: updatedStates,
      logs: logs,
      updatedEngineState: {
        'currentWeekIndex': nextWeekIndex,
        'currentBlockIndex': nextWeekIndex ~/ cycleLengthWeeks,
        'cycleLengthWeeks': cycleLengthWeeks,
      },
    );
  }
}

class ProgramEngineResult {
  const ProgramEngineResult({
    required this.nextWorkoutIndex,
    required this.updatedStates,
    required this.logs,
    required this.updatedEngineState,
  });

  final int nextWorkoutIndex;
  final List<TrainingState> updatedStates;
  final List<ExerciseLog> logs;
  final Map<String, dynamic> updatedEngineState;
}

ExerciseSessionState _buildExerciseSession({
  required Exercise exercise,
  required TrainingState state,
  required double baseWeight,
}) {
  final stage = exercise.stageById(state.currentStageId);
  return ExerciseSessionState(
    id: exercise.id,
    exerciseId: exercise.exerciseId,
    exerciseName: exercise.name,
    tier: exercise.tier,
    restSeconds: exercise.restSeconds,
    stageId: stage.id,
    sets: [
      for (var index = 0; index < stage.sets.length; index++)
        _buildSessionSet(
          id: '${exercise.id}-$index',
          definition: stage.sets[index],
          baseWeight: baseWeight,
          roundingIncrement: exercise.roundingIncrement,
        ),
    ],
  );
}

SessionSetState _buildSessionSet({
  required String id,
  required SetDefinition definition,
  required double baseWeight,
  required double roundingIncrement,
}) {
  final targetWeight = roundToIncrement(
    baseWeight * definition.intensity,
    roundingIncrement,
  );
  return SessionSetState(
    id: id,
    role: definition.kind,
    targetReps: definition.targetReps,
    completedReps: definition.targetReps,
    targetWeight: targetWeight,
    weight: targetWeight,
    isAmrap: definition.isAmrap,
  );
}

double _resolvePeriodizedBaseWeight({
  required Exercise exercise,
  required TrainingState state,
  required TrainingMaxProfile trainingMaxProfile,
}) {
  final stage = exercise.stageById(state.currentStageId);
  return _resolveStageBaseWeight(
    exercise: exercise,
    stage: stage,
    trainingMaxProfile: trainingMaxProfile,
  );
}

double _resolveStageBaseWeight({
  required Exercise exercise,
  required SetScheme stage,
  required TrainingMaxProfile trainingMaxProfile,
}) {
  if (exercise.trainingMaxLift == null || trainingMaxProfile.isEmpty) {
    return exercise.initialBaseWeight;
  }
  return roundToIncrement(
    trainingMaxProfile.require(exercise.trainingMaxLift!) *
        exercise.trainingMaxMultiplier *
        stage.basePercent,
    exercise.roundingIncrement,
  );
}

ExerciseLog _exerciseLogFromSession({
  required String stageId,
  required ExerciseSessionState session,
}) {
  return ExerciseLog(
    exerciseId: session.id,
    exerciseName: session.exerciseName,
    stageId: stageId,
    sets: [
      for (final set in session.sets)
        SetLog(
          role: set.role,
          targetReps: set.targetReps,
          completedReps: set.completedReps,
          targetWeight: set.targetWeight,
          weight: set.weight,
          isAmrap: set.isAmrap,
          isCompleted: set.isCompleted,
        ),
    ],
  );
}
