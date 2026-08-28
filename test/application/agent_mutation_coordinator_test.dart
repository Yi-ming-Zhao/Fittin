import 'dart:convert';

import 'package:fittin_v2/src/application/agent_mutation_coordinator.dart';
import 'package:fittin_v2/src/application/active_session_provider.dart';
import 'package:fittin_v2/src/application/plan_library_provider.dart';
import 'package:fittin_v2/src/application/template_editor_provider.dart';
import 'package:fittin_v2/src/application/sync_refresh_provider.dart';
import 'package:fittin_v2/src/application/advanced_analytics_provider.dart';
import 'package:fittin_v2/src/application/body_metrics_provider.dart';
import 'package:fittin_v2/src/data/agent_local_repository.dart';
import 'package:fittin_v2/src/data/progress_repository.dart';
import 'package:fittin_v2/src/data/database_repository.dart';
import 'package:fittin_v2/src/data/models/agent_action_collection.dart';
import 'package:fittin_v2/src/data/models/sync_queue_collection.dart';
import 'package:fittin_v2/src/domain/models/agent_models.dart';
import 'package:fittin_v2/src/domain/models/body_metric.dart';
import 'package:fittin_v2/src/domain/models/training_max.dart';
import 'package:fittin_v2/src/domain/models/training_plan.dart';
import 'package:fittin_v2/src/domain/models/training_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/isar_test_helper.dart';
import '../support/in_memory_database_repository.dart';

