@TestOn('browser')
library;

import 'package:fittin_v2/src/data/agent_local_repository_web.dart';
import 'package:fittin_v2/src/data/web_local_store.dart';
import 'package:flutter_test/flutter_test.dart';
import '../support/agent_checkpoint_transcript_checks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test(
    'IndexedDB checkpoint pages preserve recovery, rollback, ownership and deletion',
    () async {
      final store = await WebLocalStore.open(
        databaseName:
            'checkpoint_pages_${DateTime.now().microsecondsSinceEpoch}',
      );
      addTearDown(store.close);
      final repository = _CountingRepository(store);
      await checkCheckpointTranscript(
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
    if (kind.startsWith('checkpointPages:')) pageWrites++;
    return super.saveDocument(kind, id, payload, ownerUserId: ownerUserId);
  }
}
