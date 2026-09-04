import 'dart:convert';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:fittin_v2/src/domain/models/cardio.dart';
import 'package:xml/xml.dart';

class CardioImportException implements Exception {
  const CardioImportException(this.message);

  final String message;

  @override
  String toString() => message;
}

enum CardioCsvField {
  startedAt,
  duration,
  distanceKm,
  pace,
  speedKmh,
  activity,
  averageHeartRate,
  maxHeartRate,
  cadence,
  elevationGain,
  calories,
  incline,
}

class CardioCsvMapping {
  const CardioCsvMapping(this.columns);

  final Map<CardioCsvField, String> columns;

  String? column(CardioCsvField field) => columns[field];
}

class CardioCsvInspection {
  const CardioCsvInspection({required this.headers, required this.suggested});

  final List<String> headers;
  final CardioCsvMapping suggested;
}

class CardioImportService {
  const CardioImportService();

  CardioImportPreview parse({
    required String fileName,
    required Uint8List bytes,
    required List<CardioRecord> existingRecords,
    Set<String> confirmedFingerprints = const {},
    CardioCsvMapping? csvMapping,
  }) {
    if (bytes.isEmpty) {
      throw const CardioImportException('The selected file is empty.');
    }
    if (bytes.length > 20 * 1024 * 1024) {
      throw const CardioImportException('The selected file exceeds 20 MB.');
    }
    final fingerprint = sha256.convert(bytes).toString();
    final extension = fileName.toLowerCase().split('.').last;
    final parsed = switch (extension) {
      'gpx' => _parseGpx(bytes),
      'tcx' => _parseTcx(bytes),
      'fit' => _parseFit(bytes),
      'csv' => _parseCsv(bytes, csvMapping),
      _ => throw const CardioImportException(
        'Only GPX, TCX, FIT, and CSV files are supported.',
      ),
    };
    if (parsed.records.isEmpty) {
      throw const CardioImportException(
        'No complete cardio activities were found in this file.',
      );
    }

    final records = <CardioRecord>[];
    final duplicates = <String>{};
    final sourceWasAlreadyImported = confirmedFingerprints.contains(
      fingerprint,
    );
    for (var index = 0; index < parsed.records.length; index++) {
      final source = parsed.records[index];
      final record = CardioRecord(
        id: 'cardio-record:import:${fingerprint.substring(0, 20)}:$index',
        activityTypeId: source.activityTypeId,
        activityName: source.activityName,
        startedAt: source.startedAt,
        metrics: source.metrics,
        note: source.note,
        source: extension,
        sourceFingerprint: fingerprint,
      );
      records.add(record);
      if (sourceWasAlreadyImported ||
          existingRecords.any(
            (existing) =>
                existing.sourceFingerprint == fingerprint ||
                _looksLikeSameActivity(existing, record),
          )) {
        duplicates.add(record.id);
      }
    }
    return CardioImportPreview(
      sourceName: fileName,
      sourceFingerprint: fingerprint,
      records: records,
      warnings: parsed.warnings,
      duplicateRecordIds: duplicates,
    );
  }

  CardioCsvInspection inspectCsv(Uint8List bytes) {
    final table = _readCsvTable(bytes);
    final headers = table.rawHeaders;
    final mapping = <CardioCsvField, String>{};
    for (final entry in _csvAliases.entries) {
      for (var index = 0; index < table.normalizedHeaders.length; index++) {
        if (entry.value
            .map(_normalizeHeader)
            .contains(table.normalizedHeaders[index])) {
          mapping[entry.key] = headers[index];
          break;
        }
      }
    }
    return CardioCsvInspection(
      headers: headers,
      suggested: CardioCsvMapping(mapping),
    );
  }

