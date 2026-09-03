import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:fittin_v2/src/application/active_session_provider.dart';
import 'package:fittin_v2/src/application/auth_provider.dart';
import 'package:fittin_v2/src/data/database_repository.dart';
import 'package:fittin_v2/src/data/models/body_metric_collection.dart';
import 'package:fittin_v2/src/data/models/instance_collection.dart';
import 'package:fittin_v2/src/data/models/sync_queue_collection.dart';
import 'package:fittin_v2/src/data/models/template_collection.dart';
import 'package:fittin_v2/src/data/models/workout_log_collection.dart';
import 'package:fittin_v2/src/data/progress_repository.dart';
import 'package:fittin_v2/src/data/remote/supabase_remote_repository.dart';
import 'package:fittin_v2/src/data/sync/sync_models.dart';
import 'package:fittin_v2/src/domain/models/training_max.dart';
import 'package:fittin_v2/src/domain/models/training_state.dart';

class SyncConflictException implements Exception {
  const SyncConflictException(this.count);

  final int count;

  @override
  String toString() => 'SyncConflictException: $count conflict(s) preserved';
}

final syncServiceProvider = Provider<SyncService>((ref) {
  final database = ref.watch(databaseRepositoryProvider);
  final progress = ref.watch(progressRepositoryProvider);
  final remote = ref.watch(supabaseRemoteRepositoryProvider);
  final ownerUserId = ref.watch(currentUserIdProvider);
  return SyncService(
    databaseRepository: database,
    progressRepository: progress,
    remoteRepository: remote,
    ownerUserId: ownerUserId,
  );
});

class SyncService {
  SyncService({
    required DatabaseRepository databaseRepository,
    required ProgressRepository progressRepository,
    required SupabaseRemoteRepository remoteRepository,
    required String? ownerUserId,
  }) : _databaseRepository = databaseRepository,
       _progressRepository = progressRepository,
       _remoteRepository = remoteRepository,
       _ownerUserId = ownerUserId;

  final DatabaseRepository _databaseRepository;
  final ProgressRepository _progressRepository;
  final SupabaseRemoteRepository _remoteRepository;
  final String? _ownerUserId;

  Isar get _isar {
    final isar = _databaseRepository.isar;
    if (isar == null) {
      throw StateError('SyncService requires Isar.');
    }
    return isar;
  }

  Future<void> synchronize() async {
    final ownerUserId = _ownerUserId;
    if (ownerUserId == null ||
        !_remoteRepository.isAvailable ||
        _databaseRepository.isar == null) {
      return;
    }

    await _databaseRepository.claimLocalDataForUser(ownerUserId);
    await _progressRepository.claimLocalDataForUser(ownerUserId);
    await _pullRemote(ownerUserId);
    await _pushPending(ownerUserId);
    await _pullRemote(ownerUserId);
    final conflicts = await _countConflicts(ownerUserId);
    if (conflicts > 0) throw SyncConflictException(conflicts);
  }

  Future<int> _countConflicts(String ownerUserId) async {
    final List<int> counts = await Future.wait<int>(<Future<int>>[
      _isar.templateCollections
          .filter()
          .ownerUserIdEqualTo(ownerUserId)
          .syncStatusKeyEqualTo(SyncStatusKeys.conflict)
          .count(),
      _isar.instanceCollections
          .filter()
          .ownerUserIdEqualTo(ownerUserId)
          .syncStatusKeyEqualTo(SyncStatusKeys.conflict)
          .count(),
      _isar.workoutLogCollections
          .filter()
          .ownerUserIdEqualTo(ownerUserId)
          .syncStatusKeyEqualTo(SyncStatusKeys.conflict)
          .count(),
      _isar.bodyMetricCollections
          .filter()
          .ownerUserIdEqualTo(ownerUserId)
          .syncStatusKeyEqualTo(SyncStatusKeys.conflict)
          .count(),
      _isar.progressPhotoCollections
          .filter()
          .ownerUserIdEqualTo(ownerUserId)
          .syncStatusKeyEqualTo(SyncStatusKeys.conflict)
          .count(),
    ]);
    var total = 0;
    for (final count in counts) {
      total += count;
    }
    return total;
  }

  Future<void> _pushPending(String ownerUserId) async {
    final queue = await _isar.syncQueueCollections
        .filter()
        .ownerUserIdEqualTo(ownerUserId)
        .sortByCreatedAt()
        .findAll();

    for (final item in queue) {
      try {
        await _pushQueueItem(item, ownerUserId);
      } on RemoteRepositoryException catch (error) {
        if (!error.isConflict) {
          rethrow;
        }
        await _markQueueItemConflict(item);
      }
    }
  }

