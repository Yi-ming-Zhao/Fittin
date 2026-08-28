import 'dart:async';
import 'dart:convert';

import 'package:fittin_v2/src/application/active_session_provider.dart';
import 'package:fittin_v2/src/application/advanced_analytics_provider.dart';
import 'package:fittin_v2/src/application/auth_provider.dart';
import 'package:fittin_v2/src/application/body_metrics_provider.dart';
import 'package:fittin_v2/src/application/plan_library_provider.dart';
import 'package:fittin_v2/src/application/progress_analytics_provider.dart';
import 'package:fittin_v2/src/application/sync_refresh_provider.dart';
import 'package:fittin_v2/src/application/template_editor_provider.dart';
import 'package:fittin_v2/src/data/agent_local_repository.dart';
import 'package:fittin_v2/src/data/agent_atomic_mutation.dart';
import 'package:fittin_v2/src/data/agent_business_transaction.dart';
import 'package:fittin_v2/src/data/database_repository.dart';
import 'package:fittin_v2/src/data/local/local_instance_repository.dart';
import 'package:fittin_v2/src/data/local/local_plan_repository.dart';
import 'package:fittin_v2/src/data/local/local_progress_repository.dart';
import 'package:fittin_v2/src/data/local/local_workout_log_repository.dart';
import 'package:fittin_v2/src/data/seeds/seed_utils.dart';
import 'package:fittin_v2/src/domain/models/agent_models.dart';
import 'package:fittin_v2/src/domain/models/body_metric.dart';
import 'package:fittin_v2/src/domain/models/training_plan.dart';
import 'package:fittin_v2/src/domain/models/training_state.dart';
import 'package:fittin_v2/src/domain/models/training_max.dart';
import 'package:fittin_v2/src/domain/models/workout_log.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final agentMutationCoordinatorProvider = Provider<AgentMutationCoordinator>((
  ref,
) {
  return AgentMutationCoordinator(ref);
});

class AgentMutationConflict implements Exception {
  const AgentMutationConflict(this.message);

  final String message;

  @override
  String toString() => message;
}

class AgentMutationCoordinator {
  AgentMutationCoordinator(this._ref);

  final Ref _ref;
  Future<void>? _mutationInFlight;

  Future<AgentActionRecord> confirm(AgentMutationProposal proposal) async {
    AgentActionRecord? result;
    await _serialize(() async {
      result = await _confirmUnlocked(proposal);
    });
    return result!;
  }

  Future<AgentActionRecord> undo(String actionId) async {
    AgentActionRecord? result;
    await _serialize(() async {
      result = await _undoUnlocked(actionId);
    });
    return result!;
  }

  Future<void> _serialize(Future<void> Function() operation) async {
    final previous = _mutationInFlight;
    final completer = Completer<void>();
    _mutationInFlight = completer.future;
    if (previous != null) await previous;
    try {
      await operation();
    } finally {
      completer.complete();
      if (identical(_mutationInFlight, completer.future)) {
        _mutationInFlight = null;
      }
    }
  }

  Future<AgentActionRecord> _confirmUnlocked(
    AgentMutationProposal proposal,
  ) async {
    final ownerUserId = _ref.read(currentUserIdProvider);
    final actionStore = _ref.read(agentLocalRepositoryProvider);
    final previous = await actionStore.fetchAction(
      proposal.operationId,
      ownerUserId: ownerUserId,
    );
    if (previous != null) return previous;
    if (proposal.status != AgentProposalStatus.pending ||
        DateTime.now().difference(proposal.createdAt) >
            const Duration(minutes: 30)) {
      throw const AgentMutationConflict(
        'This proposal expired. Ask the Agent to generate it again.',
      );
    }

    final before = await _targetSnapshot(
      proposal.targetType,
      proposal.targetId,
    );
    if (agentPayloadDigest(before) != proposal.expectedDigest) {
      throw const AgentMutationConflict(
        'The target changed on this or another device. Generate a fresh proposal.',
      );
    }

    final args = _decodeMap(proposal.argumentsJson);
    await _validateSecondaryPreconditions(proposal, args);
    final atomicWriter = AgentAtomicMutationWriter(actionStore);
    final action = await AgentBusinessTransaction(actionStore).run(() async {
      final applied = await _apply(proposal, args, before);
      if (_isBodyMetricTool(proposal.toolName) &&
          !atomicWriter.supportsBodyMetrics) {
        await _applyBodyMetricThroughRepository(applied);
      }
      final action = AgentActionRecord(
        id: proposal.operationId,
        ownerUserId: ownerUserId,
        toolName: proposal.toolName,
        title: proposal.title,
        targetType: applied.targetType ?? proposal.targetType,
        targetId: applied.targetId,
        beforeJson: jsonEncode(applied.before),
        afterJson: jsonEncode(applied.after),
        afterDigest: agentPayloadDigest(applied.currentTarget),
        createdAt: DateTime.now(),
      );
      if (utf8.encode(action.beforeJson).length +
              utf8.encode(action.afterJson).length >
          AgentRunLimits.maxActionSnapshotBytes) {
        throw StateError(
          'This change is too large to keep a safe undo snapshot. Split it into smaller changes.',
        );
      }
      if (_isBodyMetricTool(proposal.toolName) &&
          atomicWriter.supportsBodyMetrics) {
        final metricJson = applied.after;
        await atomicWriter.writeBodyMetric(
          metric: metricJson == null
              ? null
              : BodyMetric.fromJson(_map(metricJson)),
          metricId: applied.targetId,
          ownerUserId: ownerUserId,
          action: action,
          delete: metricJson == null,
        );
      } else {
        await actionStore.saveAction(action);
      }
      return action;
    });
    _refresh();
    return action;
  }

