import 'dart:convert';

import 'package:fittin_v2/src/application/agent_tools.dart';
import 'package:fittin_v2/src/application/agent_plan_tools.dart';
import 'package:fittin_v2/src/application/agent_mutation_coordinator.dart';
import 'package:fittin_v2/src/data/agent_local_repository.dart';
import 'package:fittin_v2/src/application/active_session_provider.dart';
import 'package:fittin_v2/src/data/seeds/shenshi_five_day_seed.dart';
import 'package:fittin_v2/src/domain/models/agent_models.dart';
import 'package:fittin_v2/src/domain/models/training_plan.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/in_memory_database_repository.dart';
import '../support/fake_today_workout_gateway.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'active drafts block both preview and a previously generated revision',
    () async {
      final repository = InMemoryDatabaseRepository();
      await repository.saveTemplate(fakePlanTemplate, isBuiltIn: true);
      final active = await repository.activateTemplate(fakePlanTemplate.id);
      final c = ProviderContainer(
        overrides: [
          databaseRepositoryProvider.overrideWithValue(repository),
          agentLocalRepositoryProvider.overrideWithValue(
            InMemoryAgentLocalRepository(),
          ),
        ],
      );
      addTearDown(c.dispose);
      final tools = c.read(agentToolRegistryProvider);
      final input = {
        'templateId': fakePlanTemplate.id,
        'expectedDigest': agentPayloadDigest(fakePlanTemplate.toJson()),
        'edits': [
          {'op': 'replace', 'path': '/name', 'value': 'Revised'},
        ],
      };
      final preview = await tools.execute('propose_revise_plan', input);
      expect(preview.isError, false, reason: preview.encoded);
      final draft = fakeWorkoutSessionState.copyWith(
        instanceId: active.instanceId,
        templateId: active.templateId,
      );
      await repository.saveActiveSessionDraft(draft);
      final blocked = await tools.execute('propose_revise_plan', input);
      expect(blocked.isError, true);
      await expectLater(
        c.read(agentMutationCoordinatorProvider).confirm(preview.proposal!),
        throwsA(isA<AgentMutationConflict>()),
      );
      expect(
        (await repository.fetchActiveSessionDraft(active.instanceId))!.toJson(),
        draft.toJson(),
      );
      expect(
        (await repository.fetchActiveInstance())!.instanceId,
        active.instanceId,
      );
    },
  );

  test(
    'paged built-in plan edit confirms, preserves progress, and undoes',
    () async {
      final source = await ShenshiFiveDaySeed.loadTemplate();
      final repository = InMemoryDatabaseRepository();
      await repository.saveTemplate(source, isBuiltIn: true);
      final instance = await repository.activateTemplate(source.id);
      await repository.saveInstance(instance.copyWith(currentWorkoutIndex: 2));
      final container = ProviderContainer(
        overrides: [
          databaseRepositoryProvider.overrideWithValue(repository),
          agentLocalRepositoryProvider.overrideWithValue(
            InMemoryAgentLocalRepository(),
          ),
        ],
      );
      addTearDown(container.dispose);
      final tools = container.read(agentToolRegistryProvider);
      final page = await tools.execute('get_plan', {
        'templateId': source.id,
        'offset': 0,
        'limit': 1,
      });
      expect(page.isError, false);
      expect(page.payload['workouts'], hasLength(1));
      expect(page.payload['nextOffset'], 1);
      expect((page.payload['template'] as Map).containsKey('phases'), false);
      final path = (page.payload['workouts'] as List).first['path'];
      final result = await tools.execute('propose_revise_plan', {
        'templateId': source.id,
        'expectedDigest': page.payload['expectedDigest'],
        'edits': [
          {
            'op': 'replace',
            'path': '$path/exercises/0/restSeconds',
            'value': 90,
          },
          {
            'op': 'replace',
            'path': '$path/exercises/0/stages/0/sets/0/targetReps',
            'value': 10,
          },
        ],
      });
      expect(result.isError, false, reason: result.encoded);
      final proposal = result.proposal!;
      expect(result.payload['changeCount'], proposal.changes.length);
      expect(result.payload['changedPaths'], hasLength(2));
      expect(result.payload.containsKey('changes'), false);
      expect(
        proposal.changes.any(
          (c) =>
              c.path.contains('targetReps') &&
              c.before == '12' &&
              c.after == '10',
        ),
        true,
      );
      expect(
        (await repository.fetchTemplate(source.id))!.toJson(),
        source.toJson(),
      );
      final coordinator = container.read(agentMutationCoordinatorProvider);
      final action = await coordinator.confirm(proposal);
      final active = await repository.fetchActiveInstance();
      expect(active!.currentWorkoutIndex, 2);
      expect(active.states, instance.states);
      expect(active.templateId, isNot(source.id));
      final changed = (await repository.fetchTemplate(active.templateId))!;
      expect(changed.workouts.first.exercises.first.restSeconds, 90);
      expect(
        changed
            .workouts
            .first
            .exercises
            .first
            .stages
            .first
            .sets
            .first
            .targetReps,
        10,
      );
      expect(changed.workouts.skip(1), source.workouts.skip(1));
      expect(
        (await repository.fetchTemplate(source.id))!.toJson(),
        source.toJson(),
      );
      await coordinator.undo(action.id);
      expect((await repository.fetchActiveInstance())!.templateId, source.id);
      expect((await repository.fetchActiveInstance())!.currentWorkoutIndex, 2);
    },
  );

  test(
    'stale digest, bad path, invalid values and no-op are rejected without writes',
    () async {
      final source = await ShenshiFiveDaySeed.loadTemplate();
      final repository = InMemoryDatabaseRepository();
      await repository.saveTemplate(source);
      final container = ProviderContainer(
        overrides: [databaseRepositoryProvider.overrideWithValue(repository)],
      );
      addTearDown(container.dispose);
      final tools = container.read(agentToolRegistryProvider);
      final digest = agentPayloadDigest(source.toJson());
      for (final edit in [
        {'op': 'replace', 'path': '/phases/99/name', 'value': 'bad'},
        {'op': 'replace', 'path': '/id', 'value': 'wrong'},
        {
          'op': 'replace',
          'path': '/phases/0/workouts/0/exercises/0/stages/0/sets/0/targetReps',
          'value': -1,
        },
        {'op': 'replace', 'path': '/name', 'value': source.name},
      ]) {
        final result = await tools.execute('propose_revise_plan', {
          'templateId': source.id,
          'expectedDigest': digest,
          'edits': [edit],
        });
        expect(result.isError, true, reason: jsonEncode(edit));
        expect(result.proposal, isNull);
      }
      final stale = await tools.execute('propose_revise_plan', {
        'templateId': source.id,
        'expectedDigest': 'old',
        'edits': [
          {'op': 'replace', 'path': '/name', 'value': 'new'},
        ],
      });
      expect(stale.encoded, contains('Read get_plan again'));
      expect(
        (await repository.fetchTemplate(source.id))!.toJson(),
        source.toJson(),
      );
    },
  );

  test('add/remove sets applies only to a local copy', () async {
    final source = await ShenshiFiveDaySeed.loadTemplate();
    const path = '/phases/0/workouts/0/exercises/0/stages/0/sets';
    final original = jsonEncode(source.toJson());
    final patched = applyAgentPlanEdits(source, [
      {
        'op': 'add',
        'path': '$path/-',
        'value': {'targetReps': 15, 'intensity': 1.0},
      },
      {'op': 'remove', 'path': '$path/0'},
    ]);
    final sets =
        patched['phases'][0]['workouts'][0]['exercises'][0]['stages'][0]['sets']
            as List;
    expect(
      sets.length,
      source.workouts.first.exercises.first.stages.first.sets.length,
    );
    expect(sets.last['targetReps'], 15);
    expect(jsonEncode(source.toJson()), original);
  });
}
