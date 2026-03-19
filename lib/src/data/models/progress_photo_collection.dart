import 'package:isar/isar.dart';

part 'progress_photo_collection.g.dart';

@collection
class ProgressPhotoCollection {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String photoId;

  @Index()
  late DateTime timestamp;

  late String filePath;
  
  String? label; // e.g., 'Front', 'Side', 'Back'
  
  String? metadataJson;
}
