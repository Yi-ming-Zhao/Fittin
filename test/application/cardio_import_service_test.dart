import 'dart:convert';
import 'dart:typed_data';

import 'package:fittin_v2/src/application/cardio_import_service.dart';
import 'package:fittin_v2/src/domain/models/cardio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const service = CardioImportService();

  test('parses GPX locally and detects the same fingerprint', () {
    final bytes = Uint8List.fromList(
      utf8.encode('''<?xml version="1.0"?>
<gpx><trk><trkseg>
<trkpt lat="31.2304" lon="121.4737"><ele>3</ele><time>2026-09-04T00:00:00Z</time></trkpt>
<trkpt lat="31.2314" lon="121.4737"><ele>8</ele><time>2026-09-04T00:05:00Z</time></trkpt>
</trkseg></trk></gpx>'''),
    );
    final first = service.parse(
      fileName: 'run.gpx',
      bytes: bytes,
      existingRecords: const [],
    );

    expect(first.records, hasLength(1));
    expect(first.records.single.activityTypeId, 'cardio:running');
    expect(
      first.records.single.metric(CardioMetricKey.distanceMeters),
      inInclusiveRange(110, 112),
    );
    expect(first.records.single.metric(CardioMetricKey.durationSeconds), 300);
    expect(first.routes[first.records.single.id], hasLength(2));
    expect(first.routes[first.records.single.id]!.first.accuracyMeters, isNull);

    final second = service.parse(
      fileName: 'renamed.gpx',
      bytes: bytes,
      existingRecords: first.records,
    );
    expect(second.newRecords, isEmpty);
    expect(second.duplicateRecordIds, hasLength(1));

    final afterDeletedRecords = service.parse(
      fileName: 'same-source.gpx',
      bytes: bytes,
      existingRecords: const [],
      confirmedFingerprints: {first.sourceFingerprint},
    );
    expect(afterDeletedRecords.newRecords, isEmpty);
    expect(afterDeletedRecords.duplicateRecordIds, hasLength(1));
  });

  test('parses TCX activity summaries and metrics', () {
    final bytes = Uint8List.fromList(
      utf8.encode('''<?xml version="1.0"?>
<TrainingCenterDatabase><Activities><Activity Sport="Running">
<Id>2026-09-04T01:00:00Z</Id><Lap StartTime="2026-09-04T01:00:00Z">
<TotalTimeSeconds>600</TotalTimeSeconds><DistanceMeters>2000</DistanceMeters>
<Calories>120</Calories><AverageHeartRateBpm><Value>145</Value></AverageHeartRateBpm>
<Track><Trackpoint><DistanceMeters>0</DistanceMeters></Trackpoint>
<Trackpoint><DistanceMeters>2000</DistanceMeters></Trackpoint></Track>
</Lap></Activity></Activities></TrainingCenterDatabase>'''),
    );
    final preview = service.parse(
      fileName: 'run.tcx',
      bytes: bytes,
      existingRecords: const [],
    );

    final record = preview.records.single;
    expect(record.metric(CardioMetricKey.durationSeconds), 600);
    expect(record.metric(CardioMetricKey.distanceMeters), 2000);
    expect(record.metric(CardioMetricKey.caloriesKcal), 120);
    expect(record.metric(CardioMetricKey.averageHeartRateBpm), 145);
    expect(preview.laps[record.id]!.single.distanceMeters, 2000);
  });

  test('GPX keeps separate tracks and never bridges reception gaps', () {
    final preview = service.parse(
      fileName: 'segments.gpx',
      existingRecords: [],
      bytes: Uint8List.fromList(
        utf8.encode('''<gpx>
<trk><trkseg>
<trkpt lat="30" lon="120"><time>2026-10-20T00:00:00Z</time></trkpt>
<trkpt lat="30.001" lon="120"><time>2026-10-20T00:01:00Z</time></trkpt>
</trkseg><trkseg>
<trkpt lat="31" lon="121"><time>2026-10-20T01:00:00Z</time></trkpt>
<trkpt lat="31.001" lon="121"><time>2026-10-20T01:01:00Z</time></trkpt>
</trkseg></trk><trk><type>cycling</type><trkseg>
<trkpt lat="30" lon="120"><time>2026-10-21T00:00:00Z</time></trkpt>
<trkpt lat="30.001" lon="120"><time>2026-10-21T00:01:00Z</time></trkpt>
</trkseg></trk></gpx>'''),
      ),
    );
    expect(preview.records, hasLength(2));
    expect(
      preview.records.first.metric(CardioMetricKey.distanceMeters),
      inInclusiveRange(220, 224),
    );
    expect(
      preview.routes[preview.records.first.id]!.map((p) => p.segment).toSet(),
      hasLength(2),
    );
    expect(preview.records.last.activityTypeId, 'cardio:cycling');
    expect(
      preview.records.first.toJson().toString(),
      isNot(contains('latitude')),
    );
  });

  test('parses a standard FIT session message without an SDK', () {
    final preview = service.parse(
      fileName: 'watch-export.fit',
      bytes: _minimalFitSession(),
      existingRecords: const [],
    );

    final record = preview.records.single;
    expect(record.activityTypeId, 'cardio:running');
    expect(record.metric(CardioMetricKey.durationSeconds), 600);
    expect(record.metric(CardioMetricKey.distanceMeters), 5000);
    expect(record.startedAt.toUtc(), DateTime.utc(1990, 1, 11, 13, 46, 40));
  });

  test(
    'FIT retains compressed-time route points, developer payload alignment and laps',
    () {
      final preview = service.parse(
        fileName: 'route.fit',
        bytes: _fitWithRoute(),
        existingRecords: [],
      );
      final id = preview.records.single.id;
      final route = preview.routes[id]!;
      expect(route, hasLength(2));
      expect(route.first.latitude, closeTo(30, 0.000001));
      expect(route.last.latitude, closeTo(30.0001, 0.000001));
      expect(
        route.last.timestamp.difference(route.first.timestamp),
        const Duration(seconds: 1),
      );
      expect(route.first.accuracyMeters, isNull);
      expect(preview.laps[id]!.single.distanceMeters, 5000);
    },
  );

  test(
    'parses bilingual CSV exports and skips malformed rows with warnings',
    () {
      final bytes = Uint8List.fromList(
        utf8.encode('''开始时间,运动类型,时长,距离,平均心率
2026-09-04 07:30:00,跑步,30:00,5.0,152
bad,跑步,wrong,5.0,152'''),
      );
      final preview = service.parse(
        fileName: 'rqrun.csv',
        bytes: bytes,
        existingRecords: const [],
      );

      expect(preview.records, hasLength(1));
      expect(
        preview.records.single.metric(CardioMetricKey.durationSeconds),
        1800,
      );
      expect(
        preview.records.single.metric(CardioMetricKey.distanceMeters),
        5000,
      );
      expect(preview.warnings, hasLength(1));
    },
  );

  test('inspects and explicitly maps unrecognized CSV columns', () {
    final bytes = Uint8List.fromList(
      utf8.encode('''When,How long,Route length,Kind
2026-09-04 07:30:00,42:15,8.2,run'''),
    );
    final inspection = service.inspectCsv(bytes);

    expect(inspection.headers, ['When', 'How long', 'Route length', 'Kind']);
    expect(inspection.suggested.columns, isEmpty);

    final preview = service.parse(
      fileName: 'unmapped.csv',
      bytes: bytes,
      existingRecords: const [],
      csvMapping: const CardioCsvMapping({
        CardioCsvField.startedAt: 'When',
        CardioCsvField.duration: 'How long',
        CardioCsvField.distanceKm: 'Route length',
        CardioCsvField.activity: 'Kind',
      }),
    );
    expect(preview.records, hasLength(1));
    expect(
      preview.records.single.metric(CardioMetricKey.durationSeconds),
      2535,
    );
    expect(preview.records.single.metric(CardioMetricKey.distanceMeters), 8200);
  });

  test('rejects unsupported and oversized files', () {
    expect(
      () => service.parse(
        fileName: 'run.json',
        bytes: Uint8List.fromList([1]),
        existingRecords: const [],
      ),
      throwsA(isA<CardioImportException>()),
    );
    expect(
      () => service.parse(
        fileName: 'run.gpx',
        bytes: Uint8List(20 * 1024 * 1024 + 1),
        existingRecords: const [],
      ),
      throwsA(isA<CardioImportException>()),
    );
  });
}

