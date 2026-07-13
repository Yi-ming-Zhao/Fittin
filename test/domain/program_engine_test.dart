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

    test('session display unit defaults to kilograms for weight-based lifts', () {
      const template = PlanTemplate(
        id: 'unit-template',
        name: 'Unit Test',
        description: 'Display unit defaults',
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
                    id: 'bench-day1',
                    exerciseId: 'bench_press',
                    name: 'Bench Press',
                    loadUnit: LoadUnits.lbs,
                    stages: [
                      SetScheme(
                        id: 'stage-1',
                        name: '3x5',
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
        instanceId: 'unit-instance',
        templateId: template.id,
        currentWorkoutIndex: 0,
        states: const [
          TrainingState(
            workoutId: 'day1',
            exerciseId: 'bench-day1',
            exerciseName: 'Bench Press',
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

      expect(session.exercises.first.displayLoadUnit, LoadUnits.kg);
    });

    test('RPE-only prescriptions use the workbook percentage chart', () {
      const template = PlanTemplate(
        id: 'rpe-template',
        name: 'RPE Test',
        description: 'RPE-derived loads',
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
                    roundingIncrement: 2.5,
                    stages: [
                      SetScheme(
                        id: 'stage-1',
                        name: 'RPE work',
                        sets: [
                          SetDefinition(
                            targetReps: 6,
                            intensity: 1.0,
                            targetRpe: 7.5,
                          ),
                          SetDefinition(
                            targetReps: 1,
                            intensity: 0.001,
                            targetRpe: 8.0,
                          ),
                          SetDefinition(
                            targetReps: 6,
                            intensity: 0.8,
                            targetRpe: 7.5,
                          ),
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
        instanceId: 'rpe-instance',
        templateId: template.id,
        currentWorkoutIndex: 0,
        states: const [
          TrainingState(
            workoutId: 'day1',
            exerciseId: 'squat-day1',
            exerciseName: 'Squat',
            baseWeight: 200,
            currentStageId: 'stage-1',
          ),
        ],
      );

      final session = const LinearProgramEngine().buildSession(
        template: template,
        instance: instance,
        workout: template.workoutByIndex(0),
        stateByExerciseId: {'squat-day1': instance.states.first},
      );

      expect(session.exercises.first.sets.map((set) => set.targetWeight), [
        155,
        185,
        160,
      ]);
    });

    test('completed sets default missing performed RPE to target RPE', () {
      const template = PlanTemplate(
        id: 'rpe-log-template',
        name: 'RPE Log Test',
        description: 'RPE log defaults',
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
                    id: 'bench-day1',
                    exerciseId: 'bench',
                    name: 'Bench Press',
                    stages: [
                      SetScheme(
                        id: 'stage-1',
                        name: 'RPE work',
                        sets: [
                          SetDefinition(
                            targetReps: 5,
                            intensity: 0.8,
                            targetRpe: 8.0,
                          ),
                          SetDefinition(
                            targetReps: 5,
                            intensity: 0.8,
                            targetRpe: 8.0,
                          ),
                          SetDefinition(
                            targetReps: 5,
                            intensity: 0.8,
                            targetRpe: 8.0,
                          ),
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
        instanceId: 'rpe-log-instance',
        templateId: template.id,
        currentWorkoutIndex: 0,
        states: const [
          TrainingState(
            workoutId: 'day1',
            exerciseId: 'bench-day1',
            exerciseName: 'Bench Press',
            baseWeight: 100,
            currentStageId: 'stage-1',
          ),
        ],
      );
      const engine = LinearProgramEngine();
      final session = engine.buildSession(
        template: template,
        instance: instance,
        workout: template.workoutByIndex(0),
        stateByExerciseId: {'bench-day1': instance.states.first},
      );
      final completedSession = session.copyWith(
        exercises: [
          session.exercises.first.copyWith(
            sets: [
              session.exercises.first.sets[0].copyWith(isCompleted: true),
              session.exercises.first.sets[1].copyWith(
                isCompleted: true,
                completedRpe: 9.0,
              ),
              session.exercises.first.sets[2],
            ],
          ),
        ],
      );

      final result = engine.conclude(
        template: template,
        instance: instance,
        session: completedSession,
        stateByExerciseId: {'bench-day1': instance.states.first},
      );

      expect(result.logs.single.sets.map((set) => set.completedRpe), [
        8.0,
        9.0,
        null,
      ]);
    });
  });
}
