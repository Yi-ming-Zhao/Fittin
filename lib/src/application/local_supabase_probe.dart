import 'local_supabase_probe_stub.dart'
    if (dart.library.io) 'local_supabase_probe_io.dart';

typedef LocalSupabaseProbe = Future<bool> Function(Uri baseUri);

Future<bool> defaultLocalSupabaseProbe(Uri baseUri) =>
    probeLocalSupabase(baseUri);
