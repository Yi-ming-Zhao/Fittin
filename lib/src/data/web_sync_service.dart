import 'dart:convert';

import 'package:fittin_v2/src/data/database_repository.dart';
import 'package:fittin_v2/src/data/remote/supabase_remote_repository.dart';
import 'package:fittin_v2/src/data/sync/sync_models.dart';
import 'package:fittin_v2/src/data/sync/sync_service.dart';
import 'package:fittin_v2/src/data/web_database_repository.dart';
import 'package:fittin_v2/src/data/web_local_store.dart';
import 'package:fittin_v2/src/data/web_progress_repository.dart';
import 'package:fittin_v2/src/data/web_storage_models.dart';
import 'package:fittin_v2/src/domain/models/training_max.dart';
import 'package:fittin_v2/src/domain/models/training_state.dart';

class WebSyncService extends SyncService {
  // ignore: use_super_parameters
  WebSyncService({
    required WebDatabaseRepository databaseRepository,
    required WebProgressRepository progressRepository,
    required SupabaseRemoteRepository remoteRepository,
    required String? ownerUserId,
  }) : _databaseRepository = databaseRepository,
       _progressRepository = progressRepository,
       _remoteRepository = remoteRepository,
       _ownerUserId = ownerUserId,
       super(
         databaseRepository: databaseRepository,
         progressRepository: progressRepository,
         remoteRepository: remoteRepository,
         ownerUserId: ownerUserId,
       );

  final WebDatabaseRepository _databaseRepository;
  final WebProgressRepository _progressRepository;
  final SupabaseRemoteRepository _remoteRepository;
  final String? _ownerUserId;

  WebLocalStore get _store => _databaseRepository.store;

  @override
  Future<void> synchronize() async {
    final ownerUserId = _ownerUserId;
    if (ownerUserId == null || !_remoteRepository.isAvailable) {
      return;
    }

    await _databaseRepository.claimLocalDataForUser(ownerUserId);
    await _progressRepository.claimLocalDataForUser(ownerUserId);
    await _pullRemote(ownerUserId);
    await _pushPending(ownerUserId);
    await _pullRemote(ownerUserId);
  }

  Future<void> _pushPending(String ownerUserId) async {
    final queue = await _store.getAllRecords(WebStoreNames.syncQueue);
    final pending =
        queue.where((doc) => doc['ownerUserId'] == ownerUserId).toList()..sort(
          (a, b) => (parseStoredDateTime(a['createdAt']) ?? DateTime.now())
              .compareTo(parseStoredDateTime(b['createdAt']) ?? DateTime.now()),
        );

    for (final item in pending) {
      try {
        await _pushQueueItem(item, ownerUserId);
      } on RemoteRepositoryException catch (error) {
        if (!error.isConflict) rethrow;
        await _markQueueDocConflict(item);
      }
    }
  }

