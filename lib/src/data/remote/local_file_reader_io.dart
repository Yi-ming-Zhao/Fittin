import 'dart:io';

Future<List<int>> readLocalFileBytes(String path) async {
  return File(path).readAsBytes();
}
