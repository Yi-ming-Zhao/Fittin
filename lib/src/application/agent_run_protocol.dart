import 'dart:convert';

import '../domain/models/agent_models.dart';
import 'agent_chat_protocol.dart';
import 'agent_tools.dart';

/// Provider-neutral turn assembly. Like pi agent-core, completion and tool
/// execution are separate: syntactically valid arguments can still be cut off.
class AgentTurnAccumulator {
  final _calls = <int, _ToolFragments>{};
  bool completed = false;
  String? finishReason;

  void add(AgentModelEvent event) {
    if (event is AgentToolCallDelta) {
      _calls.putIfAbsent(event.index, _ToolFragments.new).add(event);
    } else if (event is AgentModelCompleted) {
      completed = true;
      finishReason = event.finishReason ?? finishReason;
    }
  }

  bool get truncated => finishReason == 'length';

  List<AgentToolCall> finish({required String messageId, required String key}) {
    if (!completed) {
      throw const AgentProtocolException(
        'The model response was interrupted. Retry to continue.',
        code: 'incomplete_response',
      );
    }
    if (finishReason == 'content_filter' || finishReason == 'error') {
      throw const AgentProtocolException(
        'The provider stopped the response without completing it.',
        code: 'provider_stopped',
      );
    }
    final indices = _calls.keys.toList()..sort();
    return [
      for (final index in indices)
        AgentToolCall(
          id: _calls[index]!.id ?? '$messageId-tool-$index',
          name: _calls[index]!.name,
          argumentsJson: redactAgentSecrets(
            _calls[index]!.arguments.isEmpty ? '{}' : _calls[index]!.arguments,
            secrets: [key],
          ),
        ),
    ];
  }
}

class _ToolFragments {
  String? id;
  String name = '';
  String arguments = '';

  void add(AgentToolCallDelta delta) {
    id ??= delta.id;
    name += delta.name ?? '';
    arguments += delta.argumentsDelta;
  }
}

AgentToolResult agentToolError(String code, String message) => AgentToolResult(
  isError: true,
  payload: {
    'error': {'code': code, 'message': message},
    'executed': false,
  },
);

/// Invalid arguments and local tool errors are model-visible outcomes, not
/// transport failures. No attempt is made to salvage incomplete write JSON.
Future<AgentToolResult> executeAgentToolCall(
  AgentToolCall call,
  AgentToolRegistry registry, {
  required bool truncated,
}) async {
  if (truncated) {
    return agentToolError(
      'truncated_arguments',
      'Output hit the token limit. No tool in this response was executed. '
          'Reissue smaller complete calls; for plan revisions use edits, not a full plan.',
    );
  }
  Map<String, dynamic> args;
  try {
    final decoded = jsonDecode(call.argumentsJson);
    if (decoded is! Map<String, dynamic>) throw const FormatException();
    args = decoded;
  } on FormatException {
    return agentToolError(
      'invalid_arguments',
      'Arguments must be a complete JSON object. Reissue the call with valid '
          'JSON; for plan revisions use small edits after reading get_plan.',
    );
  }
  try {
    return await registry.execute(call.name, args);
  } catch (_) {
    return agentToolError(
      'tool_failed',
      'The local tool could not complete. Read the target again and correct the call.',
    );
  }
}

/// Repairs legacy/mid-batch histories for strict chat-completions providers.
/// Unmatched results are discarded; unexecuted calls are explicitly closed.
List<AgentMessage> completeAgentToolHistory(
  List<AgentMessage> messages, {
  String skippedReason =
      'Run stopped before this tool completed. No result is available; read again before making changes.',
  bool keepPartialText = true,
}) {
  final output = <AgentMessage>[];
  for (var i = 0; i < messages.length; i++) {
    final message = messages[i];
    if (message.role == AgentMessageRole.tool) continue;
    if (message.isPartial) {
      if (keepPartialText && message.content.trim().isNotEmpty) {
        output.add(message);
      }
      continue;
    }
    if (message.role == AgentMessageRole.assistant &&
        message.content.trim().isEmpty &&
        message.toolCalls.isEmpty) {
      continue;
    }
    output.add(message);
    if (message.toolCalls.isEmpty) continue;
    final results = <String, AgentMessage>{};
    while (i + 1 < messages.length &&
        messages[i + 1].role == AgentMessageRole.tool) {
      final result = messages[++i];
      if (result.toolCallId != null) results[result.toolCallId!] = result;
    }
    for (final call in message.toolCalls) {
      output.add(
        results[call.id] ??
            AgentMessage(
              id: '${message.id}-skipped-${call.id}',
              role: AgentMessageRole.tool,
              toolCallId: call.id,
              content: agentToolError('not_executed', skippedReason).encoded,
              createdAt: message.createdAt,
            ),
      );
    }
  }
  return output;
}
