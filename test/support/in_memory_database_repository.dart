import 'dart:convert';

import 'package:fittin_v2/src/data/database_repository.dart';
import 'package:fittin_v2/src/data/seeds/gzclp_seed.dart';
import 'package:fittin_v2/src/data/seeds/jacked_and_tan_seed.dart';
import 'package:fittin_v2/src/data/seeds/tsa_intermediate_seed.dart';
import 'package:fittin_v2/src/data/seeds/seed_utils.dart';
import 'package:fittin_v2/src/application/app_locale_provider.dart';
import 'package:fittin_v2/src/domain/models/workout_log.dart';
import 'package:fittin_v2/src/domain/one_rep_max.dart';
import 'package:fittin_v2/src/domain/models/training_plan.dart';
import 'package:fittin_v2/src/domain/models/training_max.dart';
import 'package:fittin_v2/src/domain/models/training_state.dart';

class InMemoryDatabaseRepository extends DatabaseRepository {
  final Map<String, StoredTemplateRecord> _templates = {};
  final Map<String, StoredTrainingInstance> _instances = {};
  final Map<String, String?> _activeInstanceIdsByOwner = {};
  AppLocale _appLocale = AppLocale.en;
  OneRepMaxFormula _analyticsFormula = OneRepMaxFormula.epley;
  final List<WorkoutLog> _workoutLogs = [];
  final Map<String, WorkoutSessionState> _sessionDrafts = {};
  String? _deviceId;
  double _glassOpacity = 0.3;
  String? _homeDisplayName;
  DateTime? _homeMilestonesLastSeenAt;

  String _ownerScope(String? ownerUserId) => ownerUserId ?? '__local__';

  @override
  Future<void> ensureDefaultProgramSeeded() async {
    await saveTemplate(await GzclpSeed.loadTemplate(), isBuiltIn: true);
    await saveTemplate(await JackedAndTanSeed.loadTemplate(), isBuiltIn: true);
    await saveTemplate(
      await TsaIntermediateSeed.loadTemplate(),
      isBuiltIn: true,
    );
  }

  @override
  Future<void> saveTemplate(
    PlanTemplate template, {
    bool isBuiltIn = false,
    String? sourceTemplateId,
    String? ownerUserId,
    String? syncStatus,
    String? deviceId,
  }) async {
    final existing = _templates[template.id];
    final now = DateTime.now();
    _templates[template.id] = StoredTemplateRecord(
      template: template,
      isBuiltIn: existing?.isBuiltIn ?? isBuiltIn,
      sourceTemplateId: existing?.sourceTemplateId ?? sourceTemplateId,
      createdAt: existing?.createdAt ?? now,
      lastModifiedAt: now,
      instanceCount: existing?.instanceCount ?? 0,
      ownerUserId: existing?.ownerUserId ?? ownerUserId,
      version: (existing?.version ?? 0) + 1,
      syncStatus:
          syncStatus ?? (ownerUserId == null ? 'local_only' : 'pending_upload'),
      lastModifiedByDeviceId: deviceId,
    );
  }

  @override
  Future<PlanTemplate?> fetchTemplate(String templateId) async {
    return _templates[templateId]?.template;
  }

  @override
  Future<StoredTemplateRecord?> fetchStoredTemplate(
    String templateId, {
    String? ownerUserId,
  }) async {
    final record = _templates[templateId];
    if (record == null) {
      return null;
    }
    if (!record.isBuiltIn && record.ownerUserId != ownerUserId) {
      return null;
    }

    return StoredTemplateRecord(
      template: record.template,
      isBuiltIn: record.isBuiltIn,
      sourceTemplateId: record.sourceTemplateId,
      createdAt: record.createdAt,
      lastModifiedAt: record.lastModifiedAt,
      instanceCount: _instances.values
          .where(
            (instance) =>
                instance.templateId == templateId &&
                instance.ownerUserId == ownerUserId,
          )
          .length,
      ownerUserId: record.ownerUserId,
      version: record.version,
      syncStatus: record.syncStatus,
      lastSyncedAt: record.lastSyncedAt,
      lastModifiedByDeviceId: record.lastModifiedByDeviceId,
    );
  }

  @override
  Future<List<StoredTemplateRecord>> fetchTemplates({
    String? ownerUserId,
  }) async {
    final records = await Future.wait(
      _templates.keys.map(
        (key) => fetchStoredTemplate(key, ownerUserId: ownerUserId),
      ),
    );
    final nonNullRecords = records.whereType<StoredTemplateRecord>().toList();
    nonNullRecords.sort((a, b) {
      if (a.isBuiltIn != b.isBuiltIn) {
        return a.isBuiltIn ? -1 : 1;
      }
      return a.template.name.compareTo(b.template.name);
    });
    return nonNullRecords;
  }

  @override
  Future<void> saveInstance(
    StoredTrainingInstance data, {
    String? syncStatus,
    String? deviceId,
  }) async {
    _instances[data.instanceId] = data;
  }

