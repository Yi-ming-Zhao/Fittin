import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fittin_v2/src/application/active_session_provider.dart';

import '../support/fake_today_workout_gateway.dart';

void main() {
  test(
    'preserves multi-exercise edits and concludes the whole workout',
    () async {
      final fakeGateway = FakeTodayWorkoutGateway();
      final container = ProviderContainer(
        overrides: [todayWorkoutGatewayProvider.overrideWithValue(fakeGateway)],
      );
      addTearDown(container.dispose);

      final notifier = container.read(activeSessionProvider.notifier);
      await notifier.startOrResumeSession();

      notifier.updateReps(1, 7);
      notifier.toggleSetComplete(1);
      notifier.selectExercise(1);
      notifier.updateWeight(0, 72.5);
      notifier.toggleSetComplete(0);
      notifier.selectExercise(0);

      final inProgress = container.read(activeSessionProvider).activeWorkout!;
      expect(inProgress.exercises.first.sets[1].completedReps, 7);
      expect(inProgress.exercises.first.sets[1].isCompleted, isTrue);
      expect(inProgress.exercises[1].sets.first.weight, 72.5);
      expect(inProgress.exercises[1].sets.first.isCompleted, isTrue);

      final didConclude = await notifier.concludeSession();
      expect(didConclude, isTrue);
      expect(fakeGateway.concludedSession, isNotNull);
      expect(fakeGateway.concludedSession!.exercises.length, 2);
      expect(
        fakeGateway.concludedSession!.exercises.first.sets[1].completedReps,
        7,
      );
      expect(
        fakeGateway.concludedSession!.exercises[1].sets.first.weight,
        72.5,
      );
      expect(container.read(activeSessionProvider).activeWorkout, isNull);
    },
  );
}
