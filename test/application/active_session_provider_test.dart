import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fittin_v2/src/application/active_session_provider.dart';
import 'package:fittin_v2/src/application/auth_provider.dart';
import 'package:fittin_v2/src/application/sync_provider.dart';
import 'package:fittin_v2/src/data/database_repository.dart';
import 'package:fittin_v2/src/domain/models/training_state.dart';

import '../support/fake_today_workout_gateway.dart';
import '../support/in_memory_database_repository.dart';

class _TrackingSyncController extends SyncController {
  _TrackingSyncController(super.ref);

  int recoveryCalls = 0;

  @override
  Future<void> synchronizeWithRecovery({bool hydrate = false}) async {
    recoveryCalls += 1;
  }
}

void main() {
  test(
    'active session auto-restores persisted drafts on provider init',
    () async {
      final repository = InMemoryDatabaseRepository();
      final gateway = FakeTodayWorkoutGateway();
      final persistedDraft = fakeWorkoutSessionState.copyWith(
        exercises: [
          fakeWorkoutSessionState.exercises.first.copyWith(
            sets: [
              fakeWorkoutSessionState.exercises.first.sets.first.copyWith(
                completedReps: 6,
                isCompleted: true,
              ),
              fakeWorkoutSessionState.exercises.first.sets[1],
            ],
          ),
          fakeWorkoutSessionState.exercises[1],
        ],
      );

      await repository.saveInstance(
        StoredTrainingInstance(
          instanceId: fakeWorkoutSessionState.instanceId,
          templateId: fakeWorkoutSessionState.templateId,
          currentWorkoutIndex: 0,
          states: const [],
        ),
      );
      await repository.saveActiveInstanceId(fakeWorkoutSessionState.instanceId);
      await repository.saveActiveSessionDraft(persistedDraft);

      final container = ProviderContainer(
        overrides: [
          databaseRepositoryProvider.overrideWithValue(repository),
          todayWorkoutGatewayProvider.overrideWithValue(gateway),
        ],
      );
      addTearDown(container.dispose);

      container.read(activeSessionProvider.notifier);
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

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
        6,
      );
      expect(
        container
            .read(activeSessionProvider)
            .activeWorkout
            ?.exercises
            .first
            .sets
            .first
            .isCompleted,
        true,
      );
    },
  );

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

  test(
    'active session supports set jumping, unit switching, and performed rpe',
    () async {
      final repository = InMemoryDatabaseRepository();
      final gateway = FakeTodayWorkoutGateway();
      final container = ProviderContainer(
        overrides: [
          databaseRepositoryProvider.overrideWithValue(repository),
          todayWorkoutGatewayProvider.overrideWithValue(gateway),
        ],
      );
      addTearDown(container.dispose);

      await container
          .read(activeSessionProvider.notifier)
          .startOrResumeSession();

      final notifier = container.read(activeSessionProvider.notifier);
      notifier.selectSet(1);
      notifier.switchExerciseDisplayUnit('lbs');
      notifier.updateWeightFromDisplayUnit(1, 225, displayUnit: 'lbs');
      notifier.updateCompletedRpe(1, 7.5);

      final workout = container.read(activeSessionProvider).activeWorkout!;
      final set = workout.exercises.first.sets[1];

      expect(workout.exercises.first.currentSetIndex, 1);
      expect(workout.exercises.first.displayLoadUnit, 'lbs');
      expect(set.completedRpe, 7.5);
      expect(set.weight, closeTo(102.058, 0.001));
    },
  );

  test('weight edits propagate forward through unresolved sets only', () async {
    final repository = InMemoryDatabaseRepository();
    final session = fakeWorkoutSessionState.copyWith(
      exercises: [
        fakeWorkoutSessionState.exercises.first.copyWith(
          sets: const [
            SessionSetState(
              id: 'set-0',
              role: 'working',
              targetReps: 5,
              completedReps: 5,
              targetWeight: 80,
              weight: 80,
              isCompleted: true,
            ),
            SessionSetState(
              id: 'set-1',
              role: 'working',
              targetReps: 5,
              completedReps: 5,
              targetWeight: 82.5,
              weight: 82.5,
            ),
            SessionSetState(
              id: 'set-2',
              role: 'working',
              targetReps: 5,
              completedReps: 5,
              targetWeight: 85,
              weight: 85,
            ),
            SessionSetState(
              id: 'set-3',
              role: 'working',
              targetReps: 5,
              completedReps: 5,
              targetWeight: 87.5,
              weight: 87.5,
              isSkipped: true,
            ),
          ],
        ),
        fakeWorkoutSessionState.exercises[1],
      ],
    );
    final gateway = FakeTodayWorkoutGateway(session: session);
    final container = ProviderContainer(
      overrides: [
        databaseRepositoryProvider.overrideWithValue(repository),
        todayWorkoutGatewayProvider.overrideWithValue(gateway),
      ],
    );
    addTearDown(container.dispose);

    await container.read(activeSessionProvider.notifier).startOrResumeSession();
    final notifier = container.read(activeSessionProvider.notifier);

    notifier.updateWeight(1, 90);
    var workout = container.read(activeSessionProvider).activeWorkout!;
    expect(workout.exercises.first.sets.map((set) => set.weight), [
      80,
      90,
      90,
      87.5,
    ]);
    expect(workout.exercises.first.sets.map((set) => set.targetWeight), [
      80,
      82.5,
      85,
      87.5,
    ]);
    expect(workout.exercises[1].sets.first.weight, 70);

    notifier.updateWeight(2, 92.5);
    workout = container.read(activeSessionProvider).activeWorkout!;
    expect(workout.exercises.first.sets.map((set) => set.weight), [
      80,
      90,
      92.5,
      87.5,
    ]);
  });

  test(
    'cancelled sets advance, persist, and remain incomplete on conclusion',
    () async {
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
      final container = ProviderContainer(
        overrides: [
          databaseRepositoryProvider.overrideWithValue(repository),
          todayWorkoutGatewayProvider.overrideWithValue(gateway),
        ],
      );
      addTearDown(container.dispose);

      await container
          .read(activeSessionProvider.notifier)
          .startOrResumeSession();
      container.read(activeSessionProvider.notifier).cancelSet(0);
      await Future<void>.delayed(Duration.zero);

      var workout = container.read(activeSessionProvider).activeWorkout!;
      expect(workout.exercises.first.sets.first.isSkipped, true);
      expect(workout.exercises.first.sets.first.isCompleted, false);
      expect(workout.exercises.first.currentSetIndex, 1);

      final restoredContainer = ProviderContainer(
        overrides: [
          databaseRepositoryProvider.overrideWithValue(repository),
          todayWorkoutGatewayProvider.overrideWithValue(gateway),
        ],
      );
      addTearDown(restoredContainer.dispose);
      restoredContainer.read(activeSessionProvider.notifier);
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      workout = restoredContainer.read(activeSessionProvider).activeWorkout!;
      expect(workout.exercises.first.sets.first.isSkipped, true);
      expect(workout.exercises.first.currentSetIndex, 1);

      final success = await restoredContainer
          .read(activeSessionProvider.notifier)
          .concludeSession();
      expect(success, true);
      expect(
        gateway.concludedSession!.exercises.first.sets.first.isCompleted,
        false,
      );
    },
  );

  test('concluding a signed-in workout triggers auto sync recovery', () async {
    final repository = InMemoryDatabaseRepository();
    final gateway = FakeTodayWorkoutGateway();
    _TrackingSyncController? tracker;
    final container = ProviderContainer(
      overrides: [
        databaseRepositoryProvider.overrideWithValue(repository),
        todayWorkoutGatewayProvider.overrideWithValue(gateway),
        currentUserIdProvider.overrideWithValue('signed-in-user'),
        syncControllerProvider.overrideWith((ref) {
          tracker = _TrackingSyncController(ref);
          return tracker!;
        }),
      ],
    );
    addTearDown(container.dispose);

    container.read(syncControllerProvider.notifier);
    await container.read(activeSessionProvider.notifier).startOrResumeSession();
    final success = await container
        .read(activeSessionProvider.notifier)
        .concludeSession();
    await Future<void>.delayed(Duration.zero);

    expect(success, true);
    expect(gateway.concludedSession, isNotNull);
    expect(tracker?.recoveryCalls, 1);
  });

  test('concluding a signed-out workout does not trigger auto sync', () async {
    final repository = InMemoryDatabaseRepository();
    final gateway = FakeTodayWorkoutGateway();
    _TrackingSyncController? tracker;
    final container = ProviderContainer(
      overrides: [
        databaseRepositoryProvider.overrideWithValue(repository),
        todayWorkoutGatewayProvider.overrideWithValue(gateway),
        currentUserIdProvider.overrideWithValue(null),
        syncControllerProvider.overrideWith((ref) {
          tracker = _TrackingSyncController(ref);
          return tracker!;
        }),
      ],
    );
    addTearDown(container.dispose);

    container.read(syncControllerProvider.notifier);
    await container.read(activeSessionProvider.notifier).startOrResumeSession();
    final success = await container
        .read(activeSessionProvider.notifier)
        .concludeSession();
    await Future<void>.delayed(Duration.zero);

    expect(success, true);
    expect(tracker?.recoveryCalls, 0);
  });
}
