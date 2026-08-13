import 'dart:convert';

import 'package:fittin_v2/src/application/advanced_analytics_provider.dart';
import 'package:fittin_v2/src/application/app_locale_provider.dart';
import 'package:fittin_v2/src/application/exercise_library_provider.dart';
import 'package:fittin_v2/src/application/pr_dashboard_provider.dart';
import 'package:fittin_v2/src/application/progress_analytics_provider.dart';
import 'package:fittin_v2/src/data/database_repository.dart';
import 'package:fittin_v2/src/data/local/local_instance_repository.dart';
import 'package:fittin_v2/src/data/local/local_plan_repository.dart';
import 'package:fittin_v2/src/data/local/local_progress_repository.dart';
import 'package:fittin_v2/src/data/local/local_workout_log_repository.dart';
import 'package:fittin_v2/src/domain/models/agent_models.dart';
import 'package:fittin_v2/src/domain/models/body_metric.dart';
import 'package:fittin_v2/src/domain/models/training_plan.dart';
import 'package:fittin_v2/src/domain/models/workout_log.dart';
import 'package:fittin_v2/src/domain/template_validation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

final agentToolRegistryProvider = Provider<AgentToolRegistry>((ref) {
  return AgentToolRegistry(ref);
});

class AgentToolResult {
  const AgentToolResult({
    required this.payload,
    this.proposal,
    this.isError = false,
  });

  final Map<String, dynamic> payload;
  final AgentMutationProposal? proposal;
  final bool isError;

  String get encoded => jsonEncode(payload);
}

class AgentToolRegistry {
  AgentToolRegistry(this._ref);

  final Ref _ref;

  bool get _isChinese => _ref.read(appLocaleProvider) == AppLocale.zh;

  static const readToolNames = {
    'list_plans',
    'get_active_plan',
    'get_workout_history',
    'analyze_training',
    'get_body_metrics',
  };

  static const mutationToolNames = {
    'propose_create_plan',
    'propose_revise_plan',
    'propose_delete_plan',
    'propose_create_workout_log',
    'propose_update_workout_log',
    'propose_delete_workout_log',
    'propose_create_body_metric',
    'propose_update_body_metric',
    'propose_delete_body_metric',
  };

  List<Map<String, dynamic>> get definitions => [
    _tool(
      'list_plans',
      'List visible training plans and whether they are active.',
      _object({'limit': _integer(1, 50)}, required: const []),
    ),
    _tool(
      'get_active_plan',
      'Read the active plan, current workout position, training maxes and exercise progression.',
      _object(const {}, required: const []),
    ),
    _tool(
      'get_workout_history',
      'Read recent workout logs using a bounded limit and optional day range.',
      _object({
        'limit': _integer(1, AgentRunLimits.maxRawRows),
        'days': _integer(1, 3650),
        'cursor': _string(),
      }, required: const []),
    ),
    _tool(
      'analyze_training',
      'Calculate deterministic PR, volume, consistency and muscle-load analytics locally.',
      _object({'days': _integer(1, 3650)}, required: const []),
    ),
    _tool(
      'get_body_metrics',
      'Read bounded body weight, body-fat and waist history. Progress photos are excluded.',
      _object({
        'limit': _integer(1, AgentRunLimits.maxRawRows),
        'days': _integer(1, 3650),
        'cursor': _string(),
      }, required: const []),
    ),
    _tool(
      'propose_create_plan',
      'Propose creating a training plan. Never writes before approval.',
      _object(
        {
          'plan': const {'type': 'object'},
        },
        required: const ['plan'],
      ),
    ),
    _tool(
      'propose_revise_plan',
      'Propose a full validated revision of an existing plan while preserving stable IDs.',
      _object(
        {
          'templateId': _string(),
          'plan': const {'type': 'object'},
        },
        required: const ['templateId', 'plan'],
      ),
    ),
    _tool(
      'propose_delete_plan',
      'Propose deleting an unused custom plan. Built-in or instantiated plans cannot be deleted.',
      _object({'templateId': _string()}, required: const ['templateId']),
    ),
    _tool(
      'propose_create_workout_log',
      'Propose adding a historical workout log without advancing current plan progress.',
      _object(
        {
          'log': const {'type': 'object'},
        },
        required: const ['log'],
      ),
    ),
    _tool(
      'propose_update_workout_log',
      'Propose correcting a workout log. Include the complete revised log JSON.',
      _object(
        {
          'logId': _string(),
          'log': const {'type': 'object'},
        },
        required: const ['logId', 'log'],
      ),
    ),
    _tool(
      'propose_delete_workout_log',
      'Propose soft-deleting a workout log.',
      _object({'logId': _string()}, required: const ['logId']),
    ),
    _tool(
      'propose_create_body_metric',
      'Propose a body metric entry. At least one measurement or note is required.',
      _bodyMetricSchema(includeId: false),
    ),
    _tool(
      'propose_update_body_metric',
      'Propose correcting an existing body metric.',
      _bodyMetricSchema(includeId: true),
    ),
    _tool(
      'propose_delete_body_metric',
      'Propose soft-deleting a body metric.',
      _object({'metricId': _string()}, required: const ['metricId']),
    ),
  ];

