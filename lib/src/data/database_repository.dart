import 'dart:convert';

import 'package:isar/isar.dart';
import 'package:fittin_v2/src/data/models/app_state_collection.dart';
import 'package:fittin_v2/src/data/models/instance_collection.dart';
import 'package:fittin_v2/src/data/models/sync_queue_collection.dart';
import 'package:fittin_v2/src/data/models/template_collection.dart';
import 'package:fittin_v2/src/data/models/workout_log_collection.dart';
import 'package:fittin_v2/src/data/seeds/gzclp_seed.dart';
import 'package:fittin_v2/src/data/seeds/jacked_and_tan_seed.dart';
import 'package:fittin_v2/src/data/sync/sync_models.dart';
import 'package:fittin_v2/src/data/seeds/seed_utils.dart';
import 'package:fittin_v2/src/application/app_locale_provider.dart';
import 'package:fittin_v2/src/domain/one_rep_max.dart';
import 'package:fittin_v2/src/domain/models/training_plan.dart';
import 'package:fittin_v2/src/domain/models/training_max.dart';
import 'package:fittin_v2/src/domain/models/training_state.dart';
import 'package:fittin_v2/src/domain/models/workout_log.dart';
import 'package:uuid/uuid.dart';

class DatabaseRepository {
  static const _activeStateKey = 'active-instance-selection';
  static const _localeStateKey = 'app-locale';
  static const _analyticsFormulaStateKey = 'analytics-formula';
  static const _glassOpacityKey = 'glass-opacity';
  static const _deviceIdStateKey = 'device-id';
  final Isar? _isar;

  Isar? get isar => _isar;

  DatabaseRepository([this._isar]);

  Isar get _database {
    final isar = _isar;
    if (isar == null) {
      throw StateError('This repository instance is not backed by Isar.');
    }
    return isar;
  }

  Future<void> ensureDefaultProgramSeeded() async {
    await _syncBuiltInTemplate(
      templateId: GzclpSeed.templateId,
      loadTemplate: GzclpSeed.loadTemplate,
    );
    await _syncBuiltInTemplate(
      templateId: JackedAndTanSeed.templateId,
      loadTemplate: JackedAndTanSeed.loadTemplate,
    );
    await _purgeLegacyBuiltInInstanceIfNeeded(GzclpSeed.instanceId);
    await _purgeLegacyBuiltInInstanceIfNeeded(JackedAndTanSeed.instanceId);

    final activeInstanceId = await fetchActiveInstanceId();
    final activeInstance = activeInstanceId == null
        ? null
        : await fetchInstance(activeInstanceId);
    if (activeInstanceId != null && activeInstance == null) {
      await clearActiveInstanceId();
    }
  }

  // ---------- Templates ---------- //

  Future<void> saveTemplate(
    PlanTemplate template, {
    bool isBuiltIn = false,
    String? sourceTemplateId,
    String? ownerUserId,
    String? syncStatus,
    String? deviceId,
  }) async {
    final Map<String, dynamic> templateJson = template.toJson();
    final String serialized = jsonEncode(templateJson);
    final existing = await _database.templateCollections.getByTemplateId(
      template.id,
    );

    final collection = TemplateCollection()
      ..templateId = template.id
      ..name = template.name
      ..description = template.description
      ..isBuiltIn = existing?.isBuiltIn ?? isBuiltIn
      ..sourceTemplateId = existing?.sourceTemplateId ?? sourceTemplateId
      ..ownerUserId = existing?.ownerUserId ?? ownerUserId
      ..createdAt = existing?.createdAt ?? DateTime.now()
      ..lastModifiedAt = DateTime.now()
      ..deletedAt = null
      ..lastSyncedAt = existing?.lastSyncedAt
      ..version = (existing?.version ?? 0) + 1
      ..syncStatusKey =
          syncStatus ?? _defaultSyncStatus(ownerUserId ?? existing?.ownerUserId)
      ..lastModifiedByDeviceId = deviceId ?? existing?.lastModifiedByDeviceId
      ..rawJsonPayload = serialized;

    await _database.writeTxn(() async {
      await _database.templateCollections.putByTemplateId(collection);
    });
    await _enqueueSync(
      entityType: SyncEntityTypes.template,
      entityId: template.id,
      ownerUserId: collection.ownerUserId,
      operationType: SyncOperationTypes.upsert,
      syncStatus: collection.syncStatusKey,
    );
  }