  _ParsedImport _parseGpx(Uint8List bytes) {
    final document = _parseXml(bytes);
    final points = document.descendants
        .where((node) => node is XmlElement && node.name.local == 'trkpt')
        .cast<XmlElement>()
        .map(_gpxPoint)
        .whereType<_TrackPoint>()
        .toList(growable: false);
    if (points.length < 2) {
      throw const CardioImportException(
        'The GPX file needs at least two timestamped track points.',
      );
    }
    final metrics = _metricsFromTrack(points);
    return _ParsedImport(
      records: [
        _importRecord(
          BuiltInCardioActivities.byId('cardio:running'),
          points.first.time,
          metrics,
        ),
      ],
      warnings: [
        if (points.any((point) => point.heartRate == null))
          'Heart-rate data was not available for every GPX track point.',
      ],
    );
  }

  _ParsedImport _parseTcx(Uint8List bytes) {
    final document = _parseXml(bytes);
    final activities = document.descendants
        .where((node) => node is XmlElement && node.name.local == 'Activity')
        .cast<XmlElement>();
    final records = <CardioRecord>[];
    final warnings = <String>[];
    for (final activity in activities) {
      final sport = (activity.getAttribute('Sport') ?? '').toLowerCase();
      final type = sport.contains('bik')
          ? BuiltInCardioActivities.byId('cardio:cycling')
          : sport.contains('swim')
          ? BuiltInCardioActivities.byId('cardio:swimming')
          : BuiltInCardioActivities.byId('cardio:running');
      final points = activity.descendants
          .where(
            (node) => node is XmlElement && node.name.local == 'Trackpoint',
          )
          .cast<XmlElement>()
          .map(_tcxPoint)
          .whereType<_TrackPoint>()
          .toList(growable: false);
      final idTime = _firstText(activity, 'Id');
      final startedAt = points.isNotEmpty
          ? points.first.time
          : DateTime.tryParse(idTime ?? '');
      final duration = _sumLapSummary(activity, 'TotalTimeSeconds');
      final distance = _sumLapSummary(activity, 'DistanceMeters');
      if (startedAt == null || (duration <= 0 && points.length < 2)) {
        warnings.add('Skipped an incomplete TCX activity.');
        continue;
      }
      final metrics = points.length >= 2
          ? _metricsFromTrack(points)
          : <CardioMetricKey, double>{};
      if (duration > 0) {
        metrics[CardioMetricKey.durationSeconds] = duration;
      }
      if (distance > 0) {
        metrics[CardioMetricKey.distanceMeters] = distance;
      }
      final averageHeartRate = _firstNumber(activity, 'AverageHeartRateBpm');
      final maxHeartRate = _firstNumber(activity, 'MaximumHeartRateBpm');
      final cadence = _averageDescendantNumbers(activity, 'Cadence');
      final calories = _sumLapSummary(activity, 'Calories');
      if (averageHeartRate != null) {
        metrics[CardioMetricKey.averageHeartRateBpm] = averageHeartRate;
      }
      if (maxHeartRate != null) {
        metrics[CardioMetricKey.maxHeartRateBpm] = maxHeartRate;
      }
      if (cadence != null) {
        metrics[CardioMetricKey.cadencePerMinute] = cadence;
      }
      if (calories > 0) metrics[CardioMetricKey.caloriesKcal] = calories;
      if ((metrics[CardioMetricKey.durationSeconds] ?? 0) <= 0) {
        warnings.add('Skipped a TCX activity with zero duration.');
        continue;
      }
      records.add(_importRecord(type, startedAt, metrics));
    }
    return _ParsedImport(records: records, warnings: warnings);
  }

  _ParsedImport _parseCsv(Uint8List bytes, CardioCsvMapping? mapping) {
    final table = _readCsvTable(bytes);
    final lines = table.lines;
    final delimiter = table.delimiter;
    final headers = table.normalizedHeaders;
    final records = <CardioRecord>[];
    final warnings = <String>[];
    for (var rowIndex = 1; rowIndex < lines.length; rowIndex++) {
      final values = _splitCsvLine(lines[rowIndex], delimiter);
      final row = <String, String>{
        for (var index = 0; index < headers.length; index++)
          headers[index]: index < values.length ? values[index].trim() : '',
      };
      try {
        final record = _csvRecord(row, mapping);
        if (record == null) {
          warnings.add(
            'Skipped CSV row ${rowIndex + 1}: required data missing.',
          );
        } else {
          records.add(record);
        }
      } on FormatException {
        warnings.add('Skipped CSV row ${rowIndex + 1}: invalid values.');
      }
    }
    return _ParsedImport(records: records, warnings: warnings);
  }

