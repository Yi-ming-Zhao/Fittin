import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fittin_v2/src/application/supabase_bootstrap.dart';

void main() {
  test(
    'initializeSupabase prefers explicit config over local fallback',
    () async {
      var probeCalls = 0;
      String? initializedUrl;
      String? initializedAnonKey;

      final state = await initializeSupabase(
        configuredUrl: 'https://api.example.com',
        configuredAnonKey: 'dev-api-key',
        localDevStackProbe: (baseUri) async {
          probeCalls += 1;
          return true;
        },
        initializeClient: ({required url, required anonKey}) async {
          initializedUrl = url;
          initializedAnonKey = anonKey;
        },
        targetPlatformOverride: TargetPlatform.macOS,
        isWebOverride: false,
      );

      expect(state.isConfigured, isTrue);
      expect(state.url, 'https://api.example.com');
      expect(state.anonKey, 'dev-api-key');
      expect(initializedUrl, 'https://api.example.com');
      expect(initializedAnonKey, 'dev-api-key');
      expect(probeCalls, 0);
    },
  );

  test(
    'initializeSupabase falls back to local dev stack when reachable',
    () async {
      String? initializedUrl;
      String? initializedAnonKey;

      final state = await initializeSupabase(
        configuredUrl: '',
        configuredAnonKey: '',
        localDevStackProbe: (baseUri) async => true,
        initializeClient: ({required url, required anonKey}) async {
          initializedUrl = url;
          initializedAnonKey = anonKey;
        },
        targetPlatformOverride: TargetPlatform.macOS,
        isWebOverride: false,
      );

      expect(state.isConfigured, isTrue);
      expect(state.url, 'http://127.0.0.1:8081');
      expect(initializedUrl, 'http://127.0.0.1:8081');
      expect(initializedAnonKey, isEmpty);
    },
  );

  test('initializeSupabase allows explicit config without api key', () async {
    final state = await initializeSupabase(
      configuredUrl: 'https://api.example.com',
      configuredAnonKey: '',
      localDevStackProbe: (baseUri) async => true,
      initializeClient: ({required url, required anonKey}) async {},
      targetPlatformOverride: TargetPlatform.macOS,
      isWebOverride: false,
    );

    expect(state.isConfigured, isTrue);
    expect(state.url, 'https://api.example.com');
  });

  test('initializeSupabase reports unreachable local fallback', () async {
    final state = await initializeSupabase(
      configuredUrl: '',
      configuredAnonKey: '',
      localDevStackProbe: (baseUri) async => false,
      initializeClient: ({required url, required anonKey}) async {},
      targetPlatformOverride: TargetPlatform.macOS,
      isWebOverride: false,
    );

    expect(state.isConfigured, isFalse);
    expect(
      state.errorMessage,
      contains('Local backend dev server at http://127.0.0.1:8081 is not reachable'),
    );
  });

  test('initializeSupabase requires explicit config on Android', () async {
    var probeCalls = 0;

    final state = await initializeSupabase(
      configuredUrl: '',
      configuredAnonKey: '',
      localDevStackProbe: (baseUri) async {
        probeCalls += 1;
        return true;
      },
      initializeClient: ({required url, required anonKey}) async {},
      targetPlatformOverride: TargetPlatform.android,
      isWebOverride: false,
    );

    expect(state.isConfigured, isFalse);
    expect(probeCalls, 0);
    expect(
      state.errorMessage,
      'Missing BACKEND_URL. Android APK builds cannot auto-connect to the repo-local backend via 127.0.0.1; provide explicit backend config for devices.',
    );
  });
}
