import 'dart:convert';
import 'agent_models.dart';

class AgentRunRecord {
  const AgentRunRecord({
    required this.id,
    required this.conversationId,
    required this.ownerUserId,
    required this.authEpoch,
    required this.createdAt,
    required this.updatedAt,
    required this.phase,
    this.modelTurns = 0,
    this.toolCalls = 0,
    this.hasCommittedWrites = false,
  });
  final String id;
  final String conversationId;
  final String? ownerUserId;
  final String authEpoch;
  final DateTime createdAt;
  final DateTime updatedAt;
  final AgentRunPhase phase;
  final int modelTurns;
  final int toolCalls;
  final bool hasCommittedWrites;
  AgentRunRecord advance(
    AgentRunState state, {
    bool committed = false,
    String? epoch,
  }) => AgentRunRecord(
    id: id,
    conversationId: conversationId,
    ownerUserId: ownerUserId,
    authEpoch: epoch ?? authEpoch,
    createdAt: createdAt,
    updatedAt: DateTime.now(),
    phase: state.phase,
    modelTurns: state.modelTurns,
    toolCalls: state.toolCalls,
    hasCommittedWrites: hasCommittedWrites || committed,
  );
  Map<String, dynamic> toJson() => {
    'id': id,
    'conversationId': conversationId,
    'ownerUserId': ownerUserId,
    'authEpoch': authEpoch,
    'createdAt': createdAt.toUtc().toIso8601String(),
    'updatedAt': updatedAt.toUtc().toIso8601String(),
    'phase': phase.name,
    'modelTurns': modelTurns,
    'toolCalls': toolCalls,
    'hasCommittedWrites': hasCommittedWrites,
  };
  factory AgentRunRecord.fromJson(Map<String, dynamic> j) => AgentRunRecord(
    id: j['id'] as String,
    conversationId: j['conversationId'] as String,
    ownerUserId: j['ownerUserId'] as String?,
    authEpoch: j['authEpoch'] as String,
    createdAt: DateTime.parse(j['createdAt'] as String),
    updatedAt: DateTime.parse(j['updatedAt'] as String),
    phase: AgentRunPhase.values.byName(j['phase'] as String),
    modelTurns: j['modelTurns'] as int? ?? 0,
    toolCalls: j['toolCalls'] as int? ?? 0,
    hasCommittedWrites: j['hasCommittedWrites'] == true,
  );
}

class AgentTurnRecord {
  const AgentTurnRecord({
    required this.id,
    required this.runId,
    required this.ordinal,
  });
  final String id;
  final String runId;
  final int ordinal;
  Map<String, dynamic> toJson() => {
    'id': id,
    'runId': runId,
    'ordinal': ordinal,
  };
}

class AgentRunEvent {
  const AgentRunEvent({
    required this.id,
    required this.runId,
    required this.phase,
    required this.createdAt,
    this.toolName,
    this.errorCode,
    this.elapsedMs,
    this.bytes,
    this.usage,
    this.turnId,
  });
  final String id;
  final String runId;
  final AgentRunPhase phase;
  final DateTime createdAt;
  final String? toolName;
  final String? errorCode;
  final int? elapsedMs;
  final int? bytes;
  final Map<String, int>? usage;
  final String? turnId;
  Map<String, dynamic> toJson() => {
    'id': id,
    'runId': runId,
    if (turnId != null) 'turnId': turnId,
    'phase': phase.name,
    'updatedAt': createdAt.toUtc().toIso8601String(),
    if (toolName != null) 'toolName': toolName,
    if (errorCode != null) 'errorCode': errorCode,
    if (elapsedMs != null) 'elapsedMs': elapsedMs,
    if (bytes != null) 'bytes': bytes,
    if (usage != null) 'usage': usage,
  };
  factory AgentRunEvent.fromJson(Map<String, dynamic> j) => AgentRunEvent(
    id: j['id'] as String,
    runId: j['runId'] as String,
    turnId: j['turnId'] as String?,
    phase: AgentRunPhase.values.byName(j['phase'] as String),
    createdAt: DateTime.parse(j['updatedAt'] as String),
    toolName: j['toolName'] as String?,
    errorCode: j['errorCode'] as String?,
    elapsedMs: j['elapsedMs'] as int?,
    bytes: j['bytes'] as int?,
    usage: (j['usage'] as Map?)?.cast<String, int>(),
  );
}

