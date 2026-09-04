enum CardioMetricKey {
  durationSeconds,
  distanceMeters,
  averageSpeedMps,
  paceSecondsPerKm,
  inclinePercent,
  averageHeartRateBpm,
  maxHeartRateBpm,
  cadencePerMinute,
  elevationGainMeters,
  caloriesKcal,
  steps,
  strokesPerMinute,
  poolLengthMeters,
}

enum CardioActivityIcon {
  run,
  incline,
  bike,
  row,
  stairs,
  swim,
  elliptical,
  generic,
}

class CardioActivityDefinition {
  CardioActivityDefinition({
    required this.id,
    required this.nameEn,
    required this.nameZhCn,
    required this.icon,
    required Iterable<CardioMetricKey> requiredMetrics,
    required Iterable<CardioMetricKey> optionalMetrics,
    this.isBuiltIn = false,
  }) : requiredMetrics = Set.unmodifiable(requiredMetrics),
       optionalMetrics = Set.unmodifiable(optionalMetrics) {
    validate();
  }

  final String id;
  final String nameEn;
  final String nameZhCn;
  final CardioActivityIcon icon;
  final Set<CardioMetricKey> requiredMetrics;
  final Set<CardioMetricKey> optionalMetrics;
  final bool isBuiltIn;

  String displayName(String localeCode) =>
      localeCode.toLowerCase().startsWith('zh') ? nameZhCn : nameEn;

  Set<CardioMetricKey> get allowedMetrics => {
    ...requiredMetrics,
    ...optionalMetrics,
  };

  void validate() {
    if (id.trim().isEmpty || id.length > 120) {
      throw const FormatException('Cardio activity ID is invalid.');
    }
    if (nameEn.trim().isEmpty || nameZhCn.trim().isEmpty) {
      throw const FormatException('Cardio activity names cannot be empty.');
    }
    if (requiredMetrics.isEmpty ||
        !requiredMetrics.contains(CardioMetricKey.durationSeconds) ||
        requiredMetrics.intersection(optionalMetrics).isNotEmpty) {
      throw const FormatException('Cardio metric schema is invalid.');
    }
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'nameEn': nameEn,
    'nameZhCn': nameZhCn,
    'icon': icon.name,
    'requiredMetrics': requiredMetrics.map((value) => value.name).toList(),
    'optionalMetrics': optionalMetrics.map((value) => value.name).toList(),
    'isBuiltIn': isBuiltIn,
  };

  factory CardioActivityDefinition.fromJson(Map<String, dynamic> json) =>
      CardioActivityDefinition(
        id: json['id'] as String,
        nameEn: json['nameEn'] as String,
        nameZhCn: json['nameZhCn'] as String,
        icon: CardioActivityIcon.values.byName(json['icon'] as String),
        requiredMetrics: (json['requiredMetrics'] as List).cast<String>().map(
          CardioMetricKey.values.byName,
        ),
        optionalMetrics: (json['optionalMetrics'] as List? ?? const [])
            .cast<String>()
            .map(CardioMetricKey.values.byName),
        isBuiltIn: json['isBuiltIn'] as bool? ?? false,
      );
}

class CardioRecord {
  CardioRecord({
    required this.id,
    required this.activityTypeId,
    required this.activityName,
    required this.startedAt,
    required Map<CardioMetricKey, double> metrics,
    this.note,
    this.source = 'manual',
    this.sourceFingerprint,
  }) : metrics = Map.unmodifiable(_withDerivedMetrics(metrics));

  final String id;
  final String activityTypeId;
  final String activityName;
  final DateTime startedAt;
  final Map<CardioMetricKey, double> metrics;
  final String? note;
  final String source;
  final String? sourceFingerprint;

  double? metric(CardioMetricKey key) => metrics[key];

