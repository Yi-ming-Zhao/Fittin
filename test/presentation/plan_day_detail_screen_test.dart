import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fittin_v2/src/application/active_session_provider.dart';
import 'package:fittin_v2/src/application/plan_library_provider.dart';
import 'package:fittin_v2/src/data/database_repository.dart';
import 'package:fittin_v2/src/data/seeds/seed_utils.dart';
import 'package:fittin_v2/src/domain/models/training_plan.dart';
import 'package:fittin_v2/src/domain/models/training_max.dart';
import 'package:fittin_v2/src/domain/program_engine.dart';
import 'package:fittin_v2/src/presentation/screens/plan_day_detail_screen.dart';
import '../support/fake_today_workout_gateway.dart';
import '../support/in_memory_database_repository.dart';

void main() {
  testWidgets(
    'day preview shares week prescriptions and never invents unknown loads',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(320, 568));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final exercise = fakePlanTemplate.workouts.single.exercises.single
          .copyWith(
            trainingMaxLift: 'squat',
            initialBaseWeight: 0,
            engineConfig: {
              'notes': '中文说明',
              'localizedNotes': {'en': 'Control the descent'},
            },
            stages: [
              const SetScheme(
                id: 'w1',
                name: 'Week 1',
                basePercent: .75,
                sets: [
                  SetDefinition(targetReps: 8, intensity: 1, kind: 'working'),
                ],
                rules: [],
              ),
              const SetScheme(
                id: 'w2',
                name: 'Week 2',
                basePercent: .8,
                sets: [
                  SetDefinition(targetReps: 5, intensity: 1, kind: 'working'),
                ],
                rules: [],
              ),
            ],
          );
      final workout = fakePlanTemplate.workouts.single.copyWith(
        exercises: [exercise],
      );
      final template = fakePlanTemplate.copyWith(
        engineFamily: 'periodized_tm',
        phases: [
          fakePlanTemplate.phases.single.copyWith(workouts: [workout]),
        ],
      );
      for (final known in [false, true]) {
        final profile = known
            ? const TrainingMaxProfile({'squat': 100})
            : const TrainingMaxProfile({'bench': 100});
        final states = buildStarterStatesForTemplate(template);
        final instance = StoredTrainingInstance(
          instanceId: 'existing',
          templateId: template.id,
          currentWorkoutIndex: 0,
          states: states,
          trainingMaxProfile: profile,
        );
        await tester.pumpWidget(
          ProviderScope(
            key: ValueKey(known),
            overrides: [
              databaseRepositoryProvider.overrideWithValue(
                InMemoryDatabaseRepository(),
              ),
              planInstanceProvider(
                template.id,
              ).overrideWith((ref) async => instance),
            ],
            child: MaterialApp(
              home: PlanDayDetailScreen(template: template, workout: workout),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        expect(find.text('Control the descent'), findsOneWidget);
        expect(
          find.textContaining(known ? '75.0 kg' : '75% TM'),
          findsOneWidget,
        );
        await tester.tap(find.text('Week 2'));
        await tester.pumpAndSettle();
        expect(
          find.textContaining(known ? '80.0 kg' : '80% TM'),
          findsOneWidget,
        );
        if (known) {
          final actual = ProgramEngineDispatcher.resolve(template.engineFamily)
              .buildSession(
                template: template,
                instance: instance,
                workout: workout,
                stateByExerciseId: {
                  exercise.id: states.single.copyWith(currentStageId: 'w2'),
                },
              );
          expect(
            find.textContaining(
              '${actual.exercises.single.sets.single.targetWeight} kg',
            ),
            findsOneWidget,
          );
        }
        expect(tester.takeException(), isNull);
      }
    },
  );
}
