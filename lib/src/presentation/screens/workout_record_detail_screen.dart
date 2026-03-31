import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fittin_v2/src/application/advanced_analytics_provider.dart';
import 'package:fittin_v2/src/application/progress_analytics_provider.dart';
import 'package:fittin_v2/src/data/local/local_workout_log_repository.dart';
import 'package:fittin_v2/src/domain/models/workout_log.dart';
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

    return Scaffold(
      backgroundColor: Colors.black,
      body: DashboardPageScaffold(
        bottomPadding: 80,
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
                        IconButton(
                          onPressed: () => _editLog(context, log),
                          icon: const Icon(Icons.edit_rounded),
                          tooltip: strings.edit,
                        ),
                      ],
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

  Future<void> _editLog(BuildContext context, WorkoutLog log) async {
    final updated = await showModalBottomSheet<WorkoutLog>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.black,
      builder: (context) => _WorkoutLogEditorSheet(
        log: log,
        strings: AppStrings.of(context, ref),
      ),
    );
    if (updated == null || !mounted) {
      return;
    }

    final repository = ref.read(localWorkoutLogRepositoryProvider);
    final result = await repository.updateWorkoutLog(updated);
    if (!mounted) {
      return;
    }
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
}

class _WorkoutLogEditorSheet extends StatefulWidget {
  const _WorkoutLogEditorSheet({required this.log, required this.strings});

  final WorkoutLog log;
  final AppStrings strings;

  @override
  State<_WorkoutLogEditorSheet> createState() => _WorkoutLogEditorSheetState();
}

class _WorkoutLogEditorSheetState extends State<_WorkoutLogEditorSheet> {
  late final TextEditingController _dateController;
  late final TextEditingController _timeController;
  late final List<_EditableExerciseState> _exercises;

  @override
  void initState() {
    super.initState();
    final completedAt = widget.log.completedAt;
    _dateController = TextEditingController(
      text:
          '${completedAt.year.toString().padLeft(4, '0')}-${completedAt.month.toString().padLeft(2, '0')}-${completedAt.day.toString().padLeft(2, '0')}',
    );
    _timeController = TextEditingController(
      text:
          '${completedAt.hour.toString().padLeft(2, '0')}:${completedAt.minute.toString().padLeft(2, '0')}',
    );
    _exercises = [
      for (final exercise in widget.log.exercises)
        _EditableExerciseState(
          exerciseId: exercise.exerciseId,
          exerciseName: exercise.exerciseName,
          stageId: exercise.stageId,
          sets: [
            for (final set in exercise.sets)
              _EditableSetState(
                role: set.role,
                targetReps: set.targetReps,
                targetWeight: set.targetWeight,
                isAmrap: set.isAmrap,
                completed: set.isCompleted,
                repsController: TextEditingController(
                  text: '${set.completedReps}',
                ),
                weightController: TextEditingController(
                  text: set.weight.toStringAsFixed(
                    set.weight.truncateToDouble() == set.weight ? 0 : 1,
                  ),
                ),
              ),
          ],
        ),
    ];
  }

  @override
  void dispose() {
    _dateController.dispose();
    _timeController.dispose();
    for (final exercise in _exercises) {
      for (final set in exercise.sets) {
        set.repsController.dispose();
        set.weightController.dispose();
      }
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final strings = widget.strings;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          16,
          16,
          16,
          16 + MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.log.workoutName,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _dateController,
                      decoration: InputDecoration(
                        labelText: strings.recordedDate,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _timeController,
                      decoration: InputDecoration(
                        labelText: strings.recordedTime,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              for (final exercise in _exercises) ...[
                Text(
                  exercise.exerciseName,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                for (var index = 0; index < exercise.sets.length; index++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: exercise.sets[index].repsController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'Reps ${index + 1}',
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: exercise.sets[index].weightController,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            decoration: InputDecoration(
                              labelText: 'Weight ${index + 1}',
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Checkbox(
                          value: exercise.sets[index].completed,
                          onChanged: (value) {
                            setState(() {
                              exercise.sets[index].completed = value ?? false;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 8),
              ],
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(strings.cancel),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: () => _save(context, strings),
                      child: Text(strings.saveChanges),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _save(BuildContext context, AppStrings strings) {
    final completedAt = _parseDateTime(
      _dateController.text.trim(),
      _timeController.text.trim(),
    );
    if (completedAt == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(strings.invalidDateTime)));
      return;
    }

    final exercises = [
      for (final exercise in _exercises)
        ExerciseLog(
          exerciseId: exercise.exerciseId,
          exerciseName: exercise.exerciseName,
          stageId: exercise.stageId,
          sets: [
            for (final set in exercise.sets)
              SetLog(
                role: set.role,
                targetReps: set.targetReps,
                completedReps:
                    int.tryParse(set.repsController.text.trim()) ?? 0,
                targetWeight: set.targetWeight,
                weight: double.tryParse(set.weightController.text.trim()) ?? 0,
                isAmrap: set.isAmrap,
                isCompleted: set.completed,
              ),
          ],
        ),
    ];

    Navigator.of(
      context,
    ).pop(widget.log.copyWith(completedAt: completedAt, exercises: exercises));
  }
}

class _EditableExerciseState {
  _EditableExerciseState({
    required this.exerciseId,
    required this.exerciseName,
    required this.stageId,
    required this.sets,
  });

  final String exerciseId;
  final String exerciseName;
  final String stageId;
  final List<_EditableSetState> sets;
}

class _EditableSetState {
  _EditableSetState({
    required this.role,
    required this.targetReps,
    required this.targetWeight,
    required this.isAmrap,
    required this.completed,
    required this.repsController,
    required this.weightController,
  });

  final String role;
  final int targetReps;
  final double targetWeight;
  final bool isAmrap;
  bool completed;
  final TextEditingController repsController;
  final TextEditingController weightController;
}

DateTime? _parseDateTime(String rawDate, String rawTime) {
  final dateParts = rawDate.split('-');
  final timeParts = rawTime.split(':');
  if (dateParts.length != 3 || timeParts.length != 2) {
    return null;
  }
  final year = int.tryParse(dateParts[0]);
  final month = int.tryParse(dateParts[1]);
  final day = int.tryParse(dateParts[2]);
  final hour = int.tryParse(timeParts[0]);
  final minute = int.tryParse(timeParts[1]);
  if (year == null ||
      month == null ||
      day == null ||
      hour == null ||
      minute == null) {
    return null;
  }
  return DateTime(year, month, day, hour, minute);
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
