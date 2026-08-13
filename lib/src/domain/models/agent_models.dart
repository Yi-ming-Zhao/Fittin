import 'dart:convert';

enum AgentMessageRole { system, user, assistant, tool }

enum AgentRunPhase {
  idle,
  connecting,
  streaming,
  usingTools,
  awaitingApproval,
  completed,
  cancelled,
  failed,
}

enum AgentProposalStatus { pending, confirmed, rejected, stale }

enum AgentActionStatus { applied, undone, conflicted }

class AgentProviderConfig {
  const AgentProviderConfig({
    required this.baseUrl,
    required this.model,
    this.hasApiKey = false,
    this.toolCallingVerified = false,
  });

  final String baseUrl;
  final String model;
  final bool hasApiKey;
  final bool toolCallingVerified;

  bool get isReady =>
      baseUrl.trim().isNotEmpty && model.trim().isNotEmpty && hasApiKey;

  AgentProviderConfig copyWith({
    String? baseUrl,
    String? model,
    bool? hasApiKey,
    bool? toolCallingVerified,
  }) {
    return AgentProviderConfig(
      baseUrl: baseUrl ?? this.baseUrl,
      model: model ?? this.model,
      hasApiKey: hasApiKey ?? this.hasApiKey,
      toolCallingVerified: toolCallingVerified ?? this.toolCallingVerified,
    );
  }

  Map<String, dynamic> toJson() => {
    'baseUrl': baseUrl,
    'model': model,
    'hasApiKey': hasApiKey,
    'toolCallingVerified': toolCallingVerified,
  };

  factory AgentProviderConfig.fromJson(Map<String, dynamic> json) {
    return AgentProviderConfig(
      baseUrl: json['baseUrl'] as String? ?? '',
      model: json['model'] as String? ?? '',
      hasApiKey: json['hasApiKey'] as bool? ?? false,
      toolCallingVerified: json['toolCallingVerified'] as bool? ?? false,
    );
  }
}

class AgentToolCall {
  const AgentToolCall({
    required this.id,
    required this.name,
    required this.argumentsJson,
    this.resultJson,
    this.isError = false,
  });

  final String id;
  final String name;
  final String argumentsJson;
  final String? resultJson;
  final bool isError;

  AgentToolCall copyWith({String? resultJson, bool? isError}) => AgentToolCall(
    id: id,
    name: name,
    argumentsJson: argumentsJson,
    resultJson: resultJson ?? this.resultJson,
    isError: isError ?? this.isError,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'argumentsJson': argumentsJson,
    'resultJson': resultJson,
    'isError': isError,
  };

  factory AgentToolCall.fromJson(Map<String, dynamic> json) => AgentToolCall(
    id: json['id'] as String,
    name: json['name'] as String,
    argumentsJson: json['argumentsJson'] as String? ?? '{}',
    resultJson: json['resultJson'] as String?,
    isError: json['isError'] as bool? ?? false,
  );
}

class AgentMessage {
  const AgentMessage({
    required this.id,
    required this.role,
    required this.createdAt,
    this.content = '',
    this.toolCalls = const [],
    this.toolCallId,
    this.isPartial = false,
  });

  final String id;
  final AgentMessageRole role;
  final DateTime createdAt;
  final String content;
  final List<AgentToolCall> toolCalls;
  final String? toolCallId;
  final bool isPartial;

  AgentMessage copyWith({
    String? content,
    List<AgentToolCall>? toolCalls,
    bool? isPartial,
  }) => AgentMessage(
    id: id,
    role: role,
    createdAt: createdAt,
    content: content ?? this.content,
    toolCalls: toolCalls ?? this.toolCalls,
    toolCallId: toolCallId,
    isPartial: isPartial ?? this.isPartial,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'role': role.name,
    'createdAt': createdAt.toUtc().toIso8601String(),
    'content': content,
    'toolCalls': toolCalls.map((call) => call.toJson()).toList(),
    'toolCallId': toolCallId,
    'isPartial': isPartial,
  };

  factory AgentMessage.fromJson(Map<String, dynamic> json) => AgentMessage(
    id: json['id'] as String,
    role: AgentMessageRole.values.byName(json['role'] as String),
    createdAt: DateTime.parse(json['createdAt'] as String).toLocal(),
    content: json['content'] as String? ?? '',
    toolCalls: (json['toolCalls'] as List? ?? const [])
        .map((item) => AgentToolCall.fromJson((item as Map).cast()))
        .toList(),
    toolCallId: json['toolCallId'] as String?,
    isPartial: json['isPartial'] as bool? ?? false,
  );
}

class AgentConversation {
  const AgentConversation({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.updatedAt,
    required this.messages,
  });

  final String id;
  final String title;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<AgentMessage> messages;

