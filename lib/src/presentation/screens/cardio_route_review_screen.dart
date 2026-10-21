import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/auth_provider.dart';
import '../../application/cardio_recording_provider.dart';
import '../../application/cardio_route_export.dart';
import '../../application/cardio_route_sync.dart';
import '../../application/user_content_provider.dart';
import '../../data/private_file_export.dart';
import '../../domain/models/cardio.dart';
import '../../domain/models/cardio_recording.dart';
import '../localization/app_strings.dart';
import '../widgets/cardio_route_preview.dart';
import '../widgets/cardio_split_list.dart';
import '../widgets/dashboard_primitives.dart';

/// Local routes stay manageable after their synced summary was deleted.
/// Opening this page never recreates or uploads an activity record.
class LocalCardioRoutesScreen extends ConsumerWidget {
  const LocalCardioRoutesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final zh = AppStrings.of(context, ref).isChinese;
    final owner = ref.watch(currentUserIdProvider);
    final sessions = ref.watch(localCardioSessionsProvider);
    return DashboardPageScaffold(
      layout: DashboardPageLayout.detail,
      children: [
        DashboardScreenHeader(
          title: zh ? '本机运动轨迹' : 'Local activity routes',
          showBackButton: true,
        ),
        const SizedBox(height: 20),
        Text(
          zh
              ? '轨迹默认仅保存在本机，只有确认上传后才保存到云端。删除运动汇总不会自动删除路线。'
              : 'Routes stay on this device unless you confirm an upload. Deleting an activity summary does not automatically delete its route.',
        ),
        const SizedBox(height: 20),
        if (owner != null)
          OutlinedButton.icon(
            icon: const Icon(Icons.cloud_outlined),
            label: Text(zh ? '管理私有云端轨迹' : 'Manage private cloud routes'),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const CloudCardioRoutesScreen(),
              ),
            ),
          ),
        ...sessions.when(
          loading: () => [const LinearProgressIndicator()],
          error: (_, _) => [
            OutlinedButton(
              onPressed: () => ref.invalidate(localCardioSessionsProvider),
              child: Text(zh ? '读取失败，重试' : 'Could not load · retry'),
            ),
          ],
          data: (all) {
            final routes = all
                .where(
                  (entry) =>
                      entry.chunkCount > 0 &&
                      entry.session.phase == CardioRecordingPhase.finished,
                )
                .toList();
            if (routes.isEmpty) {
              return [
                Text(
                  zh
                      ? '没有已结束运动的本机轨迹'
                      : 'No local routes from finished activities',
                ),
              ];
            }
            return [
              for (final entry in routes)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.route_outlined),
                  title: Text(entry.session.activityName),
                  subtitle: Text(
                    MaterialLocalizations.of(
                      context,
                    ).formatFullDate(entry.session.startedAt),
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => CardioRouteReviewScreen(
                        ownerUserId: owner,
                        record: CardioRecord(
                          id: entry.session.id,
                          activityTypeId: entry.session.activityTypeId,
                          activityName: entry.session.activityName,
                          startedAt: entry.session.startedAt,
                          source: 'local',
                          elapsedSeconds:
                              entry.session.elapsedMilliseconds / 1000,
                          metrics: {
                            CardioMetricKey.durationSeconds:
                                entry.session.activeMilliseconds / 1000,
                            if (entry.session.distanceMeters > 0)
                              CardioMetricKey.distanceMeters:
                                  entry.session.distanceMeters,
                          },
                        ),
                      ),
                    ),
                  ),
                ),
            ];
          },
        ),
      ],
    );
  }
}

/// Explicitly opened inventory; it never downloads coordinates automatically.
class CloudCardioRoutesScreen extends ConsumerStatefulWidget {
  const CloudCardioRoutesScreen({super.key});
  @override
  ConsumerState<CloudCardioRoutesScreen> createState() => _CloudRoutesState();
}

class _CloudRoutesState extends ConsumerState<CloudCardioRoutesScreen> {
  final _pages = <Map<String, dynamic>>[];
  CardioRouteSync? _service;
  Future<Map<String, dynamic>>? _pending;

