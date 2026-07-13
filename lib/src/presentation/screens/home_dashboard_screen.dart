import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:fittin_v2/src/application/home_dashboard_provider.dart';
import 'package:fittin_v2/src/application/pr_dashboard_provider.dart';
import 'package:fittin_v2/src/application/progress_analytics_provider.dart';
import 'package:fittin_v2/src/application/fittin_theme_provider.dart';
import 'package:fittin_v2/src/presentation/theme/fittin_theme.dart';
import 'package:fittin_v2/src/presentation/localization/app_strings.dart';
import 'package:fittin_v2/src/presentation/screens/advanced_analytics_screen.dart';
import 'package:fittin_v2/src/presentation/screens/exercise_deep_dive_screen.dart';
import 'package:fittin_v2/src/presentation/screens/plan_library_screen.dart';
import 'package:fittin_v2/src/presentation/screens/pr_dashboard_screen.dart';
import 'package:fittin_v2/src/presentation/widgets/dashboard_primitives.dart';
import 'package:fittin_v2/src/presentation/widgets/today_workout_hero_card.dart';
import 'package:fittin_v2/src/presentation/widgets/fittin_card.dart';
import 'package:fittin_v2/src/presentation/widgets/fittin_primitives.dart';
import 'package:fittin_v2/src/presentation/widgets/charts/step_chart.dart';

class HomeDashboardScreen extends ConsumerStatefulWidget {
  const HomeDashboardScreen({super.key});

  @override
  ConsumerState<HomeDashboardScreen> createState() =>
      _HomeDashboardScreenState();
}

class _HomeDashboardScreenState extends ConsumerState<HomeDashboardScreen> {
  final PageController _pageController = PageController(viewportFraction: 1);

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context, ref);
    final homeDataAsync = ref.watch(homeDashboardDataProvider);
    final theme = ref.watch(resolvedFittinThemeProvider);

    return Scaffold(
      backgroundColor: theme.bg,
      body: SafeArea(
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 430),
            child: Padding(
              padding: EdgeInsets.fromLTRB(theme.pad, 16, theme.pad, 20),
              child: Column(
                children: [
                  homeDataAsync.when(
                    data: (data) => _FittinTopMetaRow(
                      theme: theme,
                      data: data,
                      onNotificationTap: () =>
                          _openMilestonesPanel(context, data),
                    ),
                    loading: () => _FittinTopMetaRowSkeleton(theme: theme),
                    error: (_, __) => _FittinTopMetaRowSkeleton(theme: theme),
                  ),
                  const SizedBox(height: 6),
                  const TodayWorkoutHeroCard(compact: true),
                  const SizedBox(height: 6),
                  homeDataAsync.when(
                    data: (data) => _AtAGlanceSection(
                      data: data,
                      strings: strings,
                      theme: theme,
                      pageController: _pageController,
                    ),
                    loading: () => const _HomeOverviewSkeleton(),
                    error: (error, _) => _isMissingActivePlanError(error)
                        ? const SizedBox.shrink()
                        : _HomeOverviewError(message: error.toString()),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _openMilestonesPanel(
    BuildContext context,
    HomeDashboardData data,
  ) async {
    final latestMilestoneAt = data.milestones.isEmpty
        ? null
        : data.milestones.first.date;
    await ref
        .read(homeDashboardControllerProvider)
        .markMilestonesSeen(latestMilestoneAt);
    if (!context.mounted) {
      return;
    }

    await showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'milestones',
      barrierColor: Colors.black.withValues(alpha: 0.5),
      transitionDuration: const Duration(milliseconds: 220),
      pageBuilder: (dialogContext, _, __) {
        final strings = AppStrings.of(dialogContext, ref);
        return SafeArea(
          child: Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 72, 24, 0),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 340),
                child: Material(
                  color: Colors.transparent,
                  child: DashboardSurfaceCard(
                    radius: 28,
                    padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          strings.trainingMilestones,
                          style: Theme.of(dialogContext).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 14),
                        if (data.milestones.isEmpty)
                          Text(strings.noMilestoneNotifications)
                        else
                          for (final milestone in data.milestones)
                            _NotificationMilestoneTile(
                              strings: strings,
                              milestone: milestone,
                              onTap: () {
                                Navigator.of(dialogContext).pop();
                                final summary = milestone.summary;
                                if (summary != null) {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => ExerciseDeepDiveScreen(
                                        summary: summary,
                                      ),
                                    ),
                                  );
                                  return;
                                }
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => const PRDashboardScreen(),
                                  ),
                                );
                              },
                            ),
                        if (data.milestones.isNotEmpty)
                          const SizedBox(height: 10),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            key: const ValueKey(
                              'open-pr-dashboard-from-notifications',
                            ),
                            onPressed: () {
                              Navigator.of(dialogContext).pop();
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const PRDashboardScreen(),
                                ),
                              );
                            },
                            child: Text(strings.viewPrDashboard),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final offsetTween = Tween<Offset>(
          begin: const Offset(0, -0.08),
          end: Offset.zero,
        );
        return SlideTransition(
          position: offsetTween.animate(
            CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
          ),
          child: FadeTransition(opacity: animation, child: child),
        );
      },
    );
  }
}

