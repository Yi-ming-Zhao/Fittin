import 'package:fittin_v2/src/domain/models/training_plan.dart';

import 'seed_utils.dart';

class ShenshiFiveDaySeed {
  static const templateId = 'shenshi-five-day-split';
  static const assetPath = 'assets/plans/shenshi_five_day_split.json';

  static Future<PlanTemplate> loadTemplate() =>
      loadTemplateAsset(assetPath: assetPath, expectedTemplateId: templateId);
}
