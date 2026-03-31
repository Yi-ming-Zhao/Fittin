import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fittin_v2/src/application/active_session_provider.dart';
import 'package:fittin_v2/src/application/auth_provider.dart';
import 'package:fittin_v2/src/data/database_repository.dart';
import 'package:fittin_v2/src/domain/models/training_plan.dart';
import 'package:fittin_v2/src/domain/models/training_state.dart';
import 'package:fittin_v2/src/domain/models/workout_log.dart';
import 'package:fittin_v2/src/domain/program_engine.dart';

final localWorkoutLogRepositoryProvider = Provider<LocalWorkoutLogRepository>((
  ref,
) {
  return LocalWorkoutLogRepository(
    repository: ref.watch(databaseRepositoryProvider),
    ownerUserId: ref.watch(currentUserIdProvider),
  );
});

class LocalWorkoutLogRepository {
  LocalWorkoutLogRepository({
    required DatabaseRepository repository,
    required String? ownerUserId,
  }) : _repository = repository,
       _ownerUserId = ownerUserId;

  final DatabaseRepository _repository;
  final String? _ownerUserId;

  Future<void> logWorkout(WorkoutLog log) {
    return _repository.logWorkout(log, ownerUserId: _ownerUserId);
  }

  Future<List<WorkoutLog>> fetchWorkoutLogs(String instanceId) {
    return _repository.fetchWorkoutLogs(instanceId, ownerUserId: _ownerUserId);
  }

  Future<List<WorkoutLog>> fetchAllWorkoutLogs() {
    return _repository.fetchAllWorkoutLogs(ownerUserId: _ownerUserId);
  }

  Future<WorkoutLog?> fetchWorkoutLogById(String logId) {
    return _repository.fetchWorkoutLogById(logId, ownerUserId: _ownerUserId);
  }

  Future<WorkoutLogUpdateResult> updateWorkoutLog(WorkoutLog log) async {
    final existing = await fetchWorkoutLogById(log.logId);
    if (existing == null) {
      throw StateError('Workout log not found: ${log.logId}');
    }

    final normalizedLog = log.copyWith(
      logId: log.logId,
      preConclusionSnapshot:
          log.preConclusionSnapshot ?? existing.preConclusionSnapshot,
      postConclusionSnapshot:
          log.postConclusionSnapshot ?? existing.postConclusionSnapshot,
    );

    await _repository.updateWorkoutLog(
      normalizedLog,
      ownerUserId: _ownerUserId,
    );

    final progressionRewritten = await _rewriteProgressionIfAllowed(
      normalizedLog,
    );
    return WorkoutLogUpdateResult(
      log: normalizedLog,
      progressionRewritten: progressionRewritten,
    );
  }

  Future<bool> _rewriteProgressionIfAllowed(WorkoutLog updatedLog) async {
    final preSnapshot = updatedLog.preConclusionSnapshot;
    final postSnapshot = updatedLog.postConclusionSnapshot;
    if (preSnapshot == null || postSnapshot == null) {
      return false;
    }

    final logs = await fetchWorkoutLogs(updatedLog.instanceId);
    if (logs.isEmpty || logs.first.logId != updatedLog.logId) {
      return false;
    }

    final currentInstance = await _repository.fetchInstance(
      updatedLog.instanceId,
    );
    if (currentInstance == null ||
        currentInstance.currentWorkoutIndex !=
            postSnapshot.currentWorkoutIndex) {
      return false;
    }

    final template = await _repository.fetchTemplate(preSnapshot.templateId);
    if (template == null) {
      return false;
    }

    final baseInstance = _instanceFromSnapshot(
      currentInstance: currentInstance,
      snapshot: preSnapshot,
    );
    final replaySession = _sessionFromLog(updatedLog, template);
    final stateByExerciseId = {
      for (final state in baseInstance.states) state.exerciseId: state,
    };
    final result = ProgramEngineDispatcher.resolve(template.engineFamily)
        .conclude(
          template: template,
          instance: baseInstance,
          session: replaySession,
          stateByExerciseId: stateByExerciseId,
        );

    await _repository.saveInstance(
      currentInstance.copyWith(
        currentWorkoutIndex: result.nextWorkoutIndex,
        engineState: result.updatedEngineState,
        states: result.updatedStates,
      ),
    );
    return true;
  }

  StoredTrainingInstance _instanceFromSnapshot({
    required StoredTrainingInstance currentInstance,
    required WorkoutProgressionSnapshot snapshot,
  }) {
    return StoredTrainingInstance(
      instanceId: currentInstance.instanceId,
      templateId: snapshot.templateId,
      currentWorkoutIndex: snapshot.currentWorkoutIndex,
      ownerUserId: currentInstance.ownerUserId,
      trainingMaxProfile: snapshot.trainingMaxProfile,
      engineState: snapshot.engineState,
      states: snapshot.states,
      createdAt: currentInstance.createdAt,
      updatedAt: currentInstance.updatedAt,
      deletedAt: currentInstance.deletedAt,
      version: currentInstance.version,
      syncStatus: currentInstance.syncStatus,
      lastSyncedAt: currentInstance.lastSyncedAt,
      lastModifiedByDeviceId: currentInstance.lastModifiedByDeviceId,
    );
  }

  WorkoutSessionState _sessionFromLog(WorkoutLog log, PlanTemplate template) {
    final exercises = [
      for (final exerciseLog in log.exercises)
        _exerciseSessionFromLog(
          exerciseLog,
          template.findExerciseById(exerciseLog.exerciseId),
        ),
    ];
    return WorkoutSessionState(
      instanceId: log.instanceId,
      templateId: template.id,
      workoutId: log.workoutId,
      workoutName: log.workoutName,
      dayLabel: log.dayLabel,
      estimatedDurationMinutes: template
          .findWorkoutById(log.workoutId)
          .estimatedDurationMinutes,
      exercises: exercises,
    );
  }

  ExerciseSessionState _exerciseSessionFromLog(
    ExerciseLog log,
    Exercise exercise,
  ) {
    return ExerciseSessionState(
      id: log.exerciseId,
      exerciseId: exercise.exerciseId,
      exerciseName: log.exerciseName,
      tier: exercise.tier,
      restSeconds: exercise.restSeconds,
      stageId: log.stageId,
      sets: [
        for (var index = 0; index < log.sets.length; index++)
          SessionSetState(
            id: '${log.exerciseId}-$index',
            role: log.sets[index].role,
            targetReps: log.sets[index].targetReps,
            completedReps: log.sets[index].completedReps,
            targetWeight: log.sets[index].targetWeight,
            weight: log.sets[index].weight,
            isAmrap: log.sets[index].isAmrap,
            isCompleted: log.sets[index].isCompleted,
          ),
      ],
    );
  }
}

class WorkoutLogUpdateResult {
  const WorkoutLogUpdateResult({
    required this.log,
    required this.progressionRewritten,
  });

  final WorkoutLog log;
  final bool progressionRewritten;
}