  Future<AgentToolResult> execute(
    String name,
    Map<String, dynamic> arguments,
  ) async {
    try {
      return switch (name) {
        'list_plans' => await _listPlans(arguments),
        'get_active_plan' => await _activePlan(),
        'get_workout_history' => await _workoutHistory(arguments),
        'analyze_training' => await _analyzeTraining(arguments),
        'get_body_metrics' => await _bodyMetrics(arguments),
        'propose_create_plan' => await _proposeCreatePlan(arguments),
        'propose_revise_plan' => await _proposeRevisePlan(arguments),
        'propose_delete_plan' => await _proposeDeletePlan(arguments),
        'propose_create_workout_log' => await _proposeCreateLog(arguments),
        'propose_update_workout_log' => await _proposeUpdateLog(arguments),
        'propose_delete_workout_log' => await _proposeDeleteLog(arguments),
        'propose_create_body_metric' => await _proposeCreateMetric(arguments),
        'propose_update_body_metric' => await _proposeUpdateMetric(arguments),
        'propose_delete_body_metric' => await _proposeDeleteMetric(arguments),
        _ => _error('unsupported_tool', 'This operation is not available.'),
      };
    } catch (error) {
      return _error('tool_failed', _safeError(error));
    }
  }

  static Set<String> get exposedReadToolsForTesting => readToolNames;

  static Set<String> get exposedMutationToolsForTesting => mutationToolNames;

  static void validateWorkoutLogForTesting(WorkoutLog log) {
    _validateWorkoutLog(log);
  }

  Future<AgentToolResult> _listPlans(Map<String, dynamic> args) async {
    final records = await _ref
        .read(localPlanRepositoryProvider)
        .fetchTemplates();
    final active = await _ref
        .read(localInstanceRepositoryProvider)
        .fetchActiveInstance();
    final limit = _boundedInt(args['limit'], fallback: 20, max: 50);
    return AgentToolResult(
      payload: {
        'plans': records
            .take(limit)
            .map(
              (record) => {
                'id': record.template.id,
                'name': record.template.name,
                'description': record.template.description,
                'scheduleMode': record.template.resolvedScheduleMode,
                'workoutCount': record.template.workouts.length,
                'isBuiltIn': record.isBuiltIn,
                'instanceCount': record.instanceCount,
                'isActive': active?.templateId == record.template.id,
                'version': record.version,
              },
            )
            .toList(),
        'truncated': records.length > limit,
      },
    );
  }

  Future<AgentToolResult> _activePlan() async {
    final instance = await _ref
        .read(localInstanceRepositoryProvider)
        .fetchActiveInstance();
    if (instance == null) {
      return _error('no_active_plan', 'No plan is active.');
    }
    final record = await _ref
        .read(localPlanRepositoryProvider)
        .fetchStoredTemplate(instance.templateId);
    if (record == null) {
      return _error('plan_missing', 'The active plan is unavailable.');
    }
    final workout = record.template.workoutByIndex(
      instance.currentWorkoutIndex,
    );
    return AgentToolResult(
      payload: {
        'template': record.template.toJson(),
        'templateVersion': record.version,
        'instance': {
          'id': instance.instanceId,
          'version': instance.version,
          'currentWorkoutIndex': instance.currentWorkoutIndex,
          'nextWorkoutId': workout.id,
          'nextWorkoutName': workout.name,
          'trainingMaxProfile': instance.trainingMaxProfile.toJson(),
          'engineState': instance.engineState,
          'exerciseStates': instance.states
              .map((state) => state.toJson())
              .toList(),
        },
      },
    );
  }

