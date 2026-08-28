import 'dart:async';
import 'dart:convert';

/// A single OpenAI-compatible Chat Completions message.
class AgentChatMessagePayload {
  const AgentChatMessagePayload({
    required this.role,
    this.content,
    this.name,
    this.toolCallId,
    this.toolCalls = const [],
    this.reasoningContent,
  });

  final String role;
  final String? content;
  final String? name;
  final String? toolCallId;
  final List<Map<String, dynamic>> toolCalls;
  final String? reasoningContent;

  Map<String, dynamic> toJson({bool includeReasoningContent = false}) => {
    'role': role,
    if (content != null) 'content': content,
    if (name != null) 'name': name,
    if (toolCallId != null) 'tool_call_id': toolCallId,
    if (toolCalls.isNotEmpty) 'tool_calls': toolCalls,
    if (includeReasoningContent && role == 'assistant')
      'reasoning_content': reasoningContent ?? '',
  };
}

class AgentChatToolDefinition {
  const AgentChatToolDefinition({
    required this.name,
    required this.description,
    required this.parameters,
  });

  final String name;
  final String description;
  final Map<String, dynamic> parameters;

  Map<String, dynamic> toJson() => {
    'type': 'function',
    'function': {
      'name': name,
      'description': description,
      'parameters': parameters,
    },
  };
}

/// Common-subset request accepted by OpenAI-compatible Chat Completions APIs.
class AgentChatCompletionRequest {
  const AgentChatCompletionRequest({
    required this.model,
    required this.messages,
    this.tools = const [],
    this.toolChoice,
    this.stream = true,
    this.temperature,
    this.maxCompletionTokens,
  });

  final String model;
  final List<AgentChatMessagePayload> messages;
  final List<AgentChatToolDefinition> tools;
  final Object? toolChoice;
  final bool stream;
  final double? temperature;
  final int? maxCompletionTokens;

  Map<String, dynamic> toJson({bool includeReasoningContent = false}) => {
    'model': model,
    'messages': messages
        .map(
          (message) =>
              message.toJson(includeReasoningContent: includeReasoningContent),
        )
        .toList(),
    'stream': stream,
    if (tools.isNotEmpty)
      'tools': tools.map((definition) => definition.toJson()).toList(),
    if (toolChoice != null) 'tool_choice': toolChoice,
    if (temperature != null) 'temperature': temperature,
    if (maxCompletionTokens != null)
      'max_completion_tokens': maxCompletionTokens,
  };
}

sealed class AgentModelEvent {
  const AgentModelEvent();
}

class AgentTextDelta extends AgentModelEvent {
  const AgentTextDelta(this.text);

  final String text;
}

/// Provider continuation metadata, never visible chat text.
class AgentReasoningDelta extends AgentModelEvent {
  const AgentReasoningDelta(this.text);

  final String text;
}

/// A fragment of one tool call. Callers assemble fragments by [index].
class AgentToolCallDelta extends AgentModelEvent {
  const AgentToolCallDelta({
    required this.index,
    this.id,
    this.name,
    this.argumentsDelta = '',
  });

  final int index;
  final String? id;
  final String? name;
  final String argumentsDelta;
}

class AgentModelCompleted extends AgentModelEvent {
  const AgentModelCompleted({this.finishReason});

  final String? finishReason;
}

class AgentModelFailure extends AgentModelEvent {
  const AgentModelFailure({required this.code, required this.message});

  final String code;
  final String message;
}

class AgentProtocolException implements Exception {
  const AgentProtocolException(this.message, {this.code = 'invalid_response'});

  final String code;
  final String message;

  @override
  String toString() => message;
}

/// Parses either a streamed SSE response or a normal JSON response.
///
/// UTF-8 decoding happens before SSE line splitting so a multi-byte code point
/// may be fragmented across arbitrary network chunks without corruption.
Stream<AgentModelEvent> parseAgentChatCompletionResponse(
  Stream<List<int>> body, {
  required String? contentType,
  int maxJsonBytes = 1024 * 1024,
  int maxSseEventCharacters = 1024 * 1024,
}) async* {
  final normalizedType = (contentType ?? '').toLowerCase();
  if (normalizedType.contains('text/event-stream')) {
    var emittedCompletion = false;
    var emittedFailure = false;
    await for (final data in _decodeSseData(
      body,
      maxEventCharacters: maxSseEventCharacters,
    )) {
      if (data.trim() == '[DONE]') {
        if (!emittedCompletion) {
          emittedCompletion = true;
          yield const AgentModelCompleted();
        }
        continue;
      }
      final payload = _decodeObject(data);
      for (final event in _eventsFromPayload(payload)) {
        if (event is AgentModelCompleted) emittedCompletion = true;
        if (event is AgentModelFailure) emittedFailure = true;
        yield event;
      }
    }
    if (!emittedCompletion && !emittedFailure) {
      yield const AgentModelCompleted();
    }
    return;
  }

  final bytes = <int>[];
  await for (final chunk in body) {
    if (bytes.length + chunk.length > maxJsonBytes) {
      throw const AgentProtocolException(
        'The model response exceeded the allowed size.',
        code: 'response_too_large',
      );
    }
    bytes.addAll(chunk);
  }
  final payload = _decodeObject(utf8.decode(bytes));
  var emittedCompletion = false;
  var emittedFailure = false;
  for (final event in _eventsFromPayload(payload)) {
    if (event is AgentModelCompleted) emittedCompletion = true;
    if (event is AgentModelFailure) emittedFailure = true;
    yield event;
  }
  if (!emittedCompletion && !emittedFailure) yield const AgentModelCompleted();
}

