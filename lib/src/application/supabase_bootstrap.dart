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

  if (url.isEmpty || anonKey.isEmpty) {
    return const SupabaseBootstrapState.unavailable(
      'Missing SUPABASE_URL or SUPABASE_ANON_KEY dart define.',
    );
  }

  try {
    await Supabase.initialize(url: url, anonKey: anonKey);
    return const SupabaseBootstrapState.configured(url: url, anonKey: anonKey);
  } catch (error) {
    return SupabaseBootstrapState.unavailable(error.toString());
  }
}
