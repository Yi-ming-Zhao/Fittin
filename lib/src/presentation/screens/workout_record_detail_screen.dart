import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fittin_v2/src/application/active_session_provider.dart';
import 'package:fittin_v2/src/application/auth_provider.dart';
import 'package:fittin_v2/src/domain/workout_session_editing.dart';
import 'package:fittin_v2/src/presentation/screens/active_session_screen.dart';
import 'package:fittin_v2/src/application/advanced_analytics_provider.dart';
import 'package:fittin_v2/src/application/fittin_theme_provider.dart';
import 'package:fittin_v2/src/application/exercise_library_provider.dart';
import 'package:fittin_v2/src/application/progress_analytics_provider.dart';
import 'package:fittin_v2/src/data/local/local_workout_log_repository.dart';
import 'package:fittin_v2/src/domain/models/training_plan.dart';
import 'package:fittin_v2/src/domain/models/workout_log.dart';
import 'package:fittin_v2/src/domain/exercise_library.dart';
import 'package:fittin_v2/src/domain/weight_tools.dart';
import 'package:fittin_v2/src/presentation/localization/app_strings.dart';
import 'package:fittin_v2/src/presentation/widgets/dashboard_primitives.dart';

class WorkoutRecordDetailScreen extends ConsumerStatefulWidget {
  const WorkoutRecordDetailScreen({
    super.key,
    required this.date,
    required this.logs,
  });

  final DateTime date;
  final List<WorkoutLog> logs;

  @override
  ConsumerState<WorkoutRecordDetailScreen> createState() =>
      _WorkoutRecordDetailScreenState();
}

