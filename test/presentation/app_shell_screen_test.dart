import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fittin_v2/src/application/active_session_provider.dart';
import 'package:fittin_v2/src/application/home_dashboard_provider.dart';
import 'package:fittin_v2/src/application/plan_library_provider.dart';
import 'package:fittin_v2/src/data/database_repository.dart';
import 'package:fittin_v2/src/data/progress_repository.dart';
import 'package:fittin_v2/src/domain/models/body_metric.dart';
import 'package:fittin_v2/src/presentation/screens/app_shell_screen.dart';
import 'package:fittin_v2/src/presentation/screens/body_metrics_screen.dart';
import 'package:fittin_v2/src/presentation/screens/home_dashboard_screen.dart';
import 'package:fittin_v2/src/presentation/widgets/charts/interactive_line_chart.dart';
import 'package:fittin_v2/src/presentation/widgets/today_workout_hero_card.dart';

import '../support/fake_today_workout_gateway.dart';
import '../support/in_memory_database_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('bottom nav opens the plan library tab', (
    WidgetTester tester,
  ) async {
    final repository = InMemoryDatabaseRepository();
    final builtInRecord = StoredTemplateRecord(
      template: fakePlanTemplate,
      isBuiltIn: true,
      sourceTemplateId: null,
      createdAt: DateTime(2026, 3, 12),
      lastModifiedAt: DateTime(2026, 3, 12),
      instanceCount: 1,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseRepositoryProvider.overrideWithValue(repository),
          todayWorkoutGatewayProvider.overrideWithValue(
            FakeTodayWorkoutGateway(),
          ),
          planLibraryItemsProvider.overrideWith(
            (ref) async => [
              PlanLibraryItem(record: builtInRecord, isActive: true),
            ],
          ),
          planLibraryActionProvider.overrideWith(
            (ref) => PlanLibraryActionNotifier(ref),
          ),
        ],
        child: const MaterialApp(home: AppShellScreen()),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Squat'), findsWidgets);
    expect(find.text('Squat Focus'), findsOneWidget);
    expect(find.textContaining('GZCLP 4-Day 12-Week'), findsOneWidget);
    expect(find.textContaining('TSA Intermediate Approach 2.0'), findsNothing);
    expect(find.textContaining('55 mins'), findsOneWidget);
    expect(find.textContaining('3×6+'), findsNothing);
    expect(
      tester.getSemantics(find.byKey(const ValueKey('nav-plan-library'))).label,
      'PLANS',
    );

    await tester.tap(find.byKey(const ValueKey('nav-plan-library')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Plan Library'), findsOneWidget);
    expect(find.text('GZCLP 4-Day 12-Week'), findsOneWidget);
  });
  testWidgets('bottom nav opens the profile settings tab', (
    WidgetTester tester,
  ) async {
    final repository = InMemoryDatabaseRepository();
    final builtInRecord = StoredTemplateRecord(
      template: fakePlanTemplate,
      isBuiltIn: true,
      sourceTemplateId: null,
      createdAt: DateTime(2026, 3, 12),
      lastModifiedAt: DateTime(2026, 3, 12),
      instanceCount: 1,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseRepositoryProvider.overrideWithValue(repository),
          todayWorkoutGatewayProvider.overrideWithValue(
            FakeTodayWorkoutGateway(),
          ),
          planLibraryItemsProvider.overrideWith(
            (ref) async => [
              PlanLibraryItem(record: builtInRecord, isActive: true),
            ],
          ),
          planLibraryActionProvider.overrideWith(
            (ref) => PlanLibraryActionNotifier(ref),
          ),
        ],
        child: const MaterialApp(home: AppShellScreen()),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    await tester.tap(find.byKey(const ValueKey('nav-profile')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('Language'), findsOneWidget);
  });

  for (final viewport in const [Size(390, 926), Size(390, 568)]) {
    testWidgets(
      'Today and Body clear the app-shell nav at ${viewport.width.toInt()}x${viewport.height.toInt()}',
      (tester) async {
        _setViewport(tester, viewport);
        final repository = InMemoryDatabaseRepository();
        final progressRepository = InMemoryProgressRepository();
        await progressRepository.saveBodyMetric(
          BodyMetric(
            metricId: 'shell-body-1',
            timestamp: DateTime(2026, 3, 1),
            weightKg: 80,
            bodyFatPercent: 20,
            waistCm: 90,
          ),
        );
        await progressRepository.saveBodyMetric(
          BodyMetric(
            metricId: 'shell-body-2',
            timestamp: DateTime(2026, 3, 18),
            weightKg: 79.2,
            bodyFatPercent: 19.5,
            waistCm: 88,
          ),
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              databaseRepositoryProvider.overrideWithValue(repository),
              todayWorkoutGatewayProvider.overrideWithValue(
                FakeTodayWorkoutGateway(),
              ),
              homeDashboardDataProvider.overrideWith(
                (ref) async => _shellHomeData(),
              ),
              progressRepositoryProvider.overrideWithValue(progressRepository),
            ],
            child: const MaterialApp(home: AppShellScreen()),
          ),
        );
        await tester.pump();
        await tester.pump(const Duration(seconds: 1));

        final compact = viewport.height < 720;
        expect(find.byType(HomeDashboardScreen), findsOneWidget);
        expect(
          tester
              .widget<TodayWorkoutHeroCard>(find.byType(TodayWorkoutHeroCard))
              .compact,
          compact,
        );

        final homeNavTop = tester
            .getRect(find.byKey(const ValueKey('nav-home')))
            .top;
        final quickAction = find.byKey(const ValueKey('today-quick-action-1'));
        if (compact) {
          final homeScroll = _verticalScrollIn(
            find.byType(HomeDashboardScreen),
          );
          expect(homeScroll, findsOneWidget);
          await tester.scrollUntilVisible(
            quickAction,
            180,
            scrollable: homeScroll,
          );
          await tester.pump();
        }
        final quickRect = tester.getRect(quickAction);
        expect(quickRect.left, greaterThanOrEqualTo(0));
        expect(quickRect.right, lessThanOrEqualTo(viewport.width));
        expect(quickRect.bottom, lessThanOrEqualTo(homeNavTop));

        await tester.tap(find.byKey(const ValueKey('nav-body')));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        expect(find.byType(BodyMetricsScreen), findsOneWidget);
        final bodyNavTop = tester
            .getRect(find.byKey(const ValueKey('nav-body')))
            .top;
        final bodyScroll = find
            .descendant(
              of: find.byType(BodyMetricsScreen),
              matching: find.byType(ListView),
            )
            .first;
        final bodyScrollable = _verticalScrollIn(
          find.byType(BodyMetricsScreen),
        );
        final bodyScrollRect = tester.getRect(bodyScroll);
        expect(bodyScrollRect.left, greaterThanOrEqualTo(0));
        expect(bodyScrollRect.right, lessThanOrEqualTo(viewport.width));
        expect(bodyScrollRect.bottom, lessThanOrEqualTo(bodyNavTop));

        final chart = tester.widget<InteractiveLineChart>(
          find.byKey(const ValueKey('body-weight-chart')),
        );
        expect(chart.height, compact ? 216 : 250);

        final checkIns = find.byKey(
          const ValueKey('body-metric-card-check-ins'),
        );
        await tester.scrollUntilVisible(
          checkIns,
          180,
          scrollable: bodyScrollable,
        );
        await tester.pump();
        final checkInsRect = tester.getRect(checkIns);
        expect(checkInsRect.left, greaterThanOrEqualTo(0));
        expect(checkInsRect.right, lessThanOrEqualTo(viewport.width));
        expect(checkInsRect.bottom, lessThanOrEqualTo(bodyNavTop));
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

Finder _verticalScrollIn(Finder screen) {
  return find.descendant(
    of: screen,
    matching: find.byWidgetPredicate(
      (widget) =>
          widget is Scrollable &&
          widget.physics is! NeverScrollableScrollPhysics &&
          (widget.axisDirection == AxisDirection.down ||
              widget.axisDirection == AxisDirection.up),
    ),
  );
}

HomeDashboardData _shellHomeData() {
  return const HomeDashboardData(
    greetingPeriod: HomeGreetingPeriod.morning,
    displayName: 'Alex',
    todayWorkout: fakeTodayWorkoutSummary,
    weekProgress: 0.25,
    cycleProgress: 0.25,
    sparklineLifts: [],
    milestones: [],
    hasUnreadMilestones: false,
  );
}
