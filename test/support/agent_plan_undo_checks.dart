import 'package:fittin_v2/src/application/active_session_provider.dart';
import 'package:fittin_v2/src/application/agent_mutation_coordinator.dart';
import 'package:fittin_v2/src/application/agent_tools.dart';
import 'package:fittin_v2/src/application/app_locale_provider.dart';
import 'package:fittin_v2/src/data/agent_local_repository.dart';
import 'package:fittin_v2/src/data/database_repository.dart';
import 'package:fittin_v2/src/data/seeds/seed_utils.dart';
import 'package:fittin_v2/src/domain/models/agent_models.dart';
import 'package:fittin_v2/src/domain/models/training_plan.dart';
import 'package:fittin_v2/src/domain/models/workout_log.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fake_today_workout_gateway.dart';

const agentPlanUndoScenarios = [
  'restore',
  'history',
  'deleted-history',
  'draft',
];

Future<void> checkAgentPlanUndoScenario({
  required DatabaseRepository database,
  required AgentLocalRepository actions,
  required String scenario,
  PlanTemplate sourcePlan = fakePlanTemplate,
}) async {
  await database.saveTemplate(sourcePlan, isBuiltIn: true);
  // Persistence tests seed records directly: browser unit runners do not serve
  // Flutter asset bundles, and built-in bootstrapping has separate coverage.
  final source = StoredTrainingInstance(
    instanceId: 'source-instance',
    templateId: sourcePlan.id,
    currentWorkoutIndex: 0,
    states: buildStarterStatesForTemplate(sourcePlan),
  );
  await database.saveInstance(source);
  await database.saveActiveInstanceId(source.instanceId);
  final container = ProviderContainer(
    overrides: [
      databaseRepositoryProvider.overrideWithValue(database),
      agentLocalRepositoryProvider.overrideWithValue(actions),
      appLocaleProvider.overrideWith(
        (ref) => AppLocaleNotifier(ref, initialLocale: AppLocale.en),
      ),
    ],
  );
  try {
    final tools = container.read(agentToolRegistryProvider);
    final page = await tools.execute('get_active_plan', {'limit': 1});
    final path = (page.payload['workouts'] as List).first['path'];
    final preview = await tools.execute('propose_revise_plan', {
      'templateId': sourcePlan.id,
      'expectedDigest': page.payload['expectedDigest'],
      'edits': [
        {'op': 'replace', 'path': '$path/exercises/0/restSeconds', 'value': 91},
      ],
    });
    expect(preview.isError, false, reason: preview.encoded);
    final coordinator = container.read(agentMutationCoordinatorProvider);
    final action = await coordinator.confirm(preview.proposal!);
    final migrated = (await database.fetchActiveInstance())!;
    expect(migrated.instanceId, isNot(source.instanceId));

    if (scenario == 'restore') {
      await coordinator.undo(action.id);
      final restored = (await database.fetchActiveInstance())!;
      expect(restored.instanceId, source.instanceId);
      expect(restored.states, source.states);
      expect(restored.currentWorkoutIndex, source.currentWorkoutIndex);
      expect(await database.fetchStoredTemplate(action.targetId), isNull);
      expect(await database.fetchInstanceForTemplate(action.targetId), isNull);
      expect(
        (await database.fetchStoredTemplate(sourcePlan.id))!.isBuiltIn,
        true,
      );
      expect(
        (await actions.fetchAction(action.id))!.status,
        AgentActionStatus.undone,
      );
      return;
    }

    if (scenario == 'draft') {
      await database.saveActiveSessionDraft(
        fakeWorkoutSessionState.copyWith(
          instanceId: migrated.instanceId,
          templateId: migrated.templateId,
        ),
      );
    } else {
      await database.logWorkout(
        WorkoutLog(
          logId: 'history-after-revision',
          instanceId: migrated.instanceId,
          workoutId: 'historical-day',
          workoutName: 'Synthetic history',
          dayLabel: 'Day 1',
          completedAt: DateTime(2026, 8, 1),
          exercises: const [],
        ),
      );
      if (scenario == 'deleted-history') {
        await database.deleteWorkoutLog('history-after-revision');
        expect(await database.fetchWorkoutLogs(migrated.instanceId), isEmpty);
      }
      expect(
        await database.hasWorkoutHistoryForInstance(migrated.instanceId),
        true,
      );
    }
    // Neither an imported historical log nor a draft advances the instance.
    expect((await database.fetchActiveInstance())!.version, migrated.version);
    await expectLater(
      coordinator.undo(action.id),
      throwsA(isA<AgentMutationConflict>()),
    );
    expect(
      (await database.fetchActiveInstance())!.instanceId,
      migrated.instanceId,
    );
    expect(await database.fetchStoredTemplate(action.targetId), isNotNull);
    expect(
      (await actions.fetchAction(action.id))!.status,
      AgentActionStatus.applied,
    );
    if (scenario == 'draft') {
      expect(
        await database.fetchActiveSessionDraft(migrated.instanceId),
        isNotNull,
      );
    }
  } finally {
    container.dispose();
  }
}