Map<String, dynamic> _decodeObject(String source) {
  final Object? decoded;
  try {
    decoded = jsonDecode(source);
  } on FormatException {
    throw const AgentProtocolException(
      'The model returned invalid JSON.',
      code: 'invalid_json',
    );
  }
  if (decoded is! Map) {
    throw const AgentProtocolException(
      'The model returned an invalid response.',
    );
  }
  return decoded.cast<String, dynamic>();
}

Iterable<AgentModelEvent> _eventsFromPayload(
  Map<String, dynamic> payload,
) sync* {
  final error = payload['error'];
  if (error != null) {
    final errorMap = error is Map ? error.cast<String, dynamic>() : payload;
    yield AgentModelFailure(
      code: _boundedString(errorMap['code'], fallback: 'provider_error'),
      message: _boundedString(
        errorMap['message'] ?? error,
        fallback: 'The model provider rejected the request.',
      ),
    );
    return;
  }

  final choices = payload['choices'];
  if (choices is List && choices.isEmpty && payload['usage'] is Map) {
    return;
  }
  if (choices is! List || choices.isEmpty || choices.first is! Map) {
    throw const AgentProtocolException(
      'The model response did not contain a completion choice.',
    );
  }
  final choice = (choices.first as Map).cast<String, dynamic>();
  final rawMessage = choice['delta'] ?? choice['message'];
  if (rawMessage is Map) {
    final message = rawMessage.cast<String, dynamic>();
    final reasoning = message['reasoning_content'];
    if (reasoning is String) yield AgentReasoningDelta(reasoning);
    final content = _textContent(message['content']);
    if (content.isNotEmpty) yield AgentTextDelta(content);

    final toolCalls = message['tool_calls'];
    if (toolCalls is List) {
      for (var position = 0; position < toolCalls.length; position += 1) {
        final rawCall = toolCalls[position];
        if (rawCall is! Map) continue;
        final call = rawCall.cast<String, dynamic>();
        final function = call['function'] is Map
            ? (call['function'] as Map).cast<String, dynamic>()
            : const <String, dynamic>{};
        yield AgentToolCallDelta(
          index: call['index'] is int ? call['index'] as int : position,
          id: _optionalString(call['id']),
          name: _optionalString(function['name']),
          argumentsDelta: function['arguments'] is String
              ? function['arguments'] as String
              : '',
        );
      }
    } else if (message['function_call'] is Map) {
      // Tolerate the legacy single-function-call dialect used by a few
      // OpenAI-compatible endpoints.
      final function = (message['function_call'] as Map)
          .cast<String, dynamic>();
      yield AgentToolCallDelta(
        index: 0,
        name: _optionalString(function['name']),
        argumentsDelta: function['arguments'] is String
            ? function['arguments'] as String
            : '',
      );
    }
  }

  final finishReason = _optionalString(choice['finish_reason']);
  if (finishReason != null) {
    yield AgentModelCompleted(finishReason: finishReason);
  }
}

String _textContent(Object? content) {
  if (content is String) return content;
  if (content is! List) return '';
  return content
      .whereType<Map>()
      .map((part) => part['text'])
      .whereType<String>()
      .join();
}

String? _optionalString(Object? value) {
  if (value is! String || value.isEmpty) return null;
  return value;
}

String _boundedString(Object? value, {required String fallback}) {
  final text = value?.toString().trim() ?? '';
  if (text.isEmpty) return fallback;
  return text.length <= 500 ? text : '${text.substring(0, 500)}…';
}

Stream<String> _decodeSseData(
  Stream<List<int>> bytes, {
  required int maxEventCharacters,
}) async* {
  var lineBuffer = '';
  final dataLines = <String>[];
  var eventCharacters = 0;

  Iterable<String> consumeLine(String line) sync* {
    final normalized = line.endsWith('\r')
        ? line.substring(0, line.length - 1)
        : line;
    if (normalized.isEmpty) {
      if (dataLines.isNotEmpty) {
        yield dataLines.join('\n');
        dataLines.clear();
        eventCharacters = 0;
      }
      return;
    }
    if (normalized.startsWith(':')) return;
    if (normalized == 'data') {
      dataLines.add('');
    } else if (normalized.startsWith('data:')) {
      var value = normalized.substring(5);
      if (value.startsWith(' ')) value = value.substring(1);
      eventCharacters += value.length;
      if (eventCharacters > maxEventCharacters) {
        throw const AgentProtocolException(
          'The model stream event exceeded the allowed size.',
          code: 'response_too_large',
        );
      }
      dataLines.add(value);
    }
  }

  await for (final textChunk in bytes.transform(const Utf8Decoder())) {
    lineBuffer += textChunk;
    var newline = lineBuffer.indexOf('\n');
    while (newline >= 0) {
      final line = lineBuffer.substring(0, newline);
      lineBuffer = lineBuffer.substring(newline + 1);
      for (final data in consumeLine(line)) {
        yield data;
      }
      newline = lineBuffer.indexOf('\n');
    }
    if (lineBuffer.length > maxEventCharacters) {
      throw const AgentProtocolException(
        'The model stream event exceeded the allowed size.',
        code: 'response_too_large',
      );
    }
  }
  if (lineBuffer.isNotEmpty) {
    for (final data in consumeLine(lineBuffer)) {
      yield data;
    }
  }
  if (dataLines.isNotEmpty) yield dataLines.join('\n');
}
