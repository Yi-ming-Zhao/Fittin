import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fittin_v2/src/application/active_session_provider.dart';
import 'package:fittin_v2/src/application/milestone_preferences_provider.dart';
import 'package:fittin_v2/src/presentation/screens/milestone_exercise_settings_screen.dart';

import '../support/in_memory_database_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('searches, persists selection, and resets to Big Three', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final notifier = MilestoneExercisePreferencesNotifier(loadPersisted: false);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseRepositoryProvider.overrideWithValue(
            InMemoryDatabaseRepository(),
          ),
          milestoneExercisePreferencesProvider.overrideWith((ref) => notifier),
        ],
        child: const MaterialApp(home: MilestoneExerciseSettingsScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(notifier.state.exerciseIds, defaultMilestoneExerciseIds);
    expect(find.text('3 selected'), findsOneWidget);

    await tester.enterText(
      find.byKey(const ValueKey('milestone-exercise-search')),
      'overhead press',
    );
    await tester.pump();
    final overheadTile = find.byKey(
      const ValueKey('milestone-exercise-overhead_press'),
    );
    expect(overheadTile, findsOneWidget);
    await tester.tap(overheadTile);
    await tester.pump();
    expect(notifier.state.exerciseIds, contains('overhead_press'));

    await tester.tap(find.byKey(const ValueKey('reset-milestone-exercises')));
    await tester.pump();
    expect(notifier.state.exerciseIds, defaultMilestoneExerciseIds);
    expect(tester.takeException(), isNull);
  });
}
