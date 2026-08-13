package app

import (
	"bytes"
	"context"
	"errors"
	"io"
	"log"
	"net/http"
	"net/http/httptest"
	"net/netip"
	"net/url"
	"strconv"
	"strings"
	"sync"
	"sync/atomic"
	"testing"
	"time"
)

type agentResolverStub struct {
	addresses []netip.Addr
	err       error
	calls     atomic.Int32
}

func (r *agentResolverStub) LookupNetIP(context.Context, string, string) ([]netip.Addr, error) {
	r.calls.Add(1)
	return r.addresses, r.err
}

type agentRoundTripFunc func(*http.Request) (*http.Response, error)

func (f agentRoundTripFunc) RoundTrip(request *http.Request) (*http.Response, error) {
	return f(request)
}

func TestAgentRelayRequiresAuthenticationBeforeDNS(t *testing.T) {
	resolver := &agentResolverStub{addresses: []netip.Addr{netip.MustParseAddr("8.8.8.8")}}
	server := newAgentRelayTestServer(resolver, nil, Config{JWTSecret: "test-secret"})
	handler := server.withAuth(server.handleAgentChatCompletions)
	recorder := httptest.NewRecorder()
	handler(recorder, httptest.NewRequest(http.MethodPost, "/v1/agent/chat-completions", strings.NewReader(validAgentRelayBody("sk-test"))))

	if recorder.Code != http.StatusUnauthorized {
		t.Fatalf("expected 401, got %d", recorder.Code)
	}
	if resolver.calls.Load() != 0 {
		t.Fatal("anonymous request must not resolve provider DNS")
	}
}

func TestAgentRelayAcceptsValidFittinSession(t *testing.T) {
	server := newAgentRelayTestServer(publicAgentResolver(), agentRoundTripFunc(func(*http.Request) (*http.Response, error) {
		return agentResponse(http.StatusOK, "application/json", `{}`), nil
	}), Config{JWTSecret: "test-secret"})
	token, err := server.issueToken("authenticated-user", "user@example.com")
	if err != nil {
		t.Fatalf("issue Fittin token: %v", err)
	}
	request := httptest.NewRequest(http.MethodPost, "/v1/agent/chat-completions", strings.NewReader(validAgentRelayBody("sk-provider")))
	request.Header.Set("Authorization", "Bearer "+token)
	recorder := httptest.NewRecorder()

	server.withAuth(server.handleAgentChatCompletions)(recorder, request)

	if recorder.Code != http.StatusOK {
		t.Fatalf("valid Fittin session was rejected: %d %s", recorder.Code, recorder.Body.String())
	}
}

