import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/active_session_provider.dart';
import '../../application/app_locale_provider.dart';
import '../../application/exercise_library_provider.dart';
import '../../domain/exercise_library.dart';
import '../../domain/models/training_state.dart';
import '../../domain/models/training_plan.dart';
import '../localization/app_strings.dart';
import '../localization/plan_text.dart';
import '../screens/active_session_screen.dart';
import '../screens/plan_library_screen.dart';
import '../screens/share_screen.dart';
import 'fittin_card.dart';
import 'fittin_primitives.dart';
import '../theme/fittin_theme.dart' show FittinTheme, FittinCardStyle;
import '../../application/fittin_theme_provider.dart';

class TodayWorkoutHeroCard extends ConsumerStatefulWidget {
  const TodayWorkoutHeroCard({super.key, this.compact = false});

  final bool compact;

  @override
  ConsumerState<TodayWorkoutHeroCard> createState() =>
      _TodayWorkoutHeroCardState();
}

class _TodayWorkoutHeroCardState extends ConsumerState<TodayWorkoutHeroCard> {
  bool _openingSession = false;

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(resolvedFittinThemeProvider);
    final sessionState = ref.watch(activeSessionProvider);
    final summaryAsync = ref.watch(todayWorkoutSummaryProvider);
    final templateAsync = ref.watch(activeTemplateProvider);
    final exerciseLibrary = ref.watch(exerciseLibraryProvider).valueOrNull;
    final strings = AppStrings.of(context, ref);

    return summaryAsync.when(
      data: (summary) => templateAsync.when(
        data: (template) => _FittinWorkoutCard(
          theme: theme,
          strings: strings,
          planName: localizedTemplateName(
            template,
            ref.watch(appLocaleProvider),
          ),
          summary: _localizedSummary(summary, template, ref, exerciseLibrary),
          isResuming: sessionState.activeWorkout != null,
          isLoading: sessionState.isLoading || _openingSession,
          compact: widget.compact,
          onTap: sessionState.isLoading || _openingSession
              ? null
              : _openSession,
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
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(strings.unableToSharePlan)),
              );
            }
          },
        ),
        loading: () => _LoadingCard(theme: theme, compact: widget.compact),
        error: (error, _) =>
            _buildFailureCard(error, theme: theme, strings: strings),
      ),
      loading: () => _LoadingCard(theme: theme, compact: widget.compact),
      error: (error, _) =>
          _buildFailureCard(error, theme: theme, strings: strings),
    );
  }

  Widget _buildFailureCard(
    Object error, {
    required FittinTheme theme,
    required AppStrings strings,
  }) {
    if (isMissingActivePlanError(error)) {
      return _NoActivePlanCard(
        theme: theme,
        strings: strings,
        onBrowsePlans: () => Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const PlanLibraryScreen())),
      );
    }
    return _ErrorCard(
      theme: theme,
      strings: strings,
      message: strings.loadError(error),
      onRetry: () {
        ref.invalidate(todayWorkoutSummaryProvider);
        ref.invalidate(activeTemplateProvider);
      },
    );
  }

  Future<void> _openSession() async {
    if (_openingSession) {
      return;
    }
    setState(() => _openingSession = true);
    try {
      await ref.read(activeSessionProvider.notifier).startOrResumeSession();
      if (!mounted) return;
      final latestState = ref.read(activeSessionProvider);
      if (latestState.errorMessage != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(latestState.errorMessage!)));
        return;
      }
      await Navigator.of(context).push<void>(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 450),
          pageBuilder: (context, animation, secondaryAnimation) =>
              const ActiveSessionScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
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
    } finally {
      if (mounted) {
        setState(() => _openingSession = false);
      }
    }
  }
}

TodayWorkoutSummary _localizedSummary(
  TodayWorkoutSummary summary,
  PlanTemplate template,
  WidgetRef ref,
  ExerciseLibrary? library,
) {
  final locale = ref.watch(appLocaleProvider);
  final workout = template.findWorkoutById(summary.workoutId);
  final exercise = template.findExerciseById(summary.primaryExerciseId);
  return summary.copyWith(
    workoutName: localizedWorkoutName(workout, locale),
    dayLabel: localizedWorkoutDayLabel(workout, locale),
    primaryExerciseName: localizedExerciseName(
      exercise,
      locale,
      library: library,
    ),
  );
}

/// Redesigned workout card in Fittin style
class _FittinWorkoutCard extends StatelessWidget {
  const _FittinWorkoutCard({
    required this.theme,
    required this.strings,
    required this.planName,
    required this.summary,
    required this.isResuming,
    required this.isLoading,
    required this.compact,
    required this.onTap,
    required this.onShareTap,
  });

  final FittinTheme theme;
  final AppStrings strings;
  final String planName;
  final TodayWorkoutSummary summary;
  final bool isResuming;
  final bool isLoading;
  final bool compact;
  final VoidCallback? onTap;
  final Future<void> Function() onShareTap;

