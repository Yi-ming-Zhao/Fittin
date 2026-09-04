@TestOn('browser')
library;

import 'dart:convert';

import 'package:fittin_v2/src/application/active_session_provider.dart';
import 'package:fittin_v2/src/application/agent_mutation_coordinator.dart';
import 'package:fittin_v2/src/application/agent_mutation_diff.dart';
import 'package:fittin_v2/src/application/agent_owner_scope.dart';
import 'package:fittin_v2/src/application/auth_provider.dart';
import 'package:fittin_v2/src/application/fittin_theme_provider.dart';
import 'package:fittin_v2/src/data/agent_entity_version.dart';
import 'package:fittin_v2/src/data/agent_local_repository.dart';
import 'package:fittin_v2/src/data/agent_local_repository_web.dart';
import 'package:fittin_v2/src/data/web_database_repository.dart';
import 'package:fittin_v2/src/data/web_local_store.dart';
import 'package:fittin_v2/src/domain/models/agent_models.dart';
import 'package:fittin_v2/src/domain/models/user_content.dart';
import 'package:fittin_v2/src/presentation/theme/fittin_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'Web user-content batch is atomic across records and sync queue',
    () async {
      final store = await WebLocalStore.open(
        databaseName:
            'fittin_user_content_batch_${DateTime.now().microsecondsSinceEpoch}',
      );
      addTearDown(store.close);
      final database = WebDatabaseRepository(store);
      const existingId = 'user-exercise:web-batch-existing';
      const newId = 'user-exercise:web-batch-new';
      final existing = UserContentDocument(
        id: existingId,
        kind: UserContentKind.customExercise,
        ownerUserId: 'user-a',
        payload: _exercisePayload(existingId, 'Existing'),
      );
      final newDocument = UserContentDocument(
        id: newId,
        kind: UserContentKind.customExercise,
        ownerUserId: 'user-a',
        payload: _exercisePayload(newId, 'New'),
      );
      await database.saveUserContent(existing, expectedVersion: 0);
      final queueBefore = await store.getAllRecords(WebStoreNames.syncQueue);

      await expectLater(
        database.saveUserContentsAtomically(
          [newDocument, existing],
          expectedVersions: const {newId: 0, existingId: 0},
        ),
        throwsStateError,
      );

      expect(
        await database.fetchUserContent(newId, ownerUserId: 'user-a'),
        isNull,
      );
      expect(
        (await database.fetchUserContent(
          existingId,
          ownerUserId: 'user-a',
        ))?.version,
        1,
      );
      expect(await store.getAllRecords(WebStoreNames.syncQueue), queueBefore);
    },
  );

  test('Web user-content versions reject ABA confirmation and undo', () async {
    final databaseName =
        'fittin_agent_content_${DateTime.now().microsecondsSinceEpoch}';
    final firstStore = await WebLocalStore.open(databaseName: databaseName);
    final secondStore = await WebLocalStore.open(databaseName: databaseName);
    addTearDown(firstStore.close);
    addTearDown(secondStore.close);
    final first = WebDatabaseRepository(firstStore);
    final second = WebDatabaseRepository(secondStore);
    final actions = WebAgentLocalRepository(firstStore);
    final container = ProviderContainer(
      overrides: [
        databaseRepositoryProvider.overrideWithValue(first),
        agentLocalRepositoryProvider.overrideWithValue(actions),
        currentUserIdProvider.overrideWithValue('user-a'),
      ],
    );
    addTearDown(container.dispose);
    final scope = container.read(agentOwnerScopeProvider);
    const id = 'user-exercise:web-version';
    final original = _exercisePayload(id, 'Cable row');
    final created = await first.saveUserContent(
      UserContentDocument(
        id: id,
        kind: UserContentKind.customExercise,
        payload: original,
        ownerUserId: 'user-a',
      ),
      expectedVersion: 0,
    );
    expect(created.version, 1);
    expect(
      await agentEntityVersion(actions, 'custom_exercise', id, 'user-a'),
      1,
    );

    final revised = _exercisePayload(id, 'Chest-supported cable row');
    final stale = _proposal(
      operationId: 'web-stale-confirm',
      scope: scope,
      id: id,
      before: original,
      after: revised,
      expectedVersion: 1,
    );
    await second.saveUserContent(
      UserContentDocument(
        id: id,
        kind: UserContentKind.customExercise,
        payload: _exercisePayload(id, 'Intermediate'),
        ownerUserId: 'user-a',
      ),
      expectedVersion: 1,
    );
    await second.saveUserContent(
      UserContentDocument(
        id: id,
        kind: UserContentKind.customExercise,
        payload: original,
        ownerUserId: 'user-a',
      ),
      expectedVersion: 2,
    );
    final coordinator = container.read(agentMutationCoordinatorProvider);
    await expectLater(
      coordinator.confirm(stale),
      throwsA(isA<AgentMutationConflict>()),
    );
    expect(await actions.fetchActions(ownerUserId: 'user-a'), isEmpty);

    final fresh = _proposal(
      operationId: 'web-fresh-confirm',
      scope: scope,
      id: id,
      before: original,
      after: revised,
      expectedVersion: 3,
    );
    final action = await coordinator.confirm(fresh);
    expect(action.afterVersion, 4);
    await second.saveUserContent(
      UserContentDocument(
        id: id,
        kind: UserContentKind.customExercise,
        payload: revised,
        ownerUserId: 'user-a',
      ),
      expectedVersion: 4,
    );
    await expectLater(
      coordinator.undo(action.id),
      throwsA(isA<AgentMutationConflict>()),
    );
    final unchanged = await first.fetchUserContentOfKind(
      id,
      kind: UserContentKind.customExercise,
      ownerUserId: 'user-a',
    );
    expect(unchanged!.payload, revised);
    expect(unchanged.version, 5);
  });

  test(
    'Web library mutation rolls back business, sync and audit together',
    () async {
      final store = await WebLocalStore.open(
        databaseName:
            'fittin_agent_content_rollback_${DateTime.now().microsecondsSinceEpoch}',
      );
      addTearDown(store.close);
      final database = WebDatabaseRepository(store);
      final actions = _FailingWebAgentRepository(store);
      final container = ProviderContainer(
        overrides: [
          databaseRepositoryProvider.overrideWithValue(database),
          agentLocalRepositoryProvider.overrideWithValue(actions),
          currentUserIdProvider.overrideWithValue('user-a'),
        ],
      );
      addTearDown(container.dispose);
      const id = 'user-exercise:web-rollback';
      final after = _exercisePayload(id, 'Atomic row');
      final scope = container.read(agentOwnerScopeProvider);
      final proposal = AgentMutationProposal(
        operationId: 'web-library-rollback',
        toolName: 'propose_create_custom_exercise',
        title: 'Create exercise',
        summary: 'Test rollback',
        argumentsJson: jsonEncode({'exercise': after}),
        targetType: 'custom_exercise',
        targetId: id,
        expectedDigest: agentPayloadDigest(null),
        expectedVersion: 0,
        changes: AgentMutationDiff.between(null, after),
        ownerUserId: scope.ownerUserId,
        authEpoch: scope.epoch,
        createdAt: DateTime.now(),
      );

      await expectLater(
        container.read(agentMutationCoordinatorProvider).confirm(proposal),
        throwsStateError,
      );
      expect(
        await store.getRecord(
          WebStoreNames.userContent,
          '${UserContentKind.customExercise.name}:$id',
        ),
        isNull,
      );
      expect(await store.getAllRecords(WebStoreNames.syncQueue), isEmpty);
      expect(await store.getAllRecords(WebStoreNames.agentActions), isEmpty);
    },
  );

  test(
    'Web active palette stays selected when audit rolls back deletion',
    () async {
      final store = await WebLocalStore.open(
        databaseName:
            'fittin_agent_palette_rollback_${DateTime.now().microsecondsSinceEpoch}',
      );
      addTearDown(store.close);
      final database = WebDatabaseRepository(store);
      const id = 'user-palette:web-rollback';
      final before = _palettePayload(id, 'Web rollback palette');
      await database.saveUserContent(
        UserContentDocument(
          id: id,
          kind: UserContentKind.customThemePalette,
          payload: before,
          ownerUserId: 'user-a',
        ),
        expectedVersion: 0,
      );
      final actions = _FailingWebAgentRepository(store);
      final container = ProviderContainer(
        overrides: [
          databaseRepositoryProvider.overrideWithValue(database),
          agentLocalRepositoryProvider.overrideWithValue(actions),
          currentUserIdProvider.overrideWithValue('user-a'),
        ],
      );
      addTearDown(container.dispose);
      await container.read(fittinThemeProvider.notifier).setPaletteKey(id);
      final scope = container.read(agentOwnerScopeProvider);
      final proposal = AgentMutationProposal(
        operationId: 'web-palette-delete-rollback',
        toolName: 'propose_delete_custom_palette',
        title: 'Delete palette',
        summary: 'Test rollback',
        argumentsJson: jsonEncode({'paletteId': id}),
        targetType: 'custom_theme_palette',
        targetId: id,
        expectedDigest: agentPayloadDigest(before),
        expectedVersion: 1,
        changes: AgentMutationDiff.between(before, null),
        ownerUserId: scope.ownerUserId,
        authEpoch: scope.epoch,
        createdAt: DateTime.now(),
      );

      await expectLater(
        container.read(agentMutationCoordinatorProvider).confirm(proposal),
        throwsStateError,
      );

      expect(container.read(fittinThemeProvider), id);
      final stored = await database.fetchUserContentOfKind(
        id,
        kind: UserContentKind.customThemePalette,
        ownerUserId: 'user-a',
      );
      expect(stored, isNotNull);
      expect(stored!.payload['name'], 'Web rollback palette');
      expect(await store.getAllRecords(WebStoreNames.agentActions), isEmpty);
    },
  );

  test('Web undo of a selected new palette falls back to default', () async {
    final store = await WebLocalStore.open(
      databaseName:
          'fittin_agent_palette_undo_${DateTime.now().microsecondsSinceEpoch}',
    );
    addTearDown(store.close);
    final database = WebDatabaseRepository(store);
    final actions = WebAgentLocalRepository(store);
    final container = ProviderContainer(
      overrides: [
        databaseRepositoryProvider.overrideWithValue(database),
        agentLocalRepositoryProvider.overrideWithValue(actions),
        currentUserIdProvider.overrideWithValue('user-a'),
      ],
    );
    addTearDown(container.dispose);
    const id = 'user-palette:web-create-undo';
    final after = _palettePayload(id, 'Temporary Web palette');
    final scope = container.read(agentOwnerScopeProvider);
    final proposal = AgentMutationProposal(
      operationId: 'web-palette-create-undo',
      toolName: 'propose_create_custom_palette',
      title: 'Create palette',
      summary: 'Test undo',
      argumentsJson: jsonEncode({'palette': after}),
      targetType: 'custom_theme_palette',
      targetId: id,
      expectedDigest: agentPayloadDigest(null),
      expectedVersion: 0,
      changes: AgentMutationDiff.between(null, after),
      ownerUserId: scope.ownerUserId,
      authEpoch: scope.epoch,
      createdAt: DateTime.now(),
    );
    final coordinator = container.read(agentMutationCoordinatorProvider);
    final action = await coordinator.confirm(proposal);
    await container.read(fittinThemeProvider.notifier).setPaletteKey(id);

    await coordinator.undo(action.id);

    expect(
      container.read(fittinThemeProvider),
      FittinPaletteRegistry.defaultId.storageKey,
    );
    expect(
      await database.fetchUserContentOfKind(
        id,
        kind: UserContentKind.customThemePalette,
        ownerUserId: 'user-a',
      ),
      isNull,
    );
  });
}