  Future<void> _pushQueueItem(
    Map<String, dynamic> item,
    String ownerUserId,
  ) async {
    switch (item['entityType']) {
      case SyncEntityTypes.template:
        final doc = await _store.getRecord(
          WebStoreNames.templates,
          item['entityId'] as String,
        );
        if (doc != null) {
          if (doc['syncStatusKey'] == SyncStatusKeys.conflict) return;
          if (parseStoredDateTime(doc['deletedAt']) != null) {
            await _remoteRepository.deleteById(
              table: 'plans',
              id: item['entityId'] as String,
              version: doc['version'] as int?,
              deviceId: doc['lastModifiedByDeviceId'] as String?,
            );
          } else {
            await _remoteRepository.upsertRow(
              table: 'plans',
              row: planRowFromTemplateDoc(doc),
            );
          }
          await _markDocSynced(WebStoreNames.templates, 'templateId', doc);
        }
        break;
      case SyncEntityTypes.instance:
        final instance = await _databaseRepository.fetchInstance(
          item['entityId'] as String,
        );
        if (instance != null) {
          if (instance.syncStatus == SyncStatusKeys.conflict) return;
          if (instance.deletedAt != null) {
            await _remoteRepository.deleteById(
              table: 'plan_instances',
              id: item['entityId'] as String,
              version: instance.version,
              deviceId: instance.lastModifiedByDeviceId,
            );
          } else {
            await _remoteRepository.upsertInstance(instance);
          }
          await _databaseRepository.saveRemoteInstance(
            instance.copyWith(
              syncStatus: SyncStatusKeys.synced,
              lastSyncedAt: DateTime.now(),
            ),
          );
        }
        break;
      case SyncEntityTypes.workoutLog:
        final doc = await _store.getRecord(
          WebStoreNames.workoutLogs,
          item['entityId'] as String,
        );
        if (doc != null) {
          if (doc['syncStatusKey'] == SyncStatusKeys.conflict) return;
          if (parseStoredDateTime(doc['deletedAt']) != null) {
            await _remoteRepository.deleteById(
              table: 'workout_logs',
              id: item['entityId'] as String,
              version: doc['version'] as int?,
              deviceId: doc['lastModifiedByDeviceId'] as String?,
            );
          } else {
            await _remoteRepository.upsertRow(
              table: 'workout_logs',
              row: workoutLogRowFromDoc(doc),
            );
          }
          await _markDocSynced(WebStoreNames.workoutLogs, 'logId', doc);
        }
        break;
      case SyncEntityTypes.bodyMetric:
        final doc = await _store.getRecord(
          WebStoreNames.bodyMetrics,
          item['entityId'] as String,
        );
        if (doc != null) {
          if (doc['syncStatusKey'] == SyncStatusKeys.conflict) return;
          if (parseStoredDateTime(doc['deletedAt']) != null) {
            await _remoteRepository.deleteById(
              table: 'body_metrics',
              id: item['entityId'] as String,
              version: doc['version'] as int?,
              deviceId: doc['lastModifiedByDeviceId'] as String?,
            );
          } else {
            await _remoteRepository.upsertRow(
              table: 'body_metrics',
              row: bodyMetricRowFromDoc(doc),
            );
          }
          await _markDocSynced(WebStoreNames.bodyMetrics, 'metricId', doc);
        }
        break;
      case SyncEntityTypes.progressPhoto:
        final doc = await _store.getRecord(
          WebStoreNames.progressPhotos,
          item['entityId'] as String,
        );
        if (doc != null) {
          if (doc['syncStatusKey'] == SyncStatusKeys.conflict) return;
          if (parseStoredDateTime(doc['deletedAt']) != null) {
            await _remoteRepository.deleteById(
              table: 'progress_photos',
              id: item['entityId'] as String,
              version: doc['version'] as int?,
              deviceId: doc['lastModifiedByDeviceId'] as String?,
            );
          } else {
            final storagePath = await _remoteRepository.uploadProgressPhoto(
              userId: ownerUserId,
              photoId: item['entityId'] as String,
              localFilePath: doc['filePath'] as String? ?? '',
            );
            await _remoteRepository.upsertRow(
              table: 'progress_photos',
              row: progressPhotoRowFromDoc(doc, storagePath: storagePath),
            );
          }
          await _markDocSynced(WebStoreNames.progressPhotos, 'photoId', doc);
        }
        break;
    }

    await _store.deleteRecord(
      WebStoreNames.syncQueue,
      item['queueKey'] as String,
    );
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
      final existing = await _store.getRecord(
        WebStoreNames.templates,
        row['id'] as String,
      );
      final remoteVersion = row['version'] as int? ?? 1;
      if (_shouldMarkConflict(existing, row)) {
        await _markDocConflict(
          WebStoreNames.templates,
          'templateId',
          existing!,
        );
        continue;
      }
      if (_shouldKeepLocal(existing, remoteVersion)) continue;

      final doc = <String, dynamic>{
        'templateId': row['id'] as String,
        'name': row['name'] as String? ?? '',
        'description': row['description'] as String? ?? '',
        'isBuiltIn': row['is_built_in'] as bool? ?? false,
        'sourceTemplateId': row['source_plan_id'] as String?,
        'ownerUserId': ownerUserId,
        'createdAt': serializeStoredDateTime(
          DateTime.parse(row['created_at'] as String).toLocal(),
        ),
        'lastModifiedAt': serializeStoredDateTime(
          DateTime.parse(row['updated_at'] as String).toLocal(),
        ),
        'deletedAt': serializeStoredDateTime(_parseDateTime(row['deleted_at'])),
        'lastSyncedAt': serializeStoredDateTime(DateTime.now()),
        'version': remoteVersion,
        'syncStatusKey': SyncStatusKeys.synced,
        'lastModifiedByDeviceId': row['last_modified_by_device_id'] as String?,
        'rawJsonPayload': row['raw_json'] as String? ?? '{}',
      };
      await _store.putRecord(WebStoreNames.templates, row['id'] as String, doc);
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
      if (existing != null &&
          _isPendingLocalConflict(existing.syncStatus) &&
          existing.version > remoteVersion) {
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
      final existing = await _store.getRecord(
        WebStoreNames.workoutLogs,
        row['id'] as String,
      );
      final remoteVersion = row['version'] as int? ?? 1;
      if (_shouldMarkConflict(existing, row)) {
        await _markDocConflict(WebStoreNames.workoutLogs, 'logId', existing!);
        continue;
      }
      if (_shouldKeepLocal(existing, remoteVersion)) continue;
      if (existing != null &&
          !_isPendingLocalConflict(existing['syncStatusKey'] as String?) &&
          (existing['version'] as int? ?? 0) > remoteVersion) {
        continue;
      }

      final doc = <String, dynamic>{
        'logId': row['id'] as String,
        'instanceId': row['instance_id'] as String,
        'workoutId': row['workout_id'] as String,
        'workoutName': row['workout_name'] as String? ?? '',
        'ownerUserId': ownerUserId,
        'rawJsonPayload': row['raw_json'] as String? ?? '{}',
        'completedAt': serializeStoredDateTime(
          DateTime.parse(row['completed_at'] as String).toLocal(),
        ),
        'deletedAt': serializeStoredDateTime(_parseDateTime(row['deleted_at'])),
        'lastSyncedAt': serializeStoredDateTime(DateTime.now()),
        'version': remoteVersion,
        'syncStatusKey': SyncStatusKeys.synced,
        'lastModifiedByDeviceId': row['last_modified_by_device_id'] as String?,
      };
      await _store.putRecord(
        WebStoreNames.workoutLogs,
        row['id'] as String,
        doc,
      );
    }
  }

