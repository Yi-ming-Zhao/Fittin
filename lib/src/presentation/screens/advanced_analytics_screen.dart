import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fittin_v2/src/application/fittin_theme_provider.dart';
import 'package:fittin_v2/src/application/advanced_analytics_provider.dart';
import 'package:fittin_v2/src/domain/calendar_month.dart';
import 'package:fittin_v2/src/domain/models/cardio.dart';
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
  AnalyticsModality _selectedModality = AnalyticsModality.all;
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
          layout: DashboardPageLayout.detail,
          children: [
            DashboardScreenHeader(
              eyebrow: strings.insights,
              title: strings.advancedAnalytics,
              subtitle: strings.advancedAnalyticsSubtitle,
              showBackButton: true,
            ),
            const SizedBox(height: 18),
            _ModalitySelector(
              selected: _selectedModality,
              onChanged: (value) => setState(() => _selectedModality = value),
            ),
            const SizedBox(height: 12),
            _RangeSummaryCards(
              summary: data.summaryFor(_selectedRange),
              modality: _selectedModality,
            ),
            const SizedBox(height: 18),
            _ConsistencyExplorer(
              range: _selectedRange,
              modality: _selectedModality,
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
    required this.modality,
    required this.data,
    required this.selectedMonth,
    required this.onRangeChanged,
    required this.onMonthChanged,
  });

  final ConsistencyRange range;
  final AnalyticsModality modality;
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
        ? 142.0 + (calendar.weeks.length * 52.0)
        : 112.0 + (sections.length * 56.0);

    return ChartContainer(
      title: strings.trainingConsistency,
      height: sections.isEmpty ? 140 : contentHeight,
      headerAction: _RangeSelector(selected: range, onChanged: onRangeChanged),
      child: range == ConsistencyRange.month
          ? _CalendarMonthView(
              month: calendar,
              data: data,
              selection: selectedMonth,
              modality: modality,
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
                const SizedBox(height: 10),
                const _ModalityLegend(),
                const SizedBox(height: 14),
                _DayHeader(strings: strings),
                const SizedBox(height: 8),
                for (final section in sections) ...[
                  _WeekRow(section: section, modality: modality),
                  const SizedBox(height: 8),
                ],
              ],
            ),
    );
  }
}

class _ModalityLegend extends ConsumerWidget {
  const _ModalityLegend();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppStrings.of(context, ref);
    final theme = ref.watch(resolvedFittinThemeProvider);
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _LegendItem(
          color: theme.strengthSeries,
          label: strings.isChinese ? '力量' : 'Strength',
          circular: false,
        ),
        _LegendItem(
          color: theme.cardioSeries,
          label: strings.isChinese ? '有氧' : 'Cardio',
          circular: true,
        ),
      ],
    );
  }
}

class _ModalitySelector extends ConsumerWidget {
  const _ModalitySelector({required this.selected, required this.onChanged});

  final AnalyticsModality selected;
  final ValueChanged<AnalyticsModality> onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppStrings.of(context, ref);
    return SegmentedButton<AnalyticsModality>(
      showSelectedIcon: false,
      segments: [
        ButtonSegment(
          value: AnalyticsModality.all,
          label: Text(
            strings.isChinese ? '全部' : 'All',
            key: const ValueKey('analytics-modality-all'),
          ),
        ),
        ButtonSegment(
          value: AnalyticsModality.strength,
          label: Text(
            strings.isChinese ? '力量' : 'Strength',
            key: const ValueKey('analytics-modality-strength'),
          ),
          icon: const Icon(Icons.crop_square_rounded, size: 16),
        ),
        ButtonSegment(
          value: AnalyticsModality.cardio,
          label: Text(
            strings.isChinese ? '有氧' : 'Cardio',
            key: const ValueKey('analytics-modality-cardio'),
          ),
          icon: const Icon(Icons.circle_outlined, size: 15),
        ),
      ],
      selected: {selected},
      onSelectionChanged: (value) => onChanged(value.first),
    );
  }
}

class _RangeSummaryCards extends ConsumerWidget {
  const _RangeSummaryCards({required this.summary, required this.modality});

