import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fittin_v2/src/application/active_session_provider.dart';
import 'package:fittin_v2/src/domain/models/workout_log.dart';
import 'package:fittin_v2/src/domain/one_rep_max.dart';

class ExercisePerformancePoint {
  const ExercisePerformancePoint({
    required this.completedAt,
    required this.weight,
    required this.reps,
    required this.value,
    required this.isActual,
  });

  final DateTime completedAt;
  final double weight;
  final int reps;
  final double value;
  final bool isActual;
}

class ExerciseProgressSummary {
  const ExerciseProgressSummary({
    required this.exerciseId,
    required this.exerciseName,
    required this.encounterCount,
    required this.currentEstimatedOneRepMax,
    required this.bestEstimatedOneRepMax,
    required this.currentActualOneRepMax,
    required this.bestActualOneRepMax,
    required this.recentChange,
    required this.totalVolume,
    required this.lastCompletedAt,
    required this.isStagnating,
    required this.personalRecords,
    required this.estimatedHistory,
    required this.actualHistory,
  });

  final String exerciseId;
  final String exerciseName;
  final int encounterCount;
  final double? currentEstimatedOneRepMax;
  final double? bestEstimatedOneRepMax;
  final double? currentActualOneRepMax;
  final double? bestActualOneRepMax;
  final double? recentChange;
  final double totalVolume;
  final DateTime? lastCompletedAt;
  final bool isStagnating;
  final List<String> personalRecords;
  final List<ExercisePerformancePoint> estimatedHistory;
  final List<ExercisePerformancePoint> actualHistory;
}

class ProgressAnalyticsOverview {
  const ProgressAnalyticsOverview({
    required this.completedWorkoutCount,
    required this.recentTrainingDays,
    required this.recentVolume,
    required this.exerciseSummaries,
    required this.highlightExerciseId,
  });

  final int completedWorkoutCount;
  final int recentTrainingDays;
  final double recentVolume;
  final List<ExerciseProgressSummary> exerciseSummaries;
  final String? highlightExerciseId;
}

final analyticsFormulaProvider =
    StateNotifierProvider<AnalyticsFormulaNotifier, OneRepMaxFormula>((ref) {
      return AnalyticsFormulaNotifier(ref);
    });

class AnalyticsFormulaNotifier extends StateNotifier<OneRepMaxFormula> {
  AnalyticsFormulaNotifier(this._ref) : super(OneRepMaxFormula.epley) {
    _load();
  }

  final Ref _ref;

  Future<void> _load() async {
    final formula = await _ref.read(databaseRepositoryProvider).fetchAnalyticsFormula();
    if (mounted) {
      state = formula;
    }
  }

  Future<void> setFormula(OneRepMaxFormula formula) async {
    if (state == formula) {
      return;
    }
    state = formula;
    await _ref.read(databaseRepositoryProvider).saveAnalyticsFormula(formula);
  }
}

final progressAnalyticsOverviewProvider =
    FutureProvider<ProgressAnalyticsOverview>((ref) async {
      final repository = ref.watch(databaseRepositoryProvider);
      final formula = ref.watch(analyticsFormulaProvider);
      final logs = await repository.fetchAllWorkoutLogs();
      return buildProgressAnalytics(logs, formula);
    });

ProgressAnalyticsOverview buildProgressAnalytics(
  List<WorkoutLog> logs,
  OneRepMaxFormula formula,
) {
  final byExercise = <String, List<_ExerciseLogEntry>>{};
  final now = DateTime.now();
  double recentVolume = 0;
  final recentTrainingDays = <String>{};

  for (final log in logs) {
    final isRecent = now.difference(log.completedAt).inDays <= 30;
    if (isRecent) {
      recentTrainingDays.add(
        '${log.completedAt.year}-${log.completedAt.month}-${log.completedAt.day}',
      );
    }

    for (final exercise in log.exercises) {
      byExercise.putIfAbsent(exercise.exerciseId, () => []).add(
        _ExerciseLogEntry(
          exerciseId: exercise.exerciseId,
          exerciseName: exercise.exerciseName,
          completedAt: log.completedAt,
          sets: exercise.sets,
        ),
      );

      if (isRecent) {
        for (final set in exercise.sets) {
          if (set.isCompleted && set.weight > 0 && set.completedReps > 0) {
            recentVolume += set.weight * set.completedReps;
          }
        }
      }
    }
  }

  final summaries = byExercise.entries
      .map((entry) => _buildExerciseSummary(entry.key, entry.value, formula))
      .whereType<ExerciseProgressSummary>()
      .toList()
    ..sort((a, b) {
      final deltaA = a.recentChange ?? -999999;
      final deltaB = b.recentChange ?? -999999;
      return deltaB.compareTo(deltaA);
    });

  return ProgressAnalyticsOverview(
    completedWorkoutCount: logs.length,
    recentTrainingDays: recentTrainingDays.length,
    recentVolume: recentVolume,
    exerciseSummaries: summaries,
    highlightExerciseId: summaries.isEmpty ? null : summaries.first.exerciseId,
  );
}

