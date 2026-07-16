import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fittin_v2/src/application/fittin_theme_provider.dart';
import 'package:fittin_v2/src/application/advanced_analytics_provider.dart';
import 'package:fittin_v2/src/domain/calendar_month.dart';
import 'package:fittin_v2/src/presentation/localization/app_strings.dart';
import 'package:fittin_v2/src/presentation/theme/fittin_theme.dart'
    show FittinTheme;
import 'package:fittin_v2/src/presentation/screens/workout_record_detail_screen.dart';
import 'package:fittin_v2/src/presentation/widgets/anatomy_load_map.dart';
import 'package:fittin_v2/src/presentation/widgets/chart_container.dart';
import 'package:fittin_v2/src/presentation/widgets/charts/muscle_distribution_painter.dart';
import 'package:fittin_v2/src/presentation/widgets/dashboard_primitives.dart';
import 'package:fittin_v2/src/presentation/widgets/fittin_primitives.dart';

class AdvancedAnalyticsScreen extends ConsumerStatefulWidget {
  const AdvancedAnalyticsScreen({super.key});

  @override
  ConsumerState<AdvancedAnalyticsScreen> createState() =>
      _AdvancedAnalyticsScreenState();
}

class _AdvancedAnalyticsScreenState
    extends ConsumerState<AdvancedAnalyticsScreen> {
  ConsistencyRange _selectedRange = ConsistencyRange.week;
  CalendarMonthSelection _selectedMonth = CalendarMonthSelection.today();

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context, ref);
    final fittinTheme = ref.watch(resolvedFittinThemeProvider);
    final dataAsync = ref.watch(advancedAnalyticsDataProvider);

    return Scaffold(
      backgroundColor: fittinTheme.bg,
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
              selectedMonth: _selectedMonth,
              onRangeChanged: (value) {
                setState(() {
                  _selectedRange = value;
                });
              },
              onMonthChanged: (value) {
                setState(() {
                  _selectedMonth = value;
                });
              },
            ),
            const SizedBox(height: 24),
            _buildVolumeDistribution(context, strings, data, fittinTheme),
            const SizedBox(height: 32),
            AnatomyLoadMap(overview: data.muscleLoad),
            const SizedBox(height: 80),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(strings.loadError(e))),
      ),
    );
  }

  Widget _buildVolumeDistribution(
    BuildContext context,
    AppStrings strings,
    AdvancedAnalyticsData data,
    FittinTheme theme,
  ) {
    final loads = data.muscleLoad.loads.take(5).toList(growable: false);
    final maximum = loads.fold<double>(
      0,
      (value, load) => load.weightedCompletedSets > value
          ? load.weightedCompletedSets
          : value,
    );
    final volumeData = [
      for (final load in loads)
        MuscleVolumeData(
          label: strings.muscleName(load.muscle),
          currentSets: load.weightedCompletedSets,
          targetSets: maximum,
          color: Color.lerp(
            theme.loadLow,
            theme.loadHigh,
            load.normalizedIntensity.clamp(0, 1),
          )!,
        ),
    ];
    return ChartContainer(
      title: strings.muscleTrainingLoad,
      height: 220,
      child: volumeData.isEmpty
          ? Center(
              child: Text(strings.anatomyNoData, textAlign: TextAlign.center),
            )
          : Semantics(
              container: true,
              image: true,
              label: strings.muscleLoadChartSemantics([
                for (final item in volumeData)
                  strings.muscleLoadChartEntry(item.label, item.currentSets),
              ]),
              child: CustomPaint(
                painter: MuscleDistributionPainter(
                  data: volumeData,
                  labelColor: theme.chartLabel,
                  trackColor: theme.chartGrid,
                ),
                size: Size.infinite,
              ),
            ),
    );
  }
}

class _ConsistencyExplorer extends ConsumerWidget {
  const _ConsistencyExplorer({
    required this.range,
    required this.data,
    required this.selectedMonth,
    required this.onRangeChanged,
    required this.onMonthChanged,
  });