  _ParsedImport _parseFit(Uint8List bytes) {
    try {
      final sessions = _FitDecoder(bytes).sessions();
      final records = <CardioRecord>[];
      final warnings = <String>[];
      for (final session in sessions) {
        final duration = session.number(8) ?? session.number(7);
        final startedAt = session.fitDate(2) ?? session.fitDate(253);
        if (duration == null || duration <= 0 || startedAt == null) {
          warnings.add('Skipped an incomplete FIT session.');
          continue;
        }
        final sport = session.number(5)?.round();
        final activity = switch (sport) {
          1 => BuiltInCardioActivities.byId('cardio:running'),
          2 => BuiltInCardioActivities.byId('cardio:cycling'),
          5 => BuiltInCardioActivities.byId('cardio:swimming'),
          15 => BuiltInCardioActivities.byId('cardio:rowing'),
          _ => BuiltInCardioActivities.byId('cardio:generic'),
        };
        final metrics = <CardioMetricKey, double>{
          CardioMetricKey.durationSeconds: duration / 1000,
        };
        _putScaled(
          metrics,
          CardioMetricKey.distanceMeters,
          session.number(9),
          100,
        );
        _putScaled(
          metrics,
          CardioMetricKey.averageSpeedMps,
          session.number(14),
          1000,
        );
        _put(metrics, CardioMetricKey.caloriesKcal, session.number(11));
        _put(metrics, CardioMetricKey.averageHeartRateBpm, session.number(16));
        _put(metrics, CardioMetricKey.maxHeartRateBpm, session.number(17));
        _put(metrics, CardioMetricKey.cadencePerMinute, session.number(18));
        _put(metrics, CardioMetricKey.elevationGainMeters, session.number(22));
        records.add(_importRecord(activity, startedAt, metrics));
      }
      return _ParsedImport(records: records, warnings: warnings);
    } on CardioImportException {
      rethrow;
    } on Object {
      throw const CardioImportException(
        'This FIT file uses data that could not be decoded safely.',
      );
    }
  }

  XmlDocument _parseXml(Uint8List bytes) {
    try {
      return XmlDocument.parse(utf8.decode(bytes, allowMalformed: false));
    } on Object {
      throw const CardioImportException('The XML file is malformed.');
    }
  }
}

class _ParsedImport {
  const _ParsedImport({required this.records, required this.warnings});

  final List<CardioRecord> records;
  final List<String> warnings;
}

class _CsvTable {
  const _CsvTable({
    required this.lines,
    required this.delimiter,
    required this.rawHeaders,
    required this.normalizedHeaders,
  });

  final List<String> lines;
  final String delimiter;
  final List<String> rawHeaders;
  final List<String> normalizedHeaders;
}

_CsvTable _readCsvTable(Uint8List bytes) {
  if (bytes.isEmpty || bytes.length > 20 * 1024 * 1024) {
    throw const CardioImportException('The selected CSV size is invalid.');
  }
  final text = utf8
      .decode(bytes, allowMalformed: false)
      .replaceFirst('\ufeff', '');
  final lines = const LineSplitter()
      .convert(text)
      .where((line) => line.trim().isNotEmpty)
      .toList(growable: false);
  if (lines.length < 2) {
    throw const CardioImportException(
      'The CSV file needs a header and at least one data row.',
    );
  }
  final delimiter = _delimiterFor(lines.first);
  final rawHeaders = _splitCsvLine(
    lines.first,
    delimiter,
  ).map((value) => value.trim()).toList(growable: false);
  if (rawHeaders.isEmpty || rawHeaders.every((value) => value.isEmpty)) {
    throw const CardioImportException('The CSV header is empty.');
  }
  return _CsvTable(
    lines: lines,
    delimiter: delimiter,
    rawHeaders: rawHeaders,
    normalizedHeaders: rawHeaders.map(_normalizeHeader).toList(growable: false),
  );
}

