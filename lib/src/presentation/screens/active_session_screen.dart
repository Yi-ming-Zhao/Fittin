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
        DashboardSurfaceCard(
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
                  _AnimatedCheckButton(
                    controller: _completionController,
                    onTap: () => _handleCompleteSet(notifier, resolvedSetIndex),
                  ),
                ],
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
                onLongPress: () => _editWeight(
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
                        (currentSet.completedRpe ?? currentSet.targetRpe ?? 7) -
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
    required dynamic theme,
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
    required dynamic theme,
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

class _WeightEntryCard extends StatelessWidget {
  const _WeightEntryCard({
    required this.strings,
    required this.displayWeight,
    required this.displayUnit,
    required this.step,
    required this.onDecrease,
    required this.onIncrease,
    required this.onLongPress,
  });

  final AppStrings strings;
  final double displayWeight;
  final String displayUnit;
  final double step;
  final VoidCallback onDecrease;
  final VoidCallback onIncrease;
  final VoidCallback onLongPress;

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
                  onLongPress: onLongPress,
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
                          strings.isChinese
                              ? '长按直接输入重量'
                              : 'Long press to type weight',
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

class _AnimatedCheckButton extends StatelessWidget {
  const _AnimatedCheckButton({required this.controller, required this.onTap});

  final AnimationController controller;
  final VoidCallback onTap;

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
              width: 74,
              height: 74,
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
              child: const Icon(Icons.check_rounded, size: 32),
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
        : active
        ? Colors.white.withValues(alpha: 0.88)
        : Colors.transparent;
    final borderColor = active || set.isCompleted
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
          ),
          const SizedBox(height: 6),
          Text('${index + 1}'),
        ],
      ),
    );
  }
}
