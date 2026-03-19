import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:fittin_v2/src/application/body_metrics_provider.dart';
import 'package:fittin_v2/src/domain/models/body_metric.dart';
import 'package:fittin_v2/src/presentation/widgets/chart_container.dart';
import 'package:fittin_v2/src/presentation/widgets/charts/line_chart_painter.dart';
import 'package:fittin_v2/src/presentation/widgets/dashboard_primitives.dart';

class BodyMetricsScreen extends ConsumerWidget {
  const BodyMetricsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final metricsAsync = ref.watch(bodyMetricsProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddMetricDialog(context, ref),
        backgroundColor: Colors.white,
        child: const Icon(Icons.add, color: Colors.black),
      ),
      body: metricsAsync.when(
        data: (metrics) => DashboardPageScaffold(
          children: [
            const DashboardScreenHeader(
              eyebrow: 'COMPOSITION',
              title: 'Body Metrics',
              subtitle: 'Track your physical transformation beyond the barbell.',
            ),
            const SizedBox(height: 24),
            _buildWeightChart(context, metrics),
            const SizedBox(height: 24),
            DashboardSectionLabel(label: 'CURRENT VITALS'),
            const SizedBox(height: 16),
            _buildMetricGrid(context, metrics),
            const SizedBox(height: 32),
            DashboardSectionLabel(label: 'MEASUREMENT LOG'),
            const SizedBox(height: 16),
            _buildHistoryList(context, metrics, ref),
            const SizedBox(height: 80),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildWeightChart(BuildContext context, List<BodyMetric> metrics) {
    if (metrics.isEmpty) return const SizedBox.shrink();

    final recent = metrics.length > 10 ? metrics.sublist(0, 10).reversed.toList() : metrics.reversed.toList();
    final weightPoints = <Offset>[];

    final weights = recent.where((m) => m.weightKg != null).map((m) => m.weightKg!).toList();
    if (weights.isEmpty) return const SizedBox.shrink();

    final minVal = weights.reduce((a, b) => a < b ? a : b) * 0.95;
    final maxVal = weights.reduce((a, b) => a > b ? a : b) * 1.05;
    final range = maxVal - minVal;

    for (int i = 0; i < recent.length; i++) {
      final dx = i / (recent.length - 1);
      final dy = range == 0 ? 0.5 : (recent[i].weightKg! - minVal) / range;
      weightPoints.add(Offset(dx, dy));
    }

    return ChartContainer(
      title: 'Weight Progression (KG)',
      height: 180,
      child: LineChartPainter(
        datasets: [
          LineChartDataset(points: weightPoints, color: Colors.orangeAccent, label: 'Weight'),
        ],
      ).toWidget(),
    );
  }

  Widget _buildMetricGrid(BuildContext context, List<BodyMetric> metrics) {
    final latest = metrics.firstOrNull;
    final previous = metrics.length > 1 ? metrics[1] : null;

    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.4,
      children: [
        _MetricCard(
          label: 'BODY FAT',
          value: latest?.bodyFatPercent?.toStringAsFixed(1) ?? '—',
          unit: '%',
          delta: _calculateDelta(latest?.bodyFatPercent, previous?.bodyFatPercent),
          color: Colors.cyanAccent,
        ),
        _MetricCard(
          label: 'WAIST',
          value: latest?.waistCm?.toStringAsFixed(1) ?? '—',
          unit: 'cm',
          delta: _calculateDelta(latest?.waistCm, previous?.waistCm),
          color: Colors.purpleAccent,
        ),
      ],
    );
  }

  double? _calculateDelta(double? current, double? prev) {
    if (current == null || prev == null) return null;
    return current - prev;
  }

  Widget _buildHistoryList(BuildContext context, List<BodyMetric> metrics, WidgetRef ref) {
    return Column(
      children: metrics.map((m) => _HistoryEntry(metric: m, ref: ref)).toList(),
    );
  }

  void _showAddMetricDialog(BuildContext context, WidgetRef ref) {
    // Basic dialog for weight entry
    final weightController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF111111),
        title: const Text('Add Measurement'),
        content: TextField(
          controller: weightController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Weight (kg)'),
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final w = double.tryParse(weightController.text);
              if (w != null) {
                ref.read(bodyMetricsProvider.notifier).addMetric(weight: w);
              }
              Navigator.pop(context);
            },
            child: const Text('Save'),
          )
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.label, required this.value, required this.unit, this.delta, required this.color});
  final String label;
  final String value;
  final String unit;
  final double? delta;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return DashboardStatCard(
      label: label,
      value: '$value$unit',
      caption: delta != null
          ? '${delta! >= 0 ? '+' : ''}${delta!.toStringAsFixed(1)}$unit'
          : null,
      highlight: delta != null && delta! < 0, // Green highlight for weight/fat loss
    );
  }
}

class _HistoryEntry extends StatelessWidget {
  const _HistoryEntry({required this.metric, required this.ref});
  final BodyMetric metric;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DashboardSurfaceCard(
        radius: 22,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Text('${metric.weightKg ?? '—'} kg', style: const TextStyle(fontWeight: FontWeight.w700)),
                   Text(
                     DateFormat('yyyy-MM-dd').format(metric.timestamp),
                     style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 12),
                   ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 20),
              onPressed: () => ref.read(bodyMetricsProvider.notifier).deleteMetric(metric.metricId),
            ),
          ],
        ),
      ),
    );
  }
}

extension on LineChartPainter {
  Widget toWidget() => CustomPaint(painter: this, size: Size.infinite);
}
