import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/active_session_provider.dart';
import '../../application/app_locale_provider.dart';
import '../../domain/models/training_state.dart';
import '../../domain/models/training_plan.dart';
import '../localization/app_strings.dart';
import '../localization/plan_text.dart';
import '../screens/active_session_screen.dart';
import '../screens/share_screen.dart';

class TodayWorkoutHeroCard extends ConsumerWidget {
  const TodayWorkoutHeroCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionState = ref.watch(activeSessionProvider);
    final summaryAsync = ref.watch(todayWorkoutSummaryProvider);
    final templateAsync = ref.watch(activeTemplateProvider);
    final strings = AppStrings.of(context, ref);

    return summaryAsync.when(
      data: (summary) => templateAsync.when(
        data: (template) => GestureDetector(
        onTap: () async {
          await ref.read(activeSessionProvider.notifier).startOrResumeSession();
          if (!context.mounted) {
            return;
          }

          final latestState = ref.read(activeSessionProvider);
          if (latestState.errorMessage != null) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(latestState.errorMessage!)));
            return;
          }

          Navigator.of(context).push(
            PageRouteBuilder(
              transitionDuration: const Duration(milliseconds: 450),
              pageBuilder: (context, animation, secondaryAnimation) =>
                  const ActiveSessionScreen(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                    final slideAnimation =
                        Tween<Offset>(
                          begin: const Offset(0.15, 0.0),
                          end: Offset.zero,
                        ).animate(
                          CurvedAnimation(
                            parent: animation,
                            curve: Curves.easeOutQuart,
                          ),
                        );

                    return SlideTransition(
                      position: slideAnimation,
                      child: FadeTransition(opacity: animation, child: child),
                    );
                  },
            ),
          );
        },
        child: _WorkoutCard(
          summary: _localizedSummary(summary, template, ref),
          strings: strings,
          isResuming: sessionState.activeWorkout != null,
          isLoading: sessionState.isLoading,
          onShareTap: () async {
            try {
              final template = await ref.read(activeTemplateProvider.future);
              if (!context.mounted) {
                return;
              }

              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ShareScreen(planTemplate: template),
                ),
              );
            } catch (error) {
              if (!context.mounted) {
                return;
              }
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(error.toString())));
            }
          },
        ),
      ),
        loading: () => const _LoadingCard(),
        error: (error, _) => _ErrorCard(message: error.toString()),
      ),
      loading: () => const _LoadingCard(),
      error: (error, _) => _ErrorCard(message: error.toString()),
    );
  }
}

TodayWorkoutSummary _localizedSummary(
  TodayWorkoutSummary summary,
  PlanTemplate template,
  WidgetRef ref,
) {
  final locale = ref.watch(appLocaleProvider);
  final workout = template.findWorkoutById(summary.workoutId);
  final exercise = template.findExerciseById(summary.primaryExerciseId);
  return summary.copyWith(
    workoutName: localizedWorkoutName(workout, locale),
    dayLabel: localizedWorkoutDayLabel(workout, locale),
    primaryExerciseName: localizedExerciseName(exercise, locale),
  );
}

class _WorkoutCard extends StatelessWidget {
  const _WorkoutCard({
    required this.summary,
    required this.strings,
    required this.isResuming,
    required this.isLoading,
    required this.onShareTap,
  });

  final TodayWorkoutSummary summary;
  final AppStrings strings;
  final bool isResuming;
  final bool isLoading;
  final Future<void> Function() onShareTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primary.withOpacity(0.24),
            theme.colorScheme.primaryContainer.withOpacity(0.4),
          ],
        ),
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.16),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(0.12),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  strings.todayWorkout,
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: onShareTap,
                  icon: const Icon(Icons.qr_code_2_rounded),
                  color: Colors.white.withValues(alpha: 0.82),
                  tooltip: strings.sharePlan,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              summary.primaryExerciseName,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w800,
                height: 1.05,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              summary.workoutName,
              style: theme.textTheme.titleMedium?.copyWith(
                color: Colors.white.withOpacity(0.82),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              strings.dayMinutes(summary.dayLabel, summary.estimatedDurationMinutes),
              style: theme.textTheme.bodyLarge?.copyWith(
                color: Colors.white.withOpacity(0.72),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              strings.exercisesLabel(summary.exerciseCount),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.white.withOpacity(0.58),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                _InfoPill(
                  icon: Icons.event_repeat_rounded,
                  label: strings.rotation,
                  value: summary.dayLabel,
                ),
                const SizedBox(width: 16),
                _InfoPill(
                  icon: Icons.fitness_center_rounded,
                  label: strings.leadLift,
                  value: summary.primaryExerciseName,
                ),
                const Spacer(),
                if (isLoading)
                  const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else
                  Row(
                    children: [
                      Text(
                        isResuming ? strings.resume : strings.start,
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: Colors.white.withOpacity(0.75),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: Colors.white.withOpacity(0.6),
                        size: 16,
                      ),
                    ],
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadingCard extends StatelessWidget {
  const _LoadingCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 220,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.05),
      ),
      child: const Center(child: CircularProgressIndicator()),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        color: theme.colorScheme.errorContainer.withOpacity(0.72),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Unable to load workout',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.onErrorContainer,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onErrorContainer.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: Colors.white.withOpacity(0.55),
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Icon(icon, size: 16, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 4),
            Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.white.withOpacity(0.92),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