class _TrackPoint {
  const _TrackPoint({
    required this.time,
    this.latitude,
    this.longitude,
    this.distance,
    this.elevation,
    this.heartRate,
    this.cadence,
  });

  final DateTime time;
  final double? latitude;
  final double? longitude;
  final double? distance;
  final double? elevation;
  final double? heartRate;
  final double? cadence;
}

_TrackPoint? _gpxPoint(XmlElement element) {
  final time = DateTime.tryParse(_firstText(element, 'time') ?? '');
  if (time == null) return null;
  return _TrackPoint(
    time: time,
    latitude: double.tryParse(element.getAttribute('lat') ?? ''),
    longitude: double.tryParse(element.getAttribute('lon') ?? ''),
    elevation: double.tryParse(_firstText(element, 'ele') ?? ''),
    heartRate: _firstNumber(element, 'hr'),
    cadence: _firstNumber(element, 'cad'),
  );
}

_TrackPoint? _tcxPoint(XmlElement element) {
  final time = DateTime.tryParse(_firstText(element, 'Time') ?? '');
  if (time == null) return null;
  return _TrackPoint(
    time: time,
    latitude: _firstNumber(element, 'LatitudeDegrees'),
    longitude: _firstNumber(element, 'LongitudeDegrees'),
    distance: _firstNumber(element, 'DistanceMeters'),
    elevation: _firstNumber(element, 'AltitudeMeters'),
    heartRate: _firstNumber(element, 'HeartRateBpm'),
    cadence: _firstNumber(element, 'Cadence'),
  );
}

Map<CardioMetricKey, double> _metricsFromTrack(List<_TrackPoint> points) {
  final duration =
      points.last.time.difference(points.first.time).inMilliseconds / 1000;
  if (duration <= 0) {
    throw const CardioImportException('The activity duration is invalid.');
  }
  var distance = 0.0;
  var ascent = 0.0;
  final firstDistance = points.first.distance;
  final lastDistance = points.last.distance;
  if (firstDistance != null &&
      lastDistance != null &&
      lastDistance > firstDistance) {
    distance = lastDistance - firstDistance;
  } else {
    for (var index = 1; index < points.length; index++) {
      final previous = points[index - 1];
      final current = points[index];
      if (previous.latitude != null &&
          previous.longitude != null &&
          current.latitude != null &&
          current.longitude != null) {
        distance += _haversineMeters(
          previous.latitude!,
          previous.longitude!,
          current.latitude!,
          current.longitude!,
        );
      }
      if (previous.elevation != null && current.elevation != null) {
        ascent += math.max(0, current.elevation! - previous.elevation!);
      }
    }
  }
  final heartRates = points.map((point) => point.heartRate).whereType<double>();
  final cadences = points.map((point) => point.cadence).whereType<double>();
  return {
    CardioMetricKey.durationSeconds: duration,
    if (distance > 0) CardioMetricKey.distanceMeters: distance,
    if (ascent > 0) CardioMetricKey.elevationGainMeters: ascent,
    if (heartRates.isNotEmpty)
      CardioMetricKey.averageHeartRateBpm:
          heartRates.reduce((left, right) => left + right) / heartRates.length,
    if (cadences.isNotEmpty)
      CardioMetricKey.cadencePerMinute:
          cadences.reduce((left, right) => left + right) / cadences.length,
  };
}

