import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import 'package:fittin_v2/src/application/agent_chat_protocol.dart';
import 'package:fittin_v2/src/application/auth_provider.dart';
import 'package:fittin_v2/src/application/supabase_bootstrap.dart';
import 'package:fittin_v2/src/domain/models/agent_models.dart';

typedef AgentAccessTokenLoader = Future<String?> Function();

class AgentCancellationToken {
  AgentCancellationToken();

  final Completer<void> _cancelled = Completer<void>();

  bool get isCancelled => _cancelled.isCompleted;
  Future<void> get whenCancelled => _cancelled.future;

  void cancel() {
    if (!_cancelled.isCompleted) _cancelled.complete();
  }

  void throwIfCancelled() {
    if (isCancelled) throw const AgentRequestCancelledException();
  }
}

class AgentTransportException implements Exception {
  const AgentTransportException(
    this.message, {
    this.code = 'transport_error',
    this.statusCode,
    this.retryAfter,
  });

  final String code;
  final String message;
  final int? statusCode;
  final Duration? retryAfter;

  @override
  String toString() => message;
}

class AgentRequestCancelledException extends AgentTransportException {
  const AgentRequestCancelledException()
    : super('The model request was cancelled.', code: 'cancelled');
}

abstract interface class AgentModelTransport {
  Stream<AgentModelEvent> stream({
    required AgentProviderConfig config,
    required String apiKey,
    required AgentChatCompletionRequest request,
    AgentCancellationToken? cancellationToken,
  });

  void dispose();
}

/// Explicitly named alias used by orchestration code to distinguish model
/// streaming from local repository streams.
extension AgentModelTransportChat on AgentModelTransport {
  Stream<AgentModelEvent> streamChat({
    required AgentProviderConfig config,
    required String apiKey,
    required AgentChatCompletionRequest request,
    AgentCancellationToken? cancellationToken,
  }) => stream(
    config: config,
    apiKey: apiKey,
    request: request,
    cancellationToken: cancellationToken,
  );
}

class NativeAgentModelTransport extends _HttpAgentModelTransport {
  NativeAgentModelTransport({
    super.client,
    super.timeout,
    super.firstResponseTimeout,
    super.idleTimeout,
    super.maxErrorBytes,
    super.maxResponseBytes,
  });

  @override
  Uri endpointFor(AgentProviderConfig config) {
    return agentChatCompletionsUri(
      config.baseUrl,
      allowDebugLoopbackHttp: !kReleaseMode,
    );
  }

  @override
  Future<Map<String, String>> headersFor(String apiKey) async => {
    'Accept': 'text/event-stream, application/json',
    'Authorization': 'Bearer $apiKey',
    'Content-Type': 'application/json',
  };

  @override
  Map<String, dynamic> bodyFor({
    required AgentProviderConfig config,
    required String apiKey,
    required AgentChatCompletionRequest request,
  }) => _providerRequestBody(config, request);
}

class WebRelayAgentModelTransport extends _HttpAgentModelTransport {
  WebRelayAgentModelTransport({
    required this.backendBaseUrl,
    required this.accessTokenLoader,
    super.client,
    super.timeout,
    super.firstResponseTimeout,
    super.idleTimeout,
    super.maxErrorBytes,
    super.maxResponseBytes,
  });

  final String backendBaseUrl;
  final AgentAccessTokenLoader accessTokenLoader;

  @override
  Uri endpointFor(AgentProviderConfig config) {
    final base = Uri.tryParse(backendBaseUrl.trim());
    if (base == null || !base.hasScheme || base.host.isEmpty) {
      throw const AgentTransportException(
        'Fittin backend is unavailable for Web Agent requests.',
        code: 'relay_unavailable',
      );
    }
    return Uri.parse(
      '${backendBaseUrl.trim().replaceFirst(RegExp(r'/+$'), '')}'
      '/v1/agent/chat-completions',
    );
  }

