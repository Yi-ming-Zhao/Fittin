import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:fittin_v2/src/application/active_session_provider.dart';
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

class HomeDashboardScreen extends ConsumerStatefulWidget {
  const HomeDashboardScreen({super.key});

  @override
  ConsumerState<HomeDashboardScreen> createState() =>
      _HomeDashboardScreenState();
}

class _HomeDashboardScreenState extends ConsumerState<HomeDashboardScreen> {
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
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isCompact = constraints.maxHeight < 720;
                final roomyProgress = ((constraints.maxHeight - 880) / 46)
                    .clamp(0.0, 1.0);
                final sectionGap = isCompact
                    ? 6.0
                    : 16.0 + (24.0 * roomyProgress);
                final content = Column(
                  children: [
                    homeDataAsync.when(
                      data: (data) => _FittinTopMetaRow(
                        theme: theme,
                        strings: strings,
                        data: data,
                        onNotificationTap: () =>
                            _openMilestonesPanel(context, data),
                      ),
                      loading: () => _FittinTopMetaRowSkeleton(theme: theme),
                      error: (_, __) => _FittinTopMetaRowSkeleton(theme: theme),
                    ),
                    SizedBox(height: sectionGap),
                    TodayWorkoutHeroCard(compact: isCompact),
                    SizedBox(height: sectionGap),
                    homeDataAsync.when(
                      data: (data) => _AtAGlanceSection(
                        data: data,
                        strings: strings,
                        theme: theme,
                        compact: isCompact,
                      ),
                      loading: () => _HomeOverviewSkeleton(compact: isCompact),
                      error: (error, _) => isMissingActivePlanError(error)
                          ? const SizedBox.shrink()
                          : _HomeOverviewError(
                              message: strings.loadError(error),
                            ),
                    ),
                  ],
                );
                final padding = EdgeInsets.fromLTRB(
                  theme.pad,
                  isCompact ? 16 : 16 + (8 * roomyProgress),
                  theme.pad,
                  20,
                );
                if (!isCompact) {
                  return Padding(padding: padding, child: content);
                }
                return SingleChildScrollView(padding: padding, child: content);
              },
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
      barrierLabel: AppStrings.of(context, ref).trainingMilestones,
      barrierColor: ref.read(resolvedFittinThemeProvider).scrim,
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

class _FittinTopMetaRow extends StatelessWidget {
  const _FittinTopMetaRow({
    required this.theme,
    required this.strings,
    required this.data,
    required this.onNotificationTap,
  });

  final FittinTheme theme;
  final AppStrings strings;
  final HomeDashboardData data;
  final VoidCallback onNotificationTap;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final dateStr = strings.isChinese
        ? '${now.month}月${now.day}日 ${strings.weekdayName(now)}'
        : DateFormat('EEEE, MMM d', 'en_US').format(now);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Align(
            alignment: Alignment.centerLeft,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: FittinEyebrow(theme, dateStr),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Align(
            alignment: Alignment.centerRight,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: FittinEyebrow(
                theme,
                strings.compactWeekDayLabel(
                  data.todayWorkout.currentWeekNumber,
                  data.todayWorkout.currentDayNumber,
                ),
              ),
            ),
          ),
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
    required this.compact,
  });

  final HomeDashboardData data;
  final AppStrings strings;
  final FittinTheme theme;
  final bool compact;

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
                compact: compact,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _HighlightLiftCard(
                data: data,
                strings: strings,
                theme: theme,
                compact: compact,
              ),
            ),
          ],
        ),
        SizedBox(height: compact ? 6 : 16),
        _ActivityCard(
          data: data,
          strings: strings,
          theme: theme,
          compact: compact,
        ),
        SizedBox(height: compact ? 6 : 16),
        _QuickActionsCard(
          theme: theme,
          strings: strings,
          compact: compact,
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
    required this.compact,
  });

  final HomeDashboardData data;
  final AppStrings strings;
  final FittinTheme theme;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      key: const ValueKey('today-cycle-card'),
      height: compact ? 144 : 168,
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
            FittinEyebrow(theme, strings.cycle),
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

class _HighlightLiftCard extends StatefulWidget {
  const _HighlightLiftCard({
    required this.data,
    required this.strings,
    required this.theme,
    required this.compact,
  });

  final HomeDashboardData data;
  final AppStrings strings;
  final FittinTheme theme;
  final bool compact;

  @override
  State<_HighlightLiftCard> createState() => _HighlightLiftCardState();
}