const Map<CardioCsvField, List<String>> _csvAliases = {
  CardioCsvField.startedAt: [
    'starttime',
    'startedat',
    'datetime',
    'date',
    'time',
    '开始时间',
    '日期',
  ],
  CardioCsvField.duration: [
    'duration',
    'elapsedtime',
    'movingtime',
    'totaltime',
    '时长',
    '运动时间',
  ],
  CardioCsvField.distanceKm: ['distancekm', 'distance', 'km', '距离', '公里'],
  CardioCsvField.pace: ['averagepace', 'avgpace', 'pace', '平均配速', '配速'],
  CardioCsvField.speedKmh: ['averagespeed', 'avgspeed', 'speed', '平均速度', '速度'],
  CardioCsvField.activity: [
    'activity',
    'sport',
    'type',
    'activitytype',
    '运动类型',
    '项目',
  ],
  CardioCsvField.averageHeartRate: [
    'averageheartrate',
    'avghr',
    'heartrate',
    '平均心率',
    '心率',
  ],
  CardioCsvField.maxHeartRate: ['maxheartrate', 'maxhr', '最高心率'],
  CardioCsvField.cadence: ['cadence', 'averagecadence', '步频', '踏频'],
  CardioCsvField.elevationGain: ['elevationgain', 'totalascent', '爬升', '累计爬升'],
  CardioCsvField.calories: ['calories', 'kcal', '卡路里', '热量'],
  CardioCsvField.incline: ['incline', 'grade', '坡度'],
};

CardioRecord? _csvRecord(Map<String, String> row, CardioCsvMapping? mapping) {
  String? mapped(CardioCsvField field) {
    final column = mapping?.column(field);
    if (column == null || column.isEmpty) return null;
    final value = row[_normalizeHeader(column)];
    return value == null || value.trim().isEmpty ? null : value.trim();
  }

  String? value(CardioCsvField field) =>
      mapped(field) ?? _rowValue(row, _csvAliases[field] ?? const []);
  final startedAt = _parseCsvDate(value(CardioCsvField.startedAt));
  final duration = _parseDuration(value(CardioCsvField.duration));
  if (startedAt == null || duration == null || duration <= 0) return null;
  final sport = (value(CardioCsvField.activity) ?? '').toLowerCase();
  final activity =
      sport.contains('cycl') || sport.contains('bike') || sport.contains('骑')
      ? BuiltInCardioActivities.byId('cardio:cycling')
      : sport.contains('swim') || sport.contains('游')
      ? BuiltInCardioActivities.byId('cardio:swimming')
      : sport.contains('row') || sport.contains('划')
      ? BuiltInCardioActivities.byId('cardio:rowing')
      : BuiltInCardioActivities.byId('cardio:running');
  final metrics = <CardioMetricKey, double>{
    CardioMetricKey.durationSeconds: duration,
  };
  _putScaled(
    metrics,
    CardioMetricKey.distanceMeters,
    _parseNumber(value(CardioCsvField.distanceKm)),
    0.001,
  );
  _putScaled(
    metrics,
    CardioMetricKey.averageSpeedMps,
    _parseNumber(value(CardioCsvField.speedKmh)),
    3.6,
  );
  final pace = _parseDuration(value(CardioCsvField.pace));
  _put(metrics, CardioMetricKey.paceSecondsPerKm, pace);
  _put(
    metrics,
    CardioMetricKey.averageHeartRateBpm,
    _parseNumber(value(CardioCsvField.averageHeartRate)),
  );
  _put(
    metrics,
    CardioMetricKey.maxHeartRateBpm,
    _parseNumber(value(CardioCsvField.maxHeartRate)),
  );
  _put(
    metrics,
    CardioMetricKey.cadencePerMinute,
    _parseNumber(value(CardioCsvField.cadence)),
  );
  _put(
    metrics,
    CardioMetricKey.elevationGainMeters,
    _parseNumber(value(CardioCsvField.elevationGain)),
  );
  _put(
    metrics,
    CardioMetricKey.caloriesKcal,
    _parseNumber(value(CardioCsvField.calories)),
  );
  _put(
    metrics,
    CardioMetricKey.inclinePercent,
    _parseNumber(value(CardioCsvField.incline)),
  );
  return _importRecord(activity, startedAt, metrics);
}

