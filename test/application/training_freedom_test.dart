import 'package:flutter_test/flutter_test.dart';
import 'package:fittin_v2/src/application/services/today_workout_gateway.dart';
import 'package:fittin_v2/src/data/database_repository.dart';
import 'package:fittin_v2/src/data/local/local_workout_log_repository.dart';
import 'package:fittin_v2/src/data/seeds/gzclp_seed.dart';
import 'package:fittin_v2/src/domain/microcycle_schedule.dart';
import 'package:fittin_v2/src/domain/models/workout_log.dart';
import 'package:fittin_v2/src/domain/workout_session_editing.dart';
import '../support/in_memory_database_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late InMemoryDatabaseRepository database;
  late DatabaseTodayWorkoutGateway gateway;
  late LocalWorkoutLogRepository history;

  setUp(() async {
    database = InMemoryDatabaseRepository();
    final template = await GzclpSeed.loadTemplate();
    await database.saveTemplate(template, isBuiltIn: true);
    await database.saveInstance(
      StoredTrainingInstance(
        instanceId: 'training',
        templateId: template.id,
        currentWorkoutIndex: 0,
        states: GzclpSeed.buildStarterStates(template),
      ),
    );
    await database.saveActiveInstanceId('training');
    gateway = DatabaseTodayWorkoutGateway(database);
    history = LocalWorkoutLogRepository(
      repository: database,
      ownerUserId: null,
    );
  });

  Future<WorkoutLog> conclude() async {
    final session = await gateway.loadTodayWorkoutSession();
    await gateway.concludeWorkoutSession(
      session.copyWith(
        exercises: [
          for (final exercise in session.exercises)
            exercise.copyWith(
              sets: [
                for (final set in exercise.sets)
                  set.copyWith(isCompleted: true),
              ],
            ),
        ],
      ),
    );
    return (await database.fetchAllWorkoutLogs()).first;
  }

  test(
    'skip advances schedule without performance progression or a fake log',
    () async {
      final before = (await database.fetchInstance('training'))!;
      await gateway.skipTodayWorkout();
      final after = (await database.fetchInstance('training'))!;
      expect(after.currentWorkoutIndex, 1);
      expect(after.states, before.states);
      expect(await database.fetchAllWorkoutLogs(), isEmpty);
    },
  );

  test('skip and reorder cannot overwrite an active draft', () async {
    final draft = await gateway.loadTodayWorkoutSession();
    await database.saveActiveSessionDraft(draft);
    await expectLater(gateway.skipTodayWorkout(), throwsStateError);
    final pending = await gateway.loadRemainingMicrocycleWorkouts();
    await expectLater(
      gateway.reorderTodayWorkout(pending[1].id),
      throwsStateError,
    );
    expect(await database.fetchActiveSessionDraft('training'), draft);
  });

  test('stale schedule preview cannot skip or reorder a new day', () async {
    final token = (await gateway.loadTodayWorkoutSession()).scheduleToken;
    await gateway.skipTodayWorkout();
    await expectLater(
      gateway.skipTodayWorkout(expectedToken: token),
      throwsStateError,
    );
    final remaining = await gateway.loadRemainingMicrocycleWorkouts();
    await expectLater(
      gateway.reorderTodayWorkout(remaining.last.id, expectedToken: token),
      throwsStateError,
    );
    expect((await database.fetchInstance('training'))!.currentWorkoutIndex, 1);
  });

  test('schedule compare-and-swap refuses a stale version', () async {
    final before = (await database.fetchInstance('training'))!;
    await gateway.skipTodayWorkout();
    await expectLater(
      database.updateInstanceEngineState(
        instanceId: 'training',
        ownerUserId: null,
        expectedVersion: before.version,
        engineState: const {},
      ),
      throwsStateError,
    );
    expect((await database.fetchInstance('training'))!.currentWorkoutIndex, 1);
  });

  test('delete only preserves plan progression', () async {
    final log = await conclude();
    final before = (await database.fetchInstance('training'))!;
    await history.deleteWorkoutLog(log.logId, expectedLog: log);
    final after = (await database.fetchInstance('training'))!;
    expect(after.currentWorkoutIndex, before.currentWorkoutIndex);
    expect(after.states, before.states);
    expect(await database.fetchAllWorkoutLogs(), isEmpty);
    final repeated = await conclude();
    expect(repeated.logId, isNot(log.logId));
  });

  test(
    'release latest matching record restores its exact previous state',
    () async {
      final before = (await database.fetchInstance('training'))!;
      final log = await conclude();
      await history.deleteWorkoutLog(
        log.logId,
        expectedLog: log,
        releaseToPlan: true,
      );
      final after = (await database.fetchInstance('training'))!;
      expect(after.currentWorkoutIndex, before.currentWorkoutIndex);
      expect(after.states, before.states);
      expect(await database.fetchAllWorkoutLogs(), isEmpty);
      final repeated = await conclude();
      expect(repeated.logId, isNot(log.logId));
    },
  );

  test(
    'older released day is queued and its completion does not advance regular plan',
    () async {
      final oldLog = await conclude();
      await Future<void>.delayed(const Duration(milliseconds: 2));
      final newerLog = await conclude();
      final before = (await database.fetchInstance('training'))!;
      await history.deleteWorkoutLog(
        oldLog.logId,
        expectedLog: oldLog,
        releaseToPlan: true,
      );
      final queued = (await database.fetchInstance('training'))!;
      expect(queued.currentWorkoutIndex, before.currentWorkoutIndex);
      expect(queued.states, before.states);
      expect(releasedWorkoutQueue(queued), [oldLog.workoutId]);
      expect(
        (await gateway.loadTodayWorkoutSession()).workoutId,
        oldLog.workoutId,
      );
      final recoveredLog = await conclude();
      final after = (await database.fetchInstance('training'))!;
      expect(after.currentWorkoutIndex, before.currentWorkoutIndex);
      expect(after.states, before.states);
      expect(releasedWorkoutQueue(after), isEmpty);
      expect(await database.fetchWorkoutLogById(newerLog.logId), isNotNull);
      final result = await history.updateWorkoutLog(recoveredLog);
      expect(result.progressionRewritten, isFalse);
    },
  );

  test(
    'release refuses a live draft and stale history without partial deletion',
    () async {
      final log = await conclude();
      await database.saveActiveSessionDraft(
        await gateway.loadTodayWorkoutSession(),
      );
      await expectLater(
        history.deleteWorkoutLog(
          log.logId,
          expectedLog: log,
          releaseToPlan: true,
        ),
        throwsStateError,
      );
      expect(await database.fetchWorkoutLogById(log.logId), log);
      await expectLater(
        history.deleteWorkoutLog(
          log.logId,
          expectedLog: log.copyWith(workoutName: 'stale'),
        ),
        throwsStateError,
      );
      expect(await database.fetchWorkoutLogById(log.logId), log);
    },
  );

  test(
    'history recorder roundtrip preserves trusted snapshots, IDs, flags, and RPE',
    () async {
      final log = await conclude();
      final original = log.copyWith(
        exercises: [
          log.exercises.first.copyWith(
            sets: [
              log.exercises.first.sets.first.copyWith(
                targetRpe: 8,
                completedRpe: 7.5,
                isSkipped: false,
              ),
            ],
          ),
        ],
      );
      final roundtrip = applySessionToHistory(
        original,
        sessionForHistory(original),
      );
      expect(roundtrip, original);
    },
  );

  test(
    'free training logs participate in history without an instance or progression',
    () async {
      final before = (await database.fetchInstance('training'))!;
      final session = (await gateway.loadTodayWorkoutSession()).copyWith(
        instanceId: 'free:local',
      );
      final log = WorkoutLog(
        logId: 'free:test',
        instanceId: 'free:local',
        workoutId: 'free-test',
        workoutName: 'Free training',
        dayLabel: '',
        completedAt: DateTime.now(),
        exercises: const [],
      );
      await history.logWorkout(applySessionToHistory(log, session));
      expect(
        (await history.fetchAllWorkoutLogs()).single.instanceId,
        'free:local',
      );
      expect((await database.fetchInstance('training'))!.states, before.states);
      await expectLater(
        history.deleteWorkoutLog(log.logId, releaseToPlan: true),
        throwsStateError,
      );
    },
  );
}
