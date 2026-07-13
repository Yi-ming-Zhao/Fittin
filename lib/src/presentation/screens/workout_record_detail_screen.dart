import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fittin_v2/src/application/advanced_analytics_provider.dart';
import 'package:fittin_v2/src/application/fittin_theme_provider.dart';
import 'package:fittin_v2/src/application/progress_analytics_provider.dart';
import 'package:fittin_v2/src/data/local/local_workout_log_repository.dart';
import 'package:fittin_v2/src/domain/models/training_plan.dart';
import 'package:fittin_v2/src/domain/models/workout_log.dart';
import 'package:fittin_v2/src/domain/weight_tools.dart';
import 'package:fittin_v2/src/presentation/localization/app_strings.dart';
import 'package:fittin_v2/src/presentation/theme/fittin_theme.dart';
import 'package:fittin_v2/src/presentation/widgets/dashboard_primitives.dart';
import 'package:fittin_v2/src/presentation/widgets/fittin_primitives.dart';

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
                                foregroundColor: const Color(0xFFE7A09B),
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
                                  '${strings.completedSets}: ${set.completedReps}/${set.targetReps}${set.targetRpe == null ? '' : ' · target RPE ${_formatOptionalRpe(set.targetRpe)}'}${set.completedRpe == null ? '' : ' · RPE ${_formatOptionalRpe(set.completedRpe)}'}',
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
        fittinTheme: ref.read(resolvedFittinThemeProvider),
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

  ButtonStyle _recordActionStyle(
    BuildContext context, {
    Color foregroundColor = Colors.white,
  }) {
    return TextButton.styleFrom(
      foregroundColor: foregroundColor,
      textStyle: Theme.of(
        context,
      ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      visualDensity: VisualDensity.compact,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: Colors.white.withValues(alpha: 0.16)),
      ),
      backgroundColor: Colors.white.withValues(alpha: 0.05),
    );
  }

  Future<void> _confirmDeleteLog(BuildContext context, WorkoutLog log) async {
    final strings = AppStrings.of(context, ref);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(strings.deleteWorkoutRecordTitle),
        content: Text(strings.deleteWorkoutRecordMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(strings.cancel),
          ),
          TextButton(
            key: const ValueKey('confirm-delete-workout'),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFE7A09B),
            ),
            child: Text(strings.delete),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) {
      return;
    }

    await ref
        .read(localWorkoutLogRepositoryProvider)
        .deleteWorkoutLog(log.logId);
    if (!mounted) {
      return;
    }

    ref.invalidate(advancedAnalyticsDataProvider);
    ref.invalidate(progressAnalyticsOverviewProvider);
    setState(() {
      _logs.removeWhere((item) => item.logId == log.logId);
    });
    ScaffoldMessenger.of(
      this.context,
    ).showSnackBar(SnackBar(content: Text(strings.workoutRecordDeleted)));
  }
}

class _WorkoutLogEditorSheet extends StatefulWidget {
  const _WorkoutLogEditorSheet({
    required this.log,
    required this.strings,
    required this.fittinTheme,
  });

  final WorkoutLog log;
  final AppStrings strings;
  final FittinTheme fittinTheme;

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
          displayLoadUnit: exercise.displayLoadUnit,
          sets: [
            for (final set in exercise.sets)
              _EditableSetState(
                role: set.role,
                targetReps: set.targetReps,
                targetWeight: set.targetWeight,
                targetRpe: set.targetRpe,
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
                rpeController: TextEditingController(
                  text: set.completedRpe == null
                      ? ''
                      : _formatOptionalRpe(set.completedRpe),
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
        set.rpeController.dispose();
      }
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fittinTheme = widget.fittinTheme;
    final strings = widget.strings;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          fittinTheme.pad,
          fittinTheme.pad,
          fittinTheme.pad,
          fittinTheme.pad + MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DashboardBackButton(
                theme: fittinTheme,
                label: strings.recordedWorkoutDetails,
                onPressed: () => Navigator.of(context).pop(),
              ),
              const SizedBox(height: 10),
              Text(
                widget.log.workoutName,
                style: fittinTheme.displayStyle(24, fittinTheme.fg),
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
                  style: fittinTheme
                      .uiStyle(16, fittinTheme.fg)
                      .copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 6),
                FittinSegmented(
                  theme: fittinTheme,
                  options: const ['kg', 'lb'],
                  value: exercise.displayLoadUnit == LoadUnits.lbs
                      ? 'lb'
                      : 'kg',
                  onChange: (selection) {
                    setState(() {
                      exercise.displayLoadUnit = selection == 'lb'
                          ? LoadUnits.lbs
                          : LoadUnits.kg;
                    });
                  },
                ),
                const SizedBox(height: 10),
                for (var index = 0; index < exercise.sets.length; index++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Column(
                      children: [
                        Row(
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
                                controller:
                                    exercise.sets[index].weightController,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                decoration: InputDecoration(
                                  labelText:
                                      'Weight ${index + 1} (${exercise.displayLoadUnit == LoadUnits.lbs ? 'lb' : 'kg'})',
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextField(
                                controller: exercise.sets[index].rpeController,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                decoration: InputDecoration(
                                  labelText: 'RPE ${index + 1}',
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Checkbox(
                              value: exercise.sets[index].completed,
                              onChanged: (value) {
                                setState(() {
                                  exercise.sets[index].completed =
                                      value ?? false;
                                });
                              },
                            ),
                          ],
                        ),
                        if (exercise.sets[index].targetRpe != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Target RPE ${_formatOptionalRpe(exercise.sets[index].targetRpe)}',
                                style: fittinTheme.uiStyle(
                                  12,
                                  fittinTheme.fgDim,
                                ),
                              ),
                            ),
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
                    child: FittinBtn(
                      fittinTheme,
                      strings.cancel,
                      variant: 'secondary',
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FittinBtn(
                      fittinTheme,
                      strings.saveChanges,
                      onPressed: () => _save(context, strings),
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
          displayLoadUnit: exercise.displayLoadUnit,
          sets: [
            for (final set in exercise.sets)
              SetLog(
                role: set.role,
                targetReps: set.targetReps,
                completedReps:
                    int.tryParse(set.repsController.text.trim()) ?? 0,
                targetWeight: set.targetWeight,
                weight: convertWeight(
                  double.tryParse(set.weightController.text.trim()) ?? 0,
                  exercise.displayLoadUnit,
                  LoadUnits.kg,
                ),
                targetRpe: set.targetRpe,
                completedRpe: double.tryParse(set.rpeController.text.trim()),
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
    required this.displayLoadUnit,
    required this.sets,
  });

  final String exerciseId;
  final String exerciseName;
  final String stageId;
  String displayLoadUnit;
  final List<_EditableSetState> sets;
}

class _EditableSetState {
  _EditableSetState({
    required this.role,
    required this.targetReps,
    required this.targetWeight,
    required this.targetRpe,
    required this.isAmrap,
    required this.completed,
    required this.repsController,
    required this.weightController,
    required this.rpeController,
  });

  final String role;
  final int targetReps;
  final double targetWeight;
  final double? targetRpe;
  final bool isAmrap;
  bool completed;
  final TextEditingController repsController;
  final TextEditingController weightController;
  final TextEditingController rpeController;
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
