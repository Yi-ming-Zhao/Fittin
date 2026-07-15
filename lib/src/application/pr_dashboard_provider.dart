import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fittin_v2/src/application/milestone_preferences_provider.dart';
import 'package:fittin_v2/src/application/progress_analytics_provider.dart';

enum PRMetricMode { estimated, actual }

enum PRMilestoneType { estimated, actual }

class PRDashboardData {
  PRDashboardData({
    this.squat,
    this.bench,
    this.deadlift,
    required this.allMilestones,
  });

  final ExerciseProgressSummary? squat;
  final ExerciseProgressSummary? bench;
  final ExerciseProgressSummary? deadlift;
  final List<PRMilestone> allMilestones;

  List<PRMilestone> get recentMilestones => allMilestones.take(2).toList();

  List<ExerciseProgressSummary> get primaryLiftSummaries =>
      [squat, bench, deadlift].whereType<ExerciseProgressSummary>().toList();
}

class PRMilestone {
  PRMilestone({
    required this.date,
    required this.exerciseId,
    required this.exerciseName,
    required this.type,
    required this.label,
    required this.value,
    this.summary,
  });

  final DateTime date;
  final String exerciseId;
  final String exerciseName;
  final PRMilestoneType type;
  final String label;
  final double value;
  final ExerciseProgressSummary? summary;
}

final prDashboardDataProvider = Provider<AsyncValue<PRDashboardData>>((ref) {
  final analyticsAsync = ref.watch(progressAnalyticsOverviewProvider);
  final milestoneExerciseIds = ref.watch(
    milestoneExercisePreferencesProvider.select(
      (preferences) => preferences.exerciseIds,
    ),
  );

  return analyticsAsync.whenData(
    (overview) => buildPRDashboardData(
      overview,
      milestoneExerciseIds: milestoneExerciseIds,
    ),
  );
});

PRDashboardData buildPRDashboardData(
  ProgressAnalyticsOverview overview, {
  Set<String> milestoneExerciseIds = defaultMilestoneExerciseIds,
}) {
  final squat = _findPrimaryLift(overview.exerciseSummaries, 'squat');
  final bench = _findPrimaryLift(overview.exerciseSummaries, 'bench_press');
  final deadlift = _findPrimaryLift(overview.exerciseSummaries, 'deadlift');

  final rawMilestones = <PRMilestone>[
    for (final summary in overview.exerciseSummaries)
      if (milestoneExerciseIds.contains(summary.exerciseId)) ...[
        ..._buildMilestonesForHistory(
          summary: summary,
          history: summary.estimatedHistory,
          type: PRMilestoneType.estimated,
          label: 'New e1RM PR',
        ),
        ..._buildMilestonesForHistory(
          summary: summary,
          history: summary.actualHistory,
          type: PRMilestoneType.actual,
          label: 'New 1RM PR',
        ),
      ],
  ]..sort((a, b) => b.date.compareTo(a.date));

  return PRDashboardData(
    squat: squat,
    bench: bench,
    deadlift: deadlift,
    allMilestones: rawMilestones,
  );
}

ExerciseProgressSummary? _findPrimaryLift(
  List<ExerciseProgressSummary> summaries,
  String liftKey,
) {
  for (final summary in summaries) {
    if (summary.exerciseId == liftKey) {
      return summary;
    }
  }
  return null;
}

List<PRMilestone> _buildMilestonesForHistory({
  required ExerciseProgressSummary summary,
  required List<ExercisePerformancePoint> history,
  required PRMilestoneType type,
  required String label,
}) {
  final milestones = <PRMilestone>[];
  double highestSoFar = 0;
  for (final point in history) {
    if (point.value > highestSoFar) {
      highestSoFar = point.value;
      milestones.add(
        PRMilestone(
          date: point.completedAt,
          exerciseId: summary.exerciseId,
          exerciseName: summary.exerciseName,
          type: type,
          label: label,
          value: point.value,
          summary: summary,
        ),
      );
    }
  }
  return milestones;
}