func TestResolveAgentTargetRejectsUnsafeURLsAndAddresses(t *testing.T) {
	tests := []struct {
		name      string
		baseURL   string
		addresses []netip.Addr
	}{
		{name: "plain HTTP", baseURL: "http://provider.example/v1", addresses: publicAgentAddresses()},
		{name: "userinfo", baseURL: "https://user:pass@provider.example/v1", addresses: publicAgentAddresses()},
		{name: "query", baseURL: "https://provider.example/v1?target=x", addresses: publicAgentAddresses()},
		{name: "fragment", baseURL: "https://provider.example/v1#x", addresses: publicAgentAddresses()},
		{name: "loopback", baseURL: "https://provider.example/v1", addresses: []netip.Addr{netip.MustParseAddr("127.0.0.1")}},
		{name: "private", baseURL: "https://provider.example/v1", addresses: []netip.Addr{netip.MustParseAddr("10.1.2.3")}},
		{name: "link local", baseURL: "https://provider.example/v1", addresses: []netip.Addr{netip.MustParseAddr("169.254.169.254")}},
		{name: "carrier NAT", baseURL: "https://provider.example/v1", addresses: []netip.Addr{netip.MustParseAddr("100.64.0.1")}},
		{name: "documentation", baseURL: "https://provider.example/v1", addresses: []netip.Addr{netip.MustParseAddr("203.0.113.10")}},
		{name: "AS112 IPv4", baseURL: "https://provider.example/v1", addresses: []netip.Addr{netip.MustParseAddr("192.31.196.1")}},
		{name: "AMT IPv4", baseURL: "https://provider.example/v1", addresses: []netip.Addr{netip.MustParseAddr("192.52.193.1")}},
		{name: "IPv6 private", baseURL: "https://provider.example/v1", addresses: []netip.Addr{netip.MustParseAddr("fd00::1")}},
		{name: "IPv6 documentation", baseURL: "https://provider.example/v1", addresses: []netip.Addr{netip.MustParseAddr("2001:db8::1")}},
		{name: "NAT64 private embedding", baseURL: "https://provider.example/v1", addresses: []netip.Addr{netip.MustParseAddr("64:ff9b::a00:1")}},
		{name: "IETF protocol assignment", baseURL: "https://provider.example/v1", addresses: []netip.Addr{netip.MustParseAddr("2001:1::1")}},
		{name: "6to4 private embedding", baseURL: "https://provider.example/v1", addresses: []netip.Addr{netip.MustParseAddr("2002:a00:1::")}},
		{name: "IPv6 documentation 3fff", baseURL: "https://provider.example/v1", addresses: []netip.Addr{netip.MustParseAddr("3fff::1")}},
		{name: "IPv6 scoped address", baseURL: "https://provider.example/v1", addresses: []netip.Addr{netip.MustParseAddr("2606:4700:4700::1111%en0")}},
		{name: "mixed public and private", baseURL: "https://provider.example/v1", addresses: []netip.Addr{netip.MustParseAddr("8.8.8.8"), netip.MustParseAddr("127.0.0.1")}},
	}
	for _, test := range tests {
		t.Run(test.name, func(t *testing.T) {
			resolver := &agentResolverStub{addresses: test.addresses}
			if _, err := resolveAgentTarget(context.Background(), test.baseURL, resolver); err == nil {
				t.Fatalf("expected %q to be rejected", test.baseURL)
			}
		})
	}
}

func TestResolveAgentTargetPinsPublicAddressAndAppendsEndpoint(t *testing.T) {
	resolver := &agentResolverStub{addresses: []netip.Addr{
		netip.MustParseAddr("8.8.8.8"),
		netip.MustParseAddr("2606:4700:4700::1111"),
	}}
	target, err := resolveAgentTarget(context.Background(), "https://provider.example/openai/v1/", resolver)
	if err != nil {
		t.Fatalf("resolve target: %v", err)
	}
	if target.URL.String() != "https://provider.example/openai/v1/chat/completions" {
		t.Fatalf("unexpected target URL: %s", target.URL)
	}
	if target.IP.String() != "8.8.8.8" {
		t.Fatalf("expected first validated DNS address to be pinned, got %s", target.IP)
	}
	if got, err := pinnedAgentDialAddress(target, "provider.example:443"); err != nil || got != "8.8.8.8:443" {
		t.Fatalf("unexpected pinned dial result %q, %v", got, err)
	}
	if _, err := pinnedAgentDialAddress(target, "redirect.example:443"); err == nil {
		t.Fatal("expected an unpinned hostname to be rejected")
	}
}

func TestPinnedAgentClientDisablesProxiesAndRedirects(t *testing.T) {
	target := agentPinnedTarget{
		URL:      mustParseAgentURL(t, "https://provider.example/v1/chat/completions"),
		Hostname: "provider.example",
		Port:     "443",
		IP:       netip.MustParseAddr("8.8.8.8"),
	}
	client := newPinnedAgentHTTPClient(target, Config{})
	transport, ok := client.Transport.(*http.Transport)
	if !ok {
		t.Fatalf("unexpected transport type %T", client.Transport)
	}
	if transport.Proxy != nil {
		t.Fatal("Agent transport must not use environment proxies")
	}
	redirect := httptest.NewRequest(http.MethodGet, "https://redirect.example", nil)
	if err := client.CheckRedirect(redirect, nil); !errors.Is(err, errAgentRedirectBlocked) {
		t.Fatalf("redirect policy returned %v", err)
	}
}

