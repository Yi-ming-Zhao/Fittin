import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:fittin_v2/src/data/models/body_metric_collection.dart';
import 'package:fittin_v2/src/data/models/sync_queue_collection.dart';
import 'package:fittin_v2/src/data/progress_repository.dart';
import 'package:fittin_v2/src/data/sync/sync_models.dart';
import 'package:fittin_v2/src/domain/models/body_metric.dart';
import 'package:fittin_v2/src/domain/models/progress_photo.dart';

import '../support/isar_test_helper.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Isar isar;
  late Directory directory;
  late ProgressRepository repository;

  setUp(() async {
    final testStore = await openTestIsar('progress_repository_test');
    isar = testStore.isar;
    directory = testStore.directory;
    repository = ProgressRepository(isar);
  });

  tearDown(() async {
    await isar.close(deleteFromDisk: true);
    if (await directory.exists()) {
      await directory.delete(recursive: true);
    }
  });

  test('claimLocalDataForUser migrates progress data and queues sync', () async {
    await repository.saveBodyMetric(
      BodyMetric(
        metricId: 'metric-local',
        timestamp: DateTime(2026, 3, 19, 10),
        weightKg: 82.5,
      ),
    );
    await repository.saveProgressPhoto(
      ProgressPhoto(
        photoId: 'photo-local',
        timestamp: DateTime(2026, 3, 19, 11),
        filePath: '/tmp/progress.jpg',
        label: 'Front',
      ),
    );

    await repository.claimLocalDataForUser('user-123');

    final metrics = await repository.fetchBodyMetrics(ownerUserId: 'user-123');
    final photos = await repository.fetchProgressPhotos(ownerUserId: 'user-123');
    final metricCollection = await isar.bodyMetricCollections
        .filter()
        .metricIdEqualTo('metric-local')
        .findFirst();
    final photoCollection = await isar.progressPhotoCollections
        .filter()
        .photoIdEqualTo('photo-local')
        .findFirst();
    final metricQueue = await isar.syncQueueCollections
        .getByQueueKey('${SyncEntityTypes.bodyMetric}:metric-local');
    final photoQueue = await isar.syncQueueCollections
        .getByQueueKey('${SyncEntityTypes.progressPhoto}:photo-local');

    expect(metrics, hasLength(1));
    expect(photos, hasLength(1));
    expect(metricCollection?.ownerUserId, 'user-123');
    expect(metricCollection?.syncStatusKey, SyncStatusKeys.pendingUpload);
    expect(photoCollection?.ownerUserId, 'user-123');
    expect(photoCollection?.syncStatusKey, SyncStatusKeys.pendingUpload);
    expect(metricQueue?.ownerUserId, 'user-123');
    expect(photoQueue?.ownerUserId, 'user-123');
  });

  test('deleteBodyMetric marks soft delete and keeps sync queue entry', () async {
    await repository.saveBodyMetric(
      BodyMetric(
        metricId: 'metric-delete',
        timestamp: DateTime(2026, 3, 19, 12),
        weightKg: 80,
      ),
      ownerUserId: 'user-123',
    );

    await repository.deleteBodyMetric('metric-delete');

    final visibleMetrics = await repository.fetchBodyMetrics(
      ownerUserId: 'user-123',
    );
    final collection = await isar.bodyMetricCollections
        .filter()
        .metricIdEqualTo('metric-delete')
        .findFirst();
    final queue = await isar.syncQueueCollections
        .getByQueueKey('${SyncEntityTypes.bodyMetric}:metric-delete');

    expect(visibleMetrics, isEmpty);
    expect(collection?.deletedAt, isNotNull);
    expect(collection?.syncStatusKey, SyncStatusKeys.pendingDelete);
    expect(queue?.operationType, SyncOperationTypes.delete);
  });
}