  Future<void> _pushQueueItem(
    SyncQueueCollection item,
    String ownerUserId,
  ) async {
    switch (item.entityType) {
      case SyncEntityTypes.template:
        {
          final collection = await _isar.templateCollections.getByTemplateId(
            item.entityId,
          );
          if (collection != null) {
            if (collection.syncStatusKey == SyncStatusKeys.conflict) {
              return;
            }
            if (collection.deletedAt != null) {
              await _remoteRepository.deleteById(
                table: 'plans',
                id: item.entityId,
                version: collection.version,
                deviceId: collection.lastModifiedByDeviceId,
              );
            } else {
              await _remoteRepository.upsertPlan(collection);
            }
            await _completeTemplatePush(item, collection);
            return;
          }
          break;
        }
      case SyncEntityTypes.instance:
        {
          final instance = await _databaseRepository.fetchInstance(
            item.entityId,
          );
          if (instance != null) {
            if (instance.syncStatus == SyncStatusKeys.conflict) {
              return;
            }
            if (instance.deletedAt != null) {
              await _remoteRepository.deleteById(
                table: 'plan_instances',
                id: item.entityId,
                version: instance.version,
                deviceId: instance.lastModifiedByDeviceId,
              );
            } else {
              await _remoteRepository.upsertInstance(instance);
            }
            await _completeInstancePush(item, instance);
            return;
          }
          break;
        }
      case SyncEntityTypes.workoutLog:
        {
          final collection = await _isar.workoutLogCollections.getByLogId(
            item.entityId,
          );
          if (collection != null) {
            if (collection.syncStatusKey == SyncStatusKeys.conflict) {
              return;
            }
            if (collection.deletedAt != null) {
              await _remoteRepository.deleteById(
                table: 'workout_logs',
                id: item.entityId,
                version: collection.version,
                deviceId: collection.lastModifiedByDeviceId,
              );
            } else {
              await _remoteRepository.upsertWorkoutLog(collection);
            }
            await _completeWorkoutLogPush(item, collection);
            return;
          }
          break;
        }
      case SyncEntityTypes.bodyMetric:
        {
          final collection = await _isar.bodyMetricCollections
              .filter()
              .metricIdEqualTo(item.entityId)
              .findFirst();
          if (collection != null) {
            if (collection.syncStatusKey == SyncStatusKeys.conflict) {
              return;
            }
            if (collection.deletedAt != null) {
              await _remoteRepository.deleteById(
                table: 'body_metrics',
                id: item.entityId,
                version: collection.version,
                deviceId: collection.lastModifiedByDeviceId,
              );
            } else {
              await _remoteRepository.upsertBodyMetric(collection);
            }
            await _completeBodyMetricPush(item, collection);
            return;
          }
          break;
        }
      case SyncEntityTypes.progressPhoto:
        {
          final collection = await _isar.progressPhotoCollections
              .filter()
              .photoIdEqualTo(item.entityId)
              .findFirst();
          if (collection != null) {
            if (collection.syncStatusKey == SyncStatusKeys.conflict) {
              return;
            }
            if (collection.deletedAt != null) {
              await _remoteRepository.deleteById(
                table: 'progress_photos',
                id: item.entityId,
                version: collection.version,
                deviceId: collection.lastModifiedByDeviceId,
              );
            } else {
              final storagePath = await _remoteRepository.uploadProgressPhoto(
                userId: ownerUserId,
                photoId: collection.photoId,
                localFilePath: collection.filePath,
              );
              await _remoteRepository.upsertProgressPhotoMetadata(
                collection: collection,
                storagePath: storagePath,
              );
            }
            await _completeProgressPhotoPush(item, collection);
            return;
          }
          break;
        }
    }

    await _deleteQueueItemIfEntityStillMissing(item);
  }

  Future<void> _pullRemote(String ownerUserId) async {
    final plans = await _fetchIncremental('plans', ownerUserId);
    final instances = await _fetchIncremental('plan_instances', ownerUserId);
    final logs = await _fetchIncremental('workout_logs', ownerUserId);
    final metrics = await _fetchIncremental('body_metrics', ownerUserId);
    final progressPhotos = await _fetchIncremental(
      'progress_photos',
      ownerUserId,
    );

    await _mergePlans(plans, ownerUserId);
    await _mergeInstances(instances, ownerUserId);
    await _mergeWorkoutLogs(logs, ownerUserId);
    await _mergeBodyMetrics(metrics, ownerUserId);
    await _mergeProgressPhotos(progressPhotos, ownerUserId);
    await _saveCursors(ownerUserId, {
      'plans': plans,
      'plan_instances': instances,
      'workout_logs': logs,
      'body_metrics': metrics,
      'progress_photos': progressPhotos,
    });
  }