  @override
  Future<Map<String, String>> headersFor(String apiKey) async {
    final token = await accessTokenLoader();
    if (token == null || token.isEmpty) {
      throw const AgentTransportException(
        'Sign in to use the Agent on Web.',
        code: 'relay_auth_required',
      );
    }
    return {
      'Accept': 'text/event-stream, application/json',
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  @override
  Map<String, dynamic> bodyFor({
    required AgentProviderConfig config,
    required String apiKey,
    required AgentChatCompletionRequest request,
  }) => {
    'providerBaseUrl': normalizeAgentProviderBaseUrl(config.baseUrl).toString(),
    'apiKey': apiKey,
    'payload': _providerRequestBody(config, request),
  };
}

Map<String, dynamic> _providerRequestBody(
  AgentProviderConfig config,
  AgentChatCompletionRequest request,
) {
  // DeepSeek's thinking-mode tool turns require reasoning_content even when
  // the visible answer is empty. Do not send this extension to other APIs.
  final host = Uri.tryParse(config.baseUrl)?.host.toLowerCase();
  final deepSeek =
      host == 'api.deepseek.com' ||
      config.model.toLowerCase().contains('deepseek');
  final body = request.toJson(includeReasoningContent: deepSeek);
  if (deepSeek && body.containsKey('max_completion_tokens')) {
    body['max_tokens'] = body.remove('max_completion_tokens');
  }
  return body;
}

abstract class _HttpAgentModelTransport implements AgentModelTransport {
  _HttpAgentModelTransport({
    http.Client? client,
    this.timeout = const Duration(minutes: 5),
    this.firstResponseTimeout = const Duration(seconds: 45),
    this.idleTimeout = const Duration(seconds: 60),
    this.maxErrorBytes = 32 * 1024,
    this.maxResponseBytes = AgentRunLimits.maxProviderResponseBytes,
  }) : _client = client ?? http.Client(),
       _ownsClient = client == null;

  final http.Client _client;
  final bool _ownsClient;
  final Duration timeout;
  final Duration firstResponseTimeout;
  final Duration idleTimeout;
  final int maxErrorBytes;
  final int maxResponseBytes;

  Uri endpointFor(AgentProviderConfig config);

  Future<Map<String, String>> headersFor(String apiKey);

  Map<String, dynamic> bodyFor({
    required AgentProviderConfig config,
    required String apiKey,
    required AgentChatCompletionRequest request,
  });

  @override
  Stream<AgentModelEvent> stream({
    required AgentProviderConfig config,
    required String apiKey,
    required AgentChatCompletionRequest request,
    AgentCancellationToken? cancellationToken,
  }) async* {
    final token = cancellationToken ?? AgentCancellationToken();
    final watch = Stopwatch()..start();
    for (var attempt = 0; ; attempt++) {
      var observable = false;
      try {
        await for (final event in _streamAttempt(
          config: config,
          apiKey: apiKey,
          request: request,
          cancellationToken: token,
          remaining: timeout - watch.elapsed,
        )) {
          if (event is! AgentResponseMetadata) observable = true;
          yield event;
        }
        return;
      } on AgentTransportException catch (error) {
        final status = error.statusCode;
        final retryable =
            !{
              'provider_auth_failed',
              'provider_rejected',
              'provider_request_rejected',
              'invalid_provider_url',
              'relay_auth_required',
            }.contains(error.code) &&
            (status == 408 ||
                status == 429 ||
                (status != null && status >= 500 && status <= 599));
        if (!request.allowRetries ||
            observable ||
            !retryable ||
            attempt >= 2 ||
            watch.elapsed >= timeout) {
          rethrow;
        }
        final delay =
            error.retryAfter ??
            Duration(
              milliseconds:
                  500 * (1 << attempt) + DateTime.now().millisecond % 200,
            );
        if (delay >= timeout - watch.elapsed) rethrow;
        await Future.any([Future<void>.delayed(delay), token.whenCancelled]);
        token.throwIfCancelled();
      }
    }
  }

  Stream<AgentModelEvent> _streamAttempt({
    required AgentProviderConfig config,
    required String apiKey,
    required AgentChatCompletionRequest request,
    required AgentCancellationToken cancellationToken,
    required Duration remaining,
  }) async* {
    final token = cancellationToken;
    token.throwIfCancelled();
    final trimmedKey = apiKey.trim();
    if (trimmedKey.isEmpty) {
      throw const AgentTransportException(
        'An API key is required.',
        code: 'api_key_required',
      );
    }

    final uri = endpointFor(config);
    final abort = Completer<void>();
    var timedOut = false;
    var timeoutCode = 'request_timeout';
    if (remaining <= Duration.zero) {
      throw const AgentTransportException(
        'The model request timed out.',
        code: 'request_timeout',
      );
    }
    final timeoutTimer = Timer(remaining, () {
      timedOut = true;
      if (!abort.isCompleted) abort.complete();
    });
    unawaited(
      token.whenCancelled.then((_) {
        if (!abort.isCompleted) abort.complete();
      }),
    );

    try {
      final outgoing = http.AbortableRequest(
        'POST',
        uri,
        abortTrigger: abort.future,
      );
      outgoing.headers.addAll(
        await Future.any([
          headersFor(trimmedKey).timeout(
            remaining < firstResponseTimeout ? remaining : firstResponseTimeout,
          ),
          token.whenCancelled.then<Map<String, String>>(
            (_) => throw const AgentRequestCancelledException(),
          ),
        ]),
      );
      token.throwIfCancelled();
      outgoing.body = jsonEncode(
        bodyFor(config: config, apiKey: trimmedKey, request: request),
      );
      if (utf8.encode(outgoing.body).length > 512 * 1024) {
        throw const AgentTransportException(
          'The context is too large. Read smaller pages or start a focused task.',
          code: 'request_too_large',
        );
      }

      final response = await _client
          .send(outgoing)
          .timeout(
            firstResponseTimeout,
            onTimeout: () {
              timeoutCode = 'first_byte_timeout';
              timedOut = true;
              if (!abort.isCompleted) abort.complete();
              throw TimeoutException('First response timed out');
            },
          );
      if (response.statusCode < 200 || response.statusCode >= 300) {
        final bytes = await _readBounded(
          response.stream,
          maxErrorBytes,
        ).timeout(idleTimeout);
        throw _errorFromResponse(
          statusCode: response.statusCode,
          bytes: bytes,
          secrets: [trimmedKey],
          retryAfter: _retryAfter(response.headers['retry-after']),
        );
      }

      yield AgentResponseMetadata(
        streaming:
            response.headers['content-type']?.contains('text/event-stream') ==
            true,
      );
      final body = response.stream.timeout(
        idleTimeout,
        onTimeout: (sink) {
          timeoutCode = 'stream_idle_timeout';
          timedOut = true;
          sink.addError(TimeoutException('Stream idle timeout'));
          if (!abort.isCompleted) abort.complete();
        },
      );
      await for (final event in parseAgentChatCompletionResponse(
        _limitResponseBytes(body, maxResponseBytes),
        contentType: response.headers['content-type'],
      )) {
        token.throwIfCancelled();
        if (event is AgentModelFailure) {
          yield AgentModelFailure(
            code: _safeCode(event.code),
            message: _safeMessage(event.message, secrets: [trimmedKey]),
          );
        } else {
          yield event;
        }
      }
    } on AgentRequestCancelledException {
      rethrow;
    } on http.RequestAbortedException {
      if (timedOut) {
        throw AgentTransportException(
          'The model request timed out.',
          code: timeoutCode,
        );
      }
      throw const AgentRequestCancelledException();
    } on TimeoutException {
      throw AgentTransportException(
        'The model request timed out.',
        code: timeoutCode,
      );
    } on http.ClientException {
      if (token.isCancelled) throw const AgentRequestCancelledException();
      throw const AgentTransportException(
        'The model provider is unreachable.',
        code: 'network_unavailable',
      );
    } on FormatException {
      throw const AgentTransportException(
        'The provider URL or response was invalid.',
        code: 'invalid_response',
      );
    } on AgentProtocolException catch (error) {
      throw AgentTransportException(
        _safeMessage(error.message, secrets: [trimmedKey]),
        code: error.code,
      );
    } on AgentTransportException catch (error) {
      throw AgentTransportException(
        _safeMessage(error.message, secrets: [trimmedKey]),
        code: _safeCode(error.code),
        statusCode: error.statusCode,
        retryAfter: error.retryAfter,
      );
    } catch (error) {
      if (token.isCancelled) throw const AgentRequestCancelledException();
      throw AgentTransportException(
        _safeMessage(error.toString(), secrets: [trimmedKey]),
      );
    } finally {
      timeoutTimer.cancel();
    }
  }

  @override
  void dispose() {
    if (_ownsClient) _client.close();
  }
}

Stream<List<int>> _limitResponseBytes(
  Stream<List<int>> source,
  int limit,
) async* {
  var received = 0;
  await for (final chunk in source) {
    received += chunk.length;
    if (received > limit) {
      throw const AgentProtocolException(
        'The model response exceeded the safety limit.',
        code: 'provider_response_too_large',
      );
    }
    yield chunk;
  }
}

Uri normalizeAgentProviderBaseUrl(
  String value, {
  bool allowDebugLoopbackHttp = false,
}) {
  final trimmed = value.trim().replaceFirst(RegExp(r'/+$'), '');
  final uri = Uri.tryParse(trimmed);
  if (uri == null ||
      !uri.hasScheme ||
      uri.host.isEmpty ||
      uri.userInfo.isNotEmpty ||
      trimmed.contains('?') ||
      trimmed.contains('#') ||
      uri.hasQuery ||
      uri.hasFragment) {
    throw const FormatException(
      'Enter a provider Base URL without credentials, query, or fragment.',
    );
  }
  final isHttps = uri.scheme.toLowerCase() == 'https';
  final isAllowedDebugHttp =
      allowDebugLoopbackHttp &&
      uri.scheme.toLowerCase() == 'http' &&
      _isLoopbackHost(uri.host);
  if (!isHttps && !isAllowedDebugHttp) {
    throw const FormatException('The provider Base URL must use HTTPS.');
  }
  var path = uri.path.replaceFirst(RegExp(r'/+$'), '');
  const endpointSuffix = '/chat/completions';
  if (path.endsWith(endpointSuffix)) {
    path = path.substring(0, path.length - endpointSuffix.length);
  }
  return uri.replace(path: path);
}

Uri agentChatCompletionsUri(
  String baseUrl, {
  bool allowDebugLoopbackHttp = false,
}) {
  final base = normalizeAgentProviderBaseUrl(
    baseUrl,
    allowDebugLoopbackHttp: allowDebugLoopbackHttp,
  );
  return base.replace(path: '${base.path}/chat/completions');
}

bool _isLoopbackHost(String host) {
  final normalized = host.toLowerCase();
  return normalized == 'localhost' ||
      normalized == '127.0.0.1' ||
      normalized == '::1';
}

Future<List<int>> _readBounded(Stream<List<int>> body, int limit) async {
  final bytes = <int>[];
  await for (final chunk in body) {
    final remaining = limit - bytes.length;
    if (remaining <= 0) break;
    bytes.addAll(
      chunk.length <= remaining ? chunk : chunk.sublist(0, remaining),
    );
  }
  return bytes;
}

AgentTransportException _errorFromResponse({
  required int statusCode,
  required List<int> bytes,
  required Iterable<String> secrets,
  Duration? retryAfter,
}) {
  String code = switch (statusCode) {
    401 || 403 => 'provider_auth_failed',
    429 => 'provider_rate_limited',
    >= 500 => 'provider_unavailable',
    _ => 'provider_rejected',
  };
  var message = 'The model provider rejected the request ($statusCode).';
  try {
    final decoded = jsonDecode(utf8.decode(bytes));
    if (decoded is Map) {
      final error = decoded['error'];
      final source = error is Map ? error : decoded;
      final candidateCode = source['code'];
      if (candidateCode is String &&
          _safeCode(candidateCode) != 'provider_error') {
        code = candidateCode;
      }
      final candidateMessage = source['message'] ?? source['error'];
      if (candidateMessage is String && candidateMessage.isNotEmpty) {
        message = candidateMessage;
      }
    }
  } catch (_) {
    // Do not expose an arbitrary HTML/text error body from a gateway.
  }
  return AgentTransportException(
    _safeMessage(message, secrets: secrets),
    code: _safeCode(code),
    statusCode: statusCode,
    retryAfter: retryAfter,
  );
}

Duration? _retryAfter(String? value) {
  final seconds = int.tryParse(value ?? '');
  if (seconds != null) return Duration(seconds: seconds.clamp(0, 300));
  if (value != null) {
    try {
      final date = DateFormat(
        "EEE, dd MMM yyyy HH:mm:ss 'GMT'",
        'en_US',
      ).parseStrict(value, true);
      return Duration(
        seconds: date
            .difference(DateTime.now().toUtc())
            .inSeconds
            .clamp(0, 300),
      );
    } catch (_) {
      /* Invalid Retry-After uses bounded backoff. */
    }
  }
  return null;
}

String _safeCode(String value) {
  // Never persist arbitrary provider strings in diagnostic metadata. A code
  // supplied by a gateway can contain a credential just like its message.
  const codes = {
    'cancelled',
    'api_key_required',
    'relay_auth_required',
    'relay_unavailable',
    'request_timeout',
    'first_byte_timeout',
    'stream_idle_timeout',
    'request_too_large',
    'provider_response_too_large',
    'invalid_response',
    'provider_auth_failed',
    'provider_rate_limited',
    'provider_unavailable',
    'provider_rejected',
    'provider_request_rejected',
    'invalid_provider_url',
    'network_unavailable',
    'transport_error',
    'invalid_json',
    'invalid_utf8',
    'invalid_tool_call',
    'incomplete_response',
  };
  if (codes.contains(value)) return value;
  return 'provider_error';
}

String _safeMessage(String value, {required Iterable<String> secrets}) {
  final redacted = redactAgentSecrets(
    value,
    secrets: secrets,
  ).replaceAll(RegExp(r'[\r\n\t]+'), ' ').trim();
  if (redacted.isEmpty) return 'The model request failed.';
  return redacted.length <= 500 ? redacted : '${redacted.substring(0, 500)}…';
}

final agentModelTransportProvider = Provider<AgentModelTransport>((ref) {
  final AgentModelTransport transport;
  if (kIsWeb) {
    final bootstrap = ref.watch(supabaseBootstrapProvider);
    transport = WebRelayAgentModelTransport(
      backendBaseUrl: bootstrap.isConfigured ? bootstrap.url : '',
      accessTokenLoader: () =>
          ref.read(authRepositoryProvider).currentAccessToken(),
    );
  } else {
    transport = NativeAgentModelTransport();
  }
  ref.onDispose(transport.dispose);
  return transport;
});
