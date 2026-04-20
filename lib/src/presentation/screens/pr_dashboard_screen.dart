import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fittin_v2/src/application/app_locale_provider.dart';
import 'package:fittin_v2/src/application/fittin_theme_provider.dart';
import 'package:fittin_v2/src/application/pr_dashboard_provider.dart';
import 'package:fittin_v2/src/application/progress_analytics_provider.dart';
import 'package:fittin_v2/src/presentation/localization/app_strings.dart';
import 'package:fittin_v2/src/presentation/screens/advanced_analytics_screen.dart';
import 'package:fittin_v2/src/presentation/screens/exercise_deep_dive_screen.dart';
import 'package:fittin_v2/src/presentation/widgets/chart_container.dart';
import 'package:fittin_v2/src/presentation/widgets/charts/step_chart.dart';
import 'package:fittin_v2/src/presentation/widgets/dashboard_primitives.dart';
import 'package:fittin_v2/src/presentation/widgets/fittin_primitives.dart';
import 'package:fittin_v2/src/presentation/theme/fittin_theme.dart' show FittinTheme;

class PRDashboardScreen extends ConsumerStatefulWidget {
  const PRDashboardScreen({super.key});

  @override
  ConsumerState<PRDashboardScreen> createState() => _PRDashboardScreenState();
}

class _PRDashboardScreenState extends ConsumerState<PRDashboardScreen> {
  PRMetricMode _metricMode = PRMetricMode.estimated;
  String _selectedLiftKey = 'squat';

  @override
  Widget build(BuildContext context) {
    final dataAsync = ref.watch(prDashboardDataProvider);
    final strings = AppStrings.of(context, ref);
    final fittinTheme = ref.watch(resolvedFittinThemeProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      body: dataAsync.when(
        data: (data) {
          _selectedLiftKey = _resolveSelectedLiftKey(data);
          return DashboardPageScaffold(
            children: [
              DashboardScreenHeader(
                eyebrow: 'Performance',
                title: 'PR dashboard',
                subtitle: 'Peak strength benchmarks, derived and actual.',
              ),
              const SizedBox(height: 24),
              _buildMetricToggle(fittinTheme, strings),
              const SizedBox(height: 16),
              _buildQuickStats(fittinTheme, context, strings, data),
              const SizedBox(height: 24),
              _buildMainChart(fittinTheme, context, strings, data),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: DashboardSectionLabel(
                      label: strings.recentMilestones,
                    ),
                  ),
                  TextButton(
                    key: const ValueKey('view-all-milestones'),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => MilestoneHistoryScreen(
                            milestones: data.allMilestones,
                          ),
                        ),
                      );
                    },
                    child: Text('View all'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (data.recentMilestones.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(strings.noMilestonesYet),
                )
              else
                ...data.recentMilestones.map(
                  (milestone) => _MilestoneTile(
                    theme: fittinTheme,
                    milestone: milestone,
                    locale: ref.watch(appLocaleProvider),
                    valueLabel: strings.milestoneValueLabel(
                      _localizedMilestoneLabel(strings, milestone.type),
                      milestone.value,
                    ),
                    onTap: () {
                      final summary = milestone.summary;
                      if (summary != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                ExerciseDeepDiveScreen(summary: summary),
                          ),
                        );
                      }
                    },
                  ),
                ),
              const SizedBox(height: 40),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
    );
  }

  String _resolveSelectedLiftKey(PRDashboardData data) {
    final available = {
      if (data.squat != null) 'squat',
      if (data.bench != null) 'bench',
      if (data.deadlift != null) 'deadlift',
    };
    if (available.contains(_selectedLiftKey)) {
      return _selectedLiftKey;
    }
    return available.firstOrNull ?? 'squat';
  }

  Widget _buildMetricToggle(FittinTheme theme, AppStrings strings) {
    return FittinSegmented(
      theme: theme,
      options: [strings.estimated1rmShort, strings.actualPrShort],
      value: _metricMode == PRMetricMode.estimated
          ? strings.estimated1rmShort
          : strings.actualPrShort,
      onChange: (selected) {
        setState(() {
          _metricMode = selected == strings.estimated1rmShort
              ? PRMetricMode.estimated
              : PRMetricMode.actual;
        });
      },
    );
  }