  Future<List<Map<String, dynamic>>> _fetchIncremental(
    String table,
    String ownerUserId,
  ) async {
    final cursor = await _databaseRepository.fetchSyncCursor(
      ownerUserId,
      table,
    );
    return _remoteRepository.fetchRows(
      table: table,
      userId: ownerUserId,
      since: cursor?.subtract(const Duration(seconds: 2)),
    );
  }

  Future<void> _saveCursors(
    String ownerUserId,
    Map<String, List<Map<String, dynamic>>> rowsByTable,
  ) async {
    for (final entry in rowsByTable.entries) {
      DateTime? newest;
      for (final row in entry.value) {
        final value = row['updated_at'] as String?;
        final updatedAt = value == null
            ? null
            : DateTime.tryParse(value)?.toUtc();
        if (updatedAt != null &&
            (newest == null || updatedAt.isAfter(newest))) {
          newest = updatedAt;
        }
      }
      if (newest != null) {
        await _databaseRepository.saveSyncCursor(
          ownerUserId,
          entry.key,
          newest,
        );
      }
    }
  }

  Future<void> _mergePlans(
    List<Map<String, dynamic>> rows,
    String ownerUserId,
  ) async {
    for (final row in rows) {
      final existing = await _isar.templateCollections.getByTemplateId(
        row['id'] as String,
      );
      if (_shouldMarkTemplateConflict(existing, row)) {
        await _markTemplateConflict(existing!);
        continue;
      }
      if (_shouldKeepTemplateLocal(existing, row)) {
        continue;
      }

      final collection = TemplateCollection()
        ..templateId = row['id'] as String
        ..name = row['name'] as String? ?? ''
        ..description = row['description'] as String? ?? ''
        ..isBuiltIn = row['is_built_in'] as bool? ?? false
        ..sourceTemplateId = row['source_plan_id'] as String?
        ..ownerUserId = ownerUserId
        ..createdAt = DateTime.parse(row['created_at'] as String).toLocal()
        ..lastModifiedAt = DateTime.parse(row['updated_at'] as String).toLocal()
        ..deletedAt = _parseDateTime(row['deleted_at'])
        ..lastSyncedAt = DateTime.now()
        ..version = row['version'] as int? ?? 1
        ..syncStatusKey = SyncStatusKeys.synced
        ..lastModifiedByDeviceId = row['last_modified_by_device_id'] as String?
        ..rawJsonPayload = row['raw_json'] as String? ?? '{}';
      if (existing != null) {
        collection.id = existing.id;
      }
      await _isar.writeTxn(() async {
        await _isar.templateCollections.putByTemplateId(collection);
      });
    }
  }

  Future<void> _mergeInstances(
    List<Map<String, dynamic>> rows,
    String ownerUserId,
  ) async {
    final remoteInstances = <StoredTrainingInstance>[];
    for (final row in rows) {
      final existing = await _databaseRepository.fetchInstance(
        row['id'] as String,
      );
      final remoteVersion = row['version'] as int? ?? 1;
      if (_shouldMarkInstanceConflict(existing, row)) {
        await _databaseRepository.saveRemoteInstance(
          existing!.copyWith(syncStatus: SyncStatusKeys.conflict),
        );
        continue;
      }
      if (_shouldKeepInstanceLocal(existing, row)) {
        continue;
      }

      final statesJson =
          jsonDecode(row['current_states_json'] as String) as List;
      final instance = StoredTrainingInstance(
        instanceId: row['id'] as String,
        templateId: row['template_id'] as String,
        currentWorkoutIndex: row['current_workout_index'] as int? ?? 0,
        ownerUserId: ownerUserId,
        trainingMaxProfile: TrainingMaxProfile.fromJson(
          jsonDecode(row['training_max_profile_json'] as String)
              as Map<String, dynamic>,
        ),
        engineState:
            jsonDecode(row['engine_state_json'] as String)
                as Map<String, dynamic>,
        states: statesJson
            .map((item) => TrainingState.fromJson(item as Map<String, dynamic>))
            .toList(),
        createdAt: DateTime.parse(row['created_at'] as String).toLocal(),
        updatedAt: DateTime.parse(row['updated_at'] as String).toLocal(),
        deletedAt: _parseDateTime(row['deleted_at']),
        version: remoteVersion,
        syncStatus: SyncStatusKeys.synced,
        lastSyncedAt: DateTime.now(),
        lastModifiedByDeviceId: row['last_modified_by_device_id'] as String?,
      );
      await _databaseRepository.saveRemoteInstance(instance);
      if (instance.deletedAt == null) {
        remoteInstances.add(instance);
      }
    }

    final activeInstanceId = await _databaseRepository
        .fetchActiveInstanceIdForUser(ownerUserId);
    if (activeInstanceId == null && remoteInstances.isNotEmpty) {
      remoteInstances.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      await _databaseRepository.saveActiveInstanceIdForUser(
        remoteInstances.first.instanceId,
        ownerUserId,
      );
    }
  }

