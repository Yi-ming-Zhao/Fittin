import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fittin_v2/src/application/active_session_provider.dart';
import 'package:fittin_v2/src/application/exercise_library_provider.dart';
import 'package:fittin_v2/src/application/sync_refresh_provider.dart';
import 'package:fittin_v2/src/data/database_repository.dart';
import 'package:fittin_v2/src/data/local/local_workout_log_repository.dart';
import 'package:fittin_v2/src/domain/exercise_library.dart';
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
  const ConsistencySection({required this.label, required this.days});

  final String label;
  final List<ConsistencyDayRecord> days;
}

class AnalyticsDateRange {
  const AnalyticsDateRange({this.startInclusive, this.endInclusive});

  final DateTime? startInclusive;
  final DateTime? endInclusive;

  bool includes(DateTime timestamp) {
    if (startInclusive != null && timestamp.isBefore(startInclusive!)) {
      return false;
    }
    if (endInclusive != null && timestamp.isAfter(endInclusive!)) {
      return false;
    }
    return true;
  }
}

class MuscleLoadData {
  const MuscleLoadData({
    required this.muscle,
    required this.weightedCompletedSets,
    required this.contributingCompletedSets,
    required this.normalizedIntensity,
  });

  final ExerciseMuscle muscle;
  final double weightedCompletedSets;
  final int contributingCompletedSets;
  final double normalizedIntensity;
}

class MuscleLoadOverview {
  const MuscleLoadOverview({
    required this.loads,
    required this.totalCompletedSets,
  });

  final List<MuscleLoadData> loads;
  final int totalCompletedSets;

  bool get hasData => loads.isNotEmpty;

  MuscleLoadData? forMuscle(ExerciseMuscle muscle) {
    for (final load in loads) {
      if (load.muscle == muscle) {
        return load;
      }
    }
    return null;
  }
}

class AdvancedAnalyticsData {
  AdvancedAnalyticsData({
    required this.sectionsByRange,
    required this.muscleLoad,
    required Map<DateTime, ConsistencyDayRecord> dayRecords,
  }) : dayRecords = Map<DateTime, ConsistencyDayRecord>.unmodifiable(
         dayRecords,
       );

  final Map<ConsistencyRange, List<ConsistencySection>> sectionsByRange;
  final MuscleLoadOverview muscleLoad;
  final Map<DateTime, ConsistencyDayRecord> dayRecords;

  List<MuscleVolumeData> volumeData({
    required String Function(ExerciseMuscle muscle) labelFor,
  }) {
    if (muscleLoad.loads.isEmpty) {
      return const [];
    }
    final maxLoad = muscleLoad.loads
        .map((load) => load.weightedCompletedSets)
        .reduce(math.max);
    return muscleLoad.loads
        .take(5)
        .map(
          (load) => MuscleVolumeData(
            label: labelFor(load.muscle),
            currentSets: load.weightedCompletedSets,
            targetSets: maxLoad,
            color: _warmMuscleColor(load.normalizedIntensity),
          ),
        )
        .toList(growable: false);
  }

  List<DateTime> get recordedDates =>
      dayRecords.keys.toList(growable: false)..sort();

  DateTime? get earliestRecordedDate =>
      recordedDates.isEmpty ? null : recordedDates.first;

  DateTime? get latestRecordedDate =>
      recordedDates.isEmpty ? null : recordedDates.last;

  ConsistencyDayRecord? recordFor(DateTime date) =>
      dayRecords[DateTime(date.year, date.month, date.day)];
}

final advancedAnalyticsDataProvider = FutureProvider<AdvancedAnalyticsData>((
  ref,
) async {
  final repository = ref.watch(localWorkoutLogRepositoryProvider);
  final exerciseLibrary = await ref.watch(exerciseLibraryProvider.future);
  final activeInstance = await ref.watch(
    _activeTrainingInstanceProvider.future,
  );
  final logs = await repository.fetchAllWorkoutLogs();
  return buildAdvancedAnalytics(
    logs: logs,
    exerciseLibrary: exerciseLibrary,
    activeInstance: activeInstance,
  );
});

final _activeTrainingInstanceProvider = FutureProvider<StoredTrainingInstance?>(
  (ref) async {
    ref.watch(syncRefreshProvider);
    return ref.watch(databaseRepositoryProvider).fetchActiveInstance();
  },
);