  Future<AgentToolResult> _workoutHistory(Map<String, dynamic> args) async {
    final logs = await _ref
        .read(localWorkoutLogRepositoryProvider)
        .fetchAllWorkoutLogs();
    final days = _boundedInt(args['days'], fallback: 180, max: 3650);
    final cutoff = DateTime.now().subtract(Duration(days: days));
    final filtered = logs
        .where((log) => !log.completedAt.isBefore(cutoff))
        .toList();
    final limit = _boundedInt(
      args['limit'],
      fallback: 30,
      max: AgentRunLimits.maxRawRows,
    );
    final offset = _decodeCursor(args['cursor']);
    final page = filtered.skip(offset).take(limit).toList();
    final nextOffset = offset + page.length;
    return AgentToolResult(
      payload: {
        'logs': page.map((log) => log.toJson()).toList(),
        'totalInRange': filtered.length,
        'truncated': nextOffset < filtered.length,
        if (nextOffset < filtered.length)
          'nextCursor': _encodeCursor(nextOffset),
      },
    );
  }

  Future<AgentToolResult> _analyzeTraining(Map<String, dynamic> args) async {
    final days = _boundedInt(args['days'], fallback: 90, max: 3650);
    final logs = await _ref
        .read(localWorkoutLogRepositoryProvider)
        .fetchAllWorkoutLogs();
    final cutoff = DateTime.now().subtract(Duration(days: days));
    final filtered = logs
        .where((log) => !log.completedAt.isBefore(cutoff))
        .toList();
    final library = await _ref.read(exerciseLibraryProvider.future);
    final formula = _ref.read(analyticsFormulaProvider);
    final progress = buildProgressAnalytics(
      filtered,
      formula,
      exerciseLibrary: library,
    );
    final advanced = buildAdvancedAnalytics(
      logs: filtered,
      exerciseLibrary: library,
      activeInstance: await _ref
          .read(localInstanceRepositoryProvider)
          .fetchActiveInstance(),
    );
    final prs = buildPRDashboardData(progress);
    return AgentToolResult(
      payload: {
        'rangeDays': days,
        'completedWorkouts': progress.completedWorkoutCount,
        'trainingDays': progress.recentTrainingDays,
        'volume': progress.recentVolume,
        'exercises': progress.exerciseSummaries
            .take(30)
            .map(
              (summary) => {
                'id': summary.exerciseId,
                'name': summary.exerciseName,
                'sessions': summary.encounterCount,
                'currentE1rm': summary.currentEstimatedOneRepMax,
                'bestE1rm': summary.bestEstimatedOneRepMax,
                'bestActual1rm': summary.bestActualOneRepMax,
                'recentChange': summary.recentChange,
                'volume': summary.totalVolume,
                'stagnating': summary.isStagnating,
              },
            )
            .toList(),
        'recentPrs': prs.recentMilestones
            .map(
              (item) => {
                'date': item.date.toIso8601String(),
                'exercise': item.exerciseName,
                'type': item.type.name,
                'value': item.value,
              },
            )
            .toList(),
        'muscleLoad': advanced.muscleLoad.loads
            .map(
              (load) => {
                'muscle': load.muscle.name,
                'weightedSets': load.weightedCompletedSets,
                'completedSets': load.contributingCompletedSets,
              },
            )
            .toList(),
      },
    );
  }

  Future<AgentToolResult> _bodyMetrics(Map<String, dynamic> args) async {
    final metrics = await _ref
        .read(localProgressRepositoryProvider)
        .fetchBodyMetrics();
    final days = _boundedInt(args['days'], fallback: 365, max: 3650);
    final cutoff = DateTime.now().subtract(Duration(days: days));
    final filtered = metrics
        .where((metric) => !metric.timestamp.isBefore(cutoff))
        .toList();
    final limit = _boundedInt(
      args['limit'],
      fallback: 50,
      max: AgentRunLimits.maxRawRows,
    );
    final offset = _decodeCursor(args['cursor']);
    final page = filtered.skip(offset).take(limit).toList();
    final nextOffset = offset + page.length;
    return AgentToolResult(
      payload: {
        'metrics': page.map((metric) => metric.toJson()).toList(),
        'totalInRange': filtered.length,
        'truncated': nextOffset < filtered.length,
        if (nextOffset < filtered.length)
          'nextCursor': _encodeCursor(nextOffset),
        'photosExcluded': true,
      },
    );
  }

