import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fittin_v2/src/application/active_session_provider.dart';
import 'package:fittin_v2/src/application/app_locale_provider.dart';
import 'package:fittin_v2/src/application/fittin_theme_provider.dart';
import 'package:fittin_v2/src/application/ui_settings_provider.dart';
import 'package:fittin_v2/src/domain/models/training_plan.dart';
import 'package:fittin_v2/src/domain/models/training_state.dart';
import 'package:fittin_v2/src/domain/weight_tools.dart';
import 'package:fittin_v2/src/presentation/localization/app_strings.dart';
import 'package:fittin_v2/src/presentation/localization/plan_text.dart';
import 'package:fittin_v2/src/presentation/theme/fittin_theme.dart';
import 'package:fittin_v2/src/presentation/widgets/dashboard_primitives.dart';
import 'package:fittin_v2/src/presentation/widgets/fittin_primitives.dart';
import 'package:fittin_v2/src/presentation/widgets/weight_tools_sheet.dart';

class ActiveSessionScreen extends ConsumerStatefulWidget {
  const ActiveSessionScreen({super.key});

  @override
  ConsumerState<ActiveSessionScreen> createState() =>
      _ActiveSessionScreenState();
}

class _ActiveSessionScreenState extends ConsumerState<ActiveSessionScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _completionController;

  @override
  void initState() {
    super.initState();
    _completionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
  }

  @override
  void dispose() {
    _completionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sessionState = ref.watch(activeSessionProvider);
    final template = ref.watch(activeTemplateProvider).valueOrNull;
    final locale = ref.watch(appLocaleProvider);
    final strings = AppStrings.of(context, ref);
    final notifier = ref.read(activeSessionProvider.notifier);
    final theme = Theme.of(context);
    final fittinTheme = ref.watch(resolvedFittinThemeProvider);
    final recordingMode = ref.watch(workoutRecordingModeProvider);
    final workout = sessionState.activeWorkout;

    if (sessionState.isLoading && workout == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (workout == null) {
      return Scaffold(
        body: Center(
          child: Text(
            sessionState.errorMessage ?? strings.noActiveWorkoutSession,
            style: theme.textTheme.bodyLarge,
          ),
        ),
      );
    }

    String localizedExercise(ExerciseSessionState exercise) {
      if (template == null) return exercise.exerciseName;
      try {
        return localizedExerciseName(
          template.findExerciseById(exercise.id),
          locale,
        );
      } on StateError {
        return exercise.exerciseName;
      }
    }

    final currentExercise = workout.exercises[workout.currentExerciseIndex];
    final currentExerciseName = localizedExercise(currentExercise);
    final resolvedSetIndex = _resolveCurrentSetIndex(currentExercise);
    final currentSet = currentExercise.sets[resolvedSetIndex];
    final displayUnit = _supportsUnitToggle(currentExercise.displayLoadUnit)
        ? currentExercise.displayLoadUnit
        : LoadUnits.kg;
    final displayWeight = convertWeight(
      currentSet.weight,
      LoadUnits.kg,
      displayUnit,
    );
    final displayTargetWeight = convertWeight(
      currentSet.targetWeight,
      LoadUnits.kg,
      displayUnit,
    );
    final step = displayUnit == LoadUnits.lbs ? 5.0 : 2.5;
    final kgBarWeight = ref.watch(kgBarWeightProvider);
    final lbBarWeight = ref.watch(lbBarWeightProvider);
    final compactWorkoutTitle = _buildWorkoutContextTitle(
      workout: workout,
      displayName: _localizedWorkoutName(template, workout, locale),
      currentStageId: currentExercise.stageId,
    );
    final plateBreakdown =
        currentExercise.showsPlateBreakdown && _supportsUnitToggle(displayUnit)
        ? computePlateBreakdown(
            totalWeight: displayWeight,
            unit: displayUnit,
            barWeight: displayUnit == LoadUnits.lbs ? lbBarWeight : kgBarWeight,
          )
        : null;

    return DashboardPageScaffold(
      bottomPadding: 28,
      children: [
        Row(
          children: [
            DashboardBackButton(theme: fittinTheme),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                compactWorkoutTitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1.2,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        DashboardSurfaceCard(
          highlight: true,
          radius: 28,
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.08),
                    ),
                    child: const Icon(Icons.fitness_center_rounded, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          currentExerciseName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                            height: 1,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          strings.isChinese
                              ? '第 ${resolvedSetIndex + 1} 组 / 共 ${currentExercise.sets.length} 组'
                              : 'Set ${resolvedSetIndex + 1} / ${currentExercise.sets.length}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.white.withValues(alpha: 0.62),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _ExerciseSwitchMenu(
                    exercises: workout.exercises,
                    activeIndex: workout.currentExerciseIndex,
                    localizedExercise: localizedExercise,
                    onSelect: notifier.selectExercise,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _CompactMetaTile(
                      label: strings.tier,
                      value: currentExercise.tier,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: _CompactMetaTile(
                      label: strings.isChinese ? '目标' : 'Target',
                      value: _targetSummary(
                        strings,
                        currentSet,
                        displayTargetWeight,
                        displayUnit,
                      ),
                      highlight: true,
                    ),
                  ),
                ],
              ),
              if (_supportsUnitToggle(displayUnit)) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: FittinSegmented(
                        theme: fittinTheme,
                        options: [
                          strings.isChinese ? '公斤' : 'kg',
                          strings.isChinese ? '磅' : 'lb',
                        ],
                        value: displayUnit == LoadUnits.kg
                            ? (strings.isChinese ? '公斤' : 'kg')
                            : (strings.isChinese ? '磅' : 'lb'),
                        expand: true,
                        onChange: (selection) =>
                            notifier.switchExerciseDisplayUnit(
                              selection == (strings.isChinese ? '公斤' : 'kg')
                                  ? LoadUnits.kg
                                  : LoadUnits.lbs,
                            ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    FittinBtn(
                      fittinTheme,
                      strings.isChinese ? '换算' : 'Tools',
                      icon: Icons.calculate_rounded,
                      onPressed: () => _openWeightTools(
                        exerciseName: currentExerciseName,
                        weight: displayWeight,
                        unit: displayUnit,
                        onApply: (value, unit) {
                          notifier.updateWeightFromDisplayUnit(
                            resolvedSetIndex,
                            value,
                            displayUnit: unit,
                          );
                          notifier.switchExerciseDisplayUnit(unit);
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 12),
        if (recordingMode == WorkoutRecordingMode.card)
          _CardSetStack(
            strings: strings,
            setIndex: resolvedSetIndex,
            totalSets: currentExercise.sets.length,
            currentSet: currentSet,
            upcomingSets: currentExercise.sets
                .skip(resolvedSetIndex + 1)
                .where((set) => !set.isCompleted && !set.isSkipped)
                .take(2)
                .toList(),
            displayWeight: displayWeight,
            displayTargetWeight: displayTargetWeight,
            displayUnit: displayUnit,
            step: step,
            plateBreakdown: plateBreakdown,
            completionController: _completionController,
            onDecreaseReps: currentSet.completedReps > 0
                ? () => notifier.updateReps(
                    resolvedSetIndex,
                    currentSet.completedReps - 1,
                  )
                : null,
            onIncreaseReps: () => notifier.updateReps(
              resolvedSetIndex,
              currentSet.completedReps + 1,
            ),
            onDecreaseWeight: () => notifier.updateWeightFromDisplayUnit(
              resolvedSetIndex,
              displayWeight - step < 0 ? 0 : displayWeight - step,
              displayUnit: displayUnit,
            ),
            onIncreaseWeight: () => notifier.updateWeightFromDisplayUnit(
              resolvedSetIndex,
              displayWeight + step,
              displayUnit: displayUnit,
            ),
            onEditWeight: () => _editWeight(
              strings,
              theme: fittinTheme,
              currentValue: displayWeight,
              displayUnit: displayUnit,
              onSubmit: (value) => notifier.updateWeightFromDisplayUnit(
                resolvedSetIndex,
                value,
                displayUnit: displayUnit,
              ),
            ),
            onEditRpe: () => _editRpe(
              strings,
              theme: fittinTheme,
              currentValue: currentSet.completedRpe ?? currentSet.targetRpe,
              onSubmit: (value) =>
                  notifier.updateCompletedRpe(resolvedSetIndex, value),
            ),
            onComplete: () => _handleCompleteSet(notifier, resolvedSetIndex),
            onCancel: () => notifier.cancelSet(resolvedSetIndex),
          )
        else
          DashboardSurfaceCard(
            key: const ValueKey('traditional-set-logger'),
            highlight: true,
            radius: 30,
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
            child: Column(
              children: [
                Row(
                  children: [
                    _SquareActionButton(
                      icon: Icons.remove_rounded,
                      onTap: currentSet.completedReps > 0
                          ? () => notifier.updateReps(
                              resolvedSetIndex,
                              currentSet.completedReps - 1,
                            )
                          : null,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => notifier.updateReps(
                          resolvedSetIndex,
                          currentSet.completedReps + 1,
                        ),
                        child: Container(
                          height: 126,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                Colors.white.withValues(alpha: 0.96),
                                Colors.white.withValues(alpha: 0.8),
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: theme.colorScheme.primary.withValues(
                                  alpha: 0.18,
                                ),
                                blurRadius: 28,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.fitness_center_rounded,
                                size: 20,
                                color: Colors.black.withValues(alpha: 0.76),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                '+1',
                                style: theme.textTheme.displaySmall?.copyWith(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -2,
                                ),
                              ),
                              Text(
                                strings.isChinese ? '次数' : 'Reps',
                                style: theme.textTheme.titleSmall?.copyWith(
                                  color: Colors.black.withValues(alpha: 0.76),
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    const SizedBox(width: 74),
                  ],
                ),
                const SizedBox(height: 12),
                Center(
                  child: _AnimatedCheckButton(
                    key: const ValueKey('complete-current-set'),
                    controller: _completionController,
                    onTap: () => _handleCompleteSet(notifier, resolvedSetIndex),
                  ),
                ),
                const SizedBox(height: 12),
                _InfoPanel(
                  label: strings.isChinese ? '当前次数' : 'Current Reps',
                  primary: '${currentSet.completedReps}',
                  secondary: currentSet.isAmrap
                      ? 'AMRAP'
                      : (strings.isChinese
                            ? '目标 ${currentSet.targetReps}'
                            : 'Target ${currentSet.targetReps}'),
                ),
                const SizedBox(height: 12),
                _WeightEntryCard(
                  strings: strings,
                  displayWeight: displayWeight,
                  displayUnit: displayUnit,
                  step: step,
                  onDecrease: () => notifier.updateWeightFromDisplayUnit(
                    resolvedSetIndex,
                    displayWeight - step < 0 ? 0 : displayWeight - step,
                    displayUnit: displayUnit,
                  ),
                  onIncrease: () => notifier.updateWeightFromDisplayUnit(
                    resolvedSetIndex,
                    displayWeight + step,
                    displayUnit: displayUnit,
                  ),
                  onTap: () => _editWeight(
                    strings,
                    theme: fittinTheme,
                    currentValue: displayWeight,
                    displayUnit: displayUnit,
                    onSubmit: (value) => notifier.updateWeightFromDisplayUnit(
                      resolvedSetIndex,
                      value,
                      displayUnit: displayUnit,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _InfoPanel(
                        label: strings.isChinese ? '目标 RPE' : 'Target RPE',
                        primary: currentSet.targetRpe == null
                            ? (strings.isChinese ? '未设置' : 'Not set')
                            : currentSet.targetRpe!.toStringAsFixed(
                                currentSet.targetRpe!.truncateToDouble() ==
                                        currentSet.targetRpe
                                    ? 0
                                    : 1,
                              ),
                        secondary: strings.isChinese ? '计划预填' : 'Planned',
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _RpeEditorCard(
                        strings: strings,
                        currentRpe: currentSet.completedRpe,
                        onDecrease: () => notifier.updateCompletedRpe(
                          resolvedSetIndex,
                          (currentSet.completedRpe ??
                                  currentSet.targetRpe ??
                                  7) -
                              0.5,
                        ),
                        onIncrease: () => notifier.updateCompletedRpe(
                          resolvedSetIndex,
                          (currentSet.completedRpe ??
                                  currentSet.targetRpe ??
                                  6.5) +
                              0.5,
                        ),
                        onTap: () => _editRpe(
                          strings,
                          theme: fittinTheme,
                          currentValue:
                              currentSet.completedRpe ?? currentSet.targetRpe,
                          onSubmit: (value) => notifier.updateCompletedRpe(
                            resolvedSetIndex,
                            value,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                if (plateBreakdown != null) ...[
                  const SizedBox(height: 12),
                  _PlateBreakdownCard(
                    strings: strings,
                    breakdown: plateBreakdown,
                  ),
                ],
              ],
            ),
          ),
        const SizedBox(height: 12),
        DashboardSurfaceCard(
          radius: 28,
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DashboardSectionLabel(
                label: strings.isChinese ? '组进度' : 'Set Progress',
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  for (var i = 0; i < currentExercise.sets.length; i++) ...[
                    _SetProgressDot(
                      index: i,
                      set: currentExercise.sets[i],
                      active: i == resolvedSetIndex,
                      onTap: () => notifier.selectSet(i),
                    ),
                    if (i != currentExercise.sets.length - 1)
                      Expanded(
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 6),
                          height: 2,
                          color: Colors.white.withValues(alpha: 0.1),
                        ),
                      ),
                  ],
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        PremiumPrimaryButton(
          label: sessionState.isLoading
              ? strings.saving
              : strings.concludeWorkout,
          icon: Icons.check_circle_outline_rounded,
          loading: sessionState.isLoading,
          onPressed: () async {
            final confirmed = await showDialog<bool>(
              context: context,
              builder: (dialogContext) => AlertDialog(
                backgroundColor: fittinTheme.surface,
                surfaceTintColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(fittinTheme.radius),
                  side: BorderSide(color: fittinTheme.border),
                ),
                title: Text(
                  strings.confirmConcludeWorkoutTitle,
                  style: fittinTheme.displayStyle(22, fittinTheme.fg),
                ),
                content: Text(
                  strings.confirmConcludeWorkoutMessage,
                  style: fittinTheme
                      .uiStyle(14, fittinTheme.fgDim)
                      .copyWith(height: 1.45),
                ),
                actions: [
                  FittinBtn(
                    fittinTheme,
                    strings.cancel,
                    size: 'sm',
                    variant: 'secondary',
                    onPressed: () => Navigator.of(dialogContext).pop(false),
                  ),
                  FittinBtn(
                    fittinTheme,
                    strings.concludeWorkout,
                    size: 'sm',
                    onPressed: () => Navigator.of(dialogContext).pop(true),
                  ),
                ],
              ),
            );
            if (confirmed != true) {
              return;
            }
            final success = await notifier.concludeSession();
            if (!context.mounted) return;
            if (success) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(strings.workoutSaved)));
              Navigator.of(context).pop();
            } else {
              final latestState = ref.read(activeSessionProvider);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    latestState.errorMessage ?? 'Unable to conclude workout.',
                  ),
                ),
              );
            }
          },
        ),
      ],
    );
  }

  Future<void> _handleCompleteSet(
    ActiveSessionNotifier notifier,
    int setIndex,
  ) async {
    await _completionController.forward(from: 0);
    notifier.completeSet(setIndex);
  }

  Future<void> _openWeightTools({
    required String exerciseName,
    required double weight,
    required String unit,
    required void Function(double value, String unit) onApply,
  }) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.black,
      builder: (_) => WeightToolsSheet(
        initialWeight: weight,
        initialUnit: unit,
        showApplyButton: true,
        exerciseName: exerciseName,
        onApply: onApply,
      ),
    );
  }

  Future<void> _editWeight(
    AppStrings strings, {
    required FittinTheme theme,
    required double currentValue,
    required String displayUnit,
    required ValueChanged<double> onSubmit,
  }) async {
    final controller = TextEditingController(
      text: _formatWeightValue(currentValue),
    );
    final result = await showDialog<double>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: theme.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(theme.radius),
          side: BorderSide(color: theme.border),
        ),
        title: Text(
          strings.isChinese ? '直接输入重量' : 'Enter Weight',
          style: theme.displayStyle(22, theme.fg),
        ),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            labelText: strings.isChinese ? '重量' : 'Weight',
            suffixText: displayUnit == LoadUnits.kg ? 'kg' : 'lb',
          ),
        ),
        actions: [
          FittinBtn(
            theme,
            strings.cancel,
            size: 'sm',
            variant: 'secondary',
            onPressed: () => Navigator.of(dialogContext).pop(),
          ),
          FittinBtn(
            theme,
            strings.saveChanges,
            size: 'sm',
            onPressed: () => Navigator.of(
              dialogContext,
            ).pop(double.tryParse(controller.text.trim())),
          ),
        ],
      ),
    );
    controller.dispose();
    if (result != null) {
      onSubmit(result);
    }
  }

  Future<void> _editRpe(
    AppStrings strings, {
    required FittinTheme theme,
    required double? currentValue,
    required ValueChanged<double?> onSubmit,
  }) async {
    final controller = TextEditingController(
      text: currentValue == null ? '' : _formatWeightValue(currentValue),
    );
    final result = await showDialog<double?>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: theme.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(theme.radius),
          side: BorderSide(color: theme.border),
        ),
        title: Text(
          strings.isChinese ? '输入 RPE' : 'Enter RPE',
          style: theme.displayStyle(22, theme.fg),
        ),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            labelText: 'RPE',
            hintText: strings.isChinese ? '例如 7 或 7.5' : 'For example 7 or 7.5',
          ),
        ),
        actions: [
          FittinBtn(
            theme,
            strings.cancel,
            size: 'sm',
            variant: 'secondary',
            onPressed: () => Navigator.of(dialogContext).pop(),
          ),
          FittinBtn(
            theme,
            strings.isChinese ? '清空' : 'Clear',
            size: 'sm',
            variant: 'secondary',
            onPressed: () => Navigator.of(dialogContext).pop(null),
          ),
          FittinBtn(
            theme,
            strings.saveChanges,
            size: 'sm',
            onPressed: () => Navigator.of(
              dialogContext,
            ).pop(double.tryParse(controller.text.trim())),
          ),
        ],
      ),
    );
    controller.dispose();
    onSubmit(result);
  }
}

