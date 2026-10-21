import 'package:fittin_v2/src/data/agent_local_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import '../support/isar_test_helper.dart';
import '../support/agent_conversation_transcript_checks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test(
    'native conversation pages migrate, read ranges, rollback and delete atomically',
    () async {
      final db = await openTestIsar('agent_conversation_pages');
      addTearDown(() async {
        await db.isar.close(deleteFromDisk: true);
        await db.directory.delete(recursive: true);
      });
      final repository = _CountingRepository(db.isar);
      await checkConversationTranscript(
        repository,
        pageWrites: () => repository.pageWrites,
      );
    },
  );
}

class _CountingRepository extends IsarAgentLocalRepository {
  _CountingRepository(super.isar);
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