  Future<PlanTemplate?> fetchTemplate(String templateId) async {
    final collection = await _database.templateCollections.getByTemplateId(
      templateId,
    );
    if (collection == null) return null;
    return PlanTemplate.fromJson(jsonDecode(collection.rawJsonPayload));
  }

  Future<StoredTemplateRecord?> fetchStoredTemplate(
    String templateId, {
    String? ownerUserId,
  }) async {
    final collection = await _database.templateCollections.getByTemplateId(
      templateId,
    );
    if (collection == null) {
      return null;
    }
    if (!_templateVisibleToUser(collection, ownerUserId)) {
      return null;
    }
    final instanceCount = await _instanceCountForTemplate(
      templateId,
      ownerUserId: ownerUserId,
    );
    return _toStoredTemplateRecord(collection, instanceCount);
  }

  Future<List<StoredTemplateRecord>> fetchTemplates({
    String? ownerUserId,
  }) async {
    final collections = await _database.templateCollections.where().findAll();
    final instances = await _database.instanceCollections.where().findAll();
    final counts = <String, int>{};
    for (final instance in instances) {
      if (!_ownerMatches(instance.ownerUserId, ownerUserId)) {
        continue;
      }
      counts.update(
        instance.templateId,
        (value) => value + 1,
        ifAbsent: () => 1,
      );
    }

    final records = collections
        .where((collection) => _templateVisibleToUser(collection, ownerUserId))
        .map(
          (collection) => _toStoredTemplateRecord(
            collection,
            counts[collection.templateId] ?? 0,
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

  Future<PlanTemplate?> fetchTemplateForInstance(String instanceId) async {
    final instance = await fetchInstance(instanceId);
    if (instance == null) {
      return null;
    }
    return fetchTemplate(instance.templateId);
  }

  Future<PlanTemplate> importSharedTemplate(PlanTemplate template) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final importedTemplate = template.copyWith(
      id: '${_slugifyTemplateId(template.id)}-imported-$timestamp',
      name: '${template.name} (Imported)',
      description: '${template.description}\nImported via QR sharing.',
    );
    await saveTemplate(importedTemplate, sourceTemplateId: template.id);
    return importedTemplate;
  }

  Future<StoredTemplateRecord> saveEditedTemplate({
    required PlanTemplate draft,
    String? originalTemplateId,
  }) async {
    final existing = originalTemplateId == null
        ? null
        : await fetchStoredTemplate(originalTemplateId);
    final shouldFork =
        existing == null || existing.isBuiltIn || existing.instanceCount > 0;

    final templateToSave = shouldFork
        ? draft.copyWith(
            id: _generatedTemplateId(
              draft.name,
              fallbackSourceId: existing?.template.id ?? draft.id,
            ),
          )
        : draft.copyWith(id: existing.template.id);

    final sourceTemplateId =
        existing?.sourceTemplateId ?? existing?.template.id;

    await saveTemplate(
      templateToSave,
      isBuiltIn: false,
      sourceTemplateId: sourceTemplateId,
    );

    return (await fetchStoredTemplate(templateToSave.id))!;
  }

  Future<String?> fetchActiveInstanceId() async {
    return fetchActiveInstanceIdForUser(null);
  }

  Future<String?> fetchActiveInstanceIdForUser(String? ownerUserId) async {
    final state = await _database.appStateCollections.getByStateKey(
      _scopedStateKey(_activeStateKey, ownerUserId),
    );
    return state?.activeInstanceId;
  }

  Future<void> saveActiveInstanceId(String instanceId) async {
    return saveActiveInstanceIdForUser(instanceId, null);
  }

  Future<void> saveActiveInstanceIdForUser(
    String instanceId,
    String? ownerUserId,
  ) async {
    final existing = await _database.appStateCollections.getByStateKey(
      _scopedStateKey(_activeStateKey, ownerUserId),
    );
    final state = AppStateCollection()
      ..stateKey = _scopedStateKey(_activeStateKey, ownerUserId)
      ..activeInstanceId = instanceId
      ..updatedAt = DateTime.now();
    if (existing != null) {
      state.id = existing.id;
    }

    await _database.writeTxn(() async {
      await _database.appStateCollections.putByStateKey(state);
    });
  }

  Future<void> clearActiveInstanceId() async {
    return clearActiveInstanceIdForUser(null);
  }

  Future<void> clearActiveInstanceIdForUser(String? ownerUserId) async {
    final existing = await _database.appStateCollections.getByStateKey(
      _scopedStateKey(_activeStateKey, ownerUserId),
    );
    if (existing == null) {
      return;
    }

    final state = AppStateCollection()
      ..id = existing.id
      ..stateKey = _scopedStateKey(_activeStateKey, ownerUserId)
      ..updatedAt = DateTime.now();

    await _database.writeTxn(() async {
      await _database.appStateCollections.putByStateKey(state);
    });
  }

  Future<AppLocale> fetchAppLocale() async {
    final state = await _database.appStateCollections.getByStateKey(
      _localeStateKey,
    );
    return AppLocaleX.fromCode(state?.localeCode);
  }

  Future<void> saveAppLocale(AppLocale locale) async {
    final existing = await _database.appStateCollections.getByStateKey(
      _localeStateKey,
    );
    final state = AppStateCollection()
      ..stateKey = _localeStateKey
      ..localeCode = locale.code
      ..updatedAt = DateTime.now();
    if (existing != null) {
      state.id = existing.id;
      state.activeInstanceId = existing.activeInstanceId;
    }

    await _database.writeTxn(() async {
      await _database.appStateCollections.putByStateKey(state);
    });
  }

  Future<OneRepMaxFormula> fetchAnalyticsFormula() async {
    final state = await _database.appStateCollections.getByStateKey(
      _analyticsFormulaStateKey,
    );
    return OneRepMaxFormulaX.fromKey(state?.analyticsFormulaKey);
  }

  Future<void> saveAnalyticsFormula(OneRepMaxFormula formula) async {
    final existing = await _database.appStateCollections.getByStateKey(
      _analyticsFormulaStateKey,
    );
    final state = existing ?? AppStateCollection();
    state.stateKey = _analyticsFormulaStateKey;
    state.analyticsFormulaKey = formula.key;
    state.updatedAt = DateTime.now();

    await _database.writeTxn(() async {
      await _database.appStateCollections.putByStateKey(state);
    });
  }

  Future<double> fetchGlassOpacity() async {
    final state = await _database.appStateCollections.getByStateKey(
      _glassOpacityKey,
    );
    return state?.glassOpacity ?? 0.3;
  }

  Future<void> saveGlassOpacity(double opacity) async {
    final existing = await _database.appStateCollections.getByStateKey(
      _glassOpacityKey,
    );
    final state = existing ?? AppStateCollection();
    state.stateKey = _glassOpacityKey;
    state.glassOpacity = opacity;
    state.updatedAt = DateTime.now();

    await _database.writeTxn(() async {
      await _database.appStateCollections.putByStateKey(state);
    });
  }

  Future<StoredTrainingInstance?> fetchActiveInstance() async {
    return fetchActiveInstanceForUser(null);
  }

  Future<StoredTrainingInstance?> fetchActiveInstanceForUser(
    String? ownerUserId,
  ) async {
    final activeInstanceId = await fetchActiveInstanceIdForUser(ownerUserId);
    if (activeInstanceId == null) {
      return null;
    }
    return fetchInstance(activeInstanceId);
  }

  Future<StoredTrainingInstance?> fetchInstanceForTemplate(
    String templateId, {
    String? ownerUserId,
  }) async {
    final collections = await _database.instanceCollections
        .filter()
        .templateIdEqualTo(templateId)
        .findAll();
    final filtered = collections
        .where(
          (collection) => _ownerMatches(collection.ownerUserId, ownerUserId),
        )
        .toList();
    if (filtered.isEmpty) {
      return null;
    }

    filtered.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    final collection = filtered.first;
    return StoredTrainingInstance(
      instanceId: collection.instanceId,
      templateId: collection.templateId,
      currentWorkoutIndex: collection.currentWorkoutIndex,
      ownerUserId: collection.ownerUserId,
      trainingMaxProfile: collection.trainingMaxProfileJson == null
          ? TrainingMaxProfile.empty
          : TrainingMaxProfile.fromJson(
              jsonDecode(collection.trainingMaxProfileJson!)
                  as Map<String, dynamic>,
            ),
      engineState: collection.engineStateJson == null
          ? const {}
          : jsonDecode(collection.engineStateJson!) as Map<String, dynamic>,
      states: collection.currentStatesJson
          .map((encoded) => TrainingState.fromJson(jsonDecode(encoded)))
          .toList(),
      createdAt: collection.createdAt,
      updatedAt: collection.lastModifiedAt,
      deletedAt: collection.deletedAt,
      version: collection.version,
      syncStatus: collection.syncStatusKey,
      lastSyncedAt: collection.lastSyncedAt,
      lastModifiedByDeviceId: collection.lastModifiedByDeviceId,
    );
  }

  Future<TrainingMaxSetupRequirement?> activationRequirementForTemplate(
    String templateId, {
    String? ownerUserId,
  }) async {
    await ensureDefaultProgramSeeded();
    final existingInstance = await fetchInstanceForTemplate(
      templateId,
      ownerUserId: ownerUserId,
    );
    if (existingInstance != null) {
      return null;
    }

    final template = await fetchTemplate(templateId);
    if (template == null || template.requiredTrainingMaxKeys.isEmpty) {
      return null;
    }

    return TrainingMaxSetupRequirement(
      templateId: template.id,
      templateName: template.name,
      liftKeys: template.requiredTrainingMaxKeys,
    );
  }

  Future<StoredTrainingInstance> activateTemplate(
    String templateId, {
    TrainingMaxProfile trainingMaxProfile = TrainingMaxProfile.empty,
    String? ownerUserId,
  }) async {
    await ensureDefaultProgramSeeded();
    final existingInstance = await fetchInstanceForTemplate(
      templateId,
      ownerUserId: ownerUserId,
    );
    final instance =
        existingInstance ??
        await _createInstanceForTemplate(
          templateId: templateId,
          preferredInstanceId: _defaultInstanceIdForTemplate(templateId),
          trainingMaxProfile: trainingMaxProfile,
          ownerUserId: ownerUserId,
        );
    await saveActiveInstanceIdForUser(instance.instanceId, ownerUserId);
    return instance;
  }

  // ---------- Instances ---------- //

  Future<void> saveInstance(
    StoredTrainingInstance data, {
    String? syncStatus,
    String? deviceId,
  }) async {
    final encodedStates = data.states
        .map((state) => jsonEncode(state.toJson()))
        .toList();
    final existing = await _database.instanceCollections.getByInstanceId(
      data.instanceId,
    );

    final instance = InstanceCollection()
      ..instanceId = data.instanceId
      ..templateId = data.templateId
      ..currentStatesJson = encodedStates
      ..trainingMaxProfileJson = jsonEncode(data.trainingMaxProfile.toJson())
      ..engineStateJson = jsonEncode(data.engineState)
      ..currentWorkoutIndex = data.currentWorkoutIndex
      ..ownerUserId = data.ownerUserId ?? existing?.ownerUserId
      ..createdAt = existing?.createdAt ?? DateTime.now()
      ..lastModifiedAt = DateTime.now()
      ..deletedAt = data.deletedAt
      ..lastSyncedAt = data.lastSyncedAt
      ..version =
          (existing?.version ?? data.version) + (existing == null ? 0 : 1)
      ..syncStatusKey =
          syncStatus ??
          (data.syncStatus.isEmpty
              ? _defaultSyncStatus(data.ownerUserId ?? existing?.ownerUserId)
              : data.syncStatus)
      ..lastModifiedByDeviceId =
          deviceId ??
          data.lastModifiedByDeviceId ??
          existing?.lastModifiedByDeviceId;

    await _database.writeTxn(() async {
      await _database.instanceCollections.putByInstanceId(instance);
    });
    await _enqueueSync(
      entityType: SyncEntityTypes.instance,
      entityId: data.instanceId,
      ownerUserId: instance.ownerUserId,
      operationType: SyncOperationTypes.upsert,
      syncStatus: instance.syncStatusKey,
    );
  }

  Future<StoredTrainingInstance?> fetchInstance(String instanceId) async {
    final instance = await _database.instanceCollections.getByInstanceId(
      instanceId,
    );
    if (instance == null) return null;

    return StoredTrainingInstance(
      instanceId: instance.instanceId,
      templateId: instance.templateId,
      currentWorkoutIndex: instance.currentWorkoutIndex,
      ownerUserId: instance.ownerUserId,
      trainingMaxProfile: instance.trainingMaxProfileJson == null
          ? TrainingMaxProfile.empty
          : TrainingMaxProfile.fromJson(
              jsonDecode(instance.trainingMaxProfileJson!)
                  as Map<String, dynamic>,
            ),
      engineState: instance.engineStateJson == null
          ? const {}
          : jsonDecode(instance.engineStateJson!) as Map<String, dynamic>,
      states: instance.currentStatesJson
          .map((encoded) => TrainingState.fromJson(jsonDecode(encoded)))
          .toList(),
      createdAt: instance.createdAt,
      updatedAt: instance.lastModifiedAt,
      deletedAt: instance.deletedAt,
      version: instance.version,
      syncStatus: instance.syncStatusKey,
      lastSyncedAt: instance.lastSyncedAt,
      lastModifiedByDeviceId: instance.lastModifiedByDeviceId,
    );
  }

  // ---------- Workflow Logs ---------- //

  Future<void> logWorkout(
    WorkoutLog logRecord, {
    String? ownerUserId,
    String? syncStatus,
    String? deviceId,
  }) async {
    final encodedLog = jsonEncode(logRecord.toJson());
    final logId =
        '${logRecord.instanceId}_${logRecord.workoutId}_${logRecord.completedAt.millisecondsSinceEpoch}';
    final existing = await _database.workoutLogCollections.getByLogId(logId);

    final collection = WorkoutLogCollection()
      ..logId = logId
      ..instanceId = logRecord.instanceId
      ..workoutId = logRecord.workoutId
      ..workoutName = logRecord.workoutName
      ..ownerUserId = ownerUserId ?? existing?.ownerUserId
      ..rawJsonPayload = encodedLog
      ..completedAt = logRecord.completedAt
      ..deletedAt = null
      ..lastSyncedAt = existing?.lastSyncedAt
      ..version = (existing?.version ?? 0) + 1
      ..syncStatusKey =
          syncStatus ?? _defaultSyncStatus(ownerUserId ?? existing?.ownerUserId)
      ..lastModifiedByDeviceId = deviceId ?? existing?.lastModifiedByDeviceId;

    await _database.writeTxn(() async {
      await _database.workoutLogCollections.putByLogId(collection);
    });
    await _enqueueSync(
      entityType: SyncEntityTypes.workoutLog,
      entityId: logId,
      ownerUserId: collection.ownerUserId,
      operationType: SyncOperationTypes.upsert,
      syncStatus: collection.syncStatusKey,
    );
  }

  Future<List<WorkoutLog>> fetchWorkoutLogs(
    String instanceId, {
    String? ownerUserId,
  }) async {
    final collections = await _database.workoutLogCollections.where().findAll();
    final logs = collections
        .where(
          (collection) =>
              collection.instanceId == instanceId &&
              collection.deletedAt == null &&
              _ownerMatches(collection.ownerUserId, ownerUserId),
        )
        .map(
          (collection) =>
              WorkoutLog.fromJson(jsonDecode(collection.rawJsonPayload)),
        )
        .toList();
    logs.sort((a, b) => b.completedAt.compareTo(a.completedAt));
    return logs;
  }

  Future<List<WorkoutLog>> fetchAllWorkoutLogs({String? ownerUserId}) async {
    final collections = await _database.workoutLogCollections.where().findAll();
    final logs = collections
        .where(
          (collection) =>
              collection.deletedAt == null &&
              _ownerMatches(collection.ownerUserId, ownerUserId),
        )
        .map(
          (collection) =>
              WorkoutLog.fromJson(jsonDecode(collection.rawJsonPayload)),
        )
        .toList();
    logs.sort((a, b) => b.completedAt.compareTo(a.completedAt));
    return logs;
  }

  Future<int> _instanceCountForTemplate(
    String templateId, {
    String? ownerUserId,
  }) async {
    final instances = await _database.instanceCollections
        .filter()
        .templateIdEqualTo(templateId)
        .findAll();
    return instances
        .where((instance) => _ownerMatches(instance.ownerUserId, ownerUserId))
        .length;
  }

  StoredTemplateRecord _toStoredTemplateRecord(
    TemplateCollection collection,
    int instanceCount,
  ) {
    return StoredTemplateRecord(
      template: PlanTemplate.fromJson(jsonDecode(collection.rawJsonPayload)),
      isBuiltIn: collection.isBuiltIn,
      sourceTemplateId: collection.sourceTemplateId,
      createdAt: collection.createdAt,
      lastModifiedAt: collection.lastModifiedAt,
      instanceCount: instanceCount,
      ownerUserId: collection.ownerUserId,
      deletedAt: collection.deletedAt,
      version: collection.version,
      syncStatus: collection.syncStatusKey,
      lastSyncedAt: collection.lastSyncedAt,
      lastModifiedByDeviceId: collection.lastModifiedByDeviceId,
    );
  }

  Future<String> fetchOrCreateDeviceId() async {
    final existing = await _database.appStateCollections.getByStateKey(
      _deviceIdStateKey,
    );
    if (existing?.stringValue case final value?) {
      return value;
    }
    final deviceId = const Uuid().v4();
    final state = AppStateCollection()
      ..stateKey = _deviceIdStateKey
      ..stringValue = deviceId
      ..updatedAt = DateTime.now();
    await _database.writeTxn(() async {
      await _database.appStateCollections.putByStateKey(state);
    });
    return deviceId;
  }

  Future<void> claimLocalDataForUser(String ownerUserId) async {
    final now = DateTime.now();
    final queuedUpserts = <(String entityType, String entityId, String? ownerUserId)>[];
    await _database.writeTxn(() async {
      final templates = await _database.templateCollections.where().findAll();
      for (final template in templates) {
        if (!template.isBuiltIn && template.ownerUserId == null) {
          template.ownerUserId = ownerUserId;
          template.syncStatusKey = SyncStatusKeys.pendingUpload;
          template.lastModifiedAt = now;
          await _database.templateCollections.put(template);
          queuedUpserts.add((
            SyncEntityTypes.template,
            template.templateId,
            ownerUserId,
          ));
        }
      }

      final instances = await _database.instanceCollections.where().findAll();
      for (final instance in instances) {
        if (instance.ownerUserId == null) {
          instance.ownerUserId = ownerUserId;
          instance.syncStatusKey = SyncStatusKeys.pendingUpload;
          instance.lastModifiedAt = now;
          await _database.instanceCollections.put(instance);
          queuedUpserts.add((
            SyncEntityTypes.instance,
            instance.instanceId,
            ownerUserId,
          ));
        }
      }

      final logs = await _database.workoutLogCollections.where().findAll();
      for (final log in logs) {
        if (log.ownerUserId == null) {
          log.ownerUserId = ownerUserId;
          log.syncStatusKey = SyncStatusKeys.pendingUpload;
          await _database.workoutLogCollections.put(log);
          queuedUpserts.add((
            SyncEntityTypes.workoutLog,
            log.logId,
            ownerUserId,
          ));
        }
      }
    });

    for (final item in queuedUpserts) {
      await _enqueueSync(
        entityType: item.$1,
        entityId: item.$2,
        ownerUserId: item.$3,
        operationType: SyncOperationTypes.upsert,
        syncStatus: SyncStatusKeys.pendingUpload,
      );
    }
  }

  bool _templateVisibleToUser(
    TemplateCollection collection,
    String? ownerUserId,
  ) {
    if (collection.deletedAt != null) {
      return false;
    }
    if (collection.isBuiltIn) {
      return true;
    }
    return _ownerMatches(collection.ownerUserId, ownerUserId);
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
    final existing = await _database.syncQueueCollections.getByQueueKey(
      queueKey,
    );
    final queueItem = SyncQueueCollection()
      ..queueKey = queueKey
      ..ownerUserId = ownerUserId
      ..entityType = entityType
      ..entityId = entityId
      ..operationType = operationType
      ..createdAt = existing?.createdAt ?? DateTime.now()
      ..updatedAt = DateTime.now();
    await _database.writeTxn(() async {
      await _database.syncQueueCollections.putByQueueKey(queueItem);
    });
  }

  String _slugifyTemplateId(String value) {
    final slug = value
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'^-+|-+$'), '');
    return slug.isEmpty ? 'shared-template' : slug;
  }