  AgentConversation copyWith({
    String? title,
    DateTime? updatedAt,
    List<AgentMessage>? messages,
  }) => AgentConversation(
    id: id,
    title: title ?? this.title,
    createdAt: createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    messages: messages ?? this.messages,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'createdAt': createdAt.toUtc().toIso8601String(),
    'updatedAt': updatedAt.toUtc().toIso8601String(),
    'messages': messages.map((message) => message.toJson()).toList(),
  };

  factory AgentConversation.fromJson(Map<String, dynamic> json) {
    return AgentConversation(
      id: json['id'] as String,
      title: json['title'] as String? ?? '',
      createdAt: DateTime.parse(json['createdAt'] as String).toLocal(),
      updatedAt: DateTime.parse(json['updatedAt'] as String).toLocal(),
      messages: (json['messages'] as List? ?? const [])
          .map((item) => AgentMessage.fromJson((item as Map).cast()))
          .toList(),
    );
  }
}

class AgentMutationChange {
  const AgentMutationChange({
    required this.path,
    required this.before,
    required this.after,
  });

  final String path;
  final String before;
  final String after;

  Map<String, dynamic> toJson() => {
    'path': path,
    'before': before,
    'after': after,
  };

  factory AgentMutationChange.fromJson(Map<String, dynamic> json) =>
      AgentMutationChange(
        path: json['path'] as String,
        before: json['before'] as String? ?? '',
        after: json['after'] as String? ?? '',
      );
}

class AgentMutationProposal {
  const AgentMutationProposal({
    required this.operationId,
    required this.toolName,
    required this.title,
    required this.summary,
    required this.argumentsJson,
    required this.targetType,
    required this.targetId,
    required this.expectedDigest,
    required this.changes,
    required this.createdAt,
    this.progressionEffect,
    this.status = AgentProposalStatus.pending,
  });

  final String operationId;
  final String toolName;
  final String title;
  final String summary;
  final String argumentsJson;
  final String targetType;
  final String targetId;
  final String expectedDigest;
  final List<AgentMutationChange> changes;
  final DateTime createdAt;
  final String? progressionEffect;
  final AgentProposalStatus status;

  AgentMutationProposal copyWith({AgentProposalStatus? status}) =>
      AgentMutationProposal(
        operationId: operationId,
        toolName: toolName,
        title: title,
        summary: summary,
        argumentsJson: argumentsJson,
        targetType: targetType,
        targetId: targetId,
        expectedDigest: expectedDigest,
        changes: changes,
        createdAt: createdAt,
        progressionEffect: progressionEffect,
        status: status ?? this.status,
      );

  Map<String, dynamic> toJson() => {
    'operationId': operationId,
    'toolName': toolName,
    'title': title,
    'summary': summary,
    'argumentsJson': argumentsJson,
    'targetType': targetType,
    'targetId': targetId,
    'expectedDigest': expectedDigest,
    'changes': changes.map((change) => change.toJson()).toList(),
    'createdAt': createdAt.toUtc().toIso8601String(),
    'progressionEffect': progressionEffect,
    'status': status.name,
  };

  factory AgentMutationProposal.fromJson(Map<String, dynamic> json) =>
      AgentMutationProposal(
        operationId: json['operationId'] as String,
        toolName: json['toolName'] as String,
        title: json['title'] as String,
        summary: json['summary'] as String? ?? '',
        argumentsJson: json['argumentsJson'] as String? ?? '{}',
        targetType: json['targetType'] as String,
        targetId: json['targetId'] as String? ?? '',
        expectedDigest: json['expectedDigest'] as String? ?? '',
        changes: (json['changes'] as List? ?? const [])
            .map((item) => AgentMutationChange.fromJson((item as Map).cast()))
            .toList(),
        createdAt: DateTime.parse(json['createdAt'] as String).toLocal(),
        progressionEffect: json['progressionEffect'] as String?,
        status: AgentProposalStatus.values.byName(
          json['status'] as String? ?? AgentProposalStatus.pending.name,
        ),
      );
}

class AgentActionRecord {
  const AgentActionRecord({
    required this.id,
    required this.ownerUserId,
    required this.toolName,
    required this.title,
    required this.targetType,
    required this.targetId,
    required this.beforeJson,
    required this.afterJson,
    required this.afterDigest,
    required this.createdAt,
    this.undoneAt,
    this.status = AgentActionStatus.applied,
  });

  final String id;
  final String? ownerUserId;
  final String toolName;
  final String title;
  final String targetType;
  final String targetId;
  final String beforeJson;
  final String afterJson;
  final String afterDigest;
  final DateTime createdAt;
  final DateTime? undoneAt;
  final AgentActionStatus status;

  AgentActionRecord copyWith({AgentActionStatus? status, DateTime? undoneAt}) =>
      AgentActionRecord(
        id: id,
        ownerUserId: ownerUserId,
        toolName: toolName,
        title: title,
        targetType: targetType,
        targetId: targetId,
        beforeJson: beforeJson,
        afterJson: afterJson,
        afterDigest: afterDigest,
        createdAt: createdAt,
        undoneAt: undoneAt ?? this.undoneAt,
        status: status ?? this.status,
      );

