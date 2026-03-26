import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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

Future<SupabaseBootstrapState> initializeSupabase() async {
  const url = String.fromEnvironment('SUPABASE_URL');
  const anonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
  const localDevUrl = 'http://127.0.0.1:55321';
  const localDevPublishableKey =
      'sb_publishable_ACJWlzQHlZjBrEguHvfOxg_3BJgxAaH';

  final resolvedUrl = url.isNotEmpty ? url : (kDebugMode ? localDevUrl : '');
  final resolvedAnonKey = anonKey.isNotEmpty
      ? anonKey
      : (kDebugMode ? localDevPublishableKey : '');

  if (resolvedUrl.isEmpty || resolvedAnonKey.isEmpty) {
    return const SupabaseBootstrapState.unavailable(
      'Missing SUPABASE_URL or SUPABASE_ANON_KEY dart define. Debug builds fall back to the local Supabase dev stack when available.',
    );
  }

  try {
    await Supabase.initialize(url: resolvedUrl, anonKey: resolvedAnonKey);
    return SupabaseBootstrapState.configured(
      url: resolvedUrl,
      anonKey: resolvedAnonKey,
    );
  } catch (error) {
    return SupabaseBootstrapState.unavailable(error.toString());
  }
}
