import 'package:fittin_v2/src/application/app_locale_provider.dart';
import 'package:fittin_v2/src/domain/models/training_plan.dart';

String localizedTemplateName(PlanTemplate template, AppLocale locale) {
  return template.displayName(locale.code);
}

String localizedTemplateDescription(PlanTemplate template, AppLocale locale) {
  return template.displayDescription(locale.code);
}

String localizedWorkoutName(Workout workout, AppLocale locale) {
  return workout.displayName(locale.code);
}

String localizedWorkoutDayLabel(Workout workout, AppLocale locale) {
  return workout.displayDayLabel(locale.code);
}

String localizedExerciseName(Exercise exercise, AppLocale locale) {
  return exercise.displayName(locale.code);
}
