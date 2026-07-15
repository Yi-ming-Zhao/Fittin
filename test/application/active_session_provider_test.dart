import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fittin_v2/src/application/active_session_provider.dart';
import 'package:fittin_v2/src/application/auth_provider.dart';
import 'package:fittin_v2/src/application/sync_provider.dart';
import 'package:fittin_v2/src/application/sync_refresh_provider.dart';
import 'package:fittin_v2/src/application/services/today_workout_gateway.dart';
import 'package:fittin_v2/src/data/database_repository.dart';
import 'package:fittin_v2/src/data/seeds/gzclp_seed.dart';
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

class _DelayedSessionGateway extends FakeTodayWorkoutGateway {
  final Completer<WorkoutSessionState> _sessionCompleter = Completer();
  int loadCalls = 0;

  @override
  Future<WorkoutSessionState> loadTodayWorkoutSession() {
    loadCalls += 1;
    return _sessionCompleter.future;
  }

  void completeSession([
    WorkoutSessionState session = fakeWorkoutSessionState,
  ]) {
    if (!_sessionCompleter.isCompleted) {
      _sessionCompleter.complete(session);
    }
  }
}

class _FailOnceSessionGateway extends FakeTodayWorkoutGateway {
  int loadCalls = 0;

  @override
  Future<WorkoutSessionState> loadTodayWorkoutSession() async {
    loadCalls += 1;
    if (loadCalls == 1) {
      throw StateError('temporary session read failure');
    }
    return super.loadTodayWorkoutSession();
  }
}

class _DelayedConclusionGateway extends FakeTodayWorkoutGateway {
  final Completer<void> _conclusionGate = Completer<void>();

  @override
  Future<void> concludeWorkoutSession(WorkoutSessionState session) async {
    await _conclusionGate.future;
    await super.concludeWorkoutSession(session);
  }

  void completeConclusion() {
    if (!_conclusionGate.isCompleted) {
      _conclusionGate.complete();
    }
  }
}

class _DelayedDraftRepository extends InMemoryDatabaseRepository {
  Completer<void>? _nextDraftSaveGate;

  Completer<void> delayNextDraftSave() {
    final gate = Completer<void>();
    _nextDraftSaveGate = gate;
    return gate;
  }

