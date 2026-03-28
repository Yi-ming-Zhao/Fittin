import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:fittin_v2/src/application/progress_analytics_provider.dart';
import 'package:fittin_v2/src/application/progress_service.dart';
import 'package:fittin_v2/src/presentation/localization/app_strings.dart';
import 'package:fittin_v2/src/presentation/widgets/chart_container.dart';
import 'package:fittin_v2/src/presentation/widgets/charts/line_chart_painter.dart';
import 'package:fittin_v2/src/presentation/widgets/dashboard_primitives.dart';

class ExerciseDeepDiveScreen extends ConsumerWidget {
  const ExerciseDeepDiveScreen({super.key, required this.summary});
  final ExerciseProgressSummary summary;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final progressService = ref.watch(progressServiceProvider);
    final strings = AppStrings.of(context, ref);

    return Scaffold(
      backgroundColor: Colors.black,
      body: CustomScrollView(
        slivers: [
          _buildHeroAppBar(context, theme, strings),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  // Quick stats row
                  _buildQuickStats(theme, strings),
                  const SizedBox(height: 24),
                  _buildTrendChart(context, progressService, strings),
                  const SizedBox(height: 32),
                  DashboardSectionLabel(label: strings.sessionHistory),
                  const SizedBox(height: 16),
                  _buildHistoryList(context, strings),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Task 4.3: ExerciseHeroHeader with high-contrast gradient
  Widget _buildHeroAppBar(
    BuildContext context,
    ThemeData theme,
    AppStrings strings,
  ) {
    return SliverAppBar(
      expandedHeight: 260,
      pinned: true,
      backgroundColor: Colors.black,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.black.withValues(alpha: 0.4),
          ),
          child: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
        ),
        onPressed: () => Navigator.pop(context),
      ),
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
        title: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              summary.exerciseName.toUpperCase(),
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w900,
                letterSpacing: 1.5,
                fontSize: 16,
              ),
            ),
            if (summary.currentEstimatedOneRepMax != null)
              Text(
                strings.e1rmLabel(summary.currentEstimatedOneRepMax!),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
          ],
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            // B&W gradient hero background
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    theme.colorScheme.primary.withValues(alpha: 0.15),
                    Colors.black,
                  ],
                ),
              ),
            ),
            // Subtle radial glow at top
            Positioned(
              top: -60,
              right: -30,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      theme.colorScheme.primary.withValues(alpha: 0.12),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            // Bottom fade
            const Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black],
                  ),
                ),
                child: SizedBox(height: 120),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStats(ThemeData theme, AppStrings strings) {
    final current = summary.currentEstimatedOneRepMax;
    final change = summary.recentChange;

    return Row(
      children: [
        Expanded(
          child: DashboardStatCard(
            label: 'E1RM',
            value: current?.toStringAsFixed(1) ?? '—',
            highlight: true,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: DashboardStatCard(
            label: strings.change30d,
            value: change != null
                ? '${change >= 0 ? '+' : ''}${change.toStringAsFixed(1)}'
                : '—',
            caption: change != null && change > 0 ? strings.gaining : null,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: DashboardStatCard(
            label: strings.encounterCount,
            value: '${summary.estimatedHistory.length}',
            caption: strings.totalLogged,
          ),
        ),
      ],
    );
  }

  // Task 4.2: StrengthTrendsOverlayChart showing 1/3/5RM lines
  Widget _buildTrendChart(
    BuildContext context,
    ProgressService service,
    AppStrings strings,
  ) {
    if (summary.estimatedHistory.isEmpty) return const SizedBox.shrink();

    final recent = summary.estimatedHistory.length > 10
        ? summary.estimatedHistory.sublist(summary.estimatedHistory.length - 10)
        : summary.estimatedHistory;

    final e1rmPoints = <Offset>[];
    final e3rmPoints = <Offset>[];
    final e5rmPoints = <Offset>[];

    final minVal = recent.map((e) => e.value).reduce((a, b) => a < b ? a : b) * 0.8;
    final maxVal = recent.map((e) => e.value).reduce((a, b) => a > b ? a : b) * 1.1;
    final range = maxVal - minVal;

    for (int i = 0; i < recent.length; i++) {
      final dx = recent.length > 1 ? i / (recent.length - 1) : 0.5;
      final e1rm = recent[i].value;
      final e3rm = service.calculateNRM(e1rm, 3) ?? 0;
      final e5rm = service.calculateNRM(e1rm, 5) ?? 0;

      final normalizedE1 = range == 0 ? 0.5 : (e1rm - minVal) / range;
      final normalizedE3 = range == 0 ? 0.5 : (e3rm - minVal) / range;
      final normalizedE5 = range == 0 ? 0.5 : (e5rm - minVal) / range;

      e1rmPoints.add(Offset(dx, normalizedE1));
      e3rmPoints.add(Offset(dx, normalizedE3));
      e5rmPoints.add(Offset(dx, normalizedE5));
    }

    return ChartContainer(
      title: strings.strengthTrendsOverlay,
      height: 220,
      headerAction: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _LegendDot(color: Colors.cyanAccent, label: '1RM'),
          const SizedBox(width: 10),
          _LegendDot(color: Colors.purpleAccent, label: '3RM'),
          const SizedBox(width: 10),
          _LegendDot(color: Colors.pinkAccent, label: '5RM'),
        ],
      ),
      child: CustomPaint(
        painter: LineChartPainter(
          datasets: [
            LineChartDataset(points: e1rmPoints, color: Colors.cyanAccent, label: '1RM'),
            LineChartDataset(points: e3rmPoints, color: Colors.purpleAccent, label: '3RM'),
            LineChartDataset(points: e5rmPoints, color: Colors.pinkAccent, label: '5RM'),
          ],
        ),
        size: Size.infinite,
      ),
    );
  }

  Widget _buildHistoryList(BuildContext context, AppStrings strings) {
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
                        DateFormat.yMMMMd(strings.isChinese ? 'zh' : 'en')
                            .format(point.completedAt),
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${strings.kilograms(point.weight)} × ${point.reps}',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.5),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      point.value.toStringAsFixed(1),
                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
                    ),
                    Text(
                      'E1RM',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.0,
                        color: Colors.cyanAccent.withValues(alpha: 0.7),
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

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.4),
                blurRadius: 4,
              ),
            ],
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: Colors.white.withValues(alpha: 0.5),
          ),
        ),
      ],
    );
  }
}
