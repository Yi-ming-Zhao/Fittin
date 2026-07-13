import 'package:flutter_test/flutter_test.dart';
import 'package:fittin_v2/src/data/seeds/powerbuilding_4day_12week_seed.dart';
import 'package:fittin_v2/src/domain/models/training_plan.dart';
import 'package:fittin_v2/src/domain/template_validation.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'powerbuilding asset seeds a valid 12-week four-day built-in plan',
    () async {
      final template = await Powerbuilding4Day12WeekSeed.loadTemplate();

      expect(template.id, Powerbuilding4Day12WeekSeed.templateId);
      expect(template.engineFamily, 'periodized_tm');
      expect(template.requiredTrainingMaxKeys, ['squat', 'bench', 'deadlift']);
      expect(template.engineConfig['cycleLengthWeeks'], 12);
      expect(template.workouts.length, 4);
      expect(TemplateValidation.validate(template).errors, isEmpty);

      for (final workout in template.workouts) {
        expect(workout.exercises.length, inInclusiveRange(4, 5));
        for (final exercise in workout.exercises) {
          expect(exercise.stages.length, 12);
          for (final stage in exercise.stages) {
            for (final set in stage.sets) {
              expect(set.targetRpe, isNotNull);
            }
          }
        }
      }

      final isolatedExerciseIds = {
        'cable_lateral_raise',
        'cable_pressdown',
        'barbell_curl',
        'abdominal_training',
      };
      final isolatedExercises = template.workouts
          .expand((workout) => workout.exercises)
          .where(
            (exercise) => isolatedExerciseIds.contains(exercise.exerciseId),
          );
      for (final exercise in isolatedExercises) {
        for (final week in [1, 2, 3, 5, 6, 7, 9, 10]) {
          for (final set in exercise.stages[week - 1].sets) {
            expect(set.targetRpe, inInclusiveRange(9, 10));
          }
        }
        expect(exercise.stages.expand((stage) => stage.rules), isNotEmpty);
      }
    },
  );
}