  Future<void> _mergeWorkoutLogs(
    List<Map<String, dynamic>> rows,
    String ownerUserId,
  ) async {
    for (final row in rows) {
      final existing = await _isar.workoutLogCollections.getByLogId(
        row['id'] as String,
      );
      if (_shouldMarkWorkoutLogConflict(existing, row)) {
        await _markWorkoutLogConflict(existing!);
        continue;
      }
      if (_shouldKeepWorkoutLogLocal(existing, row)) {
        continue;
      }
      if (existing != null &&
          !_isPendingLocalConflict(existing.syncStatusKey) &&
          existing.version > (row['version'] as int? ?? 0)) {
        continue;
      }
      final collection = WorkoutLogCollection()
        ..logId = row['id'] as String
        ..instanceId = row['instance_id'] as String
        ..workoutId = row['workout_id'] as String
        ..workoutName = row['workout_name'] as String? ?? ''
        ..ownerUserId = ownerUserId
        ..rawJsonPayload = row['raw_json'] as String? ?? '{}'
        ..completedAt = DateTime.parse(row['completed_at'] as String).toLocal()
        ..deletedAt = _parseDateTime(row['deleted_at'])
        ..lastSyncedAt = DateTime.now()
        ..version = row['version'] as int? ?? 1
        ..syncStatusKey = SyncStatusKeys.synced
        ..lastModifiedByDeviceId = row['last_modified_by_device_id'] as String?;
      if (existing != null) {
        collection.id = existing.id;
      }
      await _isar.writeTxn(() async {
        await _isar.workoutLogCollections.putByLogId(collection);
      });
    }
  }

  Future<void> _mergeBodyMetrics(
    List<Map<String, dynamic>> rows,
    String ownerUserId,
  ) async {
    for (final row in rows) {
      final existing = await _isar.bodyMetricCollections
          .filter()
          .metricIdEqualTo(row['id'] as String)
          .findFirst();
      if (_shouldMarkBodyMetricConflict(existing, row)) {
        await _markBodyMetricConflict(existing!);
        continue;
      }
      if (_shouldKeepBodyMetricLocal(existing, row)) {
        continue;
      }
      if (existing != null &&
          !_isPendingLocalConflict(existing.syncStatusKey) &&
          existing.version > (row['version'] as int? ?? 0)) {
        continue;
      }
      final metric = BodyMetricCollection()
        ..metricId = row['id'] as String
        ..ownerUserId = ownerUserId
        ..timestamp = DateTime.parse(row['timestamp'] as String).toLocal()
        ..weightKg = (row['weight_kg'] as num?)?.toDouble()
        ..bodyFatPercent = (row['body_fat_percent'] as num?)?.toDouble()
        ..waistCm = (row['waist_cm'] as num?)?.toDouble()
        ..note = row['note'] as String?
        ..deletedAt = _parseDateTime(row['deleted_at'])
        ..lastSyncedAt = DateTime.now()
        ..version = row['version'] as int? ?? 1
        ..syncStatusKey = SyncStatusKeys.synced
        ..lastModifiedByDeviceId = row['last_modified_by_device_id'] as String?;
      if (existing != null) {
        metric.id = existing.id;
      }
      await _isar.writeTxn(() async {
        await _isar.bodyMetricCollections.put(metric);
      });
    }
  }

