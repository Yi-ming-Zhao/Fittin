@TestOn('browser')
library;

import 'package:fittin_v2/src/data/cardio_recording_store.dart';
import 'package:fittin_v2/src/data/cardio_recording_store_web.dart';
import 'package:fittin_v2/src/data/web_local_store.dart';
import 'package:fittin_v2/src/domain/models/cardio_recording.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('cloud restore nested checkpoint rolls back all route chunks', () async {
    final db = await WebLocalStore.open(
      databaseName: 'cardio_restore_${DateTime.now().microsecondsSinceEpoch}',
    );
    addTearDown(db.close);
    final local = CardioRecordingStore(WebCardioLocalDocuments(db));
    final session = CardioRecordingSession(
      id: 'cardio-record:11111111-1111-4111-8111-111111111111',
      ownerUserId: 'alice',
      sport: CardioSport.running,
      startedAt: DateTime.utc(2026),
      phase: CardioRecordingPhase.finished,
      activityTypeId: 'cardio:running',
      activityName: 'Synthetic route',
    );
    final points = List.generate(
      1001,
      (i) => RoutePoint(
        latitude: 30,
        longitude: 120,
        timestamp: session.startedAt.add(Duration(seconds: i)),
      ),
    );
    Future<void> restore({required bool fail}) =>
        local.documents.transaction(() async {
          expect(await local.read(session.id, ownerUserId: 'alice'), isNull);
          await local.checkpoint(
            session,
            expectedRevision: 0,
            batchId: 'cloud:1',
            points: points,
          );
          if (fail) throw StateError('Injected interruption');
        });
    await expectLater(restore(fail: true), throwsStateError);
    expect(await db.getAllRecords(WebStoreNames.cardioLocal), isEmpty);
    await restore(fail: false);
    expect((await local.read(session.id, ownerUserId: 'alice'))?.chunkCount, 3);
    expect(
      (await local.route(session.id, ownerUserId: 'alice').toList())
          .expand((p) => p)
          .length,
      1001,
    );
    expect(await local.read(session.id, ownerUserId: 'bob'), isNull);
  });
}
