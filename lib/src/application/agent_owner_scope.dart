import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import 'auth_provider.dart';

/// An identity lease, replaced even when a user logs out and back in.
class AgentOwnerScope {
  AgentOwnerScope(this.ownerUserId) : epoch = const Uuid().v4();
  final String? ownerUserId;
  final String epoch;
}

final agentOwnerScopeProvider = Provider<AgentOwnerScope>((ref) {
  return AgentOwnerScope(ref.watch(currentUserIdProvider));
});