func TestAgentRelayRejectsPrivateTargetWithoutUpstreamRequest(t *testing.T) {
	resolver := &agentResolverStub{addresses: []netip.Addr{netip.MustParseAddr("127.0.0.1")}}
	var upstreamCalls atomic.Int32
	server := newAgentRelayTestServer(resolver, agentRoundTripFunc(func(*http.Request) (*http.Response, error) {
		upstreamCalls.Add(1)
		return nil, errors.New("must not run")
	}), Config{})
	recorder := serveAgentRelay(server, validAgentRelayBody("sk-test"), "user-private", "198.18.0.1")

	if recorder.Code != http.StatusBadRequest || !strings.Contains(recorder.Body.String(), "invalid_provider_url") {
		t.Fatalf("unexpected private-target response: %d %s", recorder.Code, recorder.Body.String())
	}
	if upstreamCalls.Load() != 0 {
		t.Fatal("private target reached the upstream transport")
	}
}

func TestAgentRelayPassesJSONWithoutProviderHeaders(t *testing.T) {
	transport := agentRoundTripFunc(func(request *http.Request) (*http.Response, error) {
		if request.Header.Get("Authorization") != "Bearer sk-test" {
			t.Fatalf("provider authorization was not set")
		}
		if request.URL.String() != "https://provider.example/v1/chat/completions" {
			t.Fatalf("unexpected upstream URL: %s", request.URL)
		}
		return agentResponse(http.StatusOK, "application/json; charset=utf-8", `{"id":"completion-1"}`), nil
	})
	server := newAgentRelayTestServer(publicAgentResolver(), transport, Config{})
	recorder := serveAgentRelay(server, validAgentRelayBody("sk-test"), "user-json", "198.18.0.2")

	if recorder.Code != http.StatusOK || recorder.Body.String() != `{"id":"completion-1"}` {
		t.Fatalf("unexpected JSON relay response: %d %s", recorder.Code, recorder.Body.String())
	}
	if recorder.Header().Get("Content-Type") != "application/json" || recorder.Header().Get("Cache-Control") != "no-store" {
		t.Fatalf("unexpected response headers: %#v", recorder.Header())
	}
}

func TestAgentRelayFlushesStreamingChunks(t *testing.T) {
	reader, writer := io.Pipe()
	transport := agentRoundTripFunc(func(*http.Request) (*http.Response, error) {
		return &http.Response{
			StatusCode: http.StatusOK,
			Header:     http.Header{"Content-Type": []string{"text/event-stream"}},
			Body:       reader,
		}, nil
	})
	server := newAgentRelayTestServer(publicAgentResolver(), transport, Config{})
	recorder := &flushObservingRecorder{
		ResponseRecorder: httptest.NewRecorder(),
		bodyFlushed:      make(chan struct{}, 1),
	}
	request := agentRelayRequestForTest(validAgentRelayBody("sk-stream"), "user-stream", "198.18.0.3")
	done := make(chan struct{})
	go func() {
		server.handleAgentChatCompletions(recorder, request)
		close(done)
	}()

	firstChunk := "data: {\"choices\":[{\"delta\":{\"content\":\"one\"}}]}\n\n"
	if _, err := writer.Write([]byte(firstChunk)); err != nil {
		t.Fatalf("write first SSE chunk: %v", err)
	}
	select {
	case <-recorder.bodyFlushed:
	case <-time.After(time.Second):
		t.Fatal("first SSE chunk was not flushed progressively")
	}
	if !strings.Contains(recorder.Body.String(), "one") {
		t.Fatalf("first chunk not visible after flush: %q", recorder.Body.String())
	}

	_, _ = writer.Write([]byte("data: [DONE]\n\n"))
	_ = writer.Close()
	select {
	case <-done:
	case <-time.After(time.Second):
		t.Fatal("stream relay did not finish")
	}
	if recorder.Header().Get("X-Accel-Buffering") != "no" {
		t.Fatal("streaming response must disable nginx buffering")
	}
}