  final ConsistencyRange range;
  final AdvancedAnalyticsData data;
  final CalendarMonthSelection selectedMonth;
  final ValueChanged<ConsistencyRange> onRangeChanged;
  final ValueChanged<CalendarMonthSelection> onMonthChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppStrings.of(context, ref);
    final theme = ref.watch(resolvedFittinThemeProvider);
    final sections = data.sectionsByRange[range] ?? const [];
    final calendar = CalendarMonthBuilder().build(
      focusedMonth: selectedMonth.focusedMonth,
      recordedDates: data.recordedDates,
      localeCode: strings.isChinese ? 'zh_CN' : 'en',
    );
    final contentHeight = range == ConsistencyRange.month
        ? 112.0 + (calendar.weeks.length * 52.0)
        : 78.0 + (sections.length * 56.0);

    return ChartContainer(
      title: strings.trainingConsistency,
      height: sections.isEmpty ? 140 : contentHeight,
      headerAction: _RangeSelector(selected: range, onChanged: onRangeChanged),
      child: range == ConsistencyRange.month
          ? _CalendarMonthView(
              month: calendar,
              data: data,
              selection: selectedMonth,
              onSelectionChanged: onMonthChanged,
            )
          : sections.isEmpty
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
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: theme.fgDim),
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

class _CalendarMonthView extends ConsumerWidget {
  const _CalendarMonthView({
    required this.month,
    required this.data,
    required this.selection,
    required this.onSelectionChanged,
  });

  final CalendarMonth month;
  final AdvancedAnalyticsData data;
  final CalendarMonthSelection selection;
  final ValueChanged<CalendarMonthSelection> onSelectionChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppStrings.of(context, ref);
    final theme = ref.watch(resolvedFittinThemeProvider);
    final todayMonth = CalendarMonthBuilder.monthOf(DateTime.now());
    final earliestMonth = CalendarMonthBuilder.monthOf(
      data.earliestRecordedDate ?? todayMonth,
    );
    final latestRecordedMonth = CalendarMonthBuilder.monthOf(
      data.latestRecordedDate ?? todayMonth,
    );
    final latestMonth = latestRecordedMonth.isAfter(todayMonth)
        ? latestRecordedMonth
        : todayMonth;
    final canMovePrevious = selection.focusedMonth.isAfter(earliestMonth);
    final canMoveNext = selection.focusedMonth.isBefore(latestMonth);

