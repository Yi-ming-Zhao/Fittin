import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/active_session_provider.dart';
import '../../application/app_locale_provider.dart';
import '../../application/auth_provider.dart';
import '../../application/cardio_recording_provider.dart';
import '../../application/user_content_provider.dart';
import '../../domain/models/cardio.dart';
import '../../domain/models/cardio_recording.dart';
import '../../domain/models/user_content.dart';
import '../localization/app_strings.dart';
import '../widgets/dashboard_primitives.dart';
import '../widgets/cardio_route_preview.dart';
import '../widgets/cardio_split_list.dart';
import 'cardio_screen.dart';

CardioSport cardioSportFor(String id) => switch (id) {
  'cardio:running' || 'cardio:trail-running' => CardioSport.running,
  'cardio:outdoor-walking' => CardioSport.walking,
  'cardio:cycling' => CardioSport.cycling,
  'cardio:hiking' => CardioSport.hiking,
  _ => CardioSport.indoor,
};

class CardioRecordingScreen extends ConsumerStatefulWidget {
  const CardioRecordingScreen({
    super.key,
    required this.activity,
    this.restoreId,
  });
  final CardioActivityDefinition activity;
  final String? restoreId;
  @override
  ConsumerState<CardioRecordingScreen> createState() =>
      _CardioRecordingScreenState();
}

