import 'dart:async';

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

    final page = DashboardPageScaffold(
      scrollable: false,
      extendBody: false,
      safeAreaBottom: true,
      topPadding: 12,
      bottomPadding: 12,
      children: [
        _SessionHeader(
          theme: fittinTheme,
          workoutTitle: compactWorkoutTitle,
          exerciseName: currentExerciseName,
          tier: currentExercise.tier,
          setIndex: resolvedSetIndex,
          totalSets: currentExercise.sets.length,
          displayUnit: displayUnit,
          canSwitchUnit: _supportsUnitToggle(displayUnit),
          onToggleUnit: () => notifier.switchExerciseDisplayUnit(
            displayUnit == LoadUnits.kg ? LoadUnits.lbs : LoadUnits.kg,
          ),
          onOpenTools: () => _openWeightTools(
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
          exercises: workout.exercises,
          activeExerciseIndex: workout.currentExerciseIndex,
          localizedExercise: localizedExercise,
          onSelectExercise: notifier.selectExercise,
        ),
        const SizedBox(height: 10),
        Expanded(
          child: recordingMode == WorkoutRecordingMode.card
              ? _CardSetStack(
                  theme: fittinTheme,
                  strings: strings,
                  setIndex: resolvedSetIndex,
                  totalSets: currentExercise.sets.length,
                  currentSet: currentSet,
                  upcomingSets: currentExercise.sets
                      .skip(resolvedSetIndex + 1)
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
                    currentValue:
                        currentSet.completedRpe ?? currentSet.targetRpe,
                    onSubmit: (value) =>
                        notifier.updateCompletedRpe(resolvedSetIndex, value),
                  ),
                  onComplete: () =>
                      _handleCompleteSet(notifier, resolvedSetIndex),
                  onCancel: () => notifier.cancelSet(resolvedSetIndex),
                  onPreviousSet: resolvedSetIndex > 0
                      ? () => notifier.selectSet(resolvedSetIndex - 1)
                      : null,
                  onNextSet: resolvedSetIndex < currentExercise.sets.length - 1
                      ? () => notifier.selectSet(resolvedSetIndex + 1)
                      : null,
                )
              : _TraditionalSetLogger(
                  strings: strings,
                  setIndex: resolvedSetIndex,
                  totalSets: currentExercise.sets.length,
                  currentSet: currentSet,
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
                    currentValue:
                        currentSet.completedRpe ?? currentSet.targetRpe,
                    onSubmit: (value) =>
                        notifier.updateCompletedRpe(resolvedSetIndex, value),
                  ),
                  onComplete: () =>
                      _handleCompleteSet(notifier, resolvedSetIndex),
                ),
        ),
        const SizedBox(height: 10),
        _SetProgressRail(
          sets: currentExercise.sets,
          activeIndex: resolvedSetIndex,
          onSelect: notifier.selectSet,
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 48,
          child: PremiumPrimaryButton(
            label: sessionState.isLoading
                ? strings.saving
                : strings.concludeWorkout,
            icon: Icons.check_circle_outline_rounded,
            loading: sessionState.isLoading,
            onPressed: () => _confirmAndConclude(
              strings: strings,
              theme: fittinTheme,
              notifier: notifier,
            ),
          ),
        ),
      ],
    );
    return AbsorbPointer(absorbing: sessionState.isLoading, child: page);
  }

  Future<void> _confirmAndConclude({
    required AppStrings strings,
    required FittinTheme theme,
    required ActiveSessionNotifier notifier,
  }) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: theme.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(theme.radius),
          side: BorderSide(color: theme.border),
        ),
        title: Text(
          strings.confirmConcludeWorkoutTitle,
          style: theme.displayStyle(22, theme.fg),
        ),
        content: Text(
          strings.confirmConcludeWorkoutMessage,
          style: theme.uiStyle(14, theme.fgDim).copyWith(height: 1.45),
        ),
        actions: [
          FittinBtn(
            theme,
            strings.cancel,
            size: 'sm',
            variant: 'secondary',
            onPressed: () => Navigator.of(dialogContext).pop(false),
          ),
          FittinBtn(
            theme,
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
    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(strings.workoutSaved)));
      Navigator.of(context).pop();
      return;
    }
    final latestState = ref.read(activeSessionProvider);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          latestState.errorMessage ?? 'Unable to conclude workout.',
        ),
      ),
    );
  }

  void _handleCompleteSet(ActiveSessionNotifier notifier, int setIndex) {
    notifier.completeSet(setIndex);
    unawaited(_completionController.forward(from: 0));
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

class _SessionHeader extends StatelessWidget {
  const _SessionHeader({
    required this.theme,
    required this.workoutTitle,
    required this.exerciseName,
    required this.tier,
    required this.setIndex,
    required this.totalSets,
    required this.displayUnit,
    required this.canSwitchUnit,
    required this.onToggleUnit,
    required this.onOpenTools,
    required this.exercises,
    required this.activeExerciseIndex,
    required this.localizedExercise,
    required this.onSelectExercise,
  });

  final FittinTheme theme;
  final String workoutTitle;
  final String exerciseName;
  final String tier;
  final int setIndex;
  final int totalSets;
  final String displayUnit;
  final bool canSwitchUnit;
  final VoidCallback onToggleUnit;
  final VoidCallback onOpenTools;
  final List<ExerciseSessionState> exercises;
  final int activeExerciseIndex;
  final String Function(ExerciseSessionState) localizedExercise;
  final ValueChanged<int> onSelectExercise;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        DashboardBackButton(theme: theme),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              FittinEyebrow(theme, workoutTitle),
              const SizedBox(height: 3),
              Text(
                exerciseName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.displayStyle(24, theme.fg).copyWith(height: 1),
              ),
              const SizedBox(height: 4),
              Text(
                '$tier · SET ${setIndex + 1} / $totalSets',
                style: theme.uiStyle(11, theme.fgMuted, FontWeight.w600),
              ),
            ],
          ),
        ),
        if (canSwitchUnit)
          _HeaderTextButton(
            key: const ValueKey('session-unit-toggle'),
            label: displayUnit == LoadUnits.kg ? 'KG' : 'LB',
            onTap: onToggleUnit,
          ),
        const SizedBox(width: 6),
        _HeaderIconButton(
          key: const ValueKey('session-weight-tools'),
          icon: Icons.calculate_outlined,
          tooltip: 'Weight tools',
          onTap: onOpenTools,
        ),
        const SizedBox(width: 6),
        _ExerciseSwitchMenu(
          exercises: exercises,
          activeIndex: activeExerciseIndex,
          localizedExercise: localizedExercise,
          onSelect: onSelectExercise,
        ),
      ],
    );
  }
}

