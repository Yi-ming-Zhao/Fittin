import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

const _latestReleaseEndpoint =
    'https://api.github.com/repos/Yi-ming-Zhao/Fittin/releases/latest';
final appReleasesPageUri = Uri.parse(
  'https://github.com/Yi-ming-Zhao/Fittin/releases/latest',
);

class AppReleaseInfo {
  const AppReleaseInfo({
    required this.version,
    required this.releasePageUrl,
    this.androidApkUrl,
  });

  final String version;
  final Uri releasePageUrl;
  final Uri? androidApkUrl;
}

abstract interface class AppUpdateSource {
  Future<AppReleaseInfo> fetchLatestRelease();
}

class GitHubAppUpdateSource implements AppUpdateSource {
  GitHubAppUpdateSource({http.Client? client})
    : _client = client ?? http.Client(),
      _ownsClient = client == null;

  final http.Client _client;
  final bool _ownsClient;

  @override
  Future<AppReleaseInfo> fetchLatestRelease() async {
    final response = await _client
        .get(
          Uri.parse(_latestReleaseEndpoint),
          headers: {
            'Accept': 'application/vnd.github+json',
            'X-GitHub-Api-Version': '2022-11-28',
            if (!kIsWeb) 'User-Agent': 'Fittin-App-Update',
          },
        )
        .timeout(const Duration(seconds: 12));

    if (response.statusCode != 200) {
      throw const AppUpdateException('Unable to load the latest release.');
    }

    final Object? decoded;
    try {
      decoded = jsonDecode(response.body);
    } on FormatException {
      throw const AppUpdateException('The release response was invalid.');
    }
    if (decoded is! Map<String, dynamic>) {
      throw const AppUpdateException('The release response was invalid.');
    }

    final tagName = decoded['tag_name'];
    final htmlUrl = decoded['html_url'];
    if (tagName is! String || htmlUrl is! String) {
      throw const AppUpdateException('The release response was incomplete.');
    }

    final version = _normalizeVersion(tagName);
    if (!RegExp(r'^\d+(?:\.\d+)*$').hasMatch(version)) {
      throw const AppUpdateException('The release version was invalid.');
    }

    final releasePageUrl = _validatedGitHubUrl(
      htmlUrl,
      requiredPathPrefix: '/Yi-ming-Zhao/Fittin/releases/tag/',
    );
    Uri? androidApkUrl;
    final assets = decoded['assets'];
    if (assets is List) {
      for (final asset in assets) {
        if (asset is! Map<String, dynamic>) continue;
        final name = asset['name'];
        final downloadUrl = asset['browser_download_url'];
        if (name is String &&
            name.toLowerCase().endsWith('.apk') &&
            downloadUrl is String) {
          androidApkUrl = _validatedGitHubUrl(
            downloadUrl,
            requiredPathPrefix: '/Yi-ming-Zhao/Fittin/releases/download/',
          );
          break;
        }
      }
    }

    return AppReleaseInfo(
      version: version,
      releasePageUrl: releasePageUrl,
      androidApkUrl: androidApkUrl,
    );
  }

  void close() {
    if (_ownsClient) _client.close();
  }
}

class AppUpdateException implements Exception {
  const AppUpdateException(this.message);

  final String message;

  @override
  String toString() => message;
}

int compareAppVersions(String left, String right) {
  final leftParts = _versionParts(left);
  final rightParts = _versionParts(right);
  final count = leftParts.length > rightParts.length
      ? leftParts.length
      : rightParts.length;

  for (var index = 0; index < count; index += 1) {
    final leftPart = index < leftParts.length ? leftParts[index] : 0;
    final rightPart = index < rightParts.length ? rightParts[index] : 0;
    if (leftPart != rightPart) return leftPart.compareTo(rightPart);
  }
  return 0;
}

bool isAppUpdateAvailable({
  required String currentVersion,
  required String latestVersion,
}) => compareAppVersions(latestVersion, currentVersion) > 0;

List<int> _versionParts(String value) {
  final normalized = _normalizeVersion(value).split('+').first.split('-').first;
  final parts = normalized.split('.');
  if (parts.isEmpty || parts.any((part) => int.tryParse(part) == null)) {
    throw const FormatException('Invalid application version.');
  }
  return parts.map(int.parse).toList(growable: false);
}

String _normalizeVersion(String value) {
  final normalized = value.trim().replaceFirst(RegExp(r'^[vV]'), '');
  if (normalized.isEmpty) {
    throw const AppUpdateException('The release version was invalid.');
  }
  return normalized;
}

Uri _validatedGitHubUrl(String value, {required String requiredPathPrefix}) {
  final uri = Uri.tryParse(value);
  if (uri == null ||
      uri.scheme != 'https' ||
      uri.host != 'github.com' ||
      !uri.path.startsWith(requiredPathPrefix)) {
    throw const AppUpdateException('The release link was invalid.');
  }
  return uri;
}

final appPackageInfoProvider = FutureProvider<PackageInfo>(
  (ref) => PackageInfo.fromPlatform(),
);

final appPlatformProvider = Provider<TargetPlatform?>(
  (ref) => kIsWeb ? null : defaultTargetPlatform,
);

final appUpdateSourceProvider = Provider<AppUpdateSource>((ref) {
  final source = GitHubAppUpdateSource();
  ref.onDispose(source.close);
  return source;
});

typedef ExternalUrlLauncher = Future<bool> Function(Uri uri);

final externalUrlLauncherProvider = Provider<ExternalUrlLauncher>(
  (ref) =>
      (uri) => launchUrl(
        uri,
        mode: kIsWeb
            ? LaunchMode.platformDefault
            : LaunchMode.externalApplication,
      ),
);
