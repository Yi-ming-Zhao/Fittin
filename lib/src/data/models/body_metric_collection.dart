import 'package:isar/isar.dart';
import 'package:fittin_v2/src/data/sync/sync_models.dart';

part 'body_metric_collection.g.dart';

@collection
class BodyMetricCollection {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String metricId;

  late DateTime timestamp;
  @Index()
  String? ownerUserId;

  double? weightKg;
  double? bodyFatPercent;
  double? waistCm;
  String? note;
  DateTime? deletedAt;
  DateTime? lastSyncedAt;
  late int version;
  late String syncStatusKey;
  String? lastModifiedByDeviceId;
}

@collection
class ProgressPhotoCollection {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String photoId;

  late DateTime timestamp;
  @Index()
  String? ownerUserId;

  late String filePath;
  String? label;
  String? metadataJson;
  DateTime? deletedAt;
  DateTime? lastSyncedAt;
  late int version;
  late String syncStatusKey;
  String? lastModifiedByDeviceId;
}