  Widget _buildQuickStats(
    FittinTheme theme,
    BuildContext context,
    AppStrings strings,
    PRDashboardData data,
  ) {
    final cards = [
      _StrengthCard(
        key: const ValueKey('strength-card-squat'),
        theme: theme,
        summary: data.squat,
        label: strings.squatShort,
        metricMode: _metricMode,
        onTap: () => _navigateToDeepDive(context, data.squat),
      ),
      _StrengthCard(
        key: const ValueKey('strength-card-bench'),
        theme: theme,
        summary: data.bench,
        label: strings.benchShort,
        metricMode: _metricMode,
        onTap: () => _navigateToDeepDive(context, data.bench),
      ),
      _StrengthCard(
        key: const ValueKey('strength-card-deadlift'),
        theme: theme,
        summary: data.deadlift,
        label: strings.deadliftShort,
        metricMode: _metricMode,
        onTap: () => _navigateToDeepDive(context, data.deadlift),
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 420) {
          return Column(
            children: [
              for (var i = 0; i < cards.length; i++) ...[
                cards[i],
                if (i < cards.length - 1) const SizedBox(height: 12),
              ],
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: cards[0]),
            const SizedBox(width: 12),
            Expanded(child: cards[1]),
            const SizedBox(width: 12),
            Expanded(child: cards[2]),
          ],
        );
      },
    );
  }

  void _navigateToDeepDive(
    BuildContext context,
    ExerciseProgressSummary? summary,
  ) {
    if (summary != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ExerciseDeepDiveScreen(summary: summary),
        ),
      );
    }
  }

  Widget _buildMainChart(
    FittinTheme theme,
    BuildContext context,
    AppStrings strings,
    PRDashboardData data,
  ) {
    final selectedSummary = switch (_selectedLiftKey) {
      'bench' => data.bench,
      'deadlift' => data.deadlift,
      _ => data.squat,
    };

    return ChartContainer(
      title: strings.strengthProgressionTitle,
      height: 260,
      headerAction: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: SizedBox(
              width: double.infinity,
              child: FittinSegmented(
                theme: theme,
                options: [strings.squatShort, strings.benchShort, strings.deadliftShort],
                value: _selectedLiftKey == 'bench'
                    ? strings.benchShort
                    : _selectedLiftKey == 'deadlift'
                        ? strings.deadliftShort
                        : strings.squatShort,
                onChange: (selected) {
                  setState(() {
                    if (selected == strings.benchShort) {
                      _selectedLiftKey = 'bench';
                    } else if (selected == strings.deadliftShort) {
                      _selectedLiftKey = 'deadlift';
                    } else {
                      _selectedLiftKey = 'squat';
                    }
                  });
                },
              ),
            ),
          ),
          const SizedBox(height: 12),
          if (selectedSummary != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                selectedSummary.exerciseName,
                key: const ValueKey('selected-chart-lift-label'),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.72),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          TextButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const AdvancedAnalyticsScreen(),
              ),
            ),
            child: Text(
              strings.detailsCta,
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      child: _LiftChart(
        theme: theme,
        summary: selectedSummary,
        metricMode: _metricMode,
        axisWeightLabelBuilder: strings.chartAxisWeight,
        localeCode: ref.watch(appLocaleProvider).code,
      ),
    );
  }
}

class _StrengthCard extends StatelessWidget {
  const _StrengthCard({
    super.key,
    required this.theme,
    this.summary,
    required this.label,
    required this.metricMode,
    this.onTap,
  });

  final FittinTheme theme;
  final ExerciseProgressSummary? summary;
  final String label;
  final PRMetricMode metricMode;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final value = metricMode == PRMetricMode.actual
        ? summary?.bestActualOneRepMax
        : summary?.currentEstimatedOneRepMax;
    final change = metricMode == PRMetricMode.actual
        ? _actualPrDelta(summary)
        : summary?.recentChange;

    // Build sparkline data from history
    final history = metricMode == PRMetricMode.actual
        ? summary?.actualHistory
        : summary?.estimatedHistory;
    final sparklineData = history != null && history.isNotEmpty
        ? history.map((p) => p.value).toList()
        : <double>[];