CardioRecord _importRecord(
  CardioActivityDefinition activity,
  DateTime startedAt,
  Map<CardioMetricKey, double> sourceMetrics,
) {
  if (!sourceMetrics.keys.toSet().containsAll(activity.requiredMetrics)) {
    activity = BuiltInCardioActivities.byId('cardio:generic');
  }
  final allowed = {
    ...activity.allowedMetrics,
    CardioMetricKey.averageSpeedMps,
    CardioMetricKey.paceSecondsPerKm,
  };
  final metrics = Map<CardioMetricKey, double>.fromEntries(
    sourceMetrics.entries.where((entry) => allowed.contains(entry.key)),
  );
  if (!metrics.containsKey(CardioMetricKey.durationSeconds)) {
    throw const CardioImportException('The activity duration is missing.');
  }
  return CardioRecord(
    id: 'pending',
    activityTypeId: activity.id,
    activityName: activity.nameEn,
    startedAt: startedAt.toLocal(),
    metrics: metrics,
    source: 'import',
  );
}

bool _looksLikeSameActivity(CardioRecord left, CardioRecord right) {
  if (left.activityTypeId != right.activityTypeId ||
      left.startedAt.difference(right.startedAt).abs() >
          const Duration(minutes: 2)) {
    return false;
  }
  final leftDuration = left.metric(CardioMetricKey.durationSeconds) ?? 0;
  final rightDuration = right.metric(CardioMetricKey.durationSeconds) ?? 0;
  if (!_withinRatio(leftDuration, rightDuration, 0.02, minimum: 3)) {
    return false;
  }
  final leftDistance = left.metric(CardioMetricKey.distanceMeters);
  final rightDistance = right.metric(CardioMetricKey.distanceMeters);
  if (leftDistance == null || rightDistance == null) return true;
  return _withinRatio(leftDistance, rightDistance, 0.01, minimum: 20);
}

bool _withinRatio(
  double left,
  double right,
  double ratio, {
  required double minimum,
}) => (left - right).abs() <= math.max(minimum, math.max(left, right) * ratio);

double _haversineMeters(double lat1, double lon1, double lat2, double lon2) {
  const radius = 6371000.0;
  final dLat = (lat2 - lat1) * math.pi / 180;
  final dLon = (lon2 - lon1) * math.pi / 180;
  final a =
      math.sin(dLat / 2) * math.sin(dLat / 2) +
      math.cos(lat1 * math.pi / 180) *
          math.cos(lat2 * math.pi / 180) *
          math.sin(dLon / 2) *
          math.sin(dLon / 2);
  return radius * 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
}

String? _firstText(XmlElement element, String localName) => element.descendants
    .where((node) => node is XmlElement && node.name.local == localName)
    .cast<XmlElement>()
    .map((node) => node.innerText.trim())
    .where((value) => value.isNotEmpty)
    .firstOrNull;

double? _firstNumber(XmlElement element, String localName) {
  final target = element.descendants
      .where((node) => node is XmlElement && node.name.local == localName)
      .cast<XmlElement>()
      .firstOrNull;
  if (target == null) return null;
  final nestedValue = target.descendants
      .where((node) => node is XmlElement && node.name.local == 'Value')
      .cast<XmlElement>()
      .firstOrNull;
  return double.tryParse((nestedValue ?? target).innerText.trim());
}

double _sumLapSummary(XmlElement activity, String localName) {
  final laps = activity.childElements.where(
    (element) => element.name.local == 'Lap',
  );
  final values = laps
      .map(
        (lap) => lap.childElements
            .where((element) => element.name.local == localName)
            .map((element) => double.tryParse(element.innerText.trim()))
            .whereType<double>()
            .firstOrNull,
      )
      .whereType<double>()
      .toList(growable: false);
  return values.fold(0, (sum, value) => sum + value);
}

