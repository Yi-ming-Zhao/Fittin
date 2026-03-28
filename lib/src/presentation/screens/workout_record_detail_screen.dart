import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fittin_v2/src/domain/models/workout_log.dart';
import 'package:fittin_v2/src/presentation/localization/app_strings.dart';
import 'package:fittin_v2/src/presentation/widgets/dashboard_primitives.dart';

class WorkoutRecordDetailScreen extends ConsumerWidget {
  const WorkoutRecordDetailScreen({
    super.key,
    required this.date,
    required this.logs,
  });

  final DateTime date;
  final List<WorkoutLog> logs;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppStrings.of(context, ref);

    return Scaffold(
      backgroundColor: Colors.black,
      body: DashboardPageScaffold(
        bottomPadding: 80,
        children: [
          DashboardScreenHeader(
            eyebrow: strings.insights,
            title: strings.recordedWorkoutDetails,
            subtitle: strings.recordedDayTitle(date),
            showBackButton: true,
          ),
          const SizedBox(height: 24),
          if (logs.isEmpty)
            DashboardSurfaceCard(
              child: Text(strings.noWorkoutRecordsForDay),
            )
          else
            for (final log in logs) ...[
              DashboardSurfaceCard(
                radius: 28,
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      log.workoutName,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${log.dayLabel} · ${_timeLabel(log.completedAt)}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.6),
                      ),
                    ),
                    const SizedBox(height: 18),
                    for (final exercise in log.exercises) ...[
                      Text(
                        exercise.exerciseName,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 10),
                      for (final set in exercise.sets)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  '${strings.completedSets}: ${set.completedReps}/${set.targetReps}',
                                ),
                              ),
                              Text(
                                strings.kilograms(set.weight),
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 8),
                    ],
                    Text(
                      strings.setSummary(
                        _completedSetCount(log),
                        _workoutVolume(log),
                      ),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white.withValues(alpha: 0.54),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
            ],
        ],
      ),
    );
  }
}

String _timeLabel(DateTime dateTime) {
  final hour = dateTime.hour.toString().padLeft(2, '0');
  final minute = dateTime.minute.toString().padLeft(2, '0');
  return '$hour:$minute';
}

int _completedSetCount(WorkoutLog log) {
  return log.exercises.fold<int>(
    0,
    (sum, exercise) =>
        sum + exercise.sets.where((set) => set.isCompleted).length,
  );
}

double _workoutVolume(WorkoutLog log) {
  return log.exercises.fold<double>(
    0,
    (sum, exercise) =>
        sum +
        exercise.sets.fold<double>(
          0,
          (setSum, set) => !set.isCompleted
              ? setSum
              : setSum + (set.weight * set.completedReps),
        ),
  );
}