class _HeaderTextButton extends StatelessWidget {
  const _HeaderTextButton({
    super.key,
    required this.label,
    required this.onTap,
  });

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: 38,
        height: 38,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: 0.8,
          ),
        ),
      ),
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          child: Icon(icon, size: 18),
        ),
      ),
    );
  }
}

class _SetProgressRail extends StatelessWidget {
  const _SetProgressRail({
    required this.sets,
    required this.activeIndex,
    required this.onSelect,
  });

  final List<SessionSetState> sets;
  final int activeIndex;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 28,
      child: Row(
        children: [
          for (var index = 0; index < sets.length; index++) ...[
            Expanded(
              child: InkWell(
                key: ValueKey('session-set-progress-$index'),
                onTap: () => onSelect(index),
                borderRadius: BorderRadius.circular(99),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  height: 6,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(99),
                    color: sets[index].isCompleted
                        ? Colors.white.withValues(alpha: 0.9)
                        : sets[index].isSkipped
                        ? const Color(0xFFB77A70).withValues(alpha: 0.7)
                        : index == activeIndex
                        ? Colors.white.withValues(alpha: 0.38)
                        : Colors.white.withValues(alpha: 0.1),
                    border: index == activeIndex
                        ? Border.all(
                            color: Colors.white.withValues(alpha: 0.52),
                          )
                        : null,
                  ),
                ),
              ),
            ),
            if (index != sets.length - 1) const SizedBox(width: 6),
          ],
        ],
      ),
    );
  }
}

