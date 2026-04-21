import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum SupabaseBootstrapStatus { configured, unavailable }

class SupabaseBootstrapState {
  const SupabaseBootstrapState.configured({
    required this.url,
    this.anonKey = '',
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
    'Backend bootstrap was not overridden.',
  );
});

const localBackendDevUrl = 'http://127.0.0.1:8081';

Future<SupabaseBootstrapState> initializeSupabase({
  String? configuredUrl,
  String? configuredAnonKey,
  Future<bool> Function(Uri baseUri)? localDevStackProbe,
  Future<void> Function({required String url, required String anonKey})?
  initializeClient,
  TargetPlatform? targetPlatformOverride,
  bool? isWebOverride,
}) async {
  final url = configuredUrl ?? const String.fromEnvironment('BACKEND_URL');
  final apiKey =
      configuredAnonKey ?? const String.fromEnvironment('BACKEND_API_KEY');
  final targetPlatform = targetPlatformOverride ?? defaultTargetPlatform;
  final isWebRuntime = isWebOverride ?? kIsWeb;

  if (url.isNotEmpty) {
    try {
      if (initializeClient != null) {
        await initializeClient(url: url, anonKey: apiKey);
      }
      return SupabaseBootstrapState.configured(url: url, anonKey: apiKey);
    } catch (error) {
      return SupabaseBootstrapState.unavailable(error.toString());
    }
  }

  if (!isWebRuntime && targetPlatform == TargetPlatform.android) {
    return const SupabaseBootstrapState.unavailable(
      'Missing BACKEND_URL. Android APK builds cannot auto-connect to the repo-local backend via 127.0.0.1; provide explicit backend config for devices.',
    );
  }

  final localDevUri = Uri.parse(localBackendDevUrl);
  if (localDevStackProbe != null) {
    final localDevAvailable = await localDevStackProbe(localDevUri);
    if (!localDevAvailable) {
      return const SupabaseBootstrapState.unavailable(
        'Missing BACKEND_URL. Local backend dev server at http://127.0.0.1:8081 is not reachable.',
      );
    }
  }

  try {
    if (initializeClient != null) {
      await initializeClient(url: localBackendDevUrl, anonKey: apiKey);
    }
    return SupabaseBootstrapState.configured(
      url: localBackendDevUrl,
      anonKey: apiKey,
    );
  } catch (error) {
    return SupabaseBootstrapState.unavailable(error.toString());
  }
}
