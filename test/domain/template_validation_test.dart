import 'package:flutter_test/flutter_test.dart';
import 'package:fittin_v2/src/data/seeds/gzclp_seed.dart';
import 'package:fittin_v2/src/domain/models/training_plan.dart';
import 'package:fittin_v2/src/domain/template_validation.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('seeded GZCLP template passes validation', () async {
    final template = await GzclpSeed.loadTemplate();

    final result = TemplateValidation.validate(template);

    expect(result.errors, isEmpty);
  });

  test('invalid nested template structure surfaces actionable errors', () {
    const template = PlanTemplate(
      id: 'broken-template',
      name: ' ',
      description: 'Broken',
      phases: [
        Phase(
          id: 'phase-1',
          name: 'Main',
          workouts: [
            Workout(
              id: 'workout-1',
              name: '',
              exercises: [
                Exercise(
                  id: 'exercise-1',
                  exerciseId: 'squat',
                  name: 'Squat',
                  initialBaseWeight: 100,
                  stages: [
                    SetScheme(
                      id: 'stage-1',
                      name: '',
                      sets: [
                        SetDefinition(
                          targetReps: 0,
                          intensity: -1,
                          kind: 'drop',
                        ),
                      ],
                      rules: [
                        ProgressionRule(
                          condition: 'on_success',
                          actions: [
                            RuleAction(
                              type: 'JUMP_TO_STAGE',
                              targetStageId: 'missing-stage',
                            ),
                          ],
                        ),
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

    final result = TemplateValidation.validate(template);

    expect(result.isValid, isFalse);
    expect(result.errors, contains('Template name is required.'));
    expect(result.errors, contains('Workout "workout-1" must have a name.'));
    expect(
      result.errors,
      contains('Stage "stage-1" in exercise "Squat" must have a name.'),
    );
    expect(
      result.errors,
      contains(
        'Stage "stage-1" in exercise "Squat" must contain at least one working set.',
      ),
    );
    expect(
      result.errors,
      contains(
        'Stage "stage-1" in exercise "Squat" has a set with invalid role.',
      ),
    );
    expect(
      result.errors,
      contains(
        'Stage "stage-1" in exercise "Squat" jumps to an unknown stage.',
      ),
    );
  });
}