  String _generatedTemplateId(String name, {String? fallbackSourceId}) {
    final seed = _slugifyTemplateId(name);
    final base = seed == 'shared-template'
        ? _slugifyTemplateId(fallbackSourceId ?? name)
        : seed;
    return '$base-${DateTime.now().millisecondsSinceEpoch}';
  }

  Future<void> _syncBuiltInTemplate({
    required String templateId,
    required Future<PlanTemplate> Function() loadTemplate,
  }) async {
    await saveTemplate(await loadTemplate(), isBuiltIn: true);
  }

  Future<void> _purgeLegacyBuiltInInstanceIfNeeded(String instanceId) async {
    final instance = await fetchInstance(instanceId);
    if (instance == null || instance.trainingMaxProfile.isNotEmpty) {
      return;
    }

    await _database.writeTxn(() async {
      await _database.instanceCollections.deleteByInstanceId(instanceId);
    });

    final activeInstanceId = await fetchActiveInstanceId();
    if (activeInstanceId == instanceId) {
      await clearActiveInstanceId();
    }
  }

  Future<StoredTrainingInstance> _createInstanceForTemplate({
    required String templateId,
    required String preferredInstanceId,
    required TrainingMaxProfile trainingMaxProfile,
    String? ownerUserId,
  }) async {
    final template = await fetchTemplate(templateId);
    if (template == null) {
      throw StateError('Template not found for instance creation: $templateId');
    }
    if (template.requiredTrainingMaxKeys.isNotEmpty &&
        trainingMaxProfile.isEmpty) {
      throw StateError(
        'Training max setup required before activating ${template.name}.',
      );
    }

    final instance = StoredTrainingInstance(
      instanceId: preferredInstanceId,
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
    return instance;
  }

  String _defaultInstanceIdForTemplate(String templateId) {
    if (templateId == GzclpSeed.templateId) {
      return GzclpSeed.instanceId;
    }
    if (templateId == JackedAndTanSeed.templateId) {
      return JackedAndTanSeed.instanceId;
    }
    return 'instance-$templateId';
  }
}

class StoredTemplateRecord {
  StoredTemplateRecord({
    required this.template,
    required this.isBuiltIn,
    required this.sourceTemplateId,
    required this.createdAt,
    required this.lastModifiedAt,
    required this.instanceCount,
    this.ownerUserId,
    this.deletedAt,
    this.version = 1,
    this.syncStatus = SyncStatusKeys.localOnly,
    this.lastSyncedAt,
    this.lastModifiedByDeviceId,
  });