enum AgentApprovalOutcome { committed, rejected, conflicted }

class AgentApprovalDecision {
  const AgentApprovalDecision({
    required this.operationId,
    required this.outcome,
    this.action,
    this.changes = const [],
    this.progressionEffect,
  });
  final String operationId;
  final AgentApprovalOutcome outcome;
  final AgentActionRecord? action;
  final List<AgentMutationChange> changes;
  final String? progressionEffect;
  Map<String, dynamic> toJson() => {
    'status': outcome.name,
    'operationId': operationId,
    if (action != null) 'targetId': action!.targetId,
    if (action != null) 'targetType': action!.targetType,
    if (action != null) 'afterDigest': action!.afterDigest,
    if (action != null) 'version': action!.afterVersion,
    if (action != null)
      'actualChanges': changes.map((c) => c.toJson()).toList(),
    if (action != null) 'progressionEffect': progressionEffect,
    if (action != null) 'affectsCurrentProgress': _affectsProgress,
    'executed': outcome == AgentApprovalOutcome.committed,
  };

  /// A bounded result for the next model turn.
  ///
  /// The complete semantic diff remains in the proposal and action history for
  /// the confirmation UI and undo. Replaying every field of a newly-created
  /// plan here can duplicate tens of thousands of tokens and prevent the model
  /// from finishing after the user approves it.
  Map<String, dynamic> toModelJson({int maxChanges = 12}) {
    final visible = changes.take(maxChanges).map((change) {
      String bounded(String value) =>
          value.length <= 240 ? value : '${value.substring(0, 237)}...';
      return {
        'path': bounded(change.path),
        'before': bounded(change.before),
        'after': bounded(change.after),
      };
    }).toList();
    return {
      'status': outcome.name,
      'operationId': operationId,
      if (action != null) 'targetId': action!.targetId,
      if (action != null) 'targetType': action!.targetType,
      if (action != null) 'afterDigest': action!.afterDigest,
      if (action?.afterVersion != null) 'version': action!.afterVersion,
      if (changes.isNotEmpty) 'changeCount': changes.length,
      if (visible.isNotEmpty) 'actualChanges': visible,
      if (changes.length > visible.length) 'changesTruncated': true,
      if (action != null && progressionEffect != null)
        'progressionEffect': progressionEffect,
      if (action != null) 'affectsCurrentProgress': _affectsProgress,
      'executed': outcome == AgentApprovalOutcome.committed,
    };
  }

  bool get _affectsProgress {
    final after = jsonDecode(action!.afterJson);
    return after is Map &&
        (after.containsKey('progressionInstance') ||
            after.containsKey('migratedInstance'));
  }
}

class AgentCheckpoint {
  const AgentCheckpoint({
    required this.run,
    required this.conversation,
    this.proposal,
    this.pendingToolCallId,
    this.errorCode,
    this.errorMessage,
    this.contextSummary = '',
    this.steering = const [],
  });
  final AgentRunRecord run;
  final AgentConversation conversation;
  final AgentMutationProposal? proposal;
  final String? pendingToolCallId;
  final String? errorCode;
  final String? errorMessage;
  final String contextSummary;
  final List<String> steering;
  Map<String, dynamic> toJson() => {
    'id': run.id,
    'run': run.toJson(),
    'conversation': conversation.toJson(),
    'proposal': proposal?.toJson(),
    'pendingToolCallId': pendingToolCallId,
    'errorCode': errorCode,
    'errorMessage': errorMessage,
    'contextSummary': contextSummary,
    'steering': steering,
    'updatedAt': run.updatedAt.toUtc().toIso8601String(),
  };
  factory AgentCheckpoint.fromJson(Map<String, dynamic> j) => AgentCheckpoint(
    run: AgentRunRecord.fromJson((j['run'] as Map).cast()),
    conversation: AgentConversation.fromJson((j['conversation'] as Map).cast()),
    proposal: j['proposal'] == null
        ? null
        : AgentMutationProposal.fromJson((j['proposal'] as Map).cast()),
    pendingToolCallId: j['pendingToolCallId'] as String?,
    errorCode: j['errorCode'] as String?,
    errorMessage: j['errorMessage'] as String?,
    contextSummary: j['contextSummary'] as String? ?? '',
    steering: (j['steering'] as List? ?? []).cast<String>(),
  );
}