AdvancedAnalyticsData buildAdvancedAnalytics({
  required List<WorkoutLog> logs,
  required ExerciseLibrary exerciseLibrary,
  required StoredTrainingInstance? activeInstance,
  AnalyticsDateRange? muscleLoadPeriod,
  DateTime? now,
}) {
  final referenceNow = now ?? DateTime.now();
  final normalizedLogs = [...logs]
    ..sort((a, b) => a.completedAt.compareTo(b.completedAt));

  final byDay = <DateTime, List<WorkoutLog>>{};

  for (final log in normalizedLogs) {
    final day = _normalizeDate(log.completedAt);
    final bucket = byDay.putIfAbsent(day, () => []);
    bucket.add(log);
  }

  final maxDailyVolume = byDay.values.fold<double>(0, (maximum, dayLogs) {
    final dailyVolume = dayLogs.fold<double>(
      0,
      (sum, log) => sum + _workoutVolume(log),
    );
    return math.max(maximum, dailyVolume);
  });

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

  final muscleLoad = aggregateMuscleLoad(
    logs: normalizedLogs,
    exerciseLibrary: exerciseLibrary,
    period: muscleLoadPeriod,
  );
  final dayRecords = <DateTime, ConsistencyDayRecord>{
    for (final entry in byDay.entries)
      entry.key: _dayRecord(byDay, entry.key, maxDailyVolume: maxDailyVolume),
  };
  return AdvancedAnalyticsData(
    sectionsByRange: sectionMap,
    muscleLoad: muscleLoad,
    dayRecords: dayRecords,
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
    final start = _addCalendarDays(
      currentWeekStart,
      -7 * (weekCount - 1 - index),
    );
    final days = List.generate(7, (dayIndex) {
      final date = _addCalendarDays(start, dayIndex);
      return _dayRecord(byDay, date, maxDailyVolume: maxDailyVolume);
    });
    return ConsistencySection(label: _weekLabel(start), days: days);
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
  final totalWeeks = ((gridEnd.difference(gridStart).inDays + 1) / 7).ceil();

  return List.generate(totalWeeks, (index) {
    final start = _addCalendarDays(gridStart, index * 7);
    final days = List.generate(7, (dayIndex) {
      final date = _addCalendarDays(start, dayIndex);
      final record = _dayRecord(byDay, date, maxDailyVolume: maxDailyVolume);
      return ConsistencyDayRecord(
        date: record.date,
        logs: record.logs,
        intensity: record.intensity,
        isInRange: date.month == targetMonth.month,
      );
    });
    return ConsistencySection(label: _weekLabel(start), days: days);
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
          final date = _addCalendarDays(anchor, index);
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
  final totalWeeks = math.max(
    1,
    (_calendarDayDifference(anchor, end) / 7).floor() + 1,
  );

  return List.generate(totalWeeks, (weekIndex) {
    final start = _addCalendarDays(anchor, weekIndex * 7);
    final days = List.generate(7, (dayIndex) {
      final date = _addCalendarDays(start, dayIndex);
      final record = _dayRecord(byDay, date, maxDailyVolume: maxDailyVolume);
      return ConsistencyDayRecord(
        date: record.date,
        logs: record.logs,
        intensity: record.intensity,
        isInRange: !date.isAfter(end),
        planWeekIndex: weekIndex,
      );
    });
    return ConsistencySection(label: 'W${weekIndex + 1}', days: days);
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
      : (maxDailyVolume <= 0
            ? 1.0
            : (volume / maxDailyVolume).clamp(0.18, 1.0));
  return ConsistencyDayRecord(
    date: date,
    logs: logs,
    intensity: intensity,
    isInRange: true,
  );
}

MuscleLoadOverview aggregateMuscleLoad({
  required List<WorkoutLog> logs,
  required ExerciseLibrary exerciseLibrary,
  AnalyticsDateRange? period,
}) {
  final weightedSets = <ExerciseMuscle, double>{};
  final contributingSets = <ExerciseMuscle, int>{};
  var totalCompletedSets = 0;

  for (final log in logs) {
    if (period != null && !period.includes(log.completedAt)) {
      continue;
    }
    for (final exercise in log.exercises) {
      final canonicalId = exercise.exerciseDefinitionId.trim();
      final definition =
          (canonicalId.isEmpty
              ? null
              : exerciseLibrary.findKnown(exerciseId: canonicalId)) ??
          exerciseLibrary.findKnown(
            exerciseId: exercise.exerciseId,
            name: exercise.exerciseName,
          );
      if (definition == null || definition.isSelectionSlot) {
        continue;
      }

      final completedSetCount = exercise.sets
          .where((set) => set.isCompleted && set.completedReps > 0)
          .length;
      if (completedSetCount == 0) {
        continue;
      }
      totalCompletedSets += completedSetCount;
      for (final entry in definition.muscles.weights.entries) {
        weightedSets.update(
          entry.key,
          (value) => value + entry.value * completedSetCount,
          ifAbsent: () => entry.value * completedSetCount,
        );
        contributingSets.update(
          entry.key,
          (value) => value + completedSetCount,
          ifAbsent: () => completedSetCount,
        );
      }
    }
  }

  if (weightedSets.isEmpty) {
    return const MuscleLoadOverview(loads: [], totalCompletedSets: 0);
  }

  final maximum = weightedSets.values.reduce(math.max);
  final loads =
      weightedSets.entries
          .map(
            (entry) => MuscleLoadData(
              muscle: entry.key,
              weightedCompletedSets: entry.value,
              contributingCompletedSets: contributingSets[entry.key] ?? 0,
              normalizedIntensity: maximum <= 0
                  ? 0
                  : (entry.value / maximum).clamp(0, 1),
            ),
          )
          .toList(growable: false)
        ..sort((a, b) {
          final byLoad = b.weightedCompletedSets.compareTo(
            a.weightedCompletedSets,
          );
          return byLoad != 0
              ? byLoad
              : a.muscle.index.compareTo(b.muscle.index);
        });
  return MuscleLoadOverview(
    loads: List.unmodifiable(loads),
    totalCompletedSets: totalCompletedSets,
  );
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

DateTime _normalizeDate(DateTime date) =>
    DateTime(date.year, date.month, date.day);

DateTime _startOfWeek(DateTime date) =>
    _addCalendarDays(date, -(date.weekday - DateTime.monday));

DateTime _endOfWeek(DateTime date) => _addCalendarDays(_startOfWeek(date), 6);

DateTime _addCalendarDays(DateTime date, int days) =>
    DateTime(date.year, date.month, date.day + days);

int _calendarDayDifference(DateTime start, DateTime end) => DateTime.utc(
  end.year,
  end.month,
  end.day,
).difference(DateTime.utc(start.year, start.month, start.day)).inDays;

String _weekLabel(DateTime start) {
  final end = _addCalendarDays(start, 6);
  return '${start.month}/${start.day} - ${end.month}/${end.day}';
}

Color _warmMuscleColor(double intensity) {
  return Color.lerp(
    const Color(0xFF8C4A37),
    const Color(0xFFFFB15A),
    intensity.clamp(0, 1),
  )!;
}
