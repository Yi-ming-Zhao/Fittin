import 'dart:convert';

import 'package:fittin_v2/src/application/active_session_provider.dart';
import 'package:fittin_v2/src/application/agent_mutation_coordinator.dart';
import 'package:fittin_v2/src/application/agent_owner_scope.dart';
import 'package:fittin_v2/src/application/agent_tools.dart';
import 'package:fittin_v2/src/application/app_locale_provider.dart';
import 'package:fittin_v2/src/application/auth_provider.dart';
import 'package:fittin_v2/src/application/fittin_theme_provider.dart';
import 'package:fittin_v2/src/data/agent_local_repository.dart';
import 'package:fittin_v2/src/data/database_repository.dart';
import 'package:fittin_v2/src/data/models/sync_queue_collection.dart';
import 'package:fittin_v2/src/domain/models/agent_models.dart';
import 'package:fittin_v2/src/domain/models/custom_theme_palette.dart';
import 'package:fittin_v2/src/domain/models/user_content.dart';
import 'package:fittin_v2/src/presentation/theme/fittin_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../support/isar_test_helper.dart';

final _ownerProvider = StateProvider<String?>((ref) => 'user-a');

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('library tools read built-ins and reject unsafe model input', () async {
    final fixture = await _openFixture('agent_library_tools');
    addTearDown(fixture.close);
    final tools = fixture.container.read(agentToolRegistryProvider);

    final exercises = await tools.execute('list_exercises', {
      'source': 'built_in',
      'limit': 2,
    });
    expect(exercises.isError, isFalse, reason: exercises.encoded);
    final builtInExercise =
        (exercises.payload['exercises'] as List).first as Map;
    expect(builtInExercise['isBuiltIn'], isTrue);
    final exerciseId = builtInExercise['id'] as String;
    final readExercise = await tools.execute('get_exercise', {
      'exerciseId': exerciseId,
    });
    expect(readExercise.payload['exercise'], containsPair('id', exerciseId));

    final deleteBuiltIn = await tools.execute(
      'propose_delete_custom_exercise',
      {'exerciseId': exerciseId},
    );
    expect(deleteBuiltIn.isError, isTrue);
    final copyBuiltIn = await tools.execute('propose_revise_custom_exercise', {
      'exerciseId': exerciseId,
      'definition': _exerciseInput('Safe copy'),
    });
    expect(copyBuiltIn.isError, isFalse, reason: copyBuiltIn.encoded);
    expect(copyBuiltIn.proposal!.toolName, 'propose_create_custom_exercise');
    final copiedPayload =
        jsonDecode(copyBuiltIn.proposal!.argumentsJson)['exercise'] as Map;
    expect(copiedPayload['sourceExerciseId'], exerciseId);
    expect(copiedPayload['id'], startsWith('user-exercise:'));

    final palettes = await tools.execute('list_theme_palettes', {
      'source': 'built_in',
      'limit': 2,
    });
    expect(palettes.isError, isFalse, reason: palettes.encoded);
    final paletteId =
        ((palettes.payload['palettes'] as List).first as Map)['id'] as String;
    expect(
      (await tools.execute('get_theme_palette', {
        'paletteId': paletteId,
      })).isError,
      isFalse,
    );
    expect(
      (await tools.execute('propose_delete_custom_palette', {
        'paletteId': paletteId,
      })).isError,
      isTrue,
    );

    final injected = await tools.execute('propose_create_custom_exercise', {
      'definition': {
        ..._exerciseInput('Injected'),
        'ownerUserId': 'other-user',
      },
    });
    expect(injected.isError, isTrue);
    final cyan = await tools.execute('propose_create_custom_palette', {
      'palette': {
        ..._paletteInput('Unsafe'),
        'colors': {..._paletteColors, 'accent': '#00AFAA'},
      },
    });
    expect(cyan.isError, isTrue);
  });

  test(
    'custom exercise proposal uses complete diff, atomic CAS and reversible soft delete',
    () async {
      final fixture = await _openFixture('agent_exercise_mutations');
      addTearDown(fixture.close);
      final tools = fixture.container.read(agentToolRegistryProvider);
      final coordinator = fixture.container.read(
        agentMutationCoordinatorProvider,
      );

      final create = await tools.execute('propose_create_custom_exercise', {
        'definition': _exerciseInput('Cable row'),
      });
      expect(create.isError, isFalse, reason: create.encoded);
      expect(create.proposal!.expectedVersion, 0);
      expect(
        create.proposal!.changes.map((change) => change.path),
        containsAll(['英文名称', '中文名称', '主要肌群 1']),
      );
      final createdAction = await coordinator.confirm(create.proposal!);
      final exerciseId = create.proposal!.targetId;
      var stored = await fixture.database.fetchUserContentOfKind(
        exerciseId,
        kind: UserContentKind.customExercise,
        ownerUserId: 'user-a',
      );
      expect(stored, isNotNull);
      expect(stored!.version, 1);
      expect(stored.payload.containsKey('ownerUserId'), isFalse);
      expect(
        (await coordinator.confirm(create.proposal!)).id,
        createdAction.id,
      );
      const otherId = 'user-exercise:other-owner';
      await fixture.database.saveUserContent(
        UserContentDocument(
          id: otherId,
          kind: UserContentKind.customExercise,
          payload: {...stored.payload, 'id': otherId},
          ownerUserId: 'user-b',
        ),
      );
      final ownerScoped = await tools.execute('list_exercises', {
        'source': 'custom',
      });
      expect(
        (ownerScoped.payload['exercises'] as List).map(
          (item) => (item as Map)['id'],
        ),
        [exerciseId],
      );
      expect(
        (await tools.execute('get_exercise', {'exerciseId': otherId})).isError,
        isTrue,
      );

      final scope = fixture.container.read(agentOwnerScopeProvider);
      final hiddenDiffPayload = Map<String, dynamic>.from(stored.payload)
        ..['nameEn'] = 'Hidden change';
      await expectLater(
        coordinator.confirm(
          AgentMutationProposal(
            operationId: 'incomplete-library-preview',
            toolName: 'propose_revise_custom_exercise',
            title: 'Incomplete preview',
            summary: 'Must be rejected',
            argumentsJson: jsonEncode({'exercise': hiddenDiffPayload}),
            targetType: 'custom_exercise',
            targetId: exerciseId,
            expectedDigest: agentPayloadDigest(stored.payload),
            expectedVersion: stored.version,
            changes: const [],
            ownerUserId: scope.ownerUserId,
            authEpoch: scope.epoch,
            createdAt: DateTime.now(),
          ),
        ),
        throwsA(isA<AgentMutationConflict>()),
      );

      final revise = await tools.execute('propose_revise_custom_exercise', {
        'exerciseId': exerciseId,
        'definition': _exerciseInput('Chest-supported cable row'),
      });
      expect(revise.isError, isFalse, reason: revise.encoded);
      expect(revise.proposal!.expectedVersion, 1);
      final revisedAction = await coordinator.confirm(revise.proposal!);
      stored = await fixture.database.fetchUserContentOfKind(
        exerciseId,
        kind: UserContentKind.customExercise,
        ownerUserId: 'user-a',
      );
      expect(stored!.payload['nameEn'], 'Chest-supported cable row');
      expect(stored.version, 2);
      await coordinator.undo(revisedAction.id);
      stored = await fixture.database.fetchUserContentOfKind(
        exerciseId,
        kind: UserContentKind.customExercise,
        ownerUserId: 'user-a',
      );
      expect(stored!.payload['nameEn'], 'Cable row');
      expect(stored.version, 3);

      final deletion = await tools.execute('propose_delete_custom_exercise', {
        'exerciseId': exerciseId,
      });
      final deletedAction = await coordinator.confirm(deletion.proposal!);
      expect(
        await fixture.database.fetchUserContentOfKind(
          exerciseId,
          kind: UserContentKind.customExercise,
          ownerUserId: 'user-a',
        ),
        isNull,
      );
      await coordinator.undo(deletedAction.id);
      stored = await fixture.database.fetchUserContentOfKind(
        exerciseId,
        kind: UserContentKind.customExercise,
        ownerUserId: 'user-a',
      );
      expect(stored!.payload['nameEn'], 'Cable row');
      expect(stored.version, 5);
    },
  );

  test('library versions reject ABA confirmation and undo', () async {
    final fixture = await _openFixture('agent_library_aba');
    addTearDown(fixture.close);
    final tools = fixture.container.read(agentToolRegistryProvider);
    final coordinator = fixture.container.read(
      agentMutationCoordinatorProvider,
    );
    final create = await tools.execute('propose_create_custom_palette', {
      'palette': _paletteInput('Archive'),
    });
    await coordinator.confirm(create.proposal!);
    final id = create.proposal!.targetId;

    final stale = await tools.execute('propose_revise_custom_palette', {
      'paletteId': id,
      'palette': _paletteInput('Archive revised'),
    });
    final original = (await fixture.database.fetchUserContentOfKind(
      id,
      kind: UserContentKind.customThemePalette,
      ownerUserId: 'user-a',
    ))!;
    final intermediate = Map<String, dynamic>.from(original.payload)
      ..['name'] = 'Intermediate';
    await fixture.database.saveUserContent(
      UserContentDocument(
        id: id,
        kind: UserContentKind.customThemePalette,
        payload: intermediate,
        ownerUserId: 'user-a',
      ),
      expectedVersion: 1,
    );
    await fixture.database.saveUserContent(
      UserContentDocument(
        id: id,
        kind: UserContentKind.customThemePalette,
        payload: original.payload,
        ownerUserId: 'user-a',
      ),
      expectedVersion: 2,
    );
    await expectLater(
      coordinator.confirm(stale.proposal!),
      throwsA(isA<AgentMutationConflict>()),
    );

    fixture.container.read(_ownerProvider.notifier).state = 'user-b';
    final switched = await tools.execute('propose_create_custom_palette', {
      'palette': _paletteInput('Other user'),
    });
    expect(switched.proposal!.ownerUserId, 'user-b');
    fixture.container.read(_ownerProvider.notifier).state = 'user-a';
    await expectLater(
      coordinator.confirm(switched.proposal!),
      throwsA(isA<AgentMutationConflict>()),
    );
  });

  test(
    'deleting an active custom palette falls back after committed soft deletion',
    () async {
      final fixture = await _openFixture('agent_active_palette_delete');
      addTearDown(fixture.close);
      final tools = fixture.container.read(agentToolRegistryProvider);
      final coordinator = fixture.container.read(
        agentMutationCoordinatorProvider,
      );
      final create = await tools.execute('propose_create_custom_palette', {
        'palette': _paletteInput('Active palette'),
      });
      await coordinator.confirm(create.proposal!);
      final id = create.proposal!.targetId;
      await fixture.container
          .read(fittinThemeProvider.notifier)
          .setPaletteKey(id);

      final deletion = await tools.execute('propose_delete_custom_palette', {
        'paletteId': id,
      });
      expect(deletion.proposal!.progressionEffect, contains('默认配色'));
      final action = await coordinator.confirm(deletion.proposal!);
      expect(
        fixture.container.read(fittinThemeProvider),
        FittinPaletteRegistry.defaultId.storageKey,
      );
      expect(
        await fixture.database.fetchUserContentOfKind(
          id,
          kind: UserContentKind.customThemePalette,
          ownerUserId: 'user-a',
        ),
        isNull,
      );

      await coordinator.undo(action.id);
      expect(
        await fixture.database.fetchUserContentOfKind(
          id,
          kind: UserContentKind.customThemePalette,
          ownerUserId: 'user-a',
        ),
        isNotNull,
      );
      expect(
        fixture.container.read(fittinThemeProvider),
        FittinPaletteRegistry.defaultId.storageKey,
      );
    },
  );

  test(
    'undoing a newly created selected palette removes it and falls back safely',
    () async {
      final fixture = await _openFixture('agent_active_palette_create_undo');
      addTearDown(fixture.close);
      final tools = fixture.container.read(agentToolRegistryProvider);
      final coordinator = fixture.container.read(
        agentMutationCoordinatorProvider,
      );
      final create = await tools.execute('propose_create_custom_palette', {
        'palette': _paletteInput('Temporary palette'),
      });
      final action = await coordinator.confirm(create.proposal!);
      final id = create.proposal!.targetId;
      await fixture.container
          .read(fittinThemeProvider.notifier)
          .setPaletteKey(id);
      // A new scope represents a process/controller lifecycle after the
      // action was persisted. Undo remains owner-scoped across that boundary.
      fixture.container.invalidate(agentOwnerScopeProvider);

      await coordinator.undo(action.id);

      expect(
        await fixture.database.fetchUserContentOfKind(
          id,
          kind: UserContentKind.customThemePalette,
          ownerUserId: 'user-a',
        ),
        isNull,
      );
      expect(
        fixture.container.read(fittinThemeProvider),
        FittinPaletteRegistry.defaultId.storageKey,
      );
    },
  );

  test('coordinator independently refuses forged built-in deletion', () async {
    final fixture = await _openFixture('agent_library_forged');
    addTearDown(fixture.close);
    final scope = fixture.container.read(agentOwnerScopeProvider);
    final proposal = AgentMutationProposal(
      operationId: 'forged-built-in-delete',
      toolName: 'propose_delete_custom_exercise',
      title: 'Delete built-in',
      summary: 'forged',
      argumentsJson: jsonEncode({'exerciseId': 'barbell-back-squat'}),
      targetType: 'custom_exercise',
      targetId: 'barbell-back-squat',
      expectedDigest: agentPayloadDigest(null),
      expectedVersion: 0,
      changes: const [],
      ownerUserId: scope.ownerUserId,
      authEpoch: scope.epoch,
      createdAt: DateTime.now(),
    );

    await expectLater(
      fixture.container
          .read(agentMutationCoordinatorProvider)
          .confirm(proposal),
      throwsA(isA<AgentMutationConflict>()),
    );
    expect(
      await fixture.container
          .read(agentLocalRepositoryProvider)
          .fetchActions(ownerUserId: 'user-a'),
      isEmpty,
    );
  });

  test(
    'library row and sync queue roll back if audit persistence fails',
    () async {
      final opened = await openTestIsar('agent_library_atomic_failure');
      addTearDown(() async {
        await opened.isar.close(deleteFromDisk: true);
        if (await opened.directory.exists()) {
          await opened.directory.delete(recursive: true);
        }
      });
      final database = DatabaseRepository(opened.isar);
      final actions = _FailingIsarAgentRepository(opened.isar);
      final container = ProviderContainer(
        overrides: [
          databaseRepositoryProvider.overrideWithValue(database),
          agentLocalRepositoryProvider.overrideWithValue(actions),
          currentUserIdProvider.overrideWithValue('user-a'),
        ],
      );
      addTearDown(container.dispose);
      final proposed = await container.read(agentToolRegistryProvider).execute(
        'propose_create_custom_exercise',
        {'definition': _exerciseInput('Atomic row')},
      );

      await expectLater(
        container
            .read(agentMutationCoordinatorProvider)
            .confirm(proposed.proposal!),
        throwsStateError,
      );
      expect(
        await database.fetchUserContentOfKind(
          proposed.proposal!.targetId,
          kind: UserContentKind.customExercise,
          ownerUserId: 'user-a',
        ),
        isNull,
      );
      expect(await actions.fetchActions(ownerUserId: 'user-a'), isEmpty);
      expect(await opened.isar.syncQueueCollections.count(), 0);
    },
  );

  test(
    'active palette selection stays unchanged when native audit rolls back deletion',
    () async {
      final opened = await openTestIsar('agent_active_palette_atomic_failure');
      addTearDown(() async {
        await opened.isar.close(deleteFromDisk: true);
        if (await opened.directory.exists()) {
          await opened.directory.delete(recursive: true);
        }
      });
      final database = DatabaseRepository(opened.isar);
      const id = 'user-palette:native-rollback';
      final payload = <String, dynamic>{
        'id': id,
        ..._paletteInput('Rollback palette'),
      };
      await database.saveUserContent(
        UserContentDocument(
          id: id,
          kind: UserContentKind.customThemePalette,
          payload: payload,
          ownerUserId: 'user-a',
        ),
        expectedVersion: 0,
      );
      final actions = _FailingIsarAgentRepository(opened.isar);
      final container = ProviderContainer(
        overrides: [
          databaseRepositoryProvider.overrideWithValue(database),
          agentLocalRepositoryProvider.overrideWithValue(actions),
          currentUserIdProvider.overrideWithValue('user-a'),
        ],
      );
      addTearDown(container.dispose);
      await container.read(fittinThemeProvider.notifier).setPaletteKey(id);
      final proposed = await container.read(agentToolRegistryProvider).execute(
        'propose_delete_custom_palette',
        {'paletteId': id},
      );

      await expectLater(
        container
            .read(agentMutationCoordinatorProvider)
            .confirm(proposed.proposal!),
        throwsStateError,
      );

      expect(container.read(fittinThemeProvider), id);
      final stored = await database.fetchUserContentOfKind(
        id,
        kind: UserContentKind.customThemePalette,
        ownerUserId: 'user-a',
      );
      expect(stored, isNotNull);
      expect(stored!.payload['name'], 'Rollback palette');
      expect(await actions.fetchActions(ownerUserId: 'user-a'), isEmpty);
    },
  );

  test(
    'active palette cache stays unchanged when native audit rolls back revision',
    () async {
      SharedPreferences.setMockInitialValues({});
      final preferences = await SharedPreferences.getInstance();
      final opened = await openTestIsar(
        'agent_active_palette_revision_failure',
      );
      addTearDown(() async {
        await opened.isar.close(deleteFromDisk: true);
        if (await opened.directory.exists()) {
          await opened.directory.delete(recursive: true);
        }
      });
      final database = DatabaseRepository(opened.isar);
      const id = 'user-palette:native-revision-rollback';
      final payload = <String, dynamic>{
        'id': id,
        ..._paletteInput('Original palette'),
      };
      await database.saveUserContent(
        UserContentDocument(
          id: id,
          kind: UserContentKind.customThemePalette,
          payload: payload,
          ownerUserId: 'user-a',
        ),
        expectedVersion: 0,
      );
      final actions = _FailingIsarAgentRepository(opened.isar);
      final container = ProviderContainer(
        overrides: [
          databaseRepositoryProvider.overrideWithValue(database),
          agentLocalRepositoryProvider.overrideWithValue(actions),
          currentUserIdProvider.overrideWithValue('user-a'),
          fittinThemePreferencesProvider.overrideWithValue(preferences),
        ],
      );
      addTearDown(container.dispose);
      await container
          .read(fittinThemeProvider.notifier)
          .setCustomPalette(CustomThemePalette.fromJson(payload));
      final proposed = await container.read(agentToolRegistryProvider).execute(
        'propose_revise_custom_palette',
        {'paletteId': id, 'palette': _paletteInput('Revised palette')},
      );

      await expectLater(
        container
            .read(agentMutationCoordinatorProvider)
            .confirm(proposed.proposal!),
        throwsStateError,
      );
      await Future<void>.delayed(Duration.zero);

      final stored = await database.fetchUserContentOfKind(
        id,
        kind: UserContentKind.customThemePalette,
        ownerUserId: 'user-a',
      );
      expect(stored!.payload['name'], 'Original palette');
      expect(
        FittinThemeNotifier.cachedCustomPalette(preferences)?.name,
        'Original palette',
      );
      expect(await actions.fetchActions(ownerUserId: 'user-a'), isEmpty);
    },
  );
}

