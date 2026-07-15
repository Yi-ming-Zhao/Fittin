import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fittin_v2/src/application/app_locale_provider.dart';
import 'package:fittin_v2/src/application/body_metrics_provider.dart';
import 'package:fittin_v2/src/application/fittin_theme_provider.dart';
import 'package:fittin_v2/src/domain/models/body_metric.dart';
import 'package:fittin_v2/src/presentation/localization/app_strings.dart';
import 'package:fittin_v2/src/presentation/widgets/charts/interactive_line_chart.dart';
import 'package:fittin_v2/src/presentation/widgets/dashboard_primitives.dart';
import 'package:fittin_v2/src/presentation/widgets/fittin_card.dart';
import 'package:fittin_v2/src/presentation/widgets/fittin_primitives.dart';
import 'package:fittin_v2/src/presentation/theme/fittin_theme.dart'
    show FittinTheme;

class BodyMetricsScreen extends ConsumerStatefulWidget {
  const BodyMetricsScreen({super.key});

  @override
  ConsumerState<BodyMetricsScreen> createState() =>
      _BodyMetricsScreenStateful();
}

enum _BodyWeightUnit { kg, lb }

class _BodyMetricsScreenStateful extends ConsumerState<BodyMetricsScreen> {
  _BodyWeightUnit _weightUnit = _BodyWeightUnit.kg;