  Future<AgentToolResult> _proposeCreatePlan(Map<String, dynamic> args) async {
    final plan = PlanTemplate.fromJson(_map(args['plan']));
    _validateTemplate(plan);
    final existing = await _ref
        .read(localPlanRepositoryProvider)
        .fetchStoredTemplate(plan.id);
    if (existing != null) {
      throw StateError('A plan with this ID already exists.');
    }
    return _proposal(
      toolName: 'propose_create_plan',
      title: _isChinese ? '创建${plan.name}' : 'Create ${plan.name}',
      summary: _isChinese
          ? '将添加 ${plan.workouts.length} 个训练日。'
          : '${plan.workouts.length} workouts will be added.',
      args: {'plan': plan.toJson()},
      targetType: 'plan',
      targetId: plan.id,
      before: null,
      after: plan.toJson(),
      changes: [
        AgentMutationChange(
          path: _isChinese ? '计划' : 'plan',
          before: _isChinese ? '尚未创建' : 'Not created',
          after: plan.name,
        ),
      ],
    );
  }

  Future<AgentToolResult> _proposeRevisePlan(Map<String, dynamic> args) async {
    final templateId = _requiredString(args, 'templateId');
    final existing = await _ref
        .read(localPlanRepositoryProvider)
        .fetchStoredTemplate(templateId);
    if (existing == null) throw StateError('Plan not found.');
    final plan = PlanTemplate.fromJson(_map(args['plan']));
    _validateTemplate(plan);
    final active = await _ref
        .read(localInstanceRepositoryProvider)
        .fetchActiveInstance();
    final activeRevision = active?.templateId == templateId;
    final oldExerciseIds = existing.template.workouts
        .expand((workout) => workout.exercises)
        .map((exercise) => exercise.id)
        .toSet();
    final newExerciseIds = plan.workouts
        .expand((workout) => workout.exercises)
        .map((exercise) => exercise.id)
        .toSet();
    final added = newExerciseIds.difference(oldExerciseIds);
    final removed = oldExerciseIds.difference(newExerciseIds);
    final activeInstanceDigest = activeRevision
        ? agentPayloadDigest(_instanceConcurrencySnapshot(active!))
        : null;
    return _proposal(
      toolName: 'propose_revise_plan',
      title: _isChinese
          ? '修订${existing.template.name}'
          : 'Revise ${existing.template.name}',
      summary: activeRevision
          ? (_isChinese
                ? '将创建安全副本替换当前计划，并保留可兼容的训练进度。'
                : 'A safe copy will replace the active plan while retaining compatible progress.')
          : (_isChinese
                ? '将更新计划或将其保存为安全副本。'
                : 'The plan will be updated or saved as a safe copy.'),
      args: {
        'templateId': templateId,
        'plan': plan.toJson(),
        if (activeInstanceDigest != null)
          'activeInstanceId': active!.instanceId,
        if (activeInstanceDigest != null)
          'activeInstanceDigest': activeInstanceDigest,
      },
      targetType: 'plan',
      targetId: templateId,
      before: existing.template.toJson(),
      after: plan.toJson(),
      progressionEffect: activeRevision
          ? (_isChinese
                ? '保留当前训练日、训练最大值、进度引擎状态以及 ${newExerciseIds.intersection(oldExerciseIds).length} 个匹配动作的状态；初始化 ${added.length} 个，移除 ${removed.length} 个。'
                : 'Preserve current workout, training maxes, engine state and ${newExerciseIds.intersection(oldExerciseIds).length} matching exercise states; initialize ${added.length}; remove ${removed.length}.')
          : null,
      changes: [
        if (existing.template.name != plan.name)
          AgentMutationChange(
            path: _isChinese ? '名称' : 'name',
            before: existing.template.name,
            after: plan.name,
          ),
        AgentMutationChange(
          path: _isChinese ? '训练日' : 'workouts',
          before: '${existing.template.workouts.length}',
          after: '${plan.workouts.length}',
        ),
        if (added.isNotEmpty)
          AgentMutationChange(
            path: _isChinese ? '新增动作' : 'exercises.added',
            before: _isChinese ? '无' : 'None',
            after: added.join(', '),
          ),
        if (removed.isNotEmpty)
          AgentMutationChange(
            path: _isChinese ? '移除动作' : 'exercises.removed',
            before: removed.join(', '),
            after: _isChinese ? '将移除' : 'Removed',
          ),
      ],
    );
  }