double? _averageDescendantNumbers(XmlElement element, String localName) {
  final values = element.descendants
      .where((node) => node is XmlElement && node.name.local == localName)
      .cast<XmlElement>()
      .map((node) => double.tryParse(node.innerText.trim()))
      .whereType<double>()
      .toList();
  return values.isEmpty ? null : values.reduce((a, b) => a + b) / values.length;
}

String _delimiterFor(String header) {
  final commas = ','.allMatches(header).length;
  final semicolons = ';'.allMatches(header).length;
  final tabs = '\t'.allMatches(header).length;
  if (tabs > commas && tabs > semicolons) return '\t';
  return semicolons > commas ? ';' : ',';
}

List<String> _splitCsvLine(String line, String delimiter) {
  final values = <String>[];
  final buffer = StringBuffer();
  var quoted = false;
  for (var index = 0; index < line.length; index++) {
    final char = line[index];
    if (char == '"') {
      if (quoted && index + 1 < line.length && line[index + 1] == '"') {
        buffer.write('"');
        index++;
      } else {
        quoted = !quoted;
      }
    } else if (!quoted && char == delimiter) {
      values.add(buffer.toString());
      buffer.clear();
    } else {
      buffer.write(char);
    }
  }
  values.add(buffer.toString());
  return values;
}

String _normalizeHeader(String value) =>
    value.trim().toLowerCase().replaceAll(RegExp(r'[\s_\-/()]+'), '');

String? _rowValue(Map<String, String> row, List<String> candidates) {
  for (final candidate in candidates) {
    final value = row[_normalizeHeader(candidate)];
    if (value != null && value.trim().isNotEmpty) return value.trim();
  }
  return null;
}

DateTime? _parseCsvDate(String? source) {
  if (source == null) return null;
  final direct = DateTime.tryParse(source);
  if (direct != null) return direct;
  final normalized = source.replaceAll('/', '-');
  return DateTime.tryParse(normalized);
}

double? _parseNumber(String? source) {
  if (source == null) return null;
  return double.tryParse(source.replaceAll(RegExp(r'[^0-9.\-]'), ''));
}

double? _parseDuration(String? source) {
  if (source == null) return null;
  final parts = source.trim().split(':');
  if (parts.length == 2 || parts.length == 3) {
    final values = parts.map(double.tryParse).toList();
    if (values.any((value) => value == null)) return null;
    if (values.length == 3) {
      return values[0]! * 3600 + values[1]! * 60 + values[2]!;
    }
    return values[0]! * 60 + values[1]!;
  }
  final value = _parseNumber(source);
  return value == null ? null : value * 60;
}

void _put(
  Map<CardioMetricKey, double> target,
  CardioMetricKey key,
  double? value,
) {
  if (value != null && value.isFinite && value >= 0) target[key] = value;
}

void _putScaled(
  Map<CardioMetricKey, double> target,
  CardioMetricKey key,
  double? value,
  double scale,
) {
  if (value != null) _put(target, key, value / scale);
}

class _FitFieldDefinition {
  const _FitFieldDefinition(this.number, this.size, this.baseType);
  final int number;
  final int size;
  final int baseType;
}

class _FitDefinition {
  const _FitDefinition(this.globalMessage, this.littleEndian, this.fields);
  final int globalMessage;
  final bool littleEndian;
  final List<_FitFieldDefinition> fields;
}

class _FitMessage {
  const _FitMessage(this.values);
  final Map<int, double> values;

  double? number(int field) => values[field];

  DateTime? fitDate(int field) {
    final seconds = number(field);
    if (seconds == null) return null;
    return DateTime.utc(
      1989,
      12,
      31,
    ).add(Duration(seconds: seconds.round())).toLocal();
  }
}

class _FitDecoder {
  _FitDecoder(this.bytes);

  final Uint8List bytes;
  final Map<int, _FitDefinition> _definitions = {};

