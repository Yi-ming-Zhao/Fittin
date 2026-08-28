import 'package:isar/isar.dart';
part 'agent_runtime_collection.g.dart';

/// Local-only additive storage, excluded from business synchronization.
@collection
class AgentRuntimeCollection {
  Id id = Isar.autoIncrement;
  @Index(unique: true, replace: true)
  late String documentKey;
  @Index()
  String? ownerUserId;
  @Index()
  late String kind;
  late String documentId;
  @Index()
  late DateTime updatedAt;
  late String payload;
}
