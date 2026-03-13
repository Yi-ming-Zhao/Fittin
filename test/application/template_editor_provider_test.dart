import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fittin_v2/src/application/active_session_provider.dart';
import 'package:fittin_v2/src/application/template_editor_provider.dart';
import 'package:fittin_v2/src/data/seeds/gzclp_seed.dart';
import 'package:fittin_v2/src/domain/models/training_plan.dart';

import '../support/in_memory_database_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  InMemoryDatabaseRepository? repository;
  ProviderContainer? container;

  setUp(() async {
    repository = InMemoryDatabaseRepository();
    await repository!.ensureDefaultProgramSeeded();
    container = ProviderContainer(
      overrides: [databaseRepositoryProvider.overrideWithValue(repository!)],
    );
  });

  tearDown(() async {
    container?.dispose();
  });

  test('editing the seeded template saves a customized copy', () async {
    final notifier = container!.read(templateEditorProvider.notifier);
    await notifier.loadTemplate(GzclpSeed.templateId);

    notifier.updateTemplateName('GZCLP Custom');
    notifier.updateSetTargetReps(0, 0, 0, 1, 12);
    notifier.updateSetAmrap(0, 0, 0, 1, true);

    final saved = await notifier.saveTemplate();
    final state = container!.read(templateEditorProvider);

    expect(saved, isNotNull);
    expect(saved!.template.id, isNot(GzclpSeed.templateId));
    expect(saved.template.name, 'GZCLP Custom');
    expect(
      saved
          .template
          .workouts
          .first
          .exercises
          .first
          .stages
          .first
          .sets[1]
          .targetReps,
      12,
    );
    expect(
      saved
          .template
          .workouts
          .first
          .exercises
          .first
          .stages
          .first
          .sets[1]
          .isAmrap,
      isTrue,
    );
    expect(state.infoMessage, 'Saved as a new template copy.');
  });

  test('invalid drafts are blocked from saving', () async {
    final notifier = container!.read(templateEditorProvider.notifier);
    notifier.createBlankTemplate();
    notifier.updateTemplateName(' ');

    final saved = await notifier.saveTemplate();
    final state = container!.read(templateEditorProvider);

    expect(saved, isNull);
    expect(state.validationErrors, contains('Template name is required.'));
    expect(state.errorMessage, 'Template name is required.');
  });
}
