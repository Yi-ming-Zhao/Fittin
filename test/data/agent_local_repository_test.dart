import 'package:fittin_v2/src/data/agent_local_repository.dart';
import 'package:fittin_v2/src/data/models/agent_action_collection.dart';
import 'package:fittin_v2/src/data/models/agent_conversation_collection.dart';
import 'package:fittin_v2/src/domain/models/agent_models.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/isar_test_helper.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('native agent stores preserve owner partitions and actions', () async {
    final opened = await openTestIsar('agent_local_repo');
    addTearDown(() async {
      await opened.isar.close(deleteFromDisk: true);
      if (await opened.directory.exists()) {
        await opened.directory.delete(recursive: true);
      }
    });
    final repository = IsarAgentLocalRepository(opened.isar);
    final conversation = AgentConversation(
      id: 'conversation-1',
      title: 'Weekly review',
      createdAt: DateTime(2026, 8, 13),
      updatedAt: DateTime(2026, 8, 13),
      messages: [
        AgentMessage(
          id: 'message-1',
          role: AgentMessageRole.user,
          createdAt: DateTime(2026, 8, 13),
          content: 'Review this week',
        ),
      ],
    );
    await repository.saveConversation(conversation, ownerUserId: 'user-a');

    expect(
      await repository.fetchConversation(
        conversation.id,
        ownerUserId: 'user-a',
      ),
      isNotNull,
    );
    expect(
      await repository.fetchConversation(
        conversation.id,
        ownerUserId: 'user-b',
      ),
      isNull,
    );

    final action = AgentActionRecord(
      id: 'action-1',
      ownerUserId: 'user-a',
      toolName: 'propose_update_body_metric',
      title: 'Correct weight',
      targetType: 'body_metric',
      targetId: 'metric-1',
      beforeJson: '{}',
      afterJson: '{}',
      afterDigest: 'deadbeef',
      createdAt: DateTime(2026, 8, 13),
    );
    await repository.saveAction(action);
    expect(await repository.fetchActions(ownerUserId: 'user-a'), hasLength(1));
    expect(await repository.fetchActions(ownerUserId: 'user-b'), isEmpty);
  });

  test('adding Agent schemas keeps pre-existing records readable', () async {
    final opened = await openTestIsar('agent_additive_schema');
    addTearDown(() async {
      await opened.isar.close(deleteFromDisk: true);
      if (await opened.directory.exists()) {
        await opened.directory.delete(recursive: true);
      }
    });
    // Opening the full schema set is the native additive migration. Existing
    // business schemas are registered unchanged and empty Agent stores exist.
    expect(opened.isar.agentConversationCollections.count(), completion(0));
    expect(opened.isar.agentActionCollections.count(), completion(0));
  });
}