  Future<AgentToolResult> _proposeDeletePlan(Map<String, dynamic> args) async {
    final id = _requiredString(args, 'templateId');
    final existing = await _ref
        .read(localPlanRepositoryProvider)
        .fetchStoredTemplate(id);
    if (existing == null || existing.isBuiltIn || existing.instanceCount > 0) {
      throw StateError('Only unused custom plans can be deleted.');
    }
    return _proposal(
      toolName: 'propose_delete_plan',
      title: _isChinese
          ? '删除${existing.template.name}'
          : 'Delete ${existing.template.name}',
      summary: _isChinese
          ? '该自定义计划将被软删除并同步。'
          : 'The custom plan will be soft-deleted and synced.',
      args: {'templateId': id},
      targetType: 'plan',
      targetId: id,
      before: existing.template.toJson(),
      after: null,
      changes: [
        AgentMutationChange(
          path: _isChinese ? '计划' : 'plan',
          before: existing.template.name,
          after: _isChinese ? '将删除' : 'Deleted',
        ),
      ],
    );
  }

  Future<AgentToolResult> _proposeCreateLog(Map<String, dynamic> args) async {
    var log = WorkoutLog.fromJson(_map(args['log']));
    if (log.logId.isEmpty) {
      log = log.copyWith(logId: const Uuid().v4());
    }
    _validateLog(log);
    return _proposal(
      toolName: 'propose_create_workout_log',
      title: _isChinese
          ? '添加${log.workoutName}记录'
          : 'Add ${log.workoutName} record',
      summary: _isChinese
          ? '该历史记录会更新分析，但不会改变当前计划进度。'
          : 'This historical record will update analytics but not current plan progress.',
      args: {'log': log.toJson()},
      targetType: 'workout_log',
      targetId: log.logId,
      before: null,
      after: log.toJson(),
      progressionEffect: _isChinese
          ? '仅影响历史记录和分析。'
          : 'History and analytics only.',
      changes: [
        AgentMutationChange(
          path: _isChinese ? '完成时间' : 'completedAt',
          before: _isChinese ? '尚未记录' : 'Not recorded',
          after: log.completedAt.toLocal().toString(),
        ),
      ],
    );
  }

  Future<AgentToolResult> _proposeUpdateLog(Map<String, dynamic> args) async {
    final id = _requiredString(args, 'logId');
    final existing = await _ref
        .read(localWorkoutLogRepositoryProvider)
        .fetchWorkoutLogById(id);
    if (existing == null) throw StateError('Workout log not found.');
    final revised = WorkoutLog.fromJson(_map(args['log'])).copyWith(logId: id);
    _validateLog(revised);
    return _proposal(
      toolName: 'propose_update_workout_log',
      title: _isChinese
          ? '修正${existing.workoutName}'
          : 'Correct ${existing.workoutName}',
      summary: _isChinese
          ? '将替换现有训练记录。'
          : 'The existing workout record will be replaced.',
      args: {'logId': id, 'log': revised.toJson()},
      targetType: 'workout_log',
      targetId: id,
      before: existing.toJson(),
      after: revised.toJson(),
      progressionEffect: _isChinese
          ? '仅当它仍是最新且快照兼容的记录时，才会重新计算当前进度。'
          : 'Current progression is recomputed only if this remains the latest snapshot-compatible log.',
      changes: _logChanges(existing, revised),
    );
  }

