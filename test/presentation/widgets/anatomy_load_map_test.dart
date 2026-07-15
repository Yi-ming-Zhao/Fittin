import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fittin_v2/src/application/active_session_provider.dart';
import 'package:fittin_v2/src/application/advanced_analytics_provider.dart';
import 'package:fittin_v2/src/application/app_locale_provider.dart';
import 'package:fittin_v2/src/domain/exercise_library.dart';
import 'package:fittin_v2/src/presentation/widgets/anatomy_load_map.dart';

import '../../support/in_memory_database_repository.dart';

void main() {
  testWidgets('renders front/back anatomy and taps named muscle paths', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await _pumpMap(tester, overview: _overview);

    expect(find.text('Front'), findsOneWidget);
    expect(find.text('Back'), findsOneWidget);
    expect(find.byKey(const ValueKey('anatomy-front-diagram')), findsOneWidget);
    expect(find.byKey(const ValueKey('anatomy-back-diagram')), findsOneWidget);
    expect(
      find.byKey(const ValueKey('anatomy-intensity-legend')),
      findsOneWidget,
    );
    expect(find.semantics.byLabel('Chest'), findsOne);
    expect(find.semantics.byLabel('Upper back'), findsOne);

    final frontPaint = find.descendant(
      of: find.byKey(const ValueKey('anatomy-front-diagram')),
      matching: find.byType(CustomPaint),
    );
    await tester.tapAt(_designPoint(tester.getRect(frontPaint), 48, 70));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('anatomy-detail-chest')), findsOneWidget);
    expect(find.text('Chest'), findsOneWidget);
    expect(
      find.text('0.9 weighted-set contribution · 2 completed sets'),
      findsOneWidget,
    );

    final backPaint = find.descendant(
      of: find.byKey(const ValueKey('anatomy-back-diagram')),
      matching: find.byType(CustomPaint),
    );
    await tester.tapAt(_designPoint(tester.getRect(backPaint), 60, 70));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('anatomy-detail-upperBack')),
      findsOneWidget,
    );
    expect(find.text('Upper back'), findsOneWidget);
    semantics.dispose();
  });

  testWidgets(
    'keeps the anatomy visible with a localized Chinese no-data state',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final repository = InMemoryDatabaseRepository();
      await repository.saveAppLocale(AppLocale.zh);

      await _pumpMap(
        tester,
        overview: const MuscleLoadOverview(loads: [], totalCompletedSets: 0),
        repository: repository,
      );

      expect(find.text('正面'), findsOneWidget);
      expect(find.text('背面'), findsOneWidget);
      expect(find.text('相对贡献强度'), findsOneWidget);
      expect(find.byKey(const ValueKey('anatomy-no-data')), findsOneWidget);
      expect(find.text('这个时间范围内还没有可映射到肌群的已完成训练组。'), findsOneWidget);
      expect(find.byType(CustomPaint), findsAtLeastNWidgets(2));
    },
  );
}

const _overview = MuscleLoadOverview(
  totalCompletedSets: 2,
  loads: [
    MuscleLoadData(
      muscle: ExerciseMuscle.chest,
      weightedCompletedSets: 0.9,
      contributingCompletedSets: 2,
      normalizedIntensity: 1,
    ),
    MuscleLoadData(
      muscle: ExerciseMuscle.upperBack,
      weightedCompletedSets: 0.4,
      contributingCompletedSets: 2,
      normalizedIntensity: 0.44,
    ),
  ],
);

Future<void> _pumpMap(
  WidgetTester tester, {
  required MuscleLoadOverview overview,
  InMemoryDatabaseRepository? repository,
}) async {
  final database = repository ?? InMemoryDatabaseRepository();
  await tester.pumpWidget(
    ProviderScope(
      overrides: [databaseRepositoryProvider.overrideWithValue(database)],
      child: MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: AnatomyLoadMap(overview: overview),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Offset _designPoint(Rect canvasRect, double designX, double designY) {
  final scale = math.min(canvasRect.width / 120, canvasRect.height / 250);
  final offset = Offset(
    (canvasRect.width - 120 * scale) / 2,
    (canvasRect.height - 250 * scale) / 2,
  );
  return canvasRect.topLeft + offset + Offset(designX * scale, designY * scale);
}
