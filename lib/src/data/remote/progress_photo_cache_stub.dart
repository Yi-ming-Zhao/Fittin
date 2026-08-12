import 'dart:convert';

Future<String> cacheProgressPhotoBytes(String photoId, List<int> bytes) async {
  return 'data:${_imageMimeType(bytes)};base64,${base64Encode(bytes)}';
}

String _imageMimeType(List<int> bytes) {
  if (bytes.length >= 8 &&
      bytes[0] == 0x89 &&
      bytes[1] == 0x50 &&
      bytes[2] == 0x4e &&
      bytes[3] == 0x47) {
    return 'image/png';
  }
  if (bytes.length >= 6 &&
      bytes[0] == 0x47 &&
      bytes[1] == 0x49 &&
      bytes[2] == 0x46) {
    return 'image/gif';
  }
  return 'image/jpeg';
}