  Future<void> _mergeProgressPhotos(
    List<Map<String, dynamic>> rows,
    String ownerUserId,
  ) async {
    for (final row in rows) {
      final existing = await _isar.progressPhotoCollections
          .filter()
          .photoIdEqualTo(row['id'] as String)
          .findFirst();
      if (_shouldMarkProgressPhotoConflict(existing, row)) {
        await _markProgressPhotoConflict(existing!);
        continue;
      }
      if (_shouldKeepProgressPhotoLocal(existing, row)) {
        continue;
      }
      if (existing != null &&
          !_isPendingLocalConflict(existing.syncStatusKey) &&
          existing.version > (row['version'] as int? ?? 0)) {
        continue;
      }

      final storagePath = row['storage_path'] as String? ?? '';
      var localFilePath = existing?.filePath ?? '';
      if (_parseDateTime(row['deleted_at']) == null &&
          (localFilePath.isEmpty || localFilePath == storagePath)) {
        localFilePath = await _remoteRepository.downloadProgressPhotoToLocal(
          row['id'] as String,
        );
      }
      final collection = ProgressPhotoCollection()
        ..photoId = row['id'] as String
        ..ownerUserId = ownerUserId
        ..timestamp = DateTime.parse(
          (row['captured_at'] ?? row['created_at']) as String,
        ).toLocal()
        ..filePath = localFilePath
        ..label = row['label'] as String?
        ..metadataJson = row['metadata_json'] as String?
        ..deletedAt = _parseDateTime(row['deleted_at'])
        ..lastSyncedAt = DateTime.now()
        ..version = row['version'] as int? ?? 1
        ..syncStatusKey = SyncStatusKeys.synced
        ..lastModifiedByDeviceId = row['last_modified_by_device_id'] as String?;
      if (existing != null) {
        collection.id = existing.id;
      }
      await _isar.writeTxn(() async {
        await _isar.progressPhotoCollections.put(collection);
      });
    }
  }

  Future<void> _completeTemplatePush(
    SyncQueueCollection item,
    TemplateCollection uploaded,
  ) => _completePushIfUnchanged<TemplateCollection, TemplateCollection>(
    item: item,
    uploaded: uploaded,
    readCurrent: () =>
        _isar.templateCollections.getByTemplateId(uploaded.templateId),
    matches: _sameTemplateUpload,
    markSynced: (current, syncedAt) async {
      current
        ..syncStatusKey = SyncStatusKeys.synced
        ..lastSyncedAt = syncedAt;
      await _isar.templateCollections.putByTemplateId(current);
    },
  );

  Future<void> _markTemplateConflict(TemplateCollection collection) async {
    collection.syncStatusKey = SyncStatusKeys.conflict;
    await _isar.writeTxn(() async {
      await _isar.templateCollections.putByTemplateId(collection);
    });
  }

  Future<void> _completeInstancePush(
    SyncQueueCollection item,
    StoredTrainingInstance uploaded,
  ) => _completePushIfUnchanged<StoredTrainingInstance, InstanceCollection>(
    item: item,
    uploaded: uploaded,
    readCurrent: () =>
        _isar.instanceCollections.getByInstanceId(uploaded.instanceId),
    matches: _sameInstanceUpload,
    markSynced: (current, syncedAt) async {
      current
        ..syncStatusKey = SyncStatusKeys.synced
        ..lastSyncedAt = syncedAt;
      await _isar.instanceCollections.putByInstanceId(current);
    },
  );

  Future<void> _completeWorkoutLogPush(
    SyncQueueCollection item,
    WorkoutLogCollection uploaded,
  ) => _completePushIfUnchanged<WorkoutLogCollection, WorkoutLogCollection>(
    item: item,
    uploaded: uploaded,
    readCurrent: () => _isar.workoutLogCollections.getByLogId(uploaded.logId),
    matches: _sameWorkoutLogUpload,
    markSynced: (current, syncedAt) async {
      current
        ..syncStatusKey = SyncStatusKeys.synced
        ..lastSyncedAt = syncedAt;
      await _isar.workoutLogCollections.putByLogId(current);
    },
  );

  Future<void> _markWorkoutLogConflict(WorkoutLogCollection collection) async {
    collection.syncStatusKey = SyncStatusKeys.conflict;
    await _isar.writeTxn(() async {
      await _isar.workoutLogCollections.putByLogId(collection);
    });
  }

  Future<void> _completeBodyMetricPush(
    SyncQueueCollection item,
    BodyMetricCollection uploaded,
  ) => _completePushIfUnchanged<BodyMetricCollection, BodyMetricCollection>(
    item: item,
    uploaded: uploaded,
    readCurrent: () => _isar.bodyMetricCollections
        .filter()
        .metricIdEqualTo(uploaded.metricId)
        .findFirst(),
    matches: _sameBodyMetricUpload,
    markSynced: (current, syncedAt) async {
      current
        ..syncStatusKey = SyncStatusKeys.synced
        ..lastSyncedAt = syncedAt;
      await _isar.bodyMetricCollections.put(current);
    },
  );

  Future<void> _markBodyMetricConflict(BodyMetricCollection collection) async {
    collection.syncStatusKey = SyncStatusKeys.conflict;
    await _isar.writeTxn(() async {
      await _isar.bodyMetricCollections.put(collection);
    });
  }