  final ActivityRangeSummary summary;
  final AnalyticsModality modality;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppStrings.of(context, ref);
    final theme = ref.watch(resolvedFittinThemeProvider);
    final showStrength = modality != AnalyticsModality.cardio;
    final showCardio = modality != AnalyticsModality.strength;
    final cards = <Widget>[
      if (showStrength)
        _SummaryMetric(
          theme: theme,
          color: theme.strengthSeries,
          shape: BoxShape.rectangle,
          label: strings.isChinese ? '力量训练' : 'Strength sessions',
          value: '${summary.strengthSessions}',
          caption: strings.isChinese
              ? '${(summary.strengthVolumeKg / 1000).toStringAsFixed(1)} 吨容量'
              : '${(summary.strengthVolumeKg / 1000).toStringAsFixed(1)} t volume',
        ),
      if (showCardio)
        _SummaryMetric(
          theme: theme,
          color: theme.cardioSeries,
          shape: BoxShape.circle,
          label: strings.isChinese ? '有氧训练' : 'Cardio sessions',
          value: '${summary.cardioSessions}',
          caption: strings.isChinese
              ? '${(summary.cardioDurationSeconds / 60).round()} 分钟 · ${(summary.cardioDistanceMeters / 1000).toStringAsFixed(1)} 公里'
              : '${(summary.cardioDurationSeconds / 60).round()} min · ${(summary.cardioDistanceMeters / 1000).toStringAsFixed(1)} km',
        ),
    ];
    return LayoutBuilder(
      builder: (context, constraints) => Wrap(
        spacing: 10,
        runSpacing: 10,
        children: [
          for (final card in cards)
            SizedBox(
              width: cards.length == 1 || constraints.maxWidth < 340
                  ? constraints.maxWidth
                  : (constraints.maxWidth - 10) / 2,
              child: card,
            ),
        ],
      ),
    );
  }
}

class _SummaryMetric extends StatelessWidget {
  const _SummaryMetric({
    required this.theme,
    required this.color,
    required this.shape,
    required this.label,
    required this.value,
    required this.caption,
  });

  final FittinTheme theme;
  final Color color;
  final BoxShape shape;
  final String label;
  final String value;
  final String caption;

  @override
  Widget build(BuildContext context) => DashboardSurfaceCard(
    padding: const EdgeInsets.all(14),
    child: Row(
      children: [
        Container(
          width: 9,
          height: 9,
          decoration: BoxDecoration(
            color: color,
            shape: shape,
            borderRadius: shape == BoxShape.rectangle
                ? BorderRadius.circular(2)
                : null,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: theme.uiStyle(11, theme.fgMuted)),
              const SizedBox(height: 4),
              Text(value, style: theme.numStyle(24, theme.fg)),
              Text(caption, style: theme.uiStyle(10, theme.fgMuted)),
            ],
          ),
        ),
      ],
    ),
  );
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({
    required this.color,
    required this.label,
    required this.circular,
  });

  final Color color;
  final String label;
  final bool circular;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 9,
        height: 9,
        decoration: BoxDecoration(
          color: color,
          shape: circular ? BoxShape.circle : BoxShape.rectangle,
          borderRadius: circular ? null : BorderRadius.circular(2),
        ),
      ),
      const SizedBox(width: 6),
      Text(label),
    ],
  );
}

Color _activityBackground(
  FittinTheme theme, {
  required bool hasStrength,
  required bool hasCardio,
  required double intensity,
  double inactiveAlpha = 0.055,
}) {
  if (!hasStrength && !hasCardio) {
    return theme.fg.withValues(alpha: inactiveAlpha);
  }
  final alpha = 0.10 + intensity.clamp(0, 1) * 0.30;
  var result = theme.surfaceSolid;
  if (hasStrength) {
    result = Color.alphaBlend(
      theme.strengthSeries.withValues(alpha: alpha),
      result,
    );
  }
  if (hasCardio) {
    result = Color.alphaBlend(
      theme.cardioSeries.withValues(alpha: hasStrength ? alpha * 0.72 : alpha),
      result,
    );
  }
  return result;
}