  Future<void> _mergeBodyMetrics(
    List<Map<String, dynamic>> rows,
    String ownerUserId,
  ) async {
    for (final row in rows) {
      final existing = await _store.getRecord(
        WebStoreNames.bodyMetrics,
        row['id'] as String,
      );
      final remoteVersion = row['version'] as int? ?? 1;
      if (_shouldMarkConflict(existing, row)) {
        await _markDocConflict(
          WebStoreNames.bodyMetrics,
          'metricId',
          existing!,
        );
        continue;
      }
      if (_shouldKeepLocal(existing, remoteVersion)) continue;
      if (existing != null &&
          !_isPendingLocalConflict(existing['syncStatusKey'] as String?) &&
          (existing['version'] as int? ?? 0) > remoteVersion) {
        continue;
      }
      final doc = <String, dynamic>{
        'metricId': row['id'] as String,
        'ownerUserId': ownerUserId,
        'timestamp': serializeStoredDateTime(
          DateTime.parse(row['timestamp'] as String).toLocal(),
        ),
        'weightKg': (row['weight_kg'] as num?)?.toDouble(),
        'bodyFatPercent': (row['body_fat_percent'] as num?)?.toDouble(),
        'waistCm': (row['waist_cm'] as num?)?.toDouble(),
        'note': row['note'] as String?,
        'deletedAt': serializeStoredDateTime(_parseDateTime(row['deleted_at'])),
        'lastSyncedAt': serializeStoredDateTime(DateTime.now()),
        'version': remoteVersion,
        'syncStatusKey': SyncStatusKeys.synced,
        'lastModifiedByDeviceId': row['last_modified_by_device_id'] as String?,
      };
      await _store.putRecord(
        WebStoreNames.bodyMetrics,
        row['id'] as String,
        doc,
      );
    }
  }

  Future<void> _mergeProgressPhotos(
    List<Map<String, dynamic>> rows,
    String ownerUserId,
  ) async {
    for (final row in rows) {
      final existing = await _store.getRecord(
        WebStoreNames.progressPhotos,
        row['id'] as String,
      );
      final remoteVersion = row['version'] as int? ?? 1;
      if (_shouldMarkConflict(existing, row)) {
        await _markDocConflict(
          WebStoreNames.progressPhotos,
          'photoId',
          existing!,
        );
        continue;
      }
      if (_shouldKeepLocal(existing, remoteVersion)) continue;
      if (existing != null &&
          !_isPendingLocalConflict(existing['syncStatusKey'] as String?) &&
          (existing['version'] as int? ?? 0) > remoteVersion) {
        continue;
      }

      final storagePath = row['storage_path'] as String? ?? '';
      var localFilePath = existing?['filePath'] as String? ?? '';
      if (_parseDateTime(row['deleted_at']) == null &&
          !localFilePath.startsWith('data:image/')) {
        localFilePath = await _remoteRepository.downloadProgressPhotoToLocal(
          row['id'] as String,
        );
      }
      final doc = <String, dynamic>{
        'photoId': row['id'] as String,
        'ownerUserId': ownerUserId,
        'timestamp': serializeStoredDateTime(
          DateTime.parse(
            (row['captured_at'] ?? row['created_at']) as String,
          ).toLocal(),
        ),
        'filePath': localFilePath.isEmpty ? storagePath : localFilePath,
        'label': row['label'] as String?,
        'metadataJson': row['metadata_json'] as String?,
        'deletedAt': serializeStoredDateTime(_parseDateTime(row['deleted_at'])),
        'lastSyncedAt': serializeStoredDateTime(DateTime.now()),
        'version': remoteVersion,
        'syncStatusKey': SyncStatusKeys.synced,
        'lastModifiedByDeviceId': row['last_modified_by_device_id'] as String?,
      };
      await _store.putRecord(
        WebStoreNames.progressPhotos,
        row['id'] as String,
        doc,
      );
    }
  }

