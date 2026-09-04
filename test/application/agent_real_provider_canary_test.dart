// Opt-in only. Keys come from the process environment, never dart-define,
// fixtures, logs, files or application cloud data. All fitness data is synthetic.
import 'dart:convert';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fittin_v2/src/application/active_session_provider.dart';
import 'package:fittin_v2/src/application/agent_harness_controller.dart';
import 'package:fittin_v2/src/application/agent_provider_settings_provider.dart';
import 'package:fittin_v2/src/data/agent_local_repository.dart';
import 'package:fittin_v2/src/data/progress_repository.dart';
import 'package:fittin_v2/src/data/remote/agent_model_transport.dart';
import 'package:fittin_v2/src/domain/models/agent_models.dart';
import 'package:fittin_v2/src/domain/models/body_metric.dart';
import 'package:fittin_v2/src/domain/models/workout_log.dart';
import 'package:fittin_v2/src/domain/models/training_plan.dart';
import '../support/in_memory_database_repository.dart';
import '../support/fake_today_workout_gateway.dart';

void main() {
  _RealProviderTestBinding();
  final fixtures =
      (jsonDecode(
                File(
                  'test/fixtures/agent_fitness_tasks.json',
                ).readAsStringSync(),
              )
              as List)
          .cast<Map<String, dynamic>>();
  test(
    'fitness evaluation matrix has at least 30 distinct tasks and all required categories',
    () {
      expect(fixtures.length, greaterThanOrEqualTo(30));
      expect(fixtures.map((t) => t['id']).toSet().length, fixtures.length);
      expect(
        fixtures.map((t) => t['kind']).toSet(),
        containsAll([
          'plan_create',
          'plan_rest',
          'metric_update',
          'log_weight',
          'analysis',
          'conflict',
          'undo',
          'multi',
        ]),
      );
    },
  );
  final key = Platform.environment['FITTIN_AGENT_CANARY_KEY'];
  AgentProviderCapabilityProfile? capabilities;
  if (key != null && key.isNotEmpty) {
    setUpAll(() async {
      final transport = NativeAgentModelTransport();
      try {
        final result = await AgentConnectionTester(
          transport,
        ).test(config: _CanarySettings(key).config, apiKey: key);
        expect(result.chatCapable, true, reason: result.errorMessage);
        expect(
          result.toolCallingSupported,
          true,
          reason: 'Real connection test must complete a valid ping tool call.',
        );
        capabilities = result.capabilities;
      } finally {
        transport.dispose();
      }
    });
  }
  for (final fixture in fixtures) {
    test(
      'real provider fitness task ${fixture['id']}',
      () async {
        final database = InMemoryDatabaseRepository();
        await database.saveTemplate(fakePlanTemplate, isBuiltIn: true);
        final instance = await database.activateTemplate(fakePlanTemplate.id);
        final progress = InMemoryProgressRepository();
        final metric = BodyMetric(
          metricId: 'metric-seed',
          timestamp: DateTime.now().subtract(const Duration(days: 1)),
          weightKg: 70,
          bodyFatPercent: 20,
          waistCm: 80,
          note: 'fixture',
        );
        await progress.saveBodyMetric(metric);
        final exercise = fakePlanTemplate.workouts.first.exercises.first;
        await database.logWorkout(
          WorkoutLog(
            logId: 'log-seed',
            instanceId: instance.instanceId,
            workoutId: fakePlanTemplate.workouts.first.id,
            workoutName: 'Synthetic workout',
            dayLabel: 'Day 1',
            completedAt: DateTime.now().subtract(const Duration(days: 1)),
            exercises: [
              ExerciseLog(
                exerciseId: exercise.id,
                exerciseName: exercise.name,
                stageId: exercise.stages.first.id,
                sets: const [
                  SetLog(
                    role: 'working',
                    targetReps: 5,
                    completedReps: 5,
                    targetWeight: 50,
                    weight: 50,
                    isCompleted: true,
                  ),
                ],
              ),
            ],
          ),
        );
        final actions = InMemoryAgentLocalRepository();
        final transport = NativeAgentModelTransport();
        final store = _CanarySettings(key!, capabilities: capabilities);
        final c = ProviderContainer(
          overrides: [
            databaseRepositoryProvider.overrideWithValue(database),
            progressRepositoryProvider.overrideWithValue(progress),
            agentLocalRepositoryProvider.overrideWithValue(actions),
            agentProviderSettingsStoreProvider.overrideWithValue(store),
            agentModelTransportProvider.overrideWithValue(transport),
          ],
        );
        addTearDown(c.dispose);
        addTearDown(transport.dispose);
        final runner = c.read(agentHarnessControllerProvider.notifier);
        await runner.submit(fixture['prompt'] as String);
        expect(
          await actions.fetchActions(),
          isEmpty,
          reason: 'No write may occur before explicit approval',
        );
        final kind = fixture['kind'] as String;
        var approvals = 0;
        while (true) {
          final proposal = c
              .read(agentHarnessControllerProvider)
              .runState
              .pendingProposal;
          if (proposal == null) break;
          expect(++approvals, lessThanOrEqualTo(3));
          if (kind == 'reject' || (kind == 'conflict' && approvals > 1)) {
            await runner.rejectProposal(proposal.operationId);
          } else {
            if (kind == 'conflict') {
              await progress.saveBodyMetric(metric.copyWith(weightKg: 79));
            }
            await runner.confirmProposal(proposal.operationId);
          }
          expect(
            c.read(agentHarnessControllerProvider).runState.errorMessage,
            isNull,
            reason: 'Approval must complete locally without an error.',
          );
        }
        final run = c.read(agentHarnessControllerProvider).runState;
        expect(
          run.phase,
          AgentRunPhase.completed,
          reason: [
            run.errorMessage,
            _sanitizedTrace(run.conversation),
          ].whereType<String>().where((value) => value.isNotEmpty).join('\n'),
        );
        final calls = run.conversation!.messages
            .expand((m) => m.toolCalls)
            .map((call) => call.name)
            .toSet();
        if (fixture['expectedTool'] != null) {
          expect(
            calls,
            contains(fixture['expectedTool']),
            reason: run.conversation!.messages
                .where((m) => m.role == AgentMessageRole.assistant)
                .map((m) => redactAgentSecrets(m.content, secrets: [key]))
                .join('\n'),
          );
        }
        expect(
          calls.every(
            (name) => !RegExp('photo|auth|shell|file|http').hasMatch(name),
          ),
          true,
        );
        final committed = await actions.fetchActions();
        if ([
          'read',
          'analysis',
          'forbidden',
          'reject',
          'conflict',
        ].contains(kind)) {
          expect(committed, isEmpty);
        }
        if (fixture['expectedMetric'] case final Map expected) {
          final metrics = await progress.fetchBodyMetrics();
          final actual = kind == 'metric_create'
              ? metrics.firstWhere((m) => m.metricId != 'metric-seed')
              : metrics.firstWhere((m) => m.metricId == 'metric-seed');
          for (final field in expected.entries) {
            expect(actual.toJson()[field.key], field.value);
          }
        }
        if (kind == 'metric_delete') {
          expect(await progress.fetchBodyMetrics(), isEmpty);
        }
        if (kind == 'log_delete') {
          expect(await database.fetchWorkoutLogById('log-seed'), isNull);
        }
        if (kind == 'log_weight' || kind == 'log_reps') {
          final set = (await database.fetchWorkoutLogById(
            'log-seed',
          ))!.exercises.first.sets.first;
          expect(
            kind == 'log_weight' ? set.weight : set.completedReps,
            kind == 'log_weight' ? 55 : 8,
          );
          expect(
            (await database.fetchActiveInstance())!.currentWorkoutIndex,
            instance.currentWorkoutIndex,
          );
        }
        if (kind == 'plan_rest' || kind == 'plan_reps') {
          final current = (await database.fetchActiveInstance())!;
          final plan = (await database.fetchTemplate(current.templateId))!;
          expect(current.templateId, isNot(fakePlanTemplate.id));
          expect(
            kind == 'plan_rest'
                ? plan.workouts.first.exercises.first.restSeconds
                : plan
                      .workouts
                      .first
                      .exercises
                      .first
                      .stages
                      .first
                      .sets
                      .first
                      .targetReps,
            kind == 'plan_rest' ? 90 : 10,
          );
        }
        if (kind == 'plan_create') {
          expect(
            (await database.fetchTemplates()).any(
              (t) =>
                  t.template.name == '居家三天' && t.template.workouts.length == 3,
            ),
            true,
          );
        }
        if (kind == 'undo') {
          expect(committed, hasLength(1));
          await runner.undoAction(committed.single.id);
          expect(
            (await progress.fetchBodyMetrics()).single.toJson(),
            metric.toJson(),
          );
        }
        if (kind == 'multi') expect(calls, contains('analyze_training'));
      },
      skip: key == null || key.isEmpty
          ? 'Real provider key not supplied; this is a release gate, not a pass.'
          : false,
      timeout: const Timeout(Duration(minutes: 15)),
    );
  }
}

