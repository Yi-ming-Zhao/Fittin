import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fittin_v2/src/application/body_metrics_provider.dart';
import 'package:fittin_v2/src/domain/models/body_metric.dart';
import 'package:fittin_v2/src/presentation/localization/app_strings.dart';
import 'package:fittin_v2/src/presentation/widgets/chart_container.dart';
import 'package:fittin_v2/src/presentation/widgets/charts/line_chart_painter.dart';
import 'package:fittin_v2/src/presentation/widgets/dashboard_primitives.dart';

class BodyMetricsScreen extends ConsumerWidget {
  const BodyMetricsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final metricsAsync = ref.watch(bodyMetricsProvider);
    final strings = AppStrings.of(context, ref);

    return Scaffold(
      backgroundColor: Colors.black,
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddMetricDialog(context, ref),
        backgroundColor: Colors.white,
        child: const Icon(Icons.add, color: Colors.black),
      ),
      body: metricsAsync.when(
        data: (metrics) {
          final latest = metrics.firstOrNull;
          final screenState = _BodyMetricsScreenState.fromMetrics(metrics);

          return DashboardPageScaffold(
            bottomPadding: 100,
            children: [
              DashboardScreenHeader(
                eyebrow: strings.composition,
                title: strings.bodyMetrics,
                subtitle: strings.bodyMetricsSubtitle,
              ),
              const SizedBox(height: 24),
              _buildHeroCard(context, ref, metrics, screenState),
              const SizedBox(height: 24),
              _buildStateCallout(context, ref, screenState, latest),
              const SizedBox(height: 24),
              DashboardSectionLabel(label: strings.currentSnapshot),
              const SizedBox(height: 16),
              _buildMetricGrid(context, metrics, strings),
              const SizedBox(height: 32),
              DashboardSectionLabel(label: strings.measurementLog),
              const SizedBox(height: 16),
              _buildHistoryList(context, metrics, ref, strings),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildHeroCard(
    BuildContext context,
    WidgetRef ref,
    List<BodyMetric> metrics,
    _BodyMetricsScreenState screenState,
  ) {
    final weightedMetrics = metrics
        .where((metric) => metric.weightKg != null)
        .toList();
    final strings = AppStrings.of(context, ref);
    if (weightedMetrics.isNotEmpty) {
      return _buildWeightChart(context, weightedMetrics, screenState, strings);
    }

    return _BodyMetricsHeroEmptyState(
      strings: strings,
      title: screenState == _BodyMetricsScreenState.empty
          ? strings.recordFirstCheckIn
          : strings.noWeightTrendYet,
      body: screenState == _BodyMetricsScreenState.empty
          ? strings.bodyMetricsHeroEmptyBody
          : strings.bodyMetricsHeroPartialBody,
      actionLabel: screenState == _BodyMetricsScreenState.empty
          ? strings.addFirstMeasurement
          : strings.addCompleteMeasurement,
      onPressed: () => _showAddMetricDialog(context, ref),
    );
  }

  Widget _buildWeightChart(
    BuildContext context,
    List<BodyMetric> weightedMetrics,
    _BodyMetricsScreenState screenState,
    AppStrings strings,
  ) {
    final recent = weightedMetrics.length > 10
        ? weightedMetrics.sublist(0, 10).reversed.toList()
        : weightedMetrics.reversed.toList();
    final weightPoints = <Offset>[];

    final weights = recent.map((m) => m.weightKg!).toList();
    final minVal = weights.reduce((a, b) => a < b ? a : b) * 0.95;
    final maxVal = weights.reduce((a, b) => a > b ? a : b) * 1.05;
    final range = maxVal - minVal;

    for (int i = 0; i < recent.length; i++) {
      final dx = recent.length == 1 ? 0.5 : i / (recent.length - 1);
      final dy = range == 0 ? 0.5 : (recent[i].weightKg! - minVal) / range;
      weightPoints.add(Offset(dx, dy));
    }

    final latestWeight = weightedMetrics.first.weightKg!;
    final previousWeight = weightedMetrics.length > 1
        ? weightedMetrics[1].weightKg
        : null;
    final delta = _calculateDelta(latestWeight, previousWeight);
    final date = strings.shortMonthDay(weightedMetrics.first.timestamp);
    final headline = delta == null
        ? strings.latestWeightOn(latestWeight, date)
        : strings.latestWeightDelta(latestWeight, _formatDelta(delta, 'kg'));
    final supportLine = screenState == _BodyMetricsScreenState.partial
        ? strings.completeMetricsHint
        : strings.weightTrendAnchorHint;

    return ChartContainer(
      title: strings.weightProgression,
      height: 180,
      headerAction: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            headline,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Text(
            supportLine,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.white.withValues(alpha: 0.64),
              height: 1.35,
            ),
          ),
        ],
      ),
      child: LineChartPainter(
        datasets: [
          LineChartDataset(
            points: weightPoints,
            color: Colors.orangeAccent,
            label: 'Weight',
          ),
        ],
      ).toWidget(),
    );
  }

  Widget _buildStateCallout(
    BuildContext context,
    WidgetRef ref,
    _BodyMetricsScreenState screenState,
    BodyMetric? latest,
  ) {
    final strings = AppStrings.of(context, ref);
    if (screenState == _BodyMetricsScreenState.populated) {
      return const SizedBox.shrink();
    }

    final title = screenState == _BodyMetricsScreenState.empty
        ? strings.noBodyMeasurementsYet
        : strings.latestCheckInIncomplete;
    final body = screenState == _BodyMetricsScreenState.empty
        ? strings.emptyMeasurementsCallout
        : strings.partialMeasurementsCallout;
    final actionLabel = screenState == _BodyMetricsScreenState.empty
        ? strings.addMeasurement
        : strings.completeLatestSnapshot;
    final footer = latest == null
        ? strings.noRecordedEntries
        : strings.latestEntry(latest.timestamp);

    return DashboardSurfaceCard(
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
              color: Colors.white.withValues(alpha: 0.08),
            ),
            alignment: Alignment.center,
            child: Icon(
              screenState == _BodyMetricsScreenState.empty
                  ? Icons.insights_outlined
                  : Icons.edit_note_rounded,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  body,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.7),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    FilledButton.tonalIcon(
                      onPressed: () => _showAddMetricDialog(context, ref),
                      icon: const Icon(Icons.add_rounded),
                      label: Text(actionLabel),
                    ),
                    Text(
                      footer,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white.withValues(alpha: 0.52),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricGrid(
    BuildContext context,
    List<BodyMetric> metrics,
    AppStrings strings,
  ) {
    final latest = metrics.firstOrNull;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 640;
        return GridView.count(
          crossAxisCount: isWide ? 2 : 1,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: isWide ? 1.7 : 2.6,
          children: [
            _MetricCard(
              strings: strings,
              label: strings.bodyFat,
              latestValue: latest?.bodyFatPercent,
              previousValue: _findPreviousComparable(
                metrics,
                (metric) => metric.bodyFatPercent,
              ),
              unit: '%',
              color: Colors.cyanAccent,
            ),
            _MetricCard(
              strings: strings,
              label: strings.waist,
              latestValue: latest?.waistCm,
              previousValue: _findPreviousComparable(
                metrics,
                (metric) => metric.waistCm,
              ),
              unit: 'cm',
              color: Colors.purpleAccent,
            ),
          ],
        );
      },
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

  String _formatDelta(double delta, String unit) {
    final sign = delta > 0 ? '+' : '';
    return '$sign${delta.toStringAsFixed(1)} $unit';
  }

  Widget _buildHistoryList(
    BuildContext context,
    List<BodyMetric> metrics,
    WidgetRef ref,
    AppStrings strings,
  ) {
    if (metrics.isEmpty) {
      return DashboardSurfaceCard(
        radius: 24,
        padding: const EdgeInsets.all(18),
        child: Text(
          strings.bodyMeasurementLogEmpty,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.white.withValues(alpha: 0.64),
          ),
        ),
      );
    }

    return Column(
      children: metrics
          .map(
            (metric) =>
                _HistoryEntry(metric: metric, ref: ref, strings: strings),
          )
          .toList(),
    );
  }

  void _showAddMetricDialog(BuildContext context, WidgetRef ref) {
    final weightController = TextEditingController();
    final bodyFatController = TextEditingController();
    final waistController = TextEditingController();
    final noteController = TextEditingController();

    showDialog<void>(
      context: context,
      builder: (context) {
        final strings = AppStrings.of(context, ref);
        return AlertDialog(
          backgroundColor: const Color(0xFF111111),
          title: Text(strings.addMeasurementTitle),
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
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(strings.cancel),
            ),
            ElevatedButton(
              onPressed: () {
                final weight = double.tryParse(weightController.text);
                final bodyFat = double.tryParse(bodyFatController.text);
                final waist = double.tryParse(waistController.text);
                final note = noteController.text.trim();

                if (weight == null &&
                    bodyFat == null &&
                    waist == null &&
                    note.isEmpty) {
                  Navigator.pop(context);
                  return;
                }

                ref
                    .read(bodyMetricsProvider.notifier)
                    .addMetric(
                      weight: weight,
                      bodyFat: bodyFat,
                      waist: waist,
                      note: note.isEmpty ? null : note,
                    );
                Navigator.pop(context);
              },
              child: Text(strings.save),
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
    required this.strings,
    required this.title,
    required this.body,
    required this.actionLabel,
    required this.onPressed,
  });

  final AppStrings strings;
  final String title;
  final String body;
  final String actionLabel;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return ChartContainer(
      title: strings.progressSurface,
      height: 180,
      headerAction: Text(
        strings.heroAreaIntentionalHint,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Colors.white.withValues(alpha: 0.62),
          height: 1.35,
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.white.withValues(alpha: 0.035),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.08),
              ),
              child: const Icon(Icons.timeline_rounded, color: Colors.white),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    body,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white.withValues(alpha: 0.68),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 14),
                  FilledButton.tonalIcon(
                    onPressed: onPressed,
                    icon: const Icon(Icons.add_rounded),
                    label: Text(actionLabel),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.strings,
    required this.label,
    required this.latestValue,
    required this.previousValue,
    required this.unit,
    required this.color,
  });

  final AppStrings strings;
  final String label;
  final double? latestValue;
  final double? previousValue;
  final String unit;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final delta = latestValue == null || previousValue == null
        ? null
        : latestValue! - previousValue!;
    final value = latestValue == null
        ? strings.notYetRecorded
        : '${latestValue!.toStringAsFixed(1)} $unit';
    final caption = latestValue == null
        ? strings.addThisMetricNextCheckIn
        : delta == null
        ? strings.comparisonNotAvailableYet
        : strings.bodyMetricChangeVsPrevious(delta, unit);

    return DashboardSurfaceCard(
      radius: 24,
      padding: const EdgeInsets.all(18),
      highlight: delta != null && delta < 0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(shape: BoxShape.circle, color: color),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: Colors.white.withValues(alpha: 0.58),
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
              height: 1,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            caption,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.white.withValues(alpha: 0.64),
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryEntry extends StatelessWidget {
  const _HistoryEntry({
    required this.metric,
    required this.ref,
    required this.strings,
  });

  final BodyMetric metric;
  final WidgetRef ref;
  final AppStrings strings;

  @override
  Widget build(BuildContext context) {
    final recordedItems = <String>[
      if (metric.weightKg != null) '${metric.weightKg!.toStringAsFixed(1)} kg',
      if (metric.bodyFatPercent != null)
        '${metric.bodyFatPercent!.toStringAsFixed(1)}%',
      if (metric.waistCm != null)
        '${metric.waistCm!.toStringAsFixed(1)} cm ${strings.waistSuffix}',
    ];

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DashboardSurfaceCard(
        radius: 22,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    strings.longDate(metric.timestamp),
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    strings.weekdayName(metric.timestamp),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white.withValues(alpha: 0.46),
                    ),
                  ),
                  if (recordedItems.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: recordedItems
                          .map((item) => _HistoryPill(label: item))
                          .toList(),
                    ),
                  ],
                  if (metric.note != null &&
                      metric.note!.trim().isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Text(
                      metric.note!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white.withValues(alpha: 0.68),
                        height: 1.4,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 12),
            IconButton(
              tooltip: strings.deleteMeasurement,
              icon: const Icon(Icons.delete_outline, size: 20),
              onPressed: () => ref
                  .read(bodyMetricsProvider.notifier)
                  .deleteMetric(metric.metricId),
            ),
          ],
        ),
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

extension on LineChartPainter {
  Widget toWidget() => CustomPaint(painter: this, size: Size.infinite);
}
