import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fittin_v2/src/application/fittin_theme_provider.dart';
import 'package:fittin_v2/src/application/pr_dashboard_provider.dart';
import 'package:fittin_v2/src/application/progress_analytics_provider.dart';
import 'package:fittin_v2/src/presentation/localization/app_strings.dart';
import 'package:fittin_v2/src/presentation/screens/exercise_deep_dive_screen.dart';
import 'package:fittin_v2/src/presentation/widgets/charts/interactive_line_chart.dart';
import 'package:fittin_v2/src/presentation/widgets/dashboard_primitives.dart';
import 'package:fittin_v2/src/presentation/widgets/fittin_primitives.dart';
import 'package:fittin_v2/src/presentation/theme/fittin_theme.dart'
    show FittinTheme;

class PRDashboardScreen extends ConsumerStatefulWidget {
  const PRDashboardScreen({super.key});

  @override
  ConsumerState<PRDashboardScreen> createState() => _PRDashboardScreenState();
}

class _PRDashboardScreenState extends ConsumerState<PRDashboardScreen> {
  PRMetricMode _metricMode = PRMetricMode.estimated;
  late final PageController _liftPageController;
  int _selectedLiftIndex = 0;

  @override
  void initState() {
    super.initState();
    _liftPageController = PageController();
  }

  @override
  void dispose() {
    _liftPageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dataAsync = ref.watch(prDashboardDataProvider);
    final strings = AppStrings.of(context, ref);
    final fittinTheme = ref.watch(resolvedFittinThemeProvider);

    return Scaffold(
      backgroundColor: fittinTheme.bg,
      body: dataAsync.when(
        data: (data) {
          return DashboardPageScaffold(
            topPadding: 24,
            children: [
              DashboardScreenHeader(
                eyebrow: strings.performance,
                title: strings.prDashboard,
              ),
              const SizedBox(height: 14),
              _buildMetricToggle(fittinTheme, strings),
              const SizedBox(height: 12),
              _buildQuickStats(fittinTheme, context, strings, data),
              const SizedBox(height: 14),
              _buildMainChart(fittinTheme, context, strings, data),
              const SizedBox(height: 24),
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
                    child: Text(strings.viewAllMilestones),
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
                    strings: strings,
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
        error: (error, _) => Center(child: Text(strings.loadError(error))),
      ),
    );
  }

  Widget _buildMetricToggle(FittinTheme theme, AppStrings strings) {
    return FittinSegmented(
      theme: theme,
      options: [strings.estimated1rmShort, strings.actualPrShort],
      value: _metricMode == PRMetricMode.estimated
          ? strings.estimated1rmShort
          : strings.actualPrShort,
      expand: true,
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
        strings: strings,
        metricMode: _metricMode,
        selected: _selectedLiftIndex == 0,
        onTap: () => _selectLift(0),
      ),
      _StrengthCard(
        key: const ValueKey('strength-card-bench'),
        theme: theme,
        summary: data.bench,
        label: strings.benchShort,
        strings: strings,
        metricMode: _metricMode,
        selected: _selectedLiftIndex == 1,
        onTap: () => _selectLift(1),
      ),
      _StrengthCard(
        key: const ValueKey('strength-card-deadlift'),
        theme: theme,
        summary: data.deadlift,
        label: strings.deadliftShort,
        strings: strings,
        metricMode: _metricMode,
        selected: _selectedLiftIndex == 2,
        onTap: () => _selectLift(2),
      ),
    ];

    return SizedBox(
      height: 96,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: cards[0]),
          const SizedBox(width: 8),
          Expanded(child: cards[1]),
          const SizedBox(width: 8),
          Expanded(child: cards[2]),
        ],
      ),
    );
  }

  void _selectLift(int index) {
    if (_selectedLiftIndex == index) {
      return;
    }
    setState(() => _selectedLiftIndex = index);
    _liftPageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeOutCubic,
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
    final summaries = [data.squat, data.bench, data.deadlift];
    final labels = [
      strings.squatShort,
      strings.benchShort,
      strings.deadliftShort,
    ];
    final selectedSummary = summaries[_selectedLiftIndex];

    return DashboardSurfaceCard(
      radius: 26,
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: DashboardSectionLabel(
                  label: strings.strengthProgressionTitle,
                ),
              ),
              TextButton(
                key: const ValueKey('open-selected-lift-details'),
                onPressed: selectedSummary == null
                    ? null
                    : () => _navigateToDeepDive(context, selectedSummary),
                child: Text(strings.detailsCta),
              ),
            ],
          ),
          SizedBox(
            height: 308,
            child: PageView.builder(
              key: const ValueKey('pr-lift-page-view'),
              controller: _liftPageController,
              itemCount: summaries.length,
              onPageChanged: (index) {
                if (_selectedLiftIndex != index) {
                  setState(() => _selectedLiftIndex = index);
                }
              },
              itemBuilder: (context, index) => _LiftChart(
                key: ValueKey('pr-lift-chart-${labels[index]}'),
                theme: theme,
                summary: summaries[index],
                liftLabel: labels[index],
                metricMode: _metricMode,
                strings: strings,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var index = 0; index < summaries.length; index++) ...[
                AnimatedContainer(
                  key: ValueKey('pr-lift-page-indicator-$index'),
                  duration: const Duration(milliseconds: 180),
                  width: _selectedLiftIndex == index ? 18 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: _selectedLiftIndex == index
                        ? theme.accent
                        : theme.fgMuted.withValues(alpha: 0.38),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                if (index < summaries.length - 1) const SizedBox(width: 6),
              ],
            ],
          ),
        ],
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
    required this.strings,
    required this.metricMode,
    required this.selected,
    this.onTap,
  });

  final FittinTheme theme;
  final ExerciseProgressSummary? summary;
  final String label;
  final AppStrings strings;
  final PRMetricMode metricMode;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final value = metricMode == PRMetricMode.actual
        ? summary?.bestActualOneRepMax
        : summary?.currentEstimatedOneRepMax;
    final change = metricMode == PRMetricMode.actual
        ? _actualPrDelta(summary)
        : summary?.recentChange;

    return DashboardSurfaceCard(
      onTap: onTap,
      highlight: selected,
      radius: 18,
      padding: const EdgeInsets.all(10),
      child: SizedBox(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FittinEyebrow(theme, label),
            const SizedBox(height: 5),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  FittinBigNum(
                    theme,
                    value?.toStringAsFixed(1) ?? '—',
                    size: 24,
                    color: theme.fg,
                  ),
                  const SizedBox(width: 3),
                  Text(
                    strings.kilogramUnit,
                    style: theme.uiStyle(10, theme.fgDim),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            if (change != null)
              SizedBox(
                width: double.infinity,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: FittinDelta(
                    theme,
                    change,
                    unit: ' ${strings.kilogramUnit}',
                  ),
                ),
              )
            else
              Text('—', style: theme.uiStyle(10, theme.fgDim)),
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
    super.key,
    required this.theme,
    required this.summary,
    required this.liftLabel,
    required this.metricMode,
    required this.strings,
  });

  final FittinTheme theme;
  final ExerciseProgressSummary? summary;
  final String liftLabel;
  final PRMetricMode metricMode;
  final AppStrings strings;

  @override
  Widget build(BuildContext context) {
    final history = metricMode == PRMetricMode.actual
        ? (summary?.actualHistory ?? const <ExercisePerformancePoint>[])
        : (summary?.estimatedHistory ?? const <ExercisePerformancePoint>[]);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          summary?.exerciseName ?? liftLabel,
          key: ValueKey('selected-chart-lift-label-$liftLabel'),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.uiStyle(13, theme.fgDim, FontWeight.w700),
        ),
        const SizedBox(height: 6),
        InteractiveLineChart(
          key: ValueKey('pr-interactive-chart-$liftLabel'),
          theme: theme,
          series: [
            if (summary != null)
              DatedChartSeries(
                id: '${summary!.exerciseId}-${metricMode.name}',
                label: metricMode == PRMetricMode.actual
                    ? strings.actualPrShort
                    : strings.estimated1rmShort,
                points: [
                  for (final point in history)
                    DatedChartPoint(
                      date: point.completedAt,
                      value: point.value,
                      detail: strings.derivedFromSet(point.weight, point.reps),
                    ),
                ],
              ),
          ],
          chartLabel: '$liftLabel ${strings.strengthProgressionTitle}',
          xAxisLabel: strings.dateAxis,
          yAxisLabel: strings.loadAxis,
          unit: strings.kilogramUnit,
          emptyLabel: strings.noStrengthTrendYet,
          selectionHint: strings.tapChartPoint,
          axisDateFormatter: strings.shortMonthDay,
          detailDateFormatter: strings.longDate,
          axisValueFormatter: (value) => value.toStringAsFixed(0),
          detailValueFormatter: (value) => value.toStringAsFixed(1),
          emptySemanticsFormatter: strings.chartEmptySemantics,
          summarySemanticsFormatter: strings.chartSummarySemantics,
          pointLabelFormatter: strings.chartPointLabel,
          height: 280,
        ),
      ],
    );
  }
}

