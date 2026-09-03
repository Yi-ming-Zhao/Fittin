import 'package:fittin_v2/src/data/progress_repository.dart';
import 'package:fittin_v2/src/data/sync/sync_models.dart';
import 'package:fittin_v2/src/data/web_local_store.dart';
import 'package:fittin_v2/src/data/web_storage_models.dart';
import 'package:fittin_v2/src/domain/models/body_metric.dart';
import 'package:fittin_v2/src/domain/models/progress_photo.dart';

class WebProgressRepository extends ProgressRepository {
  WebProgressRepository(this.store);

  final WebLocalStore store;

  @override
  Future<void> saveBodyMetric(
    BodyMetric metric, {
    String? ownerUserId,
    String? syncStatus,
    String? deviceId,
  }) async {
    final existing = await store.getRecord(
      WebStoreNames.bodyMetrics,
      metric.metricId,
    );
    final resolvedOwnerUserId =
        existing?['ownerUserId'] as String? ?? ownerUserId;
    final resolvedSyncStatus =
        syncStatus ?? _defaultSyncStatus(resolvedOwnerUserId);
    final doc = <String, dynamic>{
      'metricId': metric.metricId,
      'timestamp': serializeStoredDateTime(metric.timestamp),
      'ownerUserId': resolvedOwnerUserId,
      'weightKg': metric.weightKg,
      'bodyFatPercent': metric.bodyFatPercent,
      'waistCm': metric.waistCm,
      'note': metric.note,
      'deletedAt': null,
      'lastSyncedAt': existing?['lastSyncedAt'],
      'version': (existing?['version'] as int? ?? 0) + 1,
      'syncStatusKey': resolvedSyncStatus,
      'lastModifiedByDeviceId': deviceId ?? existing?['lastModifiedByDeviceId'],
    };
    await store.putRecord(WebStoreNames.bodyMetrics, metric.metricId, doc);
    await _enqueueSync(
      entityType: SyncEntityTypes.bodyMetric,
      entityId: metric.metricId,
      ownerUserId: resolvedOwnerUserId,
      operationType: SyncOperationTypes.upsert,
      syncStatus: resolvedSyncStatus,
    );
  }

  @override
  Future<List<BodyMetric>> fetchBodyMetrics({String? ownerUserId}) async {
    final docs = await store.getAllRecords(WebStoreNames.bodyMetrics);
    final metrics = docs
        .where(
          (doc) =>
              parseStoredDateTime(doc['deletedAt']) == null &&
              doc['ownerUserId'] == ownerUserId,
        )
        .map(bodyMetricFromDoc)
        .toList();
    metrics.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return metrics;
  }

  @override
  Future<void> deleteBodyMetric(
    String metricId, {
    required String? ownerUserId,
  }) async {
    final existing = await store.getRecord(WebStoreNames.bodyMetrics, metricId);
    if (existing == null) {
      return;
    }
    if (existing['ownerUserId'] != ownerUserId) {
      throw StateError('Cannot delete a body metric owned by another user.');
    }
    existing['deletedAt'] = serializeStoredDateTime(DateTime.now());
    existing['version'] = (existing['version'] as int? ?? 0) + 1;
    existing['syncStatusKey'] = SyncStatusKeys.pendingDelete;
    await store.putRecord(WebStoreNames.bodyMetrics, metricId, existing);
    await _enqueueSync(
      entityType: SyncEntityTypes.bodyMetric,
      entityId: metricId,
      ownerUserId: existing['ownerUserId'] as String?,
      operationType: SyncOperationTypes.delete,
      syncStatus: existing['syncStatusKey'] as String,
    );
  }

