import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fittin_v2/src/application/milestone_preferences_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('defaults to the canonical Big Three exercise IDs', () {
    final notifier = MilestoneExercisePreferencesNotifier(loadPersisted: false);

    expect(notifier.state.schemaVersion, 1);
    expect(notifier.state.exerciseIds, defaultMilestoneExerciseIds);
  });

  test('persists a versioned selection and restores it after reload', () async {
    final preferences = await SharedPreferences.getInstance();
    final notifier = MilestoneExercisePreferencesNotifier(
      preferences: preferences,
      loadPersisted: false,
    );

    await notifier.replace({'squat', 'overhead_press'});
    final restored = MilestoneExercisePreferencesNotifier(
      preferences: preferences,
    );
    await Future<void>.delayed(Duration.zero);

    expect(restored.state.exerciseIds, {'squat', 'overhead_press'});
    expect(
      preferences.getString(MilestoneExercisePreferencesNotifier.storageKey),
      contains('"schemaVersion":1'),
    );
  });

  test('reset restores Big Three after a custom selection', () async {
    final preferences = await SharedPreferences.getInstance();
    final notifier = MilestoneExercisePreferencesNotifier(
      preferences: preferences,
      loadPersisted: false,
    );

    await notifier.replace({'lat_pulldown'});
    await notifier.reset();

    expect(notifier.state.exerciseIds, defaultMilestoneExerciseIds);
  });

  test(
    'empty selection restores and persists the Big Three defaults',
    () async {
      final preferences = await SharedPreferences.getInstance();
      final notifier = MilestoneExercisePreferencesNotifier(
        preferences: preferences,
        loadPersisted: false,
      );

      await notifier.replace(const {});
      final restored = MilestoneExercisePreferencesNotifier(
        preferences: preferences,
      );
      await Future<void>.delayed(Duration.zero);

      expect(notifier.state.exerciseIds, defaultMilestoneExerciseIds);
      expect(restored.state.exerciseIds, defaultMilestoneExerciseIds);
    },
  );
}
