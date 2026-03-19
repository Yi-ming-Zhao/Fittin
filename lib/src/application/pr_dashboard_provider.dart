import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fittin_v2/src/application/progress_analytics_provider.dart';

class PRDashboardData {
  final ExerciseProgressSummary? squat;
  final ExerciseProgressSummary? bench;
  final ExerciseProgressSummary? deadlift;
  final List<PRMilestone> milestones;

  PRDashboardData({
    this.squat,
    this.bench,
    this.deadlift,
    required this.milestones,
  });
}

class PRMilestone {
  final DateTime date;
  final String exerciseName;
  final String label;
  final double value;
  final ExerciseProgressSummary? summary;

  PRMilestone({
    required this.date,
    required this.exerciseName,
    required this.label,
    required this.value,
    this.summary,
  });
}

final prDashboardDataProvider = Provider<AsyncValue<PRDashboardData>>((ref) {
  final analyticsAsync = ref.watch(progressAnalyticsOverviewProvider);

  return analyticsAsync.whenData((overview) {
    final squat = overview.exerciseSummaries.firstWhereOrNull(
      (e) => e.exerciseName.toLowerCase().contains('squat'),
    );
    final bench = overview.exerciseSummaries.firstWhereOrNull(
      (e) => e.exerciseName.toLowerCase().contains('bench'),
    );
    final deadlift = overview.exerciseSummaries.firstWhereOrNull(
      (e) => e.exerciseName.toLowerCase().contains('deadlift'),
    );

    // Build milestones from all exercises
    final rawMilestones = <PRMilestone>[];
    for (final summary in overview.exerciseSummaries) {
      if (summary.estimatedHistory.isNotEmpty) {
        // Simple heuristic: anytime bestEstimatedOneRepMax was reached
        double highestSoFar = 0;
        for (final point in summary.estimatedHistory) {
          if (point.value > highestSoFar) {
            highestSoFar = point.value;
            rawMilestones.add(
              PRMilestone(
                date: point.completedAt,
                exerciseName: summary.exerciseName,
                label: 'New e1RM PR',
                value: point.value,
                summary: summary,
              ),
            );
          }
        }
      }
    }

    rawMilestones.sort((a, b) => b.date.compareTo(a.date));

    return PRDashboardData(
      squat: squat,
      bench: bench,
      deadlift: deadlift,
      milestones: rawMilestones.take(10).toList(),
    );
  });
});