bool _isMissingActivePlanError(Object error) {
  return error.toString().contains('No active training plan instance');
}

class _FittinTopMetaRow extends StatelessWidget {
  const _FittinTopMetaRow({
    required this.theme,
    required this.data,
    required this.onNotificationTap,
  });

  final FittinTheme theme;
  final HomeDashboardData data;
  final VoidCallback onNotificationTap;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final dateStr = DateFormat('EEEE, MMM d', 'en_US').format(now);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        FittinEyebrow(theme, dateStr),
        FittinEyebrow(
          theme,
          'Week ${data.todayWorkout.currentWeekNumber} · Day ${data.todayWorkout.currentDayNumber}',
        ),
      ],
    );
  }
}

class _FittinTopMetaRowSkeleton extends StatelessWidget {
  const _FittinTopMetaRowSkeleton({required this.theme});

  final FittinTheme theme;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          width: 80,
          height: 12,
          decoration: BoxDecoration(
            color: theme.fgFaint,
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        Container(
          width: 100,
          height: 12,
          decoration: BoxDecoration(
            color: theme.fgFaint,
            borderRadius: BorderRadius.circular(6),
          ),
        ),
      ],
    );
  }
}

class _AtAGlanceSection extends StatelessWidget {
  const _AtAGlanceSection({
    required this.data,
    required this.strings,
    required this.theme,
    required this.pageController,
  });

  final HomeDashboardData data;
  final AppStrings strings;
  final FittinTheme theme;
  final PageController pageController;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _CycleProgressCard(
                data: data,
                strings: strings,
                theme: theme,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _HighlightLiftCard(
                data: data,
                strings: strings,
                theme: theme,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        _ActivityCard(
          data: data,
          strings: strings,
          theme: theme,
          pageController: pageController,
        ),
        const SizedBox(height: 6),
        _QuickActionsCard(
          theme: theme,
          strings: strings,
          onOpenPlans: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const PlanLibraryScreen()),
            );
          },
          onOpenPr: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const PRDashboardScreen()),
            );
          },
        ),
      ],
    );
  }
}

class _CycleProgressCard extends StatelessWidget {
  const _CycleProgressCard({
    required this.data,
    required this.strings,
    required this.theme,
  });

  final HomeDashboardData data;
  final AppStrings strings;
  final FittinTheme theme;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      key: const ValueKey('today-cycle-card'),
      height: 144,
      child: FittinCard(
        theme: theme,
        style: FittinCardStyle.glass,
        padding: 14,
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const AdvancedAnalyticsScreen()),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FittinEyebrow(theme, 'Cycle'),
            const SizedBox(height: 7),
            FittinBigNum(
              theme,
              '${(data.cycleProgress * 100).round()}',
              size: 31,
              unit: '%',
            ),
            const SizedBox(height: 7),
            Container(
              height: 3,
              decoration: BoxDecoration(
                color: theme.fgFaint,
                borderRadius: BorderRadius.circular(999),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: data.cycleProgress.clamp(0.0, 1.0),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: theme.accent,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 7),
            Text(
              strings.weekDayProgressLabel(
                data.todayWorkout.currentWeekNumber,
                data.todayWorkout.cycleWeekCount,
                data.todayWorkout.currentDayNumber,
                data.todayWorkout.workoutsPerWeek,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.uiStyle(10, theme.fgMuted).copyWith(height: 1.25),
            ),
          ],
        ),
      ),
    );
  }
}

