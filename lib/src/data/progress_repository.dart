import 'package:isar/isar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fittin_v2/src/application/active_session_provider.dart';
import 'package:fittin_v2/src/data/models/body_metric_collection.dart';
import 'package:fittin_v2/src/data/models/sync_queue_collection.dart';
import 'package:fittin_v2/src/data/sync/sync_models.dart';
import 'package:fittin_v2/src/domain/models/body_metric.dart';
import 'package:fittin_v2/src/domain/models/progress_photo.dart';

final progressRepositoryProvider = Provider<ProgressRepository>((ref) {
  final isar = ref.watch(databaseRepositoryProvider).isar;
  if (isar == null) {
    throw StateError('Isar is not initialized');
  }
  return ProgressRepository(isar);
});

class ProgressRepository {
  final Isar _isar;

  ProgressRepository(this._isar);

  // ---------- Body Metrics ---------- //

  Future<void> saveBodyMetric(
    BodyMetric metric, {
    String? ownerUserId,
    String? syncStatus,
    String? deviceId,
  }) async {
    final collection = BodyMetricCollection()
      ..metricId = metric.metricId
      ..timestamp = metric.timestamp
      ..ownerUserId = ownerUserId
      ..weightKg = metric.weightKg
      ..bodyFatPercent = metric.bodyFatPercent
      ..waistCm = metric.waistCm
      ..note = metric.note
      ..deletedAt = null
      ..version = 1
      ..syncStatusKey = syncStatus ?? _defaultSyncStatus(ownerUserId)
      ..lastModifiedByDeviceId = deviceId;

    final existing = await _isar.bodyMetricCollections
        .filter()
        .metricIdEqualTo(metric.metricId)
        .findFirst();

    if (existing != null) {
      collection.id = existing.id;
      collection.ownerUserId = existing.ownerUserId ?? ownerUserId;
      collection.lastSyncedAt = existing.lastSyncedAt;
      collection.version = existing.version + 1;
      collection.syncStatusKey =
          syncStatus ?? _defaultSyncStatus(collection.ownerUserId);
      collection.lastModifiedByDeviceId =
          deviceId ?? existing.lastModifiedByDeviceId;
    }

    await _isar.writeTxn(() async {
      await _isar.bodyMetricCollections.put(collection);
    });
    await _enqueueSync(
      entityType: SyncEntityTypes.bodyMetric,
      entityId: metric.metricId,
      ownerUserId: collection.ownerUserId,
      operationType: SyncOperationTypes.upsert,
      syncStatus: collection.syncStatusKey,
    );
  }

  Future<List<BodyMetric>> fetchBodyMetrics({String? ownerUserId}) async {
    final collections = await _isar.bodyMetricCollections
        .where()
        .sortByTimestampDesc()
        .findAll();

    return collections
        .where((c) => c.deletedAt == null && c.ownerUserId == ownerUserId)
        .map(
          (c) => BodyMetric(
            metricId: c.metricId,
            timestamp: c.timestamp,
            weightKg: c.weightKg,
            bodyFatPercent: c.bodyFatPercent,
            waistCm: c.waistCm,
            note: c.note,
          ),
        )
        .toList();
  }

  Future<void> deleteBodyMetric(String metricId) async {
    final existing = await _isar.bodyMetricCollections
        .filter()
        .metricIdEqualTo(metricId)
        .findFirst();
    if (existing == null) {
      return;
    }
    existing.deletedAt = DateTime.now();
    existing.version = existing.version + 1;
    existing.syncStatusKey = SyncStatusKeys.pendingDelete;
    await _isar.writeTxn(() async {
      await _isar.bodyMetricCollections.put(existing);
    });
    await _enqueueSync(
      entityType: SyncEntityTypes.bodyMetric,
      entityId: metricId,
      ownerUserId: existing.ownerUserId,
      operationType: SyncOperationTypes.delete,
      syncStatus: existing.syncStatusKey,
    );
  }

  // ---------- Progress Photos ---------- //