func TestAgentRelayCancelsUpstreamWhenClientDisconnects(t *testing.T) {
	upstreamStarted := make(chan struct{})
	upstreamCancelled := make(chan struct{})
	transport := agentRoundTripFunc(func(request *http.Request) (*http.Response, error) {
		close(upstreamStarted)
		<-request.Context().Done()
		close(upstreamCancelled)
		return nil, request.Context().Err()
	})
	server := newAgentRelayTestServer(publicAgentResolver(), transport, Config{})
	baseRequest := agentRelayRequestForTest(validAgentRelayBody("sk-cancel"), "user-cancel", "198.18.0.4")
	contextWithCancel, cancel := context.WithCancel(baseRequest.Context())
	request := baseRequest.WithContext(contextWithCancel)
	done := make(chan struct{})
	go func() {
		server.handleAgentChatCompletions(httptest.NewRecorder(), request)
		close(done)
	}()

	select {
	case <-upstreamStarted:
	case <-time.After(time.Second):
		t.Fatal("upstream request did not start")
	}
	cancel()
	select {
	case <-upstreamCancelled:
	case <-time.After(time.Second):
		t.Fatal("client cancellation did not reach upstream")
	}
	select {
	case <-done:
	case <-time.After(time.Second):
		t.Fatal("relay handler did not return after cancellation")
	}
}

func TestAgentRelayCancelsBodyReadWhenClientDisconnectsMidStream(t *testing.T) {
	readStarted := make(chan struct{})
	bodyClosed := make(chan struct{})
	transport := agentRoundTripFunc(func(request *http.Request) (*http.Response, error) {
		return &http.Response{
			StatusCode: http.StatusOK,
			Header:     http.Header{"Content-Type": []string{"text/event-stream"}},
			Body: &contextBlockingAgentBody{
				ctx:         request.Context(),
				readStarted: readStarted,
				closed:      bodyClosed,
			},
		}, nil
	})
	server := newAgentRelayTestServer(publicAgentResolver(), transport, Config{})
	baseRequest := agentRelayRequestForTest(validAgentRelayBody("sk-mid-stream-cancel"), "user-mid-stream-cancel", "198.18.0.15")
	requestContext, cancel := context.WithCancel(baseRequest.Context())
	request := baseRequest.WithContext(requestContext)
	done := make(chan struct{})
	go func() {
		server.handleAgentChatCompletions(httptest.NewRecorder(), request)
		close(done)
	}()

	select {
	case <-readStarted:
	case <-time.After(time.Second):
		t.Fatal("relay did not begin reading the upstream SSE body")
	}
	cancel()
	select {
	case <-done:
	case <-time.After(time.Second):
		t.Fatal("mid-stream client disconnect did not stop the relay")
	}
	select {
	case <-bodyClosed:
	case <-time.After(time.Second):
		t.Fatal("upstream body was not closed after client disconnect")
	}
}

func TestAgentRelayTimesOutSlowProvider(t *testing.T) {
	transport := agentRoundTripFunc(func(request *http.Request) (*http.Response, error) {
		<-request.Context().Done()
		return nil, request.Context().Err()
	})
	server := newAgentRelayTestServer(publicAgentResolver(), transport, Config{
		AgentUpstreamTimeout: 20 * time.Millisecond,
	})
	recorder := serveAgentRelay(server, validAgentRelayBody("sk-timeout"), "user-timeout", "198.18.0.13")

	if recorder.Code != http.StatusGatewayTimeout || !strings.Contains(recorder.Body.String(), "provider_timeout") {
		t.Fatalf("unexpected timeout response: %d %s", recorder.Code, recorder.Body.String())
	}
}

