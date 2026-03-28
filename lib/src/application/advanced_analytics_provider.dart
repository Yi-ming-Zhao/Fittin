import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fittin_v2/src/application/active_session_provider.dart';
import 'package:fittin_v2/src/application/progress_analytics_provider.dart';
import 'package:fittin_v2/src/data/database_repository.dart';
import 'package:fittin_v2/src/data/local/local_workout_log_repository.dart';
import 'package:fittin_v2/src/domain/models/workout_log.dart';
import 'package:fittin_v2/src/presentation/widgets/charts/muscle_distribution_painter.dart';

enum ConsistencyRange { week, month, plan }

class ConsistencyDayRecord {
  const ConsistencyDayRecord({
    required this.date,
    required this.logs,
    required this.intensity,
    required this.isInRange,
    this.planWeekIndex,
  });

  final DateTime date;
  final List<WorkoutLog> logs;
  final double intensity;
  final bool isInRange;
  final int? planWeekIndex;

  bool get hasActivity => logs.isNotEmpty;
}

class ConsistencySection {
  const ConsistencySection({
    required this.label,
    required this.days,
  });

  final String label;
  final List<ConsistencyDayRecord> days;
}

class AdvancedAnalyticsData {
  const AdvancedAnalyticsData({
    required this.sectionsByRange,
    required this.volumeData,
  });

  final Map<ConsistencyRange, List<ConsistencySection>> sectionsByRange;
  final List<MuscleVolumeData> volumeData;
}

final advancedAnalyticsDataProvider =
    FutureProvider<AdvancedAnalyticsData>((ref) async {
      final repository = ref.watch(localWorkoutLogRepositoryProvider);
      final analyticsAsync = await ref.watch(progressAnalyticsOverviewProvider.future);
      final activeInstance = await ref.watch(_activeTrainingInstanceProvider.future);
      final logs = await repository.fetchAllWorkoutLogs();
      return buildAdvancedAnalytics(
        logs: logs,
        overview: analyticsAsync,
        activeInstance: activeInstance,
      );
    });

final _activeTrainingInstanceProvider =
    FutureProvider<StoredTrainingInstance?>((ref) async {
      return ref.watch(databaseRepositoryProvider).fetchActiveInstance();
    });

AdvancedAnalyticsData buildAdvancedAnalytics({
  required List<WorkoutLog> logs,
  required ProgressAnalyticsOverview overview,
  required StoredTrainingInstance? activeInstance,
  DateTime? now,
}) {
  final referenceNow = now ?? DateTime.now();
  final normalizedLogs = [...logs]..sort((a, b) => a.completedAt.compareTo(b.completedAt));

  final byDay = <DateTime, List<WorkoutLog>>{};
  var maxDailyVolume = 0.0;

  for (final log in normalizedLogs) {
    final day = _normalizeDate(log.completedAt);
    final bucket = byDay.putIfAbsent(day, () => []);
    bucket.add(log);
    final volume = _workoutVolume(log);
    if (volume > maxDailyVolume) {
      maxDailyVolume = volume;
    }
  }

  final sectionMap = <ConsistencyRange, List<ConsistencySection>>{
    ConsistencyRange.week: _buildRecentWeekSections(
      byDay,
      referenceNow,
      maxDailyVolume,
    ),
    ConsistencyRange.month: _buildMonthSections(
      byDay,
      referenceNow,
      maxDailyVolume,
    ),
    ConsistencyRange.plan: _buildPlanSections(
      byDay,
      referenceNow,
      maxDailyVolume,
      activeInstance?.createdAt,
    ),
  };

  final volumeData = _buildVolumeData(overview);
  return AdvancedAnalyticsData(
    sectionsByRange: sectionMap,
    volumeData: volumeData,
  );
}

List<ConsistencySection> _buildRecentWeekSections(
  Map<DateTime, List<WorkoutLog>> byDay,
  DateTime now,
  double maxDailyVolume,
) {
  const weekCount = 8;
  final currentWeekStart = _startOfWeek(_normalizeDate(now));
  return List.generate(weekCount, (index) {
    final start = currentWeekStart.subtract(Duration(days: 7 * (weekCount - 1 - index)));
    final days = List.generate(7, (dayIndex) {
      final date = start.add(Duration(days: dayIndex));
      return _dayRecord(byDay, date, maxDailyVolume: maxDailyVolume);
    });
    return ConsistencySection(
      label: _weekLabel(start),
      days: days,
    );
  });
}

List<ConsistencySection> _buildMonthSections(
  Map<DateTime, List<WorkoutLog>> byDay,
  DateTime now,
  double maxDailyVolume,
) {
  final targetMonth = DateTime(now.year, now.month);
  final monthStart = DateTime(targetMonth.year, targetMonth.month, 1);
  final monthEnd = DateTime(targetMonth.year, targetMonth.month + 1, 0);
  final gridStart = _startOfWeek(monthStart);
  final gridEnd = _endOfWeek(monthEnd);
  final totalWeeks =
      ((gridEnd.difference(gridStart).inDays + 1) / 7).ceil();

  return List.generate(totalWeeks, (index) {
    final start = gridStart.add(Duration(days: index * 7));
    final days = List.generate(7, (dayIndex) {
      final date = start.add(Duration(days: dayIndex));
      final record = _dayRecord(byDay, date, maxDailyVolume: maxDailyVolume);
      return ConsistencyDayRecord(
        date: record.date,
        logs: record.logs,
        intensity: record.intensity,
        isInRange: date.month == targetMonth.month,
      );
    });
    return ConsistencySection(
      label: _weekLabel(start),
      days: days,
    );
  });
}