  void validate(CardioActivityDefinition definition) {
    if (id.trim().isEmpty || activityTypeId != definition.id) {
      throw const FormatException('Cardio record identity is invalid.');
    }
    for (final required in definition.requiredMetrics) {
      if (!metrics.containsKey(required)) {
        throw FormatException('Missing cardio metric: ${required.name}.');
      }
    }
    final allowed = {
      ...definition.allowedMetrics,
      CardioMetricKey.averageSpeedMps,
      CardioMetricKey.paceSecondsPerKm,
    };
    if (!allowed.containsAll(metrics.keys)) {
      throw const FormatException('Cardio record contains unsupported data.');
    }
    for (final entry in metrics.entries) {
      validateCardioMetricValue(entry.key, entry.value);
    }
    if (note != null && note!.length > 500) {
      throw const FormatException('Cardio note is too long.');
    }
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'activityTypeId': activityTypeId,
    'activityName': activityName,
    'startedAt': startedAt.toUtc().toIso8601String(),
    'metrics': {
      for (final entry in metrics.entries) entry.key.name: entry.value,
    },
    'note': note,
    'source': source,
    'sourceFingerprint': sourceFingerprint,
  };

  factory CardioRecord.fromJson(Map<String, dynamic> json) => CardioRecord(
    id: json['id'] as String,
    activityTypeId: json['activityTypeId'] as String,
    activityName: json['activityName'] as String,
    startedAt: DateTime.parse(json['startedAt'] as String).toLocal(),
    metrics: (json['metrics'] as Map<String, dynamic>).map(
      (key, value) => MapEntry(
        CardioMetricKey.values.byName(key),
        (value as num).toDouble(),
      ),
    ),
    note: json['note'] as String?,
    source: json['source'] as String? ?? 'manual',
    sourceFingerprint: json['sourceFingerprint'] as String?,
  );
}

Map<CardioMetricKey, double> _withDerivedMetrics(
  Map<CardioMetricKey, double> source,
) {
  final result = Map<CardioMetricKey, double>.from(source);
  final duration = result[CardioMetricKey.durationSeconds];
  final distance = result[CardioMetricKey.distanceMeters];
  if (duration != null && distance != null && distance > 0) {
    result.putIfAbsent(
      CardioMetricKey.averageSpeedMps,
      () => distance / duration,
    );
    result.putIfAbsent(
      CardioMetricKey.paceSecondsPerKm,
      () => duration / (distance / 1000),
    );
  }
  return result;
}

void validateCardioMetricValue(CardioMetricKey key, double value) {
  if (!value.isFinite || value < 0) {
    throw FormatException('Invalid cardio metric: ${key.name}.');
  }
  final valid = switch (key) {
    CardioMetricKey.durationSeconds => value > 0 && value <= 604800,
    CardioMetricKey.distanceMeters => value <= 1000000,
    CardioMetricKey.averageSpeedMps => value <= 50,
    CardioMetricKey.paceSecondsPerKm => value >= 60 && value <= 7200,
    CardioMetricKey.inclinePercent => value <= 40,
    CardioMetricKey.averageHeartRateBpm || CardioMetricKey.maxHeartRateBpm =>
      value == 0 || (value >= 30 && value <= 260),
    CardioMetricKey.cadencePerMinute => value <= 400,
    CardioMetricKey.elevationGainMeters => value <= 20000,
    CardioMetricKey.caloriesKcal => value <= 30000,
    CardioMetricKey.steps => value <= 1000000,
    CardioMetricKey.strokesPerMinute => value <= 200,
    CardioMetricKey.poolLengthMeters =>
      value == 0 || (value >= 10 && value <= 100),
  };
  if (!valid) throw FormatException('Cardio metric out of range: ${key.name}.');
}

class CardioImportPreview {
  CardioImportPreview({
    required this.sourceName,
    required this.sourceFingerprint,
    required List<CardioRecord> records,
    required List<String> warnings,
    required Set<String> duplicateRecordIds,
  }) : records = List.unmodifiable(records),
       warnings = List.unmodifiable(warnings),
       duplicateRecordIds = Set.unmodifiable(duplicateRecordIds);

  final String sourceName;
  final String sourceFingerprint;
  final List<CardioRecord> records;
  final List<String> warnings;
  final Set<String> duplicateRecordIds;

  List<CardioRecord> get newRecords => records
      .where((record) => !duplicateRecordIds.contains(record.id))
      .toList(growable: false);
}

