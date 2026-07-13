import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fittin_v2/src/application/app_update_provider.dart';
import 'package:fittin_v2/src/application/fittin_theme_provider.dart';
import 'package:fittin_v2/src/presentation/localization/app_strings.dart';
import 'package:fittin_v2/src/presentation/theme/fittin_theme.dart';
import 'package:fittin_v2/src/presentation/widgets/dashboard_primitives.dart';
import 'package:fittin_v2/src/presentation/widgets/fittin_primitives.dart';

enum _UpdateCheckState { idle, checking, current, available, failed }

class AboutScreen extends ConsumerStatefulWidget {
  const AboutScreen({super.key});

  @override
  ConsumerState<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends ConsumerState<AboutScreen> {
  _UpdateCheckState _checkState = _UpdateCheckState.idle;
  AppReleaseInfo? _latestRelease;

  bool get _isAndroid =>
      ref.read(appPlatformProvider) == TargetPlatform.android;

  Future<void> _checkForUpdate() async {
    if (_checkState == _UpdateCheckState.checking) return;
    setState(() => _checkState = _UpdateCheckState.checking);

    try {
      final packageInfo = await ref.read(appPackageInfoProvider.future);
      final release = await ref
          .read(appUpdateSourceProvider)
          .fetchLatestRelease();
      final hasUpdate = isAppUpdateAvailable(
        currentVersion: packageInfo.version,
        latestVersion: release.version,
      );
      if (!mounted) return;
      setState(() {
        _latestRelease = release;
        _checkState = hasUpdate
            ? _UpdateCheckState.available
            : _UpdateCheckState.current;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _latestRelease = null;
        _checkState = _UpdateCheckState.failed;
      });
    }
  }

  Future<void> _openUrl(Uri uri) async {
    try {
      final launched = await ref.read(externalUrlLauncherProvider)(uri);
      if (launched || !mounted) return;
    } catch (_) {
      if (!mounted) return;
    }
    setState(() => _checkState = _UpdateCheckState.failed);
  }

  Future<void> _openUpdate() async {
    final release = _latestRelease;
    if (release == null) return;
    final target = _isAndroid && release.androidApkUrl != null
        ? release.androidApkUrl!
        : release.releasePageUrl;
    await _openUrl(target);
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context, ref);
    final theme = ref.watch(resolvedFittinThemeProvider);
    final packageInfo = ref.watch(appPackageInfoProvider);
    final isChinese = strings.isChinese;

    return DashboardPageScaffold(
      bottomPadding: 80,
      children: [
        DashboardScreenHeader(
          eyebrow: strings.settings,
          title: isChinese ? '关于' : 'About',
          subtitle: isChinese
              ? '版本信息、发布来源与应用更新。'
              : 'Version details, release source, and app updates.',
          showBackButton: true,
        ),
        const SizedBox(height: 24),
        _AppIdentityCard(theme: theme, isChinese: isChinese),
        const SizedBox(height: 16),
        DashboardSurfaceCard(
          radius: theme.radius,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          child: packageInfo.when(
            data: (info) => Column(
              children: [
                _InfoRow(
                  theme: theme,
                  label: isChinese ? '当前版本' : 'Current version',
                  value: info.version,
                  valueKey: const ValueKey('about-current-version'),
                  showDivider: true,
                ),
                _InfoRow(
                  theme: theme,
                  label: isChinese ? '构建号' : 'Build number',
                  value: info.buildNumber,
                  valueKey: const ValueKey('about-build-number'),
                  showDivider: true,
                ),
                _InfoRow(
                  theme: theme,
                  label: isChinese ? '平台' : 'Platform',
                  value: _platformLabel(isChinese),
                ),
              ],
            ),
            loading: () => const SizedBox(
              height: 144,
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (_, _) => SizedBox(
              height: 96,
              child: Center(
                child: Text(
                  isChinese
                      ? '暂时无法读取版本信息。'
                      : 'Version details are unavailable.',
                  style: theme.uiStyle(13, theme.fgDim),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        DashboardSectionLabel(label: isChinese ? '应用更新' : 'APP UPDATE'),
        const SizedBox(height: 10),
        DashboardSurfaceCard(
          radius: theme.radius,
          padding: EdgeInsets.all(theme.pad),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _UpdateStatus(
                theme: theme,
                state: _checkState,
                release: _latestRelease,
                isChinese: isChinese,
              ),
              const SizedBox(height: 18),
              if (_checkState == _UpdateCheckState.available) ...[
                FittinBtn(
                  theme,
                  _isAndroid && _latestRelease?.androidApkUrl != null
                      ? (isChinese ? '下载安卓更新' : 'Download Android update')
                      : (isChinese ? '查看新版本' : 'View new release'),
                  key: const ValueKey('download-app-update'),
                  icon: Icons.system_update_alt_rounded,
                  block: true,
                  onPressed: _openUpdate,
                ),
                const SizedBox(height: 10),
                FittinBtn(
                  theme,
                  isChinese ? '查看发布说明' : 'View release notes',
                  key: const ValueKey('open-release-notes'),
                  variant: 'secondary',
                  block: true,
                  onPressed: () {
                    final release = _latestRelease;
                    if (release != null) _openUrl(release.releasePageUrl);
                  },
                ),
              ] else ...[
                FittinBtn(
                  theme,
                  _checkButtonLabel(isChinese),
                  key: const ValueKey('check-app-update'),
                  icon: Icons.refresh_rounded,
                  block: true,
                  onPressed: _checkState == _UpdateCheckState.checking
                      ? null
                      : _checkForUpdate,
                ),
                if (_checkState == _UpdateCheckState.failed) ...[
                  const SizedBox(height: 10),
                  FittinBtn(
                    theme,
                    isChinese ? '打开官方下载页' : 'Open official downloads',
                    key: const ValueKey('open-app-releases'),
                    icon: Icons.open_in_new_rounded,
                    variant: 'secondary',
                    block: true,
                    onPressed: () => _openUrl(appReleasesPageUri),
                  ),
                ],
              ],
            ],
          ),
        ),
        const SizedBox(height: 16),
        DashboardSurfaceCard(
          radius: theme.radius,
          padding: EdgeInsets.all(theme.pad),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: theme.accentDim,
                ),
                child: Icon(
                  Icons.download_outlined,
                  size: 18,
                  color: theme.accent,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isChinese ? '更新方式' : 'How updates work',
                      style: theme
                          .uiStyle(14, theme.fg)
                          .copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      isChinese
                          ? '版本信息来自 Fittin 的 GitHub Release。安卓会在浏览器下载 APK，并由系统要求你确认安装。\n\n从 1.0.6 起，安卓版本使用固定正式签名。若设备仍安装 1.0.5 或更早版本，请先同步或备份数据，卸载旧版后再安装一次 1.0.6。'
                          : 'Release details come from Fittin on GitHub. Android downloads the APK in your browser and asks you to confirm installation.\n\nFrom 1.0.6 onward, Android releases share one stable signer. If 1.0.5 or earlier is installed, sync or back up first, uninstall it, then install 1.0.6 once.',
                      key: const ValueKey('legacy-signing-note'),
                      style: theme
                          .uiStyle(12, theme.fgDim)
                          .copyWith(height: 1.5),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _checkButtonLabel(bool isChinese) {
    return switch (_checkState) {
      _UpdateCheckState.checking => isChinese ? '正在检查…' : 'Checking…',
      _UpdateCheckState.current => isChinese ? '再次检查' : 'Check again',
      _UpdateCheckState.failed => isChinese ? '重试' : 'Try again',
      _ => isChinese ? '检查更新' : 'Check for updates',
    };
  }
}

class _AppIdentityCard extends StatelessWidget {
  const _AppIdentityCard({required this.theme, required this.isChinese});

  final FittinTheme theme;
  final bool isChinese;

  @override
  Widget build(BuildContext context) {
    return DashboardSurfaceCard(
      radius: theme.radius,
      highlight: true,
      padding: EdgeInsets.all(theme.pad),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: theme.accent,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(
              Icons.fitness_center_rounded,
              color: theme.accentInk,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Fittin',
                  style: theme.displayStyle(28, theme.fg).copyWith(height: 1),
                ),
                const SizedBox(height: 7),
                Text(
                  isChinese ? '专注每一次训练。' : 'Make every set count.',
                  style: theme.uiStyle(13, theme.fgDim),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.theme,
    required this.label,
    required this.value,
    this.valueKey,
    this.showDivider = false,
  });

  final FittinTheme theme;
  final String label;
  final String value;
  final Key? valueKey;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        border: showDivider
            ? Border(bottom: BorderSide(color: theme.border, width: 0.5))
            : null,
      ),
      child: Row(
        children: [
          Expanded(child: Text(label, style: theme.uiStyle(13, theme.fgDim))),
          const SizedBox(width: 12),
          Text(
            value,
            key: valueKey,
            style: theme
                .numStyle(14, theme.fg)
                .copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _UpdateStatus extends StatelessWidget {
  const _UpdateStatus({
    required this.theme,
    required this.state,
    required this.release,
    required this.isChinese,
  });

  final FittinTheme theme;
  final _UpdateCheckState state;
  final AppReleaseInfo? release;
  final bool isChinese;

  @override
  Widget build(BuildContext context) {
    final (icon, title, detail) = switch (state) {
      _UpdateCheckState.checking => (
        Icons.sync_rounded,
        isChinese ? '正在检查更新' : 'Checking for updates',
        isChinese ? '正在连接发布服务器…' : 'Connecting to the release service…',
      ),
      _UpdateCheckState.current => (
        Icons.check_circle_outline_rounded,
        isChinese ? '已是最新版本' : 'You are up to date',
        isChinese ? '当前没有可用的新版本。' : 'No newer release is available.',
      ),
      _UpdateCheckState.available => (
        Icons.new_releases_outlined,
        isChinese
            ? '发现新版本 ${release?.version}'
            : 'Version ${release?.version} is available',
        isChinese ? '可立即打开官方下载地址。' : 'The official download is ready to open.',
      ),
      _UpdateCheckState.failed => (
        Icons.cloud_off_outlined,
        isChinese ? '检查失败' : 'Update check failed',
        isChinese
            ? '请检查网络后重试，也可直接打开官方下载页。'
            : 'Try again, or open the official downloads page directly.',
      ),
      _ => (
        Icons.system_update_outlined,
        isChinese ? '获取最新版本' : 'Get the latest release',
        isChinese ? '手动检查是否有新的安卓安装包。' : 'Check for a newer Android package.',
      ),
    };

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 22, color: theme.accent),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                key: const ValueKey('app-update-status'),
                style: theme
                    .uiStyle(15, theme.fg)
                    .copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 5),
              Text(
                detail,
                style: theme.uiStyle(12, theme.fgDim).copyWith(height: 1.45),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

String _platformLabel(bool isChinese) {
  if (kIsWeb) return isChinese ? '网页' : 'Web';
  return switch (defaultTargetPlatform) {
    TargetPlatform.android => 'Android',
    TargetPlatform.iOS => 'iOS',
    TargetPlatform.macOS => 'macOS',
    TargetPlatform.windows => 'Windows',
    TargetPlatform.linux => 'Linux',
    TargetPlatform.fuchsia => 'Fuchsia',
  };
}
