import 'package:fittin_v2/src/application/active_session_provider.dart';
import 'package:fittin_v2/src/application/auth_provider.dart';
import 'package:fittin_v2/src/application/user_content_provider.dart';
import 'package:fittin_v2/src/domain/models/cardio.dart';
import 'package:fittin_v2/src/domain/models/user_content.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/in_memory_database_repository.dart';

void main() {
  test(
    'confirmed cardio import commits records and source receipt together',
    () async {
      final repository = InMemoryDatabaseRepository();
      final container = ProviderContainer(
        overrides: [
          databaseRepositoryProvider.overrideWithValue(repository),
          currentUserIdProvider.overrideWithValue('user-123'),
        ],
      );
      addTearDown(container.dispose);
      final fingerprint = List.filled(64, 'b').join();
      final record = CardioRecord(
        id: 'cardio-record:import:$fingerprint:0',
        activityTypeId: 'cardio:running',
        activityName: 'Running',
        startedAt: DateTime(2026, 9, 4, 7),
        metrics: const {
          CardioMetricKey.durationSeconds: 1800,
          CardioMetricKey.distanceMeters: 5000,
        },
        source: 'gpx',
        sourceFingerprint: fingerprint,
      );
      final preview = CardioImportPreview(
        sourceName: 'run.gpx',
        sourceFingerprint: fingerprint,
        records: [record],
        warnings: const [],
        duplicateRecordIds: const {},
      );

      await container
          .read(userContentServiceProvider)
          .saveCardioImport(preview);

      final records = await repository.fetchUserContents(
        UserContentKind.cardioRecord,
        ownerUserId: 'user-123',
      );
      final receipts = await repository.fetchUserContents(
        UserContentKind.cardioImportFingerprint,
        ownerUserId: 'user-123',
      );
      expect(records.map((document) => document.id), [record.id]);
      expect(receipts.single.payload['fingerprint'], fingerprint);
      expect(receipts.single.payload['recordIds'], [record.id]);

      await expectLater(
        container.read(userContentServiceProvider).saveCardioImport(preview),
        throwsStateError,
      );
      expect(
        await repository.fetchUserContents(
          UserContentKind.cardioRecord,
          ownerUserId: 'user-123',
        ),
        hasLength(1),
      );
    },
  );
}
