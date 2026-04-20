import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fittin_v2/src/application/fittin_theme_provider.dart';
import 'package:fittin_v2/src/application/progress_analytics_provider.dart';
import 'package:fittin_v2/src/application/progress_service.dart';
import 'package:fittin_v2/src/presentation/localization/app_strings.dart';
import 'package:fittin_v2/src/presentation/widgets/chart_container.dart';
import 'package:fittin_v2/src/presentation/widgets/charts/step_chart.dart';
import 'package:fittin_v2/src/presentation/widgets/dashboard_primitives.dart';
import 'package:fittin_v2/src/presentation/widgets/fittin_primitives.dart';
import 'package:fittin_v2/src/presentation/theme/fittin_theme.dart' show FittinTheme;

class ExerciseDeepDiveScreen extends ConsumerWidget {
  const ExerciseDeepDiveScreen({super.key, required this.summary});
  final ExerciseProgressSummary summary;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fittinTheme = ref.watch(resolvedFittinThemeProvider);
    final progressService = ref.watch(progressServiceProvider);
    final strings = AppStrings.of(context, ref);

    return Scaffold(
      backgroundColor: Colors.black,
      body: DashboardPageScaffold(
        children: [
          Row(
            children: [
              FittinBtn(
                fittinTheme,
                'Progress',
                variant: 'ghost',
                size: 'sm',
                icon: Icons.chevron_left_rounded,
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
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  strings.isChinese ? 'kg · 预估 1RM' : 'kg · estimated 1RM',
                  style: fittinTheme.uiStyle(13, fittinTheme.fgDim),
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
                  'E1RM',
                  style: theme.uiStyle(10, theme.fgMuted).copyWith(
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
                  style: theme.uiStyle(10, theme.fgMuted).copyWith(
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
                  style: theme.uiStyle(10, theme.fgMuted).copyWith(
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

    // Extract e1rm, e3rm, e5rm data series
    final e1rmData = recent.map((e) => e.value).toList();
    final e3rmData = recent.map((e) => service.calculateNRM(e.value, 3) ?? 0.0).toList();
    final e5rmData = recent.map((e) => service.calculateNRM(e.value, 5) ?? 0.0).toList();

    // Compute y-axis labels
    final allValues = [...e1rmData, ...e3rmData, ...e5rmData];
    final minVal = allValues.reduce((a, b) => a < b ? a : b) * 0.9;
    final maxVal = allValues.reduce((a, b) => a > b ? a : b) * 1.05;
    final yLabels = [
      strings.chartAxisWeight(minVal.toStringAsFixed(0)),
      strings.chartAxisWeight(((minVal + maxVal) / 2).toStringAsFixed(0)),
      strings.chartAxisWeight(maxVal.toStringAsFixed(0)),
    ];

    return ChartContainer(
      title: strings.strengthTrendsOverlay,
      height: 220,
      headerAction: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _LegendDot(color: theme.accent, label: '1RM'),
          const SizedBox(width: 10),
          _LegendDot(color: theme.fgMuted, label: '3RM'),
          const SizedBox(width: 10),
          _LegendDot(color: theme.fgDim, label: '5RM'),
        ],
      ),
      child: Stack(
        children: [
          // 5RM - most transparent
          Opacity(
            opacity: 0.5,
            child: StepChart(
              theme,
              e5rmData,
              height: 180,
              showDots: false,
              showGrid: false,
              yLabels: [],
            ),
          ),
          // 3RM - medium opacity
          Opacity(
            opacity: 0.7,
            child: StepChart(
              theme,
              e3rmData,
              height: 180,
              showDots: false,
              showGrid: false,
              yLabels: [],
            ),
          ),
          // 1RM - full opacity with grid
          StepChart(
            theme,
            e1rmData,
            height: 180,
            showDots: true,
            showGrid: true,
            yLabels: yLabels,
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryList(
    BuildContext context,
    AppStrings strings,
    FittinTheme theme,
  ) {
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
                        style: theme.uiStyle(14, theme.fg).copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${strings.kilograms(point.weight)} × ${point.reps}',
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
                      style: theme.numStyle(18, theme.fg).copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      'E1RM',
                      style: theme.uiStyle(10, theme.fgMuted).copyWith(
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
              BoxShadow(color: color.withValues(alpha: 0.4), blurRadius: 4),
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