String _localizedWorkoutName(
  PlanTemplate? template,
  WorkoutSessionState workout,
  AppLocale locale,
) {
  if (template == null) return workout.workoutName;
  try {
    return localizedWorkoutName(
      template.findWorkoutById(workout.workoutId),
      locale,
    );
  } on StateError {
    return workout.workoutName;
  }
}

String _buildWorkoutContextTitle({
  required WorkoutSessionState workout,
  required String displayName,
  required String currentStageId,
}) {
  final dayMatch = RegExp(r'(\d+)').firstMatch(workout.dayLabel);
  final stageWeekMatch = RegExp(
    r'week[-_]?(\d+)',
    caseSensitive: false,
  ).firstMatch(currentStageId);
  final weekPart = stageWeekMatch == null
      ? null
      : 'W${stageWeekMatch.group(1)}';
  final dayPart = dayMatch == null ? null : 'D${dayMatch.group(1)}';
  final prefix = [
    if (weekPart != null) weekPart,
    if (dayPart != null) dayPart,
  ].join();
  return prefix.isEmpty ? displayName : '$prefix-$displayName';
}

int _resolveCurrentSetIndex(ExerciseSessionState exercise) {
  if (exercise.sets.isEmpty) {
    return 0;
  }
  final saved = exercise.currentSetIndex;
  if (saved >= 0 && saved < exercise.sets.length) {
    return saved;
  }
  final firstIncomplete = exercise.sets.indexWhere((set) => !set.isCompleted);
  return firstIncomplete == -1 ? exercise.sets.length - 1 : firstIncomplete;
}

