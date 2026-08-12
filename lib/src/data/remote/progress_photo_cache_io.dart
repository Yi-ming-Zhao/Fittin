import 'dart:io';

import 'package:path_provider/path_provider.dart';

Future<String> cacheProgressPhotoBytes(String photoId, List<int> bytes) async {
  final support = await getApplicationSupportDirectory();
  final directory = Directory('${support.path}/progress_photos');
  await directory.create(recursive: true);
  final target = File('${directory.path}/$photoId.image');
  final temporary = File('${target.path}.tmp');
  await temporary.writeAsBytes(bytes, flush: true);
  if (await target.exists()) await target.delete();
  await temporary.rename(target.path);
  return target.path;
}
