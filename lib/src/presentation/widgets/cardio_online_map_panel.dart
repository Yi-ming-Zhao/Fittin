import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/auth_provider.dart';
import '../../data/cardio_online_map.dart';
import '../../domain/models/cardio_recording.dart';

// Deliberately session-only: no shared release key, disk storage or cloud sync.
final cardioMapKeyProvider = StateProvider<String?>((ref) {
  ref.watch(currentUserIdProvider);
  return null;
});
final cardioOnlineMapProvider = Provider<CardioOnlineMap>(
  (ref) => CardioOnlineMap(),
);

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
    var draft = ref.read(cardioMapKeyProvider) ?? '';
    final accepted = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(zh ? '启用个人在线地图' : 'Enable personal online map'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                zh
                    ? '仅用于你已获授权的个人测试。每次加载会将一个定位点及网络信息发送给高德，不发送完整路线，也不上传到 Fittin。可能消耗高德配额。Key 仅保留在本次应用会话，退出登录或重启后清除。'
                    : 'For your authorized personal testing. Each refresh sends one position and network information to AMap, not the full route or Fittin. Provider quotas may apply. The key stays only in this app session and is cleared on sign-out or restart.',
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: draft,
                onChanged: (value) => draft = value,
                obscureText: true,
                autocorrect: false,
                enableSuggestions: false,
                decoration: InputDecoration(
                  labelText: zh ? '高德 Web 服务 Key' : 'AMap Web Service key',
                ),
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
            onPressed: () => Navigator.pop(context, draft.trim()),
            child: Text(zh ? '同意并加载' : 'Agree & load'),
          ),
        ],
      ),
    );
    if (!mounted ||
        accepted == null ||
        owner != ref.read(currentUserIdProvider)) {
      return;
    }
    if (!CardioOnlineMap.validKey(accepted)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            zh
                ? '请输入有效的 32 位 Web 服务 Key。'
                : 'Enter a valid 32-character Web Service key.',
          ),
        ),
      );
      return;
    }
    ref.read(cardioMapKeyProvider.notifier).state = accepted;
    setState(() => _enabled = true);
    await _load();
  }

  Future<void> _load() async {
    final point = widget.point, key = ref.read(cardioMapKeyProvider);
    if (!_enabled ||
        _busy ||
        point == null ||
        key == null ||
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
            key: key,
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
                ? '地图加载失败，请检查 Key 类型、配额和网络。离线记录不受影响。'
                : 'Map failed to load. Check key type, quota and network. Offline recording is unaffected.',
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
                ref.read(cardioMapKeyProvider.notifier).state = null;
                _disable();
              },
              child: Text(zh ? '关闭并清除 Key' : 'Close & clear key'),
            ),
          ],
        ),
      ],
    );
  }
}
