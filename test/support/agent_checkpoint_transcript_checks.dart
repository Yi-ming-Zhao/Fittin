import 'package:fittin_v2/src/data/agent_business_transaction.dart';
import 'package:fittin_v2/src/data/agent_checkpoint_transcript.dart';
import 'package:fittin_v2/src/data/agent_local_repository.dart';
import 'package:fittin_v2/src/domain/models/agent_models.dart';
import 'package:fittin_v2/src/domain/models/agent_runtime.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> checkCheckpointTranscript(
  AgentLocalRepository repository, {
  required int Function() pageWrites,
}) async {
  final now = DateTime.utc(2026, 10, 21);
  final transcript = AgentCheckpointTranscript();
  AgentCheckpoint checkpoint(List<AgentMessage> messages) => AgentCheckpoint(
    run: AgentRunRecord(
      id: 'run:1',
      conversationId: 'conversation',
      ownerUserId: 'alice',
      authEpoch: 'epoch',
      createdAt: now,
      updatedAt: now,
      phase: AgentRunPhase.interrupted,
    ),
    conversation: AgentConversation(
      id: 'conversation',
      title: '长任务',
      createdAt: now,
      updatedAt: now,
      messages: messages,
    ),
    contextSummary: '目标与已经确认的操作',
    steering: const ['保留原重量'],
  );
  AgentMessage message(int i) => AgentMessage(
    id: 'm$i',
    role: AgentMessageRole.user,
    createdAt: now,
    content: 'Message $i',
  );
  Future<void> save(AgentCheckpoint value, {bool fail = false}) async {
    await AgentBusinessTransaction(repository).run(() async {
      final document = await transcript.write(
        repository,
        value,
        ownerUserId: 'alice',
      );
      if (fail) throw StateError('injected checkpoint failure');
      await repository.saveDocument(
        'checkpoint',
        value.run.id,
        document,
        ownerUserId: 'alice',
      );
    });
    transcript.committed(value, ownerUserId: 'alice');
  }

  Future<AgentCheckpoint> read() async => AgentCheckpointTranscript.read(
    repository,
    (await repository.readDocument(
      'checkpoint',
      'run:1',
      ownerUserId: 'alice',
    ))!,
    ownerUserId: 'alice',
  );
  final messages = List.generate(105, message);
  await save(checkpoint(messages));
  expect(pageWrites(), 3);
  final doc = (await repository.readDocument(
    'checkpoint',
    'run:1',
    ownerUserId: 'alice',
  ))!;
  expect((doc['conversation'] as Map)['messages'], isEmpty);
  expect(doc['transcriptPageCount'], 3);
  expect(
    (await read()).conversation.messages.map((m) => m.id),
    messages.map((m) => m.id),
  );
  expect((await read()).contextSummary, '目标与已经确认的操作');
  expect((await read()).steering, ['保留原重量']);
  await expectLater(
    AgentCheckpointTranscript.read(repository, doc, ownerUserId: 'bob'),
    throwsFormatException,
  );
  expect(
    await repository.readDocument(
      agentCheckpointPageKind('run:1'),
      '0',
      ownerUserId: 'bob',
    ),
    isNull,
  );
  final legacy = checkpoint(messages).toJson();
  legacy['run'] = {...(legacy['run'] as Map), 'id': 'legacy-run'};
  expect(
    (await AgentCheckpointTranscript.read(
      repository,
      legacy,
      ownerUserId: 'alice',
    )).conversation.messages,
    hasLength(105),
  );

  final appended = [...messages, message(105)];
  await save(checkpoint(appended));
  expect(
    (await AgentCheckpointTranscript.read(
      repository,
      doc,
      ownerUserId: 'alice',
    )).conversation.messages,
    hasLength(106),
    reason:
        'A stale index is refreshed inside the same transaction as the pages.',
  );
  expect(pageWrites(), 4, reason: 'Only the final changed page is rewritten.');
  final modified = [message(999), ...appended.skip(1)];
  await expectLater(save(checkpoint(modified), fail: true), throwsStateError);
  expect((await read()).conversation.messages.first.id, 'm0');
  await save(checkpoint(modified));
  expect((await read()).conversation.messages.first.id, 'm999');
  await save(checkpoint(modified.take(49).toList()));
  expect((await read()).conversation.messages, hasLength(49));
  expect(
    await repository.readDocument(
      agentCheckpointPageKind('run:1'),
      '1',
      ownerUserId: 'alice',
    ),
    isNull,
  );
  await repository.deleteDocument(
    agentCheckpointPageKind('run:1'),
    '0',
    ownerUserId: 'alice',
  );
  await expectLater(read(), throwsFormatException);
  await repository.deleteDocument('checkpoint', 'run:1', ownerUserId: 'alice');
  expect(
    await repository.listDocuments(
      agentCheckpointPageKind('run:1'),
      ownerUserId: 'alice',
    ),
    isEmpty,
  );
}
