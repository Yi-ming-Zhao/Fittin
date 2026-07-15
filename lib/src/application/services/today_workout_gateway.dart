import 'package:fittin_v2/src/application/exercise_library_provider.dart';
import 'package:fittin_v2/src/data/database_repository.dart';
import 'package:fittin_v2/src/data/sync/sync_models.dart';
import 'package:fittin_v2/src/domain/exercise_library.dart';
import 'package:fittin_v2/src/domain/models/training_plan.dart';
import 'package:fittin_v2/src/domain/models/training_state.dart';
import 'package:fittin_v2/src/domain/models/workout_log.dart';
import 'package:fittin_v2/src/domain/program_engine.dart';
import 'package:uuid/uuid.dart';

abstract class TodayWorkoutGateway {
  Future<PlanTemplate> loadActiveTemplate();

  Future<TodayWorkoutSummary> loadTodayWorkoutSummary();

  Future<WorkoutSessionState> loadTodayWorkoutSession();

  Future<void> concludeWorkoutSession(WorkoutSessionState session);

  Future<PlanTemplate> importSharedTemplate(PlanTemplate template);
}

class DatabaseTodayWorkoutGateway implements TodayWorkoutGateway {
  DatabaseTodayWorkoutGateway(
    this._repository, {
    this.ownerUserId,
    Future<ExerciseLibrary> Function()? exerciseLibraryLoader,
  }) : _exerciseLibraryLoader =
           exerciseLibraryLoader ?? ExerciseLibraryLoader().load;

  final DatabaseRepository _repository;
  final String? ownerUserId;
  final Future<ExerciseLibrary> Function() _exerciseLibraryLoader;
  Future<ExerciseLibrary>? _exerciseLibraryFuture;

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
    final session =
        ProgramEngineDispatcher.resolve(
          context.template.engineFamily,
        ).buildSession(
          template: context.template,
          instance: context.instance,
          workout: context.workout,
          stateByExerciseId: context.stateByExerciseId,
        );
    return _withCanonicalExerciseIds(
      session: session,
      template: context.template,
      library: await _exerciseLibrary(),
    );
  }

  @override
  Future<void> concludeWorkoutSession(WorkoutSessionState session) async {
    final context = await _loadContext();
    final engine = ProgramEngineDispatcher.resolve(
      context.template.engineFamily,
    );
    final library = await _exerciseLibrary();
    final scheduledSession = _withCanonicalExerciseIds(
      session: engine.buildSession(
        template: context.template,
        instance: context.instance,
        workout: context.workout,
        stateByExerciseId: context.stateByExerciseId,
      ),
      template: context.template,
      library: library,
    );
    final canonicalSession = _withCanonicalExerciseIds(
      session: session,
      template: context.template,
      library: library,
    );
    if (!workoutSessionMatchesSchedule(canonicalSession, scheduledSession)) {
      throw StateError(
        'This workout is no longer the active scheduled session. '
        'Return Home and open the current workout.',
      );
    }

    final result = engine.conclude(
      template: context.template,
      instance: context.instance,
      session: canonicalSession,
      stateByExerciseId: context.stateByExerciseId,
    );

    final postInstance = context.instance.copyWith(
      currentWorkoutIndex: result.nextWorkoutIndex,
      engineState: result.updatedEngineState,
      states: result.updatedStates,
    );
    final logId = const Uuid().v5(
      Namespace.url.value,
      'fittin:workout-conclusion:${context.instance.instanceId}:'
      '${scheduledSession.scheduleToken}',
    );
    final existingLog = await _repository.fetchWorkoutLogById(
      logId,
      ownerUserId: ownerUserId,
    );
    final completedAt = existingLog?.completedAt ?? DateTime.now();

    await _repository.logWorkout(
      WorkoutLog(
        instanceId: context.instance.instanceId,
        workoutId: canonicalSession.workoutId,
        logId: logId,
        workoutName: canonicalSession.workoutName,
        dayLabel: canonicalSession.dayLabel,
        completedAt: completedAt,
        exercises: result.logs,
        preConclusionSnapshot: _snapshotFromInstance(context.instance),
        postConclusionSnapshot: _snapshotFromInstance(postInstance),
      ),
      ownerUserId: ownerUserId,
    );

    await _repository.saveInstance(
      postInstance,
      syncStatus: ownerUserId == null
          ? SyncStatusKeys.localOnly
          : SyncStatusKeys.pendingUpload,
    );
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

  Future<ExerciseLibrary> _exerciseLibrary() {
    return _exerciseLibraryFuture ??= _exerciseLibraryLoader();
  }
}

WorkoutSessionState _withCanonicalExerciseIds({
  required WorkoutSessionState session,
  required PlanTemplate template,
  required ExerciseLibrary library,
}) {
  return session.copyWith(
    exercises: [
      for (final sessionExercise in session.exercises)
        _withCanonicalExerciseId(
          sessionExercise: sessionExercise,
          templateExercise: template.findExerciseById(sessionExercise.id),
          library: library,
        ),
    ],
  );
}

ExerciseSessionState _withCanonicalExerciseId({
  required ExerciseSessionState sessionExercise,
  required Exercise templateExercise,
  required ExerciseLibrary library,
}) {
  final resolved = library.resolve(
    exerciseId: templateExercise.exerciseId,
    name: templateExercise.name,
  );
  return sessionExercise.copyWith(exerciseId: resolved.id);
}

bool workoutSessionMatchesSchedule(
  WorkoutSessionState candidate,
  WorkoutSessionState scheduled,
) {
  if (candidate.instanceId != scheduled.instanceId ||
      candidate.templateId != scheduled.templateId ||
      candidate.workoutId != scheduled.workoutId) {
    return false;
  }

  if (candidate.scheduleToken.isNotEmpty &&
      scheduled.scheduleToken.isNotEmpty &&
      candidate.scheduleToken != scheduled.scheduleToken) {
    return false;
  }

  if (candidate.exercises.length != scheduled.exercises.length) {
    return false;
  }
  for (
    var exerciseIndex = 0;
    exerciseIndex < candidate.exercises.length;
    exerciseIndex++
  ) {
    final candidateExercise = candidate.exercises[exerciseIndex];
    final scheduledExercise = scheduled.exercises[exerciseIndex];
    if (candidateExercise.id != scheduledExercise.id ||
        candidateExercise.stageId != scheduledExercise.stageId ||
        candidateExercise.sets.length != scheduledExercise.sets.length) {
      return false;
    }
    for (
      var setIndex = 0;
      setIndex < candidateExercise.sets.length;
      setIndex++
    ) {
      final candidateSet = candidateExercise.sets[setIndex];
      final scheduledSet = scheduledExercise.sets[setIndex];
      if (candidateSet.id != scheduledSet.id ||
          candidateSet.role != scheduledSet.role ||
          candidateSet.targetReps != scheduledSet.targetReps ||
          candidateSet.targetWeight != scheduledSet.targetWeight ||
          candidateSet.targetRpe != scheduledSet.targetRpe ||
          candidateSet.isAmrap != scheduledSet.isAmrap) {
        return false;
      }
    }
  }
  return true;
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