void main() {
  test(
    'confirmation is idempotent and undo restores the before snapshot',
    () async {
      final progress = InMemoryProgressRepository();
      final actions = InMemoryAgentLocalRepository();
      var libraryLoads = 0;
      final container = ProviderContainer(
        overrides: [
          progressRepositoryProvider.overrideWithValue(progress),
          agentLocalRepositoryProvider.overrideWithValue(actions),
          planLibraryItemsProvider.overrideWith((ref) async {
            ref.watch(syncRefreshProvider);
            libraryLoads++;
            return const [];
          }),
        ],
      );
      addTearDown(container.dispose);
      final librarySubscription = container.listen(
        planLibraryItemsProvider,
        (_, _) {},
      );
      addTearDown(librarySubscription.close);
      await container.read(planLibraryItemsProvider.future);
      expect(libraryLoads, 1);
      final before = BodyMetric(
        metricId: 'metric-1',
        timestamp: DateTime(2026, 8, 13),
        weightKg: 80,
      );
      final after = before.copyWith(weightKg: 81);
      await progress.saveBodyMetric(before);
      final proposal = AgentMutationProposal(
        operationId: 'operation-1',
        toolName: 'propose_update_body_metric',
        title: 'Correct weight',
        summary: '80 to 81',
        argumentsJson: jsonEncode({'metric': after.toJson()}),
        targetType: 'body_metric',
        targetId: before.metricId,
        expectedDigest: agentPayloadDigest(before.toJson()),
        changes: const [
          AgentMutationChange(path: 'weightKg', before: '80', after: '81'),
        ],
        createdAt: DateTime.now(),
      );

      final coordinator = container.read(agentMutationCoordinatorProvider);
      final first = await coordinator.confirm(proposal);
      await container.read(planLibraryItemsProvider.future);
      expect(libraryLoads, 2);
      for (final initialized in [
        container.exists(templateLibraryProvider),
        container.exists(todayWorkoutSummaryProvider),
        container.exists(activeTemplateProvider),
        container.exists(activeSessionProvider),
        container.exists(advancedAnalyticsDataProvider),
        container.exists(bodyMetricsProvider),
      ]) {
        expect(
          initialized,
          false,
          reason: 'A mutation must not start an unopened page reader.',
        );
      }
      final second = await coordinator.confirm(proposal);

      expect(first.id, second.id);
      expect((await progress.fetchBodyMetrics()).single.weightKg, 81);
      expect(await actions.fetchActions(), hasLength(1));

      final undone = await coordinator.undo(first.id);
      expect(undone.status, AgentActionStatus.undone);
      expect((await progress.fetchBodyMetrics()).single.weightKg, 80);
    },
  );

  test('rejects stale confirmation without mutating data', () async {
    final progress = InMemoryProgressRepository();
    final container = ProviderContainer(
      overrides: [
        progressRepositoryProvider.overrideWithValue(progress),
        agentLocalRepositoryProvider.overrideWithValue(
          InMemoryAgentLocalRepository(),
        ),
      ],
    );
    addTearDown(container.dispose);
    final original = BodyMetric(
      metricId: 'metric-2',
      timestamp: DateTime(2026, 8, 13),
      weightKg: 75,
    );
    await progress.saveBodyMetric(original);
    final proposal = AgentMutationProposal(
      operationId: 'operation-stale',
      toolName: 'propose_update_body_metric',
      title: 'Correct weight',
      summary: '',
      argumentsJson: jsonEncode({
        'metric': original.copyWith(weightKg: 76).toJson(),
      }),
      targetType: 'body_metric',
      targetId: original.metricId,
      expectedDigest: agentPayloadDigest(original.toJson()),
      changes: const [],
      createdAt: DateTime.now(),
    );
    await progress.saveBodyMetric(original.copyWith(weightKg: 77));

    await expectLater(
      container.read(agentMutationCoordinatorProvider).confirm(proposal),
      throwsA(isA<AgentMutationConflict>()),
    );
    expect((await progress.fetchBodyMetrics()).single.weightKg, 77);
  });

  test('refuses undo when the target changed after application', () async {
    final progress = InMemoryProgressRepository();
    final container = ProviderContainer(
      overrides: [
        progressRepositoryProvider.overrideWithValue(progress),
        agentLocalRepositoryProvider.overrideWithValue(
          InMemoryAgentLocalRepository(),
        ),
      ],
    );
    addTearDown(container.dispose);
    final original = BodyMetric(
      metricId: 'metric-3',
      timestamp: DateTime(2026, 8, 13),
      weightKg: 70,
    );
    final proposed = original.copyWith(weightKg: 71);
    await progress.saveBodyMetric(original);
    final coordinator = container.read(agentMutationCoordinatorProvider);
    final action = await coordinator.confirm(
      AgentMutationProposal(
        operationId: 'operation-conflict',
        toolName: 'propose_update_body_metric',
        title: 'Correct weight',
        summary: '',
        argumentsJson: jsonEncode({'metric': proposed.toJson()}),
        targetType: 'body_metric',
        targetId: original.metricId,
        expectedDigest: agentPayloadDigest(original.toJson()),
        changes: const [],
        createdAt: DateTime.now(),
      ),
    );
    await progress.saveBodyMetric(original.copyWith(weightKg: 72));

    await expectLater(
      coordinator.undo(action.id),
      throwsA(isA<AgentMutationConflict>()),
    );
    expect((await progress.fetchBodyMetrics()).single.weightKg, 72);
  });

  test(
    'active plan migration preserves stable progress and initializes changes',
    () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final coordinator = container.read(agentMutationCoordinatorProvider);
      final oldPlan = _plan(
        workouts: const [
          Workout(
            id: 'day-a',
            name: 'Day A',
            exercises: [_squat, _bench, _removedRow],
          ),
          Workout(id: 'day-b', name: 'Day B', exercises: [_deadlift]),
        ],
      );
      final newPlan = _plan(
        id: 'revised-plan',
        workouts: const [
          Workout(
            id: 'day-b',
            name: 'Day B revised',
            exercises: [_deadlift, _newPress],
          ),
          Workout(
            id: 'day-a',
            name: 'Day A revised',
            exercises: [_squat, _bench],
          ),
        ],
      );
      final current = StoredTrainingInstance(
        instanceId: 'instance-1',
        templateId: oldPlan.id,
        currentWorkoutIndex: 1,
        ownerUserId: 'owner-1',
        trainingMaxProfile: const TrainingMaxProfile({
          'squat': 180,
          'bench': 120,
          'deadlift': 220,
        }),
        engineState: const {'cycleWeek': 4},
        states: const [
          TrainingState(
            workoutId: 'day-a',
            exerciseId: 'squat-slot',
            exerciseName: 'Squat',
            baseWeight: 132.5,
            currentStageId: 'stage-1',
            history: ['success'],
          ),
          TrainingState(
            workoutId: 'day-b',
            exerciseId: 'deadlift-slot',
            exerciseName: 'Deadlift',
            baseWeight: 170,
            currentStageId: 'stage-1',
          ),
          TrainingState(
            workoutId: 'day-a',
            exerciseId: 'row-slot',
            exerciseName: 'Row',
            baseWeight: 70,
            currentStageId: 'stage-1',
          ),
        ],
      );

      final migrated = coordinator.migrateInstanceForTesting(
        current,
        oldPlan: oldPlan,
        newPlan: newPlan,
        operationId: '12345678-abcd-efgh-ijkl-123456789012',
      );

      expect(migrated.templateId, newPlan.id);
      expect(migrated.currentWorkoutIndex, 0);
      expect(migrated.ownerUserId, current.ownerUserId);
      expect(
        migrated.trainingMaxProfile.values,
        current.trainingMaxProfile.values,
      );
      expect(migrated.engineState, current.engineState);
      expect(
        migrated.states.firstWhere((state) => state.exerciseId == 'squat-slot'),
        isA<TrainingState>()
            .having((state) => state.baseWeight, 'baseWeight', 132.5)
            .having((state) => state.history, 'history', ['success']),
      );
      expect(
        migrated.states
            .firstWhere((state) => state.exerciseId == 'deadlift-slot')
            .baseWeight,
        170,
      );
      expect(
        migrated.states
            .firstWhere((state) => state.exerciseId == 'press-slot')
            .baseWeight,
        30,
      );
      expect(
        migrated.states.any((state) => state.exerciseId == 'row-slot'),
        isFalse,
      );
    },
  );

  test('active plan revision rejects progress changed after preview', () async {
    final database = InMemoryDatabaseRepository();
    final oldPlan = _plan(
      workouts: const [
        Workout(id: 'day-a', name: 'Day A', exercises: [_squat]),
      ],
    );
    final revised = _plan(
      id: 'revised-plan',
      workouts: const [
        Workout(id: 'day-a', name: 'Day A revised', exercises: [_squat]),
      ],
    );
    await database.saveTemplate(oldPlan);
    final active = StoredTrainingInstance(
      instanceId: 'instance-stale',
      templateId: oldPlan.id,
      currentWorkoutIndex: 0,
      states: const [
        TrainingState(
          workoutId: 'day-a',
          exerciseId: 'squat-slot',
          exerciseName: 'Squat',
          baseWeight: 100,
          currentStageId: 'stage-1',
        ),
      ],
    );
    await database.saveInstance(active);
    await database.saveActiveInstanceId(active.instanceId);
    final instanceSnapshot = {
      'instanceId': active.instanceId,
      'templateId': active.templateId,
      'currentWorkoutIndex': active.currentWorkoutIndex,
      'trainingMaxProfile': active.trainingMaxProfile.toJson(),
      'engineState': active.engineState,
      'states': active.states.map((state) => state.toJson()).toList(),
    };
    final proposal = AgentMutationProposal(
      operationId: 'stale-plan-revision',
      toolName: 'propose_revise_plan',
      title: 'Revise active plan',
      summary: '',
      argumentsJson: jsonEncode({
        'templateId': oldPlan.id,
        'plan': revised.toJson(),
        'activeInstanceId': active.instanceId,
        'activeInstanceDigest': agentPayloadDigest(instanceSnapshot),
      }),
      targetType: 'plan',
      targetId: oldPlan.id,
      expectedDigest: agentPayloadDigest(oldPlan.toJson()),
      changes: const [],
      createdAt: DateTime.now(),
    );
    await database.saveInstance(
      active.copyWith(states: [active.states.single.copyWith(baseWeight: 105)]),
    );
    final container = ProviderContainer(
      overrides: [
        databaseRepositoryProvider.overrideWithValue(database),
        agentLocalRepositoryProvider.overrideWithValue(
          InMemoryAgentLocalRepository(),
        ),
      ],
    );
    addTearDown(container.dispose);

    await expectLater(
      container.read(agentMutationCoordinatorProvider).confirm(proposal),
      throwsA(isA<AgentMutationConflict>()),
    );
    expect(await database.fetchStoredTemplate(revised.id), isNull);
  });

  test(
    'native confirmation rolls back business rows if audit write fails',
    () async {
      final opened = await openTestIsar('agent_atomic_business_failure');
      addTearDown(() async {
        await opened.isar.close(deleteFromDisk: true);
        if (await opened.directory.exists()) {
          await opened.directory.delete(recursive: true);
        }
      });
      final database = DatabaseRepository(opened.isar);
      final actionStore = _FailingIsarAgentRepository(opened.isar);
      final container = ProviderContainer(
        overrides: [
          databaseRepositoryProvider.overrideWithValue(database),
          agentLocalRepositoryProvider.overrideWithValue(actionStore),
        ],
      );
      addTearDown(container.dispose);
      final plan = _plan(
        id: 'atomic-create-plan',
        workouts: const [
          Workout(id: 'day-a', name: 'Day A', exercises: [_squat]),
        ],
      );
      final proposal = AgentMutationProposal(
        operationId: 'atomic-operation',
        toolName: 'propose_create_plan',
        title: 'Create atomic plan',
        summary: '',
        argumentsJson: jsonEncode({'plan': plan.toJson()}),
        targetType: 'plan',
        targetId: plan.id,
        expectedDigest: agentPayloadDigest(null),
        changes: const [],
        createdAt: DateTime.now(),
      );

      await expectLater(
        container.read(agentMutationCoordinatorProvider).confirm(proposal),
        throwsStateError,
      );

      expect(await database.fetchStoredTemplate(plan.id), isNull);
      expect(await opened.isar.syncQueueCollections.count(), 0);
      expect(await opened.isar.agentActionCollections.count(), 0);
    },
  );
}

