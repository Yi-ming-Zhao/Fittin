import 'package:isar/isar.dart';
import 'package:fittin_v2/src/data/sync/sync_models.dart';

part 'template_collection.g.dart';

@collection
class TemplateCollection {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String templateId;

  late String name;

  late String description;

  @Index()
  late bool isBuiltIn;

  String? sourceTemplateId;
  @Index()
  String? ownerUserId;

  late DateTime createdAt;

  late DateTime lastModifiedAt;
  DateTime? deletedAt;
  DateTime? lastSyncedAt;
  late int version;
  late String syncStatusKey;
  String? lastModifiedByDeviceId;

  // Since PlanTemplate tree can be complex and Isar strongly types nested objects,
  // we serialize the whole definition tree to a JSON string here to maximize
  // flexibility for the RuleEngine.
  late String rawJsonPayload;

  @ignore
  bool get isDeleted => deletedAt != null;

  @ignore
  bool get isPendingSync =>
      syncStatusKey == SyncStatusKeys.pendingUpload ||
      syncStatusKey == SyncStatusKeys.pendingDelete ||
      syncStatusKey == SyncStatusKeys.conflict;
}