bool _supportsUnitToggle(String unit) {
  return unit == LoadUnits.kg || unit == LoadUnits.lbs;
}

String _formatDisplayWeight(double value, String unit) {
  final formatted = _formatWeightValue(value);
  return '$formatted ${unit == LoadUnits.kg ? 'kg' : 'lb'}';
}

String _formatWeightValue(double value) {
  if (value.truncateToDouble() == value) {
    return value.toStringAsFixed(0);
  }
  if ((value * 10).roundToDouble() / 10 == value) {
    return value.toStringAsFixed(1);
  }
  return value.toStringAsFixed(2);
}

String _targetSummary(
  AppStrings strings,
  SessionSetState set,
  double displayTargetWeight,
  String displayUnit,
) {
  final reps = set.isAmrap ? '${set.targetReps}+' : '${set.targetReps}';
  final rpe = set.targetRpe == null
      ? ''
      : ' · RPE ${set.targetRpe!.toStringAsFixed(set.targetRpe!.truncateToDouble() == set.targetRpe ? 0 : 1)}';
  return '${_formatDisplayWeight(displayTargetWeight, displayUnit)} · $reps$rpe';
}

class _CompactMetaTile extends StatelessWidget {
  const _CompactMetaTile({
    required this.label,
    required this.value,
    this.highlight = false,
  });

