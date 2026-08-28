import 'dart:convert';

import 'package:fittin_v2/src/application/agent_chat_protocol.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('SSE EOF without completion is an interruption, not success', () async {
    final stream = parseAgentChatCompletionResponse(
      Stream.value(
        utf8.encode('data: {"choices":[{"delta":{"content":"partial"}}]}\n\n'),
      ),
      contentType: 'text/event-stream',
    );
    await expectLater(
      stream,
      emitsInOrder([
        isA<AgentTextDelta>(),
        emitsError(
          isA<AgentProtocolException>().having(
            (e) => e.code,
            'code',
            'incomplete_response',
          ),
        ),
        emitsDone,
      ]),
    );
  });

  test('encodes the common Chat Completions tool contract', () {
    final request = AgentChatCompletionRequest(
      model: 'gpt-compatible',
      messages: const [
        AgentChatMessagePayload(role: 'user', content: 'Analyze my week'),
      ],
      tools: const [
        AgentChatToolDefinition(
          name: 'training_summary',
          description: 'Reads a bounded summary.',
          parameters: {'type': 'object', 'properties': <String, dynamic>{}},
        ),
      ],
    ).toJson();

    expect(request['model'], 'gpt-compatible');
    expect(request['stream'], isTrue);
    expect((request['tools'] as List).single, {
      'type': 'function',
      'function': {
        'name': 'training_summary',
        'description': 'Reads a bounded summary.',
        'parameters': {'type': 'object', 'properties': <String, dynamic>{}},
      },
    });
  });

  test('parses fragmented UTF-8 SSE and assembles tool call deltas', () async {
    final source = [
      'data: {"choices":[{"delta":{"content":"训练 💪"},',
      '"finish_reason":null}]}\n\n',
      'data: {"choices":[{"delta":{"tool_calls":[{"index":0,',
      '"id":"call_1","function":{"name":"modify_",',
      '"arguments":"{\\"week\\":"}}]},"finish_reason":null}]}\n\n',
      'data: {"choices":[{"delta":{"tool_calls":[{"index":0,',
      '"function":{"name":"plan","arguments":"3}"}}]},',
      '"finish_reason":"tool_calls"}]}\n\n',
      'data: [DONE]\n\n',
    ].join();
    final bytes = utf8.encode(source);
    final chunks = <List<int>>[];
    for (var index = 0; index < bytes.length;) {
      final length = (index % 7) + 1;
      final end = (index + length).clamp(0, bytes.length);
      chunks.add(bytes.sublist(index, end));
      index = end;
    }

    final events = await parseAgentChatCompletionResponse(
      Stream<List<int>>.fromIterable(chunks),
      contentType: 'text/event-stream; charset=utf-8',
    ).toList();

    expect(events.whereType<AgentTextDelta>().single.text, '训练 💪');
    final toolDeltas = events.whereType<AgentToolCallDelta>().toList();
    expect(
      toolDeltas.map((event) => event.name).whereType<String>().join(),
      'modify_plan',
    );
    expect(
      toolDeltas.map((event) => event.argumentsDelta).join(),
      '{"week":3}',
    );
    expect(toolDeltas.first.id, 'call_1');
    expect(
      events.whereType<AgentModelCompleted>().last.finishReason,
      'tool_calls',
    );
  });

  test('supports normal JSON when streaming is ignored by provider', () async {
    final body = utf8.encode(
      jsonEncode({
        'choices': [
          {
            'message': {
              'role': 'assistant',
              'content': 'Ready',
              'tool_calls': [
                {
                  'id': 'call_ping',
                  'type': 'function',
                  'function': {'name': 'ping', 'arguments': '{}'},
                },
              ],
            },
            'finish_reason': 'tool_calls',
          },
        ],
      }),
    );

    final events = await parseAgentChatCompletionResponse(
      Stream.value(body),
      contentType: 'application/json',
    ).toList();

    expect(events.whereType<AgentTextDelta>().single.text, 'Ready');
    expect(events.whereType<AgentToolCallDelta>().single.name, 'ping');
    expect(
      events.whereType<AgentModelCompleted>().single.finishReason,
      'tool_calls',
    );
  });

  test('accepts CRLF, comments, and multi-line SSE data', () async {
    const body =
        ': keepalive\r\n'
        'event: message\r\n'
        'data: {"choices":[{"delta":{"content":"hello"},\r\n'
        'data: "finish_reason":"stop"}]}\r\n\r\n';

    final events = await parseAgentChatCompletionResponse(
      Stream.value(utf8.encode(body)),
      contentType: 'text/event-stream',
    ).toList();

    expect(events.whereType<AgentTextDelta>().single.text, 'hello');
    expect(events.whereType<AgentModelCompleted>().single.finishReason, 'stop');
  });

  test('rejects oversized JSON fallback before decoding', () async {
    await expectLater(
      parseAgentChatCompletionResponse(
        Stream.value(utf8.encode('{"too":"large"}')),
        contentType: 'application/json',
        maxJsonBytes: 4,
      ).toList(),
      throwsA(
        isA<AgentProtocolException>().having(
          (error) => error.code,
          'code',
          'response_too_large',
        ),
      ),
    );
  });

  test(
    'rejects an oversized SSE event before buffering indefinitely',
    () async {
      await expectLater(
        parseAgentChatCompletionResponse(
          Stream.value(utf8.encode('data: ${List.filled(80, 'x').join()}\n\n')),
          contentType: 'text/event-stream',
          maxSseEventCharacters: 32,
        ).toList(),
        throwsA(
          isA<AgentProtocolException>().having(
            (error) => error.code,
            'code',
            'response_too_large',
          ),
        ),
      );
    },
  );

  test(
    'allows many bounded SSE events delivered in one network chunk',
    () async {
      final chunks = List.generate(
        20,
        (index) =>
            'data: {"choices":[{"delta":{"content":"$index"},'
            '"finish_reason":null}]}\n\n',
      )..add('data: [DONE]\n\n');
      final body = chunks.join();

      final events = await parseAgentChatCompletionResponse(
        Stream.value(utf8.encode(body)),
        contentType: 'text/event-stream',
        maxSseEventCharacters: 96,
      ).toList();

      expect(events.whereType<AgentTextDelta>(), hasLength(20));
    },
  );

  test('uses a top-level stable code for string error payloads', () async {
    final events = await parseAgentChatCompletionResponse(
      Stream.value(
        utf8.encode(
          'data: {"code":"provider_timeout","error":"Timed out"}\n\n',
        ),
      ),
      contentType: 'text/event-stream',
    ).toList();

    final failure = events.whereType<AgentModelFailure>().single;
    expect(failure.code, 'provider_timeout');
    expect(failure.message, 'Timed out');
  });

  test('emits a bounded provider failure without a fake completion', () async {
    final events = await parseAgentChatCompletionResponse(
      Stream.value(
        utf8.encode(
          'data: {"error":{"code":"denied","message":"No access"}}\n\n',
        ),
      ),
      contentType: 'text/event-stream',
    ).toList();

    expect(events, hasLength(1));
    expect(events.single, isA<AgentModelFailure>());
  });
}