class _MilestoneTile extends StatelessWidget {
  const _MilestoneTile({
    required this.theme,
    required this.milestone,
    required this.strings,
    required this.valueLabel,
    this.onTap,
  });

  final FittinTheme theme;
  final PRMilestone milestone;
  final AppStrings strings;
  final String valueLabel;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final dateLabel = strings.shortMonthDay(milestone.date);
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
                color: theme.surface,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.check_rounded, color: theme.accent, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    milestone.exerciseName,
                    style: TextStyle(
                      color: theme.fg,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                  Text(
                    valueLabel,
                    style: TextStyle(color: theme.fgDim, fontSize: 13),
                  ),
                ],
              ),
            ),
            Text(
              dateLabel,
              style: TextStyle(color: theme.fgMuted, fontSize: 12),
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
    final fittinTheme = ref.watch(resolvedFittinThemeProvider);
    final exerciseOptions =
        widget.milestones
            .map((milestone) => milestone.exerciseName)
            .toSet()
            .toList()
          ..sort();
    final filtered = widget.milestones.where(_matchesFilters).toList();

    return Scaffold(
      backgroundColor: fittinTheme.bg,
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
          FittinSegmented(
            key: const ValueKey('milestone-type-filter'),
            theme: fittinTheme,
            options: [
              strings.allTypes,
              strings.estimatedType,
              strings.actualType,
            ],
            value: switch (_typeFilter) {
              MilestoneTypeFilter.estimated => strings.estimatedType,
              MilestoneTypeFilter.actual => strings.actualType,
              MilestoneTypeFilter.all => strings.allTypes,
            },
            expand: true,
            onChange: (selection) {
              setState(() {
                _typeFilter = selection == strings.estimatedType
                    ? MilestoneTypeFilter.estimated
                    : selection == strings.actualType
                    ? MilestoneTypeFilter.actual
                    : MilestoneTypeFilter.all;
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
                strings: strings,
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
