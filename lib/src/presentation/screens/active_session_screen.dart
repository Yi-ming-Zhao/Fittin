import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fittin_v2/src/application/active_session_provider.dart';
import 'package:fittin_v2/src/application/app_locale_provider.dart';
import 'package:fittin_v2/src/domain/models/training_plan.dart';
import 'package:fittin_v2/src/domain/models/training_state.dart';
import 'package:fittin_v2/src/presentation/localization/app_strings.dart';
import 'package:fittin_v2/src/presentation/localization/plan_text.dart';
import 'package:fittin_v2/src/presentation/widgets/dashboard_primitives.dart';

class ActiveSessionScreen extends ConsumerWidget {
  const ActiveSessionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionState = ref.watch(activeSessionProvider);
    final template = ref.watch(activeTemplateProvider).valueOrNull;
    final locale = ref.watch(appLocaleProvider);
    final strings = AppStrings.of(context, ref);
    final notifier = ref.read(activeSessionProvider.notifier);
    final theme = Theme.of(context);
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
    final currentSetIndex = currentExercise.sets.indexWhere(
      (set) => !set.isCompleted,
    );
    final resolvedSetIndex = currentSetIndex == -1
        ? currentExercise.sets.length - 1
        : currentSetIndex;
    final currentSet = currentExercise.sets[resolvedSetIndex];
    final totalSetCount = currentExercise.sets.length;
    final compactWorkoutTitle = _buildWorkoutContextTitle(
      workout: workout,
      displayName: _localizedWorkoutName(template, workout, locale),
      currentStageId: currentExercise.stageId,
    );

    return DashboardPageScaffold(
      bottomPadding: 28,
      children: [
        Row(
          children: [
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
            const SizedBox(width: 12),
            _HeaderIconButton(
              icon: Icons.close_rounded,
              onTap: () => Navigator.of(context).maybePop(),
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
                              ? '第 ${resolvedSetIndex + 1} 组 / 共 $totalSetCount 组'
                              : 'Set ${resolvedSetIndex + 1} / $totalSetCount',
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
                      label: strings.isChinese ? '层级' : 'Tier',
                      value: currentExercise.tier,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: _CompactMetaTile(
                      label: strings.isChinese ? '目标' : 'Target',
                      value:
                          '${_formatWeight(currentSet.targetWeight)} · ${currentSet.targetReps}${currentSet.isAmrap ? '+' : ''}',
                      highlight: true,
                    ),
                  ),
                ],
              ),
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
                  _SquareActionButton(
                    icon: Icons.check_rounded,
                    onTap: () => notifier.completeSet(resolvedSetIndex),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  color: Colors.white.withValues(alpha: 0.05),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.08),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            strings.isChinese ? '当前次数' : 'Current Reps',
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: Colors.white.withValues(alpha: 0.54),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${currentSet.completedReps}',
                            style: theme.textTheme.displaySmall?.copyWith(
                              fontWeight: FontWeight.w800,
                              letterSpacing: -2,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      currentSet.isAmrap ? 'AMRAP' : '${currentSet.targetReps}',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: Colors.white.withValues(alpha: 0.72),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _WeightEditorTile(
                      label: strings.isChinese ? '重量 -' : 'Weight -',
                      value: _formatWeight(currentSet.weight),
                      trailing: '-2.5',
                      onTap: () => notifier.updateWeight(
                        resolvedSetIndex,
                        currentSet.weight - 2.5 < 0
                            ? 0
                            : currentSet.weight - 2.5,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _WeightEditorTile(
                      label: strings.isChinese ? '重量 +' : 'Weight +',
                      value: _formatWeight(currentSet.weight),
                      trailing: '+2.5',
                      highlight: true,
                      onTap: () => notifier.updateWeight(
                        resolvedSetIndex,
                        currentSet.weight + 2.5,
                      ),
                    ),
                  ),
                ],
              ),
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
                title: Text(strings.confirmConcludeWorkoutTitle),
                content: Text(strings.confirmConcludeWorkoutMessage),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(dialogContext).pop(false),
                    child: Text(strings.cancel),
                  ),
                  FilledButton(
                    onPressed: () => Navigator.of(dialogContext).pop(true),
                    child: Text(strings.concludeWorkout),
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

String _formatWeight(double value) {
  return value.truncateToDouble() == value
      ? '${value.toStringAsFixed(0)} kg'
      : '${value.toStringAsFixed(1)} kg';
}

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: Colors.white.withValues(alpha: 0.05),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        child: Icon(icon),
      ),
    );
  }
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
            maxLines: 1,
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

class _WeightEditorTile extends StatelessWidget {
  const _WeightEditorTile({
    required this.label,
    required this.value,
    required this.trailing,
    required this.onTap,
    this.highlight = false,
  });

  final String label;
  final String value;
  final String trailing;
  final VoidCallback onTap;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: Colors.white.withValues(alpha: highlight ? 0.08 : 0.05),
          border: Border.all(
            color: Colors.white.withValues(alpha: highlight ? 0.14 : 0.08),
          ),
        ),
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
            Row(
              children: [
                Expanded(
                  child: Text(
                    value,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: -1,
                    ),
                  ),
                ),
                Text(
                  trailing,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.66),
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ],
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
  });

  final int index;
  final SessionSetState set;
  final bool active;

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
    return Column(
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
    );
  }
}