class _CardioRecordingScreenState extends ConsumerState<CardioRecordingScreen> {
  bool _locked = false, _saving = false;
  CardioRecordingController? _controller;
  @override
  void dispose() {
    final controller = _controller;
    // Avoid notifying provider listeners during the widget unmount phase.
    Future.microtask(() => controller?.cancelPreparation());
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    if (widget.restoreId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ref
              .read(cardioRecordingProvider.notifier)
              .restore(
                widget.restoreId!,
                chinese: ref.read(appLocaleProvider).code.startsWith('zh'),
              );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final zh = AppStrings.of(context, ref).isChinese;
    final view = ref.watch(cardioRecordingProvider);
    final controller = ref.read(cardioRecordingProvider.notifier);
    _controller = controller;
    final session = view.session;
    final finished = session?.phase == CardioRecordingPhase.finished;
    final recording = session?.phase == CardioRecordingPhase.recording;
    final ready = session == null;
    final unfinished = ref
        .watch(localCardioSessionsProvider)
        .valueOrNull
        ?.where((entry) => entry.session.phase != CardioRecordingPhase.finished)
        .firstOrNull;
    final indoor =
        (session?.sport ?? cardioSportFor(widget.activity.id)) ==
        CardioSport.indoor;
    final locale = ref.watch(appLocaleProvider);
    final colors = Theme.of(context).colorScheme;
    return PopScope(
      canPop: !_locked,
      child: DashboardPageScaffold(
        layout: DashboardPageLayout.detail,
        bottomNavigationBar: ready ? null : _controls(view, controller, zh),
        children: [
          DashboardScreenHeader(
            title:
                session?.activityName ??
                widget.activity.displayName(locale.code),
            showBackButton: !_locked,
            trailing: session == null || finished
                ? null
                : IconButton(
                    key: const ValueKey('cardio-screen-lock'),
                    tooltip: zh ? '锁定操作' : 'Lock controls',
                    onPressed: () => setState(() => _locked = true),
                    icon: const Icon(Icons.lock_outline_rounded),
                  ),
          ),
          SizedBox(
            height: ready
                ? 24 +
                      ((MediaQuery.sizeOf(context).height - 568).clamp(0, 300) /
                          3)
                : 24,
          ),
          if (ready) ...[
            Icon(
              indoor ? Icons.timer_outlined : Icons.my_location_rounded,
              size: 48,
              color: colors.primary,
            ),
            const SizedBox(height: 20),
            Text(
              indoor
                  ? (zh ? '准备开始计时' : 'Ready to start the timer')
                  : view.locationReady
                  ? (zh ? '定位已就绪' : 'Location ready')
                  : view.preparingLocation
                  ? (zh ? '正在获取位置…' : 'Acquiring location…')
                  : (zh ? '准备记录本次运动' : 'Ready to record your activity'),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            Text(
              indoor
                  ? (zh
                        ? '不使用定位。结束后可补充器械显示的真实数据。'
                        : 'No location tracking. Add measured equipment data when you finish.')
                  : (zh
                        ? '先检查定位，再开始计时。运动期间使用精确定位记录距离和路线，结束后停止。轨迹默认仅存本机。'
                        : 'Check location before starting the timer. Precise location measures distance and route during this activity. Routes stay on this device by default.'),
              textAlign: TextAlign.center,
            ),
            if (kIsWeb && !indoor) ...[
              const SizedBox(height: 12),
              Text(
                zh
                    ? '网页仅支持前台记录，切换应用或锁屏会中断。'
                    : 'Web records in the foreground only. Switching apps or locking the screen interrupts recording.',
                textAlign: TextAlign.center,
                style: TextStyle(color: colors.error),
              ),
            ],
            const SizedBox(height: 32),
            if (unfinished != null) ...[
              OutlinedButton.icon(
                key: const ValueKey('cardio-restore-unfinished'),
                onPressed: view.busy
                    ? null
                    : () => controller.restore(
                        unfinished.session.id,
                        chinese: zh,
                      ),
                icon: const Icon(Icons.restore_rounded),
                label: Text(zh ? '查看未完成运动' : 'Review unfinished activity'),
              ),
              const SizedBox(height: 12),
            ],
            FilledButton.icon(
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
              ),
              key: const ValueKey('cardio-start'),
              onPressed: view.busy || unfinished != null
                  ? null
                  : !indoor && !view.locationReady
                  ? () => controller.prepare(chinese: zh)
                  : () => controller.start(
                      sport: cardioSportFor(widget.activity.id),
                      activityTypeId: widget.activity.id,
                      activityName: widget.activity.displayName(locale.code),
                      chinese: zh,
                    ),
              icon: Icon(
                !indoor && !view.locationReady
                    ? Icons.my_location_rounded
                    : Icons.play_arrow_rounded,
              ),
              label: Text(
                view.busy
                    ? (zh ? '正在准备…' : 'Preparing…')
                    : !indoor && !view.locationReady
                    ? (zh ? '检查定位' : 'Check location')
                    : (zh ? '开始运动' : 'Start activity'),
              ),
            ),
            if (view.preparingLocation)
              TextButton(
                key: const ValueKey('cardio-cancel-preparation'),
                onPressed: controller.cancelPreparation,
                child: Text(zh ? '取消定位' : 'Cancel location check'),
              ),
            TextButton(
              onPressed: view.busy
                  ? null
                  : () {
                      controller.cancelPreparation();
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => CardioRecordEditorScreen(
                            activity: widget.activity,
                          ),
                        ),
                      );
                    },
              child: Text(zh ? '手动补记' : 'Log manually'),
            ),
          ] else ...[
            Text(
              finished
                  ? (zh ? '运动回顾' : 'Activity review')
                  : recording && !session.autoPaused
                  ? (zh ? '正在记录' : 'Recording')
                  : session.phase == CardioRecordingPhase.interrupted
                  ? (zh ? '记录已中断 · 可继续' : 'Interrupted · resume when ready')
                  : (zh ? '已暂停' : 'Paused'),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                _duration(session.activeMilliseconds),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  fontSize: 54,
                  fontWeight: FontWeight.w600,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ),
            Text(zh ? '运动时长' : 'Moving time', textAlign: TextAlign.center),
            const SizedBox(height: 24),
            if (!indoor)
              Row(
                children: [
                  Expanded(
                    child: _Metric(
                      label: zh ? '距离 · km' : 'Distance · km',
                      value: session.distanceMeters > 0
                          ? (session.distanceMeters / 1000).toStringAsFixed(2)
                          : '—',
                    ),
                  ),
                  Expanded(
                    child: _Metric(
                      label: session.sport == CardioSport.cycling
                          ? (zh ? '平均速度 · km/h' : 'Average · km/h')
                          : (zh ? '平均配速 · /km' : 'Average pace · /km'),
                      value: session.sport == CardioSport.cycling
                          ? (session.averageSpeedMps == null
                                ? '—'
                                : (session.averageSpeedMps! * 3.6)
                                      .toStringAsFixed(1))
                          : (session.paceSecondsPerKm == null
                                ? '—'
                                : _duration(
                                    (session.paceSecondsPerKm! * 1000).round(),
                                  )),
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 20),
            if (!indoor && !finished) ...[
              _Metric(
                label: session.sport == CardioSport.cycling
                    ? (zh ? '当前速度 · km/h' : 'Current speed · km/h')
                    : (zh ? '当前配速 · /km' : 'Current pace · /km'),
                value:
                    view.currentSpeedMps == null || view.currentSpeedMps! <= 0
                    ? '—'
                    : session.sport == CardioSport.cycling
                    ? (view.currentSpeedMps! * 3.6).toStringAsFixed(1)
                    : _duration((1000000 / view.currentSpeedMps!).round()),
              ),
              const SizedBox(height: 20),
            ],
            if (!indoor && !finished)
              Text(
                !recording
                    ? (zh ? '定位已暂停' : 'Location paused')
                    : view.locationStale
                    ? (zh
                          ? '定位信号中断 · 等待新的位置'
                          : 'Location signal lost · waiting for a new fix')
                    : view.accuracyMeters == null
                    ? (zh ? '正在等待定位…' : 'Waiting for location…')
                    : view.accuracyMeters! > 50
                    ? (zh
                          ? '定位较弱 · 不累计不可靠的距离'
                          : 'Weak location · unreliable distance excluded')
                    : '${zh ? '定位精度' : 'Location accuracy'} ±${view.accuracyMeters!.round()} m',
                textAlign: TextAlign.center,
              ),
            const SizedBox(height: 20),
            if (!_locked && !finished && !indoor)
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                title: Text(zh ? '自动暂停' : 'Auto-pause'),
                value: session.autoPauseEnabled,
                onChanged: view.busy ? null : controller.setAutoPause,
              ),
            const SizedBox(height: 20),
            ExpansionTile(
              tilePadding: EdgeInsets.zero,
              title: Text(zh ? '时间与分段' : 'Time and splits'),
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    zh ? '总时长（含暂停）' : 'Elapsed time (including pauses)',
                  ),
                  trailing: Text(_duration(session.elapsedMilliseconds)),
                ),
                CardioSplitList(
                  laps: session.laps,
                  chinese: zh,
                  cycling: session.sport == CardioSport.cycling,
                ),
              ],
            ),
            if (!indoor) ...[
              const SizedBox(height: 16),
              CardioRoutePreview(
                key: ValueKey(session.id),
                session: session,
                chinese: zh,
              ),
            ],
          ],
          if (view.errorCode != null)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Text(
                _errorText(view.errorCode!, zh),
                style: TextStyle(color: colors.error),
              ),
            ),
        ],
      ),
    );
  }

  Widget _controls(
    CardioRecordingView view,
    CardioRecordingController controller,
    bool zh,
  ) {
    final finished = view.session!.phase == CardioRecordingPhase.finished;
    final recording = view.session!.phase == CardioRecordingPhase.recording;
    final colors = Theme.of(context).colorScheme;
    return ColoredBox(
      color: colors.surface,
      child: SafeArea(
        top: false,
        child: Center(
          heightFactor: 1,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 430),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
              child: _locked
                  ? Semantics(
                      button: true,
                      onLongPress: () => setState(() => _locked = false),
                      child: GestureDetector(
                        onLongPress: () => setState(() => _locked = false),
                        child: Container(
                          key: const ValueKey('cardio-unlock'),
                          padding: const EdgeInsets.all(20),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: colors.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(zh ? '长按解锁' : 'Hold to unlock'),
                        ),
                      ),
                    )
                  : finished
                  ? FilledButton(
                      key: const ValueKey('cardio-save'),
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(52),
                      ),
                      onPressed: _saving || view.busy ? null : () => _save(zh),
                      child: Text(zh ? '保存运动' : 'Save activity'),
                    )
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  minimumSize: const Size.fromHeight(48),
                                ),
                                onPressed: view.busy || !recording
                                    ? null
                                    : controller.lap,
                                child: Text(zh ? '计圈' : 'Lap'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: FilledButton.icon(
                                key: const ValueKey('cardio-pause-resume'),
                                style: FilledButton.styleFrom(
                                  minimumSize: const Size.fromHeight(48),
                                ),
                                onPressed: view.busy
                                    ? null
                                    : recording
                                    ? controller.pause
                                    : controller.resume,
                                icon: Icon(
                                  recording
                                      ? Icons.pause_rounded
                                      : Icons.play_arrow_rounded,
                                ),
                                label: Text(
                                  recording
                                      ? (zh ? '暂停' : 'Pause')
                                      : (zh ? '继续' : 'Resume'),
                                ),
                              ),
                            ),
                          ],
                        ),
                        TextButton(
                          onPressed: view.busy ? null : () => _finish(zh),
                          child: Text(zh ? '结束运动' : 'Finish activity'),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _finish(bool zh) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(zh ? '结束本次运动？' : 'Finish this activity?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(zh ? '继续运动' : 'Keep going'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(zh ? '结束并回顾' : 'Finish & review'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await ref.read(cardioRecordingProvider.notifier).finish();
    }
  }

  Future<void> _save(bool zh) async {
    setState(() => _saving = true);
    try {
      final controller = ref.read(cardioRecordingProvider.notifier);
      if (!await controller.flush() || !mounted) return;
      final session = ref.read(cardioRecordingProvider).session!;
      if (session.ownerUserId != ref.read(currentUserIdProvider)) return;
      final activity = (await ref.read(
        cardioActivityLibraryProvider.future,
      )).firstWhere((item) => item.id == session.activityTypeId);
      if (!mounted || session.ownerUserId != ref.read(currentUserIdProvider)) {
        return;
      }
      final record = CardioRecord(
        id: session.id,
        activityTypeId: session.activityTypeId,
        activityName: session.activityName,
        startedAt: session.startedAt,
        elapsedSeconds: session.elapsedMilliseconds / 1000,
        source: session.sport == CardioSport.indoor ? 'timer' : 'device',
        metrics: {
          CardioMetricKey.durationSeconds: session.activeMilliseconds / 1000,
          if (session.distanceMeters > 0)
            CardioMetricKey.distanceMeters: session.distanceMeters,
        },
      );
      final db = ref.read(databaseRepositoryProvider);
      final existing = await db.fetchUserContentOfKind(
        session.id,
        kind: UserContentKind.cardioRecord,
        ownerUserId: session.ownerUserId,
        includeDeleted: true,
      );
      if (!mounted || session.ownerUserId != ref.read(currentUserIdProvider)) {
        return;
      }
      if (existing?.deletedAt != null) {
        controller.releaseFinished();
        if (mounted) Navigator.pop(context);
        return;
      }
      if (existing == null) {
        final missing = activity.requiredMetrics.where(
          (key) => !record.metrics.containsKey(key),
        );
        if (missing.isNotEmpty) {
          await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => CardioRecordEditorScreen(
                activity: activity,
                existing: record,
                expectedVersion: 0,
              ),
            ),
          );
          if (!mounted ||
              session.ownerUserId != ref.read(currentUserIdProvider)) {
            return;
          }
          if (await db.fetchUserContentOfKind(
                session.id,
                kind: UserContentKind.cardioRecord,
                ownerUserId: session.ownerUserId,
              ) ==
              null) {
            return;
          }
        } else {
          record.validate(activity);
          await db.saveUserContent(
            UserContentDocument(
              id: record.id,
              kind: UserContentKind.cardioRecord,
              payload: record.toJson(),
              ownerUserId: session.ownerUserId,
            ),
            expectedVersion: 0,
          );
        }
      }
      if (!mounted) return;
      ref.invalidate(cardioRecordDocumentsProvider);
      ref.invalidate(cardioRecordsProvider);
      controller.releaseFinished();
      Navigator.pop(context);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              zh
                  ? '保存未完成，运动仍保存在本机，请重试。'
                  : 'Save did not finish. The local activity is retained; please retry.',
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value});
  final String label, value;
  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text(value, style: Theme.of(context).textTheme.headlineMedium),
      const SizedBox(height: 6),
      Text(label, textAlign: TextAlign.center),
    ],
  );
}

