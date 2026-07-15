import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fittin_v2/src/application/active_session_provider.dart';
import 'package:fittin_v2/src/application/app_locale_provider.dart';
import 'package:fittin_v2/src/application/template_editor_provider.dart';
import 'package:fittin_v2/src/data/database_repository.dart';
import 'package:fittin_v2/src/domain/models/training_plan.dart';
import 'package:fittin_v2/src/presentation/screens/plan_editor_screen.dart';

import '../support/in_memory_database_repository.dart';

class _StubTemplateEditorNotifier extends TemplateEditorNotifier {
  _StubTemplateEditorNotifier(super.ref, PlanTemplate draft) {
    state = TemplateEditorState(draft: draft);
  }

  @override
  Future<void> loadTemplate(String templateId) async {}

  @override
  void createBlankTemplate() {}

  @override
  Future<StoredTemplateRecord?> saveTemplate() async => null;
}

PlanTemplate _buildLinearTemplate({bool chinese = false}) {
  return PlanTemplate(
    id: 'linear-template',
    name: chinese ? '线性模板' : 'Linear Template',
    description: chinese ? '可复用训练结构' : 'Reusable workout structure',
    engineFamily: 'linear_tm',
    scheduleMode: PlanScheduleModes.linear,
    phases: [
      Phase(
        id: 'phase-1',
        name: chinese ? '阶段一' : 'Phase 1',
        workouts: [
          Workout(
            id: 'workout-a',
            name: chinese ? '训练日 A' : 'Workout A',
            dayLabel: chinese ? '第 1 天' : 'Day 1',
            exercises: [
              Exercise(
                id: 'exercise-1',
                exerciseId: 'squat',
                name: chinese ? '深蹲' : 'Squat',
                stages: [
                  SetScheme(
                    id: 'stage-1',
                    name: chinese ? '阶段一' : 'Stage 1',
                    sets: const [SetDefinition(targetReps: 5, intensity: 0.75)],
                    rules: const [
                      ProgressionRule(
                        condition: 'on_success',
                        actions: [RuleAction(type: 'ADD_WEIGHT', amount: 2.5)],
                      ),
                      ProgressionRule(condition: 'on_failure', actions: []),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

PlanTemplate _buildPeriodizedTemplate() {
  return PlanTemplate(
    id: 'periodized-template',
    name: 'Periodized Template',
    description: 'Week/day slot editor',
    engineFamily: 'periodized_tm',
    scheduleMode: PlanScheduleModes.periodized,
    phases: [
      Phase(
        id: 'phase-1',
        name: 'Phase 1',
        workouts: [
          Workout(
            id: 'workout-a',
            name: 'Workout A',
            dayLabel: 'Day 1',
            exercises: [
              Exercise(
                id: 'exercise-1',
                exerciseId: 'bench',
                name: 'Bench Press',
                stages: [
                  SetScheme(
                    id: 'stage-1',
                    name: 'Week 1',
                    sets: const [SetDefinition(targetReps: 5, intensity: 0.7)],
                    rules: const [],
                  ),
                  SetScheme(
                    id: 'stage-2',
                    name: 'Week 2',
                    sets: const [SetDefinition(targetReps: 3, intensity: 0.8)],
                    rules: const [],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

Future<void> _pumpScreen(
  WidgetTester tester, {
  required PlanTemplate draft,
  bool pushFromHome = false,
  AppLocale locale = AppLocale.en,
}) async {
  final repository = InMemoryDatabaseRepository();
  await repository.saveAppLocale(locale);
  final container = ProviderContainer(
    overrides: [
      databaseRepositoryProvider.overrideWithValue(repository),
      templateEditorProvider.overrideWith(
        (ref) => _StubTemplateEditorNotifier(ref, draft),
      ),
    ],
  );
  addTearDown(container.dispose);
  await container.read(appLocaleProvider.notifier).setLocale(locale);

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        locale: locale.locale,
        home: pushFromHome
            ? Scaffold(
                body: Builder(
                  builder: (context) => Center(
                    child: FilledButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) =>
                                const PlanEditorScreen(templateId: 'ignored'),
                          ),
                        );
                      },
                      child: const Text('Open editor'),
                    ),
                  ),
                ),
              )
            : const PlanEditorScreen(templateId: 'ignored'),
      ),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
}

Future<void> _scrollUntilVisible(WidgetTester tester, Finder finder) async {
  await tester.scrollUntilVisible(
    finder,
    300,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.pump(const Duration(milliseconds: 300));
}

void main() {
  testWidgets(
    'plan editor keeps linear templates in the reusable workout flow',
    (WidgetTester tester) async {
      await _pumpScreen(tester, draft: _buildLinearTemplate());

      expect(
        find.text('Linear plans are edited as reusable workout structures.'),
        findsOneWidget,
      );
      expect(find.text('Schedule Mode'), findsWidgets);
      expect(find.text('Week/Day Slot'), findsNothing);
      expect(find.textContaining('W1D1'), findsNothing);
      expect(find.text('Template'), findsWidgets);
      expect(find.text('Description'), findsOneWidget);

      await _scrollUntilVisible(tester, find.text('Exercise Name'));
      expect(find.text('Exercise Name'), findsOneWidget);
      expect(find.text('动作名称'), findsNothing);

      await _scrollUntilVisible(tester, find.text('Equipment'));
      expect(find.text('Equipment'), findsOneWidget);
      expect(find.text('TM Mapping'), findsOneWidget);

      await _scrollUntilVisible(tester, find.text('Target RPE'));
      expect(find.text('Target RPE'), findsOneWidget);

      await _scrollUntilVisible(tester, find.text('Action'));
      expect(find.text('Action'), findsOneWidget);
      expect(find.text('Add Weight'), findsOneWidget);

      await _scrollUntilVisible(tester, find.text('On Success'));
      expect(find.text('On Success'), findsOneWidget);
      expect(find.text('On Failure'), findsOneWidget);

      await _scrollUntilVisible(tester, find.text('Add Workout'));
      expect(find.text('Add Workout'), findsOneWidget);
    },
  );

  testWidgets('plan editor shows a dashboard back button when pushed', (
    WidgetTester tester,
  ) async {
    await _pumpScreen(
      tester,
      draft: _buildLinearTemplate(),
      pushFromHome: true,
    );

    await tester.tap(find.text('Open editor'));
    await tester.pumpAndSettle();

    final backButton = find.byKey(const ValueKey('dashboard-header-back'));
    expect(backButton, findsOneWidget);

    await tester.tap(backButton);
    await tester.pumpAndSettle();

    expect(find.text('Open editor'), findsOneWidget);
    expect(find.byType(PlanEditorScreen), findsNothing);
  });

  testWidgets('plan editor focuses periodized templates by week and day slot', (
    WidgetTester tester,
  ) async {
    await _pumpScreen(tester, draft: _buildPeriodizedTemplate());

    expect(
      find.text('Edit periodized plans by week/day slot.'),
      findsOneWidget,
    );
    expect(find.text('On Success'), findsNothing);
    expect(find.text('On Failure'), findsNothing);

    expect(find.text('Periodized Template'), findsWidgets);
    expect(find.text('On Success'), findsNothing);
    expect(find.text('On Failure'), findsNothing);
  });

  testWidgets('plan editor renders its editing controls in Chinese', (
    WidgetTester tester,
  ) async {
    await _pumpScreen(
      tester,
      draft: _buildLinearTemplate(chinese: true),
      locale: AppLocale.zh,
    );

    expect(find.text('线性计划按可复用训练日整体编辑。'), findsOneWidget);
    expect(find.text('模板'), findsWidgets);
    expect(find.text('描述'), findsOneWidget);
    expect(
      find.text('Linear plans are edited as reusable workout structures.'),
      findsNothing,
    );
    expect(find.text('Template'), findsNothing);
    expect(find.text('Description'), findsNothing);

    await tester.enterText(find.widgetWithText(TextField, '计划名称'), '');
    await tester.pump();
    expect(find.text('校验问题'), findsWidgets);
    expect(find.text('• 计划名称不能为空。'), findsOneWidget);
    expect(find.text('Template name is required.'), findsNothing);

    await _scrollUntilVisible(tester, find.text('动作名称'));
    expect(find.text('动作名称'), findsOneWidget);
    expect(find.text('Exercise Name'), findsNothing);

    await _scrollUntilVisible(tester, find.text('器械类型'));
    expect(find.text('器械类型'), findsOneWidget);
    expect(find.text('训练最大值映射'), findsOneWidget);
    expect(find.text('Equipment'), findsNothing);
    expect(find.text('TM Mapping'), findsNothing);

    await _scrollUntilVisible(tester, find.text('目标 RPE'));
    expect(find.text('目标 RPE'), findsOneWidget);
    expect(find.text('Target RPE'), findsNothing);

    await _scrollUntilVisible(tester, find.text('操作'));
    expect(find.text('操作'), findsOneWidget);
    expect(find.text('增加重量'), findsOneWidget);
    expect(find.text('Action'), findsNothing);
    expect(find.text('Add Weight'), findsNothing);
  });
}
