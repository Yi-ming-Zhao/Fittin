import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:fittin_v2/src/application/active_session_provider.dart';
import 'package:fittin_v2/src/application/auth_provider.dart';
import 'package:fittin_v2/src/application/advanced_analytics_provider.dart';
import 'package:fittin_v2/src/application/progress_analytics_provider.dart';
import 'package:fittin_v2/src/application/user_content_provider.dart';
import 'package:fittin_v2/src/application/fittin_theme_provider.dart';
import 'package:fittin_v2/src/domain/exercise_library.dart';
import 'package:fittin_v2/src/domain/models/custom_exercise.dart';
import 'package:fittin_v2/src/domain/models/training_state.dart';
import 'package:fittin_v2/src/domain/models/workout_log.dart';
import 'package:fittin_v2/src/domain/workout_session_editing.dart';
import 'package:fittin_v2/src/presentation/localization/app_strings.dart';
import 'package:fittin_v2/src/presentation/widgets/dashboard_primitives.dart';
import 'package:fittin_v2/src/presentation/widgets/exercise_catalog_sheet.dart';
import 'active_session_screen.dart';

class FreeTrainingScreen extends ConsumerStatefulWidget {
  const FreeTrainingScreen({super.key});
  @override
  ConsumerState<FreeTrainingScreen> createState() => _FreeTrainingScreenState();
}

