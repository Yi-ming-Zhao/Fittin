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
  if (isar != null) {
    return ProgressRepository(isar);
  }
  return InMemoryProgressRepository();
});

class ProgressRepository {
  final Isar? _isar;

  ProgressRepository([this._isar]);

  Isar get _database {
    final isar = _isar;
    if (isar == null) {
      throw StateError(
        'This progress repository instance is not backed by Isar.',
      );
    }
    return isar;
  }

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

    final existing = await _database.bodyMetricCollections
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

    await _database.writeTxn(() async {
      await _database.bodyMetricCollections.put(collection);
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
    final collections = await _database.bodyMetricCollections
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

  Future<void> deleteBodyMetric(
    String metricId, {
    required String? ownerUserId,
  }) async {
    final existing = await _database.bodyMetricCollections
        .filter()
        .metricIdEqualTo(metricId)
        .findFirst();
    if (existing == null) {
      return;
    }
    if (existing.ownerUserId != ownerUserId) {
      throw StateError('Cannot delete a body metric owned by another user.');
    }
    existing.deletedAt = DateTime.now();
    existing.version = existing.version + 1;
    existing.syncStatusKey = SyncStatusKeys.pendingDelete;
    await _database.writeTxn(() async {
      await _database.bodyMetricCollections.put(existing);
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

    final existing = await _database.progressPhotoCollections
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

    await _database.writeTxn(() async {
      await _database.progressPhotoCollections.put(collection);
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
    final collections = await _database.progressPhotoCollections
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
    final existing = await _database.progressPhotoCollections
        .filter()
        .photoIdEqualTo(photoId)
        .findFirst();
    if (existing == null) {
      return;
    }
    existing.deletedAt = DateTime.now();
    existing.version = existing.version + 1;
    existing.syncStatusKey = SyncStatusKeys.pendingDelete;
    await _database.writeTxn(() async {
      await _database.progressPhotoCollections.put(existing);
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
    await _database.writeTxn(() async {
      final metrics = await _database.bodyMetricCollections.where().findAll();
      for (final metric in metrics) {
        if (metric.ownerUserId == null) {
          metric.ownerUserId = ownerUserId;
          metric.syncStatusKey = SyncStatusKeys.pendingUpload;
          await _database.bodyMetricCollections.put(metric);
          claimedMetrics.add(metric.metricId);
        }
      }

      final photos = await _database.progressPhotoCollections.where().findAll();
      for (final photo in photos) {
        if (photo.ownerUserId == null) {
          photo.ownerUserId = ownerUserId;
          photo.syncStatusKey = SyncStatusKeys.pendingUpload;
          await _database.progressPhotoCollections.put(photo);
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
}

class InMemoryProgressRepository extends ProgressRepository {
  InMemoryProgressRepository() : super();

  final List<BodyMetric> _bodyMetrics = [];
  final List<ProgressPhoto> _progressPhotos = [];
  final Map<String, String?> _metricOwners = {};
  final Map<String, String?> _photoOwners = {};

  @override
  Future<void> saveBodyMetric(
    BodyMetric metric, {
    String? ownerUserId,
    String? syncStatus,
    String? deviceId,
  }) async {
    _bodyMetrics.removeWhere((item) => item.metricId == metric.metricId);
    _bodyMetrics.add(metric);
    _metricOwners[metric.metricId] = ownerUserId;
  }

  @override
  Future<List<BodyMetric>> fetchBodyMetrics({String? ownerUserId}) async {
    final metrics =
        _bodyMetrics
            .where((metric) => _metricOwners[metric.metricId] == ownerUserId)
            .toList()
          ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return metrics;
  }

  @override
  Future<void> deleteBodyMetric(
    String metricId, {
    required String? ownerUserId,
  }) async {
    if (!_metricOwners.containsKey(metricId)) {
      return;
    }
    if (_metricOwners[metricId] != ownerUserId) {
      throw StateError('Cannot delete a body metric owned by another user.');
    }
    _bodyMetrics.removeWhere((metric) => metric.metricId == metricId);
    _metricOwners.remove(metricId);
  }

  @override
  Future<void> saveProgressPhoto(
    ProgressPhoto photo, {
    String? ownerUserId,
    String? syncStatus,
    String? deviceId,
  }) async {
    _progressPhotos.removeWhere((item) => item.photoId == photo.photoId);
    _progressPhotos.add(photo);
    _photoOwners[photo.photoId] = ownerUserId;
  }

  @override
  Future<List<ProgressPhoto>> fetchProgressPhotos({String? ownerUserId}) async {
    final photos =
        _progressPhotos
            .where((photo) => _photoOwners[photo.photoId] == ownerUserId)
            .toList()
          ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return photos;
  }

  @override
  Future<void> deleteProgressPhoto(String photoId) async {
    _progressPhotos.removeWhere((photo) => photo.photoId == photoId);
    _photoOwners.remove(photoId);
  }

  @override
  Future<void> claimLocalDataForUser(String ownerUserId) async {
    for (final metric in _bodyMetrics) {
      _metricOwners[metric.metricId] ??= ownerUserId;
    }
    for (final photo in _progressPhotos) {
      _photoOwners[photo.photoId] ??= ownerUserId;
    }
  }
}
