import 'package:flutter_test/flutter_test.dart';
import 'package:fittin_v2/src/data/seeds/jacked_and_tan_seed.dart';
import 'package:fittin_v2/src/domain/models/training_plan.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'jacked and tan asset preserves the approved lineup and weekly set budget',
    () async {
      final template = await JackedAndTanSeed.loadTemplate();
      final workouts = template.workouts;

      expect(template.id, JackedAndTanSeed.templateId);
      expect(workouts.length, 4);

      final expectedLineup = <String, List<String>>{
        'Day 1': [
          'Competition Squat',
          'Block Pull',
          'Leg Press',
          'Barbell Row',
          'Leg Curl',
        ],
        'Day 2': [
          'Bench Press',
          'Close-Grip Bench Press',
          'Incline DB Bench',
          'DB Seated Press',
          'Lateral Raises',
        ],
        'Day 3': [
          'Auxiliary Squat',
          'Romanian Deadlift',
          'Close-Grip Lat Pulldown',
          'Chest-Supported Row',
          'Walking Lunge',
        ],
        'Day 4': [
          'Standing Barbell Press',
          'Slingshot Bench',
          'Legless Bench Press',
          'Wide-Grip Lat Pulldown',
          'Face Pull',
        ],
      };

      for (final workout in workouts) {
        expect(
          workout.exercises.map((exercise) => exercise.name).toList(),
          expectedLineup[workout.dayLabel],
        );
        expect(
          workout.exercises.where((exercise) => exercise.tier == 'T2').length,
          2,
        );
        expect(
          workout.exercises.where((exercise) => exercise.tier == 'T3').length,
          2,
        );
      }

      for (var weekIndex = 0; weekIndex < 6; weekIndex++) {
        final directSetsByGroup = <String, int>{
          'chest': 0,
          'back': 0,
          'quads': 0,
          'posterior_chain': 0,
          'shoulders': 0,
        };

        for (final workout in workouts) {
          for (final exercise in workout.exercises) {
            final workingSets = _workingSetCount(exercise, weekIndex);
            for (final muscleGroup in _muscleGroupsFor(exercise.name)) {
              directSetsByGroup[muscleGroup] =
                  directSetsByGroup[muscleGroup]! + workingSets;
            }
          }
        }

        for (final budget in directSetsByGroup.entries) {
          expect(
            budget.value,
            inInclusiveRange(12, 20),
            reason:
                '${budget.key} direct sets should stay in the 12-20 window in week ${weekIndex + 1}.',
          );
        }
      }
    },
  );
}

int _workingSetCount(Exercise exercise, int weekIndex) {
  final stage = exercise.stages[weekIndex];
  return stage.sets.where((set) => set.kind == 'working').length;
}

Iterable<String> _muscleGroupsFor(String exerciseName) {
  switch (exerciseName) {
    case 'Competition Squat':
    case 'Auxiliary Squat':
      return const ['quads', 'posterior_chain'];
    case 'Leg Press':
    case 'Walking Lunge':
      return const ['quads'];
    case 'Block Pull':
    case 'Romanian Deadlift':
    case 'Leg Curl':
      return const ['posterior_chain'];
    case 'Bench Press':
    case 'Close-Grip Bench Press':
    case 'Incline DB Bench':
    case 'Slingshot Bench':
    case 'Legless Bench Press':
      return const ['chest'];
    case 'Barbell Row':
    case 'Close-Grip Lat Pulldown':
    case 'Chest-Supported Row':
    case 'Wide-Grip Lat Pulldown':
      return const ['back'];
    case 'DB Seated Press':
    case 'Standing Barbell Press':
    case 'Lateral Raises':
    case 'Face Pull':
      return const ['shoulders'];
    default:
      throw ArgumentError(
        'Unexpected exercise in Jacked & Tan asset: $exerciseName',
      );
  }
}