  Future<void> _completeProgressPhotoPush(
    SyncQueueCollection item,
    ProgressPhotoCollection uploaded,
  ) =>
      _completePushIfUnchanged<
        ProgressPhotoCollection,
        ProgressPhotoCollection
      >(
        item: item,
        uploaded: uploaded,
        readCurrent: () => _isar.progressPhotoCollections
            .filter()
            .photoIdEqualTo(uploaded.photoId)
            .findFirst(),
        matches: _sameProgressPhotoUpload,
        markSynced: (current, syncedAt) async {
          current
            ..syncStatusKey = SyncStatusKeys.synced
            ..lastSyncedAt = syncedAt;
          await _isar.progressPhotoCollections.put(current);
        },
      );

  Future<void> _completePushIfUnchanged<TUploaded, TCurrent>({
    required SyncQueueCollection item,
    required TUploaded uploaded,
    required Future<TCurrent?> Function() readCurrent,
    required bool Function(TCurrent current, TUploaded uploaded) matches,
    required Future<void> Function(TCurrent current, DateTime syncedAt)
    markSynced,
  }) async {
    await _isar.writeTxn(() async {
      final currentQueue = await _isar.syncQueueCollections.getByQueueKey(
        item.queueKey,
      );
      if (!_sameQueueItem(currentQueue, item)) return;
      final current = await readCurrent();
      if (current == null || !matches(current, uploaded)) return;
      await markSynced(current, DateTime.now());
      await _isar.syncQueueCollections.deleteByQueueKey(item.queueKey);
    });
  }

  Future<void> _deleteQueueItemIfEntityStillMissing(
    SyncQueueCollection item,
  ) async {
    await _isar.writeTxn(() async {
      final currentQueue = await _isar.syncQueueCollections.getByQueueKey(
        item.queueKey,
      );
      if (!_sameQueueItem(currentQueue, item)) return;
      final exists = switch (item.entityType) {
        SyncEntityTypes.template =>
          await _isar.templateCollections.getByTemplateId(item.entityId) !=
              null,
        SyncEntityTypes.instance =>
          await _isar.instanceCollections.getByInstanceId(item.entityId) !=
              null,
        SyncEntityTypes.workoutLog =>
          await _isar.workoutLogCollections.getByLogId(item.entityId) != null,
        SyncEntityTypes.bodyMetric =>
          await _isar.bodyMetricCollections
                  .filter()
                  .metricIdEqualTo(item.entityId)
                  .findFirst() !=
              null,
        SyncEntityTypes.progressPhoto =>
          await _isar.progressPhotoCollections
                  .filter()
                  .photoIdEqualTo(item.entityId)
                  .findFirst() !=
              null,
        _ => false,
      };
      if (!exists) {
        await _isar.syncQueueCollections.deleteByQueueKey(item.queueKey);
      }
    });
  }

  bool _sameQueueItem(
    SyncQueueCollection? current,
    SyncQueueCollection uploaded,
  ) {
    return current != null &&
        current.queueKey == uploaded.queueKey &&
        current.ownerUserId == uploaded.ownerUserId &&
        current.entityType == uploaded.entityType &&
        current.entityId == uploaded.entityId &&
        current.operationType == uploaded.operationType &&
        _sameInstant(current.createdAt, uploaded.createdAt) &&
        _sameInstant(current.updatedAt, uploaded.updatedAt);
  }

  bool _sameTemplateUpload(
    TemplateCollection current,
    TemplateCollection uploaded,
  ) {
    return current.templateId == uploaded.templateId &&
        current.name == uploaded.name &&
        current.description == uploaded.description &&
        current.isBuiltIn == uploaded.isBuiltIn &&
        current.sourceTemplateId == uploaded.sourceTemplateId &&
        current.ownerUserId == uploaded.ownerUserId &&
        current.version == uploaded.version &&
        current.lastModifiedByDeviceId == uploaded.lastModifiedByDeviceId &&
        current.syncStatusKey == uploaded.syncStatusKey &&
        _sameInstant(current.createdAt, uploaded.createdAt) &&
        _sameInstant(current.lastModifiedAt, uploaded.lastModifiedAt) &&
        _sameInstant(current.deletedAt, uploaded.deletedAt) &&
        current.rawJsonPayload == uploaded.rawJsonPayload;
  }

  bool _sameInstanceUpload(
    InstanceCollection current,
    StoredTrainingInstance uploaded,
  ) {
    final uploadedStates = uploaded.states
        .map((state) => jsonEncode(state.toJson()))
        .toList();
    return current.instanceId == uploaded.instanceId &&
        current.templateId == uploaded.templateId &&
        current.ownerUserId == uploaded.ownerUserId &&
        current.version == uploaded.version &&
        current.lastModifiedByDeviceId == uploaded.lastModifiedByDeviceId &&
        current.syncStatusKey == uploaded.syncStatus &&
        current.currentWorkoutIndex == uploaded.currentWorkoutIndex &&
        _sameInstant(current.createdAt, uploaded.createdAt) &&
        _sameInstant(current.lastModifiedAt, uploaded.updatedAt) &&
        _sameInstant(current.deletedAt, uploaded.deletedAt) &&
        current.trainingMaxProfileJson ==
            jsonEncode(uploaded.trainingMaxProfile.toJson()) &&
        current.engineStateJson == jsonEncode(uploaded.engineState) &&
        _sameStringList(current.currentStatesJson, uploadedStates);
  }

