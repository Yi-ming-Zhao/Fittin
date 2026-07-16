import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fittin_v2/src/application/fittin_theme_provider.dart';
import 'package:fittin_v2/src/application/progress_analytics_provider.dart';
import 'package:fittin_v2/src/application/progress_service.dart';
import 'package:fittin_v2/src/presentation/localization/app_strings.dart';
import 'package:fittin_v2/src/presentation/widgets/chart_container.dart';
import 'package:fittin_v2/src/presentation/widgets/charts/interactive_line_chart.dart';
import 'package:fittin_v2/src/presentation/widgets/dashboard_primitives.dart';
import 'package:fittin_v2/src/presentation/widgets/fittin_primitives.dart';
import 'package:fittin_v2/src/presentation/theme/fittin_theme.dart'
    show FittinTheme;

class ExerciseDeepDiveScreen extends ConsumerWidget {
  const ExerciseDeepDiveScreen({super.key, required this.summary});
  final ExerciseProgressSummary summary;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fittinTheme = ref.watch(resolvedFittinThemeProvider);
    final progressService = ref.watch(progressServiceProvider);
    final strings = AppStrings.of(context, ref);

    return Scaffold(
      backgroundColor: fittinTheme.bg,
      body: DashboardPageScaffold(
        children: [
          Row(
            children: [
              DashboardBackButton(
                theme: fittinTheme,
                label: strings.progressBackLabel,
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: 18),
          FittinEyebrow(fittinTheme, strings.exerciseDetails),
          const SizedBox(height: 10),
          Text(
            summary.exerciseName,
            style: fittinTheme.displayStyle(40, fittinTheme.fg),
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              FittinBigNum(
                fittinTheme,
                summary.currentEstimatedOneRepMax?.toStringAsFixed(1) ?? '—',
                size: 26,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    strings.estimatedOneRepMaxUnitLabel(strings.kilogramUnit),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: fittinTheme.uiStyle(13, fittinTheme.fgDim),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildQuickStats(fittinTheme, strings),
          const SizedBox(height: 24),
          _buildTrendChart(context, fittinTheme, progressService, strings),
          const SizedBox(height: 32),
          DashboardSectionLabel(label: strings.sessionHistory),
          const SizedBox(height: 16),
          _buildHistoryList(context, strings, fittinTheme),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildQuickStats(FittinTheme theme, AppStrings strings) {
    final current = summary.currentEstimatedOneRepMax;
    final change = summary.recentChange;

    return Row(
      children: [
        Expanded(
          child: DashboardSurfaceCard(
            radius: 22,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  strings.estimatedOneRepMaxAbbreviation,
                  style: theme
                      .uiStyle(10, theme.fgMuted)
                      .copyWith(
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.0,
                      ),
                ),
                const SizedBox(height: 8),
                FittinBigNum(
                  theme,
                  current?.toStringAsFixed(1) ?? '—',
                  size: 32,
                  color: theme.fg,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: DashboardSurfaceCard(
            radius: 22,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  strings.change30d,
                  style: theme
                      .uiStyle(10, theme.fgMuted)
                      .copyWith(
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.0,
                      ),
                ),
                const SizedBox(height: 8),
                if (change != null)
                  FittinDelta(theme, change)
                else
                  Text('—', style: theme.uiStyle(24, theme.fgDim)),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: DashboardSurfaceCard(
            radius: 22,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  strings.encounterCount,
                  style: theme
                      .uiStyle(10, theme.fgMuted)
                      .copyWith(
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.0,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${summary.estimatedHistory.length}',
                  style: theme.numStyle(32, theme.fg),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Task 4.2: StrengthTrendsOverlayChart showing 1/3/5RM lines
  Widget _buildTrendChart(
    BuildContext context,
    FittinTheme theme,
    ProgressService service,
    AppStrings strings,
  ) {
    if (summary.estimatedHistory.isEmpty) return const SizedBox.shrink();

    final recent = summary.estimatedHistory.length > 10
        ? summary.estimatedHistory.sublist(summary.estimatedHistory.length - 10)
        : summary.estimatedHistory;

    DatedChartPoint pointFor(ExercisePerformancePoint point, double value) =>
        DatedChartPoint(
          date: point.completedAt,
          value: value,
          detail: strings.derivedFromSet(point.weight, point.reps),
        );

    return ChartContainer(
      title: strings.strengthTrendsOverlay,
      height: 270,
      child: InteractiveLineChart(
        key: const ValueKey('exercise-deep-dive-chart'),
        theme: theme,
        series: [
          DatedChartSeries(
            id: '1rm',
            label: strings.repMaxLabel(1),
            points: [for (final point in recent) pointFor(point, point.value)],
          ),
          DatedChartSeries(
            id: '3rm',
            label: strings.repMaxLabel(3),
            points: [
              for (final point in recent)
                pointFor(point, service.calculateNRM(point.value, 3) ?? 0),
            ],
          ),
          DatedChartSeries(
            id: '5rm',
            label: strings.repMaxLabel(5),
            points: [
              for (final point in recent)
                pointFor(point, service.calculateNRM(point.value, 5) ?? 0),
            ],
          ),
        ],
        chartLabel: strings.strengthTrendsOverlay,
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
        height: 270,
      ),
    );
  }

  Widget _buildHistoryList(
    BuildContext context,
    AppStrings strings,
    FittinTheme theme,
  ) {
    if (summary.estimatedHistory.isEmpty) {
      return DashboardSurfaceCard(
        radius: 22,
        padding: const EdgeInsets.all(16),
        child: Text(
          strings.noExerciseHistory,
          style: theme.uiStyle(13, theme.fgMuted),
        ),
      );
    }

    return Column(
      children: summary.estimatedHistory.reversed.map((point) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: DashboardSurfaceCard(
            radius: 22,
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        strings.longDate(point.completedAt),
                        style: theme
                            .uiStyle(14, theme.fg)
                            .copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        strings.setLoadAndReps(point.weight, point.reps),
                        style: theme.uiStyle(13, theme.fgMuted),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      point.value.toStringAsFixed(1),
                      style: theme
                          .numStyle(18, theme.fg)
                          .copyWith(fontWeight: FontWeight.w800),
                    ),
                    Text(
                      strings.estimatedOneRepMaxAbbreviation,
                      style: theme
                          .uiStyle(10, theme.fgMuted)
                          .copyWith(
                            letterSpacing: 0.8,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
