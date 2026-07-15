import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fittin_v2/src/application/active_session_provider.dart';
import 'package:fittin_v2/src/application/app_locale_provider.dart';
import 'package:fittin_v2/src/application/pr_dashboard_provider.dart';
import 'package:fittin_v2/src/application/progress_analytics_provider.dart';
import 'package:fittin_v2/src/presentation/screens/pr_dashboard_screen.dart';
import 'package:fittin_v2/src/presentation/widgets/charts/interactive_line_chart.dart';

import '../support/in_memory_database_repository.dart';

void main() {
  testWidgets(
    'PR dashboard toggles metric mode, switches chart lift, and truncates milestone preview',
    (tester) async {
      final repository = InMemoryDatabaseRepository();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            databaseRepositoryProvider.overrideWithValue(repository),
            prDashboardDataProvider.overrideWith(
              (ref) => AsyncData(_fakeData()),
            ),
          ],
          child: const MaterialApp(home: PRDashboardScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('139.3'), findsOneWidget);
      expect(find.byKey(const ValueKey('strength-card-squat')), findsOneWidget);
      expect(find.text('Deadlift'), findsOneWidget);
      expect(find.text('Standing Barbell Press'), findsNothing);

      await tester.drag(
        find.byKey(const ValueKey('pr-lift-page-view')),
        const Offset(-320, 0),
      );
      await tester.pumpAndSettle();
      expect(
        find.byKey(const ValueKey('selected-chart-lift-label-Bench')),
        findsOneWidget,
      );

      await tester.drag(
        find.byKey(const ValueKey('pr-lift-page-view')),
        const Offset(-320, 0),
      );
      await tester.pumpAndSettle();
      expect(
        find.byKey(const ValueKey('selected-chart-lift-label-Deadlift')),
        findsOneWidget,
      );

      await tester.tap(find.text('Actual PR'));
      await tester.pumpAndSettle();

      expect(find.text('135.0'), findsOneWidget);

      expect(find.text('Standing Barbell Press'), findsNothing);
    },
  );

  testWidgets('PR dashboard localizes visible labels in Chinese', (
    tester,
  ) async {
    final repository = InMemoryDatabaseRepository();
    await repository.saveAppLocale(AppLocale.zh);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseRepositoryProvider.overrideWithValue(repository),
          prDashboardDataProvider.overrideWith(
            (ref) => AsyncData(_fakeData(chinese: true)),
          ),
        ],
        child: const MaterialApp(home: PRDashboardScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('PR 仪表盘'), findsOneWidget);
    expect(find.text('表现'), findsOneWidget);
    expect(find.text('预估 1RM'), findsWidgets);
    expect(find.text('深蹲'), findsWidgets);
    expect(find.text('Competition Squat'), findsNothing);
    final chart = tester.widget<InteractiveLineChart>(
      find.byKey(const ValueKey('pr-interactive-chart-深蹲')),
    );
    expect(chart.unit, '公斤');
    expect(find.text('PR dashboard'), findsNothing);
    expect(
      find.text('Peak strength benchmarks, derived and actual.'),
      findsNothing,
    );

    final milestoneDate = find.text('3月28日');
    await _scrollUntilBuiltAndVisible(
      tester,
      target: milestoneDate,
      scrollable: _verticalScrollable(),
    );
    expect(milestoneDate, findsOneWidget);
    expect(find.text('Mar 28'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  for (final viewport in const [Size(390, 926), Size(390, 568)]) {
    testWidgets(
      'Big Three, chart, and milestones remain reachable at ${viewport.width.toInt()}x${viewport.height.toInt()}',
      (tester) async {
        _setViewport(tester, viewport);

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              databaseRepositoryProvider.overrideWithValue(
                InMemoryDatabaseRepository(),
              ),
              prDashboardDataProvider.overrideWith(
                (ref) => AsyncData(_fakeData()),
              ),
            ],
            child: const MaterialApp(home: PRDashboardScreen()),
          ),
        );
        await tester.pumpAndSettle();

        final squatTop = tester
            .getTopLeft(find.byKey(const ValueKey('strength-card-squat')))
            .dy;
        expect(
          tester
              .getTopLeft(find.byKey(const ValueKey('strength-card-bench')))
              .dy,
          squatTop,
        );
        expect(
          tester
              .getTopLeft(find.byKey(const ValueKey('strength-card-deadlift')))
              .dy,
          squatTop,
        );

        final verticalScroll = _verticalScrollable();
        final position = tester.state<ScrollableState>(verticalScroll).position;
        expect(position.maxScrollExtent, greaterThan(0));

        final chart = find.byKey(const ValueKey('pr-lift-page-view'));
        await tester.scrollUntilVisible(chart, 220, scrollable: verticalScroll);
        await tester.pump();
        final chartRect = tester.getRect(chart);
        expect(chartRect.top, lessThan(viewport.height));
        expect(chartRect.bottom, greaterThan(0));

        final milestones = find.byKey(const ValueKey('view-all-milestones'));
        await tester.scrollUntilVisible(
          milestones,
          220,
          scrollable: verticalScroll,
        );
        await tester.pump();
        final milestoneRect = tester.getRect(milestones);
        expect(milestoneRect.top, lessThan(viewport.height));
        expect(milestoneRect.bottom, greaterThan(0));
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

PRDashboardData _fakeData({bool chinese = false}) {
  final squat = _summary(
    id: 'squat',
    name: chinese ? '深蹲' : 'Competition Squat',
    estimated: [
      _point(DateTime(2026, 3, 1), 127.9),
      _point(DateTime(2026, 3, 16), 139.3),
    ],
    actual: [_point(DateTime(2026, 3, 10), 135.0, actual: true)],
  );
  final bench = _summary(
    id: 'bench_press',
    name: chinese ? '卧推' : 'Bench Press',
    estimated: [
      _point(DateTime(2026, 3, 1), 79.1),
      _point(DateTime(2026, 3, 20), 82.4),
    ],
    actual: [_point(DateTime(2026, 3, 18), 80.0, actual: true)],
  );
  final deadlift = _summary(
    id: 'deadlift',
    name: chinese ? '硬拉' : 'Deadlift',
    estimated: [
      _point(DateTime(2026, 3, 1), 145.0),
      _point(DateTime(2026, 3, 22), 150.7),
    ],
    actual: [_point(DateTime(2026, 3, 12), 147.5, actual: true)],
  );
  final press = _summary(
    id: 'press',
    name: chinese ? '站姿杠铃推举' : 'Standing Barbell Press',
    estimated: [_point(DateTime(2026, 3, 11), 48.3)],
    actual: [],
  );

  return PRDashboardData(
    squat: squat,
    bench: bench,
    deadlift: deadlift,
    allMilestones: [
      PRMilestone(
        date: DateTime(2026, 3, 28),
        exerciseId: squat.exerciseId,
        exerciseName: squat.exerciseName,
        type: PRMilestoneType.estimated,
        label: 'New e1RM PR',
        value: 139.3,
        summary: squat,
      ),
      PRMilestone(
        date: DateTime(2026, 3, 27),
        exerciseId: deadlift.exerciseId,
        exerciseName: deadlift.exerciseName,
        type: PRMilestoneType.estimated,
        label: 'New e1RM PR',
        value: 150.7,
        summary: deadlift,
      ),
      PRMilestone(
        date: DateTime(2026, 3, 16),
        exerciseId: press.exerciseId,
        exerciseName: press.exerciseName,
        type: PRMilestoneType.estimated,
        label: 'New e1RM PR',
        value: 48.3,
        summary: press,
      ),
    ],
  );
}

ExercisePerformancePoint _point(
  DateTime completedAt,
  double value, {
  bool actual = false,
}) {
  return ExercisePerformancePoint(
    completedAt: completedAt,
    weight: value,
    reps: actual ? 1 : 5,
    value: value,
    isActual: actual,
  );
}

ExerciseProgressSummary _summary({
  required String id,
  required String name,
  required List<ExercisePerformancePoint> estimated,
  required List<ExercisePerformancePoint> actual,
}) {
  return ExerciseProgressSummary(
    exerciseId: id,
    exerciseName: name,
    encounterCount: estimated.length + actual.length,
    currentEstimatedOneRepMax: estimated.isEmpty ? null : estimated.last.value,
    bestEstimatedOneRepMax: estimated.isEmpty
        ? null
        : estimated.map((point) => point.value).reduce((a, b) => a > b ? a : b),
    currentActualOneRepMax: actual.isEmpty ? null : actual.last.value,
    bestActualOneRepMax: actual.isEmpty
        ? null
        : actual.map((point) => point.value).reduce((a, b) => a > b ? a : b),
    recentChange: estimated.length < 2
        ? null
        : estimated.last.value - estimated[estimated.length - 2].value,
    totalVolume: 0,
    lastCompletedAt: [
      ...estimated,
      ...actual,
    ].map((point) => point.completedAt).reduce((a, b) => a.isAfter(b) ? a : b),
    isStagnating: false,
    personalRecords: const [],
    estimatedHistory: estimated,
    actualHistory: actual,
  );
}
