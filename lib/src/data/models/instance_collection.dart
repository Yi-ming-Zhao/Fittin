import 'package:isar/isar.dart';
import 'package:fittin_v2/src/data/sync/sync_models.dart';

part 'instance_collection.g.dart';

@collection
class InstanceCollection {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String instanceId;

  // The template this instance belongs to
  @Index()
  late String templateId;

  // Track the actual progression states for the different exercises
  // embedded in a list of JSON-encoded strings. Each string parses to `TrainingState`
  late List<String> currentStatesJson;

  String? trainingMaxProfileJson;

  String? engineStateJson;

  late int currentWorkoutIndex;
  @Index()
  String? ownerUserId;

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