class _WorkoutRecordDetailScreenState
    extends ConsumerState<WorkoutRecordDetailScreen> {
  late List<WorkoutLog> _logs;

  @override
  void initState() {
    super.initState();
    _logs = [...widget.logs];
  }

  @override
  void didUpdateWidget(covariant WorkoutRecordDetailScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.logs != widget.logs || oldWidget.date != widget.date) {
      _logs = [...widget.logs];
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context, ref);
    final exerciseLibrary = ref.watch(exerciseLibraryProvider).valueOrNull;
    final fittinTheme = ref.watch(resolvedFittinThemeProvider);

    return Scaffold(
      backgroundColor: fittinTheme.bg,
      body: DashboardPageScaffold(
        layout: DashboardPageLayout.detail,
        children: [
          DashboardScreenHeader(
            eyebrow: strings.insights,
            title: strings.recordedWorkoutDetails,
            subtitle: strings.recordedDayTitle(widget.date),
            showBackButton: true,
          ),
          const SizedBox(height: 24),
          if (_logs.isEmpty)
            DashboardSurfaceCard(child: Text(strings.noWorkoutRecordsForDay))
          else
            for (final log in _logs) ...[
              DashboardSurfaceCard(
                radius: 28,
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            log.workoutName,
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                        ),
                        Wrap(
                          spacing: 6,
                          children: [
                            TextButton.icon(
                              key: ValueKey('edit-workout-${log.logId}'),
                              onPressed: () => _editLog(context, log),
                              icon: const Icon(Icons.edit_rounded, size: 17),
                              label: Text(strings.edit),
                              style: _recordActionStyle(context),
                            ),
                            TextButton.icon(
                              key: ValueKey('delete-workout-${log.logId}'),
                              onPressed: () => _confirmDeleteLog(context, log),
                              icon: const Icon(
                                Icons.delete_outline_rounded,
                                size: 17,
                              ),
                              label: Text(strings.delete),
                              style: _recordActionStyle(
                                context,
                                foregroundColor: fittinTheme.danger,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${log.dayLabel} · ${_timeLabel(log.completedAt)}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: fittinTheme.fgDim,
                      ),
                    ),
                    const SizedBox(height: 18),
                    for (final exercise in log.exercises) ...[
                      Text(
                        _localizedExerciseLogName(
                          exercise,
                          exerciseLibrary,
                          strings,
                        ),
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 10),
                      for (final set in exercise.sets)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  '${set.isSkipped
                                      ? strings.setStatusSkipped
                                      : set.isCompleted
                                      ? strings.setStatusCompleted
                                      : strings.setStatusPending} · ${set.completedReps}/${set.targetReps}${set.targetRpe == null ? '' : ' · target RPE ${_formatOptionalRpe(set.targetRpe)}'}${set.completedRpe == null ? '' : ' · RPE ${_formatOptionalRpe(set.completedRpe)}'}',
                                ),
                              ),
                              Text(
                                _formatLoggedWeight(
                                  set.weight,
                                  exercise.displayLoadUnit,
                                ),
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
                        color: fittinTheme.fgMuted,
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

  Future<void> _editLog(BuildContext context, WorkoutLog log) async {
    WorkoutLogUpdateResult? savedResult;
    final owner = ref.read(currentUserIdProvider);
    var completedAt = log.completedAt;
    final repository = ref.read(localWorkoutLogRepositoryProvider);
    await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => ProviderScope(
          overrides: [
            activeSessionProvider.overrideWith(
              (sessionRef) => ActiveSessionNotifier(
                sessionRef,
                initialWorkout: sessionForHistory(log),
                propagateWeight: false,
                onSaveIsolatedSession: (session) async {
                  if (!mounted || ref.read(currentUserIdProvider) != owner) {
                    throw StateError('Account changed. Reopen this record.');
                  }
                  savedResult = await repository.updateWorkoutLog(
                    applySessionToHistory(
                      log,
                      session,
                      completedAt: completedAt,
                    ),
                    expectedLog: log,
                  );
                },
              ),
            ),
          ],
          child: ActiveSessionScreen(
            editingHistory: true,
            completedAt: log.completedAt,
            onCompletedAtChanged: (value) => completedAt = value,
          ),
        ),
      ),
    );
    if (savedResult == null || !mounted) {
      return;
    }
    final result = savedResult!;
    ref.invalidate(advancedAnalyticsDataProvider);
    ref.invalidate(progressAnalyticsOverviewProvider);

    setState(() {
      final index = _logs.indexWhere((item) => item.logId == result.log.logId);
      if (index != -1) {
        _logs[index] = result.log;
      }
      _logs.sort((a, b) => b.completedAt.compareTo(a.completedAt));
    });

    final strings = AppStrings.of(this.context, ref);
    ScaffoldMessenger.of(this.context).showSnackBar(
      SnackBar(
        content: Text(
          result.progressionRewritten
              ? strings.workoutUpdated
              : strings.workoutUpdatedNoProgressionRewrite,
        ),
      ),
    );
  }

  ButtonStyle _recordActionStyle(
    BuildContext context, {
    Color? foregroundColor,
  }) {
    final scheme = Theme.of(context).colorScheme;
    return TextButton.styleFrom(
      foregroundColor: foregroundColor ?? scheme.onSurface,
      textStyle: Theme.of(
        context,
      ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      minimumSize: const Size(44, 44),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: scheme.outlineVariant),
      ),
      backgroundColor: scheme.surfaceContainerHighest,
    );
  }

  Future<void> _confirmDeleteLog(BuildContext context, WorkoutLog log) async {
    final strings = AppStrings.of(context, ref);
    final choice = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(strings.deleteWorkoutRecordTitle),
        content: Text(
          strings.isChinese
              ? '仅删除：移除记录，计划进度不变。\n\n删除并释放：让这个训练日可以重练。较早的训练日会加入补练队列，不会抹掉后续进度。'
              : 'Delete only removes the record and keeps plan progress.\n\nDelete and release makes this day available again. Older days enter a recovery queue without erasing later progress.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(strings.cancel),
          ),
          TextButton(
            key: const ValueKey('confirm-delete-workout'),
            onPressed: () => Navigator.of(dialogContext).pop('delete'),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: Text(strings.isChinese ? '仅删除记录' : 'Delete only'),
          ),
          if (!log.instanceId.startsWith('free:'))
            TextButton(
              key: const ValueKey('delete-and-release-workout'),
              onPressed: () => Navigator.of(dialogContext).pop('release'),
              child: Text(strings.isChinese ? '删除并释放' : 'Delete and release'),
            ),
        ],
      ),
    );
    if (choice == null || !mounted) {
      return;
    }

    try {
      await ref
          .read(localWorkoutLogRepositoryProvider)
          .deleteWorkoutLog(
            log.logId,
            expectedLog: log,
            releaseToPlan: choice == 'release',
          );
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          this.context,
        ).showSnackBar(SnackBar(content: Text(error.toString())));
      }
      return;
    }
    if (!mounted) {
      return;
    }

    ref.invalidate(advancedAnalyticsDataProvider);
    ref.invalidate(progressAnalyticsOverviewProvider);
    ref.invalidate(todayWorkoutSummaryProvider);
    ref.invalidate(remainingMicrocycleWorkoutsProvider);
    setState(() {
      _logs.removeWhere((item) => item.logId == log.logId);
    });
    ScaffoldMessenger.of(
      this.context,
    ).showSnackBar(SnackBar(content: Text(strings.workoutRecordDeleted)));
  }
}

String _localizedExerciseLogName(
  ExerciseLog exercise,
  ExerciseLibrary? library,
  AppStrings strings,
) {
  final definition = library?.findKnown(
    exerciseId: exercise.exerciseDefinitionId.isNotEmpty
        ? exercise.exerciseDefinitionId
        : exercise.exerciseId,
    name: exercise.exerciseName,
  );
  return definition?.displayName(strings.isChinese ? 'zh' : 'en') ??
      exercise.exerciseName;
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

String _formatLoggedWeight(double canonicalWeight, String displayUnit) {
  final value = convertWeight(canonicalWeight, LoadUnits.kg, displayUnit);
  return '${value.toStringAsFixed(value.truncateToDouble() == value ? 0 : 1)} ${displayUnit == LoadUnits.lbs ? 'lb' : 'kg'}';
}

String _formatOptionalRpe(double? value) {
  if (value == null) {
    return '';
  }
  return value.toStringAsFixed(value.truncateToDouble() == value ? 0 : 1);
}