AgentMutationProposal _proposal({
  required String operationId,
  required AgentOwnerScope scope,
  required String id,
  required Map<String, dynamic> before,
  required Map<String, dynamic> after,
  required int expectedVersion,
}) => AgentMutationProposal(
  operationId: operationId,
  toolName: 'propose_revise_custom_exercise',
  title: 'Revise exercise',
  summary: 'Test revision',
  argumentsJson: jsonEncode({'exercise': after}),
  targetType: 'custom_exercise',
  targetId: id,
  expectedDigest: agentPayloadDigest(before),
  expectedVersion: expectedVersion,
  changes: AgentMutationDiff.between(before, after),
  ownerUserId: scope.ownerUserId,
  authEpoch: scope.epoch,
  createdAt: DateTime.now(),
);

Map<String, dynamic> _exercisePayload(String id, String name) => {
  'id': id,
  'nameEn': name,
  'nameZhCn': name,
  'movement': 'horizontalPull',
  'equipment': 'cable',
  'loadSemantics': 'cableStack',
  'primaryMuscles': ['upperBack'],
  'secondaryMuscles': ['biceps'],
  'tags': ['back', 'row'],
  'roundingIncrementKg': 2.5,
  'sourceExerciseId': null,
};

Map<String, dynamic> _palettePayload(String id, String name) => {
  'id': id,
  'name': name,
  'brightness': 'dark',
  'basePaletteKey': 'obsidianBrass',
  'colors': const <String, String>{
    'background': '#111111',
    'surface': '#1B1B1B',
    'foreground': '#F5F1E8',
    'mutedForeground': '#B8B0A2',
    'accent': '#D6A94E',
    'accentInk': '#111111',
    'strength': '#E05D44',
    'cardio': '#8B6FD6',
    'success': '#72A85F',
    'warning': '#E4A93B',
    'danger': '#D95C65',
  },
};

class _FailingWebAgentRepository extends WebAgentLocalRepository {
  const _FailingWebAgentRepository(super.store);

  @override
  Future<void> saveAction(AgentActionRecord action) {
    throw StateError('Injected audit failure.');
  }
}
