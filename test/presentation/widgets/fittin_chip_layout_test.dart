import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fittin_v2/src/presentation/theme/fittin_theme.dart';
import 'package:fittin_v2/src/presentation/widgets/fittin_primitives.dart';

void main() {
  testWidgets('plan filters share a row without sacrificing touch size', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(320, 568));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final theme = FittinPaletteRegistry.themeOf(
      FittinPaletteRegistry.defaultId,
    );
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(20),
            child: Wrap(
              spacing: 8,
              children: [
                for (final label in ['全部', '内置', '自定义'])
                  FittinChip(theme, label, key: ValueKey(label), onTap: () {}),
              ],
            ),
          ),
        ),
      ),
    );
    final rects = [
      for (final label in ['全部', '内置', '自定义'])
        tester.getRect(find.byKey(ValueKey(label))),
    ];
    expect(rects.map((r) => r.top).toSet(), hasLength(1));
    for (final rect in rects) {
      expect(rect.width, greaterThanOrEqualTo(44));
      expect(rect.height, greaterThanOrEqualTo(44));
    }
    expect(tester.takeException(), isNull);
  });
}
