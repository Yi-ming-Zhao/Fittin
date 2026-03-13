import 'dart:math' as math;

enum OneRepMaxFormula {
  epley,
  brzycki,
  landers,
  lombardi,
  mayhew,
  oconner,
  wathan,
}

extension OneRepMaxFormulaX on OneRepMaxFormula {
  String get key => switch (this) {
    OneRepMaxFormula.epley => 'epley',
    OneRepMaxFormula.brzycki => 'brzycki',
    OneRepMaxFormula.landers => 'landers',
    OneRepMaxFormula.lombardi => 'lombardi',
    OneRepMaxFormula.mayhew => 'mayhew',
    OneRepMaxFormula.oconner => 'oconner',
    OneRepMaxFormula.wathan => 'wathan',
  };

  String get label => switch (this) {
    OneRepMaxFormula.epley => 'Epley',
    OneRepMaxFormula.brzycki => 'Brzycki',
    OneRepMaxFormula.landers => 'Landers',
    OneRepMaxFormula.lombardi => 'Lombardi',
    OneRepMaxFormula.mayhew => 'Mayhew',
    OneRepMaxFormula.oconner => "O'Conner",
    OneRepMaxFormula.wathan => 'Wathan',
  };

  static OneRepMaxFormula fromKey(String? key) {
    return OneRepMaxFormula.values.firstWhere(
      (formula) => formula.key == key,
      orElse: () => OneRepMaxFormula.epley,
    );
  }
}

double? estimateOneRepMax({
  required OneRepMaxFormula formula,
  required double weight,
  required int reps,
}) {
  if (weight <= 0 || reps <= 0) {
    return null;
  }

  final value = switch (formula) {
    OneRepMaxFormula.epley => weight * (1 + reps / 30),
    OneRepMaxFormula.brzycki => reps >= 37 ? null : weight * 36 / (37 - reps),
    OneRepMaxFormula.landers =>
      weight / (1.013 - 0.0267123 * reps),
    OneRepMaxFormula.lombardi => weight * math.pow(reps, 0.1),
    OneRepMaxFormula.mayhew =>
      weight / (0.522 + 0.419 * math.pow(math.e, -0.055 * reps)),
    OneRepMaxFormula.oconner => weight * (1 + 0.025 * reps),
    OneRepMaxFormula.wathan =>
      weight / (0.488 + 0.538 * math.pow(math.e, -0.075 * reps)),
  };
  return value?.toDouble();
}
