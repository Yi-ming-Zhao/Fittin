import 'package:fittin_v2/src/data/seeds/gzclp_seed.dart';
import 'package:fittin_v2/src/data/seeds/jacked_and_tan_seed.dart';
import 'package:fittin_v2/src/data/seeds/powerbuilding_4day_12week_seed.dart';
import 'package:fittin_v2/src/data/seeds/tsa_intermediate_seed.dart';
import 'package:fittin_v2/src/domain/models/training_plan.dart';

const builtInTemplateSeedVersionStateKey = 'built-in-template-seed-version';
// Bump whenever a bundled plan asset or its seed normalization changes.
const currentBuiltInTemplateSeedVersion = 1;

class BuiltInTemplateSeed {
  const BuiltInTemplateSeed({
    required this.templateId,
    required this.loadTemplate,
  });

  final String templateId;
  final Future<PlanTemplate> Function() loadTemplate;
}

final builtInTemplateSeeds = <BuiltInTemplateSeed>[
  const BuiltInTemplateSeed(
    templateId: GzclpSeed.templateId,
    loadTemplate: GzclpSeed.loadTemplate,
  ),
  const BuiltInTemplateSeed(
    templateId: JackedAndTanSeed.templateId,
    loadTemplate: JackedAndTanSeed.loadTemplate,
  ),
  const BuiltInTemplateSeed(
    templateId: TsaIntermediateSeed.templateId,
    loadTemplate: TsaIntermediateSeed.loadTemplate,
  ),
  const BuiltInTemplateSeed(
    templateId: Powerbuilding4Day12WeekSeed.templateId,
    loadTemplate: Powerbuilding4Day12WeekSeed.loadTemplate,
  ),
];

Future<void> ensureBuiltInTemplateSeeds({
  required Future<String?> Function() fetchSeedVersion,
  required Future<void> Function(String version) saveSeedVersion,
  required Future<bool> Function(String templateId) templateExists,
  required Future<void> Function(BuiltInTemplateSeed seed) syncTemplate,
  List<BuiltInTemplateSeed>? seeds,
}) async {
  final storedVersion = _parseSeedVersion(await fetchSeedVersion());
  if (storedVersion != null &&
      storedVersion > currentBuiltInTemplateSeedVersion) {
    return;
  }

  final resolvedSeeds = seeds ?? builtInTemplateSeeds;
  if (storedVersion == currentBuiltInTemplateSeedVersion) {
    for (final seed in resolvedSeeds) {
      if (!await templateExists(seed.templateId)) {
        await syncTemplate(seed);
      }
    }
    return;
  }

  for (final seed in resolvedSeeds) {
    await syncTemplate(seed);
  }

  if (_isCurrentOrNewer(await fetchSeedVersion())) {
    return;
  }
  await saveSeedVersion('$currentBuiltInTemplateSeedVersion');
}

int? _parseSeedVersion(String? storedVersion) {
  return int.tryParse(storedVersion ?? '');
}

bool _isCurrentOrNewer(String? storedVersion) {
  final parsedVersion = _parseSeedVersion(storedVersion);
  return parsedVersion != null &&
      parsedVersion >= currentBuiltInTemplateSeedVersion;
}
