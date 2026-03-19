import 'package:flutter_test/flutter_test.dart';
import 'package:fittin_v2/src/data/database_repository.dart';
import 'package:fittin_v2/src/data/seeds/gzclp_seed.dart';
import 'package:fittin_v2/src/data/seeds/jacked_and_tan_seed.dart';
import 'package:fittin_v2/src/domain/one_rep_max.dart';
import 'package:fittin_v2/src/domain/models/training_plan.dart';
import 'package:fittin_v2/src/domain/models/training_max.dart';

import '../support/in_memory_database_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late DatabaseRepository repository;

  setUp(() async {
    repository = InMemoryDatabaseRepository();
  });

  test('editing a built-in template saves a custom copy', () async {
    await repository.ensureDefaultProgramSeeded();
    final builtIn = await repository.fetchStoredTemplate(GzclpSeed.templateId);

    final saved = await repository.saveEditedTemplate(
      draft: builtIn!.template.copyWith(name: 'My GZCLP'),
      originalTemplateId: builtIn.template.id,
    );

    expect(saved.template.id, isNot(builtIn.template.id));
    expect(saved.template.name, 'My GZCLP');
    expect(saved.isBuiltIn, isFalse);
    expect(saved.sourceTemplateId, GzclpSeed.templateId);
    expect((await repository.fetchTemplates()).length, 3);
    expect(
      (await repository.fetchStoredTemplate(
        GzclpSeed.templateId,
      ))!.template.name,
      isNot('My GZCLP'),
    );
  });

  test(
    'editing a custom template without instances updates it in place',
    () async {
      await repository.saveTemplate(
        (await GzclpSeed.loadTemplate()).copyWith(
          id: 'custom-template',
          name: 'Custom Base',
        ),
      );

      final saved = await repository.saveEditedTemplate(
        draft: (await repository.fetchStoredTemplate(
          'custom-template',
        ))!.template.copyWith(description: 'Edited description'),
        originalTemplateId: 'custom-template',
      );

      expect(saved.template.id, 'custom-template');
      expect(saved.template.description, 'Edited description');
      expect((await repository.fetchTemplates()).length, 1);
    },
  );

  test('template metadata persists richer editor fields', () async {
    final base = await GzclpSeed.loadTemplate();
    final template = base.copyWith(
      id: 'rich-template',
      scheduleMode: PlanScheduleModes.linear,
      phases: [
        base.phases.first.copyWith(
          workouts: [
            base.workouts.first.copyWith(
              exercises: [
                base.workouts.first.exercises.first.copyWith(
                  loadUnit: LoadUnits.percent1rm,
                  stages: [
                    base.workouts.first.exercises.first.stages.first.copyWith(
                      sets: [
                        base
                            .workouts
                            .first
                            .exercises
                            .first
                            .stages
                            .first
                            .sets
                            .first
                            .copyWith(setType: SetTypes.topSet),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ],
    );

    await repository.saveTemplate(template);
    final loaded = await repository.fetchTemplate('rich-template');

    expect(loaded!.resolvedScheduleMode, PlanScheduleModes.linear);
    expect(
      loaded.workouts.first.exercises.first.loadUnit,
      LoadUnits.percent1rm,
    );
    expect(
      loaded
          .workouts
          .first
          .exercises
          .first
          .stages
          .first
          .sets
          .first
          .resolvedSetType,
      SetTypes.topSet,
    );
  });

  test('editing a template with active instances forks a new copy', () async {
    await repository.saveTemplate(
      (await GzclpSeed.loadTemplate()).copyWith(
        id: 'active-template',
        name: 'Active Template',
      ),
    );
    await repository.saveInstance(
      StoredTrainingInstance(
        instanceId: 'instance-1',
        templateId: 'active-template',
        currentWorkoutIndex: 0,
        states: GzclpSeed.buildStarterStates(await GzclpSeed.loadTemplate()),
      ),
    );

    final saved = await repository.saveEditedTemplate(
      draft: (await repository.fetchStoredTemplate(
        'active-template',
      ))!.template.copyWith(name: 'Forked Copy'),
      originalTemplateId: 'active-template',
    );

    expect(saved.template.id, isNot('active-template'));
    expect(saved.template.name, 'Forked Copy');
    expect(saved.sourceTemplateId, 'active-template');
    expect(
      (await repository.fetchStoredTemplate('active-template'))!.instanceCount,
      1,
    );
  });

  test(
    'activateTemplate requires training maxes for built-ins, then reuses instances',
    () async {
      await repository.ensureDefaultProgramSeeded();

      expect(await repository.fetchActiveInstanceId(), isNull);
      expect(
        await repository.activationRequirementForTemplate(
          JackedAndTanSeed.templateId,
        ),
        isNotNull,
      );

      final jackedAndTanInstance = await repository.activateTemplate(
        JackedAndTanSeed.templateId,
        trainingMaxProfile: const TrainingMaxProfile({
          'squat': 180,
          'bench': 110,
          'deadlift': 220,
          'overhead_press': 70,
        }),
      );
      final repeatedSelection = await repository.activateTemplate(
        JackedAndTanSeed.templateId,
      );

      expect(jackedAndTanInstance.instanceId, JackedAndTanSeed.instanceId);
      expect(repeatedSelection.instanceId, JackedAndTanSeed.instanceId);
      expect(repeatedSelection.trainingMaxProfile.require('squat'), 180);
      expect(
        await repository.fetchActiveInstanceId(),
        JackedAndTanSeed.instanceId,
      );

      await repository.saveTemplate(
        (await GzclpSeed.loadTemplate()).copyWith(
          id: 'custom-template',
          name: 'Custom Template',
          engineFamily: 'legacy',
          requiredTrainingMaxKeys: const [],
        ),
      );

      final created = await repository.activateTemplate('custom-template');
      final reused = await repository.activateTemplate('custom-template');

      expect(created.templateId, 'custom-template');
      expect(reused.instanceId, created.instanceId);
      expect((await repository.fetchTemplates()).length, 3);
    },
  );

  test(
    'ensureDefaultProgramSeeded preserves an existing active plan selection',
    () async {
      await repository.ensureDefaultProgramSeeded();
      await repository.activateTemplate(
        JackedAndTanSeed.templateId,
        trainingMaxProfile: const TrainingMaxProfile({
          'squat': 180,
          'bench': 110,
          'deadlift': 220,
          'overhead_press': 70,
        }),
      );

      expect(
        await repository.fetchActiveInstanceId(),
        JackedAndTanSeed.instanceId,
      );

      await repository.ensureDefaultProgramSeeded();

      expect(
        await repository.fetchActiveInstanceId(),
        JackedAndTanSeed.instanceId,
      );
    },
  );

  test('built-in activation throws without a training max profile', () async {
    await repository.ensureDefaultProgramSeeded();

    expect(
      () => repository.activateTemplate(GzclpSeed.templateId),
      throwsA(isA<StateError>()),
    );
  });

  test('analytics formula preference persists', () async {
    expect(await repository.fetchAnalyticsFormula(), OneRepMaxFormula.epley);

    await repository.saveAnalyticsFormula(OneRepMaxFormula.brzycki);

    expect(await repository.fetchAnalyticsFormula(), OneRepMaxFormula.brzycki);
  });

  test(
    'claimLocalDataForUser migrates anonymous local records into user scope',
    () async {
      await repository.saveTemplate(
        (await GzclpSeed.loadTemplate()).copyWith(
          id: 'anon-template',
          name: 'Anonymous Template',
        ),
      );
      await repository.saveInstance(
        StoredTrainingInstance(
          instanceId: 'anon-instance',
          templateId: 'anon-template',
          currentWorkoutIndex: 0,
          states: GzclpSeed.buildStarterStates(await GzclpSeed.loadTemplate()),
        ),
      );

      await repository.claimLocalDataForUser('user-123');

      final template = await repository.fetchStoredTemplate(
        'anon-template',
        ownerUserId: 'user-123',
      );
      final instance = await repository.fetchInstanceForTemplate(
        'anon-template',
        ownerUserId: 'user-123',
      );

      expect(template, isNotNull);
      expect(template!.ownerUserId, 'user-123');
      expect(template.syncStatus, 'pending_upload');
      expect(instance, isNotNull);
      expect(instance!.ownerUserId, 'user-123');
      expect(instance.syncStatus, 'pending_upload');
    },
  );

  test('fetchOrCreateDeviceId returns a stable device id', () async {
    final first = await repository.fetchOrCreateDeviceId();
    final second = await repository.fetchOrCreateDeviceId();

    expect(first, isNotEmpty);
    expect(second, first);
  });
}