  @override
  Future<StoredTrainingInstance?> fetchInstance(String instanceId) async {
    return _instances[instanceId];
  }

  @override
  Future<String?> fetchActiveInstanceId() async {
    return fetchActiveInstanceIdForUser(null);
  }

  @override
  Future<void> saveActiveInstanceId(String instanceId) async {
    return saveActiveInstanceIdForUser(instanceId, null);
  }

  @override
  Future<String?> fetchActiveInstanceIdForUser(String? ownerUserId) async {
    return _activeInstanceIdsByOwner[_ownerScope(ownerUserId)];
  }

  @override
  Future<void> saveActiveInstanceIdForUser(
    String instanceId,
    String? ownerUserId,
  ) async {
    _activeInstanceIdsByOwner[_ownerScope(ownerUserId)] = instanceId;
  }

  @override
  Future<void> clearActiveInstanceId() async {
    return clearActiveInstanceIdForUser(null);
  }

  @override
  Future<void> clearActiveInstanceIdForUser(String? ownerUserId) async {
    _activeInstanceIdsByOwner.remove(_ownerScope(ownerUserId));
  }

  @override
  Future<AppLocale> fetchAppLocale() async => _appLocale;

  @override
  Future<void> saveAppLocale(AppLocale locale) async {
    _appLocale = locale;
  }

  @override
  Future<OneRepMaxFormula> fetchAnalyticsFormula() async => _analyticsFormula;

  @override
  Future<void> saveAnalyticsFormula(OneRepMaxFormula formula) async {
    _analyticsFormula = formula;
  }

  @override
  Future<double> fetchGlassOpacity() async => _glassOpacity;

  @override
  Future<void> saveGlassOpacity(double opacity) async {
    _glassOpacity = opacity;
  }

  @override
  Future<String?> fetchHomeDisplayName({String? ownerUserId}) async =>
      _homeDisplayName;

  @override
  Future<void> saveHomeDisplayName(String value, {String? ownerUserId}) async {
    final trimmed = value.trim();
    _homeDisplayName = trimmed.isEmpty ? null : trimmed;
  }

  @override
  Future<void> clearHomeDisplayName({String? ownerUserId}) async {
    _homeDisplayName = null;
  }

  @override
  Future<DateTime?> fetchHomeMilestonesLastSeenAt({
    String? ownerUserId,
  }) async => _homeMilestonesLastSeenAt;

  @override
  Future<void> saveHomeMilestonesLastSeenAt(
    DateTime value, {
    String? ownerUserId,
  }) async {
    _homeMilestonesLastSeenAt = value;
  }

  @override
  Future<WorkoutSessionState?> fetchActiveSessionDraft(
    String instanceId, {
    String? ownerUserId,
  }) async {
    return _sessionDrafts[instanceId];
  }

  @override
  Future<void> saveActiveSessionDraft(
    WorkoutSessionState draft, {
    String? ownerUserId,
  }) async {
    _sessionDrafts[draft.instanceId] = WorkoutSessionState.fromJson(
      jsonDecode(jsonEncode(draft.toJson())) as Map<String, dynamic>,
    );
  }

  @override
  Future<void> clearActiveSessionDraft(
    String instanceId, {
    String? ownerUserId,
  }) async {
    _sessionDrafts.remove(instanceId);
  }

  @override
  Future<String> fetchOrCreateDeviceId() async {
    _deviceId ??= 'test-device-id';
    return _deviceId!;
  }

  @override
  Future<void> claimLocalDataForUser(String ownerUserId) async {
    final updatedTemplates = <String, StoredTemplateRecord>{};
    for (final entry in _templates.entries) {
      final record = entry.value;
      updatedTemplates[entry.key] = StoredTemplateRecord(
        template: record.template,
        isBuiltIn: record.isBuiltIn,
        sourceTemplateId: record.sourceTemplateId,
        createdAt: record.createdAt,
        lastModifiedAt: record.lastModifiedAt,
        instanceCount: record.instanceCount,
        ownerUserId: record.isBuiltIn
            ? null
            : (record.ownerUserId ?? ownerUserId),
        deletedAt: record.deletedAt,
        version: record.version,
        syncStatus: record.isBuiltIn ? record.syncStatus : 'pending_upload',
        lastSyncedAt: record.lastSyncedAt,
        lastModifiedByDeviceId: record.lastModifiedByDeviceId,
      );
    }
    _templates
      ..clear()
      ..addAll(updatedTemplates);

    final updatedInstances = <String, StoredTrainingInstance>{};
    for (final entry in _instances.entries) {
      updatedInstances[entry.key] = entry.value.copyWith(
        ownerUserId: entry.value.ownerUserId ?? ownerUserId,
        syncStatus: 'pending_upload',
      );
    }
    _instances
      ..clear()
      ..addAll(updatedInstances);
  }

  @override
  Future<StoredTrainingInstance?> fetchActiveInstance() async {
    return fetchActiveInstanceForUser(null);
  }

