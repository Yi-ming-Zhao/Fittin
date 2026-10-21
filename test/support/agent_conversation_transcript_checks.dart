import 'package:fittin_v2/src/data/agent_business_transaction.dart';
import 'package:fittin_v2/src/data/agent_conversation_transcript.dart';
import 'package:fittin_v2/src/data/agent_local_repository.dart';
import 'package:fittin_v2/src/domain/models/agent_models.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> checkConversationTranscript(
  AgentLocalRepository repository, {
  required int Function() pageWrites,
}) async {
  final time = DateTime.utc(2026, 10, 21);
  AgentMessage message(int index) => AgentMessage(
    id: 'm$index',
    role: AgentMessageRole.user,
    content: 'Message $index',
    createdAt: time,
  );
  final writer = AgentConversationTranscript();
  var conversation = AgentConversation(
    id: 'paged-history',
    title: 'History',
    createdAt: time,
    updatedAt: time,
    messages: List.generate(105, message),
  );
  await writer.save(repository, conversation, ownerUserId: 'alice');
  expect(pageWrites(), 3);
  final header = (await repository.fetchConversations(
    ownerUserId: 'alice',
  )).single;
  expect(header.messages, isEmpty);
  expect(
    (await repository.fetchConversation(
      conversation.id,
      ownerUserId: 'alice',
    ))!.messages.length,
    105,
  );
  expect(
    await repository.fetchConversation(conversation.id, ownerUserId: 'bob'),
    isNull,
  );
  final page = await AgentConversationTranscript.read(
    repository,
    header,
    ownerUserId: 'alice',
    offset: 48,
    limit: 5,
  );
  expect(page.messages.map((m) => m.id), ['m48', 'm49', 'm50', 'm51', 'm52']);
  conversation = conversation.copyWith(
    messages: [...conversation.messages, message(105)],
  );
  await writer.save(repository, conversation, ownerUserId: 'alice');
  expect(pageWrites(), 4);

  final longer = conversation.copyWith(
    messages: [...conversation.messages, message(106)],
  );
  await expectLater(
    AgentBusinessTransaction(repository).run(() async {
      await writer.save(repository, longer, ownerUserId: 'alice');
      throw StateError('injected rollback');
    }),
    throwsStateError,
  );
  expect(
    (await repository.fetchConversation(
      conversation.id,
      ownerUserId: 'alice',
    ))!.messages.length,
    106,
  );
  // Even when an enclosing transaction rolls back, the old persisted token
  // invalidates the in-memory page cache and the retry restores every page.
  await writer.save(repository, longer, ownerUserId: 'alice');
  expect(
    (await repository.fetchConversation(
      conversation.id,
      ownerUserId: 'alice',
    ))!.messages.length,
    107,
  );

  await repository.deleteDocument(
    agentConversationPageKind(conversation.id),
    '2',
    ownerUserId: 'alice',
  );
  expect(
    (await AgentConversationTranscript.read(
      repository,
      header,
      ownerUserId: 'alice',
      limit: 5,
    )).messages.length,
    5,
  );
  await expectLater(
    repository.fetchConversation(conversation.id, ownerUserId: 'alice'),
    throwsFormatException,
  );
  await writer.save(
    repository,
    conversation.copyWith(messages: conversation.messages.take(49).toList()),
    ownerUserId: 'alice',
  );
  expect(
    await repository.readDocument(
      agentConversationPageKind(conversation.id),
      '1',
      ownerUserId: 'alice',
    ),
    isNull,
  );
  await repository.deleteConversation(conversation.id, ownerUserId: 'alice');
  expect(
    await repository.readDocument(
      'conversationTranscript',
      conversation.id,
      ownerUserId: 'alice',
    ),
    isNull,
  );
  expect(
    await repository.readDocument(
      agentConversationPageKind(conversation.id),
      '0',
      ownerUserId: 'alice',
    ),
    isNull,
  );

  await repository.saveConversation(conversation, ownerUserId: 'alice');
  expect(
    (await repository.fetchConversation(
      conversation.id,
      ownerUserId: 'alice',
    ))!.messages.length,
    106,
  );
  await writer.save(repository, conversation, ownerUserId: 'alice');
  await repository.saveConversation(
    conversation.copyWith(messages: [message(0)]),
    ownerUserId: 'alice',
  );
  expect(
    (await repository.fetchConversation(
      conversation.id,
      ownerUserId: 'alice',
    ))!.messages.length,
    1,
  );
}
