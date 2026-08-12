import 'package:flutter_test/flutter_test.dart';
import 'package:fittin_v2/src/domain/models/training_plan.dart';
import 'package:fittin_v2/src/domain/weight_tools.dart';

void main() {
  test('converts between kg and lb in both directions', () {
    expect(
      convertWeight(100, LoadUnits.kg, LoadUnits.lbs),
      closeTo(220.462, 0.001),
    );
    expect(
      convertWeight(225, LoadUnits.lbs, LoadUnits.kg),
      closeTo(102.058, 0.001),
    );
  });

  test('computes kilogram plate breakdown per side', () {
    final breakdown = computePlateBreakdown(
      totalWeight: 110,
      unit: LoadUnits.kg,
      barWeight: 20,
    );

    expect(breakdown.exact, true);
    expect(breakdown.platesPerSide.length, 2);
    expect(breakdown.platesPerSide.first.weight, 25);
    expect(breakdown.platesPerSide.first.count, 1);
    expect(breakdown.platesPerSide[1].weight, 20);
    expect(breakdown.platesPerSide[1].count, 1);
  });

  test('reports remaining load when exact pound breakdown is impossible', () {
    final breakdown = computePlateBreakdown(
      totalWeight: 137,
      unit: LoadUnits.lbs,
      barWeight: 45,
    );

    expect(breakdown.exact, false);
    expect(breakdown.unresolvedWeight, greaterThan(0));
  });
}
