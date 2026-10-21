import 'package:fittin_v2/src/application/active_session_provider.dart';
import 'package:fittin_v2/src/application/user_content_provider.dart';
import 'package:fittin_v2/src/domain/models/cardio.dart';
import 'package:fittin_v2/src/presentation/screens/cardio_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/in_memory_database_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'record editor exposes total time and validates moving time against it',
    (tester) async {
      final activity = BuiltInCardioActivities.byId('cardio:running');
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            databaseRepositoryProvider.overrideWithValue(
              InMemoryDatabaseRepository(),
            ),
          ],
          child: MaterialApp(
            home: CardioRecordEditorScreen(
              activity: activity,
              existing: CardioRecord(
                id: 'cardio-record:elapsed-test',
                activityTypeId: activity.id,
                activityName: 'Running',
                startedAt: DateTime(2026, 10, 21),
                metrics: const {
                  CardioMetricKey.durationSeconds: 1200,
                  CardioMetricKey.distanceMeters: 3000,
                },
                elapsedSeconds: 1800,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const ValueKey('cardio-field-durationSeconds')),
        '40',
      );
      final form = tester.state<FormState>(find.byType(Form));
      expect(form.validate(), isFalse);
      await tester.pump();
      expect(
        find.text('Elapsed time cannot be shorter than moving time'),
        findsOneWidget,
      );
      final elapsed = find.byKey(const ValueKey('cardio-field-elapsedSeconds'));
      await tester.ensureVisible(elapsed);
      await tester.enterText(elapsed, '45');
      expect(form.validate(), isTrue);
      await tester.pump();
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('cardio hub adapts activity library at 320px without overflow', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(320, 568));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseRepositoryProvider.overrideWithValue(
            InMemoryDatabaseRepository(),
          ),
          cardioActivityLibraryProvider.overrideWith(
            (ref) async => BuiltInCardioActivities.all,
          ),
          cardioRecordsProvider.overrideWith((ref) async => const []),
        ],
        child: const MaterialApp(home: CardioHubScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Record cardio'), findsOneWidget);
    expect(find.text('Running'), findsOneWidget);
    expect(find.text('Incline walking'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('incline editor rejects an out-of-range incline locally', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final activity = BuiltInCardioActivities.byId('cardio:incline-walking');
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseRepositoryProvider.overrideWithValue(
            InMemoryDatabaseRepository(),
          ),
        ],
        child: MaterialApp(home: CardioRecordEditorScreen(activity: activity)),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Duration'), findsOneWidget);
    expect(find.text('Average speed'), findsOneWidget);
    expect(find.text('Incline'), findsOneWidget);
    expect(find.text('durationSeconds'), findsNothing);
    expect(find.text('averageSpeedMps'), findsNothing);

    await tester.enterText(
      find.byKey(const ValueKey('cardio-field-durationSeconds')),
      '30',
    );
    await tester.enterText(
      find.byKey(const ValueKey('cardio-field-averageSpeedMps')),
      '5.5',
    );
    await tester.enterText(
      find.byKey(const ValueKey('cardio-field-inclinePercent')),
      '41',
    );
    final saveButton = find.text('Save cardio record');
    await tester.drag(find.byType(ListView), const Offset(0, -720));
    await tester.pumpAndSettle();
    await tester.tap(saveButton);
    await tester.pumpAndSettle();

    expect(find.text('Value is out of range'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
