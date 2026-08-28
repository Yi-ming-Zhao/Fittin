import 'dart:convert';
import 'package:fittin_v2/src/application/active_session_provider.dart';
import 'package:fittin_v2/src/application/app_locale_provider.dart';

import 'package:fittin_v2/src/application/agent_mutation_coordinator.dart';
import 'package:fittin_v2/src/application/agent_mutation_diff.dart';
import 'package:fittin_v2/src/application/agent_owner_scope.dart';
import 'package:fittin_v2/src/application/agent_workout_input.dart';
import 'package:fittin_v2/src/application/agent_tools.dart';
import 'package:fittin_v2/src/data/agent_local_repository.dart';
import 'package:fittin_v2/src/data/database_repository.dart';
import 'package:fittin_v2/src/data/progress_repository.dart';
import 'package:fittin_v2/src/domain/models/agent_models.dart';
import 'package:fittin_v2/src/domain/models/body_metric.dart';
import 'package:fittin_v2/src/domain/models/workout_log.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/isar_test_helper.dart';
import '../support/in_memory_database_repository.dart';
import 'package:fittin_v2/src/data/seeds/shenshi_five_day_seed.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test(
    'plan undo also rejects ABA changes to the migrated training instance',
    () async {
      final opened = await openTestIsar('agent_plan_aba');
      addTearDown(() async {
        // Drain Isar's worker queue after a rolled-back write transaction before
        // closing the native test handle (the app keeps its database open).
        await opened.isar.txn(() async {});
        await opened.isar.close(deleteFromDisk: true);
        await opened.directory.delete(recursive: true);
      });
      final database = DatabaseRepository(opened.isar);
      final plan = await ShenshiFiveDaySeed.loadTemplate();
      await database.saveTemplate(plan, isBuiltIn: true);
      await database.activateTemplate(plan.id);
      final c = ProviderContainer(
        overrides: [
          databaseRepositoryProvider.overrideWithValue(database),
          appLocaleProvider.overrideWith(
            (ref) => AppLocaleNotifier(ref, initialLocale: AppLocale.en),
          ),
          progressRepositoryProvider.overrideWithValue(
            ProgressRepository(opened.isar),
          ),
          agentLocalRepositoryProvider.overrideWithValue(
            IsarAgentLocalRepository(opened.isar),
          ),
        ],
      );
      addTearDown(c.dispose);
      final tools = c.read(agentToolRegistryProvider);
      final read = await tools.execute('get_active_plan', {'limit': 1});
      final path = (read.payload['workouts'] as List).first['path'];
      final proposal = await tools.execute('propose_revise_plan', {
        'templateId': plan.id,
        'expectedDigest': read.payload['expectedDigest'],
        'edits': [
          {
            'op': 'replace',
            'path': '$path/exercises/0/restSeconds',
            'value': 91,
          },
        ],
      });
      expect(proposal.isError, false, reason: proposal.encoded);
      final coordinator = c.read(agentMutationCoordinatorProvider);
      final action = await coordinator.confirm(proposal.proposal!);
      final active = (await database.fetchActiveInstance())!;
      await database.saveInstance(active);
      await expectLater(
        coordinator.undo(action.id),
        throwsA(isA<AgentMutationConflict>()),
      );
      expect(
        (await database.fetchActiveInstance())!.instanceId,
        active.instanceId,
      );
    },
  );

  test(
    'deleting a nested workout snapshot commits once and can be undone',
    () async {
      final database = InMemoryDatabaseRepository();
      final original = WorkoutLog(
        logId: 'delete-log',
        instanceId: 'instance',
        workoutId: 'day',
        workoutName: 'Synthetic',
        dayLabel: 'Day 1',
        completedAt: DateTime(2026, 8, 1),
        exercises: [
          ExerciseLog(
            exerciseId: 'squat',
            exerciseName: 'Squat',
            stageId: 'stage',
            sets: const [
              SetLog(
                role: 'working',
                targetReps: 5,
                completedReps: 5,
                targetWeight: 50,
                weight: 50,
                isCompleted: true,
              ),
            ],
          ),
        ],
      );
      await database.logWorkout(original);
      final c = ProviderContainer(
        overrides: [
          databaseRepositoryProvider.overrideWithValue(database),
          progressRepositoryProvider.overrideWithValue(
            InMemoryProgressRepository(),
          ),
        ],
      );
      addTearDown(c.dispose);
      final result = await c.read(agentToolRegistryProvider).execute(
        'propose_delete_workout_log',
        {'logId': original.logId},
      );
      expect(result.isError, false, reason: result.encoded);
      final coordinator = c.read(agentMutationCoordinatorProvider);
      final action = await coordinator.confirm(result.proposal!);
      expect(await database.fetchWorkoutLogById(original.logId), isNull);
      expect((await coordinator.confirm(result.proposal!)).id, action.id);
      await coordinator.undo(action.id);
      expect(await database.fetchWorkoutLogById(original.logId), original);
    },
  );

  test('native versions reject ABA changes in confirmation and undo', () async {
    final opened = await openTestIsar('agent_aba');
    addTearDown(() async {
      await opened.isar.close(deleteFromDisk: true);
      await opened.directory.delete(recursive: true);
    });
    final progress = ProgressRepository(opened.isar);
    final actions = IsarAgentLocalRepository(opened.isar);
    final c = ProviderContainer(
      overrides: [
        databaseRepositoryProvider.overrideWithValue(
          DatabaseRepository(opened.isar),
        ),
        progressRepositoryProvider.overrideWithValue(progress),
        agentLocalRepositoryProvider.overrideWithValue(actions),
      ],
    );
    addTearDown(c.dispose);
    final original = BodyMetric(
      metricId: 'aba',
      timestamp: DateTime(2026, 8, 1),
      weightKg: 70,
    );
    await progress.saveBodyMetric(original);
    final tools = c.read(agentToolRegistryProvider);
    final first = await tools.execute('propose_update_body_metric', {
      'metricId': 'aba',
      'weightKg': 71,
    });
    expect(first.isError, false, reason: first.encoded);
    expect(first.proposal!.expectedVersion, isNotNull);
    await progress.saveBodyMetric(original.copyWith(weightKg: 72));
    await progress.saveBodyMetric(original);
    await expectLater(
      c.read(agentMutationCoordinatorProvider).confirm(first.proposal!),
      throwsA(isA<AgentMutationConflict>()),
    );
    expect(await actions.fetchActions(), isEmpty);
    final fresh = await tools.execute('propose_update_body_metric', {
      'metricId': 'aba',
      'weightKg': 71,
    });
    final action = await c
        .read(agentMutationCoordinatorProvider)
        .confirm(fresh.proposal!);
    await progress.saveBodyMetric(original.copyWith(weightKg: 71));
    await expectLater(
      c.read(agentMutationCoordinatorProvider).undo(action.id),
      throwsA(isA<AgentMutationConflict>()),
    );
    expect((await progress.fetchBodyMetrics()).single.weightKg, 71);
  });
  test(
    'native complete snapshots clear optional fields and undo restores null',
    () async {
      final opened = await openTestIsar('nullable_agent');
      addTearDown(() async {
        await opened.isar.close(deleteFromDisk: true);
        await opened.directory.delete(recursive: true);
      });
      final progress = ProgressRepository(opened.isar);
      final container = ProviderContainer(
        overrides: [
          databaseRepositoryProvider.overrideWithValue(
            DatabaseRepository(opened.isar),
          ),
          progressRepositoryProvider.overrideWithValue(progress),
          agentLocalRepositoryProvider.overrideWithValue(
            IsarAgentLocalRepository(opened.isar),
          ),
        ],
      );
      addTearDown(container.dispose);
      final before = BodyMetric(
        metricId: 'nullable',
        timestamp: DateTime(2026, 8, 1),
        weightKg: 70,
      );
      await progress.saveBodyMetric(before);
      final after = before.copyWith(waistCm: 80, note: 'measurement');
      AgentMutationProposal proposal(String id, BodyMetric a, BodyMetric b) =>
          AgentMutationProposal(
            operationId: id,
            toolName: 'propose_update_body_metric',
            title: 'Correct',
            summary: '',
            argumentsJson: jsonEncode({'metric': b.toJson()}),
            targetType: 'body_metric',
            targetId: a.metricId,
            expectedDigest: agentPayloadDigest(a.toJson()),
            changes: AgentMutationDiff.between(a.toJson(), b.toJson()),
            createdAt: DateTime.now(),
          );
      final coordinator = container.read(agentMutationCoordinatorProvider);
      final first = await coordinator.confirm(
        proposal('add-optional', before, after),
      );
      expect((await progress.fetchBodyMetrics()).single.waistCm, 80);
      await coordinator.undo(first.id);
      expect((await progress.fetchBodyMetrics()).single.waistCm, isNull);
      expect((await progress.fetchBodyMetrics()).single.note, isNull);
      await coordinator.confirm(proposal('add-again', before, after));
      await coordinator.confirm(proposal('clear', after, before));
      expect((await progress.fetchBodyMetrics()).single.waistCm, isNull);
    },
  );

  test(
    'workout edits reject internal fields at every level and retain identity',
    () {
      final base = WorkoutLog(
        logId: 'log',
        instanceId: 'instance',
        workoutId: 'day',
        workoutName: 'Day',
        dayLabel: 'Day',
        completedAt: DateTime(2026, 8, 1),
        exercises: const [
          ExerciseLog(
            exerciseId: 'squat',
            exerciseName: 'Squat',
            stageId: 'stage',
            sets: [
              SetLog(
                role: 'work',
                targetReps: 5,
                completedReps: 5,
                targetWeight: 50,
                weight: 50,
                isCompleted: true,
              ),
            ],
          ),
        ],
      );
      for (final key in [
        'instanceId',
        'logId',
        'workoutId',
        'ownerUserId',
        'version',
        'preConclusionSnapshot',
        'postConclusionSnapshot',
      ]) {
        expect(
          () => AgentWorkoutInput.apply({key: 'injected'}, base),
          throwsFormatException,
        );
      }
      expect(
        () => AgentWorkoutInput.apply({
          'exercises': [
            {
              'exerciseId': 'squat',
              'sets': [
                {'version': 1},
              ],
            },
          ],
        }, base),
        throwsFormatException,
      );
      final result = AgentWorkoutInput.apply({
        'exercises': [
          {
            'exerciseId': 'squat',
            'sets': [
              {'weight': 60},
            ],
          },
        ],
      }, base);
      expect(result.instanceId, base.instanceId);
      expect(result.exercises.single.sets.single.weight, 60);
      final diff = AgentMutationDiff.between(base.toJson(), result.toJson());
      expect(diff.single.path, contains('weight'));
    },
  );

  test(
    'metric date and individual changes are visible even at equal volume',
    () {
      final diff = AgentMutationDiff.between(
        {
          'timestamp': 'a',
          'sets': [
            {'weight': 50, 'reps': 10},
          ],
        },
        {
          'timestamp': 'b',
          'sets': [
            {'weight': 100, 'reps': 5},
          ],
        },
      );
      expect(
        diff.map((d) => d.path),
        containsAll(['timestamp', 'sets 1 / weight', 'sets 1 / reps']),
      );
    },
  );

  test('account lease prevents a proposal from another login epoch', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final scope = container.read(agentOwnerScopeProvider);
    final proposal = AgentMutationProposal(
      operationId: 'old',
      toolName: 'propose_create_body_metric',
      title: '',
      summary: '',
      argumentsJson: '{}',
      targetType: 'body_metric',
      targetId: 'x',
      expectedDigest: agentPayloadDigest(null),
      changes: const [],
      createdAt: DateTime.now(),
      ownerUserId: scope.ownerUserId,
      authEpoch: 'previous-login',
    );
    await expectLater(
      container.read(agentMutationCoordinatorProvider).confirm(proposal),
      throwsA(isA<AgentMutationConflict>()),
    );
  });

  test('canonical SHA256 normalizes map order', () {
    expect(
      agentPayloadDigest({'b': 2, 'a': 1}),
      agentPayloadDigest({'a': 1, 'b': 2}),
    );
    expect(agentPayloadDigest(null), startsWith('sha256:'));
  });
}