  bool _sameWorkoutLogUpload(
    WorkoutLogCollection current,
    WorkoutLogCollection uploaded,
  ) {
    return current.logId == uploaded.logId &&
        current.instanceId == uploaded.instanceId &&
        current.workoutId == uploaded.workoutId &&
        current.workoutName == uploaded.workoutName &&
        current.ownerUserId == uploaded.ownerUserId &&
        current.version == uploaded.version &&
        current.lastModifiedByDeviceId == uploaded.lastModifiedByDeviceId &&
        current.syncStatusKey == uploaded.syncStatusKey &&
        _sameInstant(current.completedAt, uploaded.completedAt) &&
        _sameInstant(current.deletedAt, uploaded.deletedAt) &&
        current.rawJsonPayload == uploaded.rawJsonPayload;
  }

  bool _sameBodyMetricUpload(
    BodyMetricCollection current,
    BodyMetricCollection uploaded,
  ) {
    return current.metricId == uploaded.metricId &&
        current.ownerUserId == uploaded.ownerUserId &&
        current.version == uploaded.version &&
        current.lastModifiedByDeviceId == uploaded.lastModifiedByDeviceId &&
        current.syncStatusKey == uploaded.syncStatusKey &&
        _sameInstant(current.timestamp, uploaded.timestamp) &&
        _sameInstant(current.deletedAt, uploaded.deletedAt) &&
        current.weightKg == uploaded.weightKg &&
        current.bodyFatPercent == uploaded.bodyFatPercent &&
        current.waistCm == uploaded.waistCm &&
        current.note == uploaded.note;
  }

  bool _sameProgressPhotoUpload(
    ProgressPhotoCollection current,
    ProgressPhotoCollection uploaded,
  ) {
    return current.photoId == uploaded.photoId &&
        current.ownerUserId == uploaded.ownerUserId &&
        current.version == uploaded.version &&
        current.lastModifiedByDeviceId == uploaded.lastModifiedByDeviceId &&
        current.syncStatusKey == uploaded.syncStatusKey &&
        _sameInstant(current.timestamp, uploaded.timestamp) &&
        _sameInstant(current.deletedAt, uploaded.deletedAt) &&
        current.filePath == uploaded.filePath &&
        current.label == uploaded.label &&
        current.metadataJson == uploaded.metadataJson;
  }

  bool _sameStringList(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (var index = 0; index < a.length; index++) {
      if (a[index] != b[index]) return false;
    }
    return true;
  }

  bool _sameInstant(DateTime? a, DateTime? b) {
    if (a == null || b == null) return a == b;
    return a.isAtSameMomentAs(b);
  }

  Future<void> _markProgressPhotoConflict(
    ProgressPhotoCollection collection,
  ) async {
    collection.syncStatusKey = SyncStatusKeys.conflict;
    await _isar.writeTxn(() async {
      await _isar.progressPhotoCollections.put(collection);
    });
  }

  Future<void> _markQueueItemConflict(SyncQueueCollection item) async {
    switch (item.entityType) {
      case SyncEntityTypes.template:
        final collection = await _isar.templateCollections.getByTemplateId(
          item.entityId,
        );
        if (collection != null) await _markTemplateConflict(collection);
        break;
      case SyncEntityTypes.instance:
        final instance = await _databaseRepository.fetchInstance(item.entityId);
        if (instance != null) {
          await _databaseRepository.saveRemoteInstance(
            instance.copyWith(syncStatus: SyncStatusKeys.conflict),
          );
        }
        break;
      case SyncEntityTypes.workoutLog:
        final collection = await _isar.workoutLogCollections.getByLogId(
          item.entityId,
        );
        if (collection != null) await _markWorkoutLogConflict(collection);
        break;
      case SyncEntityTypes.bodyMetric:
        final collection = await _isar.bodyMetricCollections
            .filter()
            .metricIdEqualTo(item.entityId)
            .findFirst();
        if (collection != null) await _markBodyMetricConflict(collection);
        break;
      case SyncEntityTypes.progressPhoto:
        final collection = await _isar.progressPhotoCollections
            .filter()
            .photoIdEqualTo(item.entityId)
            .findFirst();
        if (collection != null) await _markProgressPhotoConflict(collection);
        break;
    }
  }