  Future<AgentToolResult> _proposeDeleteLog(Map<String, dynamic> args) async {
    final id = _requiredString(args, 'logId');
    final existing = await _ref
        .read(localWorkoutLogRepositoryProvider)
        .fetchWorkoutLogById(id);
    if (existing == null) throw StateError('Workout log not found.');
    return _proposal(
      toolName: 'propose_delete_workout_log',
      title: _isChinese
          ? '删除${existing.workoutName}记录'
          : 'Delete ${existing.workoutName} record',
      summary: _isChinese ? '该记录将被软删除。' : 'The record will be soft-deleted.',
      args: {'logId': id},
      targetType: 'workout_log',
      targetId: id,
      before: existing.toJson(),
      after: null,
      progressionEffect: _isChinese
          ? '可能回滚最新且兼容的训练进度；否则仅改变历史记录和分析。'
          : 'Latest compatible progression may be rolled back; otherwise only history and analytics change.',
      changes: [
        AgentMutationChange(
          path: _isChinese ? '记录' : 'record',
          before: existing.completedAt.toLocal().toString(),
          after: _isChinese ? '将删除' : 'Deleted',
        ),
      ],
    );
  }

  Future<AgentToolResult> _proposeCreateMetric(
    Map<String, dynamic> args,
  ) async {
    final metric = _metricFromArgs(args, metricId: const Uuid().v4());
    return _proposal(
      toolName: 'propose_create_body_metric',
      title: _isChinese ? '添加身体测量' : 'Add body measurement',
      summary: _isChinese
          ? '将添加一条新的身体指标记录。'
          : 'A new body metric entry will be added.',
      args: {'metric': metric.toJson()},
      targetType: 'body_metric',
      targetId: metric.metricId,
      before: null,
      after: metric.toJson(),
      changes: _metricChanges(null, metric),
    );
  }

  Future<AgentToolResult> _proposeUpdateMetric(
    Map<String, dynamic> args,
  ) async {
    final id = _requiredString(args, 'metricId');
    final existing = await _findMetric(id);
    final metric = _metricFromArgs(args, metricId: id, fallback: existing);
    return _proposal(
      toolName: 'propose_update_body_metric',
      title: _isChinese ? '修正身体测量' : 'Correct body measurement',
      summary: _isChinese
          ? '将替换选中的记录。'
          : 'The selected entry will be replaced.',
      args: {'metric': metric.toJson()},
      targetType: 'body_metric',
      targetId: id,
      before: existing.toJson(),
      after: metric.toJson(),
      changes: _metricChanges(existing, metric),
    );
  }

  Future<AgentToolResult> _proposeDeleteMetric(
    Map<String, dynamic> args,
  ) async {
    final id = _requiredString(args, 'metricId');
    final existing = await _findMetric(id);
    return _proposal(
      toolName: 'propose_delete_body_metric',
      title: _isChinese ? '删除身体测量' : 'Delete body measurement',
      summary: _isChinese ? '该记录将被软删除。' : 'The entry will be soft-deleted.',
      args: {'metricId': id},
      targetType: 'body_metric',
      targetId: id,
      before: existing.toJson(),
      after: null,
      changes: [
        AgentMutationChange(
          path: _isChinese ? '测量记录' : 'measurement',
          before: existing.timestamp.toLocal().toString(),
          after: _isChinese ? '将删除' : 'Deleted',
        ),
      ],
    );
  }

  AgentToolResult _proposal({
    required String toolName,
    required String title,
    required String summary,
    required Map<String, dynamic> args,
    required String targetType,
    required String targetId,
    required Object? before,
    required Object? after,
    required List<AgentMutationChange> changes,
    String? progressionEffect,
  }) {
    final proposal = AgentMutationProposal(
      operationId: const Uuid().v4(),
      toolName: toolName,
      title: title,
      summary: summary,
      argumentsJson: jsonEncode(args),
      targetType: targetType,
      targetId: targetId,
      expectedDigest: agentPayloadDigest(before),
      changes: changes,
      createdAt: DateTime.now(),
      progressionEffect: progressionEffect,
    );
    return AgentToolResult(
      proposal: proposal,
      payload: {
        'status': 'pending_user_approval',
        'operationId': proposal.operationId,
        'title': title,
        'summary': summary,
        'changes': changes.map((change) => change.toJson()).toList(),
        if (progressionEffect != null) 'progressionEffect': progressionEffect,
      },
    );
  }

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

  Future<BodyMetric> _findMetric(String id) async {
    final metrics = await _ref
        .read(localProgressRepositoryProvider)
        .fetchBodyMetrics();
    return metrics.firstWhere(
      (metric) => metric.metricId == id,
      orElse: () => throw StateError('Body metric not found.'),
    );
  }

