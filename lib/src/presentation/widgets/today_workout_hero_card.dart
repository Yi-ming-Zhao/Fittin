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
import 'fittin_card.dart';
import 'fittin_primitives.dart';
import '../theme/fittin_theme.dart' show FittinTheme, FittinCardStyle;
import '../../application/fittin_theme_provider.dart';

class TodayWorkoutHeroCard extends ConsumerWidget {
  const TodayWorkoutHeroCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(resolvedFittinThemeProvider);
    final sessionState = ref.watch(activeSessionProvider);
    final summaryAsync = ref.watch(todayWorkoutSummaryProvider);
    final templateAsync = ref.watch(activeTemplateProvider);
    final strings = AppStrings.of(context, ref);

    return summaryAsync.when(
      data: (summary) => templateAsync.when(
        data: (template) => _FittinWorkoutCard(
          theme: theme,
          strings: strings,
          summary: _localizedSummary(summary, template, ref),
          isResuming: sessionState.activeWorkout != null,
          isLoading: sessionState.isLoading,
          onTap: () async {
            await ref.read(activeSessionProvider.notifier).startOrResumeSession();
            if (!context.mounted) return;
            final latestState = ref.read(activeSessionProvider);
            if (latestState.errorMessage != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(latestState.errorMessage!)),
              );
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
          onShareTap: () async {
            try {
              final template = await ref.read(activeTemplateProvider.future);
              if (!context.mounted) return;
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ShareScreen(planTemplate: template),
                ),
              );
            } catch (error) {
              if (!context.mounted) return;
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text(error.toString())));
            }
          },
        ),
        loading: () => _LoadingCard(theme: theme),
        error: (error, _) => _ErrorCard(theme: theme, message: error.toString()),
      ),
      loading: () => _LoadingCard(theme: theme),
      error: (error, _) => _ErrorCard(theme: theme, message: error.toString()),
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

/// Redesigned workout card in Fittin style
class _FittinWorkoutCard extends StatelessWidget {
  const _FittinWorkoutCard({
    required this.theme,
    required this.strings,
    required this.summary,
    required this.isResuming,
    required this.isLoading,
    required this.onTap,
    required this.onShareTap,
  });

  final FittinTheme theme;
  final AppStrings strings;
  final TodayWorkoutSummary summary;
  final bool isResuming;
  final bool isLoading;
  final VoidCallback onTap;
  final Future<void> Function() onShareTap;

  @override
  Widget build(BuildContext context) {
    final progressLabel = strings.exercisesCount(summary.exerciseCount);
    final statusLabel = strings.isChinese ? 'In progress' : 'In progress';
    final upNextLabel = strings.isChinese ? 'Up next' : 'Up next';
    final weekDayLabel =
        'W${summary.currentWeekNumber} D${summary.currentDayNumber}';

    return FittinCard(
      theme: theme,
      style: FittinCardStyle.glass,
      padding: theme.pad,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row: eyebrow + in-progress dot
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              FittinEyebrow(theme, 'Next session'),
              if (isResuming)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: theme.accent,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      statusLabel,
                      style: theme.uiStyle(11, theme.fgMuted),
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 20),

          // Session title
          FittinSectionTitle(
            theme,
            summary.workoutName,
            fontSize: 30,
          ),
          const SizedBox(height: 6),
          Text(
            'TSA Intermediate Approach 2.0 · $weekDayLabel',
            style: theme.uiStyle(13, theme.fgDim),
          ),
          const SizedBox(height: 20),

          // Progress strip — 2px, not glowing
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 2,
                  decoration: BoxDecoration(
                    color: theme.fgFaint,
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: 0.6,
                    child: Container(
                      decoration: BoxDecoration(
                        color: theme.accent,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Flexible(
                child: Text(
                  progressLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.uiStyle(12, theme.fgDim).copyWith(
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Up next + Resume
          LayoutBuilder(
            builder: (context, constraints) {
              final details = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FittinEyebrow(
                    theme,
                    upNextLabel,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    summary.primaryExerciseName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.uiStyle(15, theme.fg, FontWeight.w500),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Week ${summary.currentWeekNumber} · 3×6+ @ 0.6',
                    style: theme.uiStyle(13, theme.fgDim),
                  ),
                ],
              );
              final button = _ResumeButton(
                theme: theme,
                isLoading: isLoading,
                isResuming: isResuming,
                strings: strings,
              );

              if (constraints.maxWidth < 420) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    details,
                    const SizedBox(height: 16),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: button,
                    ),
                  ],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: details),
                  const SizedBox(width: 16),
                  button,
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ResumeButton extends StatelessWidget {
  const _ResumeButton({
    required this.theme,
    required this.isLoading,
    required this.isResuming,
    required this.strings,
  });

  final FittinTheme theme;
  final bool isLoading;
  final bool isResuming;
  final AppStrings strings;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: theme.accent,
        ),
      );
    }
    return FittinBtn(
      theme,
      isResuming ? strings.resume : strings.start,
      size: 'sm',
      icon: Icons.play_arrow_rounded,
      onPressed: null, // tap handled by parent card
    );
  }
}

class _LoadingCard extends StatelessWidget {
  const _LoadingCard({required this.theme});

  final FittinTheme theme;

  @override
  Widget build(BuildContext context) {
    return FittinCard(
      theme: theme,
      style: FittinCardStyle.glass,
      child: SizedBox(
        height: 220,
        child: Center(
          child: CircularProgressIndicator(strokeWidth: 2, color: theme.fgDim),
        ),
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({required this.theme, required this.message});

  final FittinTheme theme;
  final String message;

  @override
  Widget build(BuildContext context) {
    return FittinCard(
      theme: theme,
      style: FittinCardStyle.flat,
      padding: 24,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Unable to load workout',
            style: theme.uiStyle(16, theme.fg).copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(message, style: theme.uiStyle(14, theme.fgDim)),
        ],
      ),
    );
  }
}