String _duration(int milliseconds) {
  final seconds = milliseconds ~/ 1000;
  final minutes = seconds ~/ 60;
  return '${minutes >= 60 ? '${minutes ~/ 60}:' : ''}${(minutes % 60).toString().padLeft(2, '0')}:${(seconds % 60).toString().padLeft(2, '0')}';
}

String _errorText(String code, bool zh) => switch (code) {
  'permission_denied' =>
    zh
        ? '定位权限未开启，请在系统设置中允许后重试。'
        : 'Allow location access in system settings and try again.',
  'location_disabled' => zh ? '请开启系统定位服务。' : 'Turn on location services.',
  'location_prepare_required' =>
    zh ? '请重新检查定位，再开始运动。' : 'Check location again before starting.',
  'location_fix_timeout' =>
    zh
        ? '暂时无法获得可靠位置，请到开阔处重试；尚未开始计时。'
        : 'No reliable fix yet. Try again in an open area; the timer has not started.',
  'location_unavailable' =>
    zh
        ? '无法获取位置，请检查定位权限和信号后重试。'
        : 'Location is unavailable. Check permissions and signal, then retry.',
  'unfinished_recording' =>
    zh
        ? '请先恢复或结束已有的本机运动。'
        : 'Resume or finish your existing local activity first.',
  'recording_conflict' =>
    zh
        ? '另一页面已更新这次运动，请关闭此页后重新打开。'
        : 'Another page updated this activity. Close and reopen it.',
  'storage_unavailable' =>
    zh
        ? '本机保存失败，已暂停记录。请检查存储空间后重试。'
        : 'Local saving failed. Recording is paused. Check device storage and retry.',
  _ =>
    zh
        ? '定位已中断，已保存部分仍保留；请检查定位权限后继续。'
        : 'Location was interrupted. Saved activity is retained; check permission and resume.',
};
