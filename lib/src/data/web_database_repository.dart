import 'dart:convert';

import 'package:fittin_v2/src/application/app_locale_provider.dart';
import 'package:fittin_v2/src/data/database_repository.dart';
import 'package:fittin_v2/src/data/seeds/gzclp_seed.dart';
import 'package:fittin_v2/src/data/seeds/jacked_and_tan_seed.dart';
import 'package:fittin_v2/src/data/seeds/seed_utils.dart';
import 'package:fittin_v2/src/data/seeds/tsa_intermediate_seed.dart';
import 'package:fittin_v2/src/data/sync/sync_models.dart';
import 'package:fittin_v2/src/data/web_local_store.dart';
import 'package:fittin_v2/src/data/web_storage_models.dart';
import 'package:fittin_v2/src/domain/models/training_max.dart';
import 'package:fittin_v2/src/domain/models/training_plan.dart';
import 'package:fittin_v2/src/domain/models/training_state.dart';
import 'package:fittin_v2/src/domain/models/workout_log.dart';
import 'package:fittin_v2/src/domain/one_rep_max.dart';
import 'package:uuid/uuid.dart';

class WebDatabaseRepository extends DatabaseRepository {
  WebDatabaseRepository(this.store);

  static const _activeStateKey = 'active-instance-selection';
  static const _localeStateKey = 'app-locale';
  static const _analyticsFormulaStateKey = 'analytics-formula';
  static const _glassOpacityKey = 'glass-opacity';
  static const _deviceIdStateKey = 'device-id';
  static const _homeDisplayNameKey = 'home-display-name';
  static const _homeMilestonesLastSeenAtKey = 'home-milestones-last-seen-at';
  static const _activeSessionDraftKey = 'active-session-draft';

  final WebLocalStore store;

  @override
  Future<void> ensureDefaultProgramSeeded() async {
    await _syncBuiltInTemplate(
      templateId: GzclpSeed.templateId,
      loadTemplate: GzclpSeed.loadTemplate,
    );
    await _syncBuiltInTemplate(
      templateId: JackedAndTanSeed.templateId,
      loadTemplate: JackedAndTanSeed.loadTemplate,
    );
    await _syncBuiltInTemplate(
      templateId: TsaIntermediateSeed.templateId,
      loadTemplate: TsaIntermediateSeed.loadTemplate,
    );
    final activeInstanceId = await fetchActiveInstanceId();
    final activeInstance = activeInstanceId == null
        ? null
        : await fetchInstance(activeInstanceId);
    if (activeInstanceId != null && activeInstance == null) {
      await clearActiveInstanceId();
    }
  }

  Future<void> _syncBuiltInTemplate({
    required String templateId,
    required Future<PlanTemplate> Function() loadTemplate,
  }) async {
    final template = await loadTemplate();
    final existing = await store.getRecord(WebStoreNames.templates, templateId);
    if (existing != null &&
        existing['isBuiltIn'] == true &&
        existing['rawJsonPayload'] == jsonEncode(template.toJson())) {
      return;
    }
    await saveTemplate(template, isBuiltIn: true);
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
    final existing = await store.getRecord(
      WebStoreNames.templates,
      template.id,
    );
    final now = DateTime.now();
    final resolvedOwnerUserId =
        existing?['ownerUserId'] as String? ?? ownerUserId;
    final doc = <String, dynamic>{
      'templateId': template.id,
      'name': template.name,
      'description': template.description,
      'isBuiltIn': existing?['isBuiltIn'] as bool? ?? isBuiltIn,
      'sourceTemplateId':
          existing?['sourceTemplateId'] as String? ?? sourceTemplateId,
      'ownerUserId': resolvedOwnerUserId,
      'createdAt':
          existing?['createdAt'] as String? ?? serializeStoredDateTime(now),
      'lastModifiedAt': serializeStoredDateTime(now),
      'deletedAt': null,
      'lastSyncedAt': existing?['lastSyncedAt'],
      'version': (existing?['version'] as int? ?? 0) + 1,
      'syncStatusKey': syncStatus ?? _defaultSyncStatus(resolvedOwnerUserId),
      'lastModifiedByDeviceId': deviceId ?? existing?['lastModifiedByDeviceId'],
      'rawJsonPayload': jsonEncode(template.toJson()),
    };
    await store.putRecord(WebStoreNames.templates, template.id, doc);
    await _enqueueSync(
      entityType: SyncEntityTypes.template,
      entityId: template.id,
      ownerUserId: resolvedOwnerUserId,
      operationType: SyncOperationTypes.upsert,
      syncStatus: doc['syncStatusKey'] as String,
    );
  }

