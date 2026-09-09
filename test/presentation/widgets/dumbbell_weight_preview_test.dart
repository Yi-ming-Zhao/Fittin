import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fittin_v2/src/presentation/theme/fittin_theme.dart';
import 'package:fittin_v2/src/presentation/widgets/dumbbell_weight_preview.dart';

void main() {
  for (final palette in FittinPaletteRegistry.ids) {
    testWidgets(
      'dumbbell values update and fit narrow space in ${palette.name}',
      (tester) async {
        Future<void> pump(double weight, String unit, bool perHand) =>
            tester.pumpWidget(
              MaterialApp(
                home: Scaffold(
                  body: SizedBox(
                    width: 180,
                    child: DumbbellWeightPreview(
                      theme: FittinPaletteRegistry.themeOf(palette),
                      weight: weight,
                      unit: unit,
                      perHand: perHand,
                      isChinese: true,
                    ),
                  ),
                ),
              ),
            );
        await pump(12.5, 'kg', true);
        expect(find.text('12.5 kg · 每只哑铃'), findsOneWidget);
        await pump(30, 'lbs', false);
        expect(find.text('30 lb · 合计负重'), findsOneWidget);
        expect(find.text('12.5 kg · 每只哑铃'), findsNothing);
        expect(tester.takeException(), isNull);
      },
    );
  }
}
