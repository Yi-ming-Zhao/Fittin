class TrainingMaxProfile {
  const TrainingMaxProfile(this.values);

  final Map<String, double> values;

  factory TrainingMaxProfile.fromJson(Map<String, dynamic> json) {
    return TrainingMaxProfile({
      for (final entry in json.entries)
        entry.key: (entry.value as num).toDouble(),
    });
  }

  static const empty = TrainingMaxProfile({});

  bool get isEmpty => values.isEmpty;

  bool get isNotEmpty => values.isNotEmpty;

  double require(String liftKey) {
    final value = values[liftKey];
    if (value == null) {
      throw StateError('Missing training max for "$liftKey".');
    }
    return value;
  }

  Map<String, dynamic> toJson() => values;
}

const canonicalLiftLabels = <String, String>{
  'squat': 'Squat',
  'bench': 'Bench Press',
  'deadlift': 'Deadlift',
  'overhead_press': 'Overhead Press',
};

String liftLabelFor(String liftKey) {
  return canonicalLiftLabels[liftKey] ?? liftKey;
}

double roundToIncrement(double value, double increment) {
  if (increment <= 0) {
    return value;
  }
  return (value / increment).roundToDouble() * increment;
}
