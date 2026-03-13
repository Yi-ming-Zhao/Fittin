import 'package:flutter_test/flutter_test.dart';
import 'package:fittin_v2/src/application/app_locale_provider.dart';
import 'package:fittin_v2/src/domain/models/training_plan.dart';
import 'package:fittin_v2/src/presentation/localization/plan_text.dart';

import '../support/fake_today_workout_gateway.dart';

void main() {
  test('localized plan text resolves Chinese labels with fallback support', () {
    final workout = fakePlanTemplate.workoutByIndex(0);
    final exercise = workout.exercises.first;

    expect(localizedTemplateName(fakePlanTemplate, AppLocale.zh), 'GZCLP 四天十二周');
    expect(localizedWorkoutName(workout, AppLocale.zh), '深蹲主项日');
    expect(localizedWorkoutDayLabel(workout, AppLocale.zh), '第1天');
    expect(localizedExerciseName(exercise, AppLocale.zh), '深蹲');

    expect(localizedTemplateName(fakePlanTemplate, AppLocale.en), 'GZCLP 4-Day 12-Week');
  });
}
