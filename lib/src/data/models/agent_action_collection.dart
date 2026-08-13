import 'package:isar/isar.dart';

part 'agent_action_collection.g.dart';

@collection
class AgentActionCollection {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String actionId;

  @Index()
  String? ownerUserId;

  late String statusKey;
  late DateTime createdAt;
  DateTime? undoneAt;
  late String rawJsonPayload;
}