  final String label;
  final String value;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white.withValues(alpha: highlight ? 0.08 : 0.04),
        border: Border.all(
          color: Colors.white.withValues(alpha: highlight ? 0.12 : 0.08),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.52),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoPanel extends StatelessWidget {
  const _InfoPanel({
    required this.label,
    required this.primary,
    required this.secondary,
  });

  final String label;
  final String primary;
  final String secondary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: Colors.white.withValues(alpha: 0.05),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: Colors.white.withValues(alpha: 0.54),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  primary,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: -2,
                  ),
                ),
              ],
            ),
          ),
          Text(
            secondary,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.end,
            style: theme.textTheme.titleSmall?.copyWith(
              color: Colors.white.withValues(alpha: 0.72),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _CardSetStack extends StatefulWidget {
  const _CardSetStack({
    required this.strings,
    required this.setIndex,
    required this.totalSets,
    required this.currentSet,
    required this.upcomingSets,
    required this.displayWeight,
    required this.displayTargetWeight,
    required this.displayUnit,
    required this.step,
    required this.plateBreakdown,
    required this.completionController,
    required this.onDecreaseReps,
    required this.onIncreaseReps,
    required this.onDecreaseWeight,
    required this.onIncreaseWeight,
    required this.onEditWeight,
    required this.onEditRpe,
    required this.onComplete,
    required this.onCancel,
  });

  final AppStrings strings;
  final int setIndex;
  final int totalSets;
  final SessionSetState currentSet;
  final List<SessionSetState> upcomingSets;
  final double displayWeight;
  final double displayTargetWeight;
  final String displayUnit;
  final double step;
  final PlateBreakdownResult? plateBreakdown;
  final AnimationController completionController;
  final VoidCallback? onDecreaseReps;
  final VoidCallback onIncreaseReps;
  final VoidCallback onDecreaseWeight;
  final VoidCallback onIncreaseWeight;
  final VoidCallback onEditWeight;
  final VoidCallback onEditRpe;
  final VoidCallback onComplete;
  final VoidCallback onCancel;

  @override
  State<_CardSetStack> createState() => _CardSetStackState();
}

class _CardSetStackState extends State<_CardSetStack> {
  static const _cardHeight = 390.0;
  Offset _drag = Offset.zero;
  bool _animate = false;
  bool _committing = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dragProgress = (_drag.distance / 220).clamp(0.0, 1.0);
    final leftProgress = (-_drag.dx / 120).clamp(0.0, 1.0);
    final downProgress = (_drag.dy / 130).clamp(0.0, 1.0);
    final transform = Matrix4.translationValues(_drag.dx, _drag.dy, 0)
      ..rotateZ(_drag.dx / 1500);

    return SizedBox(
      height: _cardHeight + 28,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          for (var depth = widget.upcomingSets.length; depth >= 1; depth--)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 120),
              curve: Curves.easeOut,
              left: 10.0 * depth * (1 - dragProgress * 0.45),
              right: 10.0 * depth * (1 - dragProgress * 0.45),
              top: 13.0 * depth * (1 - dragProgress * 0.55),
              height: _cardHeight,
              child: _StackBackCard(
                set: widget.upcomingSets[depth - 1],
                setNumber: widget.setIndex + depth + 1,
                displayUnit: widget.displayUnit,
                emphasis: 1 - depth * 0.22 + dragProgress * 0.18,
              ),
            ),
          Semantics(
            label: widget.strings.isChinese
                ? '当前第 ${widget.setIndex + 1} 组，左滑完成，下滑取消'
                : 'Current set ${widget.setIndex + 1}. Swipe left to finish or down to cancel.',
            child: GestureDetector(
              key: const ValueKey('active-set-card'),
              behavior: HitTestBehavior.opaque,
              onPanUpdate: _committing
                  ? null
                  : (details) {
                      setState(() {
                        _animate = false;
                        _drag += details.delta;
                      });
                    },
              onPanEnd: _committing ? null : (_) => _resolveDrag(),
              onPanCancel: _committing ? null : _resetDrag,
              child: AnimatedContainer(
                duration: _animate
                    ? const Duration(milliseconds: 190)
                    : Duration.zero,
                curve: Curves.easeOutCubic,
                height: _cardHeight,
                transform: transform,
                transformAlignment: Alignment.center,
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      theme.colorScheme.primary.withValues(alpha: 0.26),
                      const Color(0xFF151619),
                      const Color(0xFF0B0C0E),
                    ],
                    stops: const [0, 0.42, 1],
                  ),
                  border: Border.all(
                    color: Color.lerp(
                      Colors.white.withValues(alpha: 0.14),
                      leftProgress >= downProgress
                          ? const Color(0xFF9CE8BF)
                          : const Color(0xFFFFB4A8),
                      (leftProgress > downProgress
                              ? leftProgress
                              : downProgress) *
                          0.75,
                    )!,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.36),
                      blurRadius: 30,
                      offset: const Offset(0, 16),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            widget.strings.isChinese
                                ? '第 ${widget.setIndex + 1} / ${widget.totalSets} 组'
                                : 'SET ${widget.setIndex + 1} / ${widget.totalSets}',
                            style: theme.textTheme.labelMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.7,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Icon(
                          Icons.swipe_left_alt_rounded,
                          size: 18,
                          color: const Color(
                            0xFF9CE8BF,
                          ).withValues(alpha: 0.82),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.south_rounded,
                          size: 16,
                          color: const Color(
                            0xFFFFB4A8,
                          ).withValues(alpha: 0.82),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: _CardMetric(
                            label: widget.strings.isChinese ? '完成次数' : 'REPS',
                            value: '${widget.currentSet.completedReps}',
                            onDecrease: widget.onDecreaseReps,
                            onIncrease: widget.onIncreaseReps,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _CardTarget(
                            strings: widget.strings,
                            set: widget.currentSet,
                            targetWeight: widget.displayTargetWeight,
                            unit: widget.displayUnit,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Container(
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.08),
                        ),
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            onPressed: widget.onDecreaseWeight,
                            icon: const Icon(Icons.remove_rounded),
                          ),
                          Expanded(
                            child: InkWell(
                              key: const ValueKey('current-weight-editor'),
                              onTap: widget.onEditWeight,
                              borderRadius: BorderRadius.circular(16),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    _formatDisplayWeight(
                                      widget.displayWeight,
                                      widget.displayUnit,
                                    ),
                                    style: theme.textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: -1.1,
                                      height: 1,
                                    ),
                                  ),
                                  Text(
                                    widget.strings.isChinese
                                        ? '点按精确修改'
                                        : 'Tap for exact weight',
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: Colors.white.withValues(
                                        alpha: 0.5,
                                      ),
                                      fontSize: 10,
                                      height: 1,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: widget.onIncreaseWeight,
                            icon: const Icon(Icons.add_rounded),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 9),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            widget.strings.isChinese
                                ? '目标 ${widget.currentSet.targetReps}${widget.currentSet.isAmrap ? "+" : ""} 次'
                                : 'Target ${widget.currentSet.targetReps}${widget.currentSet.isAmrap ? "+" : ""} reps',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.white.withValues(alpha: 0.66),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        InkWell(
                          key: const ValueKey('current-rpe-editor'),
                          onTap: widget.onEditRpe,
                          borderRadius: BorderRadius.circular(999),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 7,
                            ),
                            child: Text(
                              'RPE ${widget.currentSet.completedRpe ?? widget.currentSet.targetRpe ?? '—'}',
                              style: theme.textTheme.labelLarge?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (widget.plateBreakdown != null) ...[
                      const SizedBox(height: 6),
                      _BarbellGraphic(
                        breakdown: widget.plateBreakdown!,
                        height: 43,
                      ),
                    ] else
                      const Spacer(),
                    const SizedBox(height: 6),
                    SizedBox(
                      height: 56,
                      child: Stack(
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: IconButton.filledTonal(
                              key: const ValueKey('cancel-current-set'),
                              tooltip: widget.strings.isChinese
                                  ? '取消当前组'
                                  : 'Cancel current set',
                              onPressed: widget.onCancel,
                              icon: const Icon(Icons.south_rounded),
                            ),
                          ),
                          Align(
                            alignment: Alignment.center,
                            child: _AnimatedCheckButton(
                              key: const ValueKey('complete-current-set'),
                              controller: widget.completionController,
                              onTap: widget.onComplete,
                              size: 56,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          IgnorePointer(
            child: Align(
              alignment: Alignment.centerLeft,
              child: Opacity(
                opacity: leftProgress,
                child: _GestureStamp(
                  label: widget.strings.isChinese ? '完成' : 'DONE',
                  icon: Icons.check_rounded,
                  color: const Color(0xFF9CE8BF),
                ),
              ),
            ),
          ),
          IgnorePointer(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Opacity(
                opacity: downProgress,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 42),
                  child: _GestureStamp(
                    label: widget.strings.isChinese ? '取消' : 'SKIP',
                    icon: Icons.south_rounded,
                    color: const Color(0xFFFFB4A8),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _resolveDrag() async {
    final horizontal = _drag.dx.abs();
    final vertical = _drag.dy.abs();
    final completes = _drag.dx < -96 && horizontal > vertical * 1.12;
    final cancels = _drag.dy > 110 && vertical > horizontal * 1.12;
    if (!completes && !cancels) {
      _resetDrag();
      return;
    }

    setState(() {
      _committing = true;
      _animate = true;
      _drag = completes
          ? Offset(-MediaQuery.sizeOf(context).width * 1.3, _drag.dy)
          : Offset(_drag.dx, MediaQuery.sizeOf(context).height * 0.9);
    });
    await Future<void>.delayed(const Duration(milliseconds: 190));
    if (completes) {
      widget.onComplete();
    } else {
      widget.onCancel();
    }
    if (!mounted) return;
    setState(() {
      _drag = Offset.zero;
      _animate = false;
      _committing = false;
    });
  }

  void _resetDrag() {
    setState(() {
      _animate = true;
      _drag = Offset.zero;
    });
  }
}

class _StackBackCard extends StatelessWidget {
  const _StackBackCard({
    required this.set,
    required this.setNumber,
    required this.displayUnit,
    required this.emphasis,
  });

  final SessionSetState set;
  final int setNumber;
  final String displayUnit;
  final double emphasis;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        color: const Color(0xFF17191C),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.08 * emphasis),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'SET $setNumber',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Colors.white.withValues(alpha: 0.34 * emphasis),
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
            ),
          ),
          const Spacer(),
          Text(
            _formatDisplayWeight(
              convertWeight(set.weight, LoadUnits.kg, displayUnit),
              displayUnit,
            ),
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.42 * emphasis),
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _CardMetric extends StatelessWidget {
  const _CardMetric({
    required this.label,
    required this.value,
    required this.onDecrease,
    required this.onIncrease,
  });

  final String label;
  final String value;
  final VoidCallback? onDecrease;
  final VoidCallback onIncrease;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      height: 78,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          IconButton(
            visualDensity: VisualDensity.compact,
            onPressed: onDecrease,
            icon: const Icon(Icons.remove_rounded),
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  value,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    letterSpacing: -1.5,
                  ),
                ),
                Text(
                  label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            visualDensity: VisualDensity.compact,
            onPressed: onIncrease,
            icon: const Icon(Icons.add_rounded),
          ),
        ],
      ),
    );
  }
}

class _CardTarget extends StatelessWidget {
  const _CardTarget({
    required this.strings,
    required this.set,
    required this.targetWeight,
    required this.unit,
  });

  final AppStrings strings;
  final SessionSetState set;
  final double targetWeight;
  final String unit;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 78,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            strings.isChinese ? '计划目标' : 'PRESCRIBED',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Colors.black.withValues(alpha: 0.54),
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          FittedBox(
            child: Text(
              '${_formatDisplayWeight(targetWeight, unit)} × ${set.targetReps}${set.isAmrap ? '+' : ''}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.black,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GestureStamp extends StatelessWidget {
  const _GestureStamp({
    required this.label,
    required this.icon,
    required this.color,
  });

  final String label;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 17),
          const SizedBox(width: 7),
          Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: color,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }
}

class _WeightEntryCard extends StatelessWidget {
  const _WeightEntryCard({
    required this.strings,
    required this.displayWeight,
    required this.displayUnit,
    required this.step,
    required this.onDecrease,
    required this.onIncrease,
    required this.onTap,
  });

  final AppStrings strings;
  final double displayWeight;
  final String displayUnit;
  final double step;
  final VoidCallback onDecrease;
  final VoidCallback onIncrease;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: Colors.white.withValues(alpha: 0.05),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              _MiniStepButton(
                label: '-${_formatWeightValue(step)}',
                onTap: onDecrease,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: InkWell(
                  key: const ValueKey('current-weight-editor'),
                  onTap: onTap,
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 20,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.white.withValues(alpha: 0.04),
                    ),
                    child: Column(
                      children: [
                        Text(
                          strings.isChinese ? '点按直接输入重量' : 'Tap to type weight',
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: Colors.white.withValues(alpha: 0.52),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _formatDisplayWeight(displayWeight, displayUnit),
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            letterSpacing: -2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              _MiniStepButton(
                label: '+${_formatWeightValue(step)}',
                onTap: onIncrease,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniStepButton extends StatelessWidget {
  const _MiniStepButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 74,
        height: 94,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.white.withValues(alpha: 0.08),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        child: Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
        ),
      ),
    );
  }
}

class _RpeEditorCard extends StatelessWidget {
  const _RpeEditorCard({
    required this.strings,
    required this.currentRpe,
    required this.onDecrease,
    required this.onIncrease,
    required this.onTap,
  });

  final AppStrings strings;
  final double? currentRpe;
  final VoidCallback onDecrease;
  final VoidCallback onIncrease;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: Colors.white.withValues(alpha: 0.05),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        children: [
          Text(
            strings.isChinese ? '实际 RPE' : 'Performed RPE',
            style: theme.textTheme.labelLarge?.copyWith(
              color: Colors.white.withValues(alpha: 0.54),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              IconButton(
                onPressed: onDecrease,
                icon: const Icon(Icons.remove_rounded),
              ),
              Expanded(
                child: InkWell(
                  onTap: onTap,
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        currentRpe == null
                            ? (strings.isChinese ? '未记录' : 'Not logged')
                            : currentRpe!.toStringAsFixed(
                                currentRpe!.truncateToDouble() == currentRpe
                                    ? 0
                                    : 1,
                              ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          letterSpacing: -1.2,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              IconButton(
                onPressed: onIncrease,
                icon: const Icon(Icons.add_rounded),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PlateBreakdownCard extends StatelessWidget {
  const _PlateBreakdownCard({required this.strings, required this.breakdown});

  final AppStrings strings;
  final PlateBreakdownResult breakdown;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final detail = breakdown.platesPerSide
        .map((plate) => '${_formatWeightValue(plate.weight)} × ${plate.count}')
        .join(' + ');
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: Colors.white.withValues(alpha: 0.05),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            strings.isChinese ? '杠铃上片' : 'Barbell Loading',
            style: theme.textTheme.labelLarge?.copyWith(
              color: Colors.white.withValues(alpha: 0.54),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          _BarbellGraphic(breakdown: breakdown),
          const SizedBox(height: 8),
          Text(
            strings.isChinese ? '每边 $detail' : '$detail each side',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          if (!breakdown.exact) ...[
            const SizedBox(height: 6),
            Text(
              strings.isChinese
                  ? '当前默认杠重下无法完全精确匹配，还差 ${_formatWeightValue(breakdown.unresolvedWeight)} ${breakdown.unit == LoadUnits.kg ? '公斤' : '磅'}'
                  : 'Exact loading is not possible with the current default bar weight. Remaining ${_formatWeightValue(breakdown.unresolvedWeight)} ${breakdown.unit == LoadUnits.kg ? 'kg' : 'lb'}.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.white.withValues(alpha: 0.7),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _BarbellGraphic extends StatelessWidget {
  const _BarbellGraphic({required this.breakdown, this.height = 58});

  final PlateBreakdownResult breakdown;
  final double height;

  @override
  Widget build(BuildContext context) {
    final plates = <double>[
      for (final plate in breakdown.platesPerSide)
        for (var count = 0; count < plate.count; count++) plate.weight,
    ];
    final largest = plates.isEmpty ? 1.0 : plates.first;
    final detail = breakdown.platesPerSide
        .map((plate) => '${_formatWeightValue(plate.weight)} × ${plate.count}')
        .join(' + ');

    Widget plate(double weight) {
      final ratio = (weight / largest).clamp(0.35, 1.0);
      final colors = <Color>[
        const Color(0xFFE45D50),
        const Color(0xFF4B8FE2),
        const Color(0xFFE4C451),
        const Color(0xFF6CB98A),
      ];
      final colorIndex = breakdown.platesPerSide.indexWhere(
        (candidate) => candidate.weight == weight,
      );
      return Container(
        width: 7 + ratio * 4,
        height: 22 + ratio * (height - 28),
        margin: const EdgeInsets.symmetric(horizontal: 1),
        decoration: BoxDecoration(
          color: colors[(colorIndex < 0 ? 0 : colorIndex) % colors.length],
          borderRadius: BorderRadius.circular(2.5),
          border: Border.all(color: Colors.white.withValues(alpha: 0.28)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.24),
              blurRadius: 3,
              offset: const Offset(0, 2),
            ),
          ],
        ),
      );
    }

    return Semantics(
      label: breakdown.unit == LoadUnits.kg
          ? '$detail kilograms each side'
          : '$detail pounds each side',
      image: true,
      child: SizedBox(
        key: const ValueKey('barbell-plate-graphic'),
        height: height,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              height: 4,
              margin: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF686D72),
                    Color(0xFFE2E5E7),
                    Color(0xFF686D72),
                  ],
                ),
                borderRadius: BorderRadius.circular(99),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (final weight in plates.reversed) plate(weight),
                _BarbellCollar(height: height * 0.48),
                SizedBox(width: height * 1.05),
                _BarbellCollar(height: height * 0.48),
                for (final weight in plates) plate(weight),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _BarbellCollar extends StatelessWidget {
  const _BarbellCollar({required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 6,
      height: height,
      margin: const EdgeInsets.symmetric(horizontal: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFBEC3C7),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}

class _AnimatedCheckButton extends StatelessWidget {
  const _AnimatedCheckButton({
    super.key,
    required this.controller,
    required this.onTap,
    this.size = 74,
  });

  final AnimationController controller;
  final VoidCallback onTap;
  final double size;

  @override
  Widget build(BuildContext context) {
    final scale = Tween<double>(
      begin: 1,
      end: 1.16,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.easeOutBack));
    final glow = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.easeOut));
    return GestureDetector(
      onTap: onTap,
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, child) {
          return Transform.scale(
            scale: scale.value,
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                color: Colors.white.withValues(alpha: 0.08 + glow.value * 0.12),
                border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withValues(
                      alpha: 0.1 + glow.value * 0.22,
                    ),
                    blurRadius: 26,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Icon(Icons.check_rounded, size: size * 0.43),
            ),
          );
        },
      ),
    );
  }
}

class _ExerciseSwitchMenu extends StatelessWidget {
  const _ExerciseSwitchMenu({
    required this.exercises,
    required this.activeIndex,
    required this.localizedExercise,
    required this.onSelect,
  });

  final List<ExerciseSessionState> exercises;
  final int activeIndex;
  final String Function(ExerciseSessionState) localizedExercise;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        popupMenuTheme: PopupMenuThemeData(
          color: const Color(0xFF101216),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          elevation: 24,
        ),
      ),
      child: PopupMenuButton<int>(
        tooltip: 'Switch exercise',
        onSelected: onSelect,
        offset: const Offset(0, 54),
        itemBuilder: (context) => [
          for (var i = 0; i < exercises.length; i++)
            PopupMenuItem<int>(
              value: i,
              child: _ExerciseMenuItem(
                active: i == activeIndex,
                tier: exercises[i].tier,
                name: localizedExercise(exercises[i]),
                completed: exercises[i].sets
                    .where((set) => set.isCompleted)
                    .length,
                total: exercises[i].sets.length,
              ),
            ),
        ],
        child: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            color: Colors.white.withValues(alpha: 0.06),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          ),
          child: const Icon(Icons.swap_vert_rounded),
        ),
      ),
    );
  }
}

class _ExerciseMenuItem extends StatelessWidget {
  const _ExerciseMenuItem({
    required this.active,
    required this.tier,
    required this.name,
    required this.completed,
    required this.total,
  });

  final bool active;
  final String tier;
  final String name;
  final int completed;
  final int total;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: active
                ? theme.colorScheme.primary.withValues(alpha: 0.2)
                : Colors.white.withValues(alpha: 0.06),
          ),
          child: Text(
            '$completed/$total',
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            '$tier $name',
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: active ? FontWeight.w800 : FontWeight.w600,
            ),
          ),
        ),
        if (active) const Icon(Icons.check_rounded, size: 18),
      ],
    );
  }
}

