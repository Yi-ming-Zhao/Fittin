import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:fittin_v2/src/application/local_supabase_probe.dart';

enum SupabaseBootstrapStatus { configured, unavailable }

class SupabaseBootstrapState {
  const SupabaseBootstrapState.configured({
    required this.url,
    required this.anonKey,
  }) : status = SupabaseBootstrapStatus.configured,
       errorMessage = null;

  const SupabaseBootstrapState.unavailable([this.errorMessage])
    : status = SupabaseBootstrapStatus.unavailable,
      url = '',
      anonKey = '';

  final SupabaseBootstrapStatus status;
  final String url;
  final String anonKey;
  final String? errorMessage;

  bool get isConfigured => status == SupabaseBootstrapStatus.configured;
}

final supabaseBootstrapProvider = Provider<SupabaseBootstrapState>((ref) {
  return const SupabaseBootstrapState.unavailable(
    'Supabase bootstrap was not overridden.',
  );
});

final supabaseClientProvider = Provider<SupabaseClient?>((ref) {
  final bootstrap = ref.watch(supabaseBootstrapProvider);
  if (!bootstrap.isConfigured) {
    return null;
  }
  return Supabase.instance.client;
});

typedef SupabaseClientInitializer =
    Future<void> Function({required String url, required String anonKey});

const localSupabaseDevUrl = 'http://127.0.0.1:55321';
const localSupabaseDevPublishableKey =
    'sb_publishable_ACJWlzQHlZjBrEguHvfOxg_3BJgxAaH';

Future<SupabaseBootstrapState> initializeSupabase({
  String? configuredUrl,
  String? configuredAnonKey,
  LocalSupabaseProbe? localDevStackProbe,
  SupabaseClientInitializer? initializeClient,
  TargetPlatform? targetPlatformOverride,
  bool? isWebOverride,
}) async {
  final url = configuredUrl ?? const String.fromEnvironment('SUPABASE_URL');
  final anonKey =
      configuredAnonKey ?? const String.fromEnvironment('SUPABASE_ANON_KEY');
  final probe = localDevStackProbe ?? defaultLocalSupabaseProbe;
  final initializer =
      initializeClient ??
      ({required String url, required String anonKey}) =>
          Supabase.initialize(url: url, anonKey: anonKey);
  final targetPlatform = targetPlatformOverride ?? defaultTargetPlatform;
  final isWebRuntime = isWebOverride ?? kIsWeb;

  if (url.isNotEmpty || anonKey.isNotEmpty) {
    if (url.isEmpty || anonKey.isEmpty) {
      return const SupabaseBootstrapState.unavailable(
        'Both SUPABASE_URL and SUPABASE_ANON_KEY must be provided together.',
      );
    }
    return _initializeSupabaseClient(
      url: url,
      anonKey: anonKey,
      initializer: initializer,
    );
  }

  if (!isWebRuntime && targetPlatform == TargetPlatform.android) {
    return const SupabaseBootstrapState.unavailable(
      'Missing SUPABASE_URL and SUPABASE_ANON_KEY. Android APK builds cannot auto-connect to the repo-local Supabase stack via 127.0.0.1; provide explicit Supabase config for devices.',
    );
  }

  final localDevUri = Uri.parse(localSupabaseDevUrl);
  final localDevAvailable = await probe(localDevUri);
  if (!localDevAvailable) {
    return const SupabaseBootstrapState.unavailable(
      'Missing SUPABASE_URL and SUPABASE_ANON_KEY. Local Supabase dev stack at http://127.0.0.1:55321 is not reachable.',
    );
  }

  return _initializeSupabaseClient(
    url: localSupabaseDevUrl,
    anonKey: localSupabaseDevPublishableKey,
    initializer: initializer,
  );
}

Future<SupabaseBootstrapState> _initializeSupabaseClient({
  required String url,
  required String anonKey,
  required SupabaseClientInitializer initializer,
}) async {
  try {
    await initializer(url: url, anonKey: anonKey);
    return SupabaseBootstrapState.configured(url: url, anonKey: anonKey);
  } catch (error) {
    return SupabaseBootstrapState.unavailable(error.toString());
  }
}
