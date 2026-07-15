import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fittin_v2/src/application/active_session_provider.dart';
import 'package:fittin_v2/src/application/plan_library_provider.dart';
import 'package:fittin_v2/src/data/database_repository.dart';
import 'package:fittin_v2/src/presentation/screens/app_shell_screen.dart';

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
}