  Future<AgentActionRecord> _undoUnlocked(String actionId) async {
    final ownerUserId = _ref.read(currentUserIdProvider);
    final actionStore = _ref.read(agentLocalRepositoryProvider);
    final action = await actionStore.fetchAction(
      actionId,
      ownerUserId: ownerUserId,
    );
    if (action == null) {
      throw StateError('Agent action not found.');
    }
    if (action.status == AgentActionStatus.undone) return action;
    if (action.status != AgentActionStatus.applied) {
      throw const AgentMutationConflict('This action cannot be undone.');
    }
    final current = await _actionCurrentSnapshot(action);
    if (agentPayloadDigest(current) != action.afterDigest) {
      final conflicted = action.copyWith(status: AgentActionStatus.conflicted);
      await actionStore.saveAction(conflicted);
      throw const AgentMutationConflict(
        'The target changed after this action. Undo was safely refused.',
      );
    }

    final beforePayload = jsonDecode(action.beforeJson);
    final undone = action.copyWith(
      status: AgentActionStatus.undone,
      undoneAt: DateTime.now(),
    );
    final atomicWriter = AgentAtomicMutationWriter(actionStore);
    if (_isBodyMetricTool(action.toolName) &&
        atomicWriter.supportsBodyMetrics) {
      await atomicWriter.writeBodyMetric(
        metric: beforePayload == null
            ? null
            : BodyMetric.fromJson(_map(beforePayload)),
        metricId: action.targetId,
        ownerUserId: ownerUserId,
        action: undone,
        delete: beforePayload == null,
      );
      _refresh();
      return undone;
    }
    await AgentBusinessTransaction(actionStore).run(() async {
      await _revert(action);
      await actionStore.saveAction(undone);
    });
    _refresh();
    return undone;
  }

