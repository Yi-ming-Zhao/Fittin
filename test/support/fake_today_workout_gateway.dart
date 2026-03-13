import 'package:fittin_v2/src/application/services/today_workout_gateway.dart';
import 'package:fittin_v2/src/domain/models/training_plan.dart';
import 'package:fittin_v2/src/domain/models/training_state.dart';

class FakeTodayWorkoutGateway implements TodayWorkoutGateway {
  FakeTodayWorkoutGateway({
    TodayWorkoutSummary? summary,
    WorkoutSessionState? session,
    PlanTemplate? template,
  }) : _summary = summary ?? fakeTodayWorkoutSummary,
       _session = session ?? fakeWorkoutSessionState,
       _template = template ?? fakePlanTemplate;

  final TodayWorkoutSummary _summary;
  final WorkoutSessionState _session;
  final PlanTemplate _template;

  int sessionLoadCount = 0;
  WorkoutSessionState? concludedSession;
  PlanTemplate? importedTemplate;

  @override
  Future<void> concludeWorkoutSession(WorkoutSessionState session) async {
    concludedSession = session;
  }

  @override
  Future<PlanTemplate> importSharedTemplate(PlanTemplate template) async {
    importedTemplate = template;
    return template;
  }

  @override
  Future<PlanTemplate> loadActiveTemplate() async => _template;

  @override
  Future<TodayWorkoutSummary> loadTodayWorkoutSummary() async => _summary;

  @override
  Future<WorkoutSessionState> loadTodayWorkoutSession() async {
    sessionLoadCount += 1;
    return _session;
  }
}

const fakeTodayWorkoutSummary = TodayWorkoutSummary(
  instanceId: 'instance-1',
  workoutId: 'day1',
  workoutName: 'Squat Focus',
  dayLabel: 'Day 1',
  primaryExerciseId: 'day1-squat',
  primaryExerciseName: 'Squat',
  estimatedDurationMinutes: 55,
  exerciseCount: 2,
);

const fakePlanTemplate = PlanTemplate(
  id: 'template-1',
  name: 'GZCLP 4-Day 12-Week',
  description: 'Shareable test template',
  localizedName: {'zh': 'GZCLP 四天十二周'},
  localizedDescription: {'zh': '可分享的测试模板'},
  phases: [
    Phase(
      id: 'rotation',
      name: 'Rotation',
      workouts: [
        Workout(
          id: 'day1',
          name: 'Squat Focus',
          localizedName: {'zh': '深蹲主项日'},
          dayLabel: 'Day 1',
          localizedDayLabel: {'zh': '第1天'},
          estimatedDurationMinutes: 55,
          exercises: [
            Exercise(
              id: 'day1-squat',
              exerciseId: 'squat',
              name: 'Squat',
              localizedName: {'zh': '深蹲'},
              initialBaseWeight: 135,
              tier: 'T1',
              restSeconds: 180,
              stages: [
                SetScheme(
                  id: 't1-3x5',
                  name: '3x5+',
                  sets: [
                    SetDefinition(targetReps: 5, intensity: 1, kind: 'working'),
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

const fakeWorkoutSessionState = WorkoutSessionState(
  instanceId: 'instance-1',
  templateId: 'template-1',
  workoutId: 'day1',
  workoutName: 'Squat Focus',
  dayLabel: 'Day 1',
  estimatedDurationMinutes: 55,
  exercises: [
    ExerciseSessionState(
      id: 'day1-squat',
      exerciseId: 'squat',
      exerciseName: 'Squat',
      tier: 'T1',
      restSeconds: 180,
      stageId: 't1-3x5',
      sets: [
        SessionSetState(
          id: 'day1-squat-0',
          role: 'warmup',
          targetReps: 5,
          completedReps: 5,
          targetWeight: 80,
          weight: 80,
        ),
        SessionSetState(
          id: 'day1-squat-1',
          role: 'working',
          targetReps: 5,
          completedReps: 5,
          targetWeight: 135,
          weight: 135,
          isAmrap: true,
        ),
      ],
    ),
    ExerciseSessionState(
      id: 'day1-row',
      exerciseId: 'barbell_row',
      exerciseName: 'Barbell Row',
      tier: 'T2',
      restSeconds: 120,
      stageId: 't2-3x10',
      sets: [
        SessionSetState(
          id: 'day1-row-0',
          role: 'working',
          targetReps: 10,
          completedReps: 10,
          targetWeight: 70,
          weight: 70,
          isAmrap: true,
        ),
      ],
    ),
  ],
);