    return DashboardSurfaceCard(
      onTap: onTap,
      radius: 24,
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        width: double.infinity,
        height: 144,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.uiStyle(11, theme.fgMuted).copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: 1.0,
              ),
            ),
            const Spacer(),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: FittinBigNum(
                    theme,
                    value?.toStringAsFixed(1) ?? '—',
                    size: 34,
                    color: theme.fg,
                  ),
                ),
                if (sparklineData.length > 1) ...[
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Sparkline(
                        theme,
                        sparklineData,
                        width: 110,
                        height: 44,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${sparklineData.length} sessions',
                        style: theme.uiStyle(10, theme.fgMuted),
                      ),
                    ],
                  ),
                ],
              ],
            ),
            const SizedBox(height: 8),
            if (change != null)
              FittinDelta(theme, change, unit: ' kg')
            else
              Text(
                '—',
                style: theme.uiStyle(12, theme.fgDim),
              ),
          ],
        ),
      ),
    );
  }

  double? _actualPrDelta(ExerciseProgressSummary? summary) {
    final history = summary?.actualHistory;
    if (history == null || history.length < 2) {
      return null;
    }
    return history.last.value - history[history.length - 2].value;
  }
}

class _LiftChart extends StatelessWidget {
  const _LiftChart({
    required this.theme,
    required this.summary,
    required this.metricMode,
    required this.axisWeightLabelBuilder,
    required this.localeCode,
  });

  final FittinTheme theme;
  final ExerciseProgressSummary? summary;
  final PRMetricMode metricMode;
  final String Function(String value) axisWeightLabelBuilder;
  final String localeCode;

  @override
  Widget build(BuildContext context) {
    final history = metricMode == PRMetricMode.actual
        ? (summary?.actualHistory ?? const <ExercisePerformancePoint>[])
        : (summary?.estimatedHistory ?? const <ExercisePerformancePoint>[]);
    if (summary == null || history.isEmpty) {
      return const Center(child: Text('—'));
    }

    final recent = history.length > 8
        ? history.sublist(history.length - 8)
        : history;
    final chartData = recent.map((p) => p.value).toList();

    // Compute y-axis labels
    final minValue = chartData.reduce((a, b) => a < b ? a : b);
    final maxValue = chartData.reduce((a, b) => a > b ? a : b);
    final yLabels = [
      axisWeightLabelBuilder(minValue.toStringAsFixed(0)),
      axisWeightLabelBuilder(((minValue + maxValue) / 2).toStringAsFixed(0)),
      axisWeightLabelBuilder(maxValue.toStringAsFixed(0)),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: StepChart(
                  theme,
                  chartData,
                  height: 200,
                  showDots: true,
                  showGrid: true,
                  yLabels: yLabels,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            for (final point in _selectTickPoints(recent))
              Text(
                _formatShortDate(point.completedAt, localeCode),
                style: theme.uiStyle(10, theme.fgDim),
              ),
          ],
        ),
      ],
    );
  }

  List<ExercisePerformancePoint> _selectTickPoints(
    List<ExercisePerformancePoint> points,
  ) {
    if (points.length <= 3) {
      return points;
    }
    return [points.first, points[points.length ~/ 2], points.last];
  }
}

class _MilestoneTile extends StatelessWidget {
  const _MilestoneTile({
    required this.theme,
    required this.milestone,
    required this.locale,
    required this.valueLabel,
    this.onTap,
  });