  final PlanTemplate template;
  final bool isBuiltIn;
  final String? sourceTemplateId;
  final DateTime createdAt;
  final DateTime lastModifiedAt;
  final int instanceCount;
  final String? ownerUserId;
  final DateTime? deletedAt;
  final int version;
  final String syncStatus;
  final DateTime? lastSyncedAt;
  final String? lastModifiedByDeviceId;

  bool get isUserOwned => !isBuiltIn;
}

class StoredTrainingInstance {
  StoredTrainingInstance({
    required this.instanceId,
    required this.templateId,
    required this.currentWorkoutIndex,
    this.ownerUserId,
    this.trainingMaxProfile = TrainingMaxProfile.empty,
    this.engineState = const {},
    required this.states,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.deletedAt,
    this.version = 1,
    this.syncStatus = SyncStatusKeys.localOnly,
    this.lastSyncedAt,
    this.lastModifiedByDeviceId,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  final String instanceId;
  final String templateId;
  final int currentWorkoutIndex;
  final String? ownerUserId;
  final TrainingMaxProfile trainingMaxProfile;
  final Map<String, dynamic> engineState;
  final List<TrainingState> states;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final int version;
  final String syncStatus;
  final DateTime? lastSyncedAt;
  final String? lastModifiedByDeviceId;

  StoredTrainingInstance copyWith({
    String? instanceId,
    String? templateId,
    int? currentWorkoutIndex,
    String? ownerUserId,
    TrainingMaxProfile? trainingMaxProfile,
    Map<String, dynamic>? engineState,
    List<TrainingState>? states,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
    int? version,
    String? syncStatus,
    DateTime? lastSyncedAt,
    String? lastModifiedByDeviceId,
  }) {
    return StoredTrainingInstance(
      instanceId: instanceId ?? this.instanceId,
      templateId: templateId ?? this.templateId,
      currentWorkoutIndex: currentWorkoutIndex ?? this.currentWorkoutIndex,
      ownerUserId: ownerUserId ?? this.ownerUserId,
      trainingMaxProfile: trainingMaxProfile ?? this.trainingMaxProfile,
      engineState: engineState ?? this.engineState,
      states: states ?? this.states,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      version: version ?? this.version,
      syncStatus: syncStatus ?? this.syncStatus,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      lastModifiedByDeviceId:
          lastModifiedByDeviceId ?? this.lastModifiedByDeviceId,
    );
  }
}

class TrainingMaxSetupRequirement {
  const TrainingMaxSetupRequirement({
    required this.templateId,
    required this.templateName,
    required this.liftKeys,
  });

  final String templateId;
  final String templateName;
  final List<String> liftKeys;
}
