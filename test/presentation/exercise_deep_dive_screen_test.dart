import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fittin_v2/src/application/active_session_provider.dart';
import 'package:fittin_v2/src/application/app_locale_provider.dart';
import 'package:fittin_v2/src/application/progress_analytics_provider.dart';
import 'package:fittin_v2/src/presentation/screens/exercise_deep_dive_screen.dart';
import 'package:fittin_v2/src/presentation/widgets/charts/interactive_line_chart.dart';

import '../support/in_memory_database_repository.dart';

void main() {
  testWidgets('exercise deep dive renders English analytics copy and units', (
    tester,
  ) async {
    await _pumpScreen(
      tester,
      locale: AppLocale.en,
      summary: _summary(name: 'Bench Press'),
    );

    expect(find.text('Progress'), findsOneWidget);
    expect(find.text('Exercise details'), findsOneWidget);
    expect(find.text('kg · estimated 1RM'), findsOneWidget);
    final chart = tester.widget<InteractiveLineChart>(
      find.byKey(const ValueKey('exercise-deep-dive-chart')),
    );
    expect(chart.unit, 'kg');
    expect(chart.series.map((series) => series.label), ['1RM', '3RM', '5RM']);
    expect(tester.takeException(), isNull);

    final historyValue = find.text('100.0 kg × 5 reps');
    await _scrollUntilBuiltAndVisible(
      tester,
      target: historyValue,
      scrollable: _verticalScrollable(),
    );
    expect(find.text('SESSION HISTORY'), findsOneWidget);
    expect(historyValue, findsOneWidget);
    expect(find.text('动作详情'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('exercise deep dive renders Chinese copy without English leaks', (
    tester,
  ) async {
    await _pumpScreen(
      tester,
      locale: AppLocale.zh,
      summary: _summary(name: '卧推'),
    );

    expect(find.text('进度'), findsOneWidget);
    expect(find.text('动作详情'), findsOneWidget);
    expect(find.text('公斤 · 预估 1RM'), findsOneWidget);
    final chart = tester.widget<InteractiveLineChart>(
      find.byKey(const ValueKey('exercise-deep-dive-chart')),
    );
    expect(chart.unit, '公斤');
    expect(tester.takeException(), isNull);

    final historyValue = find.text('100.0 公斤 × 5 次');
    await _scrollUntilBuiltAndVisible(
      tester,
      target: historyValue,
      scrollable: _verticalScrollable(),
    );
    expect(find.text('训练历史'), findsOneWidget);
    expect(historyValue, findsOneWidget);
    expect(find.text('Progress'), findsNothing);
    expect(find.text('Exercise details'), findsNothing);
    expect(find.text('kg · estimated 1RM'), findsNothing);
    expect(find.text('SESSION HISTORY'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('exercise deep dive localizes the empty history state', (
    tester,
  ) async {
    await _pumpScreen(
      tester,
      locale: AppLocale.zh,
      summary: _summary(name: '卧推', history: const []),
    );

    final emptyState = find.text('还没有这个动作的训练记录。');
    await _scrollUntilBuiltAndVisible(
      tester,
      target: emptyState,
      scrollable: _verticalScrollable(),
    );
    expect(emptyState, findsOneWidget);
    expect(
      find.text('No training history for this exercise yet.'),
      findsNothing,
    );
    expect(tester.takeException(), isNull);
  });
}

Future<void> _pumpScreen(
  WidgetTester tester, {
  required AppLocale locale,
  required ExerciseProgressSummary summary,
}) async {
  tester.view.physicalSize = const Size(390, 926);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  final repository = InMemoryDatabaseRepository();
  await repository.saveAppLocale(locale);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [databaseRepositoryProvider.overrideWithValue(repository)],
      child: MaterialApp(home: ExerciseDeepDiveScreen(summary: summary)),
    ),
  );
  await tester.pumpAndSettle();
}

ExerciseProgressSummary _summary({
  required String name,
  List<ExercisePerformancePoint>? history,
}) {
  final estimatedHistory =
      history ??
      [
        _point(DateTime(2026, 3, 1), weight: 95, value: 107.9),
        _point(DateTime(2026, 3, 18), weight: 100, value: 113.6),
      ];
  return ExerciseProgressSummary(
    exerciseId: 'bench-press',
    exerciseName: name,
    encounterCount: estimatedHistory.length,
    currentEstimatedOneRepMax: estimatedHistory.isEmpty
        ? null
        : estimatedHistory.last.value,
    bestEstimatedOneRepMax: estimatedHistory.isEmpty
        ? null
        : estimatedHistory.last.value,
    currentActualOneRepMax: null,
    bestActualOneRepMax: null,
    recentChange: estimatedHistory.length < 2
        ? null
        : estimatedHistory.last.value - estimatedHistory.first.value,
    totalVolume: 0,
    lastCompletedAt: estimatedHistory.isEmpty
        ? null
        : estimatedHistory.last.completedAt,
    isStagnating: false,
    personalRecords: const [],
    estimatedHistory: estimatedHistory,
    actualHistory: const [],
  );
}

ExercisePerformancePoint _point(
  DateTime completedAt, {
  required double weight,
  required double value,
}) {
  return ExercisePerformancePoint(
    completedAt: completedAt,
    weight: weight,
    reps: 5,
    value: value,
    isActual: false,
  );
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