class _HighlightLiftCard extends StatelessWidget {
  const _HighlightLiftCard({
    required this.data,
    required this.strings,
    required this.theme,
  });

  final HomeDashboardData data;
  final AppStrings strings;
  final FittinTheme theme;

  @override
  Widget build(BuildContext context) {
    final summary = _resolveHighlightSummary(data);
    final points =
        summary?.estimatedHistory.map((point) => point.value).toList() ?? [];

    return SizedBox(
      key: const ValueKey('today-e1rm-card'),
      height: 144,
      child: FittinCard(
        theme: theme,
        style: FittinCardStyle.glass,
        padding: 14,
        onTap: () {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const PRDashboardScreen()));
        },
        child: summary == null
            ? Center(
                child: Text(
                  strings.noStrengthTrendYet,
                  textAlign: TextAlign.center,
                  style: theme.uiStyle(12, theme.fgDim),
                ),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FittinEyebrow(theme, 'Squat e1RM'),
                  const SizedBox(height: 4),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: FittinBigNum(
                          theme,
                          (summary.currentEstimatedOneRepMax ?? 0)
                              .toStringAsFixed(1),
                          size: 26,
                          unit: strings.isChinese ? '公斤' : 'kg',
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          strings.sessionsLogged(
                            summary.estimatedHistory.length,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.uiStyle(10, theme.fgMuted),
                        ),
                      ),
                      if (points.length > 1)
                        Sparkline(theme, points, width: 54, height: 16),
                    ],
                  ),
                ],
              ),
      ),
    );
  }

  ExerciseProgressSummary? _resolveHighlightSummary(HomeDashboardData data) {
    for (final summary in data.sparklineLifts) {
      if (summary.exerciseName.toLowerCase().contains('squat')) {
        return summary;
      }
    }
    return data.sparklineLifts.isEmpty ? null : data.sparklineLifts.first;
  }
}

class _ActivityCard extends StatelessWidget {
  const _ActivityCard({
    required this.data,
    required this.strings,
    required this.theme,
    required this.pageController,
  });

  final HomeDashboardData data;
  final AppStrings strings;
  final FittinTheme theme;
  final PageController pageController;

  @override
  Widget build(BuildContext context) {
    return FittinCard(
      theme: theme,
      style: FittinCardStyle.glass,
      padding: 14,
      onTap: () {
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const PRDashboardScreen()));
      },
      child: SizedBox(
        key: const ValueKey('today-activity-card'),
        height: 74,
        child: data.sparklineLifts.isEmpty
            ? Center(
                child: Text(
                  strings.noStrengthTrendYet,
                  style: theme.uiStyle(12, theme.fgDim),
                ),
              )
            : PageView.builder(
                controller: pageController,
                itemCount: data.sparklineLifts.length,
                itemBuilder: (context, index) {
                  final summary = data.sparklineLifts[index];
                  final values = summary.estimatedHistory
                      .map((point) => point.value)
                      .toList();
                  return Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            FittinEyebrow(theme, strings.activity),
                            const SizedBox(height: 3),
                            Text(
                              summary.exerciseName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.uiStyle(
                                13,
                                theme.fg,
                                FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${summary.currentEstimatedOneRepMax?.toStringAsFixed(1) ?? '—'} ${strings.isChinese ? '公斤' : 'kg'} · ${strings.sessionsLogged(summary.estimatedHistory.length)}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.uiStyle(10, theme.fgMuted),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 14),
                      StepChart(
                        theme,
                        values,
                        width: 128,
                        height: 58,
                        showDots: true,
                        showGrid: false,
                      ),
                    ],
                  );
                },
              ),
      ),
    );
  }
}

class _QuickActionsCard extends StatelessWidget {
  const _QuickActionsCard({
    required this.theme,
    required this.strings,
    required this.onOpenPlans,
    required this.onOpenPr,
  });

  final FittinTheme theme;
  final AppStrings strings;
  final VoidCallback onOpenPlans;
  final VoidCallback onOpenPr;

