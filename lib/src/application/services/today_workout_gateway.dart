import 'package:fittin_v2/src/data/database_repository.dart';
import 'package:fittin_v2/src/domain/models/training_plan.dart';
import 'package:fittin_v2/src/domain/models/training_state.dart';
import 'package:fittin_v2/src/domain/models/workout_log.dart';
import 'package:fittin_v2/src/domain/program_engine.dart';

abstract class TodayWorkoutGateway {
  Future<PlanTemplate> loadActiveTemplate();

  Future<TodayWorkoutSummary> loadTodayWorkoutSummary();

  Future<WorkoutSessionState> loadTodayWorkoutSession();

  Future<void> concludeWorkoutSession(WorkoutSessionState session);

  Future<PlanTemplate> importSharedTemplate(PlanTemplate template);
}

class DatabaseTodayWorkoutGateway implements TodayWorkoutGateway {
  DatabaseTodayWorkoutGateway(this._repository, {this.ownerUserId});

  final DatabaseRepository _repository;
  final String? ownerUserId;

  @override
  Future<PlanTemplate> loadActiveTemplate() async {
    final context = await _loadContext();
    return context.template;
  }

  @override
  Future<TodayWorkoutSummary> loadTodayWorkoutSummary() async {
    final context = await _loadContext();
    final workout = context.workout;
    final cycleWeekCount =
        (context.instance.engineState['cycleLengthWeeks'] as num?)?.toInt() ??
        workout.exercises.first.stages.length;
    final currentWeekIndex =
        (context.instance.engineState['currentWeekIndex'] as num?)?.toInt() ??
        0;
    final workoutsPerWeek = context.template.workoutsPerCycleWeek();
    return TodayWorkoutSummary(
      instanceId: context.instance.instanceId,
      workoutId: workout.id,
      workoutName: workout.name,
      dayLabel: workout.dayLabel,
      currentWeekNumber: (currentWeekIndex % cycleWeekCount) + 1,
      currentDayNumber:
          (context.instance.currentWorkoutIndex % workoutsPerWeek) + 1,
      cycleWeekCount: cycleWeekCount,
      workoutsPerWeek: workoutsPerWeek,
      primaryExerciseId: workout.exercises.first.id,
      primaryExerciseName: workout.exercises.first.name,
      estimatedDurationMinutes: workout.estimatedDurationMinutes,
      exerciseCount: workout.exercises.length,
    );
  }

  @override
  Future<WorkoutSessionState> loadTodayWorkoutSession() async {
    final context = await _loadContext();
    return ProgramEngineDispatcher.resolve(
      context.template.engineFamily,
    ).buildSession(
      template: context.template,
      instance: context.instance,
      workout: context.workout,
      stateByExerciseId: context.stateByExerciseId,
    );
  }

  @override
  Future<void> concludeWorkoutSession(WorkoutSessionState session) async {
    final context = await _loadContext();
    final result =
        ProgramEngineDispatcher.resolve(context.template.engineFamily).conclude(
          template: context.template,
          instance: context.instance,
          session: session,
          stateByExerciseId: context.stateByExerciseId,
        );

    final postInstance = context.instance.copyWith(
      currentWorkoutIndex: result.nextWorkoutIndex,
      engineState: result.updatedEngineState,
      states: result.updatedStates,
    );

    await _repository.logWorkout(
      WorkoutLog(
        instanceId: context.instance.instanceId,
        workoutId: session.workoutId,
        logId:
            '${context.instance.instanceId}_${session.workoutId}_${DateTime.now().millisecondsSinceEpoch}',
        workoutName: session.workoutName,
        dayLabel: session.dayLabel,
        completedAt: DateTime.now(),
        exercises: result.logs,
        preConclusionSnapshot: _snapshotFromInstance(context.instance),
        postConclusionSnapshot: _snapshotFromInstance(postInstance),
      ),
      ownerUserId: ownerUserId,
    );

    await _repository.saveInstance(postInstance);
  }

  @override
  Future<PlanTemplate> importSharedTemplate(PlanTemplate template) {
    return _repository.importSharedTemplate(template);
  }

  Future<_ProgramContext> _loadContext() async {
    await _repository.ensureDefaultProgramSeeded();
    final instance = await _repository.fetchActiveInstanceForUser(ownerUserId);
    final template = instance == null
        ? null
        : await _repository.fetchTemplate(instance.templateId);

    if (template == null || instance == null) {
      throw StateError(
        'No active training plan instance. Open Plan Library to start one.',
      );
    }

    final workout = template.workoutByIndex(instance.currentWorkoutIndex);
    final stateByExerciseId = {
      for (final state in instance.states) state.exerciseId: state,
    };

    return _ProgramContext(
      template: template,
      instance: instance,
      workout: workout,
      stateByExerciseId: stateByExerciseId,
    );
  }
}

WorkoutProgressionSnapshot _snapshotFromInstance(
  StoredTrainingInstance instance,
) {
  return WorkoutProgressionSnapshot(
    templateId: instance.templateId,
    currentWorkoutIndex: instance.currentWorkoutIndex,
    trainingMaxProfile: instance.trainingMaxProfile,
    engineState: instance.engineState,
    states: instance.states,
  );
}

class _ProgramContext {
  _ProgramContext({
    required this.template,
    required this.instance,
    required this.workout,
    required this.stateByExerciseId,
  });

  final PlanTemplate template;
  final StoredTrainingInstance instance;
  final Workout workout;
  final Map<String, TrainingState> stateByExerciseId;
}
