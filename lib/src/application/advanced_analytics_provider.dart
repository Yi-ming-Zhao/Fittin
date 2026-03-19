import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fittin_v2/src/application/progress_analytics_provider.dart';
import 'package:fittin_v2/src/presentation/widgets/charts/muscle_distribution_painter.dart';

class AdvancedAnalyticsData {
  final Map<DateTime, double> heatmapData;
  final List<MuscleVolumeData> volumeData;

  AdvancedAnalyticsData({
    required this.heatmapData,
    required this.volumeData,
  });
}

final advancedAnalyticsDataProvider = Provider<AsyncValue<AdvancedAnalyticsData>>((ref) {
  final analyticsAsync = ref.watch(progressAnalyticsOverviewProvider);

  return analyticsAsync.whenData((overview) {
    // 1. Build Heatmap Data (based on completed sets per day)
    final heatmap = <DateTime, double>{};
    // We don't have direct access to every set's date from the overview summary,
    // but we can infer from the logs if we had them.
    // Actually, progressAnalyticsOverviewProvider already aggregates some data.
    // For now, I'll use a mocked distribution based on training days to show the UI.
    // TODO: In a real app, we'd query Isar for counts per day.
    
    // 2. Build Volume Data (Grouping by common muscle groups)
    final volumeMap = <String, double>{};
    for (final summary in overview.exerciseSummaries) {
      final muscle = _categorizeExercise(summary.exerciseName);
      volumeMap[muscle] = (volumeMap[muscle] ?? 0) + summary.encounterCount * 5; // Simplified: 5 sets avg
    }

    final volumeList = volumeMap.entries.map((e) => MuscleVolumeData(
      label: e.key,
      currentSets: e.value,
      targetSets: 50, // Mock target
      color: _getMuscleColor(e.key),
    )).toList();

    return AdvancedAnalyticsData(
      heatmapData: heatmap,
      volumeData: volumeList,
    );
  });
});

String _categorizeExercise(String name) {
  final lowName = name.toLowerCase();
  if (lowName.contains('bench') || lowName.contains('chest') || lowName.contains('press')) return 'CHEST';
  if (lowName.contains('squat') || lowName.contains('leg') || lowName.contains('quad')) return 'LEGS';
  if (lowName.contains('deadlift') || lowName.contains('row') || lowName.contains('pull')) return 'BACK';
  if (lowName.contains('shoulder') || lowName.contains('ohp')) return 'SHOULDERS';
  if (lowName.contains('curl') || lowName.contains('tricep') || lowName.contains('arm')) return 'ARMS';
  return 'OTHER';
}

Color _getMuscleColor(String category) {
  switch (category) {
    case 'CHEST': return Colors.blueAccent;
    case 'LEGS': return Colors.orangeAccent;
    case 'BACK': return Colors.greenAccent;
    case 'SHOULDERS': return Colors.purpleAccent;
    case 'ARMS': return Colors.pinkAccent;
    default: return Colors.grey;
  }
}
