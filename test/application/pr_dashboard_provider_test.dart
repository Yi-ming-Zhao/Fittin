import 'package:flutter_test/flutter_test.dart';
import 'package:fittin_v2/src/application/pr_dashboard_provider.dart';
import 'package:fittin_v2/src/application/progress_analytics_provider.dart';

void main() {
  test(
    'buildPRDashboardData sorts milestones and keeps only two in preview',
    () {
      final squat = _summary(
        id: 'squat',
        name: 'Competition Squat',
        estimated: [
          _point(DateTime(2026, 3, 1), 120),
          _point(DateTime(2026, 3, 10), 125),
        ],
        actual: [_point(DateTime(2026, 3, 12), 130, actual: true)],
      );
      final bench = _summary(
        id: 'bench_press',
        name: 'Bench Press',
        estimated: [_point(DateTime(2026, 3, 5), 80)],
        actual: [_point(DateTime(2026, 3, 15), 82.5, actual: true)],
      );

      final data = buildPRDashboardData(
        ProgressAnalyticsOverview(
          completedWorkoutCount: 4,
          recentTrainingDays: 4,
          recentVolume: 1000,
          exerciseSummaries: [squat, bench],
          highlightExerciseId: squat.exerciseId,
        ),
      );

      expect(data.recentMilestones.length, 2);
      expect(data.allMilestones.first.type, PRMilestoneType.actual);
      expect(data.allMilestones.first.exerciseName, 'Bench Press');
      expect(
        data.allMilestones.map((milestone) => milestone.type),
        containsAll([PRMilestoneType.estimated, PRMilestoneType.actual]),
      );
    },
  );

  test('milestones default to Big Three and honor a custom canonical set', () {
    final squat = _summary(
      id: 'squat',
      name: 'Squat',
      estimated: [_point(DateTime(2026, 3, 1), 120)],
      actual: const [],
    );
    final press = _summary(
      id: 'overhead_press',
      name: 'Overhead Press',
      estimated: [_point(DateTime(2026, 3, 2), 60)],
      actual: const [],
    );
    final overview = ProgressAnalyticsOverview(
      completedWorkoutCount: 2,
      recentTrainingDays: 2,
      recentVolume: 1000,
      exerciseSummaries: [squat, press],
      highlightExerciseId: squat.exerciseId,
    );

    expect(
      buildPRDashboardData(
        overview,
      ).allMilestones.map((item) => item.exerciseId),
      ['squat'],
    );
    expect(
      buildPRDashboardData(
        overview,
        milestoneExerciseIds: {'overhead_press'},
      ).allMilestones.map((item) => item.exerciseId),
      ['overhead_press'],
    );
  });
}

ExercisePerformancePoint _point(
  DateTime completedAt,
  double value, {
  bool actual = false,
}) {
  return ExercisePerformancePoint(
    completedAt: completedAt,
    weight: value,
    reps: actual ? 1 : 5,
    value: value,
    isActual: actual,
  );
}

ExerciseProgressSummary _summary({
  required String id,
  required String name,
  required List<ExercisePerformancePoint> estimated,
  required List<ExercisePerformancePoint> actual,
}) {
  return ExerciseProgressSummary(
    exerciseId: id,
    exerciseName: name,
    encounterCount: estimated.length + actual.length,
    currentEstimatedOneRepMax: estimated.isEmpty ? null : estimated.last.value,
    bestEstimatedOneRepMax: estimated.isEmpty
        ? null
        : estimated.map((point) => point.value).reduce((a, b) => a > b ? a : b),
    currentActualOneRepMax: actual.isEmpty ? null : actual.last.value,
    bestActualOneRepMax: actual.isEmpty
        ? null
        : actual.map((point) => point.value).reduce((a, b) => a > b ? a : b),
    recentChange: estimated.length < 2
        ? null
        : estimated.last.value - estimated[estimated.length - 2].value,
    totalVolume: 0,
    lastCompletedAt: [
      ...estimated,
      ...actual,
    ].map((point) => point.completedAt).reduce((a, b) => a.isAfter(b) ? a : b),
    isStagnating: false,
    personalRecords: const [],
    estimatedHistory: estimated,
    actualHistory: actual,
  );
}
