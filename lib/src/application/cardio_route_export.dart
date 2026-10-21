import 'dart:convert';
import 'dart:typed_data';
import 'package:xml/xml.dart';
import '../data/cardio_recording_store.dart';

/// Called only after a user confirms exporting precise location. No account ID,
/// health values, diagnosis, or authentication material enters this document.
Future<Uint8List> exportCardioRouteGpx(
  CardioRecordingStore store,
  String sessionId, {
  required String? ownerUserId,
}) async {
  final stored = await store.read(sessionId, ownerUserId: ownerUserId);
  if (stored == null) throw StateError('Local route is unavailable.');
  final output = StringBuffer(
    '<?xml version="1.0" encoding="UTF-8"?>\n'
    '<gpx version="1.1" creator="Fittin" xmlns="http://www.topografix.com/GPX/1/1">'
    '<trk><name>${XmlText(stored.session.activityName).toXmlString()}</name>'
    '<type>${stored.session.sport.name}</type>',
  );
  int? segment;
  var count = 0;
  await for (final chunk in store.route(sessionId, ownerUserId: ownerUserId)) {
    for (final point in chunk) {
      if (segment != point.segment) {
        if (segment != null) output.write('</trkseg>');
        output.write('<trkseg>');
        segment = point.segment;
      }
      output.write('<trkpt lat="${point.latitude}" lon="${point.longitude}">');
      if (point.altitudeMeters != null) {
        output.write('<ele>${point.altitudeMeters}</ele>');
      }
      output.write(
        '<time>${point.timestamp.toUtc().toIso8601String()}</time></trkpt>',
      );
      count++;
    }
  }
  if (count == 0) throw StateError('This activity has no measured route.');
  output.write('</trkseg></trk></gpx>');
  final after = await store.read(sessionId, ownerUserId: ownerUserId);
  if (after?.revision != stored.revision) throw const CardioRecordingConflict();
  return Uint8List.fromList(utf8.encode(output.toString()));
}
