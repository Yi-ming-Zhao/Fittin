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

    return DashboardPageScaffold(
      bottomPadding: 24,
      safeAreaBottom: true,
      children: [
        DashboardScreenHeader(
          eyebrow: strings.settings,
          title: strings.aboutPageTitle,
          subtitle: strings.aboutPageSubtitle,
          showBackButton: true,
        ),
        const SizedBox(height: 24),
        _AppIdentityCard(theme: theme, tagline: strings.aboutTagline),
        const SizedBox(height: 16),
        DashboardSurfaceCard(
          radius: theme.radius,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          child: packageInfo.when(
            data: (info) => Column(
              children: [
                _InfoRow(
                  theme: theme,
                  label: strings.aboutCurrentVersion,
                  value: info.version,
                  valueKey: const ValueKey('about-current-version'),
                  showDivider: true,
                ),
                _InfoRow(
                  theme: theme,
                  label: strings.aboutBuildNumber,
                  value: info.buildNumber,
                  valueKey: const ValueKey('about-build-number'),
                  showDivider: true,
                ),
                _InfoRow(
                  theme: theme,
                  label: strings.aboutPlatform,
                  value: _platformLabel(),
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
                  strings.aboutVersionUnavailable,
                  style: theme.uiStyle(13, theme.fgDim),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        DashboardSectionLabel(label: strings.aboutAppUpdateSection),
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
                strings: strings,
              ),
              const SizedBox(height: 18),
              if (_checkState == _UpdateCheckState.available) ...[
                FittinBtn(
                  theme,
                  _isAndroid && _latestRelease?.androidApkUrl != null
                      ? strings.aboutDownloadAndroidUpdate
                      : strings.aboutViewNewRelease,
                  key: const ValueKey('download-app-update'),
                  icon: Icons.system_update_alt_rounded,
                  block: true,
                  onPressed: _openUpdate,
                ),
                const SizedBox(height: 10),
                FittinBtn(
                  theme,
                  strings.aboutViewReleaseNotes,
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
                  _checkButtonLabel(strings),
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
                    strings.aboutOpenOfficialDownloads,
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
                      strings.aboutUpdateMethod,
                      style: theme
                          .uiStyle(14, theme.fg)
                          .copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      strings.aboutUpdateMethodDescription,
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

  String _checkButtonLabel(AppStrings strings) {
    return switch (_checkState) {
      _UpdateCheckState.checking => strings.aboutCheckingButton,
      _UpdateCheckState.current => strings.aboutCheckAgain,
      _UpdateCheckState.failed => strings.aboutTryAgain,
      _ => strings.aboutCheckForUpdates,
    };
  }
}

class _AppIdentityCard extends StatelessWidget {
  const _AppIdentityCard({required this.theme, required this.tagline});

  final FittinTheme theme;
  final String tagline;

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
                Text(tagline, style: theme.uiStyle(13, theme.fgDim)),
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
    required this.strings,
  });

  final FittinTheme theme;
  final _UpdateCheckState state;
  final AppReleaseInfo? release;
  final AppStrings strings;

  @override
  Widget build(BuildContext context) {
    final (icon, title, detail) = switch (state) {
      _UpdateCheckState.checking => (
        Icons.sync_rounded,
        strings.aboutCheckingForUpdates,
        strings.aboutConnectingReleaseService,
      ),
      _UpdateCheckState.current => (
        Icons.check_circle_outline_rounded,
        strings.aboutUpToDate,
        strings.aboutNoNewerRelease,
      ),
      _UpdateCheckState.available => (
        Icons.new_releases_outlined,
        strings.aboutVersionAvailable(release?.version),
        strings.aboutOfficialDownloadReady,
      ),
      _UpdateCheckState.failed => (
        Icons.cloud_off_outlined,
        strings.aboutUpdateCheckFailed,
        strings.aboutUpdateCheckFailedDetail,
      ),
      _ => (
        Icons.system_update_outlined,
        strings.aboutGetLatestRelease,
        strings.aboutCheckNewAndroidPackage,
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

String _platformLabel() {
  if (kIsWeb) return 'Web';
  return switch (defaultTargetPlatform) {
    TargetPlatform.android => 'Android',
    TargetPlatform.iOS => 'iOS',
    TargetPlatform.macOS => 'macOS',
    TargetPlatform.windows => 'Windows',
    TargetPlatform.linux => 'Linux',
    TargetPlatform.fuchsia => 'Fuchsia',
  };
}