abstract final class BuiltInCardioActivities {
  static final List<CardioActivityDefinition> all = [
    _activity(
      'cardio:running',
      'Running',
      '跑步',
      CardioActivityIcon.run,
      required: const [
        CardioMetricKey.durationSeconds,
        CardioMetricKey.distanceMeters,
      ],
      optional: const [
        CardioMetricKey.averageSpeedMps,
        CardioMetricKey.paceSecondsPerKm,
        CardioMetricKey.averageHeartRateBpm,
        CardioMetricKey.maxHeartRateBpm,
        CardioMetricKey.cadencePerMinute,
        CardioMetricKey.elevationGainMeters,
        CardioMetricKey.caloriesKcal,
      ],
    ),
    _activity(
      'cardio:incline-walking',
      'Incline walking',
      '爬坡走',
      CardioActivityIcon.incline,
      required: const [
        CardioMetricKey.durationSeconds,
        CardioMetricKey.averageSpeedMps,
        CardioMetricKey.inclinePercent,
      ],
      optional: const [
        CardioMetricKey.distanceMeters,
        CardioMetricKey.averageHeartRateBpm,
        CardioMetricKey.caloriesKcal,
        CardioMetricKey.steps,
      ],
    ),
    _activity(
      'cardio:cycling',
      'Cycling',
      '骑行',
      CardioActivityIcon.bike,
      required: const [CardioMetricKey.durationSeconds],
      optional: const [
        CardioMetricKey.distanceMeters,
        CardioMetricKey.averageSpeedMps,
        CardioMetricKey.averageHeartRateBpm,
        CardioMetricKey.cadencePerMinute,
        CardioMetricKey.elevationGainMeters,
        CardioMetricKey.caloriesKcal,
      ],
    ),
    _activity(
      'cardio:rowing',
      'Rowing',
      '划船机',
      CardioActivityIcon.row,
      required: const [CardioMetricKey.durationSeconds],
      optional: const [
        CardioMetricKey.distanceMeters,
        CardioMetricKey.paceSecondsPerKm,
        CardioMetricKey.strokesPerMinute,
        CardioMetricKey.averageHeartRateBpm,
        CardioMetricKey.caloriesKcal,
      ],
    ),
    _activity(
      'cardio:stairs',
      'Stair climbing',
      '爬楼',
      CardioActivityIcon.stairs,
      required: const [CardioMetricKey.durationSeconds],
      optional: const [
        CardioMetricKey.steps,
        CardioMetricKey.averageHeartRateBpm,
        CardioMetricKey.caloriesKcal,
      ],
    ),
    _activity(
      'cardio:swimming',
      'Swimming',
      '游泳',
      CardioActivityIcon.swim,
      required: const [
        CardioMetricKey.durationSeconds,
        CardioMetricKey.distanceMeters,
      ],
      optional: const [
        CardioMetricKey.paceSecondsPerKm,
        CardioMetricKey.poolLengthMeters,
        CardioMetricKey.averageHeartRateBpm,
        CardioMetricKey.caloriesKcal,
      ],
    ),
    _activity(
      'cardio:elliptical',
      'Elliptical',
      '椭圆机',
      CardioActivityIcon.elliptical,
      required: const [CardioMetricKey.durationSeconds],
      optional: const [
        CardioMetricKey.distanceMeters,
        CardioMetricKey.averageHeartRateBpm,
        CardioMetricKey.cadencePerMinute,
        CardioMetricKey.caloriesKcal,
      ],
    ),
    _activity(
      'cardio:generic',
      'Other cardio',
      '其它有氧',
      CardioActivityIcon.generic,
      required: const [CardioMetricKey.durationSeconds],
      optional: CardioMetricKey.values
          .where((value) => value != CardioMetricKey.durationSeconds)
          .toList(),
    ),
  ];

  static CardioActivityDefinition byId(String id) =>
      all.firstWhere((activity) => activity.id == id, orElse: () => all.last);
}

CardioActivityDefinition _activity(
  String id,
  String en,
  String zh,
  CardioActivityIcon icon, {
  required List<CardioMetricKey> required,
  required List<CardioMetricKey> optional,
}) => CardioActivityDefinition(
  id: id,
  nameEn: en,
  nameZhCn: zh,
  icon: icon,
  requiredMetrics: required,
  optionalMetrics: optional,
  isBuiltIn: true,
);
