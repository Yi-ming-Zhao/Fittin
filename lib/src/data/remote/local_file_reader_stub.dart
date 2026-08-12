import 'dart:convert';

Future<List<int>> readLocalFileBytes(String path) async {
  final marker = path.indexOf('base64,');
  if (!path.startsWith('data:image/') || marker < 0) {
    throw UnsupportedError('Web photo uploads require an image data URL.');
  }
  return base64Decode(path.substring(marker + 'base64,'.length));
}
