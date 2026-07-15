import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fittin_v2/src/application/active_session_provider.dart';
import 'package:fittin_v2/src/application/app_locale_provider.dart';
import 'package:fittin_v2/src/application/exercise_library_provider.dart';
import 'package:fittin_v2/src/application/plan_library_provider.dart';
import 'package:fittin_v2/src/data/database_repository.dart';
import 'package:fittin_v2/src/domain/models/training_plan.dart';
import 'package:fittin_v2/src/domain/exercise_library.dart';
import 'package:fittin_v2/src/presentation/screens/plan_library_screen.dart';
import 'package:fittin_v2/src/presentation/widgets/charts/step_chart.dart';

import '../support/fake_today_workout_gateway.dart';
import '../support/in_memory_database_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ExerciseLibrary exerciseLibrary;

  setUpAll(() async {
    exerciseLibrary = await ExerciseLibraryLoader().load();
  });

  testWidgets('plan library renders preview metadata and active state', (
    WidgetTester tester,
  ) async {
    final repository = InMemoryDatabaseRepository();
    final activeRecord = StoredTemplateRecord(
      template: fakePlanTemplate,
      isBuiltIn: true,
      sourceTemplateId: null,
      createdAt: DateTime(2026, 3, 12),
      lastModifiedAt: DateTime(2026, 3, 12),
      instanceCount: 1,
    );
    final secondaryRecord = StoredTemplateRecord(
      template: fakePlanTemplate.copyWith(
        id: 'template-2',
        name: 'Jacked & Tan 2.0 (Balanced)',
        phases: [
          fakePlanTemplate.phases.first.copyWith(
            workouts: [
              fakePlanTemplate.workoutByIndex(0).copyWith(name: 'Squat & Pull'),
              fakePlanTemplate
                  .workoutByIndex(0)
                  .copyWith(id: 'day2', name: 'Bench & Delts'),
              fakePlanTemplate
                  .workoutByIndex(0)
                  .copyWith(id: 'day3', name: 'Lower Pull'),
            ],
          ),
        ],
      ),
      isBuiltIn: false,
      sourceTemplateId: null,
      createdAt: DateTime(2026, 3, 12),
      lastModifiedAt: DateTime(2026, 3, 12),
      instanceCount: 0,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseRepositoryProvider.overrideWithValue(repository),
          planLibraryItemsProvider.overrideWith(
            (ref) async => [
              PlanLibraryItem(record: activeRecord, isActive: true),
              PlanLibraryItem(record: secondaryRecord, isActive: false),
            ],
          ),
          planLibraryActionProvider.overrideWith(
            (ref) => PlanLibraryActionNotifier(ref),
          ),
        ],
        child: const MaterialApp(home: PlanLibraryScreen()),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Plan Library'), findsOneWidget);
    expect(find.text('GZCLP 4-Day 12-Week'), findsOneWidget);
    expect(find.text('Jacked & Tan 2.0 (Balanced)'), findsOneWidget);
    expect(find.text('Built-in'), findsWidgets);
    expect(find.text('Active'), findsOneWidget);
    expect(find.text('1'), findsWidgets);
    expect(find.textContaining('Squat & Pull'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('plan-filter-custom')));
    await tester.pump();
    expect(find.text('GZCLP 4-Day 12-Week'), findsNothing);
    expect(find.text('Jacked & Tan 2.0 (Balanced)'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('plan-filter-built-in')));
    await tester.pump();
    expect(find.text('GZCLP 4-Day 12-Week'), findsOneWidget);
    expect(find.text('Jacked & Tan 2.0 (Balanced)'), findsNothing);
  });

  testWidgets('plan library renders built-in content in Chinese', (
    WidgetTester tester,
  ) async {
    final repository = InMemoryDatabaseRepository();
    await repository.saveAppLocale(AppLocale.zh);
    final activeRecord = StoredTemplateRecord(
      template: fakePlanTemplate,
      isBuiltIn: true,
      sourceTemplateId: null,
      createdAt: DateTime(2026, 3, 12),
      lastModifiedAt: DateTime(2026, 3, 12),
      instanceCount: 1,
    );

    final container = ProviderContainer(
      overrides: [
        databaseRepositoryProvider.overrideWithValue(repository),
        exerciseLibraryProvider.overrideWith((ref) async => exerciseLibrary),
        planLibraryItemsProvider.overrideWith(
          (ref) async => [
            PlanLibraryItem(record: activeRecord, isActive: true),
          ],
        ),
        planLibraryActionProvider.overrideWith(
          (ref) => PlanLibraryActionNotifier(ref),
        ),
      ],
    );
    addTearDown(container.dispose);
    await container.read(appLocaleProvider.notifier).setLocale(AppLocale.zh);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: PlanLibraryScreen()),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('计划库'), findsWidgets);
    expect(find.text('训练计划'), findsOneWidget);
    expect(find.text('GZCLP 四天十二周'), findsOneWidget);
    expect(find.text('深蹲主项日'), findsOneWidget);
    expect(find.text('当前'), findsOneWidget);
    expect(find.text('Training plans'), findsNothing);
    expect(find.text('Active'), findsNothing);

    await tester.tap(find.text('GZCLP 四天十二周'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));

    expect(find.text('深蹲'), findsWidgets);
    expect(find.text('Squat'), findsNothing);
    expect(find.byType(StepChart), findsNothing);
  });

  testWidgets(
    'switching a new TM-driven built-in plan prompts for training maxes',
    (WidgetTester tester) async {
      final repository = InMemoryDatabaseRepository();
      final tmRecord = StoredTemplateRecord(
        template: fakePlanTemplate.copyWith(
          id: 'template-tm',
          name: 'TM Plan',
          engineFamily: 'linear_tm',
          requiredTrainingMaxKeys: const [
            'squat',
            'bench',
            'deadlift',
            'overhead_press',
          ],
        ),
        isBuiltIn: true,
        sourceTemplateId: null,
        createdAt: DateTime(2026, 3, 12),
        lastModifiedAt: DateTime(2026, 3, 12),
        instanceCount: 0,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            databaseRepositoryProvider.overrideWithValue(repository),
            planLibraryItemsProvider.overrideWith(
              (ref) async => [
                PlanLibraryItem(record: tmRecord, isActive: false),
              ],
            ),
            planLibraryActionProvider.overrideWith(
              (ref) => PlanLibraryActionNotifier(ref),
            ),
          ],
          child: const MaterialApp(home: PlanLibraryScreen()),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      final planTitle = find.text('TM Plan');
      await tester.scrollUntilVisible(
        planTitle,
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(planTitle, warnIfMissed: false);
      await tester.pumpAndSettle();

      final switchButtonLabel = find.text('Switch');
      expect(switchButtonLabel, findsOneWidget);
      await tester.tap(switchButtonLabel, warnIfMissed: false);
      await tester.pumpAndSettle();

      expect(find.text('Set Training Maxes'), findsOneWidget);
      expect(find.text('Squat'), findsWidgets);
      expect(find.text('Bench Press'), findsOneWidget);
      expect(find.text('Deadlift'), findsOneWidget);
      expect(find.text('Overhead Press'), findsOneWidget);
      expect(find.text('Quick Start'), findsNothing);
    },
  );

  testWidgets('new plan opens editable missing-load review before activation', (
    WidgetTester tester,
  ) async {
    final repository = InMemoryDatabaseRepository();
    final missingLoadTemplate = fakePlanTemplate.copyWith(
      id: 'missing-load-template',
      name: 'Missing Load Plan',
      phases: [
        fakePlanTemplate.phases.first.copyWith(
          workouts: [
            fakePlanTemplate.workouts.first.copyWith(
              exercises: [
                fakePlanTemplate.workouts.first.exercises.first.copyWith(
                  initialBaseWeight: 0,
                ),
              ],
            ),
          ],
        ),
      ],
    );
    final record = StoredTemplateRecord(
      template: missingLoadTemplate,
      isBuiltIn: false,
      sourceTemplateId: null,
      createdAt: DateTime(2026, 7, 15),
      lastModifiedAt: DateTime(2026, 7, 15),
      instanceCount: 0,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseRepositoryProvider.overrideWithValue(repository),
          exerciseLibraryProvider.overrideWith((ref) async => exerciseLibrary),
          planLibraryItemsProvider.overrideWith(
            (ref) async => [PlanLibraryItem(record: record, isActive: false)],
          ),
          planLibraryActionProvider.overrideWith(
            (ref) => PlanLibraryActionNotifier(ref),
          ),
        ],
        child: const MaterialApp(home: PlanLibraryScreen()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Missing Load Plan'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Switch'));
    await tester.pumpAndSettle();

    expect(find.text('Review starting loads'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('plan-start-load-day1-squat')),
      findsOneWidget,
    );
    expect(find.textContaining('Plan-authored'), findsOneWidget);
  });
}