  @override
  Widget build(BuildContext context) {
    final metricsAsync = ref.watch(bodyMetricsProvider);
    final strings = AppStrings.of(context, ref);
    final fittinTheme = ref.watch(resolvedFittinThemeProvider);

    return Scaffold(
      backgroundColor: fittinTheme.bg,
      body: metricsAsync.when(
        data: (metrics) {
          final screenState = _BodyMetricsScreenState.fromMetrics(metrics);

          return DashboardPageScaffold(
            bottomPadding: 24,
            children: [
              DashboardScreenHeader(
                eyebrow: strings.composition,
                title: strings.bodyMetrics,
                subtitle: strings.bodyMetricsSubtitle,
              ),
              const SizedBox(height: 24),
              _buildHeroCard(
                context,
                fittinTheme,
                metrics,
                screenState,
                strings,
              ),
              const SizedBox(height: 16),
              DashboardSectionLabel(label: strings.currentSnapshot),
              const SizedBox(height: 16),
              _buildMetricGrid(context, fittinTheme, metrics, strings),
              if (screenState == _BodyMetricsScreenState.populated) ...[
                const SizedBox(height: 16),
                _buildCheckInCta(context, fittinTheme, strings),
              ],
              const SizedBox(height: 24),
              DashboardSectionLabel(label: strings.measurementLog),
              const SizedBox(height: 16),
              _buildHistoryList(context, fittinTheme, metrics, strings),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(strings.loadError(e))),
      ),
    );
  }

  Widget _buildHeroCard(
    BuildContext context,
    FittinTheme theme,
    List<BodyMetric> metrics,
    _BodyMetricsScreenState screenState,
    AppStrings strings,
  ) {
    final weightedMetrics = metrics
        .where((metric) => metric.weightKg != null)
        .toList();
    if (weightedMetrics.isNotEmpty) {
      return _buildWeightHero(
        context,
        theme,
        weightedMetrics,
        screenState,
        strings,
      );
    }

    return _BodyMetricsHeroEmptyState(
      theme: theme,
      title: screenState == _BodyMetricsScreenState.empty
          ? strings.recordFirstCheckIn
          : strings.noWeightTrendYet,
      body: screenState == _BodyMetricsScreenState.empty
          ? strings.bodyMetricsHeroEmptyBody
          : strings.bodyMetricsHeroPartialBody,
      actionLabel: screenState == _BodyMetricsScreenState.empty
          ? strings.addFirstMeasurement
          : strings.addCompleteMeasurement,
      onPressed: () => _showAddMetricDialog(context, theme),
    );
  }

  Widget _buildWeightHero(
    BuildContext context,
    FittinTheme theme,
    List<BodyMetric> weightedMetrics,
    _BodyMetricsScreenState screenState,
    AppStrings strings,
  ) {
    final chronological = [...weightedMetrics]
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
    final latestMetric = chronological.last;
    final latestWeightKg = latestMetric.weightKg!;
    final previousWeightKg = chronological.length > 1
        ? chronological[chronological.length - 2].weightKg
        : null;
    final scale = _weightUnit == _BodyWeightUnit.kg ? 1.0 : 2.2046226218;
    final unitSymbol = _weightUnit == _BodyWeightUnit.kg
        ? strings.kilogramSymbol
        : strings.poundSymbol;
    final unit = _weightUnit == _BodyWeightUnit.kg
        ? strings.kilogramUnit
        : strings.poundUnit;
    final latestWeight = latestWeightKg * scale;
    final previousWeight = previousWeightKg == null
        ? null
        : previousWeightKg * scale;
    final delta = _calculateDelta(latestWeight, previousWeight);
    final chartPoints = <DatedChartPoint>[
      for (var index = 0; index < chronological.length; index++)
        DatedChartPoint(
          date: chronological[index].timestamp,
          value: chronological[index].weightKg! * scale,
          detail: index == 0
              ? strings.firstWeightEntry
              : strings.weightPointDelta(
                  (chronological[index].weightKg! -
                          chronological[index - 1].weightKg!) *
                      scale,
                  unit,
                ),
        ),
    ];

    return DashboardSurfaceCard(
      radius: 34,
      padding: EdgeInsets.all(theme.pad),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              FittinEyebrow(theme, strings.weightWithUnitLabel(unit)),
              // Unit segmented control
              FittinSegmented(
                theme: theme,
                options: [strings.kilogramSymbol, strings.poundSymbol],
                value: unitSymbol,
                onChange: (value) {
                  setState(() {
                    _weightUnit = value == strings.poundSymbol
                        ? _BodyWeightUnit.lb
                        : _BodyWeightUnit.kg;
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: FittinBigNum(
                  theme,
                  latestWeight.toStringAsFixed(1),
                  size: 52,
                  color: theme.fg,
                  unit: unit,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          InteractiveLineChart(
            key: const ValueKey('body-weight-chart'),
            theme: theme,
            series: [
              DatedChartSeries(
                id: 'body-weight',
                label: strings.weightSeries,
                points: chartPoints,
              ),
            ],
            chartLabel: strings.weightProgression,
            xAxisLabel: strings.dateAxis,
            yAxisLabel: strings.weightAxis,
            unit: unit,
            emptyLabel: strings.noWeightTrendYet,
            selectionHint: strings.tapChartPoint,
            axisDateFormatter: strings.shortMonthDay,
            detailDateFormatter: strings.longDate,
            axisValueFormatter: (value) => value.toStringAsFixed(0),
            detailValueFormatter: (value) => value.toStringAsFixed(1),
            emptySemanticsFormatter: strings.chartEmptySemantics,
            summarySemanticsFormatter: strings.chartSummarySemantics,
            pointLabelFormatter: strings.chartPointLabel,
            height: 250,
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              if (delta != null) FittinDelta(theme, delta, unit: ' $unit'),
              if (delta != null) const SizedBox(width: 8),
              Text(
                delta == null
                    ? strings.shortMonthDay(latestMetric.timestamp)
                    : strings.sinceLastCheckIn,
                style: theme.uiStyle(11, theme.fgMuted),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricGrid(
    BuildContext context,
    FittinTheme theme,
    List<BodyMetric> metrics,
    AppStrings strings,
  ) {
    final latest = metrics.firstOrNull;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 520;
        return GridView.count(
          crossAxisCount: isWide ? 3 : 3,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: isWide ? 1.15 : 0.95,
          children: [
            _MetricCard(
              theme: theme,
              strings: strings,
              label: strings.bodyFat,
              latestValue: latest?.bodyFatPercent,
              previousValue: _findPreviousComparable(
                metrics,
                (metric) => metric.bodyFatPercent,
              ),
              unit: strings.percentUnit,
            ),
            _MetricCard(
              theme: theme,
              strings: strings,
              label: strings.waist,
              latestValue: latest?.waistCm,
              previousValue: _findPreviousComparable(
                metrics,
                (metric) => metric.waistCm,
              ),
              unit: strings.centimeterUnit,
            ),
            _MetricCard(
              theme: theme,
              strings: strings,
              label: strings.checkIns,
              latestValue: metrics.isEmpty ? null : metrics.length.toDouble(),
              previousValue: null,
              unit: '',
            ),
          ],
        );
      },
    );
  }

  Widget _buildCheckInCta(
    BuildContext context,
    FittinTheme theme,
    AppStrings strings,
  ) {
    return DashboardSurfaceCard(
      radius: theme.radius,
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  strings.recordFirstCheckIn,
                  style: theme.displayStyle(17, theme.fg),
                ),
                const SizedBox(height: 4),
                Text(
                  strings.bodyMetricsHeroEmptyBody,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.uiStyle(12, theme.fgDim).copyWith(height: 1.35),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          FittinBtn(
            theme,
            strings.addMeasurement,
            icon: Icons.add_rounded,
            size: 'sm',
            onPressed: () => _showAddMetricDialog(context, theme),
          ),
        ],
      ),
    );
  }

  double? _findPreviousComparable(
    List<BodyMetric> metrics,
    double? Function(BodyMetric metric) selector,
  ) {
    if (metrics.length < 2) {
      return null;
    }

    for (final metric in metrics.skip(1)) {
      final value = selector(metric);
      if (value != null) {
        return value;
      }
    }
    return null;
  }

  double? _calculateDelta(double? current, double? previous) {
    if (current == null || previous == null) {
      return null;
    }
    return current - previous;
  }

  Widget _buildHistoryList(
    BuildContext context,
    FittinTheme theme,
    List<BodyMetric> metrics,
    AppStrings strings,
  ) {
    if (metrics.isEmpty) {
      return DashboardSurfaceCard(
        radius: 24,
        padding: const EdgeInsets.all(18),
        child: Text(
          strings.bodyMeasurementLogEmpty,
          style: theme.uiStyle(14, theme.fgDim),
        ),
      );
    }

    return FittinCard(
      theme: theme,
      noPad: true,
      child: Column(
        children: [
          for (var i = 0; i < metrics.length; i++)
            _HistoryEntry(
              theme: theme,
              metric: metrics[i],
              strings: strings,
              showDivider: i < metrics.length - 1,
            ),
        ],
      ),
    );
  }

  void _showAddMetricDialog(BuildContext context, FittinTheme theme) {
    final container = ProviderScope.containerOf(context);
    final weightController = TextEditingController();
    final bodyFatController = TextEditingController();
    final waistController = TextEditingController();
    final noteController = TextEditingController();

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        final strings = AppStrings.fromLocale(
          container.read(appLocaleProvider),
        );
        return AlertDialog(
          backgroundColor: theme.surface,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(theme.radius),
            side: BorderSide(color: theme.border),
          ),
          title: Text(
            strings.addMeasurementTitle,
            style: theme.displayStyle(22, theme.fg),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _MetricTextField(
                  controller: weightController,
                  label: strings.weightKgLabel,
                ),
                const SizedBox(height: 12),
                _MetricTextField(
                  controller: bodyFatController,
                  label: strings.bodyFatLabel,
                ),
                const SizedBox(height: 12),
                _MetricTextField(
                  controller: waistController,
                  label: strings.waistCmLabel,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: noteController,
                  minLines: 2,
                  maxLines: 3,
                  decoration: InputDecoration(labelText: strings.noteOptional),
                  style: theme.uiStyle(14, theme.fg),
                ),
              ],
            ),
          ),
          actions: [
            FittinBtn(
              theme,
              strings.cancel,
              size: 'sm',
              variant: 'secondary',
              onPressed: () => Navigator.pop(dialogContext),
            ),
            FittinBtn(
              theme,
              strings.save,
              size: 'sm',
              onPressed: () {
                final weight = double.tryParse(weightController.text);
                final bodyFat = double.tryParse(bodyFatController.text);
                final waist = double.tryParse(waistController.text);
                final note = noteController.text.trim();

                if (weight == null &&
                    bodyFat == null &&
                    waist == null &&
                    note.isEmpty) {
                  Navigator.pop(dialogContext);
                  return;
                }

                container
                    .read(bodyMetricsProvider.notifier)
                    .addMetric(
                      weight: weight,
                      bodyFat: bodyFat,
                      waist: waist,
                      note: note.isEmpty ? null : note,
                    );
                Navigator.pop(dialogContext);
              },
            ),
          ],
        );
      },
    );
  }
}

enum _BodyMetricsScreenState {
  empty,
  partial,
  populated;

  factory _BodyMetricsScreenState.fromMetrics(List<BodyMetric> metrics) {
    if (metrics.isEmpty) {
      return _BodyMetricsScreenState.empty;
    }

    final latest = metrics.first;
    final hasWeight = latest.weightKg != null;
    final hasBodyFat = latest.bodyFatPercent != null;
    final hasWaist = latest.waistCm != null;
    final hasTrendContext = metrics
        .skip(1)
        .any(
          (metric) =>
              metric.weightKg != null ||
              metric.bodyFatPercent != null ||
              metric.waistCm != null,
        );

    if (hasWeight && hasBodyFat && hasWaist && hasTrendContext) {
      return _BodyMetricsScreenState.populated;
    }

    return _BodyMetricsScreenState.partial;
  }
}

class _BodyMetricsHeroEmptyState extends StatelessWidget {
  const _BodyMetricsHeroEmptyState({
    required this.theme,
    required this.title,
    required this.body,
    required this.actionLabel,
    required this.onPressed,
  });

  final FittinTheme theme;
  final String title;
  final String body;
  final String actionLabel;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return DashboardSurfaceCard(
      key: const ValueKey('body-empty-hero'),
      radius: 24,
      padding: const EdgeInsets.all(18),
      highlight: true,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.06),
            ),
            alignment: Alignment.center,
            child: Icon(Icons.timeline_rounded, color: theme.accent, size: 19),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme
                      .uiStyle(16, theme.fg)
                      .copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 6),
                Text(
                  body,
                  style: theme.uiStyle(12, theme.fgDim).copyWith(height: 1.4),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                FittinBtn(
                  theme,
                  actionLabel,
                  icon: Icons.add_rounded,
                  size: 'sm',
                  variant: 'secondary',
                  onPressed: onPressed,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.theme,
    required this.strings,
    required this.label,
    required this.latestValue,
    required this.previousValue,
    required this.unit,
  });