  BodyMetric _metricFromArgs(
    Map<String, dynamic> args, {
    required String metricId,
    BodyMetric? fallback,
  }) {
    final metric = BodyMetric(
      metricId: metricId,
      timestamp: args['timestamp'] == null
          ? fallback?.timestamp ?? DateTime.now()
          : DateTime.parse(args['timestamp'] as String),
      weightKg: _nullableDouble(args, 'weightKg', fallback?.weightKg),
      bodyFatPercent: _nullableDouble(
        args,
        'bodyFatPercent',
        fallback?.bodyFatPercent,
      ),
      waistCm: _nullableDouble(args, 'waistCm', fallback?.waistCm),
      note: args.containsKey('note') ? args['note'] as String? : fallback?.note,
    );
    validateAgentBodyMetric(metric);
    return metric;
  }

  void _validateTemplate(PlanTemplate plan) {
    final validation = TemplateValidation.validate(plan);
    if (!validation.isValid) throw StateError(validation.errors.join(' '));
  }

  void _validateLog(WorkoutLog log) {
    _validateWorkoutLog(log);
  }

  static void _validateWorkoutLog(WorkoutLog log) {
    if (log.instanceId.trim().isEmpty ||
        log.workoutId.trim().isEmpty ||
        log.workoutName.trim().isEmpty ||
        log.exercises.isEmpty) {
      throw StateError('Workout log is incomplete.');
    }
    for (final exercise in log.exercises) {
      if (exercise.exerciseId.trim().isEmpty || exercise.sets.isEmpty) {
        throw StateError('Workout exercise is incomplete.');
      }
      for (final set in exercise.sets) {
        if (!set.weight.isFinite ||
            set.weight < 0 ||
            set.completedReps < 0 ||
            set.targetReps < 1 ||
            (set.completedRpe != null &&
                (!set.completedRpe!.isFinite ||
                    set.completedRpe! < 0 ||
                    set.completedRpe! > 10))) {
          throw StateError('Workout set values are invalid.');
        }
      }
    }
  }

  List<AgentMutationChange> _logChanges(WorkoutLog before, WorkoutLog after) =>
      [
        if (before.completedAt != after.completedAt)
          AgentMutationChange(
            path: _isChinese ? '完成时间' : 'completedAt',
            before: before.completedAt.toLocal().toString(),
            after: after.completedAt.toLocal().toString(),
          ),
        AgentMutationChange(
          path: _isChinese ? '完成组数' : 'completedSets',
          before: '${_completedSets(before)}',
          after: '${_completedSets(after)}',
        ),
        AgentMutationChange(
          path: _isChinese ? '训练容量' : 'volume',
          before: _volume(before).toStringAsFixed(1),
          after: _volume(after).toStringAsFixed(1),
        ),
      ];

  List<AgentMutationChange> _metricChanges(
    BodyMetric? before,
    BodyMetric after,
  ) => [
    if (before?.weightKg != after.weightKg)
      AgentMutationChange(
        path: _isChinese ? '体重（kg）' : 'weightKg',
        before:
            before?.weightKg?.toString() ?? (_isChinese ? '未设置' : 'Not set'),
        after: after.weightKg?.toString() ?? (_isChinese ? '将移除' : 'Removed'),
      ),
    if (before?.bodyFatPercent != after.bodyFatPercent)
      AgentMutationChange(
        path: _isChinese ? '体脂率（%）' : 'bodyFatPercent',
        before:
            before?.bodyFatPercent?.toString() ??
            (_isChinese ? '未设置' : 'Not set'),
        after:
            after.bodyFatPercent?.toString() ??
            (_isChinese ? '将移除' : 'Removed'),
      ),
    if (before?.waistCm != after.waistCm)
      AgentMutationChange(
        path: _isChinese ? '腰围（cm）' : 'waistCm',
        before: before?.waistCm?.toString() ?? (_isChinese ? '未设置' : 'Not set'),
        after: after.waistCm?.toString() ?? (_isChinese ? '将移除' : 'Removed'),
      ),
    if (before?.note != after.note)
      AgentMutationChange(
        path: _isChinese ? '备注' : 'note',
        before: before?.note ?? (_isChinese ? '未设置' : 'Not set'),
        after: after.note ?? (_isChinese ? '将移除' : 'Removed'),
      ),
  ];