Uint8List _minimalFitSession() {
  const headerSize = 14;
  const definitionSize = 18;
  const messageSize = 14;
  const dataSize = definitionSize + messageSize;
  final bytes = Uint8List(headerSize + dataSize);
  final data = ByteData.sublistView(bytes);
  bytes[0] = headerSize;
  bytes[1] = 0x20;
  data.setUint16(2, 100, Endian.little);
  data.setUint32(4, dataSize, Endian.little);
  bytes.setRange(8, 12, ascii.encode('.FIT'));

  var offset = headerSize;
  bytes[offset++] = 0x40;
  bytes[offset++] = 0;
  bytes[offset++] = 0;
  data.setUint16(offset, 18, Endian.little);
  offset += 2;
  bytes[offset++] = 4;
  for (final field in const [
    (2, 4, 0x86),
    (8, 4, 0x86),
    (9, 4, 0x86),
    (5, 1, 0x02),
  ]) {
    bytes[offset++] = field.$1;
    bytes[offset++] = field.$2;
    bytes[offset++] = field.$3;
  }

  bytes[offset++] = 0;
  data.setUint32(offset, 1000000, Endian.little);
  offset += 4;
  data.setUint32(offset, 600000, Endian.little);
  offset += 4;
  data.setUint32(offset, 500000, Endian.little);
  offset += 4;
  bytes[offset] = 1;
  return bytes;
}

Uint8List _fitWithRoute() {
  final body = BytesBuilder();
  void uint32(int value) {
    final data = ByteData(4)..setUint32(0, value, Endian.little);
    body.add(data.buffer.asUint8List());
  }

  void coordinate(double value) => uint32((value * 2147483648 / 180).round());
  // Local 0: record with a 2-byte developer field, which must be skipped in
  // every data message without becoming part of the following record header.
  body.add([
    0x60,
    0,
    0,
    20,
    0,
    3,
    253,
    4,
    0x86,
    0,
    4,
    0x85,
    1,
    4,
    0x85,
    1,
    0,
    2,
    0,
  ]);
  body.addByte(0);
  uint32(1000001);
  coordinate(30);
  coordinate(120);
  body.add([7, 8]);
  body.addByte(0x80 | (1000002 & 31));
  coordinate(30.0001);
  coordinate(120);
  body.add([9, 10]);
  body.add([
    0x41,
    0,
    0,
    19,
    0,
    4,
    253,
    4,
    0x86,
    2,
    4,
    0x86,
    8,
    4,
    0x86,
    9,
    4,
    0x86,
  ]);
  body.addByte(1);
  uint32(1000600);
  uint32(1000000);
  uint32(600000);
  uint32(500000);
  final original = _minimalFitSession();
  body.add(original.sublist(14));
  final payload = body.takeBytes();
  final header = Uint8List.fromList(original.sublist(0, 14));
  ByteData.sublistView(header).setUint32(4, payload.length, Endian.little);
  return Uint8List.fromList([...header, ...payload]);
}
