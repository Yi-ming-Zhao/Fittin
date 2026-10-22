import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import '../domain/models/cardio_recording.dart';

class CardioMapUnavailable implements Exception {
  const CardioMapUnavailable();
  @override
  String toString() => 'Online map unavailable';
}

/// A personal-key map preview. Only one explicitly consented position is sent,
/// never the route. Coordinates are converted by the provider, not relabelled.
class CardioOnlineMap {
  CardioOnlineMap({http.Client Function()? clientFactory})
    : _clientFactory = clientFactory ?? http.Client.new;
  final http.Client Function() _clientFactory;

  static bool validKey(String key) =>
      RegExp(r'^[a-fA-F0-9]{32}$').hasMatch(key);

  Future<Uint8List> load({
    required String key,
    required RoutePoint point,
    int zoom = 15,
    bool Function()? isCurrent,
  }) async {
    if (!validKey(key) || !point.isValid || zoom < 3 || zoom > 17) {
      throw const CardioMapUnavailable();
    }
    final client = _clientFactory();
    try {
      return await (() async {
        final conversion = await _get(
          client,
          Uri.https('restapi.amap.com', '/v3/assistant/coordinate/convert', {
            'key': key,
            'coordsys': 'gps',
            'output': 'JSON',
            'locations': '${point.longitude},${point.latitude}',
          }),
          16384,
        );
        final json =
            jsonDecode(utf8.decode(conversion.$1)) as Map<String, dynamic>;
        final coordinate = json['locations'];
        if (json['status'] != '1' || coordinate is! String) {
          throw const CardioMapUnavailable();
        }
        final parts = coordinate.split(',');
        if (parts.length != 2 ||
            !((double.tryParse(parts[0])?.abs() ?? 181) <= 180) ||
            !((double.tryParse(parts[1])?.abs() ?? 91) <= 90)) {
          throw const CardioMapUnavailable();
        }
        if (isCurrent != null && !isCurrent()) {
          throw const CardioMapUnavailable();
        }
        final image = await _get(
          client,
          Uri.https('restapi.amap.com', '/v3/staticmap', {
            'key': key,
            'location': coordinate,
            'zoom': '$zoom',
            'size': '600*360',
            'scale': '1',
            'markers': 'mid,0xB64337,A:$coordinate',
          }),
          2 * 1024 * 1024,
        );
        if (!{'image/png', 'image/jpeg'}.contains(image.$2.split(';').first)) {
          throw const CardioMapUnavailable();
        }
        return image.$1;
      })().timeout(const Duration(seconds: 15));
    } catch (_) {
      // Provider errors/HTTP URLs may contain the key or position. Never
      // expose them to UI errors, crash reporting or application diagnostics.
      throw const CardioMapUnavailable();
    } finally {
      client.close();
    }
  }

  Future<(Uint8List, String)> _get(
    http.Client client,
    Uri uri,
    int limit,
  ) async {
    final request = http.Request('GET', uri)..followRedirects = false;
    final response = await client.send(request);
    if (response.statusCode != 200 || (response.contentLength ?? 0) > limit) {
      throw const CardioMapUnavailable();
    }
    final bytes = BytesBuilder(copy: false);
    await for (final chunk in response.stream) {
      if (bytes.length + chunk.length > limit) {
        throw const CardioMapUnavailable();
      }
      bytes.add(chunk);
    }
    return (bytes.takeBytes(), response.headers['content-type'] ?? '');
  }
}
