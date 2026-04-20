import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fittin_v2/src/application/fittin_theme_provider.dart';

class WeeklyProgressBarChart extends ConsumerWidget {
  /// The maximum value across the week to determine 100% height
  final double maxValue;

  /// A list of 7 values, one for each day (e.g., Monday to Sunday)
  final List<double> weeklyData;

  /// 0-indexed integer indicating today (e.g. 1 means Tuesday if Mon-is-0)
  final int todayIndex;

  final double barWidth;
  final double maxHeight;

  const WeeklyProgressBarChart({
    super.key,
    required this.maxValue,
    required this.weeklyData,
    required this.todayIndex,
    this.barWidth = 8.0,
    this.maxHeight = 80.0,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (weeklyData.length != 7) return const SizedBox.shrink();

    final fittinTheme = ref.watch(resolvedFittinThemeProvider);
    final days = const ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end, // Line up at bottom
      children: List.generate(7, (index) {
        final isToday = index == todayIndex;
        final val = weeklyData[index];
        final fraction = maxValue > 0 ? (val / maxValue).clamp(0.0, 1.0) : 0.0;
        final barHeight = fraction * maxHeight;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Container that gives the neon pill look
            Container(
              height: maxHeight,
              width: barWidth,
              alignment: Alignment.bottomCenter,
              decoration: BoxDecoration(
                color: fittinTheme.fg.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(barWidth / 2),
              ),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeOutQuart,
                height: barHeight,
                width: barWidth,
                decoration: BoxDecoration(
                  color: isToday
                      ? fittinTheme.accent
                      : fittinTheme.accent.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(barWidth / 2),
                  boxShadow: isToday
                      ? [
                          BoxShadow(
                            color: fittinTheme.accent.withValues(alpha: 0.6),
                            blurRadius: 8.0,
                            spreadRadius: -2.0,
                          ),
                        ]
                      : null,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              days[index],
              style: fittinTheme.uiStyle(11, isToday ? fittinTheme.accent : fittinTheme.fgMuted).copyWith(
                fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        );
      }),
    );
  }
}