class _FreeTrainingScreenState extends ConsumerState<FreeTrainingScreen> {
  final _selected = <ExerciseCatalogItem>[];
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context, ref);
    final theme = ref.watch(resolvedFittinThemeProvider);
    final catalog = ref.watch(exerciseCatalogProvider);
    return DashboardPageScaffold(
      layout: DashboardPageLayout.detail,
      children: [
        DashboardScreenHeader(
          eyebrow: strings.isChinese ? '按自己的节奏' : 'ON YOUR TERMS',
          title: strings.isChinese ? '自由训练' : 'Free training',
          subtitle: strings.isChinese
              ? '自由组合动作，不改变当前计划。未完成的记录会保存在本机。'
              : 'Build your own session without changing your plan. Unfinished records stay on this device.',
          showBackButton: true,
        ),
        const SizedBox(height: 24),
        if (_selected.isEmpty)
          DashboardSurfaceCard(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.fitness_center_rounded,
                  size: 32,
                  color: theme.accent,
                ),
                const SizedBox(height: 18),
                Text(
                  strings.isChinese ? '组装今天的训练' : 'Build today’s session',
                  style: theme.uiStyle(20, theme.fg, FontWeight.w700),
                ),
                const SizedBox(height: 10),
                Text(
                  strings.isChinese
                      ? '从动作库选择动作，再用熟悉的卡片记录每一组。力量数据照常进入历史与趋势。'
                      : 'Choose exercises, then record each set with the familiar cards. Your work still counts toward history and trends.',
                  style: theme.uiStyle(14, theme.fgDim).copyWith(height: 1.6),
                ),
              ],
            ),
          ),
        for (var i = 0; i < _selected.length; i++)
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Text(
              '${i + 1}'.padLeft(2, '0'),
              style: theme.displayStyle(22, theme.fgMuted),
            ),
            title: Text(
              _selected[i].displayName(strings.isChinese ? 'zh' : 'en'),
            ),
            subtitle: Text(
              strings.isChinese
                  ? '3 组 · 12 次 · 可在记录中调整'
                  : '3 sets · 12 reps · adjustable while recording',
            ),
            trailing: IconButton(
              tooltip: strings.delete,
              icon: const Icon(Icons.close),
              onPressed: _busy
                  ? null
                  : () => setState(() => _selected.removeAt(i)),
            ),
          ),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(52),
          ),
          key: const ValueKey('free-training-add-exercise'),
          onPressed: _busy || !catalog.hasValue
              ? null
              : () async {
                  final item = await showModalBottomSheet<ExerciseCatalogItem>(
                    context: context,
                    isScrollControlled: true,
                    useSafeArea: true,
                    builder: (sheetContext) => ExerciseCatalogSheet(
                      theme: theme,
                      strings: strings,
                      localeCode: strings.isChinese ? 'zh' : 'en',
                      items: catalog.value!,
                      onSelected: (item) => Navigator.pop(sheetContext, item),
                    ),
                  );
                  if (item != null && mounted) {
                    setState(() => _selected.add(item));
                  }
                },
          icon: const Icon(Icons.add),
          label: Text(strings.isChinese ? '从动作库添加' : 'Add from library'),
        ),
        const SizedBox(height: 12),
        FilledButton.icon(
          style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
          key: const ValueKey('free-training-start'),
          onPressed: _busy ? null : _start,
          icon: const Icon(Icons.play_arrow_rounded),
          label: Text(
            strings.isChinese ? '开始 / 继续自由训练' : 'Start / resume free training',
          ),
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: _busy ? null : _discard,
          child: Text(
            strings.isChinese
                ? '丢弃未完成的自由训练'
                : 'Discard unfinished free training',
          ),
        ),
        if (catalog.hasError) Text(strings.loadError(catalog.error!)),
      ],
    );
  }

  Future<void> _discard() async {
    final strings = AppStrings.of(context, ref);
    final owner = ref.read(currentUserIdProvider);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          strings.isChinese ? '丢弃自由训练草稿？' : 'Discard free training draft?',
        ),
        content: Text(
          strings.isChinese
              ? '仅移除未完成的自由训练，不影响历史记录和训练计划。'
              : 'Only the unfinished free session is removed. History and your plan stay unchanged.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(strings.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(strings.delete),
          ),
        ],
      ),
    );
    if (!mounted ||
        confirmed != true ||
        ref.read(currentUserIdProvider) != owner) {
      return;
    }
    setState(() => _busy = true);
    try {
      await ref
          .read(databaseRepositoryProvider)
          .clearActiveSessionDraft(
            'free:${owner ?? 'local'}',
            ownerUserId: owner,
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              strings.isChinese ? '自由训练草稿已清除' : 'Free training draft cleared',
            ),
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.toString())));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _start() async {
    setState(() => _busy = true);
    final strings = AppStrings.of(context, ref);
    final repository = ref.read(databaseRepositoryProvider);
    final owner = ref.read(currentUserIdProvider);
    final scope = 'free:${owner ?? 'local'}';
    try {
      final draft = await repository.fetchActiveSessionDraft(
        scope,
        ownerUserId: owner,
      );
      if (draft == null && _selected.isEmpty) {
        throw StateError(
          strings.isChinese
              ? '请先添加至少一个动作。'
              : 'Add at least one exercise first.',
        );
      }
      final session =
          draft ??
          WorkoutSessionState(
            instanceId: scope,
            templateId: '',
            workoutId: const Uuid().v4(),
            workoutName: strings.isChinese ? '自由训练' : 'Free training',
            dayLabel: '',
            estimatedDurationMinutes: _selected.length * 8,
            exercises: [
              for (final item in _selected)
                ExerciseSessionState(
                  id: const Uuid().v4(),
                  exerciseId: item.id,
                  exerciseName: item.displayName(
                    strings.isChinese ? 'zh' : 'en',
                  ),
                  tier: 'T3',
                  restSeconds: 90,
                  stageId: 'free',
                  showsPlateBreakdown:
                      item.equipment == ExerciseEquipment.barbell,
                  sets: [
                    for (var i = 0; i < 3; i++)
                      SessionSetState(
                        id: const Uuid().v4(),
                        role: 'working',
                        targetReps: 12,
                        completedReps: 12,
                        targetWeight: 0,
                        weight: 0,
                      ),
                  ],
                ),
            ],
          );
      if (!mounted || ref.read(currentUserIdProvider) != owner) return;
      await repository.saveActiveSessionDraft(session, ownerUserId: owner);
      if (!mounted || ref.read(currentUserIdProvider) != owner) return;
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => ProviderScope(
            overrides: [
              activeSessionProvider.overrideWith(
                (sessionRef) => ActiveSessionNotifier(
                  sessionRef,
                  initialWorkout: session,
                  persistIsolatedDraft: true,
                  onSaveIsolatedSession: (recorded) async {
                    if (ref.read(currentUserIdProvider) != owner) {
                      throw StateError('Account changed.');
                    }
                    final existing = await repository.fetchWorkoutLogById(
                      'free:${session.workoutId}',
                      ownerUserId: owner,
                    );
                    final log = WorkoutLog(
                      logId: 'free:${session.workoutId}',
                      instanceId: scope,
                      workoutId: session.workoutId,
                      workoutName: session.workoutName,
                      dayLabel: '',
                      completedAt: existing?.completedAt ?? DateTime.now(),
                      exercises: const [],
                    );
                    await repository.trainingTransaction(() async {
                      await repository.logWorkout(
                        applySessionToHistory(log, recorded),
                        ownerUserId: owner,
                      );
                      await repository.clearActiveSessionDraft(
                        scope,
                        ownerUserId: owner,
                      );
                    });
                  },
                ),
              ),
            ],
            child: const ActiveSessionScreen(freeTraining: true),
          ),
        ),
      );
      ref.invalidate(advancedAnalyticsDataProvider);
      ref.invalidate(progressAnalyticsOverviewProvider);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.toString())));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }
}
