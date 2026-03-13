import 'package:fittin_v2/src/domain/models/training_plan.dart';
import 'package:fittin_v2/src/domain/models/training_state.dart';

import 'seed_utils.dart';

class JackedAndTanSeed {
  static const templateId = 'jacked-and-tan-2-0';
  static const instanceId = 'active-jacked-and-tan-instance';
  static const assetPath = 'assets/plans/jacked_and_tan_2_0.json';

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
