@TestOn('browser')
library;

import 'package:fittin_v2/src/data/agent_local_repository_web.dart';
import 'package:fittin_v2/src/data/web_local_store.dart';
import 'package:flutter_test/flutter_test.dart';
import '../support/agent_conversation_transcript_checks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test(
    'IndexedDB conversation pages migrate, read ranges, rollback and delete atomically',
    () async {
      final store = await WebLocalStore.open(
        databaseName:
            'conversation_pages_${DateTime.now().microsecondsSinceEpoch}',
      );
      addTearDown(store.close);
      final repository = _CountingRepository(store);
      await checkConversationTranscript(
        repository,
        pageWrites: () => repository.pageWrites,
      );
    },
  );
}

class _CountingRepository extends WebAgentLocalRepository {
  _CountingRepository(super.store);
  int pageWrites = 0;
  @override
  Future<void> saveDocument(
    String kind,
    String id,
    Map<String, dynamic> payload, {
    String? ownerUserId,
  }) {
    if (kind.startsWith('conversationPages:')) pageWrites++;
    return super.saveDocument(kind, id, payload, ownerUserId: ownerUserId);
  }
}