  final FittinTheme theme;
  final AppStrings strings;
  final String label;
  final double? latestValue;
  final double? previousValue;
  final String unit;

  @override
  Widget build(BuildContext context) {
    final delta = latestValue == null || previousValue == null
        ? null
        : latestValue! - previousValue!;
    final caption = latestValue == null
        ? strings.addThisMetricNextCheckIn
        : delta == null
        ? strings.comparisonNotAvailableYet
        : strings.bodyMetricChangeVsPrevious(delta, unit);

    return DashboardSurfaceCard(
      radius: theme.radiusSm,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme
                .uiStyle(9, theme.fgMuted)
                .copyWith(fontWeight: FontWeight.w700, letterSpacing: 1),
          ),
          const Spacer(),
          FittinBigNum(
            theme,
            latestValue == null
                ? '--'
                : latestValue!.toStringAsFixed(unit.isEmpty ? 0 : 1),
            unit: unit.isEmpty ? null : unit,
            size: 22,
          ),
          const SizedBox(height: 6),
          if (delta != null)
            SizedBox(
              width: double.infinity,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: FittinDelta(
                  theme,
                  delta,
                  unit: unit.isEmpty ? '' : ' $unit',
                ),
              ),
            )
          else
            Text(
              caption,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.uiStyle(11, theme.fgDim),
            ),
        ],
      ),
    );
  }
}

