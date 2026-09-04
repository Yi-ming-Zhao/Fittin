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