func TestAgentRelayBlocksRedirects(t *testing.T) {
	transport := agentRoundTripFunc(func(*http.Request) (*http.Response, error) {
		response := agentResponse(http.StatusFound, "text/plain", "redirect")
		response.Header.Set("Location", "https://redirect.example/v1/chat/completions")
		return response, nil
	})
	server := newAgentRelayTestServer(publicAgentResolver(), transport, Config{})
	recorder := serveAgentRelay(server, validAgentRelayBody("sk-redirect"), "user-redirect", "198.18.0.5")

	if recorder.Code != http.StatusBadGateway || !strings.Contains(recorder.Body.String(), "provider_redirect_blocked") {
		t.Fatalf("unexpected redirect response: %d %s", recorder.Code, recorder.Body.String())
	}
}

func TestAgentRelayBoundsRequestAndJSONResponse(t *testing.T) {
	server := newAgentRelayTestServer(publicAgentResolver(), agentRoundTripFunc(func(*http.Request) (*http.Response, error) {
		return agentResponse(http.StatusOK, "application/json", `{"too":"large"}`), nil
	}), Config{AgentMaxRequestBytes: 64, AgentMaxResponseBytes: 4})

	requestRecorder := serveAgentRelay(server, validAgentRelayBody("sk-request"), "user-request-limit", "198.18.0.6")
	if requestRecorder.Code != http.StatusRequestEntityTooLarge || !strings.Contains(requestRecorder.Body.String(), "relay_request_too_large") {
		t.Fatalf("unexpected request limit response: %d %s", requestRecorder.Code, requestRecorder.Body.String())
	}

	server.cfg.AgentMaxRequestBytes = 64 << 10
	responseRecorder := serveAgentRelay(server, validAgentRelayBody("sk-response"), "user-response-limit", "198.18.0.7")
	if responseRecorder.Code != http.StatusBadGateway || !strings.Contains(responseRecorder.Body.String(), "provider_response_too_large") {
		t.Fatalf("unexpected response limit response: %d %s", responseRecorder.Code, responseRecorder.Body.String())
	}
}

func TestAgentRelayCapsStreamingResponseBytes(t *testing.T) {
	transport := agentRoundTripFunc(func(*http.Request) (*http.Response, error) {
		return agentResponse(http.StatusOK, "text/event-stream", "1234567890"), nil
	})
	server := newAgentRelayTestServer(publicAgentResolver(), transport, Config{
		AgentMaxResponseBytes: 5,
	})
	recorder := serveAgentRelay(server, validAgentRelayBody("sk-stream-limit"), "user-stream-limit", "198.18.0.14")

	if recorder.Code != http.StatusOK || recorder.Body.String() != "12345" {
		t.Fatalf("stream was not capped exactly: %d %q", recorder.Code, recorder.Body.String())
	}
}

func TestAgentRelayEnforcesPerUserConcurrency(t *testing.T) {
	started := make(chan struct{})
	release := make(chan struct{})
	transport := agentRoundTripFunc(func(*http.Request) (*http.Response, error) {
		select {
		case started <- struct{}{}:
		default:
		}
		<-release
		return agentResponse(http.StatusOK, "application/json", `{}`), nil
	})
	server := newAgentRelayTestServer(publicAgentResolver(), transport, Config{
		AgentMaxConcurrentPerUser: 1,
		AgentRateLimitPerMin:      10,
	})
	firstDone := make(chan struct{})
	go func() {
		serveAgentRelay(server, validAgentRelayBody("sk-first"), "same-user", "198.18.0.8")
		close(firstDone)
	}()
	select {
	case <-started:
	case <-time.After(time.Second):
		t.Fatal("first upstream request did not start")
	}

	second := serveAgentRelay(server, validAgentRelayBody("sk-second"), "same-user", "198.18.0.9")
	if second.Code != http.StatusTooManyRequests || !strings.Contains(second.Body.String(), "agent_concurrency_limited") {
		t.Fatalf("unexpected concurrency response: %d %s", second.Code, second.Body.String())
	}
	close(release)
	select {
	case <-firstDone:
	case <-time.After(time.Second):
		t.Fatal("first request did not finish")
	}
}