  @override
  Future<void> saveActiveSessionDraft(
    WorkoutSessionState draft, {
    String? ownerUserId,
  }) async {
    final gate = _nextDraftSaveGate;
    if (gate != null) {
      _nextDraftSaveGate = null;
      await gate.future;
    }
    await super.saveActiveSessionDraft(draft, ownerUserId: ownerUserId);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

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
    await _flushMicrotasks();
    final savedDraft = await repository.fetchActiveSessionDraft(
      fakeWorkoutSessionState.instanceId,
    );
    expect(savedDraft?.exercises.first.sets.first.completedReps, 8);
  });

  test('foreground start retries a failed background draft restore', () async {
    final repository = InMemoryDatabaseRepository();
    final gateway = _FailOnceSessionGateway();
    final persistedDraft = fakeWorkoutSessionState.copyWith(
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
    );
    await repository.saveInstance(
      StoredTrainingInstance(
        instanceId: persistedDraft.instanceId,
        templateId: persistedDraft.templateId,
        currentWorkoutIndex: 0,
        states: const [],
      ),
    );
    await repository.saveActiveInstanceId(persistedDraft.instanceId);
    await repository.saveActiveSessionDraft(persistedDraft);
    final container = ProviderContainer(
      overrides: [
        databaseRepositoryProvider.overrideWithValue(repository),
        todayWorkoutGatewayProvider.overrideWithValue(gateway),
      ],
    );
    addTearDown(container.dispose);

    await container.read(activeSessionProvider.notifier).startOrResumeSession();

    expect(gateway.loadCalls, greaterThanOrEqualTo(2));
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
  });

  test(
    'active session rejects a persisted draft from an earlier workout day',
    () async {
      final repository = InMemoryDatabaseRepository();
      final originalInstance = await _seedGzclpInstance(
        repository,
        currentWorkoutIndex: 1,
      );
      final gateway = DatabaseTodayWorkoutGateway(repository);
      final staleDayTwoDraft = await gateway.loadTodayWorkoutSession();
      await repository.saveActiveSessionDraft(staleDayTwoDraft);

      await repository.saveInstance(
        originalInstance.copyWith(currentWorkoutIndex: 2),
      );
      final expectedDayThree = await gateway.loadTodayWorkoutSession();
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

      final activeWorkout = container.read(activeSessionProvider).activeWorkout;
      expect(staleDayTwoDraft.workoutId, isNot(expectedDayThree.workoutId));
      expect(activeWorkout?.workoutId, expectedDayThree.workoutId);
      await _flushMicrotasks();
      expect(
        (await repository.fetchActiveSessionDraft(
          originalInstance.instanceId,
        ))?.workoutId,
        expectedDayThree.workoutId,
      );
    },
  );

  test(
    'active session rejects a stale progression draft with the same workout id',
    () async {
      final repository = InMemoryDatabaseRepository();
      final originalInstance = await _seedGzclpInstance(repository);
      final gateway = DatabaseTodayWorkoutGateway(repository);
      final staleDraft = await gateway.loadTodayWorkoutSession();
      await repository.saveActiveSessionDraft(staleDraft);

      final progressedStates = [
        for (final state in originalInstance.states)
          if (state.exerciseId == staleDraft.exercises.first.id)
            state.copyWith(
              baseWeight: state.baseWeight + 50,
              history: [...state.history, staleDraft.workoutId],
            )
          else
            state,
      ];
      await repository.saveInstance(
        originalInstance.copyWith(states: progressedStates),
      );
      final expectedProgression = await gateway.loadTodayWorkoutSession();
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

      final activeWorkout = container
          .read(activeSessionProvider)
          .activeWorkout!;
      expect(activeWorkout.workoutId, staleDraft.workoutId);
      expect(
        expectedProgression.exercises.first.sets.first.targetWeight,
        isNot(staleDraft.exercises.first.sets.first.targetWeight),
      );
      expect(
        activeWorkout.exercises.first.sets.first.targetWeight,
        expectedProgression.exercises.first.sets.first.targetWeight,
      );
    },
  );

  test('active session preserves and upgrades a valid legacy draft', () async {
    final repository = InMemoryDatabaseRepository();
    final instance = await _seedGzclpInstance(repository);
    final gateway = DatabaseTodayWorkoutGateway(repository);
    final currentSession = await gateway.loadTodayWorkoutSession();
    final legacyJson =
        jsonDecode(
                jsonEncode(
                  currentSession
                      .copyWith(
                        exercises: [
                          currentSession.exercises.first.copyWith(
                            sets: [
                              currentSession.exercises.first.sets.first
                                  .copyWith(completedReps: 3),
                              ...currentSession.exercises.first.sets.skip(1),
                            ],
                          ),
                          ...currentSession.exercises.skip(1),
                        ],
                      )
                      .toJson(),
                ),
              )
              as Map<String, dynamic>
          ..remove('scheduleToken');
    await repository.saveActiveSessionDraft(
      WorkoutSessionState.fromJson(legacyJson),
    );
    final container = ProviderContainer(
      overrides: [
        databaseRepositoryProvider.overrideWithValue(repository),
        todayWorkoutGatewayProvider.overrideWithValue(gateway),
      ],
    );
    addTearDown(container.dispose);

    await container.read(activeSessionProvider.notifier).startOrResumeSession();

    final activeWorkout = container.read(activeSessionProvider).activeWorkout!;
    expect(activeWorkout.exercises.first.sets.first.completedReps, 3);
    final activeToken = activeWorkout.toJson()['scheduleToken'];
    expect(activeToken, isA<String>());
    expect(activeToken as String, isNotEmpty);
    await _flushMicrotasks();
    final savedDraft = await repository.fetchActiveSessionDraft(
      instance.instanceId,
    );
    expect(savedDraft?.toJson()['scheduleToken'], activeToken);
  });

  test('concurrent session starts share one in-flight load', () async {
    final repository = InMemoryDatabaseRepository();
    final gateway = _DelayedSessionGateway();
    final container = ProviderContainer(
      overrides: [
        databaseRepositoryProvider.overrideWithValue(repository),
        todayWorkoutGatewayProvider.overrideWithValue(gateway),
      ],
    );
    addTearDown(container.dispose);
    final notifier = container.read(activeSessionProvider.notifier);
    await _flushMicrotasks();

    final firstStart = notifier.startOrResumeSession();
    final secondStart = notifier.startOrResumeSession();
    await _flushMicrotasks();
    gateway.completeSession();
    await Future.wait([firstStart, secondStart]);

    expect(gateway.loadCalls, 1);
    expect(
      container.read(activeSessionProvider).activeWorkout,
      fakeWorkoutSessionState,
    );
  });

  test('sync refresh does not rebuild or roll back a live session', () async {
    final repository = _DelayedDraftRepository();
    final gateway = FakeTodayWorkoutGateway();
    final container = ProviderContainer(
      overrides: [
        databaseRepositoryProvider.overrideWithValue(repository),
        todayWorkoutGatewayProvider.overrideWithValue(gateway),
      ],
    );
    addTearDown(container.dispose);
    final notifier = container.read(activeSessionProvider.notifier);
    await notifier.startOrResumeSession();
    await _flushMicrotasks();

    final delayedSave = repository.delayNextDraftSave();
    addTearDown(() {
      if (!delayedSave.isCompleted) delayedSave.complete();
    });
    notifier.updateReps(0, 9);
    expect(
      container
          .read(activeSessionProvider)
          .activeWorkout
          ?.exercises
          .first
          .sets
          .first
          .completedReps,
      9,
    );

    container.read(syncRefreshProvider.notifier).state += 1;
    final notifierAfterRefresh = container.read(activeSessionProvider.notifier);
    await _flushMicrotasks();

    expect(identical(notifierAfterRefresh, notifier), isTrue);
    expect(
      container
          .read(activeSessionProvider)
          .activeWorkout
          ?.exercises
          .first
          .sets
          .first
          .completedReps,
      9,
    );
  });

  test('conclusion drains delayed draft writes before clearing', () async {
    final repository = _DelayedDraftRepository();
    final gateway = FakeTodayWorkoutGateway();
    final container = ProviderContainer(
      overrides: [
        databaseRepositoryProvider.overrideWithValue(repository),
        todayWorkoutGatewayProvider.overrideWithValue(gateway),
      ],
    );
    addTearDown(container.dispose);
    final notifier = container.read(activeSessionProvider.notifier);
    await notifier.startOrResumeSession();
    await _flushMicrotasks();

    final delayedSave = repository.delayNextDraftSave();
    notifier.updateReps(0, 9);
    final conclusion = notifier.concludeSession();
    await _flushMicrotasks();
    delayedSave.complete();

    expect(await conclusion, isTrue);
    await _flushMicrotasks();
    expect(
      await repository.fetchActiveSessionDraft(
        fakeWorkoutSessionState.instanceId,
      ),
      isNull,
    );
  });

  test('serialized draft saves preserve the newest local mutation', () async {
    final repository = _DelayedDraftRepository();
    final gateway = FakeTodayWorkoutGateway();
    final container = ProviderContainer(
      overrides: [
        databaseRepositoryProvider.overrideWithValue(repository),
        todayWorkoutGatewayProvider.overrideWithValue(gateway),
      ],
    );
    addTearDown(container.dispose);
    final notifier = container.read(activeSessionProvider.notifier);
    await notifier.startOrResumeSession();
    await _flushMicrotasks();

    final firstSave = repository.delayNextDraftSave();
    notifier.updateReps(0, 8);
    notifier.updateReps(0, 9);
    firstSave.complete();
    await _flushMicrotasks(12);

    final savedDraft = await repository.fetchActiveSessionDraft(
      fakeWorkoutSessionState.instanceId,
    );
    expect(savedDraft?.exercises.first.sets.first.completedReps, 9);
  });

  test('mutations are rejected while conclusion is in flight', () async {
    final repository = InMemoryDatabaseRepository();
    final gateway = _DelayedConclusionGateway();
    final container = ProviderContainer(
      overrides: [
        databaseRepositoryProvider.overrideWithValue(repository),
        todayWorkoutGatewayProvider.overrideWithValue(gateway),
      ],
    );
    addTearDown(container.dispose);
    final notifier = container.read(activeSessionProvider.notifier);
    await notifier.startOrResumeSession();
    final before = container.read(activeSessionProvider).activeWorkout!;

    final conclusion = notifier.concludeSession();
    await _flushMicrotasks();
    notifier.updateReps(0, 99);
    notifier.completeSet(0);

    expect(container.read(activeSessionProvider).activeWorkout, before);
    gateway.completeConclusion();
    expect(await conclusion, isTrue);
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

Future<StoredTrainingInstance> _seedGzclpInstance(
  InMemoryDatabaseRepository repository, {
  int currentWorkoutIndex = 0,
}) async {
  final template = await GzclpSeed.loadTemplate();
  final instance = StoredTrainingInstance(
    instanceId: 'active-gzclp-instance',
    templateId: template.id,
    currentWorkoutIndex: currentWorkoutIndex,
    states: GzclpSeed.buildStarterStates(template),
  );
  await repository.saveTemplate(template, isBuiltIn: true);
  await repository.saveInstance(instance);
  await repository.saveActiveInstanceId(instance.instanceId);
  return instance;
}

Future<void> _flushMicrotasks([int count = 6]) async {
  for (var index = 0; index < count; index++) {
    await Future<void>.delayed(Duration.zero);
  }
}