Map<String, dynamic> _exerciseInput(String name) => {
  'nameEn': name,
  'nameZhCn': name == 'Cable row' ? '绳索划船' : '胸托绳索划船',
  'movement': 'horizontalPull',
  'equipment': 'cable',
  'loadSemantics': 'cableStack',
  'primaryMuscles': ['upperBack'],
  'secondaryMuscles': ['biceps'],
  'tags': ['back', 'row'],
  'roundingIncrementKg': 2.5,
};

Map<String, dynamic> _paletteInput(String name) => {
  'name': name,
  'brightness': 'dark',
  'basePaletteKey': 'obsidianBrass',
  'colors': _paletteColors,
};

const _paletteColors = <String, String>{
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
};

Future<_Fixture> _openFixture(String name) async {
  final opened = await openTestIsar(name);
  final database = DatabaseRepository(opened.isar);
  final container = ProviderContainer(
    overrides: [
      databaseRepositoryProvider.overrideWithValue(database),
      agentLocalRepositoryProvider.overrideWithValue(
        IsarAgentLocalRepository(opened.isar),
      ),
      currentUserIdProvider.overrideWith((ref) => ref.watch(_ownerProvider)),
      appLocaleProvider.overrideWith(
        (ref) => AppLocaleNotifier(ref, initialLocale: AppLocale.zh),
      ),
    ],
  );
  return _Fixture(
    database: database,
    container: container,
    close: () async {
      container.dispose();
      await opened.isar.close(deleteFromDisk: true);
      await opened.directory.delete(recursive: true);
    },
  );
}

class _Fixture {
  const _Fixture({
    required this.database,
    required this.container,
    required this.close,
  });

  final DatabaseRepository database;
  final ProviderContainer container;
  final Future<void> Function() close;
}

class _FailingIsarAgentRepository extends IsarAgentLocalRepository {
  const _FailingIsarAgentRepository(super.isar);

  @override
  Future<void> saveAction(AgentActionRecord action) {
    throw StateError('Injected audit failure.');
  }
}
