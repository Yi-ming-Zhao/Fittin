import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fittin_v2/src/application/advanced_analytics_provider.dart';
import 'package:fittin_v2/src/presentation/widgets/chart_container.dart';
import 'package:fittin_v2/src/presentation/widgets/charts/heatmap_painter.dart';
import 'package:fittin_v2/src/presentation/widgets/charts/muscle_distribution_painter.dart';
import 'package:fittin_v2/src/presentation/widgets/dashboard_primitives.dart';

class AdvancedAnalyticsScreen extends ConsumerWidget {
  const AdvancedAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dataAsync = ref.watch(advancedAnalyticsDataProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      body: dataAsync.when(
        data: (data) => DashboardPageScaffold(
          children: [
            const DashboardScreenHeader(
              eyebrow: 'INSIGHTS',
              title: 'Trends & Analytics',
              subtitle: 'Advanced training metrics and consistency visualization.',
            ),
            const SizedBox(height: 24),
            _buildHeatmap(context, data),
            const SizedBox(height: 24),
            _buildVolumeDistribution(context, data),
            const SizedBox(height: 32),
            _buildAnatomicalHighlight(context),
            const SizedBox(height: 80),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildHeatmap(BuildContext context, AdvancedAnalyticsData data) {
    return ChartContainer(
      title: 'Training Consistency (90 Days)',
      height: 140,
      child: CustomPaint(
        painter: HeatmapPainter(
          activityData: data.heatmapData,
          activeColor: Colors.greenAccent,
        ),
        size: Size.infinite,
      ),
    );
  }

  Widget _buildVolumeDistribution(BuildContext context, AdvancedAnalyticsData data) {
    return ChartContainer(
      title: 'Muscle Training Load (Sets/Week)',
      height: 220,
      child: CustomPaint(
        painter: MuscleDistributionPainter(data: data.volumeData),
        size: Size.infinite,
      ),
    );
  }

  Widget _buildAnatomicalHighlight(BuildContext context) {
    final theme = Theme.of(context);
    return DashboardSurfaceCard(
      radius: 28,
      highlight: true,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 16),
          ShaderMask(
            shaderCallback: (bounds) => LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                theme.colorScheme.primary.withValues(alpha: 0.3),
                theme.colorScheme.primary.withValues(alpha: 0.05),
              ],
            ).createShader(bounds),
            child: const Icon(Icons.accessibility_new_rounded, size: 100, color: Colors.white),
          ),
          const SizedBox(height: 16),
          Text(
            'ANATOMICAL LOAD MAP',
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.bold,
              letterSpacing: 1.8,
              color: Colors.white.withValues(alpha: 0.44),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'High-resolution muscle activation overlay\ncoming in a future update.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.white.withValues(alpha: 0.25),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
