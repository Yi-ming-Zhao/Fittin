import 'package:fittin_v2/src/application/app_locale_provider.dart';
import 'package:fittin_v2/src/application/fittin_theme_provider.dart';
import 'package:fittin_v2/src/domain/exercise_library.dart';
import 'package:fittin_v2/src/domain/models/custom_exercise.dart';
import 'package:fittin_v2/src/presentation/localization/app_strings.dart';
import 'package:fittin_v2/src/presentation/theme/fittin_theme.dart';
import 'package:fittin_v2/src/presentation/widgets/dashboard_primitives.dart';
import 'package:fittin_v2/src/presentation/widgets/exercise_catalog_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final theme = FittinPaletteRegistry.themeOf(FittinPaletteRegistry.defaultId);

  testWidgets('dashboard page presets keep root and detail rhythm explicit', (
    tester,
  ) async {
    _setViewport(tester, const Size(320, 568));

    Future<void> pump(DashboardPageLayout layout) => tester.pumpWidget(
      ProviderScope(
        overrides: [resolvedFittinThemeProvider.overrideWithValue(theme)],
        child: MaterialApp(
          home: DashboardPageScaffold(
            layout: layout,
            children: const [SizedBox(key: ValueKey('page-content'))],
          ),
        ),
      ),
    );

    await pump(DashboardPageLayout.root);
    var list = tester.widget<ListView>(find.byType(ListView));
    var safeArea = tester.widget<SafeArea>(find.byType(SafeArea));
    expect(list.padding, const EdgeInsets.fromLTRB(20, 24, 20, 24));
    expect(safeArea.bottom, isFalse);

    await pump(DashboardPageLayout.detail);
    list = tester.widget<ListView>(find.byType(ListView));
    safeArea = tester.widget<SafeArea>(find.byType(SafeArea));
    expect(list.padding, const EdgeInsets.fromLTRB(20, 20, 20, 24));
    expect(safeArea.bottom, isTrue);
  });

  for (final viewport in const [
    Size(320, 568),
    Size(390, 568),
    Size(390, 844),
    Size(390, 926),
  ]) {
    testWidgets(
      'dashboard header adapts controls at ${viewport.width.toInt()}px',
      (tester) async {
        _setViewport(tester, viewport);
        await tester.pumpWidget(
          ProviderScope(
            overrides: [resolvedFittinThemeProvider.overrideWithValue(theme)],
            child: MaterialApp(
              home: Scaffold(
                body: Padding(
                  padding: const EdgeInsets.all(20),
                  child: DashboardScreenHeader(
                    eyebrow: 'DETAIL',
                    title: 'A deliberately long detail page title',
                    subtitle: 'Secondary context remains readable.',
                    showBackButton: true,
                    trailing: const SizedBox(
                      key: ValueKey('header-trailing'),
                      width: 44,
                      height: 44,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );

        final compact = find.byKey(
          const ValueKey('dashboard-header-utility-row'),
        );
        final title = find.byKey(
          const ValueKey('dashboard-header-title-block'),
        );
        if (viewport.width < 360) {
          expect(compact, findsOneWidget);
          expect(
            tester.getTopLeft(title).dy,
            greaterThan(tester.getBottomLeft(compact).dy),
          );
        } else {
          expect(compact, findsNothing);
          expect(
            tester.getTopLeft(title).dy,
            lessThan(
              tester
                  .getBottomLeft(find.byKey(const ValueKey('header-trailing')))
                  .dy,
            ),
          );
        }
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets('dashboard centers its readable column on desktop', (
    tester,
  ) async {
    _setViewport(tester, const Size(1024, 768));
    await tester.pumpWidget(
      ProviderScope(
        overrides: [resolvedFittinThemeProvider.overrideWithValue(theme)],
        child: MaterialApp(
          home: DashboardPageScaffold(
            children: const [
              SizedBox(
                key: ValueKey('desktop-page-content'),
                width: double.infinity,
                height: 40,
              ),
            ],
          ),
        ),
      ),
    );

    final content = tester.getRect(
      find.byKey(const ValueKey('desktop-page-content')),
    );
    expect(content.width, 390);
    expect(content.center.dx, 512);
    expect(tester.takeException(), isNull);
  });

  for (final scenario in const [
    (label: '320x568 keyboard', size: Size(320, 568), keyboardInset: 180.0),
    (label: '390x568 keyboard', size: Size(390, 568), keyboardInset: 180.0),
    (label: '390x844', size: Size(390, 844), keyboardInset: 0.0),
    (label: '390x926', size: Size(390, 926), keyboardInset: 0.0),
    (label: 'desktop', size: Size(1024, 768), keyboardInset: 0.0),
  ]) {
    testWidgets(
      'representative detail scaffold covers ${scenario.label} at 1.6x',
      (tester) async {
        _setViewport(tester, scenario.size);
        if (scenario.keyboardInset > 0) {
          addTearDown(tester.view.resetViewInsets);
        }
        await tester.pumpWidget(
          ProviderScope(
            overrides: [resolvedFittinThemeProvider.overrideWithValue(theme)],
            child: MaterialApp(
              builder: (context, child) => MediaQuery(
                data: MediaQuery.of(
                  context,
                ).copyWith(textScaler: const TextScaler.linear(1.6)),
                child: child!,
              ),
              home: DashboardPageScaffold(
                layout: DashboardPageLayout.detail,
                children: [
                  DashboardScreenHeader(
                    eyebrow: '训练设置',
                    title: '深层页面响应式布局检查',
                    subtitle: '长标题和辅助说明在窄屏、大字体下保持清晰。',
                    showBackButton: true,
                    trailing: IconButton(
                      key: const ValueKey('detail-scenario-action'),
                      tooltip: '新增',
                      onPressed: () {},
                      icon: const Icon(Icons.add_rounded),
                    ),
                  ),
                  const SizedBox(height: 20),
                  DashboardSurfaceCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text('可编辑内容'),
                        const SizedBox(height: 12),
                        const TextField(
                          key: ValueKey('detail-scenario-text-field'),
                          decoration: InputDecoration(labelText: '名称'),
                        ),
                        const SizedBox(height: 180),
                        FilledButton(
                          key: const ValueKey('detail-scenario-save'),
                          onPressed: () {},
                          child: const Text('保存修改'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        if (scenario.keyboardInset > 0) {
          tester.view.viewInsets = FakeViewPadding(
            bottom: scenario.keyboardInset,
          );
          await tester.showKeyboard(
            find.byKey(const ValueKey('detail-scenario-text-field')),
          );
          await tester.pumpAndSettle();
        }

        final save = find.byKey(const ValueKey('detail-scenario-save'));
        await Scrollable.ensureVisible(
          tester.element(save),
          alignment: 1,
          duration: Duration.zero,
        );
        await tester.pumpAndSettle();
        final saveRect = tester.getRect(save);
        final media = MediaQuery.of(tester.element(save));
        final visibleBottom = media.size.height - media.viewInsets.bottom;
        expect(saveRect.bottom, lessThanOrEqualTo(visibleBottom + 0.01));
        expect(saveRect.height, greaterThanOrEqualTo(44));
        final fieldRect = tester.getRect(
          find.byKey(const ValueKey('detail-scenario-text-field')),
        );
        expect(fieldRect.width, lessThanOrEqualTo(390));
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets('large Chinese header preserves controls and touch targets', (
    tester,
  ) async {
    _setViewport(tester, const Size(320, 568));
    await tester.pumpWidget(
      ProviderScope(
        overrides: [resolvedFittinThemeProvider.overrideWithValue(theme)],
        child: MaterialApp(
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: const TextScaler.linear(1.6)),
            child: child!,
          ),
          home: Scaffold(
            body: Padding(
              padding: const EdgeInsets.all(20),
              child: DashboardScreenHeader(
                eyebrow: '训练设置',
                title: '这是一个较长的深层页面标题',
                subtitle: '辅助说明在大字体下仍需保持完整可读。',
                showBackButton: true,
                trailing: IconButton(
                  key: const ValueKey('large-text-header-action'),
                  onPressed: null,
                  icon: const Icon(Icons.add_rounded),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    expect(
      find.byKey(const ValueKey('dashboard-header-utility-row')),
      findsOneWidget,
    );
    final backSize = tester.getSize(
      find.byKey(const ValueKey('dashboard-header-back')),
    );
    final actionSize = tester.getSize(
      find.byKey(const ValueKey('large-text-header-action')),
    );
    expect(backSize.width, greaterThanOrEqualTo(44));
    expect(backSize.height, greaterThanOrEqualTo(44));
    expect(actionSize.width, greaterThanOrEqualTo(44));
    expect(actionSize.height, greaterThanOrEqualTo(44));
    expect(tester.takeException(), isNull);
  });

  testWidgets('exercise catalog fits above the keyboard at 320px', (
    tester,
  ) async {
    _setViewport(tester, const Size(320, 568));
    tester.view.viewInsets = const FakeViewPadding(bottom: 300);
    addTearDown(tester.view.resetViewInsets);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ExerciseCatalogSheet(
            theme: theme,
            strings: const AppStrings(AppLocale.en),
            localeCode: 'en',
            items: const [_catalogItem],
            onSelected: (_) {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final frame = find.byKey(const ValueKey('exercise-catalog-sheet-frame'));
    expect(tester.getSize(frame).height, closeTo(268, 0.01));
    expect(tester.getBottomLeft(frame).dy, lessThanOrEqualTo(268));
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'exercise catalog stays scrollable with keyboard and large text',
    (tester) async {
      _setViewport(tester, const Size(320, 568));
      tester.view.viewInsets = const FakeViewPadding(bottom: 260);
      addTearDown(tester.view.resetViewInsets);

      await tester.pumpWidget(
        MaterialApp(
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: const TextScaler.linear(1.6)),
            child: child!,
          ),
          home: Scaffold(
            body: ExerciseCatalogSheet(
              theme: theme,
              strings: const AppStrings(AppLocale.zh),
              localeCode: 'zh',
              items: const [_catalogItem],
              onSelected: (_) {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final scrollable = find.descendant(
        of: find.byKey(const ValueKey('exercise-catalog-scroll')),
        matching: find.byType(Scrollable),
      );
      expect(scrollable, findsWidgets);
      expect(tester.takeException(), isNull);
    },
  );
}

const _catalogItem = ExerciseCatalogItem(
  id: 'squat',
  nameEn: 'Squat',
  nameZhCn: '深蹲',
  movement: ExerciseMovement.squat,
  equipment: ExerciseEquipment.barbell,
  loadSemantics: ExerciseLoadSemantics.totalExternal,
  primaryMuscles: [ExerciseMuscle.quadriceps],
  secondaryMuscles: [ExerciseMuscle.glutes],
  tags: ['barbell', 'legs'],
  roundingIncrementKg: 2.5,
  isBuiltIn: true,
);

void _setViewport(WidgetTester tester, Size size) {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}