  @override
  Future<StoredTrainingInstance?> fetchActiveInstanceForUser(
    String? ownerUserId,
  ) async {
    final activeInstanceId = await fetchActiveInstanceIdForUser(ownerUserId);
    if (activeInstanceId == null) {
      return null;
    }
    return _instances[activeInstanceId];
  }

  @override
  Future<StoredTrainingInstance?> fetchInstanceForTemplate(
    String templateId, {
    String? ownerUserId,
  }) async {
    final matches =
        _instances.values
            .where(
              (instance) =>
                  instance.templateId == templateId &&
                  instance.ownerUserId == ownerUserId,
            )
            .toList()
          ..sort((a, b) => a.instanceId.compareTo(b.instanceId));
    return matches.isEmpty ? null : matches.first;
  }

  @override
  Future<TrainingMaxSetupRequirement?> activationRequirementForTemplate(
    String templateId, {
    String? ownerUserId,
  }) async {
    await ensureDefaultProgramSeeded();
    final existing = await fetchInstanceForTemplate(
      templateId,
      ownerUserId: ownerUserId,
    );
    if (existing != null) {
      return null;
    }

    final template = (await fetchTemplate(templateId))!;
    if (template.requiredTrainingMaxKeys.isEmpty) {
      return null;
    }
    return TrainingMaxSetupRequirement(
      templateId: template.id,
      templateName: template.name,
      liftKeys: template.requiredTrainingMaxKeys,
    );
  }

  @override
  Future<StoredTrainingInstance> activateTemplate(
    String templateId, {
    TrainingMaxProfile trainingMaxProfile = TrainingMaxProfile.empty,
    String? ownerUserId,
  }) async {
    await ensureDefaultProgramSeeded();
    final existing = await fetchInstanceForTemplate(
      templateId,
      ownerUserId: ownerUserId,
    );
    if (existing != null) {
      await saveActiveInstanceIdForUser(existing.instanceId, ownerUserId);
      return existing;
    }

    final template = (await fetchTemplate(templateId))!;
    if (template.requiredTrainingMaxKeys.isNotEmpty &&
        trainingMaxProfile.isEmpty) {
      throw StateError(
        'Training max setup required before activating ${template.name}.',
      );
    }
    final instanceId = templateId == JackedAndTanSeed.templateId
        ? JackedAndTanSeed.instanceId
        : templateId == TsaIntermediateSeed.templateId
        ? TsaIntermediateSeed.instanceId
        : templateId == GzclpSeed.templateId
        ? GzclpSeed.instanceId
        : 'instance-$templateId';
    final instance = StoredTrainingInstance(
      instanceId: instanceId,
      templateId: templateId,
      currentWorkoutIndex: 0,
      ownerUserId: ownerUserId,
      trainingMaxProfile: trainingMaxProfile,
      engineState: buildInitialEngineState(template),
      states: buildStarterStatesForTemplate(
        template,
        trainingMaxProfile: trainingMaxProfile,
      ),
    );
    await saveInstance(instance);
    await saveActiveInstanceIdForUser(instance.instanceId, ownerUserId);
    return instance;
  }

  @override
  Future<void> logWorkout(
    WorkoutLog logRecord, {
    String? ownerUserId,
    String? syncStatus,
    String? deviceId,
  }) async {
    final resolvedLog = logRecord.logId.isEmpty
        ? logRecord.copyWith(
            logId:
                '${logRecord.instanceId}_${logRecord.workoutId}_${logRecord.completedAt.millisecondsSinceEpoch}',
          )
        : logRecord;
    _workoutLogs.add(resolvedLog);
  }

  @override
  Future<WorkoutLog?> fetchWorkoutLogById(
    String logId, {
    String? ownerUserId,
  }) async {
    for (final log in _workoutLogs) {
      if (log.logId == logId) {
        return log;
      }
    }
    return null;
  }

  @override
  Future<void> updateWorkoutLog(
    WorkoutLog logRecord, {
    String? ownerUserId,
    String? syncStatus,
    String? deviceId,
  }) async {
    final index = _workoutLogs.indexWhere(
      (log) => log.logId == logRecord.logId,
    );
    if (index == -1) {
      throw StateError('Workout log not found: ${logRecord.logId}');
    }
    _workoutLogs[index] = logRecord;
  }

  @override
  Future<List<WorkoutLog>> fetchWorkoutLogs(
    String instanceId, {
    String? ownerUserId,
  }) async {
    final logs =
        _workoutLogs.where((log) => log.instanceId == instanceId).toList()
          ..sort((a, b) => b.completedAt.compareTo(a.completedAt));
    return logs;
  }

  @override
  Future<List<WorkoutLog>> fetchAllWorkoutLogs({String? ownerUserId}) async {
    final logs = [..._workoutLogs]
      ..sort((a, b) => b.completedAt.compareTo(a.completedAt));
    return logs;
  }
}