  Future<_AppliedMutation> _apply(
    AgentMutationProposal proposal,
    Map<String, dynamic> args,
    Object? before,
  ) async {
    switch (proposal.toolName) {
      case 'propose_create_plan':
        final plan = PlanTemplate.fromJson(_map(args['plan']));
        await _ref.read(localPlanRepositoryProvider).saveTemplate(plan);
        return _AppliedMutation(
          targetId: plan.id,
          before: null,
          after: plan.toJson(),
          currentTarget: plan.toJson(),
        );
      case 'propose_revise_plan':
        return _applyPlanRevision(proposal, args, before);
      case 'propose_delete_plan':
        await _ref
            .read(localPlanRepositoryProvider)
            .deleteTemplate(proposal.targetId);
        return _AppliedMutation(
          targetId: proposal.targetId,
          before: before,
          after: null,
          currentTarget: null,
        );
      case 'propose_create_workout_log':
        final log = WorkoutLog.fromJson(_map(args['log']));
        await _ref.read(localWorkoutLogRepositoryProvider).logWorkout(log);
        return _AppliedMutation(
          targetId: log.logId,
          before: null,
          after: log.toJson(),
          currentTarget: log.toJson(),
        );
      case 'propose_update_workout_log':
        final log = WorkoutLog.fromJson(_map(args['log']));
        final result = await _ref
            .read(localWorkoutLogRepositoryProvider)
            .updateWorkoutLog(log);
        final current = await _targetSnapshot('workout_log', log.logId);
        final progressionInstance = result.progressionRewritten
            ? await _ref
                  .read(localInstanceRepositoryProvider)
                  .fetchInstance(log.instanceId)
            : null;
        return _AppliedMutation(
          targetId: log.logId,
          before: before,
          after: {
            'log': current,
            if (progressionInstance != null)
              'progressionInstance': _instanceToJson(progressionInstance),
          },
          currentTarget: {
            'log': current,
            if (progressionInstance != null)
              'progressionInstance': _instanceToJson(progressionInstance),
          },
        );
      case 'propose_delete_workout_log':
        final repository = _ref.read(localWorkoutLogRepositoryProvider);
        final log = WorkoutLog.fromJson(_map(before));
        final progressionRewritten = await repository
            .restoreProgressionBeforeLogIfAllowed(log);
        await repository.deleteWorkoutLog(log.logId);
        final progressionInstance = progressionRewritten
            ? await _ref
                  .read(localInstanceRepositoryProvider)
                  .fetchInstance(log.instanceId)
            : null;
        return _AppliedMutation(
          targetId: log.logId,
          before: before,
          after: {
            'log': null,
            if (progressionInstance != null)
              'progressionInstance': _instanceToJson(progressionInstance),
          },
          currentTarget: {
            'log': null,
            if (progressionInstance != null)
              'progressionInstance': _instanceToJson(progressionInstance),
          },
        );
      case 'propose_create_body_metric':
        final metric = BodyMetric.fromJson(_map(args['metric']));
        return _AppliedMutation(
          targetId: metric.metricId,
          before: null,
          after: metric.toJson(),
          currentTarget: metric.toJson(),
        );
      case 'propose_update_body_metric':
        final metric = BodyMetric.fromJson(_map(args['metric']));
        return _AppliedMutation(
          targetId: metric.metricId,
          before: before,
          after: metric.toJson(),
          currentTarget: metric.toJson(),
        );
      case 'propose_delete_body_metric':
        return _AppliedMutation(
          targetId: proposal.targetId,
          before: before,
          after: null,
          currentTarget: null,
        );
      default:
        throw StateError('Unsupported mutation tool: ${proposal.toolName}');
    }
  }

  Future<void> _validateSecondaryPreconditions(
    AgentMutationProposal proposal,
    Map<String, dynamic> args,
  ) async {
    if (proposal.toolName != 'propose_revise_plan') return;
    final expectedInstanceId = args['activeInstanceId'] as String?;
    final expectedDigest = args['activeInstanceDigest'] as String?;
    if (expectedInstanceId == null || expectedDigest == null) return;
    final active = await _ref
        .read(localInstanceRepositoryProvider)
        .fetchActiveInstance();
    if (active?.instanceId != expectedInstanceId ||
        agentPayloadDigest(
              active == null ? null : _instanceConcurrencySnapshot(active),
            ) !=
            expectedDigest) {
      throw const AgentMutationConflict(
        'Training progress changed after this preview. Generate a fresh proposal.',
      );
    }
  }

