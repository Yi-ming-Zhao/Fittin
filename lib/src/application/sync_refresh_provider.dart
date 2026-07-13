import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Changes after a successful remote synchronization so cached data providers
/// reread the local store populated by the sync service.
final syncRefreshProvider = StateProvider<int>((ref) => 0);