  @override
  Future<PlanTemplate?> fetchTemplate(String templateId) async {
    final doc = await store.getRecord(WebStoreNames.templates, templateId);
    if (doc == null || parseStoredDateTime(doc['deletedAt']) != null) {
      return null;
    }
    return PlanTemplate.fromJson(
      jsonDecode(doc['rawJsonPayload'] as String) as Map<String, dynamic>,
    );
  }

  @override
  Future<StoredTemplateRecord?> fetchStoredTemplate(
    String templateId, {
    String? ownerUserId,
  }) async {
    final doc = await store.getRecord(WebStoreNames.templates, templateId);
    if (doc == null) {
      return null;
    }
    if (!_templateVisibleToUser(doc, ownerUserId)) {
      return null;
    }
    final instanceCount = await _instanceCountForTemplate(
      templateId,
      ownerUserId: ownerUserId,
    );
    return storedTemplateRecordFromDoc(doc, instanceCount: instanceCount);
  }

  @override
  Future<List<StoredTemplateRecord>> fetchTemplates({
    String? ownerUserId,
  }) async {
    final templateDocs = await store.getAllRecords(WebStoreNames.templates);
    final instanceDocs = await store.getAllRecords(WebStoreNames.instances);
    final counts = <String, int>{};
    for (final doc in instanceDocs) {
      if (parseStoredDateTime(doc['deletedAt']) != null) {
        continue;
      }
      if (!_ownerMatches(doc['ownerUserId'] as String?, ownerUserId)) {
        continue;
      }
      counts.update(
        doc['templateId'] as String,
        (value) => value + 1,
        ifAbsent: () => 1,
      );
    }

    final records = templateDocs
        .where((doc) => _templateVisibleToUser(doc, ownerUserId))
        .map(
          (doc) => storedTemplateRecordFromDoc(
            doc,
            instanceCount: counts[doc['templateId'] as String] ?? 0,
          ),
        )
        .toList();

    records.sort((a, b) {
      if (a.isBuiltIn != b.isBuiltIn) {
        return a.isBuiltIn ? -1 : 1;
      }
      return a.template.name.toLowerCase().compareTo(
        b.template.name.toLowerCase(),
      );
    });
    return records;
  }

  @override
  Future<String?> fetchActiveInstanceId() async {
    return fetchActiveInstanceIdForUser(null);
  }

  @override
  Future<String?> fetchActiveInstanceIdForUser(String? ownerUserId) async {
    final doc = await store.getRecord(
      WebStoreNames.appState,
      _scopedStateKey(_activeStateKey, ownerUserId),
    );
    return doc?['activeInstanceId'] as String?;
  }

  @override
  Future<void> saveActiveInstanceId(String instanceId) async {
    return saveActiveInstanceIdForUser(instanceId, null);
  }

  @override
  Future<void> saveActiveInstanceIdForUser(
    String instanceId,
    String? ownerUserId,
  ) async {
    final key = _scopedStateKey(_activeStateKey, ownerUserId);
    final doc = <String, dynamic>{
      'stateKey': key,
      'activeInstanceId': instanceId,
      'updatedAt': serializeStoredDateTime(DateTime.now()),
    };
    await store.putRecord(WebStoreNames.appState, key, doc);
  }

  @override
  Future<void> clearActiveInstanceId() async {
    return clearActiveInstanceIdForUser(null);
  }

  @override
  Future<void> clearActiveInstanceIdForUser(String? ownerUserId) async {
    final key = _scopedStateKey(_activeStateKey, ownerUserId);
    final doc = <String, dynamic>{
      'stateKey': key,
      'updatedAt': serializeStoredDateTime(DateTime.now()),
    };
    await store.putRecord(WebStoreNames.appState, key, doc);
  }

  @override
  Future<AppLocale> fetchAppLocale() async {
    final doc = await store.getRecord(WebStoreNames.appState, _localeStateKey);
    return AppLocaleX.fromCode(doc?['localeCode'] as String?);
  }

  @override
  Future<void> saveAppLocale(AppLocale locale) async {
    await store.putRecord(WebStoreNames.appState, _localeStateKey, {
      'stateKey': _localeStateKey,
      'localeCode': locale.code,
      'updatedAt': serializeStoredDateTime(DateTime.now()),
    });
  }