void _openTrainingDay(BuildContext context, ConsistencyDayRecord record) {
  Navigator.of(context).push(
    MaterialPageRoute(builder: (_) => _TrainingDayDetailScreen(record: record)),
  );
}

ConsistencyDayRecord _recordForModality(
  ConsistencyDayRecord record,
  AnalyticsModality modality,
) => ConsistencyDayRecord(
  date: record.date,
  logs: modality == AnalyticsModality.cardio ? const [] : record.logs,
  cardioRecords: modality == AnalyticsModality.strength
      ? const []
      : record.cardioRecords,
  intensity: record.intensity,
  isInRange: record.isInRange,
  planWeekIndex: record.planWeekIndex,
);

class _TrainingDayDetailScreen extends ConsumerWidget {
  const _TrainingDayDetailScreen({required this.record});

  final ConsistencyDayRecord record;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppStrings.of(context, ref);
    final theme = ref.watch(resolvedFittinThemeProvider);
    return DashboardPageScaffold(
      layout: DashboardPageLayout.detail,
      children: [
        DashboardScreenHeader(
          eyebrow: strings.isChinese ? '训练日' : 'TRAINING DAY',
          title:
              '${record.date.year}-${record.date.month.toString().padLeft(2, '0')}-${record.date.day.toString().padLeft(2, '0')}',
          subtitle: strings.isChinese
              ? '力量使用方形标记，有氧使用圆形标记。'
              : 'Strength uses square markers; cardio uses circles.',
          showBackButton: true,
        ),
        if (record.logs.isNotEmpty) ...[
          const SizedBox(height: 20),
          DashboardSectionLabel(label: strings.isChinese ? '力量' : 'STRENGTH'),
          const SizedBox(height: 10),
          DashboardSurfaceCard(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => WorkoutRecordDetailScreen(
                  date: record.date,
                  logs: record.logs,
                ),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: theme.strengthSeries,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    strings.isChinese
                        ? '${record.logs.length} 次力量训练'
                        : '${record.logs.length} strength sessions',
                    style: theme.uiStyle(14, theme.fg, FontWeight.w700),
                  ),
                ),
                const Icon(Icons.chevron_right_rounded),
              ],
            ),
          ),
        ],
        if (record.cardioRecords.isNotEmpty) ...[
          const SizedBox(height: 20),
          DashboardSectionLabel(label: strings.isChinese ? '有氧' : 'CARDIO'),
          const SizedBox(height: 10),
          for (final cardio in record.cardioRecords) ...[
            DashboardSurfaceCard(
              child: Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: theme.cardioSeries,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          cardio.activityName,
                          style: theme.uiStyle(14, theme.fg, FontWeight.w700),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          [
                            '${((cardio.metric(CardioMetricKey.durationSeconds) ?? 0) / 60).round()} min',
                            if (cardio.metric(CardioMetricKey.distanceMeters)
                                case final distance?)
                              '${(distance / 1000).toStringAsFixed(2)} km',
                          ].join(' · '),
                          style: theme.uiStyle(12, theme.fgMuted),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
          ],
        ],
      ],
    );
  }
}

class _CalendarMonthView extends ConsumerWidget {
  const _CalendarMonthView({
    required this.month,
    required this.data,
    required this.selection,
    required this.modality,
    required this.onSelectionChanged,
  });

