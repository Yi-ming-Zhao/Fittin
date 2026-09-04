import 'package:fittin_v2/src/data/sync/sync_models.dart';
import 'package:isar/isar.dart';

part 'user_content_collection.g.dart';

@collection
class UserContentCollection {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String contentKey;

  @Index()
  late String contentId;

  @Index()
  late String kindKey;

  @Index()
  String? ownerUserId;

  late String rawJsonPayload;
  late DateTime createdAt;
  late DateTime lastModifiedAt;
  DateTime? deletedAt;
  DateTime? lastSyncedAt;
  late int version;
  late String syncStatusKey;
  String? lastModifiedByDeviceId;

  @ignore
  bool get isPendingSync =>
      syncStatusKey == SyncStatusKeys.pendingUpload ||
      syncStatusKey == SyncStatusKeys.pendingDelete ||
      syncStatusKey == SyncStatusKeys.conflict;
}
