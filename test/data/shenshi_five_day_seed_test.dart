import 'dart:convert';

import 'package:fittin_v2/src/data/database_repository.dart';
import 'package:fittin_v2/src/data/models/app_state_collection.dart';
import 'package:fittin_v2/src/data/seeds/built_in_seed_coordinator.dart';
import 'package:fittin_v2/src/data/seeds/gzclp_seed.dart';
import 'package:fittin_v2/src/data/seeds/seed_utils.dart';
import 'package:fittin_v2/src/data/seeds/shenshi_five_day_seed.dart';
import 'package:fittin_v2/src/data/web_database_repository.dart';
import 'package:fittin_v2/src/data/web_local_store.dart';
import 'package:fittin_v2/src/domain/models/training_max.dart';
import 'package:fittin_v2/src/domain/models/training_plan.dart';
import 'package:fittin_v2/src/domain/template_validation.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/isar_test_helper.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'Shenshi plan preserves all five days and original prescriptions',
    () async {
      final plan = await ShenshiFiveDaySeed.loadTemplate();
      expect(plan.name, '沈师五分划');
      expect(plan.scheduleMode, PlanScheduleModes.linear);
      expect(plan.requiredTrainingMaxKeys, isEmpty);
      expect(TemplateValidation.validate(plan).errors, isEmpty);
      expect(plan.workouts.map((day) => day.name), [
        '胸部训练',
        '背部训练',
        '腿部训练',
        '肩部训练',
        '手臂训练',
      ]);
      const counts = [
        [4, 4, 4, 3],
        [4, 4, 3, 4],
        [4, 4, 3, 3, 3],
        [4, 4, 3, 3, 3],
        [4, 3, 3, 4, 3, 3],
      ];
      for (var day = 0; day < counts.length; day++) {
        expect(
          plan.workouts[day].exercises.map(
            (exercise) => exercise.stages.single.sets.length,
          ),
          counts[day],
        );
        for (var position = 0; position < counts[day].length; position++) {
          final exercise = plan.workouts[day].exercises[position];
          final amrap =
              (day == 0 && position == 2) ||
              (day == 1 && position == 0) ||
              (day == 4 && position == 3);
          final reps = day == 4 && position == 0
              ? 21
              : amrap
              ? 1
              : 12;
          for (final set in exercise.stages.single.sets) {
            expect(set.targetReps, reps);
            expect(set.isAmrap, amrap);
            expect(
              set.resolvedSetType,
              amrap ? SetTypes.amrapSet : SetTypes.straightSet,
            );
          }
          expect(exercise.initialBaseWeight, 0);
          expect(exercise.restSeconds, anyOf(60, 120));
          expect(exercise.stages.single.rules, isEmpty);
          expect(exercise.localizedName.keys, containsAll(['zh', 'en']));
        }
      }
      expect(plan.workouts[1].exercises[2].name, contains('每侧'));
      expect(plan.workouts[2].exercises[2].name, contains('每腿'));
      expect(plan.workouts[3].exercises[1].name, contains('递减组'));
      expect(plan.description, contains('上斜俯卧撑替代'));
      expect(plan.description, contains('高位下拉替代'));
      expect(plan.description, contains('慢速10次×5组'));
      expect(plan.description, contains('后期可增加到10组'));
      expect(plan.description, contains('每天20次×5组'));
      expect(plan.description, contains('48小时'));
      expect(
        builtInTemplateSeeds.where((seed) => seed.templateId == plan.id),
        hasLength(1),
      );
    },
  );

  test(
    'native seed upgrade adds Shenshi without resetting the active plan',
    () async {
      final opened = await openTestIsar('shenshi_seed_upgrade');
      addTearDown(() async {
        await opened.isar.close(deleteFromDisk: true);
        await opened.directory.delete(recursive: true);
      });
      await opened.isar.writeTxn(
        () => opened.isar.appStateCollections.put(
          AppStateCollection()
            ..stateKey = builtInTemplateSeedVersionStateKey
            ..stringValue = '1'
            ..updatedAt = DateTime.now(),
        ),
      );
      await _verifyUpgrade(DatabaseRepository(opened.isar));
      expect(
        (await opened.isar.appStateCollections.getByStateKey(
          builtInTemplateSeedVersionStateKey,
        ))!.stringValue,
        '$currentBuiltInTemplateSeedVersion',
      );
    },
  );

  test(
    'Web seed upgrade adds Shenshi without resetting the active plan',
    () async {
      final store = _MemoryStore();
      await store.putRecord(
        WebStoreNames.appState,
        builtInTemplateSeedVersionStateKey,
        {'stateKey': builtInTemplateSeedVersionStateKey, 'stringValue': '1'},
      );
      await _verifyUpgrade(WebDatabaseRepository(store));
      expect(
        (await store.getRecord(
          WebStoreNames.appState,
          builtInTemplateSeedVersionStateKey,
        ))!['stringValue'],
        '$currentBuiltInTemplateSeedVersion',
      );
    },
  );
}

Future<void> _verifyUpgrade(DatabaseRepository repository) async {
  for (final seed in builtInTemplateSeeds.where(
    (seed) => seed.templateId != ShenshiFiveDaySeed.templateId,
  )) {
    await repository.saveTemplate(await seed.loadTemplate(), isBuiltIn: true);
  }
  final template = (await repository.fetchTemplate(GzclpSeed.templateId))!;
  final instance = StoredTrainingInstance(
    instanceId: GzclpSeed.instanceId,
    templateId: template.id,
    currentWorkoutIndex: 2,
    trainingMaxProfile: const TrainingMaxProfile({
      'squat': 100,
      'bench': 80,
      'deadlift': 120,
      'overhead_press': 50,
    }),
    engineState: const {'currentWeekIndex': 3},
    states: buildStarterStatesForTemplate(template),
  );
  await repository.saveInstance(instance);
  await repository.saveActiveInstanceId(instance.instanceId);
  final before = (await repository.fetchInstance(instance.instanceId))!;

  await repository.ensureDefaultProgramSeeded();
  await repository.ensureDefaultProgramSeeded();

  final after = (await repository.fetchInstance(instance.instanceId))!;
  expect(await repository.fetchActiveInstanceId(), instance.instanceId);
  expect(after.currentWorkoutIndex, 2);
  expect(after.engineState, before.engineState);
  expect(after.trainingMaxProfile.values, before.trainingMaxProfile.values);
  expect(
    jsonEncode(after.states.map((state) => state.toJson()).toList()),
    jsonEncode(before.states.map((state) => state.toJson()).toList()),
  );
  expect(after.version, before.version);
  final added = (await repository.fetchStoredTemplate(
    ShenshiFiveDaySeed.templateId,
  ))!;
  expect(added.isBuiltIn, isTrue);
  expect(
    (await repository.fetchTemplates()).where(
      (plan) => plan.template.id == ShenshiFiveDaySeed.templateId,
    ),
    hasLength(1),
  );
}

class _MemoryStore extends WebLocalStore {
  final _records = <String, Map<String, Map<String, dynamic>>>{};

  @override
  Future<Map<String, dynamic>?> getRecord(String storeName, String key) async =>
      _records[storeName]?[key];

  @override
  Future<List<Map<String, dynamic>>> getAllRecords(String storeName) async =>
      _records[storeName]?.values.toList() ?? [];

  @override
  Future<void> putRecord(
    String storeName,
    String key,
    Map<String, dynamic> value,
  ) async {
    (_records[storeName] ??= {})[key] = value;
  }

  @override
  Future<void> deleteRecord(String storeName, String key) async {
    _records[storeName]?.remove(key);
  }
}
