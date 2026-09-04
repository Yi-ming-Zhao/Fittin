import 'package:fittin_v2/src/domain/models/cardio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CardioRecord', () {
    test('derives pace and speed from duration and distance', () {
      final record = CardioRecord(
        id: 'run-1',
        activityTypeId: 'cardio:running',
        activityName: 'Running',
        startedAt: DateTime(2026, 9, 4, 7),
        metrics: const {
          CardioMetricKey.durationSeconds: 1800,
          CardioMetricKey.distanceMeters: 5000,
        },
      );

      expect(
        record.metric(CardioMetricKey.averageSpeedMps),
        closeTo(2.777, 0.001),
      );
      expect(record.metric(CardioMetricKey.paceSecondsPerKm), 360);
      expect(
        () => record.validate(BuiltInCardioActivities.byId('cardio:running')),
        returnsNormally,
      );
    });

    test('uses activity-specific validation', () {
      final inclineWalking = CardioRecord(
        id: 'walk-1',
        activityTypeId: 'cardio:incline-walking',
        activityName: 'Incline walking',
        startedAt: DateTime(2026, 9, 4, 8),
        metrics: const {
          CardioMetricKey.durationSeconds: 1200,
          CardioMetricKey.averageSpeedMps: 1.4,
        },
      );

      expect(
        () => inclineWalking.validate(
          BuiltInCardioActivities.byId('cardio:incline-walking'),
        ),
        throwsFormatException,
      );
    });
  });
}