  @override
  Future<void> saveProgressPhoto(
    ProgressPhoto photo, {
    String? ownerUserId,
    String? syncStatus,
    String? deviceId,
  }) async {
    final existing = await store.getRecord(
      WebStoreNames.progressPhotos,
      photo.photoId,
    );
    final resolvedOwnerUserId =
        existing?['ownerUserId'] as String? ?? ownerUserId;
    final resolvedSyncStatus =
        syncStatus ?? _defaultSyncStatus(resolvedOwnerUserId);
    final doc = <String, dynamic>{
      'photoId': photo.photoId,
      'timestamp': serializeStoredDateTime(photo.timestamp),
      'ownerUserId': resolvedOwnerUserId,
      'filePath': photo.filePath,
      'label': photo.label,
      'metadataJson': photo.metadataJson,
      'deletedAt': null,
      'lastSyncedAt': existing?['lastSyncedAt'],
      'version': (existing?['version'] as int? ?? 0) + 1,
      'syncStatusKey': resolvedSyncStatus,
      'lastModifiedByDeviceId': deviceId ?? existing?['lastModifiedByDeviceId'],
    };
    await store.putRecord(WebStoreNames.progressPhotos, photo.photoId, doc);
    await _enqueueSync(
      entityType: SyncEntityTypes.progressPhoto,
      entityId: photo.photoId,
      ownerUserId: resolvedOwnerUserId,
      operationType: SyncOperationTypes.upsert,
      syncStatus: resolvedSyncStatus,
    );
  }

  @override
  Future<List<ProgressPhoto>> fetchProgressPhotos({String? ownerUserId}) async {
    final docs = await store.getAllRecords(WebStoreNames.progressPhotos);
    final photos = docs
        .where(
          (doc) =>
              parseStoredDateTime(doc['deletedAt']) == null &&
              doc['ownerUserId'] == ownerUserId,
        )
        .map(progressPhotoFromDoc)
        .toList();
    photos.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return photos;
  }

  @override
  Future<void> deleteProgressPhoto(String photoId) async {
    final existing = await store.getRecord(
      WebStoreNames.progressPhotos,
      photoId,
    );
    if (existing == null) {
      return;
    }
    existing['deletedAt'] = serializeStoredDateTime(DateTime.now());
    existing['version'] = (existing['version'] as int? ?? 0) + 1;
    existing['syncStatusKey'] = SyncStatusKeys.pendingDelete;
    await store.putRecord(WebStoreNames.progressPhotos, photoId, existing);
    await _enqueueSync(
      entityType: SyncEntityTypes.progressPhoto,
      entityId: photoId,
      ownerUserId: existing['ownerUserId'] as String?,
      operationType: SyncOperationTypes.delete,
      syncStatus: existing['syncStatusKey'] as String,
    );
  }

  @override
  Future<void> claimLocalDataForUser(String ownerUserId) async {
    final metricDocs = await store.getAllRecords(WebStoreNames.bodyMetrics);
    for (final doc in metricDocs) {
      if (doc['ownerUserId'] != null) {
        continue;
      }
      doc['ownerUserId'] = ownerUserId;
      doc['syncStatusKey'] = SyncStatusKeys.pendingUpload;
      await store.putRecord(
        WebStoreNames.bodyMetrics,
        doc['metricId'] as String,
        doc,
      );
      await _enqueueSync(
        entityType: SyncEntityTypes.bodyMetric,
        entityId: doc['metricId'] as String,
        ownerUserId: ownerUserId,
        operationType: SyncOperationTypes.upsert,
        syncStatus: SyncStatusKeys.pendingUpload,
      );
    }

    final photoDocs = await store.getAllRecords(WebStoreNames.progressPhotos);
    for (final doc in photoDocs) {
      if (doc['ownerUserId'] != null) {
        continue;
      }
      doc['ownerUserId'] = ownerUserId;
      doc['syncStatusKey'] = SyncStatusKeys.pendingUpload;
      await store.putRecord(
        WebStoreNames.progressPhotos,
        doc['photoId'] as String,
        doc,
      );
      await _enqueueSync(
        entityType: SyncEntityTypes.progressPhoto,
        entityId: doc['photoId'] as String,
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
}
