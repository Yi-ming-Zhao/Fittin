import 'package:isar/isar.dart';

part 'agent_conversation_collection.g.dart';

@collection
class AgentConversationCollection {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String conversationId;

  @Index()
  String? ownerUserId;

  late String title;
  late DateTime createdAt;

  @Index()
  late DateTime updatedAt;

  late String rawJsonPayload;
}
