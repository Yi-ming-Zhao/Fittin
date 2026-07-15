import 'package:fittin_v2/src/application/app_locale_provider.dart';
import 'package:fittin_v2/src/presentation/localization/app_strings.dart';
import 'package:fittin_v2/src/presentation/theme/fittin_theme.dart';
import 'package:fittin_v2/src/presentation/widgets/charts/interactive_line_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final theme = FittinTheme.resolve(
    direction: FittinDirection.technical,
    accent: FittinAccent.ember,
    chart: FittinChartStyle.linear,
  );

  testWidgets('renders a localized empty state and chart semantics', (
    tester,
  ) async {
    final strings = AppStrings.fromLocale(AppLocale.zh);
    await _pumpChart(
      tester,
      theme: theme,
      series: const [],
      chartLabel: '体重趋势',
      emptyLabel: '暂无体重记录',
      selectionHint: '轻触数据点查看详情',
      axisDateFormatter: _zhShortDate,
      detailDateFormatter: _zhFullDate,
      emptySemanticsFormatter: strings.chartEmptySemantics,
    );

    expect(find.text('暂无体重记录'), findsOneWidget);
    expect(_chartSemantics(tester).properties.label, '体重趋势。暂无体重记录');
    expect(tester.takeException(), isNull);
  });

  testWidgets('renders multiple-series legend without overflow at 360px', (
    tester,
  ) async {
    await _pumpChart(
      tester,
      theme: theme,
      series: [
        DatedChartSeries(
          id: 'estimated',
          label: 'Estimated 1RM',
          points: [
            DatedChartPoint(date: DateTime(2026, 1, 1), value: 100),
            DatedChartPoint(date: DateTime(2026, 2, 1), value: 105),
          ],
        ),
        DatedChartSeries(
          id: 'actual',
          label: 'Actual 1RM',
          points: [
            DatedChartPoint(date: DateTime(2026, 1, 5), value: 95),
            DatedChartPoint(date: DateTime(2026, 2, 5), value: 102.5),
          ],
        ),
      ],
    );

    expect(find.text('Estimated 1RM'), findsOneWidget);
    expect(find.text('Actual 1RM'), findsOneWidget);
    expect(
      tester
          .getSize(find.byKey(const ValueKey('interactive-line-chart-plot')))
          .width,
      lessThanOrEqualTo(336),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'tap near a point selects it and shows exact active-unit detail',
    (tester) async {
      DatedChartSelection? callbackSelection;
      final series = [
        DatedChartSeries(
          id: 'bench',
          label: 'Bench Press',
          points: [
            DatedChartPoint(
              date: DateTime(2026, 4, 5),
              value: 231.5,
              detail: '5RM',
            ),
          ],
        ),
      ];
      await _pumpChart(
        tester,
        theme: theme,
        series: series,
        unit: 'lb',
        detailDateFormatter: (_) => 'April 5, 2026',
        onSelectionChanged: (selection) => callbackSelection = selection,
      );

      await _tapPoint(tester, pointIndex: 0, offset: const Offset(35, 0));

      expect(callbackSelection?.series.id, 'bench');
      expect(callbackSelection?.point.value, 231.5);
      expect(
        find.text('Bench Press · April 5, 2026 · 231.5 lb · 5RM'),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'point semantics expose series, full date, value, unit and detail',
    (tester) async {
      await _pumpChart(
        tester,
        theme: theme,
        series: [
          DatedChartSeries(
            id: 'squat',
            label: 'Squat',
            points: [
              DatedChartPoint(
                date: DateTime(2026, 3, 9),
                value: 180,
                detail: 'Workout 12',
              ),
            ],
          ),
        ],
        detailDateFormatter: (_) => 'March 9, 2026',
      );

      const label = 'Squat · March 9, 2026 · 180.0 kg · Workout 12';
      final finder = find.byKey(const ValueKey('interactive-line-chart-plot'));
      final customPaint = tester.widget<CustomPaint>(finder);
      final painter = customPaint.painter! as InteractiveLineChartPainter;
      final pointSemantics = painter
          .semanticsBuilder(tester.getSize(finder))
          .single
          .properties;
      expect(pointSemantics.label, label);
      expect(pointSemantics.button, isTrue);
      expect(pointSemantics.onTap, isNotNull);
      expect(pointSemantics.textDirection, TextDirection.ltr);
    },
  );

  testWidgets('English formatters drive summary and selected detail', (
    tester,
  ) async {
    final strings = AppStrings.fromLocale(AppLocale.en);
    await _pumpChart(
      tester,
      theme: theme,
      series: [
        DatedChartSeries(
          id: 'weight',
          label: 'Body weight',
          points: [DatedChartPoint(date: DateTime(2026, 4, 5), value: 82.25)],
        ),
      ],
      chartLabel: 'Weight trend',
      xAxisLabel: 'Date',
      yAxisLabel: 'Weight',
      unit: 'kg',
      selectionHint: 'Tap a point for details',
      axisDateFormatter: (_) => '4/5',
      detailDateFormatter: (_) => 'April 5, 2026',
      detailValueFormatter: (value) => value.toStringAsFixed(2),
      emptySemanticsFormatter: strings.chartEmptySemantics,
      summarySemanticsFormatter: strings.chartSummarySemantics,
      pointLabelFormatter: strings.chartPointLabel,
    );

    expect(
      _chartSemantics(tester).properties.label,
      'Weight trend. Date: April 5, 2026. Weight · kg. Body weight',
    );
    await _tapPoint(tester, pointIndex: 0);
    expect(find.text('Body weight · April 5, 2026 · 82.25 kg'), findsOneWidget);
  });

  testWidgets('Chinese formatters drive summary and selected detail', (
    tester,
  ) async {
    final strings = AppStrings.fromLocale(AppLocale.zh);
    await _pumpChart(
      tester,
      theme: theme,
      series: [
        DatedChartSeries(
          id: 'weight',
          label: '体重',
          points: [DatedChartPoint(date: DateTime(2026, 4, 5), value: 82.25)],
        ),
      ],
      chartLabel: '体重趋势',
      xAxisLabel: '日期',
      yAxisLabel: '体重',
      unit: '公斤',
      emptyLabel: '暂无体重记录',
      selectionHint: '轻触数据点查看详情',
      axisDateFormatter: _zhShortDate,
      detailDateFormatter: _zhFullDate,
      detailValueFormatter: (value) => value.toStringAsFixed(2),
      emptySemanticsFormatter: strings.chartEmptySemantics,
      summarySemanticsFormatter: strings.chartSummarySemantics,
      pointLabelFormatter: strings.chartPointLabel,
    );

    expect(
      _chartSemantics(tester).properties.label,
      '体重趋势。日期：2026年4月5日。体重 · 公斤。体重',
    );
    await _tapPoint(tester, pointIndex: 0);
    expect(find.text('体重，2026年4月5日，82.25 公斤'), findsOneWidget);
    expect(find.textContaining('Weight'), findsNothing);
  });

  testWidgets('selection survives a harmless rebuild with equivalent data', (
    tester,
  ) async {
    late StateSetter rebuild;
    var generation = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 360,
              child: StatefulBuilder(
                builder: (context, setState) {
                  rebuild = setState;
                  return InteractiveLineChart(
                    theme: theme,
                    series: [
                      DatedChartSeries(
                        id: 'bench',
                        label: 'Bench',
                        points: [
                          DatedChartPoint(
                            date: DateTime(2026, 4, 5),
                            value: 100 + generation * 0,
                          ),
                        ],
                      ),
                    ],
                    chartLabel: 'Bench trend',
                    xAxisLabel: 'Date',
                    yAxisLabel: 'Load',
                    unit: 'kg',
                    emptyLabel: 'No data',
                    selectionHint: 'Tap a point for details',
                    axisDateFormatter: _enShortDate,
                    detailDateFormatter: _enFullDate,
                    axisValueFormatter: _axisValue,
                    detailValueFormatter: _detailValue,
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    await _tapPoint(tester, pointIndex: 0);
    expect(find.text('Bench · 4/5/2026 · 100.0 kg'), findsOneWidget);

    rebuild(() => generation++);
    await tester.pump();

    expect(find.text('Bench · 4/5/2026 · 100.0 kg'), findsOneWidget);
  });
}

Future<void> _pumpChart(
  WidgetTester tester, {
  required FittinTheme theme,
  required List<DatedChartSeries> series,
  String chartLabel = 'Load trend',
  String xAxisLabel = 'Date',
  String yAxisLabel = 'Load',
  String unit = 'kg',
  String emptyLabel = 'No data',
  String selectionHint = 'Tap a point for details',
  ChartDateFormatter axisDateFormatter = _enShortDate,
  ChartDateFormatter detailDateFormatter = _enFullDate,
  ChartValueFormatter axisValueFormatter = _axisValue,
  ChartValueFormatter detailValueFormatter = _detailValue,
  ChartEmptySemanticsFormatter? emptySemanticsFormatter,
  ChartSummarySemanticsFormatter? summarySemanticsFormatter,
  ChartPointLabelFormatter? pointLabelFormatter,
  ValueChanged<DatedChartSelection?>? onSelectionChanged,
}) async {
  tester.view.physicalSize = const Size(360, 760);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        backgroundColor: theme.bg,
        body: Center(
          child: SizedBox(
            width: 360,
            child: InteractiveLineChart(
              theme: theme,
              series: series,
              chartLabel: chartLabel,
              xAxisLabel: xAxisLabel,
              yAxisLabel: yAxisLabel,
              unit: unit,
              emptyLabel: emptyLabel,
              selectionHint: selectionHint,
              axisDateFormatter: axisDateFormatter,
              detailDateFormatter: detailDateFormatter,
              axisValueFormatter: axisValueFormatter,
              detailValueFormatter: detailValueFormatter,
              emptySemanticsFormatter: emptySemanticsFormatter,
              summarySemanticsFormatter: summarySemanticsFormatter,
              pointLabelFormatter: pointLabelFormatter,
              onSelectionChanged: onSelectionChanged,
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pump();
}

Future<void> _tapPoint(
  WidgetTester tester, {
  required int pointIndex,
  Offset offset = Offset.zero,
}) async {
  final finder = find.byKey(const ValueKey('interactive-line-chart-plot'));
  final customPaint = tester.widget<CustomPaint>(finder);
  final painter = customPaint.painter! as InteractiveLineChartPainter;
  final size = tester.getSize(finder);
  final point = painter.layoutFor(size).points[pointIndex].offset;
  await tester.tapAt(tester.getTopLeft(finder) + point + offset);
  await tester.pump();
}

String _enShortDate(DateTime date) => '${date.month}/${date.day}';
String _enFullDate(DateTime date) => '${date.month}/${date.day}/${date.year}';
String _zhShortDate(DateTime date) => '${date.month}月${date.day}日';
String _zhFullDate(DateTime date) => '${date.year}年${date.month}月${date.day}日';
String _axisValue(double value) => value.toStringAsFixed(0);
String _detailValue(double value) => value.toStringAsFixed(1);

Semantics _chartSemantics(WidgetTester tester) {
  return tester.widget<Semantics>(
    find.byKey(const ValueKey('interactive-line-chart-semantics')),
  );
}
