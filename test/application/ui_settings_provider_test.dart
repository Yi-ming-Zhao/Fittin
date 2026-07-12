import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fittin_v2/src/application/ui_settings_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'workout recording mode defaults to cards and persists updates',
    () async {
      SharedPreferences.setMockInitialValues({});
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(
        container.read(workoutRecordingModeProvider),
        WorkoutRecordingMode.card,
      );

      await container
          .read(workoutRecordingModeProvider.notifier)
          .update(WorkoutRecordingMode.traditional);
      expect(
        container.read(workoutRecordingModeProvider),
        WorkoutRecordingMode.traditional,
      );

      final restoredContainer = ProviderContainer();
      addTearDown(restoredContainer.dispose);
      restoredContainer.read(workoutRecordingModeProvider);
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      expect(
        restoredContainer.read(workoutRecordingModeProvider),
        WorkoutRecordingMode.traditional,
      );
    },
  );
}
