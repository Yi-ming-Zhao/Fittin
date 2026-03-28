import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fittin_v2/src/application/advanced_analytics_provider.dart';
import 'package:fittin_v2/src/presentation/localization/app_strings.dart';
import 'package:fittin_v2/src/presentation/screens/workout_record_detail_screen.dart';
import 'package:fittin_v2/src/presentation/widgets/chart_container.dart';
import 'package:fittin_v2/src/presentation/widgets/charts/muscle_distribution_painter.dart';
import 'package:fittin_v2/src/presentation/widgets/dashboard_primitives.dart';

class AdvancedAnalyticsScreen extends ConsumerStatefulWidget {
  const AdvancedAnalyticsScreen({super.key});

  @override
  ConsumerState<AdvancedAnalyticsScreen> createState() =>
      _AdvancedAnalyticsScreenState();
}

class _AdvancedAnalyticsScreenState
    extends ConsumerState<AdvancedAnalyticsScreen> {
  ConsistencyRange _selectedRange = ConsistencyRange.week;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context, ref);
    final dataAsync = ref.watch(advancedAnalyticsDataProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      body: dataAsync.when(
        data: (data) => DashboardPageScaffold(
          children: [
            DashboardScreenHeader(
              eyebrow: strings.insights,
              title: strings.advancedAnalytics,
              subtitle: strings.advancedAnalyticsSubtitle,
              showBackButton: true,
            ),
            const SizedBox(height: 24),
            _ConsistencyExplorer(
              range: _selectedRange,
              data: data,
              onRangeChanged: (value) {
                setState(() {
                  _selectedRange = value;
                });
              },
            ),
            const SizedBox(height: 24),
            _buildVolumeDistribution(context, strings, data),
            const SizedBox(height: 32),
            _buildAnatomicalHighlight(context, strings),
            const SizedBox(height: 80),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildVolumeDistribution(
    BuildContext context,
    AppStrings strings,
    AdvancedAnalyticsData data,
  ) {
    return ChartContainer(
      title: strings.muscleTrainingLoad,
      height: 220,
      child: CustomPaint(
        painter: MuscleDistributionPainter(data: data.volumeData),
        size: Size.infinite,
      ),
    );
  }

  Widget _buildAnatomicalHighlight(BuildContext context, AppStrings strings) {
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
            child: const Icon(
              Icons.accessibility_new_rounded,
              size: 100,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            strings.anatomicalLoadMap,
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.bold,
              letterSpacing: 1.8,
              color: Colors.white.withValues(alpha: 0.44),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            strings.anatomicalLoadPlaceholder,
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

class _ConsistencyExplorer extends ConsumerWidget {
  const _ConsistencyExplorer({
    required this.range,
    required this.data,
    required this.onRangeChanged,
  });

  final ConsistencyRange range;
  final AdvancedAnalyticsData data;
  final ValueChanged<ConsistencyRange> onRangeChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppStrings.of(context, ref);
    final sections = data.sectionsByRange[range] ?? const [];
    final contentHeight = 78.0 + (sections.length * 56.0);

    return ChartContainer(
      title: strings.trainingConsistency,
      height: sections.isEmpty ? 140 : contentHeight,
      headerAction: _RangeSelector(
        selected: range,
        onChanged: onRangeChanged,
      ),
      child: sections.isEmpty
          ? Center(
              child: Text(
                strings.noConsistencyRecords,
                textAlign: TextAlign.center,
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  strings.consistencyHint,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: 14),
                _DayHeader(strings: strings),
                const SizedBox(height: 8),
                for (final section in sections) ...[
                  _WeekRow(section: section),
                  const SizedBox(height: 8),
                ],
              ],
            ),
    );
  }
}

class _RangeSelector extends ConsumerWidget {
  const _RangeSelector({
    required this.selected,
    required this.onChanged,
  });

  final ConsistencyRange selected;
  final ValueChanged<ConsistencyRange> onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppStrings.of(context, ref);
    return SegmentedButton<ConsistencyRange>(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? Colors.white.withValues(alpha: 0.16)
              : Colors.white.withValues(alpha: 0.04),
        ),
        foregroundColor: WidgetStateProperty.all(Colors.white),
      ),
      showSelectedIcon: false,
      segments: [
        ButtonSegment(
          value: ConsistencyRange.week,
          label: Text(strings.consistencyByWeek),
        ),
        ButtonSegment(
          value: ConsistencyRange.month,
          label: Text(strings.consistencyByMonth),
        ),
        ButtonSegment(
          value: ConsistencyRange.plan,
          label: Text(strings.consistencyByPlan),
        ),
      ],
      selected: {selected},
      onSelectionChanged: (values) => onChanged(values.first),
    );
  }
}

class _DayHeader extends StatelessWidget {
  const _DayHeader({required this.strings});

  final AppStrings strings;

  @override
  Widget build(BuildContext context) {
    final labels = strings.isChinese
        ? const ['一', '二', '三', '四', '五', '六', '日']
        : const ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    return Row(
      children: [
        const SizedBox(width: 74),
        for (var index = 0; index < 7; index++) ...[
          Expanded(
            child: Center(
              child: Text(
                labels[index],
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Colors.white.withValues(alpha: 0.44),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          if (index < 6) const SizedBox(width: 6),
        ],
      ],
    );
  }
}

class _WeekRow extends ConsumerWidget {
  const _WeekRow({required this.section});

  final ConsistencySection section;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 68,
          child: Text(
            section.label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.6),
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: 6),
        for (var index = 0; index < section.days.length; index++) ...[
          Expanded(
            child: _DayCell(
              record: section.days[index],
            ),
          ),
          if (index < section.days.length - 1) const SizedBox(width: 6),
        ],
      ],
    );
  }
}

class _DayCell extends ConsumerWidget {
  const _DayCell({required this.record});

  final ConsistencyDayRecord record;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppStrings.of(context, ref);
    final dayLabel = '${record.date.day}';
    final foreground = record.hasActivity ? Colors.black : Colors.white;
    final background = !record.isInRange
        ? Colors.white.withValues(alpha: 0.02)
        : record.hasActivity
        ? Color.lerp(
            Colors.greenAccent,
            Colors.white,
            1 - record.intensity,
          )!
        : Colors.white.withValues(alpha: 0.06);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        key: ValueKey('consistency-day-${record.date.toIso8601String()}'),
        onTap: !record.hasActivity
            ? null
            : () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => WorkoutRecordDetailScreen(
                      date: record.date,
                      logs: record.logs,
                    ),
                  ),
                );
              },
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          height: 44,
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: record.hasActivity
                  ? Colors.white.withValues(alpha: 0.16)
                  : Colors.white.withValues(alpha: 0.05),
            ),
          ),
          child: Stack(
            children: [
              Center(
                child: Text(
                  dayLabel,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: foreground.withValues(
                      alpha: record.isInRange ? 1 : 0.4,
                    ),
                  ),
                ),
              ),
              if (record.hasActivity)
                Positioned(
                  right: 6,
                  bottom: 4,
                  child: Text(
                    strings.consistencySessions(record.logs.length),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: foreground.withValues(alpha: 0.7),
                      fontSize: 9,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
