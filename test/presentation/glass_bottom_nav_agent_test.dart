import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fittin_v2/src/application/active_session_provider.dart';
import 'package:fittin_v2/src/presentation/theme/fittin_theme.dart';
import 'package:fittin_v2/src/presentation/widgets/glass_bottom_nav.dart';

import '../support/in_memory_database_repository.dart';

void main() {
  for (final width in const [320.0, 390.0]) {
    testWidgets(
      'six-tab navigation stays accessible and compact at ${width.toInt()}px',
      (tester) async {
        await tester.binding.setSurfaceSize(Size(width, 160));
        addTearDown(() => tester.binding.setSurfaceSize(null));
        final semantics = tester.ensureSemantics();
        var active = 'home';

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              databaseRepositoryProvider.overrideWithValue(
                InMemoryDatabaseRepository(),
              ),
            ],
            child: MaterialApp(
              home: StatefulBuilder(
                builder: (context, setState) => Scaffold(
                  bottomNavigationBar: FittinTabBar(
                    theme: FittinPaletteRegistry.themeOf(
                      FittinPaletteId.obsidianBrass,
                    ),
                    active: active,
                    onChange: (value) => setState(() => active = value),
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        const keys = [
          'nav-home',
          'nav-plan-library',
          'nav-agent',
          'nav-progress',
          'nav-body',
          'nav-profile',
        ];
        for (final key in keys) {
          final finder = find.byKey(ValueKey(key));
          expect(finder, findsOneWidget);
          final rect = tester.getRect(finder);
          expect(rect.width, greaterThanOrEqualTo(44));
          expect(rect.height, greaterThanOrEqualTo(44));
          expect(rect.left, greaterThanOrEqualTo(0));
          expect(rect.right, lessThanOrEqualTo(width));
        }

        expect(find.text('TODAY'), findsOneWidget);
        expect(find.text('PLANS'), findsNothing);
        expect(
          tester.getSemantics(find.byKey(const ValueKey('nav-agent'))).label,
          'AI',
        );

        await tester.tap(find.byKey(const ValueKey('nav-agent')));
        await tester.pumpAndSettle();
        expect(active, 'agent');
        expect(find.text('AI'), findsOneWidget);
        expect(find.text('TODAY'), findsNothing);
        expect(
          tester.getSemantics(find.byKey(const ValueKey('nav-agent'))),
          // ignore: deprecated_member_use
          containsSemantics(hasSelectedState: true, isSelected: true),
        );
        expect(tester.takeException(), isNull);
        semantics.dispose();
      },
    );
  }
}