class _FailingIsarAgentRepository extends IsarAgentLocalRepository {
  const _FailingIsarAgentRepository(super.isar);

  @override
  Future<void> saveAction(AgentActionRecord action) {
    throw StateError('Injected audit failure.');
  }
}

PlanTemplate _plan({
  String id = 'source-plan',
  required List<Workout> workouts,
}) => PlanTemplate(
  id: id,
  name: id,
  description: 'migration fixture',
  engineFamily: 'linear_tm',
  phases: [Phase(id: 'phase-1', name: 'Phase', workouts: workouts)],
);

const _stage = SetScheme(
  id: 'stage-1',
  name: 'Working',
  sets: [SetDefinition(targetReps: 5, intensity: 1)],
  rules: [],
);

const _squat = Exercise(
  id: 'squat-slot',
  exerciseId: 'squat',
  name: 'Squat',
  initialBaseWeight: 100,
  stages: [_stage],
);
const _bench = Exercise(
  id: 'bench-slot',
  exerciseId: 'bench_press',
  name: 'Bench',
  initialBaseWeight: 80,
  stages: [_stage],
);
const _removedRow = Exercise(
  id: 'row-slot',
  exerciseId: 'barbell_row',
  name: 'Row',
  initialBaseWeight: 60,
  stages: [_stage],
);
const _deadlift = Exercise(
  id: 'deadlift-slot',
  exerciseId: 'deadlift',
  name: 'Deadlift',
  initialBaseWeight: 140,
  stages: [_stage],
);
const _newPress = Exercise(
  id: 'press-slot',
  exerciseId: 'overhead_press',
  name: 'Press',
  initialBaseWeight: 30,
  stages: [_stage],
);
