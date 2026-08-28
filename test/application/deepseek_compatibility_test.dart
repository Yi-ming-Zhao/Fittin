import 'dart:convert';

import 'package:fittin_v2/src/application/agent_chat_protocol.dart';
import 'package:fittin_v2/src/application/agent_provider_settings_provider.dart';
import 'package:fittin_v2/src/data/remote/agent_model_transport.dart';
import 'package:fittin_v2/src/domain/models/agent_models.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  const config = AgentProviderConfig(
    baseUrl: 'https://api.deepseek.com/v1',
    model: 'deepseek-reasoner',
    hasApiKey: true,
  );

  test(
    'DeepSeek automatic tool selection passes the real transport test',
    () async {
      final transport = NativeAgentModelTransport(
        client: MockClient((request) async {
          final body = jsonDecode(request.body) as Map;
          if (body['tool_choice'] != 'auto') {
            return http.Response(
              jsonEncode({
                'error': {
                  'message':
                      'deepseek-reasoner does not support this tool_choice',
                  'code': 'invalid_request_error',
                },
              }),
              400,
              headers: {'content-type': 'application/json'},
            );
          }
          return _pingResponse('{}');
        }),
      );
      final result = await AgentConnectionTester(
        transport,
      ).test(config: config, apiKey: 'fake-deepseek-key');

      expect(result.chatCapable, isTrue);
      expect(result.toolCallingSupported, isTrue);
    },
  );

  test('incomplete ping arguments do not mark a provider ready', () async {
    final transport = NativeAgentModelTransport(
      client: MockClient((_) async => _pingResponse('{')),
    );
    final result = await AgentConnectionTester(
      transport,
    ).test(config: config, apiKey: 'fake-deepseek-key');
    expect(result.toolCallingSupported, isFalse);
  });

  test('full DeepSeek endpoint is not appended twice', () {
    for (final base in [
      'https://api.deepseek.com',
      'https://api.deepseek.com/v1',
    ]) {
      expect(
        agentChatCompletionsUri('$base/chat/completions/').toString(),
        '$base/chat/completions',
      );
      expect(
        normalizeAgentProviderBaseUrl('$base/chat/completions').toString(),
        base,
      );
    }
  });

  test('DeepSeek reasoning fragments survive protocol decoding', () async {
    final events = await parseAgentChatCompletionResponse(
      Stream.value(
        utf8.encode(
          'data: {"choices":[{"delta":{"reasoning_content":"Check local records"}}]}\n\n'
          'data: {"choices":[{"delta":{"content":"Done"},"finish_reason":"stop"}]}\n\n'
          'data: [DONE]\n\n',
        ),
      ),
      contentType: 'text/event-stream',
    ).toList();
    expect(
      events.whereType<AgentReasoningDelta>().single.text,
      'Check local records',
    );
    expect(events.whereType<AgentTextDelta>().single.text, 'Done');
  });

  test('local message round trip preserves hidden reasoning metadata', () {
    final message = AgentMessage.fromJson({
      'id': 'assistant-1',
      'role': 'assistant',
      'createdAt': '2026-08-28T00:00:00Z',
      'content': 'Visible answer',
      'reasoningContent': 'Protocol continuation data',
    });
    expect(message.toJson()['reasoningContent'], 'Protocol continuation data');
    expect(message.content, 'Visible answer');
  });

  test(
    'Web relay normalizes endpoint and includes DeepSeek reasoning only',
    () async {
      final captures = <Map>[];
      final transport = WebRelayAgentModelTransport(
        backendBaseUrl: 'https://fittin.example/api',
        accessTokenLoader: () async => 'fittin-session',
        client: MockClient((request) async {
          captures.add(jsonDecode(request.body) as Map);
          return _pingResponse('{}');
        }),
      );
      const request = AgentChatCompletionRequest(
        model: 'deepseek-reasoner',
        messages: [
          AgentChatMessagePayload(
            role: 'assistant',
            content: 'Answer',
            reasoningContent: 'Hidden context',
          ),
        ],
      );
      await transport
          .stream(
            config: config.copyWith(
              baseUrl: '${config.baseUrl}/chat/completions',
            ),
            apiKey: 'fake-key',
            request: request,
          )
          .toList();
      final deepSeek = captures.single;
      expect(deepSeek['providerBaseUrl'], config.baseUrl);
      expect(
        deepSeek['payload']['messages'][0]['reasoning_content'],
        'Hidden context',
      );

      await transport
          .stream(
            config: config.copyWith(
              baseUrl: 'https://other.example/v1',
              model: 'other-model',
            ),
            apiKey: 'fake-key',
            request: request,
          )
          .toList();
      expect(
        (captures.last['payload']['messages'][0] as Map).containsKey(
          'reasoning_content',
        ),
        isFalse,
      );
    },
  );

  test('empty or truncated tool streams never mark a provider ready', () async {
    for (final response in [
      'data: [DONE]\n\n',
      'data: {"choices":[{"delta":{"tool_calls":[{"index":0,"id":"p","function":{"name":"ping","arguments":"{}"}}]}}]}\n\n',
    ]) {
      final request = AgentConnectionTester(
        NativeAgentModelTransport(
          client: MockClient(
            (_) async => http.Response(
              response,
              200,
              headers: {'content-type': 'text/event-stream'},
            ),
          ),
        ),
      ).test(config: config, apiKey: 'fake-key');
      if (response.contains('[DONE]')) {
        expect((await request).toolCallingSupported, isFalse);
      } else {
        await expectLater(
          request,
          throwsA(
            isA<AgentTransportException>().having(
              (e) => e.code,
              'code',
              'incomplete_response',
            ),
          ),
        );
      }
    }
  });
}

http.Response _pingResponse(String arguments) => http.Response(
  'data: ${jsonEncode({
    'choices': [
      {
        'delta': {
          'tool_calls': [
            {
              'index': 0,
              'id': 'call_ping',
              'type': 'function',
              'function': {'name': 'ping', 'arguments': arguments},
            },
          ],
        },
        'finish_reason': 'tool_calls',
      },
    ],
  })}\n\ndata: [DONE]\n\n',
  200,
  headers: {'content-type': 'text/event-stream'},
);