  static Map<String, dynamic> _tool(
    String name,
    String description,
    Map<String, dynamic> parameters,
  ) => {
    'type': 'function',
    'function': {
      'name': name,
      'description': description,
      'parameters': parameters,
    },
  };

  static Map<String, dynamic> _object(
    Map<String, dynamic> properties, {
    required List<String> required,
  }) => {
    'type': 'object',
    'properties': properties,
    'required': required,
    'additionalProperties': false,
  };

  static Map<String, dynamic> _bodyMetricSchema({required bool includeId}) =>
      _object({
        if (includeId) 'metricId': _string(),
        'timestamp': {'type': 'string', 'format': 'date-time'},
        'weightKg': {'type': 'number', 'minimum': 20, 'maximum': 500},
        'bodyFatPercent': {'type': 'number', 'minimum': 1, 'maximum': 75},
        'waistCm': {'type': 'number', 'minimum': 30, 'maximum': 250},
        'note': {'type': 'string', 'maxLength': 500},
      }, required: includeId ? const ['metricId'] : const []);

  static Map<String, dynamic> _string() => const {'type': 'string'};

  static Map<String, dynamic> _integer(int min, int max) => {
    'type': 'integer',
    'minimum': min,
    'maximum': max,
  };

  AgentToolResult _error(String code, String message) => AgentToolResult(
    isError: true,
    payload: {
      'error': {'code': code, 'message': message},
    },
  );

  static Map<String, dynamic> _map(Object? value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return value.cast<String, dynamic>();
    throw const FormatException('Expected an object.');
  }

  static String _requiredString(Map<String, dynamic> args, String key) {
    final value = args[key] as String?;
    if (value == null || value.trim().isEmpty) {
      throw FormatException('$key is required.');
    }
    return value.trim();
  }

  static int _boundedInt(
    Object? value, {
    required int fallback,
    required int max,
  }) {
    return ((value as num?)?.toInt() ?? fallback).clamp(1, max).toInt();
  }

  static String _encodeCursor(int offset) =>
      base64Url.encode(utf8.encode('offset:$offset')).replaceAll('=', '');

  static int _decodeCursor(Object? value) {
    if (value == null || value == '') return 0;
    if (value is! String || value.length > 64) {
      throw const FormatException('Invalid pagination cursor.');
    }
    try {
      final decoded = utf8.decode(base64Url.decode(base64Url.normalize(value)));
      final match = RegExp(r'^offset:([0-9]{1,6})$').firstMatch(decoded);
      if (match == null) throw const FormatException();
      return int.parse(match.group(1)!);
    } catch (_) {
      throw const FormatException('Invalid pagination cursor.');
    }
  }

  static double? _nullableDouble(
    Map<String, dynamic> args,
    String key,
    double? fallback,
  ) {
    if (!args.containsKey(key)) return fallback;
    return (args[key] as num?)?.toDouble();
  }

  static int _completedSets(WorkoutLog log) => log.exercises
      .expand((exercise) => exercise.sets)
      .where((set) => set.isCompleted)
      .length;

  static double _volume(WorkoutLog log) => log.exercises
      .expand((exercise) => exercise.sets)
      .where(
        (set) => set.isCompleted && set.weight > 0 && set.completedReps > 0,
      )
      .fold(0, (sum, set) => sum + set.weight * set.completedReps);

  static String _safeError(Object error) {
    final text = error.toString().replaceFirst(
      RegExp(r'^(StateError|FormatException):\s*'),
      '',
    );
    return text.length <= 400 ? text : text.substring(0, 400);
  }
}

void validateAgentBodyMetric(BodyMetric metric) {
  void validate(double? value, double min, double max, String label) {
    if (value != null && (!value.isFinite || value < min || value > max)) {
      throw StateError('$label must be between $min and $max.');
    }
  }

  validate(metric.weightKg, 20, 500, 'Weight');
  validate(metric.bodyFatPercent, 1, 75, 'Body fat');
  validate(metric.waistCm, 30, 250, 'Waist');
  if (metric.weightKg == null &&
      metric.bodyFatPercent == null &&
      metric.waistCm == null &&
      (metric.note == null || metric.note!.trim().isEmpty)) {
    throw StateError('Enter at least one measurement or a note.');
  }
}