func TestAgentRelayEnforcesUserAndIPRateLimits(t *testing.T) {
	transport := agentRoundTripFunc(func(*http.Request) (*http.Response, error) {
		return agentResponse(http.StatusOK, "application/json", `{}`), nil
	})
	server := newAgentRelayTestServer(publicAgentResolver(), transport, Config{
		AgentMaxConcurrentPerUser: 2,
		AgentRateLimitPerMin:      1,
	})

	first := serveAgentRelay(server, validAgentRelayBody("sk-one"), "rate-user", "198.18.0.10")
	if first.Code != http.StatusOK {
		t.Fatalf("first request failed: %d %s", first.Code, first.Body.String())
	}
	userLimited := serveAgentRelay(server, validAgentRelayBody("sk-two"), "rate-user", "198.18.0.11")
	if userLimited.Code != http.StatusTooManyRequests || !strings.Contains(userLimited.Body.String(), "agent_rate_limited") {
		t.Fatalf("user rate limit did not apply: %d %s", userLimited.Code, userLimited.Body.String())
	}
	ipLimited := serveAgentRelay(server, validAgentRelayBody("sk-three"), "different-user", "198.18.0.10")
	if ipLimited.Code != http.StatusTooManyRequests || !strings.Contains(ipLimited.Body.String(), "agent_rate_limited") {
		t.Fatalf("IP rate limit did not apply: %d %s", ipLimited.Code, ipLimited.Body.String())
	}
}

func TestAgentRelayRateStateHasHardEntryLimit(t *testing.T) {
	now := time.Now()
	server := newAgentRelayTestServer(publicAgentResolver(), nil, Config{})
	server.agentRateLastCleanup = now
	for index := 0; index < maxAgentRateEntries; index++ {
		server.agentRateByKey["existing:"+strconv.Itoa(index)] = rateWindow{
			started: now,
			count:   1,
		}
	}

	result, release := server.acquireAgentLimits("new-user", "8.8.8.8", now)
	if release != nil {
		release()
	}
	if result != agentLimitRateExceeded {
		t.Fatalf("expected a full rate table to fail closed, got %v", result)
	}
	if len(server.agentRateByKey) != maxAgentRateEntries {
		t.Fatalf("rate table grew past hard limit: %d", len(server.agentRateByKey))
	}
}

func TestAgentRelaySanitizesProviderErrors(t *testing.T) {
	secret := "sk-never-return-this"
	upstreamBody := secret + ` Authorization: Bearer raw-prompt 127.0.0.1`
	var capturedLogs bytes.Buffer
	previousLogOutput := log.Writer()
	previousLogFlags := log.Flags()
	previousLogPrefix := log.Prefix()
	log.SetOutput(&capturedLogs)
	log.SetFlags(0)
	log.SetPrefix("")
	t.Cleanup(func() {
		log.SetOutput(previousLogOutput)
		log.SetFlags(previousLogFlags)
		log.SetPrefix(previousLogPrefix)
	})
	transport := agentRoundTripFunc(func(*http.Request) (*http.Response, error) {
		return agentResponse(http.StatusUnauthorized, "application/json", upstreamBody), nil
	})
	server := newAgentRelayTestServer(publicAgentResolver(), transport, Config{})
	recorder := serveAgentRelay(server, validAgentRelayBody(secret), "user-secret", "198.18.0.12")

	if recorder.Code != http.StatusBadGateway || !strings.Contains(recorder.Body.String(), "provider_auth_failed") {
		t.Fatalf("unexpected provider auth response: %d %s", recorder.Code, recorder.Body.String())
	}
	for _, forbidden := range []string{secret, "Authorization", "raw-prompt", "127.0.0.1"} {
		if strings.Contains(recorder.Body.String(), forbidden) {
			t.Fatalf("relay error exposed sensitive value %q: %s", forbidden, recorder.Body.String())
		}
		if strings.Contains(capturedLogs.String(), forbidden) {
			t.Fatalf("relay logs exposed sensitive value %q: %s", forbidden, capturedLogs.String())
		}
	}
}