  bool _shouldMarkInstanceConflict(
    StoredTrainingInstance? existing,
    Map<String, dynamic> row,
  ) {
    return existing != null &&
        _remoteConflictsWithLocal(
          syncStatus: existing.syncStatus,
          localVersion: existing.version,
          localDeviceId: existing.lastModifiedByDeviceId,
          row: row,
        );
  }

  bool _shouldKeepTemplateLocal(
    TemplateCollection? existing,
    Map<String, dynamic> row,
  ) {
    return existing != null &&
        _shouldKeepLocal(
          existing.syncStatusKey,
          existing.version,
          row['version'],
        );
  }

  bool _shouldKeepInstanceLocal(
    StoredTrainingInstance? existing,
    Map<String, dynamic> row,
  ) {
    return existing != null &&
        _shouldKeepLocal(existing.syncStatus, existing.version, row['version']);
  }

  bool _shouldKeepWorkoutLogLocal(
    WorkoutLogCollection? existing,
    Map<String, dynamic> row,
  ) {
    return existing != null &&
        _shouldKeepLocal(
          existing.syncStatusKey,
          existing.version,
          row['version'],
        );
  }

  bool _shouldKeepBodyMetricLocal(
    BodyMetricCollection? existing,
    Map<String, dynamic> row,
  ) {
    return existing != null &&
        _shouldKeepLocal(
          existing.syncStatusKey,
          existing.version,
          row['version'],
        );
  }

  bool _shouldKeepProgressPhotoLocal(
    ProgressPhotoCollection? existing,
    Map<String, dynamic> row,
  ) {
    return existing != null &&
        _shouldKeepLocal(
          existing.syncStatusKey,
          existing.version,
          row['version'],
        );
  }

  bool _shouldKeepLocal(
    String? syncStatus,
    int localVersion,
    Object? remoteVersion,
  ) {
    return _isPendingLocalConflict(syncStatus) &&
        localVersion > (remoteVersion as int? ?? 0);
  }

  bool _remoteConflictsWithLocal({
    required String? syncStatus,
    required int localVersion,
    required String? localDeviceId,
    required Map<String, dynamic> row,
  }) {
    if (!_isPendingLocalConflict(syncStatus)) return false;
    final remoteVersion = row['version'] as int? ?? 0;
    if (remoteVersion < localVersion) return false;
    final remoteDeviceId = row['last_modified_by_device_id'] as String?;
    final isIdempotentSameDevice =
        remoteVersion == localVersion &&
        localDeviceId != null &&
        localDeviceId.isNotEmpty &&
        localDeviceId == remoteDeviceId;
    return !isIdempotentSameDevice;
  }

  bool _shouldMarkTemplateConflict(
    TemplateCollection? existing,
    Map<String, dynamic> row,
  ) {
    return existing != null &&
        _remoteConflictsWithLocal(
          syncStatus: existing.syncStatusKey,
          localVersion: existing.version,
          localDeviceId: existing.lastModifiedByDeviceId,
          row: row,
        );
  }

  bool _shouldMarkWorkoutLogConflict(
    WorkoutLogCollection? existing,
    Map<String, dynamic> row,
  ) {
    return existing != null &&
        _remoteConflictsWithLocal(
          syncStatus: existing.syncStatusKey,
          localVersion: existing.version,
          localDeviceId: existing.lastModifiedByDeviceId,
          row: row,
        );
  }

  bool _shouldMarkBodyMetricConflict(
    BodyMetricCollection? existing,
    Map<String, dynamic> row,
  ) {
    return existing != null &&
        _remoteConflictsWithLocal(
          syncStatus: existing.syncStatusKey,
          localVersion: existing.version,
          localDeviceId: existing.lastModifiedByDeviceId,
          row: row,
        );
  }

  bool _shouldMarkProgressPhotoConflict(
    ProgressPhotoCollection? existing,
    Map<String, dynamic> row,
  ) {
    return existing != null &&
        _remoteConflictsWithLocal(
          syncStatus: existing.syncStatusKey,
          localVersion: existing.version,
          localDeviceId: existing.lastModifiedByDeviceId,
          row: row,
        );
  }

  bool _isPendingLocalConflict(String? syncStatus) {
    return syncStatus == SyncStatusKeys.pendingUpload ||
        syncStatus == SyncStatusKeys.pendingDelete ||
        syncStatus == SyncStatusKeys.conflict;
  }

  DateTime? _parseDateTime(Object? value) {
    final stringValue = value as String?;
    return stringValue == null ? null : DateTime.parse(stringValue).toLocal();
  }
}
