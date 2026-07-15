import 'dart:convert';

import 'package:fittin_v2/src/application/exercise_library_provider.dart';
import 'package:fittin_v2/src/domain/exercise_library.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ExerciseLibrary library;

  setUpAll(() async {
    library = await ExerciseLibraryLoader().load();
  });

  test(
    'registered asset and provider load the versioned typed catalog',
    () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final provided = await container.read(exerciseLibraryProvider.future);

      expect(provided.schemaVersion, 1);
      expect(provided.catalogVersion, '1.0.0');
      expect(provided.sourceRevision, isNotEmpty);
      expect(provided.definitions, hasLength(42));
    },
  );

  test('covers all 49 legacy exercise IDs from every bundled plan', () async {
    const planPaths = [
      'assets/plans/gzclp_4day_12week.json',
      'assets/plans/jacked_and_tan_2_0.json',
      'assets/plans/powerbuilding_4day_12week.json',
      'assets/plans/tsa_intermediate_approach_2_0.json',
    ];
    final planIds = <String>{};
    for (final path in planPaths) {
      final decoded = jsonDecode(await rootBundle.loadString(path));
      planIds.addAll(_exerciseIds(decoded));
    }

    expect(planIds, hasLength(49));
    final catalogLegacyIds = {
      for (final definition in library.definitions) ...definition.legacyIds,
    };
    expect(catalogLegacyIds, hasLength(49));
    expect(catalogLegacyIds, planIds);
    for (final id in planIds) {
      expect(
        library.findKnown(exerciseId: id, name: null),
        isNotNull,
        reason: 'Unresolved built-in plan exerciseId: $id',
      );
    }
  });

  test('canonical IDs, legacy IDs, names, and aliases never cross-resolve', () {
    final owners = <String, String>{};
    for (final definition in library.definitions) {
      final keys = {
        definition.id,
        definition.nameEn,
        definition.nameZhCn,
        ...definition.legacyIds,
        ...definition.aliases,
      };
      for (final key in keys) {
        final normalized = normalizeExerciseKey(key);
        expect(normalized, isNotEmpty, reason: '${definition.id}: $key');
        final existing = owners[normalized];
        expect(
          existing == null || existing == definition.id,
          isTrue,
          reason: '$key conflicts between $existing and ${definition.id}',
        );
        owners[normalized] = definition.id;
        expect(
          library.findKnown(exerciseId: key, name: null)?.id,
          definition.id,
        );
      }
    }

    expect(library.resolve(name: 'Competition Squat').id, 'squat');
    expect(library.resolve(name: '深蹲').id, 'squat');
    expect(
      library.resolve(exerciseId: 'conventional_deadlift', name: '').id,
      'deadlift',
    );
    expect(
      library.resolve(exerciseId: 'db_seated_press', name: '').id,
      'seated_dumbbell_press',
    );
    expect(
      library.resolve(exerciseId: 'legless_bench_press', name: '').id,
      'feet_up_bench_press',
    );
  });

  test('bilingual and taxonomy fields are complete and ratios are legal', () {
    for (final definition in library.definitions) {
      expect(definition.nameEn.trim(), isNotEmpty);
      expect(definition.nameZhCn.trim(), isNotEmpty);
      expect(
        RegExp(r'[\u3400-\u9fff]').hasMatch(definition.nameZhCn),
        isTrue,
        reason: '${definition.id} must have a reviewed Chinese name',
      );
      expect(
        normalizeExerciseKey(definition.nameZhCn),
        isNot(normalizeExerciseKey(definition.nameEn)),
      );
      expect(definition.sourceIds, isNotEmpty);
      expect(definition.sourceRevision, isNotEmpty);
      expect(definition.license, isNotEmpty);

      if (definition.isSelectionSlot) {
        expect(definition.movement, ExerciseMovement.selection);
        expect(definition.equipment, ExerciseEquipment.selection);
        expect(definition.loadSemantics, ExerciseLoadSemantics.selection);
        expect(definition.muscles.primary, isEmpty);
        expect(definition.muscles.secondary, isEmpty);
        expect(definition.ratioPrior.mode, RatioPriorMode.notApplicable);
        continue;
      }

      expect(definition.muscles.primary, isNotEmpty);
      expect(definition.roundingIncrementKg, greaterThan(0));
      expect(
        definition.muscles.weights.values.fold<double>(0, (a, b) => a + b),
        closeTo(1, 0.0001),
      );
      if (definition.equipment == ExerciseEquipment.machine ||
          definition.equipment == ExerciseEquipment.cable) {
        expect(
          definition.ratioPrior.mode,
          RatioPriorMode.calibrationOnly,
          reason: '${definition.id} resistance is equipment-specific',
        );
      }

      final ratio = definition.ratioPrior;
      if (ratio.mode == RatioPriorMode.ratio) {
        expect(ratio.anchor, isNot(StrengthFamily.none));
        expect(ratio.lower, greaterThan(0));
        expect(ratio.lower!, lessThanOrEqualTo(ratio.center!));
        expect(ratio.center!, lessThanOrEqualTo(ratio.upper!));
        expect(ratio.upper!, lessThanOrEqualTo(1.25));
        expect(ratio.confidence, isNot(RatioConfidence.none));
        expect(ratio.sourceIds, isNotEmpty);
      } else {
        expect(ratio.lower, isNull);
        expect(ratio.center, isNull);
        expect(ratio.upper, isNull);
      }
    }
  });

  test('choice, SELECT, and composite plan entries remain explicit slots', () {
    const expectedSlotLegacyIds = {
      'abdominal_training',
      'athlete_movement_of_choice',
      'auxiliary_squat',
      'leg_press_or_hack_squat',
      'secondary_bench_press',
      'select_assistance_press',
    };
    final actualSlotLegacyIds = {
      for (final definition in library.definitions)
        if (definition.isSelectionSlot) ...definition.legacyIds,
    };

    expect(actualSlotLegacyIds, expectedSlotLegacyIds);
    expect(library.resolve(name: 'SELECT').isSelectionSlot, isTrue);
    expect(
      library.resolve(name: 'Leg Press or Hack Squat').isSelectionSlot,
      isTrue,
    );
  });

  test(
    'unknown custom fallback is deterministic and preserves display text',
    () {
      final first = library.resolve(
        exerciseId: 'import-row-12',
        name: ' Jefferson-Curl ',
      );
      final second = library.resolve(
        exerciseId: 'different-occurrence-id',
        name: 'jefferson curl',
      );
      final chinese = library.resolve(name: ' 泽奇深蹲！ ');

      expect(first.isCustom, isTrue);
      expect(first.id, 'custom:jeffersoncurl');
      expect(second.id, first.id);
      expect(first.displayName('zh'), 'Jefferson-Curl');
      expect(chinese.id, 'custom:泽奇深蹲');
      expect(
        library
            .resolve(exerciseId: 'custom:jeffersoncurl', name: 'Jefferson Curl')
            .id,
        'custom:jeffersoncurl',
      );
    },
  );
}

Iterable<String> _exerciseIds(dynamic value) sync* {
  if (value is List) {
    for (final item in value) {
      yield* _exerciseIds(item);
    }
    return;
  }
  if (value is! Map<String, dynamic>) {
    return;
  }
  final exerciseId = value['exerciseId'];
  if (exerciseId is String) {
    yield exerciseId;
  }
  for (final child in value.values) {
    yield* _exerciseIds(child);
  }
}
