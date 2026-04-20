import 'dart:async';
import 'dart:io';

Future<bool> probeLocalSupabase(Uri baseUri) async {
  final client = HttpClient()..connectionTimeout = const Duration(seconds: 1);
  try {
    final request = await client.getUrl(baseUri.resolve('/auth/v1/settings'));
    final response = await request.close().timeout(const Duration(seconds: 1));
    return response.statusCode > 0;
  } on TimeoutException {
    return false;
  } on SocketException {
    return false;
  } on HttpException {
    return false;
  } finally {
    client.close(force: true);
  }
}
