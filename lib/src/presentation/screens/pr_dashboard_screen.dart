import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fittin_v2/src/application/pr_dashboard_provider.dart';
import 'package:fittin_v2/src/application/progress_analytics_provider.dart';
import 'package:fittin_v2/src/presentation/screens/advanced_analytics_screen.dart';
import 'package:fittin_v2/src/presentation/screens/exercise_deep_dive_screen.dart';
import 'package:fittin_v2/src/presentation/widgets/chart_container.dart';
import 'package:fittin_v2/src/presentation/widgets/charts/line_chart_painter.dart';
import 'package:fittin_v2/src/presentation/widgets/dashboard_primitives.dart';
import 'package:intl/intl.dart';

class PRDashboardScreen extends ConsumerWidget {
  const PRDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dataAsync = ref.watch(prDashboardDataProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      body: dataAsync.when(
        data: (data) => DashboardPageScaffold(
          children: [
            const DashboardScreenHeader(
              eyebrow: 'PERFORMANCE',
              title: 'PR Dashboard',
              subtitle: 'Precision tracking of your peak strength benchmarks.',
            ),
            const SizedBox(height: 24),
            _buildQuickStats(context, data),
            const SizedBox(height: 24),
            _buildMainChart(context, data),
            const SizedBox(height: 32),
            DashboardSectionLabel(label: 'RECENT MILESTONES'),
            const SizedBox(height: 16),
            ...data.milestones.map((m) => _MilestoneTile(
              milestone: m,
              onTap: () {
                 final summary = m.summary;
                 if (summary != null) {
                   Navigator.push(context, MaterialPageRoute(builder: (_) => ExerciseDeepDiveScreen(summary: summary)));
                 }
              },
            )),
            const SizedBox(height: 40),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildQuickStats(BuildContext context, PRDashboardData data) {
    return Row(
      children: [
        _StrengthCard(
          summary: data.squat, 
          label: 'SQUAT', 
          color: Colors.redAccent,
          onTap: () => _navigateToDeepDive(context, data.squat),
        ),
        const SizedBox(width: 12),
        _StrengthCard(
          summary: data.bench, 
          label: 'BENCH', 
          color: Colors.blueAccent,
          onTap: () => _navigateToDeepDive(context, data.bench),
        ),
        const SizedBox(width: 12),
        _StrengthCard(
          summary: data.deadlift, 
          label: 'DEADLIFT', 
          color: Colors.greenAccent,
          onTap: () => _navigateToDeepDive(context, data.deadlift),
        ),
      ],
    );
  }

  void _navigateToDeepDive(BuildContext context, ExerciseProgressSummary? summary) {
    if (summary != null) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => ExerciseDeepDiveScreen(summary: summary)));
    }
  }

  Widget _buildMainChart(BuildContext context, PRDashboardData data) {
    final datasets = <LineChartDataset>[];
    
    if (data.squat != null) {
       datasets.add(_buildDataset(data.squat!, Colors.redAccent));
    }
    if (data.bench != null) {
       datasets.add(_buildDataset(data.bench!, Colors.blueAccent));
    }
    if (data.deadlift != null) {
       datasets.add(_buildDataset(data.deadlift!, Colors.greenAccent));
    }

    return ChartContainer(
      title: 'Strength Progression (E1RM)',
      height: 200,
      headerAction: TextButton(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdvancedAnalyticsScreen())),
        child: const Text('DETAILS >', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
      ),
      child: LineChartPainter(datasets: datasets).toWidget(), 
    );
  }

  LineChartDataset _buildDataset(ExerciseProgressSummary summary, Color color) {
    final history = summary.estimatedHistory;
    if (history.isEmpty) return LineChartDataset(points: [], color: color, label: summary.exerciseName);

    final recent = history.length > 8 ? history.sublist(history.length - 8) : history;
    final minVal = recent.map((e) => e.value).reduce((a, b) => a < b ? a : b) * 0.9;
    final maxVal = recent.map((e) => e.value).reduce((a, b) => a > b ? a : b) * 1.1;
    final range = maxVal - minVal;

    final points = <Offset>[];
    for (int i = 0; i < recent.length; i++) {
      final dx = i / (recent.length - 1);
      final dy = range == 0 ? 0.5 : (recent[i].value - minVal) / range;
      points.add(Offset(dx, dy));
    }

    return LineChartDataset(points: points, color: color, label: summary.exerciseName);
  }
}

class _StrengthCard extends StatelessWidget {
  const _StrengthCard({this.summary, required this.label, required this.color, this.onTap});
  final ExerciseProgressSummary? summary;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final change = summary?.recentChange;
    return Expanded(
      child: DashboardStatCard(
        label: label,
        value: summary?.currentEstimatedOneRepMax?.toStringAsFixed(1) ?? '—',
        caption: change != null
            ? '${change >= 0 ? '+' : ''}${change.toStringAsFixed(1)}'
            : null,
        highlight: change != null && change > 0,
      ),
    );
  }
}

class _MilestoneTile extends StatelessWidget {
  const _MilestoneTile({required this.milestone, this.onTap});
  final PRMilestone milestone;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
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
              child: const Icon(Icons.workspace_premium, color: Colors.amberAccent, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(milestone.exerciseName, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                  Text(
                    '${milestone.label}: ${milestone.value.toStringAsFixed(1)} kg',
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 13),
                  ),
                ],
              ),
            ),
            Text(
              DateFormat('MMM d').format(milestone.date),
              style: TextStyle(color: Colors.white.withValues(alpha: 0.3), fontSize: 12),
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