  List<_FitMessage> sessions() {
    if (bytes.length < 14 ||
        ascii.decode(bytes.sublist(8, 12), allowInvalid: true) != '.FIT') {
      throw const CardioImportException('The FIT header is invalid.');
    }
    final headerSize = bytes[0];
    if (headerSize < 12 || headerSize > bytes.length) {
      throw const CardioImportException('The FIT header size is invalid.');
    }
    final dataLength = ByteData.sublistView(bytes).getUint32(4, Endian.little);
    final end = headerSize + dataLength;
    if (end > bytes.length) {
      throw const CardioImportException('The FIT file is truncated.');
    }
    final sessions = <_FitMessage>[];
    var offset = headerSize;
    while (offset < end) {
      final header = bytes[offset++];
      final compressed = header & 0x80 != 0;
      final localMessage = compressed ? (header >> 5) & 0x03 : header & 0x0f;
      final isDefinition = !compressed && header & 0x40 != 0;
      if (isDefinition) {
        if (offset + 5 > end) {
          throw const CardioImportException('FIT definition is truncated.');
        }
        offset++;
        final architecture = bytes[offset++];
        final little = architecture == 0;
        final byteData = ByteData.sublistView(bytes);
        final global = byteData.getUint16(
          offset,
          little ? Endian.little : Endian.big,
        );
        offset += 2;
        final fieldCount = bytes[offset++];
        if (offset + fieldCount * 3 > end) {
          throw const CardioImportException('FIT fields are truncated.');
        }
        final fields = <_FitFieldDefinition>[];
        for (var index = 0; index < fieldCount; index++) {
          fields.add(
            _FitFieldDefinition(
              bytes[offset],
              bytes[offset + 1],
              bytes[offset + 2],
            ),
          );
          offset += 3;
        }
        if (header & 0x20 != 0) {
          if (offset >= end) {
            throw const CardioImportException(
              'FIT developer fields are truncated.',
            );
          }
          final developerCount = bytes[offset++];
          offset += developerCount * 3;
          if (offset > end) {
            throw const CardioImportException(
              'FIT developer fields are truncated.',
            );
          }
        }
        _definitions[localMessage] = _FitDefinition(global, little, fields);
        continue;
      }
      final definition = _definitions[localMessage];
      if (definition == null) {
        throw const CardioImportException(
          'FIT data appeared before its definition.',
        );
      }
      final values = <int, double>{};
      for (final field in definition.fields) {
        if (offset + field.size > end) {
          throw const CardioImportException('FIT data is truncated.');
        }
        final value = _decodeFitNumber(
          bytes,
          offset,
          field,
          definition.littleEndian,
        );
        if (value != null) values[field.number] = value;
        offset += field.size;
      }
      if (definition.globalMessage == 18) sessions.add(_FitMessage(values));
    }
    return sessions;
  }
}

double? _decodeFitNumber(
  Uint8List bytes,
  int offset,
  _FitFieldDefinition field,
  bool littleEndian,
) {
  final data = ByteData.sublistView(bytes);
  final endian = littleEndian ? Endian.little : Endian.big;
  final type = field.baseType & 0x1f;
  if (field.size == 1) {
    final value = bytes[offset];
    return value == 0xff ? null : value.toDouble();
  }
  if (field.size == 2) {
    if (type == 3) {
      final value = data.getInt16(offset, endian);
      return value == 0x7fff ? null : value.toDouble();
    }
    final value = data.getUint16(offset, endian);
    return value == 0xffff ? null : value.toDouble();
  }
  if (field.size == 4) {
    if (type == 5) {
      final value = data.getInt32(offset, endian);
      return value == 0x7fffffff ? null : value.toDouble();
    }
    if (type == 8) return data.getFloat32(offset, endian).toDouble();
    final value = data.getUint32(offset, endian);
    return value == 0xffffffff ? null : value.toDouble();
  }
  if (field.size == 8 && type == 9) return data.getFloat64(offset, endian);
  return null;
}

extension<T> on Iterable<T> {
  T? get firstOrNull {
    final iterator = this.iterator;
    return iterator.moveNext() ? iterator.current : null;
  }
}
