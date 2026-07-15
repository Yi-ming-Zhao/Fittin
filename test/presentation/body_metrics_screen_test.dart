import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fittin_v2/src/application/active_session_provider.dart';
import 'package:fittin_v2/src/application/app_locale_provider.dart';
import 'package:fittin_v2/src/data/progress_repository.dart';
import 'package:fittin_v2/src/domain/models/body_metric.dart';
import 'package:fittin_v2/src/presentation/screens/body_metrics_screen.dart';
import 'package:fittin_v2/src/presentation/widgets/charts/interactive_line_chart.dart';

import '../support/in_memory_database_repository.dart';

void main() {
  testWidgets('empty body page uses a compact hero without duplicate CTA', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseRepositoryProvider.overrideWithValue(
            InMemoryDatabaseRepository(),
          ),
          progressRepositoryProvider.overrideWithValue(
            InMemoryProgressRepository(),
          ),
        ],
        child: const MaterialApp(home: BodyMetricsScreen()),
      ),
    );
    await tester.pumpAndSettle();

    final hero = find.byKey(const ValueKey('body-empty-hero'));
    expect(hero, findsOneWidget);
    expect(tester.getSize(hero).height, lessThan(190));
    expect(find.text('Add first measurement'), findsOneWidget);
    expect(find.text('Add measurement'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'weight history uses dated axes, point details, and unit toggle',
    (tester) async {
      tester.view.physicalSize = const Size(390, 926);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final progressRepository = InMemoryProgressRepository();
      await progressRepository.saveBodyMetric(
        BodyMetric(
          metricId: 'weight-1',
          timestamp: DateTime(2026, 1, 2),
          weightKg: 80,
        ),
      );
      await progressRepository.saveBodyMetric(
        BodyMetric(
          metricId: 'weight-2',
          timestamp: DateTime(2026, 3, 18),
          weightKg: 78.5,
        ),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            databaseRepositoryProvider.overrideWithValue(
              InMemoryDatabaseRepository(),
            ),
            progressRepositoryProvider.overrideWithValue(progressRepository),
          ],
          child: const MaterialApp(home: BodyMetricsScreen()),
        ),
      );
      await tester.pumpAndSettle();

      final chartFinder = find.byKey(const ValueKey('body-weight-chart'));
      var chart = tester.widget<InteractiveLineChart>(chartFinder);
      expect(chart.xAxisLabel, 'Date');
      expect(chart.yAxisLabel, 'Weight');
      expect(chart.unit, 'kg');
      expect(chart.series.single.points.map((point) => point.date), [
        DateTime(2026, 1, 2),
        DateTime(2026, 3, 18),
      ]);

      await tester.tap(find.text('lb'));
      await tester.pump();
      chart = tester.widget<InteractiveLineChart>(chartFinder);
      expect(chart.unit, 'lb');
      expect(chart.series.single.points.last.value, closeTo(173.06, 0.01));
      expect(chart.series.single.points.last.detail, contains('-3.3 lb'));
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('body metrics localizes units, chart semantics, and history', (
    tester,
  ) async {
    _setViewport(tester, const Size(390, 926));
    final databaseRepository = InMemoryDatabaseRepository();
    await databaseRepository.saveAppLocale(AppLocale.zh);
    final progressRepository = InMemoryProgressRepository();
    await progressRepository.saveBodyMetric(
      BodyMetric(
        metricId: 'zh-body-1',
        timestamp: DateTime(2026, 3, 1),
        weightKg: 80,
        bodyFatPercent: 20,
        waistCm: 90,
      ),
    );
    await progressRepository.saveBodyMetric(
      BodyMetric(
        metricId: 'zh-body-2',
        timestamp: DateTime(2026, 3, 18),
        weightKg: 79.2,
        bodyFatPercent: 19.5,
        waistCm: 88,
      ),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseRepositoryProvider.overrideWithValue(databaseRepository),
          progressRepositoryProvider.overrideWithValue(progressRepository),
        ],
        child: const MaterialApp(home: BodyMetricsScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('身体指标'), findsOneWidget);
    expect(find.text('体重（公斤）'), findsOneWidget);
    expect(find.text('CHECK-INS'), findsNothing);
    final chart = tester.widget<InteractiveLineChart>(
      find.byKey(const ValueKey('body-weight-chart')),
    );
    expect(chart.unit, '公斤');
    final semantics = tester.widget<Semantics>(
      find.byKey(const ValueKey('interactive-line-chart-semantics')),
    );
    expect(semantics.properties.label, contains('体重趋势。日期：'));
    expect(semantics.properties.label, contains('体重 · 公斤'));

    final verticalScroll = _verticalScrollable();
    final latestWaist = find.text('腰围 88.0 厘米');
    await _scrollUntilBuiltAndVisible(
      tester,
      target: latestWaist,
      scrollable: verticalScroll,
    );
    expect(find.text('79.2 公斤'), findsWidgets);
    expect(find.text('19.5%'), findsOneWidget);
    expect(latestWaist, findsOneWidget);
    expect(find.text('79.2 kg'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  for (final viewport in const [Size(390, 926), Size(390, 568)]) {
    testWidgets(
      'body metrics keeps chart and history reachable at ${viewport.width.toInt()}x${viewport.height.toInt()}',
      (tester) async {
        _setViewport(tester, viewport);
        final progressRepository = InMemoryProgressRepository();
        await progressRepository.saveBodyMetric(
          BodyMetric(
            metricId: 'mobile-body-1',
            timestamp: DateTime(2026, 3, 1),
            weightKg: 80,
            bodyFatPercent: 20,
            waistCm: 90,
          ),
        );
        await progressRepository.saveBodyMetric(
          BodyMetric(
            metricId: 'mobile-body-2',
            timestamp: DateTime(2026, 3, 18),
            weightKg: 79.2,
            bodyFatPercent: 19.5,
            waistCm: 88,
          ),
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              databaseRepositoryProvider.overrideWithValue(
                InMemoryDatabaseRepository(),
              ),
              progressRepositoryProvider.overrideWithValue(progressRepository),
            ],
            child: const MaterialApp(home: BodyMetricsScreen()),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Body Metrics'), findsOneWidget);
        expect(find.byKey(const ValueKey('body-weight-chart')), findsOneWidget);
        final verticalScroll = _verticalScrollable();
        final position = tester.state<ScrollableState>(verticalScroll).position;
        expect(position.maxScrollExtent, greaterThan(0));

        final historyHeading = find.text('MEASUREMENT LOG');
        await _scrollUntilBuiltAndVisible(
          tester,
          target: historyHeading,
          scrollable: verticalScroll,
        );
        expect(historyHeading, findsOneWidget);
        final historyRect = tester.getRect(historyHeading);
        expect(historyRect.top, lessThan(viewport.height));
        expect(historyRect.bottom, greaterThan(0));
        expect(position.pixels, greaterThan(0));
        expect(tester.takeException(), isNull);
      },
    );
  }
}

void _setViewport(WidgetTester tester, Size size) {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

Finder _verticalScrollable() {
  return find
      .byWidgetPredicate(
        (widget) =>
            widget is Scrollable && widget.axisDirection == AxisDirection.down,
      )
      .first;
}

Future<void> _scrollUntilBuiltAndVisible(
  WidgetTester tester, {
  required Finder target,
  required Finder scrollable,
}) async {
  for (var attempt = 0; attempt < 12; attempt++) {
    if (target.evaluate().isNotEmpty) {
      await tester.scrollUntilVisible(target, 220, scrollable: scrollable);
      await tester.pump();
      return;
    }
    await tester.drag(scrollable, const Offset(0, -260));
    await tester.pump();
  }
}
