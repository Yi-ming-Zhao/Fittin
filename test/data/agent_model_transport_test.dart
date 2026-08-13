import 'dart:async';
import 'dart:convert';

import 'package:fittin_v2/src/application/agent_chat_protocol.dart';
import 'package:fittin_v2/src/data/remote/agent_model_transport.dart';
import 'package:fittin_v2/src/domain/models/agent_models.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

void main() {
  const config = AgentProviderConfig(
    baseUrl: 'https://provider.example/v1',
    model: 'test-model',
    hasApiKey: true,
  );
  const request = AgentChatCompletionRequest(
    model: 'test-model',
    messages: [AgentChatMessagePayload(role: 'user', content: 'Hi')],
  );

  test(
    'native transport sends direct bearer request and streams events',
    () async {
      late http.BaseRequest captured;
      final client = _StreamingClient((outgoing) async {
        captured = outgoing;
        return http.StreamedResponse(
          Stream.value(
            utf8.encode(
              'data: {"choices":[{"delta":{"content":"Hi"},'
              '"finish_reason":"stop"}]}\n\n',
            ),
          ),
          200,
          headers: {'content-type': 'text/event-stream'},
        );
      });
      final transport = NativeAgentModelTransport(client: client);

      final events = await transport
          .stream(config: config, apiKey: 'secret-key', request: request)
          .toList();

      expect(
        captured.url.toString(),
        'https://provider.example/v1/chat/completions',
      );
      expect(captured.headers['authorization'], 'Bearer secret-key');
      expect(events.whereType<AgentTextDelta>().single.text, 'Hi');
    },
  );

  test('Web relay uses the authenticated relay envelope', () async {
    late http.Request captured;
    final client = _StreamingClient((outgoing) async {
      captured = outgoing as http.Request;
      return http.StreamedResponse(
        Stream.value(
          utf8.encode(
            '{"choices":[{"message":{"content":"ok"},'
            '"finish_reason":"stop"}]}',
          ),
        ),
        200,
        headers: {'content-type': 'application/json'},
      );
    });
    final transport = WebRelayAgentModelTransport(
      backendBaseUrl: 'https://fittin.example/api/',
      accessTokenLoader: () async => 'fittin-session',
      client: client,
    );

    await transport
        .stream(config: config, apiKey: 'provider-key', request: request)
        .toList();

    expect(
      captured.url.toString(),
      'https://fittin.example/api/v1/agent/chat-completions',
    );
    expect(captured.headers['authorization'], 'Bearer fittin-session');
    final envelope = jsonDecode(captured.body) as Map<String, dynamic>;
    expect(envelope['providerBaseUrl'], 'https://provider.example/v1');
    expect(envelope['apiKey'], 'provider-key');
    expect((envelope['payload'] as Map)['model'], 'test-model');
  });

  test('cancellation aborts an in-flight request', () async {
    final token = AgentCancellationToken();
    final client = _StreamingClient((request) async {
      final abortable = request as http.AbortableRequest;
      await abortable.abortTrigger;
      throw http.RequestAbortedException(request.url);
    });
    final transport = NativeAgentModelTransport(client: client);

    final result = transport
        .stream(
          config: config,
          apiKey: 'secret-key',
          request: request,
          cancellationToken: token,
        )
        .toList();
    await Future<void>.delayed(Duration.zero);
    token.cancel();

    await expectLater(result, throwsA(isA<AgentRequestCancelledException>()));
  });

  test('request deadline aborts and returns a stable timeout', () async {
    final client = _StreamingClient((request) async {
      final abortable = request as http.AbortableRequest;
      await abortable.abortTrigger;
      throw http.RequestAbortedException(request.url);
    });
    final transport = NativeAgentModelTransport(
      client: client,
      timeout: const Duration(milliseconds: 1),
    );

    await expectLater(
      transport
          .stream(config: config, apiKey: 'secret-key', request: request)
          .toList(),
      throwsA(
        isA<AgentTransportException>().having(
          (error) => error.code,
          'code',
          'request_timeout',
        ),
      ),
    );
  });

  test('redacts API keys and bounds provider errors', () async {
    final longMessage = 'secret-key ${List.filled(700, 'x').join()}';
    final client = _StreamingClient((request) async {
      return http.StreamedResponse(
        Stream.value(
          utf8.encode(
            jsonEncode({
              'error': {'code': 'invalid_api_key', 'message': longMessage},
            }),
          ),
        ),
        401,
        headers: {'content-type': 'application/json'},
      );
    });
    final transport = NativeAgentModelTransport(client: client);

    await expectLater(
      transport
          .stream(config: config, apiKey: 'secret-key', request: request)
          .toList(),
      throwsA(
        isA<AgentTransportException>()
            .having(
              (error) => error.message,
              'message',
              isNot(contains('secret-key')),
            )
            .having(
              (error) => error.message.length,
              'bounded length',
              lessThanOrEqualTo(501),
            ),
      ),
    );
  });

  test('maps rate limits and gateway failures without exposing HTML', () async {
    for (final entry in const [
      (429, 'provider_rate_limited'),
      (503, 'provider_unavailable'),
    ]) {
      final client = _StreamingClient((request) async {
        return http.StreamedResponse(
          Stream.value(utf8.encode('<html>private gateway details</html>')),
          entry.$1,
          headers: {'content-type': 'text/html'},
        );
      });
      final transport = NativeAgentModelTransport(client: client);

      await expectLater(
        transport
            .stream(config: config, apiKey: 'secret-key', request: request)
            .toList(),
        throwsA(
          isA<AgentTransportException>()
              .having((error) => error.code, 'code', entry.$2)
              .having(
                (error) => error.message,
                'message',
                isNot(contains('private gateway')),
              ),
        ),
      );
    }
  });

  test(
    'rejects a provider response larger than the configured limit',
    () async {
      final client = _StreamingClient((request) async {
        return http.StreamedResponse(
          Stream.value(utf8.encode('{"choices":[]}'.padRight(128, 'x'))),
          200,
          headers: {'content-type': 'application/json'},
        );
      });
      final transport = NativeAgentModelTransport(
        client: client,
        maxResponseBytes: 32,
      );

      await expectLater(
        transport
            .stream(config: config, apiKey: 'secret-key', request: request)
            .toList(),
        throwsA(
          isA<AgentTransportException>().having(
            (error) => error.code,
            'code',
            'provider_response_too_large',
          ),
        ),
      );
    },
  );

  test('Web relay requires a Fittin session before sending', () async {
    var requests = 0;
    final client = _StreamingClient((request) async {
      requests += 1;
      return http.StreamedResponse(Stream.empty(), 200);
    });
    final transport = WebRelayAgentModelTransport(
      backendBaseUrl: 'https://fittin.example',
      accessTokenLoader: () async => null,
      client: client,
    );

    await expectLater(
      transport
          .stream(config: config, apiKey: 'provider-key', request: request)
          .toList(),
      throwsA(
        isA<AgentTransportException>().having(
          (error) => error.code,
          'code',
          'relay_auth_required',
        ),
      ),
    );
    expect(requests, 0);
  });

  test('normalizes Base URLs and rejects unsafe URL shapes', () {
    expect(
      agentChatCompletionsUri('https://example.test/openai/v1/').toString(),
      'https://example.test/openai/v1/chat/completions',
    );
    expect(
      () => normalizeAgentProviderBaseUrl('http://example.test/v1'),
      throwsFormatException,
    );
    expect(
      () => normalizeAgentProviderBaseUrl('https://user@example.test/v1'),
      throwsFormatException,
    );
    expect(
      () => normalizeAgentProviderBaseUrl('https://example.test/v1?'),
      throwsFormatException,
    );
    expect(
      normalizeAgentProviderBaseUrl(
        'http://127.0.0.1:8080/v1',
        allowDebugLoopbackHttp: true,
      ).scheme,
      'http',
    );
  });
}

class _StreamingClient extends http.BaseClient {
  _StreamingClient(this.handler);

  final Future<http.StreamedResponse> Function(http.BaseRequest request)
  handler;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    if (request is http.Request) await request.finalize().drain<void>();
    return handler(request);
  }
}
