import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fittin_v2/src/application/active_session_provider.dart';
import 'package:fittin_v2/src/data/progress_repository.dart';
import 'package:fittin_v2/src/presentation/screens/body_metrics_screen.dart';

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
}