  @override
  Widget build(BuildContext context) {
    final progressLabel = strings.exercisesCount(summary.exerciseCount);
    final weekDayLabel = strings.compactWeekDayLabel(
      summary.currentWeekNumber,
      summary.currentDayNumber,
    );
    final totalSessions = summary.cycleWeekCount * summary.workoutsPerWeek;
    final completedPosition =
        (summary.currentWeekNumber - 1) * summary.workoutsPerWeek +
        summary.currentDayNumber;
    final progress = totalSessions <= 0
        ? 0.0
        : (completedPosition / totalSessions).clamp(0.0, 1.0).toDouble();

    return Stack(
      clipBehavior: Clip.none,
      children: [
        FittinCard(
          theme: theme,
          style: FittinCardStyle.glass,
          padding: compact ? 12 : theme.pad,
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Keep the share action outside the card's tap semantics.
              SizedBox(
                height: 16,
                child: Row(
                  children: [
                    Expanded(child: FittinEyebrow(theme, strings.nextSession)),
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
                            strings.inProgress,
                            style: theme.uiStyle(11, theme.fgMuted),
                          ),
                        ],
                      ),
                    const SizedBox(width: 36),
                  ],
                ),
              ),
              SizedBox(height: compact ? 10 : 20),

              // Session title
              FittinSectionTitle(
                theme,
                summary.workoutName,
                fontSize: compact ? 24 : 30,
              ),
              SizedBox(height: compact ? 4 : 6),
              Text(
                '$planName · $weekDayLabel',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.uiStyle(compact ? 11 : 13, theme.fgDim),
              ),
              SizedBox(height: compact ? 10 : 20),

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
                        widthFactor: progress,
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
                      style: theme
                          .uiStyle(12, theme.fgDim)
                          .copyWith(
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: compact ? 10 : 20),

              // Up next + Resume
              LayoutBuilder(
                builder: (context, constraints) {
                  final details = Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FittinEyebrow(theme, strings.upNext),
                      const SizedBox(height: 4),
                      Text(
                        summary.primaryExerciseName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.uiStyle(
                          compact ? 14 : 15,
                          theme.fg,
                          FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        strings.dayMinutes(
                          weekDayLabel,
                          summary.estimatedDurationMinutes,
                        ),
                        style: theme.uiStyle(compact ? 11 : 13, theme.fgDim),
                      ),
                    ],
                  );
                  final button = _ResumeButton(
                    theme: theme,
                    isLoading: isLoading,
                    isResuming: isResuming,
                    strings: strings,
                  );

                  if (constraints.maxWidth < 300) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        details,
                        const SizedBox(height: 16),
                        Align(alignment: Alignment.centerLeft, child: button),
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
        ),
        Positioned(
          top: compact ? 0 : 4,
          right: compact ? 0 : 4,
          child: IconButton(
            key: const ValueKey('share-active-plan'),
            tooltip: strings.sharePlan,
            constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
            visualDensity: VisualDensity.compact,
            onPressed: onShareTap,
            icon: Icon(Icons.ios_share_rounded, size: 18, color: theme.fgDim),
          ),
        ),
      ],
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
        child: CircularProgressIndicator(strokeWidth: 2, color: theme.accent),
      );
    }
    final label = isResuming ? strings.resume : strings.start;
    return Container(
      constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: theme.accent,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.play_arrow_rounded, size: 14, color: theme.accentInk),
          const SizedBox(width: 8),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme
                .uiStyle(12, theme.accentInk)
                .copyWith(fontWeight: FontWeight.w500, letterSpacing: 0.1),
          ),
        ],
      ),
    );
  }
}

class _LoadingCard extends StatelessWidget {
  const _LoadingCard({required this.theme, this.compact = false});

  final FittinTheme theme;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return FittinCard(
      theme: theme,
      style: FittinCardStyle.glass,
      child: SizedBox(
        height: compact ? 150 : 220,
        child: Center(
          child: CircularProgressIndicator(strokeWidth: 2, color: theme.fgDim),
        ),
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({
    required this.theme,
    required this.strings,
    required this.message,
    required this.onRetry,
  });

  final FittinTheme theme;
  final AppStrings strings;
  final String message;
  final VoidCallback onRetry;

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
            strings.unableToLoadWorkout,
            style: theme
                .uiStyle(16, theme.fg)
                .copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(message, style: theme.uiStyle(14, theme.fgDim)),
          const SizedBox(height: 18),
          FittinBtn(
            theme,
            strings.retry,
            key: const ValueKey('retry-today-workout'),
            size: 'sm',
            icon: Icons.refresh_rounded,
            onPressed: onRetry,
          ),
        ],
      ),
    );
  }
}

class _NoActivePlanCard extends StatelessWidget {
  const _NoActivePlanCard({
    required this.theme,
    required this.strings,
    required this.onBrowsePlans,
  });

  final FittinTheme theme;
  final AppStrings strings;
  final VoidCallback onBrowsePlans;

  @override
  Widget build(BuildContext context) {
    return FittinCard(
      theme: theme,
      style: FittinCardStyle.glass,
      padding: 24,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.layers_rounded, color: theme.accent, size: 28),
          const SizedBox(height: 16),
          Text(
            strings.chooseTrainingPlan,
            style: theme.uiStyle(18, theme.fg, FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            strings.chooseTrainingPlanDetail,
            style: theme.uiStyle(14, theme.fgDim).copyWith(height: 1.45),
          ),
          const SizedBox(height: 18),
          FittinBtn(
            theme,
            strings.browsePlans,
            key: const ValueKey('choose-training-plan'),
            size: 'sm',
            icon: Icons.arrow_forward_rounded,
            onPressed: onBrowsePlans,
          ),
        ],
      ),
    );
  }
}
