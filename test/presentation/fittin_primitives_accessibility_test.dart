// Keep Flutter 3.35 compatibility until the repository minimum moves to 3.41.
// ignore_for_file: deprecated_member_use

import 'package:fittin_v2/src/presentation/theme/fittin_theme.dart';
import 'package:fittin_v2/src/presentation/widgets/fittin_primitives.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('segmented options expose selection and 44px tap targets', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    var selected = 'One';

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 220,
              child: StatefulBuilder(
                builder: (context, setState) => FittinSegmented(
                  theme: FittinPaletteRegistry.themeOf(
                    FittinPaletteId.obsidianBrass,
                  ),
                  options: const ['One', 'Two'],
                  value: selected,
                  expand: true,
                  onChange: (value) => setState(() => selected = value),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    final first = find.bySemanticsLabel('One');
    final second = find.bySemanticsLabel('Two');
    expect(tester.getRect(first).height, greaterThanOrEqualTo(44));
    expect(tester.getRect(first).width, greaterThanOrEqualTo(44));
    expect(
      tester.getSemantics(first),
      containsSemantics(
        isButton: true,
        hasSelectedState: true,
        isSelected: true,
        isInMutuallyExclusiveGroup: true,
        hasTapAction: true,
      ),
    );

    await tester.tap(second);
    await tester.pump();

    expect(selected, 'Two');
    expect(
      tester.getSemantics(second),
      containsSemantics(
        isButton: true,
        hasSelectedState: true,
        isSelected: true,
        isInMutuallyExclusiveGroup: true,
        hasTapAction: true,
      ),
    );
    semantics.dispose();
  });
}
