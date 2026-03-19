import 'package:isar/isar.dart';
import 'package:fittin_v2/src/data/sync/sync_models.dart';

part 'workout_log_collection.g.dart';

@collection
class WorkoutLogCollection {
  Id id = Isar.autoIncrement;

  // UUID for the log entry
  @Index(unique: true, replace: true)
  late String logId;

  // The Instance this log belongs to
  @Index()
  late String instanceId;

  @Index()
  late String workoutId;

  late String workoutName;
  @Index()
  String? ownerUserId;

  // Whole-workout log payload stored as JSON for schema flexibility.
  late String rawJsonPayload;

  @Index()
  late DateTime completedAt;
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
