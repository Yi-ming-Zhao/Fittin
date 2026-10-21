import 'package:fittin_v2/src/data/cardio_recording_store.dart';
import 'package:fittin_v2/src/data/cardio_recording_store_native.dart';
import 'package:fittin_v2/src/data/models/sync_queue_collection.dart';
import 'package:fittin_v2/src/domain/models/cardio_recording.dart';
import 'package:flutter_test/flutter_test.dart';
import '../support/isar_test_helper.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test(
    'delayed buffered checkpoints split chunks atomically and retry once',
    () async {
      final db = await openTestIsar('cardio_buffered');
      addTearDown(() async {
        await db.isar.close(deleteFromDisk: true);
        await db.directory.delete(recursive: true);
      });
      final docs = IsarCardioLocalDocuments(db.isar);
      final store = CardioRecordingStore(docs);
      final session = CardioRecordingSession(
        id: 'buffered',
        ownerUserId: 'alice',
        sport: CardioSport.running,
        startedAt: DateTime.utc(2026),
        phase: CardioRecordingPhase.recording,
      );
      final points = List.generate(
        1001,
        (i) => RoutePoint(
          latitude: 30,
          longitude: 120,
          timestamp: DateTime.utc(2026).add(Duration(seconds: i)),
          accuracyMeters: 5,
        ),
      );
      await expectLater(
        CardioRecordingStore(_FailingDocuments(docs)).checkpoint(
          session,
          expectedRevision: 0,
          batchId: 'buffer',
          points: points,
        ),
        throwsStateError,
      );
      expect(await docs.list('route/'), isEmpty);
      expect(await store.read(session.id, ownerUserId: 'alice'), isNull);
      final saved = await store.checkpoint(
        session,
        expectedRevision: 0,
        batchId: 'buffer',
        points: points,
      );
      expect(saved.revision, 1);
      expect(saved.chunkCount, 3);
      final retried = await store.checkpoint(
        session,
        expectedRevision: 0,
        batchId: 'buffer',
        points: points,
      );
      expect(retried.revision, 1);
      final chunks = await store
          .route(session.id, ownerUserId: 'alice')
          .toList();
      expect(chunks.map((chunk) => chunk.length), [500, 500, 1]);
    },
  );
  test(
    'native checkpoint and route are atomic, private, isolated and idempotent',
    () async {
      final db = await openTestIsar('cardio_local');
      addTearDown(() async {
        await db.isar.close(deleteFromDisk: true);
        await db.directory.delete(recursive: true);
      });
      final docs = IsarCardioLocalDocuments(db.isar);
      final store = CardioRecordingStore(docs);
      final session = CardioRecordingSession(
        id: 'run/1',
        ownerUserId: 'alice',
        sport: CardioSport.running,
        startedAt: DateTime.utc(2026),
      );
      final recorder = CardioRecorder(session)..start();
      recorder.advance(const Duration(seconds: 1));
      final point = RoutePoint(
        latitude: 30,
        longitude: 120,
        timestamp: DateTime.utc(2026),
        accuracyMeters: 5,
      );
      recorder.accept(point);
      final points = recorder.drainPoints();
      final first = await store.checkpoint(
        session,
        expectedRevision: 0,
        batchId: 'one',
        points: points,
      );
      expect(first.revision, 1);
      final retry = await store.checkpoint(
        session,
        expectedRevision: 0,
        batchId: 'one',
        points: points,
      );
      expect(retry.revision, 1);
      expect(
        await store.route(session.id, ownerUserId: 'alice').toList(),
        hasLength(1),
      );
      expect(await store.read(session.id, ownerUserId: 'bob'), isNull);
      expect(await store.list(ownerUserId: null), isEmpty);
      expect(await db.isar.syncQueueCollections.count(), 0);
      await expectLater(
        store.checkpoint(
          session,
          expectedRevision: 0,
          batchId: 'stale',
          points: points,
        ),
        throwsA(isA<CardioRecordingConflict>()),
      );
      expect(
        (await store.read(session.id, ownerUserId: 'alice'))!.chunkCount,
        1,
      );

      final failing = CardioRecordingStore(_FailingDocuments(docs));
      await expectLater(
        failing.checkpoint(
          session,
          expectedRevision: 1,
          batchId: 'two',
          points: points,
        ),
        throwsStateError,
      );
      expect((await store.read(session.id, ownerUserId: 'alice'))!.revision, 1);
      expect(await docs.list('route/'), hasLength(1));

      final results = await Future.wait(
        ['a', 'b'].map((batch) async {
          try {
            await store.checkpoint(
              session,
              expectedRevision: 1,
              batchId: batch,
            );
            return true;
          } on CardioRecordingConflict {
            return false;
          }
        }),
      );
      expect(results.where((ok) => ok), hasLength(1));
      await expectLater(
        store.delete(session.id, ownerUserId: 'alice', expectedRevision: 1),
        throwsA(isA<CardioRecordingConflict>()),
      );
      await store.delete(session.id, ownerUserId: 'alice', expectedRevision: 2);
      expect(await store.read(session.id, ownerUserId: 'alice'), isNull);
      expect(await docs.list('route/'), isEmpty);
    },
  );
}

class _FailingDocuments implements CardioLocalDocuments {
  _FailingDocuments(this.delegate);
  final CardioLocalDocuments delegate;
  @override
  Future<T> transaction<T>(Future<T> Function() action) =>
      delegate.transaction(action);
  @override
  Future<Map<String, dynamic>?> read(String key) => delegate.read(key);
  @override
  Future<void> delete(String key) => delegate.delete(key);
  @override
  Future<List<Map<String, dynamic>>> list(String prefix) =>
      delegate.list(prefix);
  @override
  Future<void> put(String key, Map<String, dynamic> value) {
    if (key.startsWith('session/')) throw StateError('injected disk failure');
    return delegate.put(key, value);
  }
}
