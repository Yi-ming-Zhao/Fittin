import 'package:fittin_v2/src/data/database_repository.dart';
import 'package:fittin_v2/src/domain/microcycle_schedule.dart';
import 'package:fittin_v2/src/domain/models/training_max.dart';
import 'package:fittin_v2/src/domain/models/training_plan.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final template = PlanTemplate(
    id: 'five-day',
    name: 'Five day',
    description: '',
    phases: [
      Phase(
        id: 'phase',
        name: 'Phase',
        workouts: [
          for (final id in ['chest', 'back', 'legs', 'shoulders', 'arms'])
            Workout(id: id, name: id, exercises: const []),
        ],
      ),
    ],
  );

  StoredTrainingInstance instance({
    int index = 0,
    Map<String, dynamic> engineState = const {},
  }) => StoredTrainingInstance(
    instanceId: 'instance',
    templateId: template.id,
    currentWorkoutIndex: index,
    trainingMaxProfile: TrainingMaxProfile.empty,
    engineState: engineState,
    states: const [],
  );

  test(
    'moves a remaining workout to today while preserving the rest order',
    () {
      final updated = reorderMicrocycleEngineState(
        template: template,
        instance: instance(index: 1),
        nextWorkoutId: 'legs',
      );
      final resolved = resolveMicrocycleSchedule(
        template: template,
        instance: instance(index: 1, engineState: updated),
      );

      expect(resolved.orderedWorkoutIds, [
        'chest',
        'legs',
        'back',
        'shoulders',
        'arms',
      ]);
      expect(resolved.currentWorkoutId, 'legs');
    },
  );

  test('rejects an already completed workout in the current cycle', () {
    expect(
      () => reorderMicrocycleEngineState(
        template: template,
        instance: instance(index: 2),
        nextWorkoutId: 'chest',
      ),
      throwsStateError,
    );
  });

  test('clears the permutation at the next cycle boundary', () {
    final reordered = reorderMicrocycleEngineState(
      template: template,
      instance: instance(),
      nextWorkoutId: 'legs',
    );
    final normalized = normalizeMicrocycleAfterAdvance(
      template: template,
      nextWorkoutIndex: 5,
      engineState: reordered,
    );

    expect(normalized.containsKey(microcycleOrderEngineKey), isFalse);
    expect(normalized[microcycleGenerationEngineKey], 1);
  });
}
