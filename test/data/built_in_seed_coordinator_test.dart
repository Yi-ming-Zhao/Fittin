import 'package:flutter_test/flutter_test.dart';
import 'package:fittin_v2/src/data/seeds/built_in_seed_coordinator.dart';
import 'package:fittin_v2/src/domain/models/training_plan.dart';

void main() {
  late String? storedVersion;
  late Set<String> storedTemplateIds;
  late Map<String, int> loadCounts;
  late List<BuiltInTemplateSeed> seeds;

  setUp(() {
    storedVersion = null;
    storedTemplateIds = {'one', 'two', 'three', 'four'};
    loadCounts = {'one': 0, 'two': 0, 'three': 0, 'four': 0};
    seeds = [
      for (final templateId in loadCounts.keys)
        BuiltInTemplateSeed(
          templateId: templateId,
          loadTemplate: () async {
            loadCounts[templateId] = loadCounts[templateId]! + 1;
            return _template(templateId);
          },
        ),
    ];
  });

  Future<void> ensureSeeded() {
    return ensureBuiltInTemplateSeeds(
      fetchSeedVersion: () async => storedVersion,
      saveSeedVersion: (version) async => storedVersion = version,
      templateExists: (templateId) async =>
          storedTemplateIds.contains(templateId),
      syncTemplate: (seed) async {
        final template = await seed.loadTemplate();
        storedTemplateIds.add(template.id);
      },
      seeds: seeds,
    );
  }

  test('missing marker resynchronizes every built-in template', () async {
    await ensureSeeded();

    expect(loadCounts.values, everyElement(1));
    expect(storedVersion, '$currentBuiltInTemplateSeedVersion');
  });

  test('current marker prevents parsing when all templates exist', () async {
    storedVersion = '$currentBuiltInTemplateSeedVersion';

    await ensureSeeded();

    expect(loadCounts.values, everyElement(0));
  });

  test('current marker reloads only a missing built-in template', () async {
    storedVersion = '$currentBuiltInTemplateSeedVersion';
    storedTemplateIds.remove('three');

    await ensureSeeded();

    expect(loadCounts, {'one': 0, 'two': 0, 'three': 1, 'four': 0});
    expect(storedTemplateIds, contains('three'));
  });

  test(
    'older explicit marker resynchronizes every built-in template',
    () async {
      storedVersion = '0';

      await ensureSeeded();

      expect(loadCounts.values, everyElement(1));
      expect(storedVersion, '$currentBuiltInTemplateSeedVersion');
    },
  );

  test('newer marker is never downgraded by an older app version', () async {
    storedVersion = '${currentBuiltInTemplateSeedVersion + 1}';

    await ensureSeeded();

    expect(loadCounts.values, everyElement(0));
    expect(storedVersion, '${currentBuiltInTemplateSeedVersion + 1}');
  });
}

PlanTemplate _template(String id) {
  return PlanTemplate(id: id, name: id, description: '', phases: const []);
}
