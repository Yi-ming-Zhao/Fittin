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
        configuredUrl: 'https://example.supabase.co',
        configuredAnonKey: 'explicit-anon-key',
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
      expect(state.url, 'https://example.supabase.co');
      expect(state.anonKey, 'explicit-anon-key');
      expect(initializedUrl, 'https://example.supabase.co');
      expect(initializedAnonKey, 'explicit-anon-key');
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
      expect(state.url, 'http://127.0.0.1:55321');
      expect(initializedUrl, 'http://127.0.0.1:55321');
      expect(initializedAnonKey, isNotEmpty);
    },
  );

  test('initializeSupabase reports incomplete explicit config', () async {
    final state = await initializeSupabase(
      configuredUrl: 'https://example.supabase.co',
      configuredAnonKey: '',
      localDevStackProbe: (baseUri) async => true,
      initializeClient: ({required url, required anonKey}) async {},
      targetPlatformOverride: TargetPlatform.macOS,
      isWebOverride: false,
    );

    expect(state.isConfigured, isFalse);
    expect(
      state.errorMessage,
      'Both SUPABASE_URL and SUPABASE_ANON_KEY must be provided together.',
    );
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
      contains(
        'Local Supabase dev stack at http://127.0.0.1:55321 is not reachable',
      ),
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
      'Missing SUPABASE_URL and SUPABASE_ANON_KEY. Android APK builds cannot auto-connect to the repo-local Supabase stack via 127.0.0.1; provide explicit Supabase config for devices.',
    );
  });
}
