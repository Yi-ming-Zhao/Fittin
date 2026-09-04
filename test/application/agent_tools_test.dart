import 'dart:convert';
import 'package:fittin_v2/src/application/agent_tools.dart';
import 'package:fittin_v2/src/application/app_locale_provider.dart';
import 'package:fittin_v2/src/data/progress_repository.dart';
import 'package:fittin_v2/src/domain/models/body_metric.dart';
import 'package:fittin_v2/src/domain/models/workout_log.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'body metric tool contracts accept explicit null and preserve omitted fields',
    () async {
      final progress = InMemoryProgressRepository();
      await progress.saveBodyMetric(
        BodyMetric(
          metricId: 'm',
          timestamp: DateTime(2026, 8, 13),
          weightKg: 70,
          bodyFatPercent: 20,
          waistCm: 80,
          note: 'note',
        ),
      );
      final container = ProviderContainer(
        overrides: [
          progressRepositoryProvider.overrideWithValue(progress),
          appLocaleProvider.overrideWith(
            (ref) => AppLocaleNotifier(ref, initialLocale: AppLocale.zh),
          ),
        ],
      );
      addTearDown(container.dispose);
      for (final field in ['bodyFatPercent', 'waistCm', 'note']) {
        final result = await container.read(agentToolRegistryProvider).execute(
          'propose_update_body_metric',
          {'metricId': 'm', field: null},
        );
        expect(result.isError, false, reason: result.encoded);
        final metric =
            jsonDecode(result.proposal!.argumentsJson)['metric'] as Map;
        expect(metric[field], isNull);
        expect(metric['weightKg'], 70);
        expect((await progress.fetchBodyMetrics()).single.note, 'note');
      }
    },
  );

  test('tool allowlist exposes only structured fitness capabilities', () {
    expect(AgentToolRegistry.exposedReadToolsForTesting, {
      'list_plans',
      'get_active_plan',
      'get_plan',
      'get_workout_history',
      'analyze_training',
      'get_body_metrics',
      'list_exercises',
      'get_exercise',
      'list_theme_palettes',
      'get_theme_palette',
    });
    expect(AgentToolRegistry.exposedMutationToolsForTesting, {
      'propose_create_plan',
      'propose_revise_plan',
      'propose_delete_plan',
      'propose_create_workout_log',
      'propose_update_workout_log',
      'propose_delete_workout_log',
      'propose_create_body_metric',
      'propose_update_body_metric',
      'propose_delete_body_metric',
      'propose_create_custom_exercise',
      'propose_revise_custom_exercise',
      'propose_delete_custom_exercise',
      'propose_create_custom_palette',
      'propose_revise_custom_palette',
      'propose_delete_custom_palette',
    });
    final names = {
      ...AgentToolRegistry.exposedReadToolsForTesting,
      ...AgentToolRegistry.exposedMutationToolsForTesting,
    };
    for (final forbidden in [
      'photo',
      'account',
      'auth',
      'setting',
      'file',
      'http',
      'code',
    ]) {
      expect(names.any((name) => name.contains(forbidden)), isFalse);
    }
  });

  test('body metric validation enforces product boundaries', () {
    expect(
      () => validateAgentBodyMetric(
        BodyMetric(
          metricId: 'valid',
          timestamp: DateTime(2026, 8, 13),
          weightKg: 80,
          bodyFatPercent: 15,
          waistCm: 82,
        ),
      ),
      returnsNormally,
    );
    expect(
      () => validateAgentBodyMetric(
        BodyMetric(
          metricId: 'invalid-weight',
          timestamp: DateTime(2026, 8, 13),
          weightKg: 501,
        ),
      ),
      throwsStateError,
    );
    expect(
      () => validateAgentBodyMetric(
        BodyMetric(metricId: 'empty', timestamp: DateTime(2026, 8, 13)),
      ),
      throwsStateError,
    );
  });

  test('workout log validation rejects unsafe values', () {
    expect(
      () => AgentToolRegistry.validateWorkoutLogForTesting(_validLog()),
      returnsNormally,
    );
    expect(
      () => AgentToolRegistry.validateWorkoutLogForTesting(
        _validLog(
          set: const SetLog(
            role: 'working',
            targetReps: 5,
            completedReps: -1,
            targetWeight: 100,
            weight: 100,
          ),
        ),
      ),
      throwsStateError,
    );
    expect(
      () => AgentToolRegistry.validateWorkoutLogForTesting(
        _validLog(
          set: const SetLog(
            role: 'working',
            targetReps: 5,
            completedReps: 5,
            targetWeight: 100,
            weight: double.infinity,
          ),
        ),
      ),
      throwsStateError,
    );
  });

  test('body metric reads use bounded opaque cursor pagination', () async {
    final progress = InMemoryProgressRepository();
    for (var index = 0; index < 4; index += 1) {
      await progress.saveBodyMetric(
        BodyMetric(
          metricId: 'metric-$index',
          timestamp: DateTime.now().subtract(Duration(days: index)),
          weightKg: 80 + index.toDouble(),
        ),
      );
    }
    final container = ProviderContainer(
      overrides: [
        progressRepositoryProvider.overrideWithValue(progress),
        appLocaleProvider.overrideWith(
          (ref) => AppLocaleNotifier(ref, initialLocale: AppLocale.zh),
        ),
      ],
    );
    addTearDown(container.dispose);
    final tools = container.read(agentToolRegistryProvider);

    final first = await tools.execute('get_body_metrics', {
      'limit': 2,
      'days': 30,
    });
    expect(first.payload['metrics'], hasLength(2));
    expect(first.payload['truncated'], isTrue);
    final cursor = first.payload['nextCursor'];
    expect(cursor, isA<String>());
    expect(cursor, isNot(contains('offset')));

    final second = await tools.execute('get_body_metrics', {
      'limit': 2,
      'days': 30,
      'cursor': cursor,
    });
    expect(second.payload['metrics'], hasLength(2));
    expect(second.payload['truncated'], isFalse);
    expect(second.payload.containsKey('nextCursor'), isFalse);

    final invalid = await tools.execute('get_body_metrics', {
      'cursor': 'not-a-valid-cursor',
    });
    expect(invalid.isError, isTrue);
  });

  test('mutation previews follow the selected Chinese locale', () async {
    final container = ProviderContainer(
      overrides: [
        appLocaleProvider.overrideWith(
          (ref) => AppLocaleNotifier(ref, initialLocale: AppLocale.zh),
        ),
      ],
    );
    addTearDown(container.dispose);

    final result = await container.read(agentToolRegistryProvider).execute(
      'propose_create_body_metric',
      {'timestamp': '2026-08-13T08:00:00.000Z', 'weightKg': 80},
    );

    expect(result.proposal?.title, '添加身体测量');
    expect(result.proposal?.summary, contains('身体指标记录'));
    expect(
      result.proposal!.changes.map((change) => change.path),
      contains('体重（kg）'),
    );
    expect(
      result.proposal!.changes
          .firstWhere((change) => change.path == '体重（kg）')
          .before,
      '未设置',
    );
  });
}

WorkoutLog _validLog({SetLog? set}) => WorkoutLog(
  logId: 'log-1',
  instanceId: 'instance-1',
  workoutId: 'day-1',
  workoutName: 'Day 1',
  dayLabel: 'Day 1',
  completedAt: DateTime(2026, 8, 13),
  exercises: [
    ExerciseLog(
      exerciseId: 'squat-slot',
      exerciseName: 'Squat',
      stageId: 'stage-1',
      sets: [
        set ??
            const SetLog(
              role: 'working',
              targetReps: 5,
              completedReps: 5,
              targetWeight: 100,
              weight: 100,
              completedRpe: 8,
              isCompleted: true,
            ),
      ],
    ),
  ],
);