  @override
  Future<OneRepMaxFormula> fetchAnalyticsFormula() async {
    final doc = await store.getRecord(
      WebStoreNames.appState,
      _analyticsFormulaStateKey,
    );
    return OneRepMaxFormulaX.fromKey(doc?['analyticsFormulaKey'] as String?);
  }

  @override
  Future<void> saveAnalyticsFormula(OneRepMaxFormula formula) async {
    await store.putRecord(WebStoreNames.appState, _analyticsFormulaStateKey, {
      'stateKey': _analyticsFormulaStateKey,
      'analyticsFormulaKey': formula.key,
      'updatedAt': serializeStoredDateTime(DateTime.now()),
    });
  }

  @override
  Future<double> fetchGlassOpacity() async {
    final doc = await store.getRecord(WebStoreNames.appState, _glassOpacityKey);
    return (doc?['glassOpacity'] as num?)?.toDouble() ?? 0.3;
  }

  @override
  Future<void> saveGlassOpacity(double opacity) async {
    await store.putRecord(WebStoreNames.appState, _glassOpacityKey, {
      'stateKey': _glassOpacityKey,
      'glassOpacity': opacity,
      'updatedAt': serializeStoredDateTime(DateTime.now()),
    });
  }

  @override
  Future<String?> fetchHomeDisplayName({String? ownerUserId}) async {
    return _fetchStringState(_scopedStateKey(_homeDisplayNameKey, ownerUserId));
  }