  final FittinTheme theme;
  final PRMilestone milestone;
  final AppLocale locale;
  final String valueLabel;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final dateLabel = _formatShortDate(milestone.date, locale.code);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DashboardSurfaceCard(
        onTap: onTap,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        radius: 22,
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_rounded,
                color: theme.accent,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    milestone.exerciseName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                  Text(
                    valueLabel,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              dateLabel,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.3),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum MilestoneTimeFilter { all, days30, days90, days365 }

enum MilestoneTypeFilter { all, estimated, actual }

class MilestoneHistoryScreen extends ConsumerStatefulWidget {
  const MilestoneHistoryScreen({super.key, required this.milestones});

  final List<PRMilestone> milestones;

  @override
  ConsumerState<MilestoneHistoryScreen> createState() =>
      _MilestoneHistoryScreenState();
}

class _MilestoneHistoryScreenState
    extends ConsumerState<MilestoneHistoryScreen> {
  String? _exerciseFilter;
  MilestoneTypeFilter _typeFilter = MilestoneTypeFilter.all;
  MilestoneTimeFilter _timeFilter = MilestoneTimeFilter.all;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context, ref);
    final locale = ref.watch(appLocaleProvider);
    final fittinTheme = ref.watch(resolvedFittinThemeProvider);
    final exerciseOptions =
        widget.milestones
            .map((milestone) => milestone.exerciseName)
            .toSet()
            .toList()
          ..sort();
    final filtered = widget.milestones.where(_matchesFilters).toList();

    return Scaffold(
      backgroundColor: Colors.black,
      body: DashboardPageScaffold(
        children: [
          DashboardScreenHeader(
            eyebrow: strings.recentMilestones,
            title: strings.milestoneHistory,
            showBackButton: true,
          ),
          const SizedBox(height: 24),
          DropdownButtonFormField<String?>(
            key: const ValueKey('milestone-lift-filter'),
            initialValue: _exerciseFilter,
            decoration: InputDecoration(labelText: strings.liftFilter),
            items: [
              DropdownMenuItem<String?>(
                value: null,
                child: Text(strings.allExercises),
              ),
              for (final exerciseName in exerciseOptions)
                DropdownMenuItem<String?>(
                  value: exerciseName,
                  child: Text(exerciseName),
                ),
            ],
            onChanged: (value) => setState(() => _exerciseFilter = value),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<MilestoneTimeFilter>(
            key: const ValueKey('milestone-time-filter'),
            initialValue: _timeFilter,
            decoration: InputDecoration(labelText: strings.timeRange),
            items: [
              DropdownMenuItem(
                value: MilestoneTimeFilter.all,
                child: Text(strings.allTime),
              ),
              DropdownMenuItem(
                value: MilestoneTimeFilter.days30,
                child: Text(strings.last30Days),
              ),
              DropdownMenuItem(
                value: MilestoneTimeFilter.days90,
                child: Text(strings.last90Days),
              ),
              DropdownMenuItem(
                value: MilestoneTimeFilter.days365,
                child: Text(strings.last365Days),
              ),
            ],
            onChanged: (value) {
              if (value != null) {
                setState(() => _timeFilter = value);
              }
            },
          ),
          const SizedBox(height: 16),
          SegmentedButton<MilestoneTypeFilter>(
            key: const ValueKey('milestone-type-filter'),
            segments: [
              ButtonSegment<MilestoneTypeFilter>(
                value: MilestoneTypeFilter.all,
                label: Text(strings.allTypes),
              ),
              ButtonSegment<MilestoneTypeFilter>(
                value: MilestoneTypeFilter.estimated,
                label: Text(strings.estimatedType),
              ),
              ButtonSegment<MilestoneTypeFilter>(
                value: MilestoneTypeFilter.actual,
                label: Text(strings.actualType),
              ),
            ],
            selected: {_typeFilter},
            onSelectionChanged: (selection) {
              setState(() {
                _typeFilter = selection.first;
              });
            },
          ),
          const SizedBox(height: 20),
          if (filtered.isEmpty)
            Text(
              widget.milestones.isEmpty
                  ? strings.noMilestonesYet
                  : strings.noFilteredMilestones,
            )
          else
            ...filtered.map(
              (milestone) => _MilestoneTile(
                theme: fittinTheme,
                milestone: milestone,
                locale: locale,
                valueLabel: strings.milestoneValueLabel(
                  _localizedMilestoneLabel(strings, milestone.type),
                  milestone.value,
                ),
                onTap: () {
                  final summary = milestone.summary;
                  if (summary != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            ExerciseDeepDiveScreen(summary: summary),
                      ),
                    );
                  }
                },
              ),
            ),
        ],
      ),
    );
  }

  bool _matchesFilters(PRMilestone milestone) {
    if (_exerciseFilter != null && milestone.exerciseName != _exerciseFilter) {
      return false;
    }
    switch (_typeFilter) {
      case MilestoneTypeFilter.all:
        break;
      case MilestoneTypeFilter.estimated:
        if (milestone.type != PRMilestoneType.estimated) {
          return false;
        }
      case MilestoneTypeFilter.actual:
        if (milestone.type != PRMilestoneType.actual) {
          return false;
        }
    }
    final now = DateTime.now();
    final difference = now.difference(milestone.date).inDays;
    return switch (_timeFilter) {
      MilestoneTimeFilter.all => true,
      MilestoneTimeFilter.days30 => difference <= 30,
      MilestoneTimeFilter.days90 => difference <= 90,
      MilestoneTimeFilter.days365 => difference <= 365,
    };
  }
}

String _localizedMilestoneLabel(AppStrings strings, PRMilestoneType type) {
  return type == PRMilestoneType.actual
      ? strings.actualType
      : strings.estimatedType;
}

String _formatShortDate(DateTime date, String localeCode) {
  if (localeCode == 'zh') {
    return '${date.month}月${date.day}日';
  }
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return '${months[date.month - 1]} ${date.day}';
}