String _sanitizedTrace(AgentConversation? conversation) {
  if (conversation == null) return 'No conversation was retained.';
  final rows = <String>[];
  for (final message in conversation.messages) {
    for (final call in message.toolCalls) {
      var detail = '';
      if (call.name == 'list_exercises') {
        try {
          final input = jsonDecode(call.argumentsJson);
          if (input is Map) {
            detail =
                ':${jsonEncode({
                  for (final key in ['query', 'movement', 'equipment', 'primaryMuscle', 'tags', 'source', 'limit', 'cursor'])
                    if (input[key] != null) key: input[key],
                })}';
          }
        } catch (_) {}
      }
      rows.add('call:${call.name}$detail');
    }
    if (message.role != AgentMessageRole.tool) continue;
    try {
      final decoded = jsonDecode(message.content);
      if (decoded is Map) {
        final error = decoded['error'];
        if (error is Map) {
          rows.add(
            'result:error:${error['code'] ?? 'unknown'}:${error['message'] ?? ''}',
          );
        } else {
          rows.add('result:${decoded['status'] ?? 'completed'}');
        }
      }
    } catch (_) {
      rows.add('result:unparseable');
    }
  }
  return rows.join(' -> ');
}

class _RealProviderTestBinding extends AutomatedTestWidgetsFlutterBinding {
  @override
  bool get overrideHttpClient => false;
}

class _CanarySettings implements AgentProviderSettingsStore {
  _CanarySettings(this.key, {this.capabilities});
  final String key;
  final AgentProviderCapabilityProfile? capabilities;
  AgentProviderConfig get config => AgentProviderConfig(
    baseUrl:
        Platform.environment['FITTIN_AGENT_CANARY_BASE_URL'] ??
        'https://api.deepseek.com/v1',
    model: Platform.environment['FITTIN_AGENT_CANARY_MODEL'] ?? 'deepseek-chat',
    hasApiKey: true,
    toolCallingVerified: true,
    capabilities: capabilities,
  );
  @override
  Future<AgentProviderConfig> load() async => config;
  @override
  Future<String?> loadApiKey() async => key;
  @override
  Future<void> clear() async {}
  @override
  Future<AgentProviderConfig> save({
    required String baseUrl,
    required String model,
    String? apiKey,
    bool toolCallingVerified = false,
    int contextWindowTokens = 32768,
    AgentProviderCapabilityProfile? capabilities,
  }) async => config;
}