  Future<_AppliedMutation> _applyPlanRevision(
    AgentMutationProposal proposal,
    Map<String, dynamic> args,
    Object? before,
  ) async {
    final planRepository = _ref.read(localPlanRepositoryProvider);
    final instanceRepository = _ref.read(localInstanceRepositoryProvider);
    final sourceId = args['templateId'] as String;
    final draft = PlanTemplate.fromJson(_map(args['plan']));
    final oldActive = await instanceRepository.fetchActiveInstance();
    // Freezed's toJson is shallow in memory (phases remain Phase objects).
    // Normalize the snapshot exactly as storage does before decoding it.
    final oldPlan = PlanTemplate.fromJson(_decodeMap(jsonEncode(before)));
    StoredTemplateRecord? saved;
    StoredTrainingInstance? migrated;
    try {
      saved = await planRepository.saveEditedTemplate(
        draft: draft,
        originalTemplateId: sourceId,
      );
      if (oldActive?.templateId == sourceId) {
        migrated = _migrateInstance(
          oldActive!,
          oldPlan: oldPlan,
          newPlan: saved.template,
          operationId: proposal.operationId,
        );
        await instanceRepository.saveAndActivateInstance(migrated);
        migrated =
            await instanceRepository.fetchInstance(migrated.instanceId) ??
            migrated;
      }
    } catch (_) {
      final partial = saved;
      if (migrated != null) {
        try {
          await instanceRepository.activateStoredInstance(
            oldActive!.instanceId,
          );
          await instanceRepository.deleteInstance(migrated.instanceId);
        } catch (_) {}
      }
      if (partial != null) {
        try {
          if (partial.template.id == sourceId) {
            await planRepository.saveTemplate(oldPlan);
          } else {
            await planRepository.deleteTemplate(partial.template.id);
          }
        } catch (_) {}
      }
      rethrow;
    }
    final beforeEnvelope = {
      'sourcePlan': oldPlan.toJson(),
      'sourceTemplateId': sourceId,
      if (oldActive?.templateId == sourceId)
        'sourceActiveInstance': _instanceToJson(oldActive!),
    };
    final afterEnvelope = {
      'savedPlan': saved.template.toJson(),
      'savedTemplateId': saved.template.id,
      'wasForked': saved.template.id != sourceId,
      if (oldActive?.templateId == sourceId)
        'sourceInactiveInstance': _instanceToJson(oldActive!),
      if (migrated != null) 'migratedInstance': _instanceToJson(migrated),
      if (migrated != null) 'activeInstanceId': migrated.instanceId,
    };
    return _AppliedMutation(
      targetId: saved.template.id,
      targetType: 'plan_revision',
      before: beforeEnvelope,
      after: afterEnvelope,
      currentTarget: {
        'savedPlan': saved.template.toJson(),
        if (oldActive?.templateId == sourceId)
          'sourceInactiveInstance': _instanceToJson(oldActive!),
        if (migrated != null) 'migratedInstance': _instanceToJson(migrated),
        if (migrated != null) 'activeInstanceId': migrated.instanceId,
      },
    );
  }

  StoredTrainingInstance _migrateInstance(
    StoredTrainingInstance current, {
    required PlanTemplate oldPlan,
    required PlanTemplate newPlan,
    required String operationId,
  }) {
    final oldWorkoutId = oldPlan.workoutByIndex(current.currentWorkoutIndex).id;
    var nextIndex = newPlan.workouts.indexWhere(
      (workout) => workout.id == oldWorkoutId,
    );
    if (nextIndex < 0) {
      nextIndex = current.currentWorkoutIndex.clamp(
        0,
        newPlan.workouts.length - 1,
      );
    }
    final existingByExerciseId = {
      for (final state in current.states) state.exerciseId: state,
    };
    final starterStates = buildStarterStatesForTemplate(
      newPlan,
      trainingMaxProfile: current.trainingMaxProfile,
    );
    final migratedStates = <TrainingState>[];
    for (final starter in starterStates) {
      final previous = existingByExerciseId[starter.exerciseId];
      if (previous == null) {
        migratedStates.add(starter);
        continue;
      }
      final exercise = newPlan.findExerciseById(starter.exerciseId);
      final stageStillExists = exercise.stages.any(
        (stage) => stage.id == previous.currentStageId,
      );
      migratedStates.add(
        previous.copyWith(
          workoutId: starter.workoutId,
          exerciseName: starter.exerciseName,
          currentStageId: stageStillExists
              ? previous.currentStageId
              : starter.currentStageId,
        ),
      );
    }
    return StoredTrainingInstance(
      instanceId:
          '${current.instanceId}-agent-${operationId.replaceAll('-', '').substring(0, 8)}',
      templateId: newPlan.id,
      currentWorkoutIndex: nextIndex,
      ownerUserId: current.ownerUserId,
      trainingMaxProfile: current.trainingMaxProfile,
      engineState: current.engineState,
      states: migratedStates,
      createdAt: current.createdAt,
      updatedAt: DateTime.now(),
    );
  }

