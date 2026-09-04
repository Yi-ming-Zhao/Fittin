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
