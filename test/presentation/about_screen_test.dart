import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fittin_v2/src/application/active_session_provider.dart';
import 'package:fittin_v2/src/application/app_update_provider.dart';
import 'package:fittin_v2/src/presentation/screens/about_screen.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../support/in_memory_database_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('about screen shows installed version and build number', (
    tester,
  ) async {
    await _pumpAbout(tester, source: _FakeUpdateSource(_release('1.2.3')));

    expect(find.text('1.2.3'), findsOneWidget);
    expect(find.text('42'), findsOneWidget);
    expect(find.byKey(const ValueKey('dashboard-header-back')), findsOneWidget);

    final migrationNote = find.byKey(const ValueKey('legacy-signing-note'));
    await tester.scrollUntilVisible(
      migrationNote,
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(migrationNote, findsOneWidget);
  });

  testWidgets('same release reports that the app is current', (tester) async {
    var launchCount = 0;
    await _pumpAbout(
      tester,
      source: _FakeUpdateSource(_release('1.2.3')),
      launcher: (_) async {
        launchCount += 1;
        return true;
      },
    );

    await _tapCheckForUpdates(tester);

    expect(find.text('You are up to date'), findsOneWidget);
    expect(find.byKey(const ValueKey('download-app-update')), findsNothing);
    expect(launchCount, 0);
  });

  testWidgets('new Android release opens its APK download', (tester) async {
    Uri? launchedUrl;
    await _pumpAbout(
      tester,
      source: _FakeUpdateSource(_release('1.3.0')),
      launcher: (uri) async {
        launchedUrl = uri;
        return true;
      },
    );

    await _tapCheckForUpdates(tester);
    final download = find.byKey(const ValueKey('download-app-update'));
    await tester.scrollUntilVisible(
      download,
      220,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.ensureVisible(download);
    await tester.pumpAndSettle();
    await tester.tap(download);
    await tester.pumpAndSettle();

    expect(find.text('Version 1.3.0 is available'), findsOneWidget);
    expect(launchedUrl?.path, endsWith('/fittin.apk'));
  });

  testWidgets('release page is used when no APK asset exists', (tester) async {
    Uri? launchedUrl;
    await _pumpAbout(
      tester,
      source: _FakeUpdateSource(
        AppReleaseInfo(
          version: '1.3.0',
          releasePageUrl: Uri.parse(
            'https://github.com/Yi-ming-Zhao/Fittin/releases/tag/v1.3.0',
          ),
        ),
      ),
      launcher: (uri) async {
        launchedUrl = uri;
        return true;
      },
    );

    await _tapCheckForUpdates(tester);
    final download = find.byKey(const ValueKey('download-app-update'));
    await tester.scrollUntilVisible(
      download,
      220,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.ensureVisible(download);
    await tester.pumpAndSettle();
    await tester.tap(download);
    await tester.pumpAndSettle();

    expect(launchedUrl?.path, endsWith('/tag/v1.3.0'));
  });

  testWidgets('non-Android platforms open the release page', (tester) async {
    Uri? launchedUrl;
    await _pumpAbout(
      tester,
      source: _FakeUpdateSource(_release('1.3.0')),
      platform: TargetPlatform.iOS,
      launcher: (uri) async {
        launchedUrl = uri;
        return true;
      },
    );

    await _tapCheckForUpdates(tester);
    final download = find.byKey(const ValueKey('download-app-update'));
    await tester.ensureVisible(download);
    await tester.pumpAndSettle();
    await tester.tap(download);
    await tester.pumpAndSettle();

    expect(launchedUrl?.path, endsWith('/tag/v1.3.0'));
  });

  testWidgets('network failure shows a retry state', (tester) async {
    await _pumpAbout(tester, source: _ThrowingUpdateSource());

    await _tapCheckForUpdates(tester);

    expect(find.text('Update check failed'), findsOneWidget);
    expect(find.text('Try again'), findsOneWidget);
  });

  testWidgets('network failure keeps the official downloads available', (
    tester,
  ) async {
    Uri? launchedUrl;
    await _pumpAbout(
      tester,
      source: _ThrowingUpdateSource(),
      launcher: (uri) async {
        launchedUrl = uri;
        return true;
      },
    );

    await _tapCheckForUpdates(tester);
    final downloads = find.byKey(const ValueKey('open-app-releases'));
    await tester.scrollUntilVisible(
      downloads,
      220,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.ensureVisible(downloads);
    await tester.pumpAndSettle();
    await tester.tap(downloads);
    await tester.pumpAndSettle();

    expect(launchedUrl, appReleasesPageUri);
  });

  testWidgets('launcher failure returns to a retry state', (tester) async {
    await _pumpAbout(
      tester,
      source: _FakeUpdateSource(_release('1.3.0')),
      launcher: (_) => throw StateError('no browser'),
    );

    await _tapCheckForUpdates(tester);
    final download = find.byKey(const ValueKey('download-app-update'));
    await tester.ensureVisible(download);
    await tester.pumpAndSettle();
    await tester.tap(download);
    await tester.pumpAndSettle();

    expect(find.text('Update check failed'), findsOneWidget);
  });

  testWidgets('launcher false result returns to a retry state', (tester) async {
    await _pumpAbout(
      tester,
      source: _FakeUpdateSource(_release('1.3.0')),
      launcher: (_) async => false,
    );

    await _tapCheckForUpdates(tester);
    final download = find.byKey(const ValueKey('download-app-update'));
    await tester.ensureVisible(download);
    await tester.pumpAndSettle();
    await tester.tap(download);
    await tester.pumpAndSettle();

    expect(find.text('Update check failed'), findsOneWidget);
  });

  testWidgets('long phone viewport has no layout overflow', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await _pumpAbout(tester, source: _FakeUpdateSource(_release('1.2.3')));

    expect(tester.takeException(), isNull);
    expect(find.byType(Scrollable), findsOneWidget);
  });
}

Future<void> _pumpAbout(
  WidgetTester tester, {
  required AppUpdateSource source,
  ExternalUrlLauncher? launcher,
  TargetPlatform platform = TargetPlatform.android,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        databaseRepositoryProvider.overrideWithValue(
          InMemoryDatabaseRepository(),
        ),
        appPlatformProvider.overrideWithValue(platform),
        appPackageInfoProvider.overrideWith(
          (ref) async => PackageInfo(
            appName: 'Fittin',
            packageName: 'com.example.fittin_v2',
            version: '1.2.3',
            buildNumber: '42',
          ),
        ),
        appUpdateSourceProvider.overrideWithValue(source),
        if (launcher != null)
          externalUrlLauncherProvider.overrideWithValue(launcher),
      ],
      child: const MaterialApp(home: AboutScreen()),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _tapCheckForUpdates(WidgetTester tester) async {
  final check = find.byKey(const ValueKey('check-app-update'));
  await tester.scrollUntilVisible(
    check,
    220,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.ensureVisible(check);
  await tester.pumpAndSettle();
  await tester.tap(check);
  await tester.pumpAndSettle();
}

AppReleaseInfo _release(String version) => AppReleaseInfo(
  version: version,
  releasePageUrl: Uri.parse(
    'https://github.com/Yi-ming-Zhao/Fittin/releases/tag/v$version',
  ),
  androidApkUrl: Uri.parse(
    'https://github.com/Yi-ming-Zhao/Fittin/releases/download/v$version/fittin.apk',
  ),
);

class _FakeUpdateSource implements AppUpdateSource {
  const _FakeUpdateSource(this.release);

  final AppReleaseInfo release;

  @override
  Future<AppReleaseInfo> fetchLatestRelease() async => release;
}

class _ThrowingUpdateSource implements AppUpdateSource {
  @override
  Future<AppReleaseInfo> fetchLatestRelease() async {
    throw const AppUpdateException('offline');
  }
}
