import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../domain/models/cardio_recording.dart';

class CardioMapUnavailable implements Exception {
  const CardioMapUnavailable();
  @override
  String toString() => 'Online map unavailable';
}

/// Provider credentials remain on the backend. Only a consented single point
/// passes through the authenticated, no-store endpoint.
class CardioOnlineMap {
  CardioOnlineMap({
    required this.backendBaseUrl,
    required this.accessTokenLoader,
    this.accessTokenRefresher,
    http.Client Function()? clientFactory,
  }) : _clientFactory = clientFactory ?? http.Client.new;
  final String backendBaseUrl;
  final Future<String?> Function() accessTokenLoader;
  final Future<String?> Function(String)? accessTokenRefresher;
  final http.Client Function() _clientFactory;

  Future<Uint8List> load({
    required RoutePoint point,
    int zoom = 15,
    bool Function()? isCurrent,
  }) async {
    final base = Uri.tryParse(backendBaseUrl);
    if (!point.isValid ||
        zoom < 3 ||
        zoom > 17 ||
        base == null ||
        base.host.isEmpty ||
        base.userInfo.isNotEmpty ||
        base.hasQuery ||
        base.hasFragment ||
        (base.scheme != 'https' &&
            !(kDebugMode &&
                base.scheme == 'http' &&
                const ['localhost', '127.0.0.1', '::1'].contains(base.host)))) {
      throw const CardioMapUnavailable();
    }
    final client = _clientFactory();
    try {
      return await (() async {
        var token = await accessTokenLoader();
        for (var attempt = 0; attempt < 2; attempt++) {
          if (token == null ||
              token.isEmpty ||
              (isCurrent != null && !isCurrent())) {
            throw const CardioMapUnavailable();
          }
          final request =
              http.Request(
                  'POST',
                  base.replace(
                    path:
                        '${base.path.replaceFirst(RegExp(r'/+$'), '')}/v1/maps/area',
                  ),
                )
                ..followRedirects = false
                ..headers.addAll({
                  'Authorization': 'Bearer $token',
                  'Content-Type': 'application/json',
                })
                ..body = jsonEncode({
                  'latitude': point.latitude,
                  'longitude': point.longitude,
                  'zoom': zoom,
                });
          final response = await client.send(request);
          if (response.statusCode == 401 &&
              attempt == 0 &&
              accessTokenRefresher != null) {
            await response.stream.listen(null).cancel();
            if (isCurrent != null && !isCurrent()) {
              throw const CardioMapUnavailable();
            }
            token = await accessTokenRefresher!(token);
            continue;
          }
          final type = (response.headers['content-type'] ?? '')
              .split(';')
              .first;
          if (response.statusCode != 200 ||
              (response.contentLength ?? 0) > 2 * 1024 * 1024 ||
              !const ['image/png', 'image/jpeg'].contains(type)) {
            await response.stream.listen(null).cancel();
            throw const CardioMapUnavailable();
          }
          final bytes = BytesBuilder(copy: false);
          await for (final chunk in response.stream) {
            if (bytes.length + chunk.length > 2 * 1024 * 1024 ||
                (isCurrent != null && !isCurrent())) {
              throw const CardioMapUnavailable();
            }
            bytes.add(chunk);
          }
          if (isCurrent != null && !isCurrent()) {
            throw const CardioMapUnavailable();
          }
          return bytes.takeBytes();
        }
        throw const CardioMapUnavailable();
      })().timeout(const Duration(seconds: 25));
    } catch (_) {
      throw const CardioMapUnavailable();
    } finally {
      client.close();
    }
  }
}