  final CalendarMonth month;
  final AdvancedAnalyticsData data;
  final CalendarMonthSelection selection;
  final AnalyticsModality modality;
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
        const Align(alignment: Alignment.centerLeft, child: _ModalityLegend()),
        const SizedBox(height: 6),
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
          ),
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
                      modality: modality,
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
  const _CalendarDayCell({
    required this.day,
    required this.record,
    required this.modality,
  });

  final CalendarDay day;
  final ConsistencyDayRecord? record;
  final AnalyticsModality modality;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppStrings.of(context, ref);
    final theme = ref.watch(resolvedFittinThemeProvider);
    final hasStrength =
        (record?.hasStrength ?? false) && modality != AnalyticsModality.cardio;
    final hasCardio =
        (record?.hasCardio ?? false) && modality != AnalyticsModality.strength;
    final hasActivity = hasStrength || hasCardio;
    final intensity = record?.intensity ?? 0;
    final background = _activityBackground(
      theme,
      hasStrength: hasStrength,
      hasCardio: hasCardio,
      intensity: intensity,
      inactiveAlpha: day.isInMonth ? 0.05 : 0.018,
    );
    final foreground = theme.fg;
    final strengthSessions = hasStrength ? record?.logs.length ?? 0 : 0;
    final cardioSessions = hasCardio ? record?.cardioRecords.length ?? 0 : 0;

    return Semantics(
      label: strings.activityDaySemantics(
        day.date,
        strengthSessions: strengthSessions,
        cardioSessions: cardioSessions,
      ),
      button: hasActivity,
      child: ExcludeSemantics(
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            key: ValueKey('calendar-day-${day.date.toIso8601String()}'),
            onTap: !hasActivity
                ? null
                : () {
                    _openTrainingDay(
                      context,
                      _recordForModality(record!, modality),
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
                      ? (hasStrength
                                ? theme.strengthSeries
                                : theme.cardioSeries)
                            .withValues(alpha: 0.48)
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
                  if (hasStrength)
                    Positioned(
                      left: 5,
                      bottom: 5,
                      child: Container(
                        width: 5,
                        height: 5,
                        decoration: BoxDecoration(
                          color: theme.strengthSeries,
                          borderRadius: BorderRadius.circular(1),
                        ),
                      ),
                    ),
                  if (hasCardio)
                    Positioned(
                      right: 5,
                      bottom: 5,
                      child: Container(
                        width: 5,
                        height: 5,
                        decoration: BoxDecoration(
                          color: theme.cardioSeries,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
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
  const _WeekRow({required this.section, required this.modality});

  final ConsistencySection section;
  final AnalyticsModality modality;

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
          Expanded(
            child: _DayCell(record: section.days[index], modality: modality),
          ),
          if (index < section.days.length - 1) const SizedBox(width: 6),
        ],
      ],
    );
  }
}

class _DayCell extends ConsumerWidget {
  const _DayCell({required this.record, required this.modality});

  final ConsistencyDayRecord record;
  final AnalyticsModality modality;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppStrings.of(context, ref);
    final theme = ref.watch(resolvedFittinThemeProvider);
    final hasStrength =
        record.hasStrength && modality != AnalyticsModality.cardio;
    final hasCardio =
        record.hasCardio && modality != AnalyticsModality.strength;
    final hasActivity = hasStrength || hasCardio;
    final dayLabel = '${record.date.day}';
    final foreground = theme.fg;
    final background = !record.isInRange
        ? theme.fg.withValues(alpha: 0.02)
        : _activityBackground(
            theme,
            hasStrength: hasStrength,
            hasCardio: hasCardio,
            intensity: record.intensity,
          );

    return Semantics(
      label: strings.activityDaySemantics(
        record.date,
        strengthSessions: hasStrength ? record.logs.length : 0,
        cardioSessions: hasCardio ? record.cardioRecords.length : 0,
      ),
      button: hasActivity,
      child: ExcludeSemantics(
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            key: ValueKey('consistency-day-${record.date.toIso8601String()}'),
            onTap: !hasActivity
                ? null
                : () {
                    _openTrainingDay(
                      context,
                      _recordForModality(record, modality),
                    );
                  },
            borderRadius: BorderRadius.circular(14),
            child: Ink(
              height: 44,
              decoration: BoxDecoration(
                color: background,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: hasActivity
                      ? (hasStrength
                                ? theme.strengthSeries
                                : theme.cardioSeries)
                            .withValues(alpha: 0.38)
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
                  if (hasStrength)
                    Positioned(
                      left: 5,
                      bottom: 5,
                      child: Container(
                        width: 5,
                        height: 5,
                        decoration: BoxDecoration(
                          color: theme.strengthSeries,
                          borderRadius: BorderRadius.circular(1),
                        ),
                      ),
                    ),
                  if (hasCardio)
                    Positioned(
                      right: 5,
                      bottom: 5,
                      child: Container(
                        width: 5,
                        height: 5,
                        decoration: BoxDecoration(
                          color: theme.cardioSeries,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
