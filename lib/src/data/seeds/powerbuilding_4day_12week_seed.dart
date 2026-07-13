import 'package:fittin_v2/src/domain/models/training_plan.dart';
import 'package:fittin_v2/src/domain/models/training_state.dart';

import 'seed_utils.dart';

class Powerbuilding4Day12WeekSeed {
  static const templateId = 'powerbuilding-4day-12week';
  static const instanceId = 'active-powerbuilding-4day-12week-instance';
  static const assetPath = 'assets/plans/powerbuilding_4day_12week.json';

  static Future<PlanTemplate> loadTemplate() async {
    return loadTemplateAsset(
      assetPath: assetPath,
      expectedTemplateId: templateId,
    );
  }

  static List<TrainingState> buildStarterStates(PlanTemplate template) {
    return buildStarterStatesForTemplate(template);
  }
}
