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
    if (ownerUserId == null || !_remoteRepository.isAvailable) {
      return;
    }

    await _databaseRepository.claimLocalDataForUser(ownerUserId);
    await _progressRepository.claimLocalDataForUser(ownerUserId);
    await _pushPending(ownerUserId);
    await _pullRemote(ownerUserId);
  }

  Future<void> _pushPending(String ownerUserId) async {
    final queue = await _isar.syncQueueCollections
        .filter()
        .ownerUserIdEqualTo(ownerUserId)
        .sortByCreatedAt()
        .findAll();

    for (final item in queue) {
      await _pushQueueItem(item, ownerUserId);
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
            if (collection.deletedAt != null) {
              await _remoteRepository.deleteById(
                table: 'plans',
                id: item.entityId,
              );
            } else {
              await _remoteRepository.upsertPlan(collection);
            }
            await _markTemplateSynced(collection);
          }
          break;
        }
      case SyncEntityTypes.instance:
        {
          final instance = await _databaseRepository.fetchInstance(
            item.entityId,
          );
          if (instance != null) {
            if (instance.deletedAt != null) {
              await _remoteRepository.deleteById(
                table: 'plan_instances',
                id: item.entityId,
              );
            } else {
              await _remoteRepository.upsertInstance(instance);
            }
            await _markInstanceSynced(item.entityId);
          }
          break;
        }
      case SyncEntityTypes.workoutLog:
        {
          final collection = await _isar.workoutLogCollections.getByLogId(
            item.entityId,
          );
          if (collection != null) {
            if (collection.deletedAt != null) {
              await _remoteRepository.deleteById(
                table: 'workout_logs',
                id: item.entityId,
              );
            } else {
              await _remoteRepository.upsertWorkoutLog(collection);
            }
            await _markWorkoutLogSynced(collection);
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
            if (collection.deletedAt != null) {
              await _remoteRepository.deleteById(
                table: 'body_metrics',
                id: item.entityId,
              );
            } else {
              await _remoteRepository.upsertBodyMetric(collection);
            }
            await _markBodyMetricSynced(collection);
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
            if (collection.deletedAt != null) {
              await _remoteRepository.deleteById(
                table: 'progress_photos',
                id: item.entityId,
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
            await _markProgressPhotoSynced(collection);
          }
          break;
        }
    }

    await _isar.writeTxn(() async {
      await _isar.syncQueueCollections.deleteByQueueKey(item.queueKey);
    });
  }

  Future<void> _pullRemote(String ownerUserId) async {
    final plans = await _remoteRepository.fetchRows(
      table: 'plans',
      userId: ownerUserId,
    );
    final instances = await _remoteRepository.fetchRows(
      table: 'plan_instances',
      userId: ownerUserId,
    );
    final logs = await _remoteRepository.fetchRows(
      table: 'workout_logs',
      userId: ownerUserId,
    );
    final metrics = await _remoteRepository.fetchRows(
      table: 'body_metrics',
      userId: ownerUserId,
    );

    await _mergePlans(plans, ownerUserId);
    await _mergeInstances(instances, ownerUserId);
    await _mergeWorkoutLogs(logs, ownerUserId);
    await _mergeBodyMetrics(metrics, ownerUserId);
  }

  Future<void> _mergePlans(
    List<Map<String, dynamic>> rows,
    String ownerUserId,
  ) async {
    for (final row in rows) {
      final existing = await _isar.templateCollections.getByTemplateId(
        row['id'] as String,
      );
      if (existing != null &&
          existing.syncStatusKey == SyncStatusKeys.pendingUpload &&
          existing.version > (row['version'] as int? ?? 0)) {
        existing.syncStatusKey = SyncStatusKeys.conflict;
        await _isar.writeTxn(() async {
          await _isar.templateCollections.putByTemplateId(existing);
        });
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
    for (final row in rows) {
      final existing = await _databaseRepository.fetchInstance(
        row['id'] as String,
      );
      final remoteVersion = row['version'] as int? ?? 1;
      if (existing != null &&
          existing.syncStatus == SyncStatusKeys.pendingUpload &&
          existing.version > remoteVersion) {
        await _databaseRepository.saveInstance(
          existing.copyWith(syncStatus: SyncStatusKeys.conflict),
          syncStatus: SyncStatusKeys.conflict,
        );
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
      await _databaseRepository.saveInstance(
        instance,
        syncStatus: SyncStatusKeys.synced,
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
      if (existing != null &&
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
      final existing = await _isar.bodyMetricCollections
          .filter()
          .metricIdEqualTo(metric.metricId)
          .findFirst();
      if (existing != null) {
        metric.id = existing.id;
      }
      await _isar.writeTxn(() async {
        await _isar.bodyMetricCollections.put(metric);
      });
    }
  }

  Future<void> _markTemplateSynced(TemplateCollection collection) async {
    collection.syncStatusKey = SyncStatusKeys.synced;
    collection.lastSyncedAt = DateTime.now();
    await _isar.writeTxn(() async {
      await _isar.templateCollections.putByTemplateId(collection);
    });
  }

  Future<void> _markInstanceSynced(String instanceId) async {
    final existing = await _databaseRepository.fetchInstance(instanceId);
    if (existing == null) {
      return;
    }
    await _databaseRepository.saveInstance(
      existing.copyWith(
        syncStatus: SyncStatusKeys.synced,
        lastSyncedAt: DateTime.now(),
      ),
      syncStatus: SyncStatusKeys.synced,
    );
  }

  Future<void> _markWorkoutLogSynced(WorkoutLogCollection collection) async {
    collection.syncStatusKey = SyncStatusKeys.synced;
    collection.lastSyncedAt = DateTime.now();
    await _isar.writeTxn(() async {
      await _isar.workoutLogCollections.putByLogId(collection);
    });
  }

  Future<void> _markBodyMetricSynced(BodyMetricCollection collection) async {
    collection.syncStatusKey = SyncStatusKeys.synced;
    collection.lastSyncedAt = DateTime.now();
    await _isar.writeTxn(() async {
      await _isar.bodyMetricCollections.put(collection);
    });
  }

  Future<void> _markProgressPhotoSynced(
    ProgressPhotoCollection collection,
  ) async {
    collection.syncStatusKey = SyncStatusKeys.synced;
    collection.lastSyncedAt = DateTime.now();
    await _isar.writeTxn(() async {
      await _isar.progressPhotoCollections.put(collection);
    });
  }

  DateTime? _parseDateTime(Object? value) {
    final stringValue = value as String?;
    return stringValue == null ? null : DateTime.parse(stringValue).toLocal();
  }
}
