import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fittin_v2/src/application/active_session_provider.dart';
import 'package:fittin_v2/src/application/auth_provider.dart';
import 'package:fittin_v2/src/application/cardio_recording_provider.dart';
import 'package:fittin_v2/src/application/user_content_provider.dart';
import 'package:fittin_v2/src/application/cardio_import_service.dart';
import 'package:fittin_v2/src/application/cardio_route_export.dart';
import 'package:fittin_v2/src/data/database_repository.dart';
import 'package:fittin_v2/src/domain/models/cardio.dart';
import 'package:fittin_v2/src/domain/models/cardio_recording.dart';
import 'package:fittin_v2/src/domain/models/user_content.dart';
import '../support/isar_test_helper.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  for (final withRoute in [false, true]) {
    test('FIT summary and local session preserve explicit elapsed time '
        'with ${withRoute ? 'route' : 'laps only'}', () async {
      final db = await openTestIsar('cardio_import_elapsed_$withRoute');
      addTearDown(() async {
        await db.isar.close(deleteFromDisk: true);
        await db.directory.delete(recursive: true);
      });
      final repository = DatabaseRepository(db.isar);
      final container = ProviderContainer(
        overrides: [
          databaseRepositoryProvider.overrideWithValue(repository),
          currentUserIdProvider.overrideWithValue('alice'),
        ],
      );
      addTearDown(container.dispose);
      final record = CardioRecord(
        id: 'cardio-record:elapsed-import',
        activityTypeId: 'cardio:running',
        activityName: 'Running',
        startedAt: DateTime.utc(2026),
        metrics: const {
          CardioMetricKey.durationSeconds: 600,
          CardioMetricKey.distanceMeters: 1000,
        },
        elapsedSeconds: 900,
        source: 'fit',
      );
      await container
          .read(userContentServiceProvider)
          .saveCardioImport(
            CardioImportPreview(
              sourceName: 'paused.fit',
              sourceFingerprint: 'b' * 64,
              records: [record],
              warnings: [],
              duplicateRecordIds: {},
              routes: {
                if (withRoute)
                  record.id: [
                    for (final seconds in [0, 700])
                      RoutePoint(
                        latitude: 30 + seconds * .000001,
                        longitude: 120,
                        timestamp: record.startedAt.add(
                          Duration(seconds: seconds),
                        ),
                      ),
                  ],
              },
              laps: {
                record.id: const [
                  CardioLap(
                    distanceMeters: 1000,
                    activeMilliseconds: 600000,
                    endDistanceMeters: 1000,
                    automatic: true,
                  ),
                ],
              },
            ),
          );
      final summary = CardioRecord.fromJson(
        (await repository.fetchUserContents(
          UserContentKind.cardioRecord,
          ownerUserId: 'alice',
        )).single.payload,
      );
      final session =
          (await container
                  .read(cardioRecordingStoreProvider)
                  .read(record.id, ownerUserId: 'alice'))!
              .session;
      expect(summary.elapsedSeconds, 900);
      expect(summary.metric(CardioMetricKey.durationSeconds), 600);
      expect(summary.metric(CardioMetricKey.paceSecondsPerKm), 600);
      expect(session.elapsedMilliseconds, 900000);
      expect(session.activeMilliseconds, 600000);
      expect(session.paceSecondsPerKm, 600);
    });
  }
  test(
    'import route and summary commit together; invalid route rolls everything back',
    () async {
      final db = await openTestIsar('cardio_import_atomic');
      addTearDown(() async {
        await db.isar.close(deleteFromDisk: true);
        await db.directory.delete(recursive: true);
      });
      final repository = DatabaseRepository(db.isar);
      final container = ProviderContainer(
        overrides: [
          databaseRepositoryProvider.overrideWithValue(repository),
          currentUserIdProvider.overrideWithValue('alice'),
        ],
      );
      addTearDown(container.dispose);
      final local = container.read(cardioRecordingStoreProvider);
      for (final valid in [false, true]) {
        final record = CardioRecord(
          id: 'cardio-record:imported',
          activityTypeId: 'cardio:running',
          activityName: 'Running',
          startedAt: DateTime.utc(2026),
          metrics: const {
            CardioMetricKey.durationSeconds: 600,
            CardioMetricKey.distanceMeters: 1000,
          },
          source: 'gpx',
        );
        final preview = CardioImportPreview(
          sourceName: 'run.gpx',
          sourceFingerprint: 'a' * 64,
          records: [record],
          warnings: [],
          duplicateRecordIds: {},
          routes: {
            record.id: [
              for (var i = 0; i < 501; i++)
                RoutePoint(
                  latitude: !valid && i == 500 ? 100 : 30 + i * .000001,
                  longitude: 120,
                  timestamp: record.startedAt.add(Duration(seconds: i)),
                ),
            ],
          },
        );
        final saving = container
            .read(userContentServiceProvider)
            .saveCardioImport(preview);
        if (!valid) {
          await expectLater(saving, throwsFormatException);
          expect(
            await repository.fetchUserContents(
              UserContentKind.cardioRecord,
              ownerUserId: 'alice',
            ),
            isEmpty,
          );
          expect(
            await repository.fetchUserContents(
              UserContentKind.cardioImportFingerprint,
              ownerUserId: 'alice',
            ),
            isEmpty,
          );
          expect(await local.read(record.id, ownerUserId: 'alice'), isNull);
        } else {
          await saving;
          expect(
            (await local.read(record.id, ownerUserId: 'alice'))!.chunkCount,
            2,
          );
          expect(
            (await local.route(record.id, ownerUserId: 'alice').toList())
                .expand((e) => e),
            hasLength(501),
          );
          expect(await local.read(record.id, ownerUserId: 'bob'), isNull);
          final summary = (await repository.fetchUserContents(
            UserContentKind.cardioRecord,
            ownerUserId: 'alice',
          )).single;
          expect(summary.payload.toString(), isNot(contains('latitude')));
          expect(summary.payload.toString(), isNot(contains('route')));
          final exported = await exportCardioRouteGpx(
            local,
            record.id,
            ownerUserId: 'alice',
          );
          final restored = const CardioImportService().parse(
            fileName: 'roundtrip.gpx',
            bytes: exported,
            existingRecords: [],
          );
          expect(restored.routes[restored.records.single.id], hasLength(501));
          await expectLater(
            exportCardioRouteGpx(local, record.id, ownerUserId: 'bob'),
            throwsStateError,
          );
        }
      }
    },
  );
}
