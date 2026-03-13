import 'package:flutter_test/flutter_test.dart';
import 'package:fittin_v2/src/data/database_repository.dart';
import 'package:fittin_v2/src/domain/models/training_max.dart';
import 'package:fittin_v2/src/domain/models/training_plan.dart';
import 'package:fittin_v2/src/domain/models/training_state.dart';
import 'package:fittin_v2/src/domain/program_engine.dart';

void main() {
  group('ProgramEngineDispatcher', () {
    test('linear_tm carries successful load increases forward', () {
      const template = PlanTemplate(
        id: 'linear-template',
        name: 'Linear',
        description: 'Test linear template',
        engineFamily: 'linear_tm',
        phases: [
          Phase(
            id: 'phase',
            name: 'Phase',
            workouts: [
              Workout(
                id: 'day1',
                name: 'Day 1',
                exercises: [
                  Exercise(
                    id: 'squat-day1',
                    exerciseId: 'squat',
                    name: 'Squat',
                    trainingMaxLift: 'squat',
                    stages: [
                      SetScheme(
                        id: 'stage-1',
                        name: '3x5+',
                        sets: [
                          SetDefinition(
                            targetReps: 5,
                            intensity: 1.0,
                            isAmrap: true,
                          ),
                        ],
                        rules: [
                          ProgressionRule(
                            condition: 'on_success',
                            actions: [
                              RuleAction(type: 'ADD_WEIGHT', amount: 5),
                              RuleAction(type: 'STAY_STAGE'),
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
      final instance = StoredTrainingInstance(
        instanceId: 'linear-instance',
        templateId: template.id,
        currentWorkoutIndex: 0,
        trainingMaxProfile: const TrainingMaxProfile({'squat': 180}),
        states: const [
          TrainingState(
            workoutId: 'day1',
            exerciseId: 'squat-day1',
            exerciseName: 'Squat',
            baseWeight: 100,
            currentStageId: 'stage-1',
          ),
        ],
      );
      final engine = ProgramEngineDispatcher.resolve(template.engineFamily);
      final session = engine.buildSession(
        template: template,
        instance: instance,
        workout: template.workoutByIndex(0),
        stateByExerciseId: {instance.states.first.exerciseId: instance.states.first},
      );
      final completedSession = session.copyWith(
        exercises: [
          session.exercises.first.copyWith(
            sets: [
              session.exercises.first.sets.first.copyWith(
                completedReps: 6,
                isCompleted: true,
              ),
            ],
          ),
        ],
      );

      final result = engine.conclude(
        template: template,
        instance: instance,
        session: completedSession,
        stateByExerciseId: {instance.states.first.exerciseId: instance.states.first},
      );

      expect(result.updatedStates.first.baseWeight, 105);
    });

    test('periodized_tm advances to the next fixed week without carry-forward', () {
      const template = PlanTemplate(
        id: 'periodized-template',
        name: 'Periodized',
        description: 'Test periodized template',
        engineFamily: 'periodized_tm',
        requiredTrainingMaxKeys: ['squat'],
        engineConfig: {'cycleLengthWeeks': 2},
        phases: [
          Phase(
            id: 'phase',
            name: 'Phase',
            workouts: [
              Workout(
                id: 'day1',
                name: 'Day 1',
                exercises: [
                  Exercise(
                    id: 'squat-day1',
                    exerciseId: 'squat',
                    name: 'Squat',
                    trainingMaxLift: 'squat',
                    trainingMaxMultiplier: 1.0,
                    stages: [
                      SetScheme(
                        id: 'week-1',
                        name: 'Week 1',
                        basePercent: 0.7,
                        sets: [
                          SetDefinition(targetReps: 6, intensity: 1.0),
                        ],
                        rules: [],
                      ),
                      SetScheme(
                        id: 'week-2',
                        name: 'Week 2',
                        basePercent: 0.75,
                        order: 1,
                        sets: [
                          SetDefinition(targetReps: 5, intensity: 1.0),
                        ],
                        rules: [],
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      );
      final instance = StoredTrainingInstance(
        instanceId: 'periodized-instance',
        templateId: template.id,
        currentWorkoutIndex: 0,
        trainingMaxProfile: const TrainingMaxProfile({'squat': 200}),
        engineState: const {'currentWeekIndex': 0, 'cycleLengthWeeks': 2},
        states: const [
          TrainingState(
            workoutId: 'day1',
            exerciseId: 'squat-day1',
            exerciseName: 'Squat',
            baseWeight: 140,
            currentStageId: 'week-1',
          ),
        ],
      );
      final engine = ProgramEngineDispatcher.resolve(template.engineFamily);
      final session = engine.buildSession(
        template: template,
        instance: instance,
        workout: template.workoutByIndex(0),
        stateByExerciseId: {instance.states.first.exerciseId: instance.states.first},
      );

      expect(session.exercises.first.sets.first.targetWeight, 140);

      final difficultSession = session.copyWith(
        exercises: [
          session.exercises.first.copyWith(
            sets: [
              session.exercises.first.sets.first.copyWith(
                completedReps: 2,
                isCompleted: true,
              ),
            ],
          ),
        ],
      );

      final result = engine.conclude(
        template: template,
        instance: instance,
        session: difficultSession,
        stateByExerciseId: {instance.states.first.exerciseId: instance.states.first},
      );

      expect(result.updatedStates.first.currentStageId, 'week-2');
      expect(result.updatedStates.first.baseWeight, 150);
      expect(result.updatedEngineState['currentWeekIndex'], 1);
    });
  });
}
