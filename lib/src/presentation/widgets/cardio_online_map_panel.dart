import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/auth_provider.dart';
import '../../application/supabase_bootstrap.dart';
import '../../data/cardio_online_map.dart';
import '../../domain/models/cardio_recording.dart';

final cardioOnlineMapProvider = Provider<CardioOnlineMap>((ref) {
  final auth = ref.watch(authRepositoryProvider);
  return CardioOnlineMap(
    backendBaseUrl: ref.watch(supabaseBootstrapProvider).url,
    accessTokenLoader: auth.currentAccessToken,
    accessTokenRefresher: (token) =>
        auth.refreshAccessToken(failedAccessToken: token),
  );
});

class CardioOnlineMapPanel extends ConsumerStatefulWidget {
  const CardioOnlineMapPanel({
    super.key,
    required this.point,
    required this.chinese,
    required this.ownerUserId,
  });
  final RoutePoint? point;
  final bool chinese;
  final String? ownerUserId;
  @override
  ConsumerState<CardioOnlineMapPanel> createState() =>
      _CardioOnlineMapPanelState();
}

class _CardioOnlineMapPanelState extends ConsumerState<CardioOnlineMapPanel> {
  Uint8List? _image;
  DateTime? _pointTime;
  bool _enabled = false, _busy = false, _failed = false;
  int _epoch = 0, _zoom = 15;

  void _disable() {
    _epoch++;
    setState(() {
      _enabled = false;
      _busy = false;
      _image = null;
      _pointTime = null;
      _failed = false;
    });
  }

  Future<void> _enable() async {
    final zh = widget.chinese;
    final owner = ref.read(currentUserIdProvider);
    if (owner != widget.ownerUserId) return;
    if (owner == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            zh
                ? '请先在“我的”中登录后使用在线地图。离线记录不受影响。'
                : 'Sign in from Me to use online maps. Offline recording is unaffected.',
          ),
        ),
      );
      return;
    }
    final accepted = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(zh ? '启用在线地图' : 'Enable online map'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                zh
                    ? '使用已配置的个人测试地图，无需填写 Key。每次加载会将一个定位点经 Fittin 转发给高德，不发送完整路线。Fittin 不保存该坐标或地图图片，可能消耗高德配额。'
                    : 'Use the configured personal test map without entering a key. Each refresh sends one position through Fittin to AMap, never your full route. Fittin does not store the point or map image. Provider quotas may apply.',
              ),
              const SizedBox(height: 8),
              Text(
                zh
                    ? '周边地图为按需刷新的地图图片，不是实时导航。'
                    : 'A refreshable area map image, not live navigation.',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(zh ? '取消' : 'Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(zh ? '同意并加载' : 'Agree & load'),
          ),
        ],
      ),
    );
    if (!mounted ||
        accepted != true ||
        owner != ref.read(currentUserIdProvider)) {
      return;
    }
    setState(() => _enabled = true);
    await _load();
  }

  Future<void> _load() async {
    final point = widget.point;
    if (!_enabled ||
        _busy ||
        point == null ||
        widget.ownerUserId != ref.read(currentUserIdProvider)) {
      return;
    }
    final epoch = ++_epoch;
    setState(() {
      _busy = true;
      _failed = false;
    });
    try {
      final bytes = await ref
          .read(cardioOnlineMapProvider)
          .load(
            point: point,
            zoom: _zoom,
            isCurrent: () =>
                mounted &&
                epoch == _epoch &&
                widget.ownerUserId == ref.read(currentUserIdProvider),
          );
      if (!mounted || epoch != _epoch) return;
      setState(() {
        _image = bytes;
        _pointTime = point.timestamp;
      });
    } catch (_) {
      if (mounted && epoch == _epoch) setState(() => _failed = true);
    } finally {
      if (mounted && epoch == _epoch) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(currentUserIdProvider, (_, __) => _disable());
    if (widget.ownerUserId != ref.watch(currentUserIdProvider)) {
      return const SizedBox.shrink();
    }
    final zh = widget.chinese;
    if (!_enabled) {
      return TextButton.icon(
        key: const ValueKey('cardio-enable-online-map'),
        onPressed: widget.point == null ? null : _enable,
        icon: const Icon(Icons.map_outlined),
        label: Text(zh ? '在线周边地图' : 'Online area map'),
      );
    }
    return Column(
      children: [
        if (_image != null)
          Image.memory(
            _image!,
            fit: BoxFit.contain,
            gaplessPlayback: true,
            errorBuilder: (_, __, ___) => Text(
              zh
                  ? '地图无法显示，离线记录不受影响。'
                  : 'Map unavailable; offline recording is unaffected.',
            ),
          ),
        if (_busy) const LinearProgressIndicator(),
        if (_failed)
          Text(
            zh
                ? '地图暂时无法加载，请稍后重试或检查网络与登录状态。离线记录不受影响。'
                : 'Map unavailable. Retry later or check your connection and sign-in. Offline recording is unaffected.',
          ),
        if (_pointTime != null)
          Text(
            '${zh ? '高德地图 · 定位时间' : 'AMap · position time'} ${TimeOfDay.fromDateTime(_pointTime!.toLocal()).format(context)}',
            style: Theme.of(context).textTheme.labelSmall,
          ),
        Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            IconButton(
              tooltip: zh ? '缩小' : 'Zoom out',
              onPressed: _busy || _zoom <= 3
                  ? null
                  : () {
                      _zoom--;
                      _load();
                    },
              icon: const Icon(Icons.remove),
            ),
            TextButton.icon(
              onPressed: _busy ? null : _load,
              icon: const Icon(Icons.refresh),
              label: Text(zh ? '更新位置' : 'Refresh position'),
            ),
            IconButton(
              tooltip: zh ? '放大' : 'Zoom in',
              onPressed: _busy || _zoom >= 17
                  ? null
                  : () {
                      _zoom++;
                      _load();
                    },
              icon: const Icon(Icons.add),
            ),
            TextButton(
              onPressed: () {
                _disable();
              },
              child: Text(zh ? '关闭地图' : 'Close map'),
            ),
          ],
        ),
      ],
    );
  }
}
