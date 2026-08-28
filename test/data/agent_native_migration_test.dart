import 'package:flutter_test/flutter_test.dart';
import 'package:fittin_v2/src/data/database_repository.dart';
import 'package:fittin_v2/src/data/progress_repository.dart';
import 'package:fittin_v2/src/data/agent_local_repository.dart';
import 'package:fittin_v2/src/data/seeds/shenshi_five_day_seed.dart';
import 'package:fittin_v2/src/domain/models/agent_models.dart';
import 'package:fittin_v2/src/domain/models/body_metric.dart';
import 'package:fittin_v2/src/domain/models/workout_log.dart';
import 'package:fittin_v2/src/domain/models/training_plan.dart';
import '../support/isar_test_helper.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test(
    'old Isar schema retains active plan, metrics and conversations after additive runtime migration',
    () async {
      final old = await openTestIsar(
        'agent_migration',
        includeAgentRuntime: false,
      );
      final db = DatabaseRepository(old.isar);
      final plan = await ShenshiFiveDaySeed.loadTemplate();
      await db.saveTemplate(plan, isBuiltIn: true);
      final instance = await db.activateTemplate(plan.id);
      await db.saveInstance(instance.copyWith(currentWorkoutIndex: 2));
      final log = WorkoutLog(
        logId: 'existing-log',
        instanceId: instance.instanceId,
        workoutId: plan.workouts.first.id,
        workoutName: 'Existing workout',
        dayLabel: 'Day 1',
        completedAt: DateTime(2026, 8, 1),
        exercises: [
          ExerciseLog(
            exerciseId: 'existing-exercise',
            exerciseName: 'Squat',
            stageId: 'working',
            sets: const [
              SetLog(
                role: 'working',
                targetReps: 12,
                completedReps: 12,
                targetWeight: 50,
                weight: 50,
                isCompleted: true,
              ),
            ],
          ),
        ],
      );
      await db.logWorkout(log);
      final metric = BodyMetric(
        metricId: 'existing',
        timestamp: DateTime(2026, 8, 1),
        weightKg: 75,
      );
      await ProgressRepository(old.isar).saveBodyMetric(metric);
      final conversation = AgentConversation(
        id: 'history',
        title: 'Existing',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        messages: const [],
      );
      await IsarAgentLocalRepository(old.isar).saveConversation(conversation);
      await old.isar.close();
      final migrated = await openTestIsar(
        'agent_migration',
        existingDirectory: old.directory,
      );
      addTearDown(() async {
        await migrated.isar.close(deleteFromDisk: true);
        await old.directory.delete(recursive: true);
      });
      final upgraded = DatabaseRepository(migrated.isar);
      expect((await upgraded.fetchActiveInstance())!.currentWorkoutIndex, 2);
      expect(await upgraded.fetchWorkoutLogById(log.logId), log);
      expect((await upgraded.fetchTemplate(plan.id))!.toJson(), plan.toJson());
      expect(
        (await ProgressRepository(
          migrated.isar,
        ).fetchBodyMetrics()).single.toJson(),
        metric.toJson(),
      );
      final agent = IsarAgentLocalRepository(migrated.isar);
      expect((await agent.fetchConversation('history'))!.title, 'Existing');
      await agent.saveDocument('checkpoint', 'run', {'state': 'interrupted'});
      expect(
        (await agent.readDocument('checkpoint', 'run'))!['state'],
        'interrupted',
      );
    },
  );
}