class _HighlightLiftCardState extends State<_HighlightLiftCard> {
  late final PageController _controller;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _controller = PageController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lifts = [
      (id: 'squat', label: widget.strings.squatShort),
      (id: 'bench_press', label: widget.strings.benchShort),
      (id: 'deadlift', label: widget.strings.deadliftShort),
    ];

    return SizedBox(
      key: const ValueKey('today-e1rm-card'),
      height: widget.compact ? 144 : 168,
      child: FittinCard(
        theme: widget.theme,
        style: FittinCardStyle.glass,
        padding: 14,
        onTap: () {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const PRDashboardScreen()));
        },
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                key: const ValueKey('home-e1rm-pager'),
                controller: _controller,
                itemCount: lifts.length,
                onPageChanged: (index) {
                  setState(() => _selectedIndex = index);
                },
                itemBuilder: (context, index) {
                  final lift = lifts[index];
                  final summary = _summaryForId(widget.data, lift.id);
                  return _HomeE1rmPage(
                    key: ValueKey('home-e1rm-page-${lift.id}'),
                    theme: widget.theme,
                    strings: widget.strings,
                    canonicalId: lift.id,
                    liftLabel: lift.label,
                    summary: summary,
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var index = 0; index < lifts.length; index++)
                  Semantics(
                    button: true,
                    label: widget.strings.showLiftEstimatedOneRepMax(
                      lifts[index].label,
                    ),
                    child: InkResponse(
                      key: ValueKey('home-e1rm-indicator-${lifts[index].id}'),
                      radius: 14,
                      onTap: () {
                        _controller.animateToPage(
                          index,
                          duration: const Duration(milliseconds: 220),
                          curve: Curves.easeOutCubic,
                        );
                      },
                      child: SizedBox(
                        width: 22,
                        height: 16,
                        child: Center(
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            width: index == _selectedIndex ? 14 : 5,
                            height: 5,
                            decoration: BoxDecoration(
                              color: index == _selectedIndex
                                  ? widget.theme.accent
                                  : widget.theme.fgFaint,
                              borderRadius: BorderRadius.circular(99),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  ExerciseProgressSummary? _summaryForId(
    HomeDashboardData data,
    String exerciseId,
  ) {
    for (final summary in data.sparklineLifts) {
      if (summary.exerciseId == exerciseId) {
        return summary;
      }
    }
    return null;
  }
}

class _HomeE1rmPage extends StatelessWidget {
  const _HomeE1rmPage({
    super.key,
    required this.theme,
    required this.strings,
    required this.canonicalId,
    required this.liftLabel,
    required this.summary,
  });

  final FittinTheme theme;
  final AppStrings strings;
  final String canonicalId;
  final String liftLabel;
  final ExerciseProgressSummary? summary;

  @override
  Widget build(BuildContext context) {
    final value = summary?.currentEstimatedOneRepMax;
    final change = summary?.recentChange;
    final date = summary?.lastCompletedAt;
    final historyCount = summary?.estimatedHistory.length ?? 0;
    final detail = value == null
        ? strings.noStrengthTrendYet
        : '${strings.sessionsLogged(historyCount)} · ${date == null ? '—' : strings.shortMonthDay(date)}';

    return Semantics(
      label: '$liftLabel ${strings.estimated1rmShort}',
      value: value == null
          ? strings.noStrengthTrendYet
          : '${strings.kilograms(value)}. $detail',
      child: Column(
        key: ValueKey('home-e1rm-content-$canonicalId'),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: double.infinity,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: FittinEyebrow(
                theme,
                strings.liftEstimatedOneRepMax(liftLabel),
              ),
            ),
          ),
          const SizedBox(height: 4),
          if (value == null)
            Expanded(
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  strings.noStrengthTrendYet,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: theme.uiStyle(11, theme.fgDim).copyWith(height: 1.25),
                ),
              ),
            )
          else ...[
            FittinBigNum(
              theme,
              value.toStringAsFixed(1),
              key: ValueKey('home-e1rm-value-$canonicalId'),
              size: 25,
              unit: strings.kilogramUnit,
            ),
            const Spacer(),
            if (change != null)
              Text(
                strings.plusMinusKilograms(change),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.uiStyle(
                  10,
                  change >= 0 ? theme.fg : theme.fgDim,
                  FontWeight.w700,
                ),
              ),
            const SizedBox(height: 2),
            Text(
              detail,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.uiStyle(9, theme.fgMuted),
            ),
          ],
        ],
      ),
    );
  }
}

class _ActivityCard extends StatelessWidget {
  const _ActivityCard({
    required this.data,
    required this.strings,
    required this.theme,
    required this.compact,
  });

