import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fittin_v2/src/application/active_session_provider.dart';
import 'package:fittin_v2/src/application/auth_provider.dart';
import 'package:fittin_v2/src/data/database_repository.dart';
import 'package:fittin_v2/src/domain/models/agent_models.dart';
import 'package:fittin_v2/src/domain/models/training_plan.dart';
import 'package:fittin_v2/src/domain/models/training_state.dart';
import 'package:fittin_v2/src/domain/models/workout_log.dart';
import 'package:fittin_v2/src/domain/program_engine.dart';
import 'package:fittin_v2/src/domain/microcycle_schedule.dart';

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

  Future<WorkoutLogUpdateResult> updateWorkoutLog(
    WorkoutLog log, {
    WorkoutLog? expectedLog,
  }) => _repository.trainingTransaction(
    () => _updateWorkoutLog(log, expectedLog: expectedLog),
  );

  Future<WorkoutLogUpdateResult> _updateWorkoutLog(
    WorkoutLog log, {
    WorkoutLog? expectedLog,
  }) async {
    final existing = await fetchWorkoutLogById(log.logId);
    if (existing == null) {
      throw StateError('Workout log not found: ${log.logId}');
    }
    if (expectedLog != null &&
        agentPayloadDigest(existing.toJson()) !=
            agentPayloadDigest(expectedLog.toJson())) {
      throw StateError('Training record changed. Reload and try again.');
    }

    final normalizedLog = log.copyWith(
      logId: log.logId,
      preConclusionSnapshot: existing.preConclusionSnapshot,
      postConclusionSnapshot: existing.postConclusionSnapshot,
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

  Future<void> deleteWorkoutLog(
    String logId, {
    WorkoutLog? expectedLog,
    bool releaseToPlan = false,
  }) => _repository.trainingTransaction(() async {
    final currentLog = await fetchWorkoutLogById(logId);
    if (currentLog == null ||
        (expectedLog != null &&
            agentPayloadDigest(currentLog.toJson()) !=
                agentPayloadDigest(expectedLog.toJson()))) {
      throw StateError('Training record changed. Reload and try again.');
    }
    if (releaseToPlan) {
      final instance = await _repository.fetchActiveInstanceForUser(
        _ownerUserId,
      );
      if (instance == null || instance.instanceId != currentLog.instanceId) {
        throw StateError(
          'This record does not belong to the active plan. Switch to its plan before releasing it.',
        );
      }
      if (await _repository.fetchActiveSessionDraft(
            instance.instanceId,
            ownerUserId: _ownerUserId,
          ) !=
          null) {
        throw StateError(
          'Finish or discard the active training draft before releasing a day.',
        );
      }
      final template = await _repository.fetchTemplate(instance.templateId);
      if (template == null ||
          !template.workouts.any((day) => day.id == currentLog.workoutId)) {
        throw StateError(
          'The original training day no longer exists in this plan.',
        );
      }
      final restored = await restoreProgressionBeforeLogIfAllowed(currentLog);
      if (restored) {
        final restoredInstance = (await _repository.fetchInstance(
          instance.instanceId,
        ))!;
        await _repository.updateInstanceEngineState(
          instanceId: instance.instanceId,
          ownerUserId: _ownerUserId,
          expectedVersion: restoredInstance.version,
          engineState: {
            ...restoredInstance.engineState,
            'releasedTrainingGeneration':
                ((instance.engineState['releasedTrainingGeneration'] as num?)
                        ?.toInt() ??
                    0) +
                1,
          },
        );
      } else {
        await _repository.updateInstanceEngineState(
          instanceId: instance.instanceId,
          ownerUserId: _ownerUserId,
          expectedVersion: instance.version,
          engineState: {
            ...instance.engineState,
            releasedWorkoutQueueEngineKey: [
              ...releasedWorkoutQueue(instance),
              currentLog.workoutId,
            ],
          },
        );
      }
    }
    await _repository.deleteWorkoutLog(logId, ownerUserId: _ownerUserId);
  });

  /// Restores the exact pre-workout state only when this is still the newest
  /// log and the active instance matches the recorded post-workout snapshot.
  /// Otherwise callers may safely edit/delete history without rewinding a
  /// plan that has since advanced on this or another device.
  Future<bool> restoreProgressionBeforeLogIfAllowed(WorkoutLog log) async {
    final preSnapshot = log.preConclusionSnapshot;
    final postSnapshot = log.postConclusionSnapshot;
    if (preSnapshot == null || postSnapshot == null) return false;

    final logs = await fetchWorkoutLogs(log.instanceId);
    if (logs.isEmpty || logs.first.logId != log.logId) return false;
    final currentInstance = await _repository.fetchInstance(log.instanceId);
    if (currentInstance == null ||
        currentInstance.currentWorkoutIndex !=
            postSnapshot.currentWorkoutIndex ||
        agentPayloadDigest(_progressionSnapshot(currentInstance)) !=
            agentPayloadDigest(_progressionSnapshotFromLog(postSnapshot))) {
      return false;
    }
    await _repository.saveInstance(
      _instanceFromSnapshot(
        currentInstance: currentInstance,
        snapshot: preSnapshot,
      ),
    );
    return true;
  }

  Future<bool> applyProgressionAfterLogIfAllowed(WorkoutLog log) async {
    final preSnapshot = log.preConclusionSnapshot;
    final postSnapshot = log.postConclusionSnapshot;
    if (preSnapshot == null || postSnapshot == null) return false;
    final currentInstance = await _repository.fetchInstance(log.instanceId);
    if (currentInstance == null ||
        agentPayloadDigest(_progressionSnapshot(currentInstance)) !=
            agentPayloadDigest(_progressionSnapshotFromLog(preSnapshot))) {
      return false;
    }
    await _repository.saveInstance(
      _instanceFromSnapshot(
        currentInstance: currentInstance,
        snapshot: postSnapshot,
      ),
    );
    return true;
  }

  Map<String, dynamic> _progressionSnapshot(StoredTrainingInstance instance) =>
      {
        'templateId': instance.templateId,
        'currentWorkoutIndex': instance.currentWorkoutIndex,
        'trainingMaxProfile': instance.trainingMaxProfile.toJson(),
        'engineState': instance.engineState,
        'states': instance.states.map((state) => state.toJson()).toList(),
      };

  Map<String, dynamic> _progressionSnapshotFromLog(
    WorkoutProgressionSnapshot snapshot,
  ) => {
    'templateId': snapshot.templateId,
    'currentWorkoutIndex': snapshot.currentWorkoutIndex,
    'trainingMaxProfile': snapshot.trainingMaxProfile.toJson(),
    'engineState': snapshot.engineState,
    'states': snapshot.states.map((state) => state.toJson()).toList(),
  };

  Future<bool> _rewriteProgressionIfAllowed(WorkoutLog updatedLog) async {
    if (await _repository.fetchActiveSessionDraft(
          updatedLog.instanceId,
          ownerUserId: _ownerUserId,
        ) !=
        null) {
      return false;
    }
    final preSnapshot = updatedLog.preConclusionSnapshot;
    final postSnapshot = updatedLog.postConclusionSnapshot;
    if ((preSnapshot?.engineState[releasedWorkoutQueueEngineKey] as List? ??
            const [])
        .isNotEmpty) {
      return false;
    }
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
        agentPayloadDigest(_progressionSnapshot(currentInstance)) !=
            agentPayloadDigest(_progressionSnapshotFromLog(postSnapshot))) {
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
            isSkipped: log.sets[index].isSkipped,
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