  Future<void> _markDocSynced(
    String storeName,
    String keyField,
    Map<String, dynamic> doc,
  ) async {
    doc['syncStatusKey'] = SyncStatusKeys.synced;
    doc['lastSyncedAt'] = serializeStoredDateTime(DateTime.now());
    await _store.putRecord(storeName, doc[keyField] as String, doc);
  }

  Future<void> _markDocConflict(
    String storeName,
    String keyField,
    Map<String, dynamic> doc,
  ) async {
    doc['syncStatusKey'] = SyncStatusKeys.conflict;
    await _store.putRecord(storeName, doc[keyField] as String, doc);
  }

  Future<void> _markQueueDocConflict(Map<String, dynamic> item) async {
    final entityId = item['entityId'] as String;
    switch (item['entityType']) {
      case SyncEntityTypes.template:
        final doc = await _store.getRecord(WebStoreNames.templates, entityId);
        if (doc != null) {
          await _markDocConflict(WebStoreNames.templates, 'templateId', doc);
        }
        break;
      case SyncEntityTypes.instance:
        final instance = await _databaseRepository.fetchInstance(entityId);
        if (instance != null) {
          await _databaseRepository.saveRemoteInstance(
            instance.copyWith(syncStatus: SyncStatusKeys.conflict),
          );
        }
        break;
      case SyncEntityTypes.workoutLog:
        final doc = await _store.getRecord(WebStoreNames.workoutLogs, entityId);
        if (doc != null) {
          await _markDocConflict(WebStoreNames.workoutLogs, 'logId', doc);
        }
        break;
      case SyncEntityTypes.bodyMetric:
        final doc = await _store.getRecord(WebStoreNames.bodyMetrics, entityId);
        if (doc != null) {
          await _markDocConflict(WebStoreNames.bodyMetrics, 'metricId', doc);
        }
        break;
      case SyncEntityTypes.progressPhoto:
        final doc = await _store.getRecord(
          WebStoreNames.progressPhotos,
          entityId,
        );
        if (doc != null) {
          await _markDocConflict(WebStoreNames.progressPhotos, 'photoId', doc);
        }
        break;
    }
  }

  bool _shouldMarkConflict(
    Map<String, dynamic>? existing,
    Map<String, dynamic> row,
  ) {
    if (existing == null ||
        !_isPendingLocalConflict(existing['syncStatusKey'] as String?)) {
      return false;
    }
    final localVersion = existing['version'] as int? ?? 0;
    final remoteVersion = row['version'] as int? ?? 0;
    if (remoteVersion < localVersion) return false;
    final localDeviceId = existing['lastModifiedByDeviceId'] as String?;
    final remoteDeviceId = row['last_modified_by_device_id'] as String?;
    return !(remoteVersion == localVersion &&
        localDeviceId != null &&
        localDeviceId.isNotEmpty &&
        localDeviceId == remoteDeviceId);
  }

  bool _shouldKeepLocal(Map<String, dynamic>? existing, int remoteVersion) {
    return existing != null &&
        _isPendingLocalConflict(existing['syncStatusKey'] as String?) &&
        (existing['version'] as int? ?? 0) > remoteVersion;
  }

  bool _shouldMarkInstanceConflict(
    StoredTrainingInstance? existing,
    Map<String, dynamic> row,
  ) {
    if (existing == null || !_isPendingLocalConflict(existing.syncStatus)) {
      return false;
    }
    final remoteVersion = row['version'] as int? ?? 0;
    if (remoteVersion < existing.version) return false;
    final remoteDeviceId = row['last_modified_by_device_id'] as String?;
    return !(remoteVersion == existing.version &&
        existing.lastModifiedByDeviceId != null &&
        existing.lastModifiedByDeviceId!.isNotEmpty &&
        existing.lastModifiedByDeviceId == remoteDeviceId);
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
