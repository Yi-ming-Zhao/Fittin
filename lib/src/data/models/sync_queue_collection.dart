import 'package:isar/isar.dart';

part 'sync_queue_collection.g.dart';

@collection
class SyncQueueCollection {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String queueKey;

  @Index()
  String? ownerUserId;

  late String entityType;
  late String entityId;
  late String operationType;
  late DateTime createdAt;
  late DateTime updatedAt;
}
