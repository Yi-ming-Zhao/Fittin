import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fittin_v2/src/application/active_session_provider.dart';
import 'package:fittin_v2/src/application/app_locale_provider.dart';
import 'package:fittin_v2/src/domain/models/training_plan.dart';
import 'package:fittin_v2/src/domain/models/training_state.dart';
import 'package:fittin_v2/src/presentation/localization/app_strings.dart';
import 'package:fittin_v2/src/presentation/localization/plan_text.dart';
import 'package:fittin_v2/src/presentation/widgets/floating_timer_widget.dart';
import 'package:fittin_v2/src/presentation/widgets/set_input_row.dart';

class ActiveSessionScreen extends ConsumerStatefulWidget {
  const ActiveSessionScreen({super.key});

  @override
  ConsumerState<ActiveSessionScreen> createState() =>
      _ActiveSessionScreenState();
}

class _ActiveSessionScreenState extends ConsumerState<ActiveSessionScreen> {
  final GlobalKey<FloatingTimerWidgetState> _timerKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
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
        appBar: AppBar(),
        body: Center(
          child: Text(
            sessionState.errorMessage ?? strings.noActiveWorkoutSession,
            style: theme.textTheme.bodyLarge,
          ),
        ),
      );
    }

    final currentExercise = workout.exercises[workout.currentExerciseIndex];
    final localizedWorkout = template == null
        ? null
        : template.findWorkoutById(workout.workoutId);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          (localizedWorkout == null
                  ? workout.dayLabel
                  : localizedWorkoutDayLabel(localizedWorkout, locale))
              .toUpperCase(),
          style: theme.textTheme.titleLarge?.copyWith(letterSpacing: 1.5),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  theme.colorScheme.background,
                  theme.colorScheme.surface,
                ],
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                  child: _WorkoutHeader(
                    workout: workout,
                    strings: strings,
                    displayWorkoutName: localizedWorkout == null
                        ? workout.workoutName
                        : localizedWorkoutName(localizedWorkout, locale),
                    displayDayLabel: localizedWorkout == null
                        ? workout.dayLabel
                        : localizedWorkoutDayLabel(localizedWorkout, locale),
                    currentExercise: currentExercise,
                    displayExerciseName: template == null
                        ? currentExercise.exerciseName
                        : localizedExerciseName(
                            template.findExerciseById(currentExercise.id),
                            locale,
                          ),
                  ),
                ),
                SizedBox(
                  height: 54,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    scrollDirection: Axis.horizontal,
                    itemCount: workout.exercises.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 10),
                    itemBuilder: (context, index) {
                      final exercise = workout.exercises[index];
                      final localizedExercise = template == null
                          ? exercise.exerciseName
                          : localizedExerciseName(
                              template.findExerciseById(exercise.id),
                              locale,
                            );
                      final isSelected = index == workout.currentExerciseIndex;
                      final completedCount = exercise.sets
                          .where((set) => set.isCompleted)
                          .length;
                      return ChoiceChip(
                        label: Text(
                          '${exercise.tier} $localizedExercise',
                          overflow: TextOverflow.ellipsis,
                        ),
                        selected: isSelected,
                        onSelected: (_) => notifier.selectExercise(index),
                        avatar: CircleAvatar(
                          radius: 12,
                          backgroundColor: isSelected
                              ? theme.colorScheme.onPrimary.withOpacity(0.18)
                              : theme.colorScheme.primary.withOpacity(0.12),
                          child: Text(
                            '$completedCount',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: isSelected
                                  ? theme.colorScheme.onPrimary
                                  : theme.colorScheme.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        selectedColor: theme.colorScheme.primary,
                        backgroundColor:
                            theme.colorScheme.surfaceContainerHighest,
                        labelStyle: theme.textTheme.bodyMedium?.copyWith(
                          color: isSelected
                              ? theme.colorScheme.onPrimary
                              : theme.colorScheme.onSurface,
                          fontWeight: FontWeight.w700,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 140),
                    itemCount: currentExercise.sets.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final setInfo = currentExercise.sets[index];
                      return SetInputRow(
                        key: ValueKey(setInfo.id),
                        setIndex: index,
                        role: setInfo.role,
                        targetReps: setInfo.targetReps,
                        completedReps: setInfo.completedReps,
                        targetWeight: setInfo.targetWeight,
                        currentWeight: setInfo.weight,
                        isAmrap: setInfo.isAmrap,
                        isCompleted: setInfo.isCompleted,
                        onRepsChanged: (reps) =>
                            notifier.updateReps(index, reps),
                        onWeightChanged: (weight) =>
                            notifier.updateWeight(index, weight),
                        onToggleComplete: () {
                          notifier.toggleSetComplete(index);
                          if (!setInfo.isCompleted) {
                            _timerKey.currentState?.startTimer(
                              currentExercise.restSeconds,
                            );
                          }
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          FloatingTimerWidget(key: _timerKey),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: SizedBox(
          width: double.infinity,
          child: FloatingActionButton.extended(
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: theme.colorScheme.onPrimary,
            elevation: 4,
            onPressed: sessionState.isLoading
                ? null
                : () async {
                    final success = await notifier.concludeSession();
                    if (!context.mounted) {
                      return;
                    }

                    if (success) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(strings.workoutSaved),
                        ),
                      );
                      Navigator.of(context).pop();
                    } else {
                      final latestState = ref.read(activeSessionProvider);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            latestState.errorMessage ??
                                'Unable to conclude workout.',
                          ),
                        ),
                      );
                    }
                  },
            label: Text(
              sessionState.isLoading ? strings.saving : strings.concludeWorkout,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
              ),
            ),
            icon: sessionState.isLoading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.check_circle_outline_rounded),
          ),
        ),
      ),
    );
  }
}

class _WorkoutHeader extends StatelessWidget {
  const _WorkoutHeader({
    required this.workout,
    required this.strings,
    required this.displayWorkoutName,
    required this.displayDayLabel,
    required this.currentExercise,
    required this.displayExerciseName,
  });

  final WorkoutSessionState workout;
  final AppStrings strings;
  final String displayWorkoutName;
  final String displayDayLabel;
  final ExerciseSessionState currentExercise;
  final String displayExerciseName;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final completedSets = workout.exercises
        .expand((exercise) => exercise.sets)
        .where((set) => set.isCompleted)
        .length;
    final totalSets = workout.exercises
        .expand((exercise) => exercise.sets)
        .length;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        color: theme.colorScheme.onSurface.withOpacity(0.04),
        border: Border.all(
          color: theme.colorScheme.onSurface.withOpacity(0.06),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            displayWorkoutName,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${strings.dayMinutes(displayDayLabel, workout.estimatedDurationMinutes)} • $completedSets/$totalSets sets',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.66),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              _HeaderPill(
                label: strings.isChinese ? '动作' : 'Exercise',
                value: displayExerciseName,
              ),
              const SizedBox(width: 12),
              _HeaderPill(
                label: strings.isChinese ? '层级' : 'Tier',
                value: currentExercise.tier,
              ),
              const SizedBox(width: 12),
              _HeaderPill(
                label: strings.isChinese ? '方案' : 'Scheme',
                value: currentExercise.stageId.replaceAll('t', 'T'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeaderPill extends StatelessWidget {
  const _HeaderPill({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: theme.colorScheme.surface,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label.toUpperCase(),
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.5),
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