  Future<void> saveProgressPhoto(
    ProgressPhoto photo, {
    String? ownerUserId,
    String? syncStatus,
    String? deviceId,
  }) async {
    final collection = ProgressPhotoCollection()
      ..photoId = photo.photoId
      ..timestamp = photo.timestamp
      ..ownerUserId = ownerUserId
      ..filePath = photo.filePath
      ..label = photo.label
      ..metadataJson = photo.metadataJson
      ..deletedAt = null
      ..version = 1
      ..syncStatusKey = syncStatus ?? _defaultSyncStatus(ownerUserId)
      ..lastModifiedByDeviceId = deviceId;

    final existing = await _isar.progressPhotoCollections
        .filter()
        .photoIdEqualTo(photo.photoId)
        .findFirst();

    if (existing != null) {
      collection.id = existing.id;
      collection.ownerUserId = existing.ownerUserId ?? ownerUserId;
      collection.lastSyncedAt = existing.lastSyncedAt;
      collection.version = existing.version + 1;
      collection.syncStatusKey =
          syncStatus ?? _defaultSyncStatus(collection.ownerUserId);
      collection.lastModifiedByDeviceId =
          deviceId ?? existing.lastModifiedByDeviceId;
    }

    await _isar.writeTxn(() async {
      await _isar.progressPhotoCollections.put(collection);
    });
    await _enqueueSync(
      entityType: SyncEntityTypes.progressPhoto,
      entityId: photo.photoId,
      ownerUserId: collection.ownerUserId,
      operationType: SyncOperationTypes.upsert,
      syncStatus: collection.syncStatusKey,
    );
  }

  Future<List<ProgressPhoto>> fetchProgressPhotos({String? ownerUserId}) async {
    final collections = await _isar.progressPhotoCollections
        .where()
        .sortByTimestampDesc()
        .findAll();

    return collections
        .where((c) => c.deletedAt == null && c.ownerUserId == ownerUserId)
        .map(
          (c) => ProgressPhoto(
            photoId: c.photoId,
            timestamp: c.timestamp,
            filePath: c.filePath,
            label: c.label,
            metadataJson: c.metadataJson,
          ),
        )
        .toList();
  }

  Future<void> deleteProgressPhoto(String photoId) async {
    final existing = await _isar.progressPhotoCollections
        .filter()
        .photoIdEqualTo(photoId)
        .findFirst();
    if (existing == null) {
      return;
    }
    existing.deletedAt = DateTime.now();
    existing.version = existing.version + 1;
    existing.syncStatusKey = SyncStatusKeys.pendingDelete;
    await _isar.writeTxn(() async {
      await _isar.progressPhotoCollections.put(existing);
    });
    await _enqueueSync(
      entityType: SyncEntityTypes.progressPhoto,
      entityId: photoId,
      ownerUserId: existing.ownerUserId,
      operationType: SyncOperationTypes.delete,
      syncStatus: existing.syncStatusKey,
    );
  }

  Future<void> claimLocalDataForUser(String ownerUserId) async {
    final claimedMetrics = <String>[];
    final claimedPhotos = <String>[];
    await _isar.writeTxn(() async {
      final metrics = await _isar.bodyMetricCollections.where().findAll();
      for (final metric in metrics) {
        if (metric.ownerUserId == null) {
          metric.ownerUserId = ownerUserId;
          metric.syncStatusKey = SyncStatusKeys.pendingUpload;
          await _isar.bodyMetricCollections.put(metric);
          claimedMetrics.add(metric.metricId);
        }
      }

      final photos = await _isar.progressPhotoCollections.where().findAll();
      for (final photo in photos) {
        if (photo.ownerUserId == null) {
          photo.ownerUserId = ownerUserId;
          photo.syncStatusKey = SyncStatusKeys.pendingUpload;
          await _isar.progressPhotoCollections.put(photo);
          claimedPhotos.add(photo.photoId);
        }
      }
    });

    for (final metricId in claimedMetrics) {
      await _enqueueSync(
        entityType: SyncEntityTypes.bodyMetric,
        entityId: metricId,
        ownerUserId: ownerUserId,
        operationType: SyncOperationTypes.upsert,
        syncStatus: SyncStatusKeys.pendingUpload,
      );
    }

    for (final photoId in claimedPhotos) {
      await _enqueueSync(
        entityType: SyncEntityTypes.progressPhoto,
        entityId: photoId,
        ownerUserId: ownerUserId,
        operationType: SyncOperationTypes.upsert,
        syncStatus: SyncStatusKeys.pendingUpload,
      );
    }
  }

  String _defaultSyncStatus(String? ownerUserId) {
    return ownerUserId == null
        ? SyncStatusKeys.localOnly
        : SyncStatusKeys.pendingUpload;
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
    final existing = await _isar.syncQueueCollections.getByQueueKey(queueKey);
    final queueItem = SyncQueueCollection()
      ..queueKey = queueKey
      ..ownerUserId = ownerUserId
      ..entityType = entityType
      ..entityId = entityId
      ..operationType = operationType
      ..createdAt = existing?.createdAt ?? DateTime.now()
      ..updatedAt = DateTime.now();
    await _isar.writeTxn(() async {
      await _isar.syncQueueCollections.putByQueueKey(queueItem);
    });
  }
}