func newAgentRelayTestServer(resolver agentDNSResolver, transport http.RoundTripper, cfg Config) *Server {
	server := &Server{
		cfg:                   cfg,
		agentResolver:         resolver,
		agentRateByKey:        make(map[string]rateWindow),
		agentConcurrentByUser: make(map[string]int),
	}
	if transport != nil {
		server.agentClientFactory = func(_ agentPinnedTarget, _ Config) *http.Client {
			return &http.Client{
				Transport: transport,
				CheckRedirect: func(_ *http.Request, _ []*http.Request) error {
					return errAgentRedirectBlocked
				},
			}
		}
	}
	return server
}

func serveAgentRelay(server *Server, body, userID, remoteIP string) *httptest.ResponseRecorder {
	recorder := httptest.NewRecorder()
	server.handleAgentChatCompletions(recorder, agentRelayRequestForTest(body, userID, remoteIP))
	return recorder
}

func agentRelayRequestForTest(body, userID, remoteIP string) *http.Request {
	request := httptest.NewRequest(http.MethodPost, "/v1/agent/chat-completions", strings.NewReader(body))
	request.RemoteAddr = remoteIP + ":43120"
	request.Header.Set("Content-Type", "application/json")
	ctx := context.WithValue(request.Context(), contextKeyUserID{}, userID)
	return request.WithContext(ctx)
}

func validAgentRelayBody(apiKey string) string {
	return `{"providerBaseUrl":"https://provider.example/v1","apiKey":"` + apiKey + `","payload":{"model":"test","stream":true,"messages":[]}}`
}

func publicAgentResolver() agentDNSResolver {
	return &agentResolverStub{addresses: publicAgentAddresses()}
}

func publicAgentAddresses() []netip.Addr {
	return []netip.Addr{netip.MustParseAddr("8.8.8.8")}
}

func agentResponse(status int, contentType, body string) *http.Response {
	return &http.Response{
		StatusCode: status,
		Header:     http.Header{"Content-Type": []string{contentType}},
		Body:       io.NopCloser(bytes.NewBufferString(body)),
	}
}

func mustParseAgentURL(t *testing.T, rawURL string) *url.URL {
	t.Helper()
	parsed, err := url.Parse(rawURL)
	if err != nil {
		t.Fatalf("parse URL: %v", err)
	}
	return parsed
}

type flushObservingRecorder struct {
	*httptest.ResponseRecorder
	bodyFlushed chan struct{}
}

type contextBlockingAgentBody struct {
	ctx         context.Context
	readStarted chan struct{}
	closed      chan struct{}
	readOnce    sync.Once
	closeOnce   sync.Once
}

func (b *contextBlockingAgentBody) Read([]byte) (int, error) {
	b.readOnce.Do(func() { close(b.readStarted) })
	<-b.ctx.Done()
	return 0, b.ctx.Err()
}

func (b *contextBlockingAgentBody) Close() error {
	b.closeOnce.Do(func() { close(b.closed) })
	return nil
}

func (r *flushObservingRecorder) Flush() {
	r.ResponseRecorder.Flush()
	if r.Body.Len() > 0 {
		select {
		case r.bodyFlushed <- struct{}{}:
		default:
		}
	}
}
