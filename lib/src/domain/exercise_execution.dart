enum ExerciseLaterality { bilateral, unilateral, alternating }

enum ExerciseGrip { standard, pronated, supinated, neutral, mixed, hook }

enum ExercisePosition {
  standing,
  seated,
  supine,
  prone,
  incline,
  decline,
  hanging,
  kneeling,
}

enum ExerciseMeasurement { repetitions, duration, distance }

class ExerciseExecution {
  const ExerciseExecution({
    this.laterality = ExerciseLaterality.bilateral,
    this.grip = ExerciseGrip.standard,
    this.position = ExercisePosition.standing,
    this.measurement = ExerciseMeasurement.repetitions,
    this.techniques = const [],
    this.equipmentVariant = '',
  });
  final ExerciseLaterality laterality;
  final ExerciseGrip grip;
  final ExercisePosition position;
  final ExerciseMeasurement measurement;
  final List<String> techniques;
  final String equipmentVariant;
  static const supportedTechniques = {
    'paused',
    'tempo',
    'dropSet',
    'twentyOne',
    'assisted',
    'explosive',
    'isometric',
    'partial',
    'deficit',
    'elevated',
    'constantTension',
  };
  static const equipmentVariants = {
    '',
    'kettlebell',
    'trapBar',
    'smithMachine',
    'ezBar',
    'safetyBar',
    'landmine',
    'rings',
    'suspension',
    'medicineBall',
    'sled',
    'resistanceBand',
  };

  factory ExerciseExecution.fromJson(Map<String, dynamic> json) {
    const keys = {
      'laterality',
      'grip',
      'position',
      'measurement',
      'techniques',
      'equipmentVariant',
    };
    if (json.keys.any((key) => !keys.contains(key))) {
      throw const FormatException('Unknown execution field.');
    }
    final techniques = (json['techniques'] as List? ?? const []).cast<String>();
    final variant = json['equipmentVariant'] as String? ?? '';
    if (techniques.length > 6 ||
        techniques.toSet().length != techniques.length ||
        techniques.any((value) => !supportedTechniques.contains(value)) ||
        !equipmentVariants.contains(variant)) {
      throw const FormatException(
        'Unsupported exercise technique or equipment variation.',
      );
    }
    return ExerciseExecution(
      laterality: ExerciseLaterality.values.byName(
        json['laterality'] as String? ?? 'bilateral',
      ),
      grip: ExerciseGrip.values.byName(json['grip'] as String? ?? 'standard'),
      position: ExercisePosition.values.byName(
        json['position'] as String? ?? 'standing',
      ),
      measurement: ExerciseMeasurement.values.byName(
        json['measurement'] as String? ?? 'repetitions',
      ),
      techniques: List.unmodifiable(techniques),
      equipmentVariant: variant,
    );
  }

  Map<String, dynamic> toJson() => {
    'laterality': laterality.name,
    'grip': grip.name,
    'position': position.name,
    'measurement': measurement.name,
    'techniques': techniques,
    'equipmentVariant': equipmentVariant,
  };

  static const labels = {
    'bilateral': '双侧',
    'unilateral': '单侧',
    'alternating': '交替',
    'standard': '常规握法',
    'pronated': '正握',
    'supinated': '反握',
    'neutral': '中立握',
    'mixed': '正反握',
    'hook': '锁握',
    'standing': '站姿',
    'seated': '坐姿',
    'supine': '仰卧',
    'prone': '俯卧',
    'incline': '上斜',
    'decline': '下斜',
    'hanging': '悬垂',
    'kneeling': '跪姿',
    'repetitions': '次数',
    'duration': '计时',
    'distance': '距离',
    'paused': '暂停',
    'tempo': '节奏控制',
    'dropSet': '递减组',
    'twentyOne': '21 次分段',
    'assisted': '辅助',
    'explosive': '爆发',
    'isometric': '等长保持',
    'partial': '部分幅度',
    'deficit': '站高位',
    'elevated': '垫高',
    'constantTension': '持续张力',
    'kettlebell': '壶铃',
    'trapBar': '六角杠',
    'smithMachine': '史密斯机',
    'ezBar': '曲杆',
    'safetyBar': '安全杠',
    'landmine': '地雷架',
    'rings': '吊环',
    'suspension': '悬吊带',
    'medicineBall': '药球',
    'sled': '雪橇',
    'resistanceBand': '弹力带',
  };
  static String label(String value, bool zh) => zh
      ? labels[value] ?? value
      : value.replaceAllMapped(
          RegExp(r'([a-z])([A-Z])'),
          (match) => '${match[1]} ${match[2]}',
        );

  String summary(bool zh) {
    final values = [
      laterality.name,
      position.name,
      if (grip != ExerciseGrip.standard) grip.name,
      if (measurement != ExerciseMeasurement.repetitions) measurement.name,
      if (equipmentVariant.isNotEmpty) equipmentVariant,
      ...techniques,
    ];
    return values.map((value) => label(value, zh)).join(' · ');
  }
}