  Future<void> _revert(AgentActionRecord action) async {
    final before = jsonDecode(action.beforeJson);
    switch (action.toolName) {
      case 'propose_create_plan':
        await _ref
            .read(localPlanRepositoryProvider)
            .deleteTemplate(action.targetId);
        return;
      case 'propose_revise_plan':
        await _revertPlanRevision(before, jsonDecode(action.afterJson));
        return;
      case 'propose_delete_plan':
        await _ref
            .read(localPlanRepositoryProvider)
            .saveTemplate(PlanTemplate.fromJson(_map(before)));
        return;
      case 'propose_create_workout_log':
        await _ref
            .read(localWorkoutLogRepositoryProvider)
            .deleteWorkoutLog(action.targetId);
        return;
      case 'propose_update_workout_log':
        await _ref
            .read(localWorkoutLogRepositoryProvider)
            .updateWorkoutLog(WorkoutLog.fromJson(_map(before)));
        return;
      case 'propose_delete_workout_log':
        final log = WorkoutLog.fromJson(_map(before));
        final repository = _ref.read(localWorkoutLogRepositoryProvider);
        await repository.logWorkout(log);
        await repository.applyProgressionAfterLogIfAllowed(log);
        return;
      case 'propose_create_body_metric':
        await _ref
            .read(localProgressRepositoryProvider)
            .deleteBodyMetric(action.targetId);
        return;
      case 'propose_update_body_metric':
      case 'propose_delete_body_metric':
        await _ref
            .read(localProgressRepositoryProvider)
            .saveBodyMetric(BodyMetric.fromJson(_map(before)));
        return;
      default:
        throw StateError('Unsupported undo operation: ${action.toolName}');
    }
  }

  Future<void> _revertPlanRevision(Object? before, Object? after) async {
    final beforeMap = _map(before);
    final afterMap = _map(after);
    final sourcePlan = PlanTemplate.fromJson(_map(beforeMap['sourcePlan']));
    final savedId = afterMap['savedTemplateId'] as String;
    final wasForked = afterMap['wasForked'] as bool? ?? false;
    final instanceRepository = _ref.read(localInstanceRepositoryProvider);
    final migratedJson = afterMap['migratedInstance'];
    if (migratedJson != null) {
      final migrated = _instanceFromJson(_map(migratedJson));
      final source = _instanceFromJson(_map(beforeMap['sourceActiveInstance']));
      await instanceRepository.activateStoredInstance(source.instanceId);
      await instanceRepository.deleteInstance(migrated.instanceId);
    }
    if (wasForked) {
      await _ref.read(localPlanRepositoryProvider).deleteTemplate(savedId);
    } else {
      await _ref.read(localPlanRepositoryProvider).saveTemplate(sourcePlan);
    }
  }

  Future<Object?> _targetSnapshot(String targetType, String targetId) async {
    switch (targetType) {
      case 'plan':
        final record = await _ref
            .read(localPlanRepositoryProvider)
            .fetchStoredTemplate(targetId);
        return record?.template.toJson();
      case 'workout_log':
        final log = await _ref
            .read(localWorkoutLogRepositoryProvider)
            .fetchWorkoutLogById(targetId);
        return log?.toJson();
      case 'body_metric':
        final metrics = await _ref
            .read(localProgressRepositoryProvider)
            .fetchBodyMetrics();
        for (final metric in metrics) {
          if (metric.metricId == targetId) return metric.toJson();
        }
        return null;
      default:
        throw StateError('Unsupported target type: $targetType');
    }
  }

  StoredTrainingInstance migrateInstanceForTesting(
    StoredTrainingInstance current, {
    required PlanTemplate oldPlan,
    required PlanTemplate newPlan,
    required String operationId,
  }) => _migrateInstance(
    current,
    oldPlan: oldPlan,
    newPlan: newPlan,
    operationId: operationId,
  );

  Future<Object?> _actionCurrentSnapshot(AgentActionRecord action) async {
    if (action.toolName == 'propose_update_workout_log' ||
        action.toolName == 'propose_delete_workout_log') {
      final after = _map(jsonDecode(action.afterJson));
      final currentLog = await _targetSnapshot('workout_log', action.targetId);
      final progressionJson = after['progressionInstance'];
      if (progressionJson == null) return {'log': currentLog};
      final instanceId = _map(progressionJson)['instanceId'] as String;
      final currentInstance = await _ref
          .read(localInstanceRepositoryProvider)
          .fetchInstance(instanceId);
      return {
        'log': currentLog,
        'progressionInstance': currentInstance == null
            ? null
            : _instanceToJson(currentInstance),
      };
    }
    if (action.targetType != 'plan_revision') {
      return _targetSnapshot(action.targetType, action.targetId);
    }
    final plan = await _targetSnapshot('plan', action.targetId);
    if (plan == null) return null;
    final after = _map(jsonDecode(action.afterJson));
    final migratedJson = after['migratedInstance'];
    if (migratedJson == null) return {'savedPlan': plan};
    final migratedId = _map(migratedJson)['instanceId'] as String;
    final instance = await _ref
        .read(localInstanceRepositoryProvider)
        .fetchInstance(migratedId);
    final sourceJson = after['sourceInactiveInstance'];
    final sourceId = sourceJson == null
        ? null
        : _map(sourceJson)['instanceId'] as String;
    final source = sourceId == null
        ? null
        : await _ref
              .read(localInstanceRepositoryProvider)
              .fetchInstance(sourceId);
    final active = await _ref
        .read(localInstanceRepositoryProvider)
        .fetchActiveInstance();
    return {
      'savedPlan': plan,
      if (sourceJson != null)
        'sourceInactiveInstance': source == null
            ? null
            : _instanceToJson(source),
      'migratedInstance': instance == null ? null : _instanceToJson(instance),
      'activeInstanceId': active?.instanceId,
    };
  }