class _HistoryEntry extends StatelessWidget {
  const _HistoryEntry({
    required this.theme,
    required this.metric,
    required this.strings,
    required this.showDivider,
  });

  final FittinTheme theme;
  final BodyMetric metric;
  final AppStrings strings;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final recordedItems = <String>[
      if (metric.weightKg != null) strings.kilograms(metric.weightKg!),
      if (metric.bodyFatPercent != null)
        strings.bodyFatHistoryValue(metric.bodyFatPercent!),
      if (metric.waistCm != null) strings.waistHistoryValue(metric.waistCm!),
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        border: showDivider
            ? Border(bottom: BorderSide(color: theme.border, width: 0.5))
            : null,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 64,
            child: Text(
              strings.shortMonthDay(metric.timestamp),
              style: theme.numStyle(12, theme.fgMuted),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (recordedItems.isNotEmpty) ...[
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: recordedItems
                        .map((item) => _HistoryPill(label: item))
                        .toList(),
                  ),
                ],
                if (metric.note != null && metric.note!.trim().isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    metric.note!,
                    style: theme.uiStyle(12, theme.fgDim).copyWith(height: 1.4),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 12),
          IconButton(
            tooltip: strings.deleteMeasurement,
            icon: const Icon(Icons.delete_outline, size: 20),
            onPressed: () => ProviderScope.containerOf(
              context,
            ).read(bodyMetricsProvider.notifier).deleteMetric(metric.metricId),
          ),
        ],
      ),
    );
  }
}

class _HistoryPill extends StatelessWidget {
  const _HistoryPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: Colors.white.withValues(alpha: 0.05),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: Colors.white.withValues(alpha: 0.72),
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _MetricTextField extends StatelessWidget {
  const _MetricTextField({required this.controller, required this.label});

  final TextEditingController controller;
  final String label;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(labelText: label),
      style: const TextStyle(color: Colors.white),
    );
  }
}