ExerciseProgressSummary? _buildExerciseSummary(
  String exerciseId,
  List<_ExerciseLogEntry> entries,
  OneRepMaxFormula formula,
) {
  entries.sort((a, b) => a.completedAt.compareTo(b.completedAt));
  final estimatedPoints = <ExercisePerformancePoint>[];
  final actualPoints = <ExercisePerformancePoint>[];
  double totalVolume = 0;
  String exerciseName = entries.last.exerciseName;
  final prs = <String>{};

  for (final entry in entries) {
    exerciseName = entry.exerciseName;
    ExercisePerformancePoint? bestEstimated;
    for (final set in entry.sets) {
      if (!set.isCompleted) {
        continue;
      }
      if (set.weight > 0 && set.completedReps > 0) {
        totalVolume += set.weight * set.completedReps;
      }
      if (_isActualOneRepMaxSet(set)) {
        final point = ExercisePerformancePoint(
          completedAt: entry.completedAt,
          weight: set.weight,
          reps: 1,
          value: set.weight,
          isActual: true,
        );
        actualPoints.add(point);
      }
      if (!_isEligibleEstimatedSet(set)) {
        continue;
      }
      final value = estimateOneRepMax(
        formula: formula,
        weight: set.weight,
        reps: set.completedReps,
      );
      if (value == null) {
        continue;
      }
      final point = ExercisePerformancePoint(
        completedAt: entry.completedAt,
        weight: set.weight,
        reps: set.completedReps,
        value: value,
        isActual: false,
      );
      if (bestEstimated == null || point.value > bestEstimated.value) {
        bestEstimated = point;
      }
    }
    if (bestEstimated != null) {
      estimatedPoints.add(bestEstimated);
    }
  }

  if (estimatedPoints.isEmpty && actualPoints.isEmpty) {
    return null;
  }

  final currentEstimated = estimatedPoints.isEmpty ? null : estimatedPoints.last.value;
  final bestEstimated = estimatedPoints.isEmpty
      ? null
      : estimatedPoints.map((point) => point.value).reduce((a, b) => a > b ? a : b);
  final currentActual = actualPoints.isEmpty ? null : actualPoints.last.value;
  final bestActual = actualPoints.isEmpty
      ? null
      : actualPoints.map((point) => point.value).reduce((a, b) => a > b ? a : b);
  final recentChange = estimatedPoints.length >= 2
      ? estimatedPoints.last.value - estimatedPoints[estimatedPoints.length - 2].value
      : null;

  if (bestEstimated != null && currentEstimated == bestEstimated) {
    prs.add('e1RM PR');
  }
  if (bestActual != null && currentActual == bestActual) {
    prs.add('1RM PR');
  }
  if (entries.isNotEmpty) {
    final strongestSet = entries
        .expand((entry) => entry.sets)
        .where((set) => set.isCompleted)
        .fold<SetLog?>(null, (best, set) {
          if (best == null) {
            return set;
          }
          final bestScore = best.weight * best.completedReps;
          final setScore = set.weight * set.completedReps;
          return setScore > bestScore ? set : best;
        });
    if (strongestSet != null) {
      prs.add('${strongestSet.weight.toStringAsFixed(1)} x ${strongestSet.completedReps}');
    }
  }

  final lastCompletedAt = entries.last.completedAt;
  final isStagnating = (currentEstimated != null || currentActual != null) &&
      DateTime.now().difference(lastCompletedAt).inDays >= 42;

  return ExerciseProgressSummary(
    exerciseId: exerciseId,
    exerciseName: exerciseName,
    encounterCount: entries.length,
    currentEstimatedOneRepMax: currentEstimated,
    bestEstimatedOneRepMax: bestEstimated,
    currentActualOneRepMax: currentActual,
    bestActualOneRepMax: bestActual,
    recentChange: recentChange,
    totalVolume: totalVolume,
    lastCompletedAt: lastCompletedAt,
    isStagnating: isStagnating,
    personalRecords: prs.toList(),
    estimatedHistory: estimatedPoints,
    actualHistory: actualPoints,
  );
}

bool _isEligibleEstimatedSet(SetLog set) {
  if (!set.isCompleted || set.weight <= 0) {
    return false;
  }
  return set.completedReps >= 1 && set.completedReps <= 10;
}

bool _isActualOneRepMaxSet(SetLog set) {
  return set.isCompleted && set.weight > 0 && set.completedReps == 1;
}

class _ExerciseLogEntry {
  const _ExerciseLogEntry({
    required this.exerciseId,
    required this.exerciseName,
    required this.completedAt,
    required this.sets,
  });

  final String exerciseId;
  final String exerciseName;
  final DateTime completedAt;
  final List<SetLog> sets;
}