class _TraditionalSetLogger extends StatelessWidget {
  const _TraditionalSetLogger({
    required this.strings,
    required this.setIndex,
    required this.totalSets,
    required this.currentSet,
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
  });

  final AppStrings strings;
  final int setIndex;
  final int totalSets;
  final SessionSetState currentSet;
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DashboardSurfaceCard(
      key: const ValueKey('traditional-set-logger'),
      highlight: true,
      radius: 28,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                strings.isChinese
                    ? '第 ${setIndex + 1} / $totalSets 组'
                    : 'SET ${setIndex + 1} / $totalSets',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.56),
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                ),
              ),
              const Spacer(),
              Text(
                _targetSummary(
                  strings,
                  currentSet,
                  displayTargetWeight,
                  displayUnit,
                ),
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _CardMetric(
                  label: strings.isChinese ? '完成次数' : 'REPS',
                  value: '${currentSet.completedReps}',
                  onDecrease: onDecreaseReps,
                  onIncrease: onIncreaseReps,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: InkWell(
                  key: const ValueKey('current-weight-editor'),
                  onTap: onEditWeight,
                  borderRadius: BorderRadius.circular(20),
                  child: _CardMetric(
                    label: displayUnit == LoadUnits.kg ? 'KG' : 'LB',
                    value: _formatWeightValue(displayWeight),
                    onDecrease: onDecreaseWeight,
                    onIncrease: onIncreaseWeight,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          InkWell(
            key: const ValueKey('current-rpe-editor'),
            onTap: onEditRpe,
            borderRadius: BorderRadius.circular(18),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                color: Colors.white.withValues(alpha: 0.05),
              ),
              child: Row(
                children: [
                  Text(
                    strings.isChinese ? '实际 RPE' : 'PERFORMED RPE',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: Colors.white.withValues(alpha: 0.5),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${currentSet.completedRpe ?? currentSet.targetRpe ?? '—'}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (plateBreakdown != null) ...[
            const Spacer(),
            _BarbellGraphic(breakdown: plateBreakdown!, height: 58),
          ] else
            const Spacer(),
          _AnimatedCheckButton(
            key: const ValueKey('complete-current-set'),
            controller: completionController,
            onTap: onComplete,
            size: 58,
          ),
        ],
      ),
    );
  }
}

class _CardSetStack extends StatefulWidget {
  const _CardSetStack({
    required this.theme,
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
    required this.onPreviousSet,
    required this.onNextSet,
  });

  final FittinTheme theme;
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
  final VoidCallback? onPreviousSet;
  final VoidCallback? onNextSet;

  @override
  State<_CardSetStack> createState() => _CardSetStackState();
}

class _CardSetStackState extends State<_CardSetStack> {
  static const _commitDistance = 56.0;
  static const _commitVelocity = 700.0;
  static const _axisLockDistance = 18.0;
  static const _axisDominance = 1.15;
  static const _flyOutDuration = Duration(milliseconds: 140);
  Offset _dragOffset = Offset.zero;
  _CardDragAxis? _dragAxis;
  Duration? _pointerDownAt;
  Duration? _pointerUpAt;
  Offset? _pointerDownPosition;
  Offset? _pointerUpPosition;
  bool _animate = false;
  bool _committing = false;

  @override
  Widget build(BuildContext context) {
    final dragProgress = (_dragOffset.distance / _commitDistance).clamp(
      0.0,
      1.0,
    );
    final leftProgress = (-_dragOffset.dx / _commitDistance).clamp(0.0, 1.0);
    final rightProgress = (_dragOffset.dx / _commitDistance).clamp(0.0, 1.0);
    final upProgress = (-_dragOffset.dy / _commitDistance).clamp(0.0, 1.0);
    final downProgress = (_dragOffset.dy / _commitDistance).clamp(0.0, 1.0);
    final isVertical = _dragOffset.dy.abs() > _dragOffset.dx.abs();
    final activeColor = isVertical
        ? (_dragOffset.dy < 0 ? widget.theme.accent : const Color(0xFFB77A70))
        : widget.theme.fgDim;
    final transform = Matrix4.translationValues(
      _dragOffset.dx,
      _dragOffset.dy + (_dragOffset.dx.abs() / 42).clamp(0, 5),
      0,
    )..rotateZ(_dragOffset.dx / 1650);

    final stack = LayoutBuilder(
      builder: (context, constraints) {
        const bottomReveal = 20.0;
        return Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(
              bottom: bottomReveal,
              child: IgnorePointer(
                child: Stack(
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Opacity(
                        opacity: widget.onPreviousSet == null
                            ? 0
                            : rightProgress,
                        child: _GestureStamp(
                          label: widget.strings.isChinese ? '上一组' : 'PREVIOUS',
                          icon: Icons.arrow_forward_rounded,
                          color: widget.theme.fgDim,
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Opacity(
                        opacity: widget.onNextSet == null ? 0 : leftProgress,
                        child: _GestureStamp(
                          label: widget.strings.isChinese ? '下一组' : 'NEXT',
                          icon: Icons.arrow_back_rounded,
                          color: widget.theme.fgDim,
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.topCenter,
                      child: Opacity(
                        opacity: downProgress,
                        child: _GestureStamp(
                          label: widget.strings.isChinese ? '跳过' : 'SKIP',
                          icon: Icons.keyboard_arrow_down_rounded,
                          color: const Color(0xFFB77A70),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Opacity(
                        opacity: upProgress,
                        child: _GestureStamp(
                          label: widget.strings.isChinese ? '记录' : 'LOG',
                          icon: Icons.check_rounded,
                          color: widget.theme.accent,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            for (var depth = widget.upcomingSets.length; depth >= 1; depth--)
              AnimatedPositioned(
                duration: const Duration(milliseconds: 170),
                curve: Curves.easeOutCubic,
                left:
                    (depth.isEven ? 7.0 : 13.0) * depth -
                    dragProgress * depth * 3,
                right:
                    (depth.isEven ? 13.0 : 7.0) * depth -
                    dragProgress * depth * 3,
                top: 9.0 * depth - dragProgress * depth * 3,
                bottom: bottomReveal - depth * 2,
                child: Transform.rotate(
                  angle: depth.isEven ? -0.014 * depth : 0.012 * depth,
                  child: _StackBackCard(
                    set: widget.upcomingSets[depth - 1],
                    setNumber: widget.setIndex + depth + 1,
                    displayUnit: widget.displayUnit,
                    emphasis: 1 - depth * 0.2 + dragProgress * 0.16,
                  ),
                ),
              ),
            Positioned.fill(
              bottom: bottomReveal,
              child: Semantics(
                label: widget.strings.isChinese
                    ? '当前第 ${widget.setIndex + 1} 组，左滑下一组，右滑上一组，上滑记录，下滑跳过'
                    : 'Current set ${widget.setIndex + 1}. Swipe left for next, right for previous, up to log, or down to skip.',
                child: GestureDetector(
                  key: const ValueKey('active-set-card'),
                  behavior: HitTestBehavior.opaque,
                  onPanStart: _committing ? null : _startDrag,
                  onPanUpdate: _committing ? null : _updateDrag,
                  onPanEnd: _committing ? null : _resolveDrag,
                  onPanCancel: _committing ? null : _resetDrag,
                  child: AnimatedContainer(
                    duration: _animate
                        ? const Duration(milliseconds: 180)
                        : Duration.zero,
                    curve: Curves.easeOutCubic,
                    transform: transform,
                    transformAlignment: Alignment.center,
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(28),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          widget.theme.surfaceHi.withValues(alpha: 0.72),
                          widget.theme.surfaceSolid,
                          widget.theme.bgDeep,
                        ],
                        stops: const [0, 0.5, 1],
                      ),
                      border: Border.all(
                        color: Color.lerp(
                          widget.theme.borderHi,
                          activeColor,
                          (leftProgress > rightProgress
                                  ? leftProgress
                                  : rightProgress) *
                              0.7,
                        )!,
                        width: 0.8,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.42),
                          blurRadius: 30,
                          offset: const Offset(0, 16),
                        ),
                        BoxShadow(
                          color: widget.theme.fg.withValues(alpha: 0.035),
                          blurRadius: 0,
                          spreadRadius: 1,
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
                                borderRadius: BorderRadius.circular(999),
                                border: Border.all(
                                  color: widget.theme.borderHi,
                                ),
                              ),
                              child: Text(
                                widget.strings.isChinese
                                    ? '第 ${widget.setIndex + 1} / ${widget.totalSets} 组'
                                    : 'SET ${widget.setIndex + 1} / ${widget.totalSets}',
                                style: widget.theme
                                    .uiStyle(
                                      10,
                                      widget.theme.fgDim,
                                      FontWeight.w700,
                                    )
                                    .copyWith(letterSpacing: 0.7),
                              ),
                            ),
                            const Spacer(),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.keyboard_double_arrow_left_rounded,
                                      size: 15,
                                    ),
                                    const SizedBox(width: 2),
                                    Text(
                                      widget.strings.isChinese ? '下一组' : 'NEXT',
                                      style: widget.theme.uiStyle(
                                        9,
                                        widget.theme.fgMuted,
                                        FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      widget.strings.isChinese ? '上一组' : 'PREV',
                                      style: widget.theme.uiStyle(
                                        9,
                                        widget.theme.fgMuted,
                                        FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(width: 2),
                                    const Icon(
                                      Icons.keyboard_double_arrow_right_rounded,
                                      size: 15,
                                    ),
                                  ],
                                ),
                                Text(
                                  widget.strings.isChinese
                                      ? '↑ 记录 · ↓ 跳过'
                                      : 'UP LOG · DOWN SKIP',
                                  style: widget.theme.uiStyle(
                                    8,
                                    widget.theme.fgMuted,
                                    FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: _CardMetric(
                                label: widget.strings.isChinese
                                    ? '完成次数'
                                    : 'REPS',
                                value: '${widget.currentSet.completedReps}',
                                onDecrease: widget.onDecreaseReps,
                                onIncrease: widget.onIncreaseReps,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _CardTarget(
                                theme: widget.theme,
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
                          height: 58,
                          decoration: BoxDecoration(
                            color: widget.theme.fg.withValues(alpha: 0.045),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: widget.theme.border),
                          ),
                          child: Row(
                            children: [
                              IconButton(
                                visualDensity: VisualDensity.compact,
                                onPressed: widget.onDecreaseWeight,
                                icon: const Icon(Icons.remove_rounded),
                              ),
                              Expanded(
                                child: InkWell(
                                  key: const ValueKey('current-weight-editor'),
                                  onTap: widget.onEditWeight,
                                  borderRadius: BorderRadius.circular(16),
                                  child: Center(
                                    child: Text(
                                      _formatDisplayWeight(
                                        widget.displayWeight,
                                        widget.displayUnit,
                                      ),
                                      style: widget.theme.numStyle(
                                        24,
                                        widget.theme.fg,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              IconButton(
                                visualDensity: VisualDensity.compact,
                                onPressed: widget.onIncreaseWeight,
                                icon: const Icon(Icons.add_rounded),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                widget.strings.isChinese
                                    ? '目标 ${widget.currentSet.targetReps}${widget.currentSet.isAmrap ? "+" : ""} 次'
                                    : 'Target ${widget.currentSet.targetReps}${widget.currentSet.isAmrap ? "+" : ""} reps',
                                style: widget.theme.uiStyle(
                                  12,
                                  widget.theme.fgDim,
                                  FontWeight.w600,
                                ),
                              ),
                            ),
                            InkWell(
                              key: const ValueKey('current-rpe-editor'),
                              onTap: widget.onEditRpe,
                              borderRadius: BorderRadius.circular(999),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 7,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(999),
                                  border: Border.all(
                                    color: widget.theme.border,
                                  ),
                                ),
                                child: Text(
                                  'RPE ${widget.currentSet.completedRpe ?? widget.currentSet.targetRpe ?? '—'}',
                                  style: widget.theme.uiStyle(
                                    12,
                                    widget.theme.fg,
                                    FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (widget.plateBreakdown != null) ...[
                          const Spacer(),
                          _BarbellGraphic(
                            breakdown: widget.plateBreakdown!,
                            height: 58,
                          ),
                        ] else
                          const Spacer(),
                        SizedBox(
                          height: 56,
                          child: Stack(
                            children: [
                              Align(
                                alignment: Alignment.center,
                                child: _AnimatedCheckButton(
                                  key: const ValueKey('complete-current-set'),
                                  controller: widget.completionController,
                                  onTap: widget.onComplete,
                                  size: 56,
                                ),
                              ),
                              Align(
                                alignment: Alignment.centerRight,
                                child: IconButton.filledTonal(
                                  key: const ValueKey('cancel-current-set'),
                                  tooltip: widget.strings.isChinese
                                      ? '跳过当前组'
                                      : 'Skip current set',
                                  style: IconButton.styleFrom(
                                    backgroundColor: const Color(
                                      0xFFB77A70,
                                    ).withValues(alpha: 0.2),
                                    foregroundColor: const Color(0xFFE7B8B0),
                                  ),
                                  onPressed: widget.onCancel,
                                  icon: const Icon(Icons.redo_rounded),
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
            ),
          ],
        );
      },
    );
    return Listener(
      onPointerDown: _trackPointerDown,
      onPointerUp: _trackPointerUp,
      child: stack,
    );
  }

  void _startDrag(DragStartDetails _) {
    setState(() {
      _animate = false;
    });
  }

  void _updateDrag(DragUpdateDetails details) {
    final candidate = _dragOffset + details.delta;
    final axis = _dragAxis ?? _dominantAxis(candidate, _axisLockDistance);
    setState(() {
      _animate = false;
      _dragAxis = axis;
      _dragOffset = switch (axis) {
        _CardDragAxis.horizontal => Offset(candidate.dx, 0),
        _CardDragAxis.vertical => Offset(0, candidate.dy),
        null => candidate,
      };
    });
  }

  Future<void> _resolveDrag(DragEndDetails details) async {
    final recognizerVelocity = details.velocity.pixelsPerSecond;
    final trackedVelocity = _trackedVelocity();
    final velocity = Offset(
      trackedVelocity.dx.abs() > recognizerVelocity.dx.abs()
          ? trackedVelocity.dx
          : recognizerVelocity.dx,
      trackedVelocity.dy.abs() > recognizerVelocity.dy.abs()
          ? trackedVelocity.dy
          : recognizerVelocity.dy,
    );
    final distanceAxis = _dominantAxis(_dragOffset, 0);
    final velocityAxis = _dominantAxis(velocity, _commitVelocity);
    final axis = _dragAxis ?? velocityAxis ?? distanceAxis;
    if (axis == null) {
      _resetDrag();
      return;
    }
    final distance = axis == _CardDragAxis.horizontal
        ? _dragOffset.dx
        : _dragOffset.dy;
    final axisVelocity = axis == _CardDragAxis.horizontal
        ? velocity.dx
        : velocity.dy;
    final commits =
        distance.abs() >= _commitDistance ||
        axisVelocity.abs() >= _commitVelocity;
    final directionValue = distance.abs() >= _commitDistance
        ? distance
        : axisVelocity;
    final action = switch (axis) {
      _CardDragAxis.horizontal =>
        directionValue < 0 ? widget.onNextSet : widget.onPreviousSet,
      _CardDragAxis.vertical =>
        directionValue < 0 ? widget.onComplete : widget.onCancel,
    };
    if (!commits || action == null) {
      _resetDrag();
      return;
    }
    final direction = axis == _CardDragAxis.horizontal
        ? Offset(directionValue.sign, 0)
        : Offset(0, directionValue.sign);
    final screenSize = MediaQuery.sizeOf(context);
    setState(() {
      _committing = true;
      _animate = true;
      _dragOffset = Offset(
        direction.dx * screenSize.width * 1.25,
        direction.dy * screenSize.height,
      );
    });
    action();
    await Future<void>.delayed(_flyOutDuration);
    if (!mounted) return;
    setState(() {
      _dragOffset = Offset.zero;
      _dragAxis = null;
      _clearPointerTracking();
      _animate = false;
      _committing = false;
    });
  }

  Offset _trackedVelocity() {
    final startedAt = _pointerDownAt;
    final endedAt = _pointerUpAt;
    final startPosition = _pointerDownPosition;
    final endPosition = _pointerUpPosition;
    if (startedAt == null ||
        endedAt == null ||
        startPosition == null ||
        endPosition == null) {
      return Offset.zero;
    }
    final elapsedMicros = (endedAt - startedAt).inMicroseconds;
    if (elapsedMicros <= 0) {
      return Offset.zero;
    }
    final elapsedSeconds = elapsedMicros / Duration.microsecondsPerSecond;
    return (endPosition - startPosition) / elapsedSeconds;
  }

  void _trackPointerDown(PointerDownEvent event) {
    if (_committing) {
      return;
    }
    _pointerDownAt = event.timeStamp;
    _pointerUpAt = null;
    _pointerDownPosition = event.position;
    _pointerUpPosition = null;
  }

  void _trackPointerUp(PointerUpEvent event) {
    _pointerUpAt = event.timeStamp;
    _pointerUpPosition = event.position;
  }

  void _clearPointerTracking() {
    _pointerDownAt = null;
    _pointerUpAt = null;
    _pointerDownPosition = null;
    _pointerUpPosition = null;
  }

  _CardDragAxis? _dominantAxis(Offset value, double minimumMagnitude) {
    final horizontal = value.dx.abs();
    final vertical = value.dy.abs();
    if (horizontal < minimumMagnitude && vertical < minimumMagnitude) {
      return null;
    }
    if (horizontal > vertical * _axisDominance) {
      return _CardDragAxis.horizontal;
    }
    if (vertical > horizontal * _axisDominance) {
      return _CardDragAxis.vertical;
    }
    return null;
  }

  void _resetDrag() {
    setState(() {
      _animate = true;
      _dragOffset = Offset.zero;
      _dragAxis = null;
      _clearPointerTracking();
    });
  }
}

enum _CardDragAxis { horizontal, vertical }

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
    required this.theme,
    required this.strings,
    required this.set,
    required this.targetWeight,
    required this.unit,
  });

  final FittinTheme theme;
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
        color: theme.accent.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            strings.isChinese ? '计划目标' : 'PRESCRIBED',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: theme.accentInk.withValues(alpha: 0.58),
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          FittedBox(
            child: Text(
              '${_formatDisplayWeight(targetWeight, unit)} × ${set.targetReps}${set.isAmrap ? '+' : ''}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: theme.accentInk,
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
    final detail = breakdown.platesPerSide
        .map((plate) => '${_formatWeightValue(plate.weight)} × ${plate.count}')
        .join(' + ');

    Widget plate(double weight, {required String side, required int index}) {
      final spec = _plateVisualSpec(
        weight: weight,
        unit: breakdown.unit,
        maxHeight: height - 2,
      );
      return Container(
        key: ValueKey('barbell-plate-${breakdown.unit}-$side-$index-$weight'),
        width: spec.width,
        height: spec.height,
        margin: const EdgeInsets.symmetric(horizontal: 0.8),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: spec.color,
          borderRadius: BorderRadius.circular(2),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.18),
            width: 0.7,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 3,
              offset: const Offset(0, 1.5),
            ),
          ],
        ),
        child: RotatedBox(
          quarterTurns: 3,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              _formatWeightValue(weight),
              style: TextStyle(
                color: spec.labelColor,
                fontSize: 6.5,
                fontWeight: FontWeight.w900,
                height: 1,
              ),
            ),
          ),
        ),
      );
    }

    Widget sleeveEnd() => SizedBox(
      width: 13,
      child: Container(
        height: 5,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF74797D), Color(0xFFD6D9DB), Color(0xFF676C70)],
          ),
          borderRadius: BorderRadius.circular(99),
        ),
      ),
    );

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
              height: 3,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF5E6367),
                    Color(0xFFE1E3E4),
                    Color(0xFF555A5E),
                  ],
                ),
                borderRadius: BorderRadius.circular(99),
              ),
            ),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  sleeveEnd(),
                  _BarbellCollar(height: height * 0.46),
                  for (var index = plates.length - 1; index >= 0; index--)
                    plate(plates[index], side: 'left', index: index),
                  const _BarbellShoulder(),
                  SizedBox(width: height * 0.98),
                  const _BarbellShoulder(),
                  for (var index = 0; index < plates.length; index++)
                    plate(plates[index], side: 'right', index: index),
                  _BarbellCollar(height: height * 0.46),
                  sleeveEnd(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

_BarbellPlateVisualSpec _plateVisualSpec({
  required double weight,
  required String unit,
  required double maxHeight,
}) {
  if (unit == LoadUnits.lbs) {
    final diameter = switch (weight) {
      >= 45 => 450.0,
      >= 35 => 400.0,
      >= 25 => 325.0,
      >= 10 => 228.0,
      >= 5 => 190.0,
      _ => 160.0,
    };
    return _BarbellPlateVisualSpec(
      height: (maxHeight * diameter / 450).clamp(18, maxHeight),
      width: switch (weight) {
        >= 45 => 12,
        >= 35 => 10,
        >= 25 => 9,
        >= 10 => 7,
        >= 5 => 6,
        _ => 5,
      },
      color: const Color(0xFF858B90),
      labelColor: const Color(0xFF111315),
    );
  }

  final diameter = switch (weight) {
    >= 20 => 450.0,
    >= 15 => 400.0,
    >= 10 => 325.0,
    >= 5 => 228.0,
    >= 2.5 => 190.0,
    _ => 160.0,
  };
  final color = switch (weight) {
    25 => const Color(0xFFB94A48),
    20 => const Color(0xFF416F9F),
    15 => const Color(0xFFC3A74A),
    10 => const Color(0xFF4E7A45),
    5 => const Color(0xFFD8D5CC),
    2.5 => const Color(0xFF292A2C),
    _ => const Color(0xFFA7ADB2),
  };
  final darkLabel = weight == 15 || weight == 5 || weight <= 1.25;
  return _BarbellPlateVisualSpec(
    height: (maxHeight * diameter / 450).clamp(18, maxHeight),
    width: switch (weight) {
      >= 25 => 12,
      >= 20 => 10,
      >= 15 => 9,
      >= 10 => 8,
      >= 5 => 7,
      >= 2.5 => 6,
      _ => 5,
    },
    color: color,
    labelColor: darkLabel ? const Color(0xFF17191B) : Colors.white,
  );
}

class _BarbellPlateVisualSpec {
  const _BarbellPlateVisualSpec({
    required this.height,
    required this.width,
    required this.color,
    required this.labelColor,
  });

  final double height;
  final double width;
  final Color color;
  final Color labelColor;
}

class _BarbellCollar extends StatelessWidget {
  const _BarbellCollar({required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 7,
      height: height,
      margin: const EdgeInsets.symmetric(horizontal: 2.5),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF777C80), Color(0xFFD4D7D9), Color(0xFF6B7074)],
        ),
        borderRadius: BorderRadius.circular(2),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
    );
  }
}

class _BarbellShoulder extends StatelessWidget {
  const _BarbellShoulder();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 5,
      height: 27,
      margin: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        color: const Color(0xFFBFC3C6),
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
