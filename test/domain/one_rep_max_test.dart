import 'package:flutter_test/flutter_test.dart';
import 'package:fittin_v2/src/domain/one_rep_max.dart';

void main() {
  test('epley estimate matches expected value', () {
    final value = estimateOneRepMax(
      formula: OneRepMaxFormula.epley,
      weight: 100,
      reps: 5,
    );

    expect(value, closeTo(116.6667, 0.001));
  });

  test('brzycki estimate matches expected value', () {
    final value = estimateOneRepMax(
      formula: OneRepMaxFormula.brzycki,
      weight: 100,
      reps: 5,
    );

    expect(value, closeTo(112.5, 0.001));
  });

  test('wathan estimate matches expected value', () {
    final value = estimateOneRepMax(
      formula: OneRepMaxFormula.wathan,
      weight: 100,
      reps: 5,
    );

    expect(value, closeTo(116.575, 0.01));
  });
}