  @override
  Widget build(BuildContext context) {
    final zh = AppStrings.of(context, ref).isChinese;
    final service = ref.watch(cardioRouteSyncProvider);
    if (!identical(_service, service)) {
      _service = service;
      _pages.clear();
      _pending = service?.list();
    }
    return DashboardPageScaffold(
      layout: DashboardPageLayout.detail,
      children: [
        DashboardScreenHeader(
          title: zh ? '私有云端轨迹' : 'Private cloud routes',
          showBackButton: true,
        ),
        const SizedBox(height: 20),
        if (service == null)
          Text(zh ? '请先登录' : 'Sign in first')
        else
          FutureBuilder<Map<String, dynamic>>(
            future: _pending,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const LinearProgressIndicator();
              }
              if (snapshot.hasError) {
                return OutlinedButton(
                  onPressed: () => setState(() {
                    _pending = service.list(
                      after: _pages.lastOrNull?['nextCursor'] as String?,
                    );
                  }),
                  child: Text(zh ? '读取失败，重试' : 'Could not load · retry'),
                );
              }
              final page = snapshot.data!;
              final rows = [
                ..._pages,
                page,
              ].expand((p) => (p['items'] as List).cast<Map>()).toList();
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (rows.isEmpty) Text(zh ? '没有上传的轨迹' : 'No uploaded routes'),
                  for (final row in rows)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.route_outlined),
                      title: Text(
                        row['activityName'] as String? ??
                            (zh ? '未完成上传' : 'Incomplete upload'),
                      ),
                      subtitle: row['startedAt'] == null
                          ? null
                          : Text(
                              MaterialLocalizations.of(context).formatFullDate(
                                DateTime.parse(
                                  row['startedAt'] as String,
                                ).toLocal(),
                              ),
                            ),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () async {
                        if (row['incomplete'] == true || row['version'] == 0) {
                          final confirmed = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text(
                                zh ? '删除未完成上传？' : 'Delete incomplete upload?',
                              ),
                              content: Text(
                                zh
                                    ? '仅删除服务器上的未完成路线片段。本机路线和运动汇总保留。'
                                    : 'Remove only incomplete route segments on the server. Local routes and activity summaries remain.',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, false),
                                  child: Text(zh ? '取消' : 'Cancel'),
                                ),
                                FilledButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: Text(zh ? '删除' : 'Delete'),
                                ),
                              ],
                            ),
                          );
                          if (confirmed != true ||
                              !mounted ||
                              !identical(_service, service)) {
                            return;
                          }
                          try {
                            await service.delete(
                              row['id'] as String,
                              expectedCloudVersion: row['version'] as int,
                            );
                          } catch (_) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    zh
                                        ? '删除未完成，请重新读取后重试。'
                                        : 'Not deleted. Reload and retry.',
                                  ),
                                ),
                              );
                            }
                          }
                          if (!mounted || !identical(_service, service)) return;
                          setState(() {
                            _pages.clear();
                            _pending = service.list();
                          });
                          return;
                        }
                        await Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => CardioRouteReviewScreen(
                              ownerUserId: service.owner,
                              record: CardioRecord(
                                id: row['id'] as String,
                                activityTypeId:
                                    row['activityTypeId'] as String? ??
                                    'cardio:running',
                                activityName:
                                    row['activityName'] as String? ??
                                    (zh ? '未完成上传' : 'Incomplete upload'),
                                startedAt:
                                    DateTime.tryParse(
                                      row['startedAt'] as String? ?? '',
                                    ) ??
                                    DateTime.now(),
                                metrics: {
                                  if (row['activeMilliseconds'] is num)
                                    CardioMetricKey.durationSeconds:
                                        (row['activeMilliseconds'] as num)
                                            .toDouble() /
                                        1000,
                                  if (row['distanceMeters'] is num)
                                    CardioMetricKey.distanceMeters:
                                        (row['distanceMeters'] as num)
                                            .toDouble(),
                                },
                              ),
                            ),
                          ),
                        );
                        if (!mounted || !identical(_service, service)) return;
                        setState(() {
                          _pages.clear();
                          _pending = service.list();
                        });
                      },
                    ),
                  if ((page['nextCursor'] as String).isNotEmpty)
                    OutlinedButton(
                      onPressed: () => setState(() {
                        _pages.add(page);
                        _pending = service.list(
                          after: page['nextCursor'] as String,
                        );
                      }),
                      child: Text(zh ? '加载更多' : 'Load more'),
                    ),
                ],
              );
            },
          ),
      ],
    );
  }
}

