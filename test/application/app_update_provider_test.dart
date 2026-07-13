import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:fittin_v2/src/application/app_update_provider.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  group('application version comparison', () {
    test('compares numeric segments instead of strings', () {
      expect(compareAppVersions('1.0.10', '1.0.9'), greaterThan(0));
      expect(compareAppVersions('v2.0.0', '1.99.99'), greaterThan(0));
      expect(compareAppVersions('1.0', '1.0.0'), 0);
    });

    test('does not offer a downgrade', () {
      expect(
        isAppUpdateAvailable(currentVersion: '1.2.0', latestVersion: 'v1.1.9'),
        isFalse,
      );
    });
  });

  group('GitHubAppUpdateSource', () {
    test('reads the release version and Android APK asset', () async {
      final source = GitHubAppUpdateSource(
        client: MockClient((request) async {
          expect(request.url.host, 'api.github.com');
          return http.Response(
            jsonEncode({
              'tag_name': 'v1.0.6',
              'html_url':
                  'https://github.com/Yi-ming-Zhao/Fittin/releases/tag/v1.0.6',
              'assets': [
                {
                  'name': 'fittin-v1.0.6-android.aab',
                  'browser_download_url':
                      'https://github.com/Yi-ming-Zhao/Fittin/releases/download/v1.0.6/fittin.aab',
                },
                {
                  'name': 'fittin-v1.0.6-android.apk',
                  'browser_download_url':
                      'https://github.com/Yi-ming-Zhao/Fittin/releases/download/v1.0.6/fittin.apk',
                },
              ],
            }),
            200,
          );
        }),
      );

      final release = await source.fetchLatestRelease();

      expect(release.version, '1.0.6');
      expect(release.androidApkUrl?.path, endsWith('/fittin.apk'));
      expect(release.releasePageUrl.path, endsWith('/tag/v1.0.6'));
    });

    test('keeps the release page as a fallback when no APK exists', () async {
      final source = GitHubAppUpdateSource(
        client: MockClient(
          (_) async => http.Response(
            jsonEncode({
              'tag_name': 'v1.0.6',
              'html_url':
                  'https://github.com/Yi-ming-Zhao/Fittin/releases/tag/v1.0.6',
              'assets': const [],
            }),
            200,
          ),
        ),
      );

      final release = await source.fetchLatestRelease();

      expect(release.androidApkUrl, isNull);
      expect(release.releasePageUrl.host, 'github.com');
    });

    test('rejects an unsuccessful response', () async {
      final source = GitHubAppUpdateSource(
        client: MockClient((_) async => http.Response('rate limited', 403)),
      );

      expect(source.fetchLatestRelease(), throwsA(isA<AppUpdateException>()));
    });

    test('rejects release links outside the Fittin repository', () async {
      final source = GitHubAppUpdateSource(
        client: MockClient(
          (_) async => http.Response(
            jsonEncode({
              'tag_name': 'v1.0.6',
              'html_url':
                  'https://github.com/another/repository/releases/tag/v1.0.6',
              'assets': const [],
            }),
            200,
          ),
        ),
      );

      expect(source.fetchLatestRelease(), throwsA(isA<AppUpdateException>()));
    });

    test('rejects an APK URL that is not a release download', () async {
      final source = GitHubAppUpdateSource(
        client: MockClient(
          (_) async => http.Response(
            jsonEncode({
              'tag_name': 'v1.0.6',
              'html_url':
                  'https://github.com/Yi-ming-Zhao/Fittin/releases/tag/v1.0.6',
              'assets': [
                {
                  'name': 'fittin.apk',
                  'browser_download_url':
                      'https://github.com/Yi-ming-Zhao/Fittin/releases/tag/v1.0.6/fittin.apk',
                },
              ],
            }),
            200,
          ),
        ),
      );

      expect(source.fetchLatestRelease(), throwsA(isA<AppUpdateException>()));
    });

    test('rejects a malformed release version', () async {
      final source = GitHubAppUpdateSource(
        client: MockClient(
          (_) async => http.Response(
            jsonEncode({
              'tag_name': 'latest',
              'html_url':
                  'https://github.com/Yi-ming-Zhao/Fittin/releases/tag/latest',
              'assets': const [],
            }),
            200,
          ),
        ),
      );

      expect(source.fetchLatestRelease(), throwsA(isA<AppUpdateException>()));
    });
  });
}
