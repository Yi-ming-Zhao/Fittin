import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fittin_v2/src/application/active_session_provider.dart';
import 'package:fittin_v2/src/application/app_locale_provider.dart';
import 'package:fittin_v2/src/domain/models/training_plan.dart';
import 'package:fittin_v2/src/presentation/widgets/weight_tools_sheet.dart';

import '../support/in_memory_database_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('weight tools follows English and Chinese locale copy', (
    tester,
  ) async {
    await _pumpWeightTools(tester, const WeightToolsSheet(initialWeight: 100));

    expect(find.text('Weight Tools'), findsOneWidget);
    expect(find.text('Converted Value'), findsOneWidget);
    expect(find.text('Plate Loading'), findsOneWidget);
    expect(find.text('换算结果'), findsNothing);

    final context = tester.element(find.byType(WeightToolsSheet));
    await ProviderScope.containerOf(
      context,
    ).read(appLocaleProvider.notifier).setLocale(AppLocale.zh);
    await tester.pumpAndSettle();

    expect(find.text('重量工具'), findsOneWidget);
    expect(find.text('换算结果'), findsOneWidget);
    expect(find.text('上片方案'), findsOneWidget);
    expect(find.text('Converted Value'), findsNothing);
    expect(find.text('Plate Loading'), findsNothing);
  });

  testWidgets('weight unit selection maps the stable lb option to LoadUnits', (
    tester,
  ) async {
    double? appliedValue;
    String? appliedUnit;
    await _pumpWeightTools(
      tester,
      WeightToolsSheet(
        initialWeight: 100,
        showApplyButton: true,
        onApply: (value, unit) {
          appliedValue = value;
          appliedUnit = unit;
        },
      ),
    );

    await tester.tap(find.text('lb'));
    await tester.pump();
    final applyButton = find.text('Use for Set');
    await tester.ensureVisible(applyButton);
    await tester.pumpAndSettle();
    await tester.tap(applyButton);
    await tester.pumpAndSettle();

    expect(appliedValue, 100);
    expect(appliedUnit, LoadUnits.lbs);
  });
}

Future<void> _pumpWeightTools(WidgetTester tester, Widget weightTools) async {
  final repository = InMemoryDatabaseRepository();
  await tester.pumpWidget(
    ProviderScope(
      overrides: [databaseRepositoryProvider.overrideWithValue(repository)],
      child: MaterialApp(home: Scaffold(body: weightTools)),
    ),
  );
  await tester.pumpAndSettle();
}