class CardioRouteReviewScreen extends ConsumerStatefulWidget {
  const CardioRouteReviewScreen({
    super.key,
    required this.record,
    required this.ownerUserId,
    this.onEdit,
  });
  final CardioRecord record;
  final String? ownerUserId;
  final VoidCallback? onEdit;
  @override
  ConsumerState<CardioRouteReviewScreen> createState() =>
      _CardioRouteReviewState();
}

class _CardioRouteReviewState extends ConsumerState<CardioRouteReviewScreen> {
  bool _busy = false;
  @override
  Widget build(BuildContext context) {
    final zh = AppStrings.of(context, ref).isChinese;
    if (ref.watch(currentUserIdProvider) != widget.ownerUserId) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(
          child: Text(
            zh ? '账号已切换，请返回重新打开。' : 'Account changed. Reopen this activity.',
          ),
        ),
      );
    }
    final local = ref.watch(localCardioSessionsProvider);
    final record =
        ref
            .watch(cardioRecordsProvider)
            .valueOrNull
            ?.where((record) => record.id == widget.record.id)
            .firstOrNull ??
        widget.record;
    final saved = local.valueOrNull
        ?.where((entry) => entry.session.id == widget.record.id)
        .firstOrNull;
    final session = saved?.session;
    final duration = record.metric(CardioMetricKey.durationSeconds);
    final distance = record.metric(CardioMetricKey.distanceMeters);
    final cycling =
        session?.sport == CardioSport.cycling ||
        record.activityTypeId == 'cardio:cycling';
    final pace = record.metric(CardioMetricKey.paceSecondsPerKm);
    final speed = record.metric(CardioMetricKey.averageSpeedMps);
    return DashboardPageScaffold(
      layout: DashboardPageLayout.detail,
      children: [
        DashboardScreenHeader(
          title: record.activityName,
          showBackButton: true,
          trailing: widget.onEdit == null
              ? null
              : IconButton(
                  onPressed: _busy ? null : widget.onEdit,
                  tooltip: zh ? '编辑汇总' : 'Edit summary',
                  icon: const Icon(Icons.edit_outlined),
                ),
        ),
        const SizedBox(height: 24),
        Text(
          MaterialLocalizations.of(context).formatFullDate(record.startedAt),
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 20),
        Wrap(
          spacing: 24,
          runSpacing: 16,
          children: [
            if (duration != null)
              _metric(
                context,
                zh ? '运动时长' : 'Timer duration',
                cardioDurationLabel(duration),
              ),
            if (distance != null)
              _metric(
                context,
                zh ? '距离' : 'Distance',
                '${(distance / 1000).toStringAsFixed(2)} km',
              ),
            if (cycling ? speed != null : pace != null)
              _metric(
                context,
                cycling
                    ? (zh ? '平均速度 · km/h' : 'Avg speed · km/h')
                    : (zh ? '平均配速 · /km' : 'Avg pace · /km'),
                cycling
                    ? (speed! * 3.6).toStringAsFixed(1)
                    : cardioDurationLabel(pace!),
              ),
            if (record.elapsedSeconds != null)
              _metric(
                context,
                zh ? '总时长' : 'Elapsed time',
                cardioDurationLabel(record.elapsedSeconds!),
              ),
            for (final field in [
              (
                CardioMetricKey.averageHeartRateBpm,
                zh ? '平均心率 · bpm' : 'Avg HR · bpm',
              ),
              (
                CardioMetricKey.maxHeartRateBpm,
                zh ? '最高心率 · bpm' : 'Max HR · bpm',
              ),
              (
                CardioMetricKey.cadencePerMinute,
                zh ? '步频 / 踏频 · /min' : 'Cadence · /min',
              ),
              (
                CardioMetricKey.elevationGainMeters,
                zh ? '累计爬升 · m' : 'Ascent · m',
              ),
              (
                CardioMetricKey.averagePowerWatts,
                zh ? '平均功率 · W' : 'Avg power · W',
              ),
            ])
              if (record.metric(field.$1) != null &&
                  record.metric(field.$1)! > 0)
                _metric(
                  context,
                  field.$2,
                  record.metric(field.$1)!.toStringAsFixed(0),
                ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          '${zh ? '来源' : 'Source'} · ${switch (record.source) {
            'manual' => zh ? '手动录入' : 'Manual entry',
            'device' => zh ? '本机定位记录' : 'Device GPS recording',
            'timer' => zh ? '本机计时记录' : 'Device timer recording',
            'local' => zh ? '本机轨迹档案' : 'Local route archive',
            'gpx' || 'fit' || 'tcx' || 'csv' => '${record.source.toUpperCase()} ${zh ? '导入' : 'import'}',
            _ => record.source,
          }}',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 24),
        if (local.isLoading) const LinearProgressIndicator(),
        if (local.hasError) Text(zh ? '本机路线暂不可读取' : 'Local route unavailable'),
        if (session != null) ...[
          CardioRoutePreview(
            key: ValueKey(session.id),
            session: session,
            chinese: zh,
          ),
          const SizedBox(height: 16),
          CardioSplitList(laps: session.laps, chinese: zh, cycling: cycling),
          const SizedBox(height: 16),
          if (saved!.chunkCount > 0)
            OutlinedButton.icon(
              key: const ValueKey('cardio-export-route'),
              onPressed: _busy ? null : () => _export(zh),
              icon: const Icon(Icons.ios_share_rounded),
              label: Text(zh ? '导出路线 GPX' : 'Export route GPX'),
            ),
          TextButton(
            onPressed: _busy ? null : () => _deleteRoute(zh),
            child: Text(zh ? '删除本机路线与分段' : 'Delete local route and laps'),
          ),
        ] else if (!local.isLoading && !local.hasError)
          Text(
            zh
                ? '本机没有保存这次运动的路线。'
                : 'No local route is saved for this activity.',
          ),
        if (widget.ownerUserId != null) ...[
          const SizedBox(height: 16),
          OutlinedButton.icon(
            key: const ValueKey('cardio-cloud-route'),
            onPressed: _busy ? null : () => _cloudRoute(zh),
            icon: const Icon(Icons.cloud_outlined),
            label: Text(zh ? '管理私有云端轨迹' : 'Manage private cloud route'),
          ),
        ],
      ],
    );
  }

  Widget _metric(BuildContext context, String label, String value) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(value, style: Theme.of(context).textTheme.headlineMedium),
      const SizedBox(height: 4),
      Text(label),
    ],
  );

  Future<bool> _confirm(
    String title,
    String consequence,
    String action,
  ) async =>
      await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(title),
          content: Text(consequence),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(action),
            ),
          ],
        ),
      ) ==
      true;

  Future<void> _export(bool zh) async {
    if (!await _confirm(
          zh ? '导出精确路线？' : 'Export precise route?',
          zh
              ? '文件包含经过的位置和时间，可能暴露住所和日常路线。请只分享给信任的对象。'
              : 'The file contains precise locations and times and may reveal your home or routine. Share only with people you trust.',
          zh ? '继续导出' : 'Continue',
        ) ||
        !mounted) {
      return;
    }
    await _perform(() async {
      final bytes = await exportCardioRouteGpx(
        ref.read(cardioRecordingStoreProvider),
        widget.record.id,
        ownerUserId: widget.ownerUserId,
      );
      if (!mounted || ref.read(currentUserIdProvider) != widget.ownerUserId) {
        return;
      }
      final box = context.findRenderObject() as RenderBox;
      await exportPrivateGpx(
        bytes,
        'Fittin-${widget.record.startedAt.toIso8601String().substring(0, 10)}.gpx',
        box.localToGlobal(Offset.zero) & box.size,
      );
    }, zh);
  }

  Future<void> _deleteRoute(bool zh) async {
    if (!await _confirm(
          zh ? '删除本机路线？' : 'Delete local route?',
          zh
              ? '路线和分段会从这台设备永久删除，运动汇总仍保留。已导出的文件不会被删除。'
              : 'The route and laps will be permanently removed from this device. The summary and previously exported files remain.',
          zh ? '删除路线' : 'Delete route',
        ) ||
        !mounted) {
      return;
    }
    await _perform(() async {
      final store = ref.read(cardioRecordingStoreProvider);
      final saved = await store.read(
        widget.record.id,
        ownerUserId: widget.ownerUserId,
      );
      if (!mounted ||
          saved == null ||
          ref.read(currentUserIdProvider) != widget.ownerUserId) {
        return;
      }
      await store.delete(
        widget.record.id,
        ownerUserId: widget.ownerUserId,
        expectedRevision: saved.revision,
      );
      if (mounted) ref.invalidate(localCardioSessionsProvider);
    }, zh);
  }

  Future<void> _cloudRoute(bool zh) async {
    await _perform(() async {
      final service = ref.read(cardioRouteSyncProvider);
      if (service == null) return;
      final cloud = await service.remote.manifest(widget.record.id);
      final local = await service.local.read(
        widget.record.id,
        ownerUserId: widget.ownerUserId,
      );
      service.checkOwner();
      if (!mounted) return;
      final action = await showDialog<String>(
        context: context,
        builder: (context) => SimpleDialog(
          title: Text(zh ? '私有云端轨迹' : 'Private cloud route'),
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Text(
                cloud == null || cloud['deleted'] == true
                    ? (zh ? '还没有已提交的云端路线。' : 'No committed cloud route yet.')
                    : (zh
                          ? '云端版本 ${cloud['version']}，仅此账号可访问。'
                          : 'Cloud version ${cloud['version']}, accessible only to this account.'),
              ),
            ),
            if (local != null && local.chunkCount > 0)
              SimpleDialogOption(
                onPressed: () => Navigator.pop(context, 'upload'),
                child: Text(zh ? '上传本机路线' : 'Upload local route'),
              ),
            if (cloud != null && cloud['deleted'] != true && local == null)
              SimpleDialogOption(
                onPressed: () => Navigator.pop(context, 'download'),
                child: Text(zh ? '下载到本机' : 'Download to this device'),
              ),
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, 'delete'),
              child: Text(
                zh
                    ? '删除云端路线及未完成上传'
                    : 'Delete cloud route and incomplete uploads',
              ),
            ),
          ],
        ),
      );
      if (action == null || !mounted) return;
      final confirmed = await _confirm(
        switch (action) {
          'upload' => zh ? '上传精确路线？' : 'Upload precise route?',
          'download' => zh ? '下载精确路线？' : 'Download precise route?',
          _ => zh ? '删除云端路线？' : 'Delete cloud route?',
        },
        switch (action) {
          'upload' =>
            zh
                ? '经过的位置、时间和分段将发送至 Fittin 后端，保存在你的账号下，不公开分享；同 ID 的已有云端路线将被替换。普通同步仍不会自动上传其它路线。'
                : 'Locations, times and laps will be sent to Fittin and stored privately under your account. An existing route with this ID will be replaced. Other routes are not uploaded automatically.',
          'download' =>
            zh
                ? '精确位置将保存在这台设备，其他能使用此账号的人可能查看。不会覆盖已有本机记录。'
                : 'Precise locations will be saved on this device and may be visible to anyone using this account. Existing local records will not be overwritten.',
          _ =>
            zh
                ? '服务器上的精确路线及未完成上传将被永久删除；本机路线、运动汇总和已导出文件保留。'
                : 'The server route and incomplete uploads will be permanently removed. Local routes, summaries and exported files remain.',
        },
        zh ? '确认' : 'Confirm',
      );
      if (!confirmed || !mounted) return;
      service.checkOwner();
      final version = cloud?['version'] as int? ?? 0;
      switch (action) {
        case 'upload':
          await service.upload(
            widget.record.id,
            expectedLocalRevision: local!.revision,
            expectedCloudVersion: version,
          );
        case 'download':
          await service.download(
            widget.record.id,
            expectedCloudVersion: version,
          );
        case 'delete':
          await service.delete(widget.record.id, expectedCloudVersion: version);
      }
      if (!mounted) return;
      ref.invalidate(localCardioSessionsProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(zh ? '轨迹操作完成' : 'Route action completed')),
      );
    }, zh);
  }

  Future<void> _perform(Future<void> Function() action, bool zh) async {
    setState(() => _busy = true);
    try {
      await action();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              zh
                  ? '操作未完成，数据仍保留，请重试。'
                  : 'Could not complete the action. Data is retained; please retry.',
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }
}