    return Column(
      children: [
        Row(
          children: [
            IconButton(
              key: const ValueKey('calendar-previous-month'),
              tooltip: strings.previousMonth,
              onPressed: canMovePrevious
                  ? () => onSelectionChanged(selection.previous())
                  : null,
              icon: const Icon(Icons.chevron_left_rounded),
            ),
            Expanded(
              child: Text(
                month.label,
                key: const ValueKey('calendar-month-label'),
                textAlign: TextAlign.center,
                style: theme.uiStyle(15, theme.fg, FontWeight.w800),
              ),
            ),
            IconButton(
              key: const ValueKey('calendar-next-month'),
              tooltip: strings.nextMonth,
              onPressed: canMoveNext
                  ? () => onSelectionChanged(selection.next())
                  : null,
              icon: const Icon(Icons.chevron_right_rounded),
            ),
          ],
        ),
        if (!selection.isCurrentMonth())
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              key: const ValueKey('calendar-today'),
              onPressed: () => onSelectionChanged(selection.jumpToToday()),
              child: Text(strings.calendarToday),
            ),
          )
        else
          const SizedBox(height: 40),
        Row(
          children: [
            for (final label in month.weekdayLabels)
              Expanded(
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.fade,
                  style: theme.uiStyle(10, theme.fgDim, FontWeight.w700),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        for (final week in month.weeks) ...[
          Row(
            children: [
              for (final day in week.days)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: _CalendarDayCell(
                      day: day,
                      record: data.recordFor(day.date),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
        ],
      ],
    );
  }
}

class _CalendarDayCell extends ConsumerWidget {
  const _CalendarDayCell({required this.day, required this.record});

  final CalendarDay day;
  final ConsistencyDayRecord? record;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppStrings.of(context, ref);
    final theme = ref.watch(resolvedFittinThemeProvider);
    final hasActivity = record?.hasActivity ?? false;
    final intensity = record?.intensity ?? 0;
    final background = hasActivity
        ? Color.alphaBlend(
            theme.accent.withValues(alpha: 0.18 + intensity * 0.5),
            theme.surfaceSolid,
          )
        : theme.fg.withValues(alpha: day.isInMonth ? 0.05 : 0.018);
    final foreground = hasActivity && intensity >= 0.58
        ? theme.accentInk
        : theme.fg;
    final sessionCount = record?.logs.length ?? 0;

    return Semantics(
      label: strings.calendarDaySemantics(day.date, sessionCount),
      button: hasActivity,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          key: ValueKey('calendar-day-${day.date.toIso8601String()}'),
          onTap: !hasActivity
              ? null
              : () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => WorkoutRecordDetailScreen(
                        date: day.date,
                        logs: record!.logs,
                      ),
                    ),
                  );
                },
          borderRadius: BorderRadius.circular(13),
          child: Ink(
            height: 44,
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(13),
              border: Border.all(
                color: day.isToday
                    ? theme.fg.withValues(alpha: 0.7)
                    : hasActivity
                    ? theme.accent.withValues(alpha: 0.32)
                    : theme.border,
              ),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Text(
                  '${day.date.day}',
                  style: theme
                      .uiStyle(13, foreground, FontWeight.w800)
                      .copyWith(
                        color: foreground.withValues(
                          alpha: day.isInMonth ? 1 : 0.32,
                        ),
                      ),
                ),
                if (hasActivity)
                  Positioned(
                    bottom: 5,
                    child: Container(
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(
                        color: foreground.withValues(alpha: 0.82),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RangeSelector extends ConsumerWidget {
  const _RangeSelector({required this.selected, required this.onChanged});

  final ConsistencyRange selected;
  final ValueChanged<ConsistencyRange> onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppStrings.of(context, ref);
    final theme = ref.watch(resolvedFittinThemeProvider);
    return FittinSegmented(
      theme: theme,
      options: [
        strings.consistencyByWeek,
        strings.consistencyByMonth,
        strings.consistencyByPlan,
      ],
      value: switch (selected) {
        ConsistencyRange.month => strings.consistencyByMonth,
        ConsistencyRange.plan => strings.consistencyByPlan,
        ConsistencyRange.week => strings.consistencyByWeek,
      },
      expand: true,
      onChange: (value) => onChanged(
        value == strings.consistencyByMonth
            ? ConsistencyRange.month
            : value == strings.consistencyByPlan
            ? ConsistencyRange.plan
            : ConsistencyRange.week,
      ),
    );
  }
}

class _DayHeader extends ConsumerWidget {
  const _DayHeader({required this.strings});

  final AppStrings strings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final labels = strings.calendarWeekdayInitials;
    final theme = ref.watch(resolvedFittinThemeProvider);
    return Row(
      children: [
        const SizedBox(width: 74),
        for (var index = 0; index < 7; index++) ...[
          Expanded(
            child: Center(
              child: Text(
                labels[index],
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: theme.fgMuted,
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
    final strings = AppStrings.of(context, ref);
    final theme = ref.watch(resolvedFittinThemeProvider);
    final planWeekIndex = section.days.isEmpty
        ? null
        : section.days.first.planWeekIndex;
    final label = planWeekIndex == null
        ? section.label
        : strings.analyticsPlanWeekLabel(planWeekIndex + 1);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 68,
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: theme.fgDim,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: 6),
        for (var index = 0; index < section.days.length; index++) ...[
          Expanded(child: _DayCell(record: section.days[index])),
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
    final theme = ref.watch(resolvedFittinThemeProvider);
    final dayLabel = '${record.date.day}';
    final foreground = record.hasActivity && record.intensity >= 0.58
        ? theme.accentInk
        : theme.fg;
    final background = !record.isInRange
        ? theme.fg.withValues(alpha: 0.02)
        : record.hasActivity
        ? Color.alphaBlend(
            theme.accent.withValues(
              alpha: 0.12 + record.intensity.clamp(0, 1) * 0.52,
            ),
            theme.surfaceSolid,
          )
        : theme.fg.withValues(alpha: 0.055);

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
                  ? theme.accent.withValues(alpha: 0.24)
                  : theme.border,
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
