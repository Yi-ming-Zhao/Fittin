import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fittin_v2/src/application/active_session_provider.dart';
import 'package:fittin_v2/src/data/database_repository.dart';

import '../support/fake_today_workout_gateway.dart';
import '../support/in_memory_database_repository.dart';

void main() {
  test('active session hydrates and persists drafts', () async {
    final repository = InMemoryDatabaseRepository();
    final gateway = FakeTodayWorkoutGateway();

    await repository.saveInstance(
      StoredTrainingInstance(
        instanceId: fakeWorkoutSessionState.instanceId,
        templateId: fakeWorkoutSessionState.templateId,
        currentWorkoutIndex: 0,
        states: const [],
      ),
    );
    await repository.saveActiveInstanceId(fakeWorkoutSessionState.instanceId);
    await repository.saveActiveSessionDraft(
      fakeWorkoutSessionState.copyWith(
        exercises: [
          fakeWorkoutSessionState.exercises.first.copyWith(
            sets: [
              fakeWorkoutSessionState.exercises.first.sets.first.copyWith(
                completedReps: 7,
              ),
              fakeWorkoutSessionState.exercises.first.sets[1],
            ],
          ),
          fakeWorkoutSessionState.exercises[1],
        ],
      ),
    );

    final container = ProviderContainer(
      overrides: [
        databaseRepositoryProvider.overrideWithValue(repository),
        todayWorkoutGatewayProvider.overrideWithValue(gateway),
      ],
    );
    addTearDown(container.dispose);

    await container.read(activeSessionProvider.notifier).startOrResumeSession();

    expect(gateway.sessionLoadCount, 0);
    expect(
      container
          .read(activeSessionProvider)
          .activeWorkout
          ?.exercises
          .first
          .sets
          .first
          .completedReps,
      7,
    );

    container.read(activeSessionProvider.notifier).updateReps(0, 8);
    final savedDraft = await repository.fetchActiveSessionDraft(
      fakeWorkoutSessionState.instanceId,
    );
    expect(savedDraft?.exercises.first.sets.first.completedReps, 8);
  });
}