List<ConsistencySection> _buildPlanSections(
  Map<DateTime, List<WorkoutLog>> byDay,
  DateTime now,
  double maxDailyVolume,
  DateTime? planStart,
) {
  if (byDay.isEmpty) {
    final anchor = _startOfWeek(_normalizeDate(planStart ?? now));
    return [
      ConsistencySection(
        label: 'W1',
        days: List.generate(7, (index) {
          final date = anchor.add(Duration(days: index));
          return ConsistencyDayRecord(
            date: date,
            logs: const [],
            intensity: 0,
            isInRange: true,
            planWeekIndex: 0,
          );
        }),
      ),
    ];
  }

  final earliestLogDate = byDay.keys.reduce((a, b) => a.isBefore(b) ? a : b);
  final anchor = _startOfWeek(_normalizeDate(planStart ?? earliestLogDate));
  final end = _normalizeDate(now);
  final totalWeeks = math.max(1, ((end.difference(anchor).inDays) / 7).floor() + 1);

  return List.generate(totalWeeks, (weekIndex) {
    final start = anchor.add(Duration(days: weekIndex * 7));
    final days = List.generate(7, (dayIndex) {
      final date = start.add(Duration(days: dayIndex));
      final record = _dayRecord(byDay, date, maxDailyVolume: maxDailyVolume);
      return ConsistencyDayRecord(
        date: record.date,
        logs: record.logs,
        intensity: record.intensity,
        isInRange: !date.isAfter(end),
        planWeekIndex: weekIndex,
      );
    });
    return ConsistencySection(
      label: 'W${weekIndex + 1}',
      days: days,
    );
  });
}

ConsistencyDayRecord _dayRecord(
  Map<DateTime, List<WorkoutLog>> byDay,
  DateTime date, {
  required double maxDailyVolume,
}) {
  final logs = byDay[date] ?? const [];
  final volume = logs.fold<double>(0, (sum, log) => sum + _workoutVolume(log));
  final intensity = logs.isEmpty
      ? 0.0
      : (maxDailyVolume <= 0 ? 1.0 : (volume / maxDailyVolume).clamp(0.18, 1.0));
  return ConsistencyDayRecord(
    date: date,
    logs: logs,
    intensity: intensity,
    isInRange: true,
  );
}

List<MuscleVolumeData> _buildVolumeData(ProgressAnalyticsOverview overview) {
  final volumeMap = <String, double>{};
  for (final summary in overview.exerciseSummaries) {
    final muscle = _categorizeExercise(summary.exerciseName);
    volumeMap[muscle] = (volumeMap[muscle] ?? 0) + summary.encounterCount * 5;
  }

  return volumeMap.entries
      .map(
        (e) => MuscleVolumeData(
          label: e.key,
          currentSets: e.value,
          targetSets: 50,
          color: _getMuscleColor(e.key),
        ),
      )
      .toList();
}

double _workoutVolume(WorkoutLog log) {
  var total = 0.0;
  for (final exercise in log.exercises) {
    for (final set in exercise.sets) {
      if (set.isCompleted && set.weight > 0 && set.completedReps > 0) {
        total += set.weight * set.completedReps;
      }
    }
  }
  return total;
}

DateTime _normalizeDate(DateTime date) => DateTime(date.year, date.month, date.day);

DateTime _startOfWeek(DateTime date) =>
    date.subtract(Duration(days: date.weekday - DateTime.monday));

DateTime _endOfWeek(DateTime date) =>
    _startOfWeek(date).add(const Duration(days: 6));

String _weekLabel(DateTime start) {
  final end = start.add(const Duration(days: 6));
  return '${start.month}/${start.day} - ${end.month}/${end.day}';
}

String _categorizeExercise(String name) {
  final lowName = name.toLowerCase();
  if (lowName.contains('bench') ||
      lowName.contains('chest') ||
      lowName.contains('press')) {
    return 'CHEST';
  }
  if (lowName.contains('squat') ||
      lowName.contains('leg') ||
      lowName.contains('quad')) {
    return 'LEGS';
  }
  if (lowName.contains('deadlift') ||
      lowName.contains('row') ||
      lowName.contains('pull')) {
    return 'BACK';
  }
  if (lowName.contains('shoulder') || lowName.contains('ohp')) {
    return 'SHOULDERS';
  }
  if (lowName.contains('curl') ||
      lowName.contains('tricep') ||
      lowName.contains('arm')) {
    return 'ARMS';
  }
  return 'OTHER';
}

Color _getMuscleColor(String category) {
  switch (category) {
    case 'CHEST':
      return Colors.blueAccent;
    case 'LEGS':
      return Colors.orangeAccent;
    case 'BACK':
      return Colors.greenAccent;
    case 'SHOULDERS':
      return Colors.purpleAccent;
    case 'ARMS':
      return Colors.pinkAccent;
    default:
      return Colors.grey;
  }
}