  Map<String, dynamic> toJson() => {
    'id': id,
    'ownerUserId': ownerUserId,
    'toolName': toolName,
    'title': title,
    'targetType': targetType,
    'targetId': targetId,
    'beforeJson': beforeJson,
    'afterJson': afterJson,
    'afterDigest': afterDigest,
    'createdAt': createdAt.toUtc().toIso8601String(),
    'undoneAt': undoneAt?.toUtc().toIso8601String(),
    'status': status.name,
  };

  factory AgentActionRecord.fromJson(Map<String, dynamic> json) =>
      AgentActionRecord(
        id: json['id'] as String,
        ownerUserId: json['ownerUserId'] as String?,
        toolName: json['toolName'] as String,
        title: json['title'] as String,
        targetType: json['targetType'] as String,
        targetId: json['targetId'] as String? ?? '',
        beforeJson: json['beforeJson'] as String? ?? 'null',
        afterJson: json['afterJson'] as String? ?? 'null',
        afterDigest: json['afterDigest'] as String? ?? '',
        createdAt: DateTime.parse(json['createdAt'] as String).toLocal(),
        undoneAt: json['undoneAt'] == null
            ? null
            : DateTime.parse(json['undoneAt'] as String).toLocal(),
        status: AgentActionStatus.values.byName(
          json['status'] as String? ?? AgentActionStatus.applied.name,
        ),
      );
}

class AgentRunState {
  const AgentRunState({
    this.phase = AgentRunPhase.idle,
    this.conversation,
    this.pendingProposal,
    this.activeToolName,
    this.errorMessage,
    this.modelTurns = 0,
    this.toolCalls = 0,
  });

  final AgentRunPhase phase;
  final AgentConversation? conversation;
  final AgentMutationProposal? pendingProposal;
  final String? activeToolName;
  final String? errorMessage;
  final int modelTurns;
  final int toolCalls;

  bool get isBusy => const {
    AgentRunPhase.connecting,
    AgentRunPhase.streaming,
    AgentRunPhase.usingTools,
  }.contains(phase);

  AgentRunState copyWith({
    AgentRunPhase? phase,
    AgentConversation? conversation,
    AgentMutationProposal? pendingProposal,
    String? activeToolName,
    String? errorMessage,
    int? modelTurns,
    int? toolCalls,
    bool clearProposal = false,
    bool clearTool = false,
    bool clearError = false,
  }) => AgentRunState(
    phase: phase ?? this.phase,
    conversation: conversation ?? this.conversation,
    pendingProposal: clearProposal
        ? null
        : pendingProposal ?? this.pendingProposal,
    activeToolName: clearTool ? null : activeToolName ?? this.activeToolName,
    errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    modelTurns: modelTurns ?? this.modelTurns,
    toolCalls: toolCalls ?? this.toolCalls,
  );
}

String canonicalJson(Object? value) {
  Object? sort(Object? current) {
    if (current is Map) {
      final keys = current.keys.map((key) => key.toString()).toList()..sort();
      return {for (final key in keys) key: sort(current[key])};
    }
    if (current is List) return current.map(sort).toList();
    return current;
  }

  return jsonEncode(sort(value));
}

String agentPayloadDigest(Object? value) {
  final input = utf8.encode(canonicalJson(value));
  // Fixed-width arithmetic keeps digests identical on Dart VM and Web.
  // This is a concurrency fingerprint, not a cryptographic secret hash.
  var hash = 0x811c9dc5;
  for (final byte in input) {
    hash ^= byte;
    hash = (hash * 0x01000193) & 0xffffffff;
  }
  return hash.toRadixString(16).padLeft(8, '0');
}

String redactAgentSecrets(String input, {Iterable<String> secrets = const []}) {
  var value = input;
  for (final secret in secrets) {
    if (secret.trim().isNotEmpty) {
      value = value.replaceAll(secret, '[REDACTED]');
    }
  }
  value = value.replaceAll(
    RegExp(r'Bearer\s+[A-Za-z0-9._~+/=-]+', caseSensitive: false),
    'Bearer [REDACTED]',
  );
  value = value.replaceAllMapped(
    RegExp(r'("(?:apiKey|api_key)"\s*:\s*")[^"]+("\s*)', caseSensitive: false),
    (match) => '${match.group(1)}[REDACTED]${match.group(2)}',
  );
  return value;
}

abstract final class AgentRunLimits {
  static const maxModelTurns = 8;
  static const maxToolCalls = 12;
  static const maxConversationMessages = 120;
  static const maxProviderResponseBytes = 8 * 1024 * 1024;
  static const maxActionSnapshotBytes = 2 * 1024 * 1024;
  static const maxRawRows = 100;
  static const maxStoredActions = 100;
}