  final HomeDashboardData data;
  final AppStrings strings;
  final FittinTheme theme;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final summaries = <ExerciseProgressSummary>[
      for (final id in const ['squat', 'bench_press', 'deadlift'])
        ...data.sparklineLifts.where((summary) => summary.exerciseId == id),
    ];
    final historyCount = summaries.fold<int>(
      0,
      (count, summary) => count + summary.estimatedHistory.length,
    );
    DateTime? latestDate;
    for (final summary in summaries) {
      final candidate = summary.lastCompletedAt;
      if (candidate != null &&
          (latestDate == null || candidate.isAfter(latestDate))) {
        latestDate = candidate;
      }
    }

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
        height: compact ? 74 : 90,
        child: historyCount == 0
            ? Center(
                child: Text(
                  strings.noStrengthTrendYet,
                  style: theme.uiStyle(12, theme.fgDim),
                ),
              )
            : Row(
                key: const ValueKey('today-activity-summary'),
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        FittinEyebrow(theme, strings.activity),
                        const SizedBox(height: 4),
                        Text(
                          strings.bigThreeHistory,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.uiStyle(13, theme.fg, FontWeight.w700),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          strings.e1rmEntries(historyCount),
                          style: theme.uiStyle(10, theme.fgMuted),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 14),
                  Container(width: 1, height: 42, color: theme.border),
                  const SizedBox(width: 14),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        strings.latest,
                        style: theme
                            .uiStyle(9, theme.fgMuted, FontWeight.w700)
                            .copyWith(letterSpacing: 0.7),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        latestDate == null
                            ? '—'
                            : strings.shortMonthDay(latestDate),
                        style: theme.uiStyle(13, theme.fg, FontWeight.w700),
                      ),
                    ],
                  ),
                ],
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
    required this.compact,
  });

  final FittinTheme theme;
  final AppStrings strings;
  final VoidCallback onOpenPlans;
  final VoidCallback onOpenPr;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final actions = [
      (
        label: strings.switchPlanAction,
        subtitle: null,
        icon: Icons.swap_horiz_rounded,
        onTap: onOpenPlans,
      ),
      (
        label: strings.seeAllPrs,
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
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            mainAxisExtent: compact ? 56 : 68,
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

class _NotificationMilestoneTile extends ConsumerWidget {
  const _NotificationMilestoneTile({
    required this.strings,
    required this.milestone,
    required this.onTap,
  });

  final AppStrings strings;
  final PRMilestone milestone;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(resolvedFittinThemeProvider);
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
                color: theme.surfaceHi,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.workspace_premium, size: 18, color: theme.fg),
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
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: theme.fgDim),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Text(
              strings.shortMonthDay(milestone.date),
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: theme.fgMuted),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeOverviewSkeleton extends StatelessWidget {
  const _HomeOverviewSkeleton({required this.compact});

  final bool compact;

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
            Expanded(child: card(height: compact ? 142 : 168)),
            const SizedBox(width: 10),
            Expanded(child: card(height: compact ? 142 : 168)),
          ],
        ),
        SizedBox(height: compact ? 10 : 16),
        card(height: compact ? 104 : 124),
        SizedBox(height: compact ? 8 : 16),
        Row(
          children: [
            Expanded(child: card(height: compact ? 52 : 72)),
            const SizedBox(width: 10),
            Expanded(child: card(height: compact ? 52 : 72)),
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

class NestedProgressRings extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(resolvedFittinThemeProvider);
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _NestedProgressRingsPainter(
          outerProgress: outerProgress,
          innerProgress: innerProgress,
          primaryColor: theme.accent,
          secondaryColor: theme.chartSeries[1],
          trackColor: theme.chartGrid,
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Text(
              centerLabel,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: theme.fg,
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
    required this.secondaryColor,
    required this.trackColor,
  });

  final double outerProgress;
  final double innerProgress;
  final Color primaryColor;
  final Color secondaryColor;
  final Color trackColor;

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
      color: secondaryColor,
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
      ..color = trackColor
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
        oldDelegate.primaryColor != primaryColor ||
        oldDelegate.secondaryColor != secondaryColor ||
        oldDelegate.trackColor != trackColor;
  }
}