class _SquareActionButton extends StatelessWidget {
  const _SquareActionButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        width: 74,
        height: 74,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: Colors.white.withValues(alpha: 0.08),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        child: Icon(
          icon,
          size: 32,
          color: Colors.white.withValues(alpha: 0.88),
        ),
      ),
    );
  }
}

class _SetProgressDot extends StatelessWidget {
  const _SetProgressDot({
    required this.index,
    required this.set,
    required this.active,
    required this.onTap,
  });

  final int index;
  final SessionSetState set;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final fillColor = set.isCompleted
        ? Colors.white
        : set.isSkipped
        ? const Color(0xFFFFB4A8).withValues(alpha: 0.18)
        : active
        ? Colors.white.withValues(alpha: 0.88)
        : Colors.transparent;
    final borderColor = set.isSkipped
        ? const Color(0xFFFFB4A8)
        : active || set.isCompleted
        ? Colors.white.withValues(alpha: 0.96)
        : Colors.white.withValues(alpha: 0.34);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Column(
        children: [
          Container(
            width: active ? 22 : 18,
            height: active ? 22 : 18,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: fillColor,
              border: Border.all(color: borderColor, width: 2),
              boxShadow: active
                  ? [
                      BoxShadow(
                        color: Colors.white.withValues(alpha: 0.14),
                        blurRadius: 16,
                      ),
                    ]
                  : null,
            ),
            child: set.isSkipped
                ? const Icon(Icons.close_rounded, size: 12)
                : null,
          ),
          const SizedBox(height: 6),
          Text('${index + 1}'),
        ],
      ),
    );
  }
}