  @override
  Future<void> saveHomeDisplayName(String value, {String? ownerUserId}) async {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      await clearHomeDisplayName(ownerUserId: ownerUserId);
      return;
    }
    await _saveStringState(
      _scopedStateKey(_homeDisplayNameKey, ownerUserId),
      trimmed,
    );
  }

  @override
  Future<void> clearHomeDisplayName({String? ownerUserId}) async {
    await store.deleteRecord(
      WebStoreNames.appState,
      _scopedStateKey(_homeDisplayNameKey, ownerUserId),
    );
  }

  @override
  Future<DateTime?> fetchHomeMilestonesLastSeenAt({String? ownerUserId}) async {
    final value = await _fetchStringState(
      _scopedStateKey(_homeMilestonesLastSeenAtKey, ownerUserId),
    );
    return value == null ? null : DateTime.tryParse(value)?.toLocal();
  }

  @override
  Future<void> saveHomeMilestonesLastSeenAt(
    DateTime value, {
    String? ownerUserId,
  }) async {
    await _saveStringState(
      _scopedStateKey(_homeMilestonesLastSeenAtKey, ownerUserId),
      value.toUtc().toIso8601String(),
    );
  }

  @override
  Future<WorkoutSessionState?> fetchActiveSessionDraft(
    String instanceId, {
    String? ownerUserId,
  }) async {
    final key = _scopedStateKey(
      '$_activeSessionDraftKey:$instanceId',
      ownerUserId,
    );
    final raw = await _fetchStringState(key);
    if (raw == null) {
      return null;
    }
    return WorkoutSessionState.fromJson(
      jsonDecode(raw) as Map<String, dynamic>,
    );
  }

  @override
  Future<void> saveActiveSessionDraft(
    WorkoutSessionState draft, {
    String? ownerUserId,
  }) async {
    await _saveStringState(
      _scopedStateKey(
        '$_activeSessionDraftKey:${draft.instanceId}',
        ownerUserId,
      ),
      jsonEncode(draft.toJson()),
    );
  }

  @override
  Future<void> clearActiveSessionDraft(
    String instanceId, {
    String? ownerUserId,
  }) async {
    await _clearStateByKey(
      _scopedStateKey('$_activeSessionDraftKey:$instanceId', ownerUserId),
    );
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
    return fetchInstance(activeInstanceId);
  }

  @override
  Future<StoredTrainingInstance?> fetchInstanceForTemplate(
    String templateId, {
    String? ownerUserId,
  }) async {
    final docs = await store.getAllRecords(WebStoreNames.instances);
    final filtered = docs
        .where(
          (doc) =>
              parseStoredDateTime(doc['deletedAt']) == null &&
              doc['templateId'] == templateId &&
              _ownerMatches(doc['ownerUserId'] as String?, ownerUserId),
        )
        .toList();
    if (filtered.isEmpty) {
      return null;
    }
    filtered.sort(
      (a, b) => (parseStoredDateTime(a['createdAt']) ?? DateTime.now())
          .compareTo(parseStoredDateTime(b['createdAt']) ?? DateTime.now()),
    );
    return storedTrainingInstanceFromDoc(filtered.first);
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

    final instance = StoredTrainingInstance(
      instanceId: _defaultInstanceIdForTemplate(templateId),
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
  Future<void> saveInstance(
    StoredTrainingInstance data, {
    String? syncStatus,
    String? deviceId,
  }) async {
    final existing = await store.getRecord(
      WebStoreNames.instances,
      data.instanceId,
    );
    final resolvedOwnerUserId =
        data.ownerUserId ?? existing?['ownerUserId'] as String?;
    final resolvedSyncStatus =
        syncStatus ??
        (data.syncStatus.isEmpty
            ? _defaultSyncStatus(resolvedOwnerUserId)
            : data.syncStatus);
    final doc = <String, dynamic>{
      'instanceId': data.instanceId,
      'templateId': data.templateId,
      'currentStatesJson': data.states.map((state) => state.toJson()).toList(),
      'trainingMaxProfileJson': data.trainingMaxProfile.toJson(),
      'engineStateJson': data.engineState,
      'currentWorkoutIndex': data.currentWorkoutIndex,
      'ownerUserId': resolvedOwnerUserId,
      'createdAt':
          existing?['createdAt'] as String? ??
          serializeStoredDateTime(DateTime.now()),
      'lastModifiedAt': serializeStoredDateTime(DateTime.now()),
      'deletedAt': serializeStoredDateTime(data.deletedAt),
      'lastSyncedAt': serializeStoredDateTime(data.lastSyncedAt),
      'version':
          (existing?['version'] as int? ?? data.version) +
          (existing == null ? 0 : 1),
      'syncStatusKey': resolvedSyncStatus,
      'lastModifiedByDeviceId':
          deviceId ??
          data.lastModifiedByDeviceId ??
          existing?['lastModifiedByDeviceId'],
    };
    await store.putRecord(WebStoreNames.instances, data.instanceId, doc);
    await _enqueueSync(
      entityType: SyncEntityTypes.instance,
      entityId: data.instanceId,
      ownerUserId: resolvedOwnerUserId,
      operationType: SyncOperationTypes.upsert,
      syncStatus: resolvedSyncStatus,
    );
  }

  @override
  Future<StoredTrainingInstance?> fetchInstance(String instanceId) async {
    final doc = await store.getRecord(WebStoreNames.instances, instanceId);
    if (doc == null) {
      return null;
    }
    return storedTrainingInstanceFromDoc(doc);
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
    final logId = resolvedLog.logId;
    final existing = await store.getRecord(WebStoreNames.workoutLogs, logId);
    final resolvedOwnerUserId =
        ownerUserId ?? existing?['ownerUserId'] as String?;
    final resolvedSyncStatus =
        syncStatus ?? _defaultSyncStatus(resolvedOwnerUserId);
    final doc = <String, dynamic>{
      'logId': logId,
      'instanceId': resolvedLog.instanceId,
      'workoutId': resolvedLog.workoutId,
      'workoutName': resolvedLog.workoutName,
      'ownerUserId': resolvedOwnerUserId,
      'rawJsonPayload': jsonEncode(resolvedLog.toJson()),
      'completedAt': serializeStoredDateTime(resolvedLog.completedAt),
      'deletedAt': null,
      'lastSyncedAt': existing?['lastSyncedAt'],
      'version': (existing?['version'] as int? ?? 0) + 1,
      'syncStatusKey': resolvedSyncStatus,
      'lastModifiedByDeviceId': deviceId ?? existing?['lastModifiedByDeviceId'],
    };
    await store.putRecord(WebStoreNames.workoutLogs, logId, doc);
    await _enqueueSync(
      entityType: SyncEntityTypes.workoutLog,
      entityId: logId,
      ownerUserId: resolvedOwnerUserId,
      operationType: SyncOperationTypes.upsert,
      syncStatus: resolvedSyncStatus,
    );
  }

  @override
  Future<WorkoutLog?> fetchWorkoutLogById(
    String logId, {
    String? ownerUserId,
  }) async {
    final doc = await store.getRecord(WebStoreNames.workoutLogs, logId);
    if (doc == null ||
        parseStoredDateTime(doc['deletedAt']) != null ||
        !_ownerMatches(doc['ownerUserId'] as String?, ownerUserId)) {
      return null;
    }
    return workoutLogFromDoc(doc);
  }

  @override
  Future<void> updateWorkoutLog(
    WorkoutLog logRecord, {
    String? ownerUserId,
    String? syncStatus,
    String? deviceId,
  }) async {
    final existing = await store.getRecord(
      WebStoreNames.workoutLogs,
      logRecord.logId,
    );
    if (existing == null) {
      throw StateError('Workout log not found: ${logRecord.logId}');
    }
    final resolvedOwnerUserId =
        ownerUserId ?? existing['ownerUserId'] as String?;
    final resolvedSyncStatus =
        syncStatus ?? _defaultSyncStatus(resolvedOwnerUserId);
    final doc = <String, dynamic>{
      'logId': logRecord.logId,
      'instanceId': logRecord.instanceId,
      'workoutId': logRecord.workoutId,
      'workoutName': logRecord.workoutName,
      'ownerUserId': resolvedOwnerUserId,
      'rawJsonPayload': jsonEncode(logRecord.toJson()),
      'completedAt': serializeStoredDateTime(logRecord.completedAt),
      'deletedAt': existing['deletedAt'],
      'lastSyncedAt': existing['lastSyncedAt'],
      'version': (existing['version'] as int? ?? 0) + 1,
      'syncStatusKey': resolvedSyncStatus,
      'lastModifiedByDeviceId': deviceId ?? existing['lastModifiedByDeviceId'],
    };
    await store.putRecord(WebStoreNames.workoutLogs, logRecord.logId, doc);
    await _enqueueSync(
      entityType: SyncEntityTypes.workoutLog,
      entityId: logRecord.logId,
      ownerUserId: resolvedOwnerUserId,
      operationType: SyncOperationTypes.upsert,
      syncStatus: resolvedSyncStatus,
    );
  }

  @override
  Future<List<WorkoutLog>> fetchWorkoutLogs(
    String instanceId, {
    String? ownerUserId,
  }) async {
    final docs = await store.getAllRecords(WebStoreNames.workoutLogs);
    final logs = docs
        .where(
          (doc) =>
              doc['instanceId'] == instanceId &&
              parseStoredDateTime(doc['deletedAt']) == null &&
              _ownerMatches(doc['ownerUserId'] as String?, ownerUserId),
        )
        .map(workoutLogFromDoc)
        .toList();
    logs.sort((a, b) => b.completedAt.compareTo(a.completedAt));
    return logs;
  }

  @override
  Future<List<WorkoutLog>> fetchAllWorkoutLogs({String? ownerUserId}) async {
    final docs = await store.getAllRecords(WebStoreNames.workoutLogs);
    final logs = docs
        .where(
          (doc) =>
              parseStoredDateTime(doc['deletedAt']) == null &&
              _ownerMatches(doc['ownerUserId'] as String?, ownerUserId),
        )
        .map(workoutLogFromDoc)
        .toList();
    logs.sort((a, b) => b.completedAt.compareTo(a.completedAt));
    return logs;
  }

  @override
  Future<String> fetchOrCreateDeviceId() async {
    final existing = await _fetchStringState(_deviceIdStateKey);
    if (existing != null) {
      return existing;
    }
    final deviceId = const Uuid().v4();
    await _saveStringState(_deviceIdStateKey, deviceId);
    return deviceId;
  }

  @override
  Future<void> claimLocalDataForUser(String ownerUserId) async {
    final now = serializeStoredDateTime(DateTime.now());
    final templateDocs = await store.getAllRecords(WebStoreNames.templates);
    for (final doc in templateDocs) {
      if (doc['isBuiltIn'] == true || doc['ownerUserId'] != null) {
        continue;
      }
      doc['ownerUserId'] = ownerUserId;
      doc['syncStatusKey'] = SyncStatusKeys.pendingUpload;
      doc['lastModifiedAt'] = now;
      await store.putRecord(
        WebStoreNames.templates,
        doc['templateId'] as String,
        doc,
      );
      await _enqueueSync(
        entityType: SyncEntityTypes.template,
        entityId: doc['templateId'] as String,
        ownerUserId: ownerUserId,
        operationType: SyncOperationTypes.upsert,
        syncStatus: SyncStatusKeys.pendingUpload,
      );
    }

    final instanceDocs = await store.getAllRecords(WebStoreNames.instances);
    for (final doc in instanceDocs) {
      if (doc['ownerUserId'] != null) {
        continue;
      }
      doc['ownerUserId'] = ownerUserId;
      doc['syncStatusKey'] = SyncStatusKeys.pendingUpload;
      doc['lastModifiedAt'] = now;
      await store.putRecord(
        WebStoreNames.instances,
        doc['instanceId'] as String,
        doc,
      );
      await _enqueueSync(
        entityType: SyncEntityTypes.instance,
        entityId: doc['instanceId'] as String,
        ownerUserId: ownerUserId,
        operationType: SyncOperationTypes.upsert,
        syncStatus: SyncStatusKeys.pendingUpload,
      );
    }

    final logDocs = await store.getAllRecords(WebStoreNames.workoutLogs);
    for (final doc in logDocs) {
      if (doc['ownerUserId'] != null) {
        continue;
      }
      doc['ownerUserId'] = ownerUserId;
      doc['syncStatusKey'] = SyncStatusKeys.pendingUpload;
      await store.putRecord(
        WebStoreNames.workoutLogs,
        doc['logId'] as String,
        doc,
      );
      await _enqueueSync(
        entityType: SyncEntityTypes.workoutLog,
        entityId: doc['logId'] as String,
        ownerUserId: ownerUserId,
        operationType: SyncOperationTypes.upsert,
        syncStatus: SyncStatusKeys.pendingUpload,
      );
    }
  }

  bool _templateVisibleToUser(Map<String, dynamic> doc, String? ownerUserId) {
    if (parseStoredDateTime(doc['deletedAt']) != null) {
      return false;
    }
    if (doc['isBuiltIn'] == true) {
      return true;
    }
    return _ownerMatches(doc['ownerUserId'] as String?, ownerUserId);
  }

  bool _ownerMatches(String? recordOwnerUserId, String? ownerUserId) {
    return recordOwnerUserId == ownerUserId;
  }

  String _defaultSyncStatus(String? ownerUserId) {
    return ownerUserId == null
        ? SyncStatusKeys.localOnly
        : SyncStatusKeys.pendingUpload;
  }

  String _scopedStateKey(String baseKey, String? ownerUserId) {
    if (ownerUserId == null || ownerUserId.isEmpty) {
      return baseKey;
    }
    return '$baseKey:$ownerUserId';
  }

  Future<String?> _fetchStringState(String stateKey) async {
    final doc = await store.getRecord(WebStoreNames.appState, stateKey);
    return doc?['stringValue'] as String?;
  }

  Future<void> _saveStringState(String stateKey, String value) async {
    await store.putRecord(WebStoreNames.appState, stateKey, {
      'stateKey': stateKey,
      'stringValue': value,
      'updatedAt': serializeStoredDateTime(DateTime.now()),
    });
  }

  Future<void> _clearStateByKey(String stateKey) async {
    await store.deleteRecord(WebStoreNames.appState, stateKey);
  }

  Future<int> _instanceCountForTemplate(
    String templateId, {
    String? ownerUserId,
  }) async {
    final docs = await store.getAllRecords(WebStoreNames.instances);
    return docs
        .where(
          (doc) =>
              parseStoredDateTime(doc['deletedAt']) == null &&
              doc['templateId'] == templateId &&
              _ownerMatches(doc['ownerUserId'] as String?, ownerUserId),
        )
        .length;
  }

  Future<void> _enqueueSync({
    required String entityType,
    required String entityId,
    required String operationType,
    required String? ownerUserId,
    required String syncStatus,
  }) async {
    if (syncStatus == SyncStatusKeys.synced) {
      return;
    }
    final queueKey = '$entityType:$entityId';
    final existing = await store.getRecord(WebStoreNames.syncQueue, queueKey);
    final queueDoc = <String, dynamic>{
      'queueKey': queueKey,
      'ownerUserId': ownerUserId,
      'entityType': entityType,
      'entityId': entityId,
      'operationType': operationType,
      'createdAt':
          existing?['createdAt'] as String? ??
          serializeStoredDateTime(DateTime.now()),
      'updatedAt': serializeStoredDateTime(DateTime.now()),
    };
    await store.putRecord(WebStoreNames.syncQueue, queueKey, queueDoc);
  }

  String _defaultInstanceIdForTemplate(String templateId) {
    if (templateId == GzclpSeed.templateId) {
      return GzclpSeed.instanceId;
    }
    if (templateId == JackedAndTanSeed.templateId) {
      return JackedAndTanSeed.instanceId;
    }
    if (templateId == TsaIntermediateSeed.templateId) {
      return TsaIntermediateSeed.instanceId;
    }
    return 'instance-$templateId';
  }
}