  @override
  Widget build(BuildContext context) {
    final actions = [
      (
        label: strings.isChinese ? 'Switch plan' : 'Switch plan',
        subtitle: null,
        icon: Icons.swap_horiz_rounded,
        onTap: onOpenPlans,
      ),
      (
        label: strings.isChinese ? 'See all PRs' : 'See all PRs',
        subtitle: null,
        icon: Icons.arrow_forward_rounded,
        onTap: onOpenPr,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GridView.builder(
          shrinkWrap: true,
          primary: false,
          padding: EdgeInsets.zero,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: actions.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 3.1,
          ),
          itemBuilder: (context, index) {
            final action = actions[index];
            return FittinCard(
              key: ValueKey('today-quick-action-$index'),
              theme: theme,
              style: FittinCardStyle.glass,
              padding: 12,
              onTap: action.onTap,
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        action.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.uiStyle(13, theme.fg, FontWeight.w500),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(action.icon, color: theme.fgDim, size: 16),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _NotificationMilestoneTile extends StatelessWidget {
  const _NotificationMilestoneTile({
    required this.strings,
    required this.milestone,
    required this.onTap,
  });

  final AppStrings strings;
  final PRMilestone milestone;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.06),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.workspace_premium, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    milestone.exerciseName,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    strings.milestoneValueLabel(
                      milestone.type == PRMilestoneType.actual
                          ? strings.actualType
                          : strings.estimatedType,
                      milestone.value,
                    ),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Text(
              strings.shortMonthDay(milestone.date),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.white.withValues(alpha: 0.45),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeOverviewSkeleton extends StatelessWidget {
  const _HomeOverviewSkeleton();

  @override
  Widget build(BuildContext context) {
    Widget card({required double height}) => DashboardSurfaceCard(
      radius: 24,
      padding: EdgeInsets.zero,
      child: SizedBox(height: height),
    );

    return Column(
      children: [
        Row(
          children: [
            Expanded(child: card(height: 142)),
            const SizedBox(width: 10),
            Expanded(child: card(height: 142)),
          ],
        ),
        const SizedBox(height: 10),
        card(height: 104),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(child: card(height: 52)),
            const SizedBox(width: 10),
            Expanded(child: card(height: 52)),
          ],
        ),
      ],
    );
  }
}

class _HomeOverviewError extends StatelessWidget {
  const _HomeOverviewError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return DashboardSurfaceCard(radius: 24, child: Text(message));
  }
}

class NestedProgressRings extends StatelessWidget {
  const NestedProgressRings({
    super.key,
    required this.outerProgress,
    required this.innerProgress,
    required this.size,
    required this.centerLabel,
  });

  final double outerProgress;
  final double innerProgress;
  final double size;
  final String centerLabel;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _NestedProgressRingsPainter(
          outerProgress: outerProgress,
          innerProgress: innerProgress,
          primaryColor: Theme.of(context).colorScheme.primary,
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Text(
              centerLabel,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: Colors.white.withValues(alpha: 0.88),
                height: 1.35,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NestedProgressRingsPainter extends CustomPainter {
  _NestedProgressRingsPainter({
    required this.outerProgress,
    required this.innerProgress,
    required this.primaryColor,
  });

  final double outerProgress;
  final double innerProgress;
  final Color primaryColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    _paintRing(
      canvas,
      center: center,
      radius: (size.width / 2) - 8,
      progress: outerProgress,
      strokeWidth: 12,
      color: primaryColor.withValues(alpha: 0.9),
    );
    _paintRing(
      canvas,
      center: center,
      radius: (size.width / 2) - 28,
      progress: innerProgress,
      strokeWidth: 10,
      color: Colors.white,
    );
  }

  void _paintRing(
    Canvas canvas, {
    required Offset center,
    required double radius,
    required double progress,
    required double strokeWidth,
    required Color color,
  }) {
    final trackPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, trackPaint);

    if (progress <= 0) {
      return;
    }

    final glowPaint = Paint()
      ..color = color.withValues(alpha: 0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth * 1.8
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    final sweep = 2 * math.pi * progress.clamp(0.0, 1.0);
    final rect = Rect.fromCircle(center: center, radius: radius);
    canvas.drawArc(rect, -math.pi / 2, sweep, false, glowPaint);

    final activePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, -math.pi / 2, sweep, false, activePaint);
  }

  @override
  bool shouldRepaint(covariant _NestedProgressRingsPainter oldDelegate) {
    return oldDelegate.outerProgress != outerProgress ||
        oldDelegate.innerProgress != innerProgress ||
        oldDelegate.primaryColor != primaryColor;
  }
}
