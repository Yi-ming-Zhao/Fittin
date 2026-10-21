import 'dart:convert';
import 'package:fittin_v2/src/application/cardio_route_sync.dart';
import 'package:fittin_v2/src/data/cardio_recording_store.dart';
import 'package:fittin_v2/src/data/cardio_recording_store_native.dart';
import 'package:fittin_v2/src/domain/models/cardio_recording.dart';
import 'package:flutter_test/flutter_test.dart';
import '../support/isar_test_helper.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late CardioRecordingStore local;
  late _Remote remote;
  late CardioRouteSync service;
  var alive = true;
  const id = 'cardio-record:11111111-1111-4111-8111-111111111111';
  setUp(() async {
    final db = await openTestIsar('private_route_sync');
    addTearDown(() async {
      await db.isar.close(deleteFromDisk: true);
      await db.directory.delete(recursive: true);
    });
    local = CardioRecordingStore(IsarCardioLocalDocuments(db.isar));
    remote = _Remote();
    alive = true;
    service = CardioRouteSync(
      local: local,
      remote: remote,
      owner: 'alice',
      checkOwner: () {
        if (!alive) throw StateError('Account changed');
      },
    );
    final session = CardioRecordingSession(
      id: id,
      ownerUserId: 'alice',
      sport: CardioSport.running,
      startedAt: DateTime.utc(2026),
      phase: CardioRecordingPhase.finished,
      activityTypeId: 'cardio:running',
      activityName: 'Synthetic run',
      elapsedMilliseconds: 1200000,
      activeMilliseconds: 1100000,
      distanceMeters: 1000,
    );
    await local.checkpoint(
      session,
      expectedRevision: 0,
      batchId: 'synthetic',
      points: List.generate(
        1001,
        (i) => RoutePoint(
          latitude: 30,
          longitude: 120 + i * .00001,
          timestamp: DateTime.utc(2026).add(Duration(seconds: i)),
        ),
      ),
    );
  });

  test(
    'explicit upload is chunked; verified download and cloud deletion preserve local data',
    () async {
      expect(remote.chunks, isEmpty);
      await service.upload(
        id,
        expectedLocalRevision: 1,
        expectedCloudVersion: 0,
      );
      expect(remote.chunks.length, 3);
      expect(
        (remote.value!['session'] as Map).containsKey('ownerUserId'),
        isFalse,
      );
      await expectLater(
        service.download(id, expectedCloudVersion: 1),
        throwsA(isA<CardioRecordingConflict>()),
      );
      await local.delete(id, ownerUserId: 'alice', expectedRevision: 1);
      await service.download(id, expectedCloudVersion: 1);
      expect(
        (await local.route(id, ownerUserId: 'alice').toList())
            .expand((p) => p)
            .length,
        1001,
      );
      expect(await local.read(id, ownerUserId: 'bob'), isNull);
      await service.delete(id, expectedCloudVersion: 1);
      expect(remote.value, isNull);
      expect(await local.read(id, ownerUserId: 'alice'), isNotNull);
    },
  );

  test(
    'corrupted cloud chunk and changed cloud version never create a partial route',
    () async {
      await service.upload(
        id,
        expectedLocalRevision: 1,
        expectedCloudVersion: 0,
      );
      await local.delete(id, ownerUserId: 'alice', expectedRevision: 1);
      final hash = remote.chunks.keys.first;
      final original = remote.chunks[hash]!;
      remote.chunks[hash] = utf8.encode('{}');
      await expectLater(
        service.download(id, expectedCloudVersion: 1),
        throwsFormatException,
      );
      expect(await local.read(id, ownerUserId: 'alice'), isNull);
      remote.chunks[hash] = original;
      remote.onChunk = () {
        remote.value!['version'] = 2;
      };
      await expectLater(
        service.download(id, expectedCloudVersion: 1),
        throwsA(isA<CardioRecordingConflict>()),
      );
      expect(await local.read(id, ownerUserId: 'alice'), isNull);
    },
  );

  test(
    'stale local approval and owner changes prevent a cloud commit',
    () async {
      await expectLater(
        service.upload(id, expectedLocalRevision: 0, expectedCloudVersion: 0),
        throwsA(isA<CardioRecordingConflict>()),
      );
      expect(remote.chunks, isEmpty);
      remote.onUpload = () => alive = false;
      await expectLater(
        service.upload(id, expectedLocalRevision: 1, expectedCloudVersion: 0),
        throwsStateError,
      );
      expect(remote.value, isNull);
    },
  );

  test('deleted cloud manifest cannot restore a route', () async {
    remote.value = {'version': 2, 'deleted': true};
    await expectLater(
      service.download(id, expectedCloudVersion: 2),
      throwsA(isA<CardioRecordingConflict>()),
    );
    expect((await local.read(id, ownerUserId: 'alice'))?.revision, 1);
  });
}

class _Remote implements CardioRouteRemote {
  @override
  Future<Map<String, dynamic>> list({String? after}) async => {
    'items': [],
    'nextCursor': '',
  };
  Map<String, dynamic>? value;
  final chunks = <String, List<int>>{};
  void Function()? onChunk, onUpload;
  @override
  Future<Map<String, dynamic>?> manifest(String id) async =>
      value == null ? null : Map.of(value!);
  @override
  Future<List<int>> chunk(String id, String hash) async {
    onChunk?.call();
    return chunks[hash]!;
  }

  @override
  Future<void> uploadChunk(String id, String hash, String data) async {
    chunks[hash] = utf8.encode(data);
    onUpload?.call();
  }

  @override
  Future<Map<String, dynamic>> commit(
    String id,
    Map<String, dynamic> data,
  ) async {
    if (data['expectedVersion'] != (value?['version'] ?? 0)) {
      throw const CardioRecordingConflict();
    }
    value = {
      'version': (value?['version'] as int? ?? 0) + 1,
      'session': data['session'],
      'chunks': data['chunks'],
    };
    return value!;
  }

  @override
  Future<void> delete(String id, int version) async {
    if (value?['version'] != version) throw const CardioRecordingConflict();
    value = null;
    chunks.clear();
  }
}