  void _refresh() {
    _ref.read(syncRefreshProvider.notifier).state++;
    _ref.invalidate(planLibraryItemsProvider);
    _ref.invalidate(templateLibraryProvider);
    _ref.invalidate(todayWorkoutSummaryProvider);
    _ref.invalidate(activeTemplateProvider);
    _ref.invalidate(activeSessionProvider);
    _ref.invalidate(progressAnalyticsOverviewProvider);
    _ref.invalidate(advancedAnalyticsDataProvider);
    _ref.read(bodyMetricsProvider.notifier).reload();
  }

  static Map<String, dynamic> _decodeMap(String value) =>
      _map(jsonDecode(value));

  static bool _isBodyMetricTool(String toolName) =>
      toolName == 'propose_create_body_metric' ||
      toolName == 'propose_update_body_metric' ||
      toolName == 'propose_delete_body_metric';

  Future<void> _applyBodyMetricThroughRepository(
    _AppliedMutation applied,
  ) async {
    final repository = _ref.read(localProgressRepositoryProvider);
    if (applied.after == null) {
      await repository.deleteBodyMetric(applied.targetId);
    } else {
      await repository.saveBodyMetric(BodyMetric.fromJson(_map(applied.after)));
    }
  }

  static Map<String, dynamic> _map(Object? value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return value.cast<String, dynamic>();
    throw const FormatException('Expected an object.');
  }

  static Map<String, dynamic> _instanceToJson(
    StoredTrainingInstance instance,
  ) => {
    'instanceId': instance.instanceId,
    'templateId': instance.templateId,
    'currentWorkoutIndex': instance.currentWorkoutIndex,
    'ownerUserId': instance.ownerUserId,
    'trainingMaxProfile': instance.trainingMaxProfile.toJson(),
    'engineState': instance.engineState,
    'states': instance.states.map((state) => state.toJson()).toList(),
    'createdAt': instance.createdAt.toUtc().toIso8601String(),
    'updatedAt': instance.updatedAt.toUtc().toIso8601String(),
  };

  static Map<String, dynamic> _instanceConcurrencySnapshot(
    StoredTrainingInstance instance,
  ) => {
    'instanceId': instance.instanceId,
    'templateId': instance.templateId,
    'currentWorkoutIndex': instance.currentWorkoutIndex,
    'trainingMaxProfile': instance.trainingMaxProfile.toJson(),
    'engineState': instance.engineState,
    'states': instance.states.map((state) => state.toJson()).toList(),
  };

  static StoredTrainingInstance _instanceFromJson(Map<String, dynamic> json) =>
      StoredTrainingInstance(
        instanceId: json['instanceId'] as String,
        templateId: json['templateId'] as String,
        currentWorkoutIndex: json['currentWorkoutIndex'] as int,
        ownerUserId: json['ownerUserId'] as String?,
        trainingMaxProfile: TrainingMaxProfile.fromJson(
          _map(json['trainingMaxProfile']),
        ),
        engineState: _map(json['engineState']),
        states: (json['states'] as List)
            .map((item) => TrainingState.fromJson(_map(item)))
            .toList(),
        createdAt: DateTime.parse(json['createdAt'] as String).toLocal(),
        updatedAt: DateTime.parse(json['updatedAt'] as String).toLocal(),
      );
}

class _AppliedMutation {
  const _AppliedMutation({
    required this.targetId,
    this.targetType,
    required this.before,
    required this.after,
    required this.currentTarget,
  });

  final String targetId;
  final String? targetType;
  final Object? before;
  final Object? after;
  final Object? currentTarget;
}
