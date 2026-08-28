package app

import (
	"bytes"
	"context"
	"crypto/tls"
	"encoding/json"
	"errors"
	"io"
	"mime"
	"net"
	"net/http"
	"net/netip"
	"net/url"
	"strconv"
	"strings"
	"sync"
	"time"
)

const (
	defaultAgentMaxRequestBytes      = int64(512 << 10)
	defaultAgentMaxResponseBytes     = int64(8 << 20)
	defaultAgentUpstreamTimeout      = 5 * time.Minute
	defaultAgentMaxConcurrentPerUser = 2
	defaultAgentRateLimitPerMin      = 12
	maxAgentRateEntries              = 20_000
)

var errAgentRedirectBlocked = errors.New("agent provider redirects are disabled")

type agentDNSResolver interface {
	LookupNetIP(ctx context.Context, network, host string) ([]netip.Addr, error)
}

type agentHTTPClientFactory func(target agentPinnedTarget, cfg Config) *http.Client

type agentPinnedTarget struct {
	URL      *url.URL
	Hostname string
	Port     string
	IP       netip.Addr
}

type agentRelayRequest struct {
	ProviderBaseURL string          `json:"providerBaseUrl"`
	APIKey          string          `json:"apiKey"`
	Payload         json.RawMessage `json:"payload"`
}

type agentLimitResult int

const (
	agentLimitAllowed agentLimitResult = iota
	agentLimitRateExceeded
	agentLimitConcurrencyExceeded
)

var agentBlockedPrefixes = []netip.Prefix{
	netip.MustParsePrefix("0.0.0.0/8"),
	netip.MustParsePrefix("10.0.0.0/8"),
	netip.MustParsePrefix("100.64.0.0/10"),
	netip.MustParsePrefix("127.0.0.0/8"),
	netip.MustParsePrefix("169.254.0.0/16"),
	netip.MustParsePrefix("172.16.0.0/12"),
	netip.MustParsePrefix("192.0.0.0/24"),
	netip.MustParsePrefix("192.0.2.0/24"),
	netip.MustParsePrefix("192.31.196.0/24"),
	netip.MustParsePrefix("192.52.193.0/24"),
	netip.MustParsePrefix("192.88.99.0/24"),
	netip.MustParsePrefix("192.175.48.0/24"),
	netip.MustParsePrefix("192.168.0.0/16"),
	netip.MustParsePrefix("198.18.0.0/15"),
	netip.MustParsePrefix("198.51.100.0/24"),
	netip.MustParsePrefix("203.0.113.0/24"),
	netip.MustParsePrefix("224.0.0.0/4"),
	netip.MustParsePrefix("240.0.0.0/4"),
	netip.MustParsePrefix("::/128"),
	netip.MustParsePrefix("::1/128"),
	netip.MustParsePrefix("64:ff9b::/96"),
	netip.MustParsePrefix("64:ff9b:1::/48"),
	netip.MustParsePrefix("100::/64"),
	netip.MustParsePrefix("2001::/23"),
	netip.MustParsePrefix("2001:db8::/32"),
	netip.MustParsePrefix("2002::/16"),
	netip.MustParsePrefix("2620:4f:8000::/48"),
	netip.MustParsePrefix("3fff::/20"),
	netip.MustParsePrefix("5f00::/16"),
	netip.MustParsePrefix("fc00::/7"),
	netip.MustParsePrefix("fe80::/10"),
	netip.MustParsePrefix("ff00::/8"),
}

func (s *Server) handleAgentChatCompletions(w http.ResponseWriter, r *http.Request) {
	started := time.Now()
	termination := agentTermRejected
	var responseBytes int64
	defer func() { s.recordAgentRelay(termination, responseBytes, time.Since(started)) }()
	if r.Method != http.MethodPost {
		writeError(w, http.StatusMethodNotAllowed, "method_not_allowed", "method not allowed")
		return
	}

	userID, _ := r.Context().Value(contextKeyUserID{}).(string)
	if userID == "" {
		writeError(w, http.StatusUnauthorized, "session_invalid", "a valid session is required")
		return
	}

	limitResult, release := s.acquireAgentLimits(userID, clientIPAddress(r), time.Now())
	if release != nil {
		defer release()
	}
	switch limitResult {
	case agentLimitRateExceeded:
		w.Header().Set("Retry-After", "60")
		writeError(w, http.StatusTooManyRequests, "agent_rate_limited", "too many Agent requests")
		return
	case agentLimitConcurrencyExceeded:
		w.Header().Set("Retry-After", "2")
		writeError(w, http.StatusTooManyRequests, "agent_concurrency_limited", "another Agent request is still running")
		return
	}

	var relayRequest agentRelayRequest
	err := decodeJSONBody(w, r, &relayRequest, s.agentMaxRequestBytes())
	if err != nil {
		var maxBytesError *http.MaxBytesError
		if errors.As(err, &maxBytesError) {
			writeError(w, http.StatusRequestEntityTooLarge, "relay_request_too_large", "Agent request is too large")
			return
		}
		writeError(w, http.StatusBadRequest, "invalid_relay_request", "Agent relay request must be valid JSON")
		return
	}
	if !validAgentCredential(relayRequest.APIKey) || len(relayRequest.ProviderBaseURL) > 2048 || !validJSONObject(relayRequest.Payload) {
		writeError(w, http.StatusBadRequest, "invalid_relay_request", "provider URL, API key, and payload are required")
		return
	}

	requestContext, cancel := context.WithTimeout(r.Context(), s.agentUpstreamTimeout())
	defer cancel()
	target, err := resolveAgentTarget(requestContext, relayRequest.ProviderBaseURL, s.agentDNSResolver())
	if err != nil {
		writeError(w, http.StatusBadRequest, "invalid_provider_url", "provider must be a public HTTPS URL")
		return
	}

	upstreamRequest, err := http.NewRequestWithContext(
		requestContext,
		http.MethodPost,
		target.URL.String(),
		bytes.NewReader(relayRequest.Payload),
	)
	if err != nil {
		writeError(w, http.StatusBadRequest, "invalid_relay_request", "could not create provider request")
		return
	}
	upstreamRequest.Header.Set("Authorization", "Bearer "+relayRequest.APIKey)
	upstreamRequest.Header.Set("Content-Type", "application/json")
	upstreamRequest.Header.Set("Accept", "text/event-stream, application/json")
	upstreamRequest.Header.Set("User-Agent", "Fittin-Agent-Relay/1.1")

	client := s.agentHTTPClient(target)
	upstreamResponse, err := client.Do(upstreamRequest)
	defer client.CloseIdleConnections()
	if err != nil {
		if upstreamResponse != nil && upstreamResponse.Body != nil {
			_ = upstreamResponse.Body.Close()
		}
		if r.Context().Err() != nil {
			termination = agentTermCancelled
			return
		}
		switch {
		case errors.Is(err, errAgentRedirectBlocked):
			writeError(w, http.StatusBadGateway, "provider_redirect_blocked", "provider redirects are not allowed")
		case errors.Is(err, context.DeadlineExceeded), errors.Is(requestContext.Err(), context.DeadlineExceeded):
			termination = agentTermTimeout
			writeError(w, http.StatusGatewayTimeout, "provider_timeout", "provider response timed out")
		default:
			termination = agentTermUnavailable
			writeError(w, http.StatusBadGateway, "provider_unavailable", "provider is unavailable")
		}
		return
	}
	defer upstreamResponse.Body.Close()
	upstreamResponse.Body = &agentIdleBody{ReadCloser: upstreamResponse.Body, idle: 60 * time.Second}

	if upstreamResponse.StatusCode < http.StatusOK || upstreamResponse.StatusCode >= http.StatusMultipleChoices {
		// The error body may contain secrets. Closing the per-request client is
		// sufficient; do not buffer or log the upstream payload.
		if delay := safeAgentRetryAfter(upstreamResponse.Header.Get("Retry-After"), time.Now()); delay != "" {
			w.Header().Set("Retry-After", delay)
		}
		writeAgentUpstreamError(w, upstreamResponse.StatusCode)
		return
	}

	mediaType := normalizedAgentMediaType(upstreamResponse.Header.Get("Content-Type"))
	switch mediaType {
	case "text/event-stream":
		termination, responseBytes = s.streamAgentResponse(w, upstreamResponse)
	case "application/json":
		termination, responseBytes = s.writeAgentJSONResponse(w, upstreamResponse)
	default:
		writeError(w, http.StatusBadGateway, "provider_response_invalid", "provider returned an unsupported response type")
	}
	if r.Context().Err() != nil {
		termination = agentTermCancelled
	} else if requestContext.Err() != nil {
		termination = agentTermTimeout
	}
}

func (s *Server) acquireAgentLimits(userID, ip string, now time.Time) (agentLimitResult, func()) {
	s.agentMu.Lock()
	defer s.agentMu.Unlock()
	if s.agentRateByKey == nil {
		s.agentRateByKey = make(map[string]rateWindow)
	}
	if s.agentConcurrentByUser == nil {
		s.agentConcurrentByUser = make(map[string]int)
	}
	if s.agentRateLastCleanup.IsZero() || now.Sub(s.agentRateLastCleanup) >= time.Minute {
		for key, window := range s.agentRateByKey {
			if now.Sub(window.started) >= 2*time.Minute {
				delete(s.agentRateByKey, key)
			}
		}
		s.agentRateLastCleanup = now
	}

	rateLimit := s.cfg.AgentRateLimitPerMin
	if rateLimit <= 0 {
		rateLimit = defaultAgentRateLimitPerMin
	}
	keys := []string{"user:" + userID, "ip:" + ip}
	newKeyCount := 0
	for _, key := range keys {
		if _, exists := s.agentRateByKey[key]; !exists {
			newKeyCount++
		}
	}
	if len(s.agentRateByKey)+newKeyCount > maxAgentRateEntries {
		return agentLimitRateExceeded, nil
	}
	windows := make([]rateWindow, len(keys))
	for index, key := range keys {
		window := s.agentRateByKey[key]
		if window.started.IsZero() || now.Sub(window.started) >= time.Minute {
			window = rateWindow{started: now}
		}
		if window.count >= rateLimit {
			return agentLimitRateExceeded, nil
		}
		windows[index] = window
	}
	for index, key := range keys {
		windows[index].count++
		s.agentRateByKey[key] = windows[index]
	}

	concurrencyLimit := s.cfg.AgentMaxConcurrentPerUser
	if concurrencyLimit <= 0 {
		concurrencyLimit = defaultAgentMaxConcurrentPerUser
	}
	if s.agentConcurrentByUser[userID] >= concurrencyLimit {
		return agentLimitConcurrencyExceeded, nil
	}
	s.agentConcurrentByUser[userID]++
	var once sync.Once
	return agentLimitAllowed, func() {
		once.Do(func() {
			s.agentMu.Lock()
			defer s.agentMu.Unlock()
			s.agentConcurrentByUser[userID]--
			if s.agentConcurrentByUser[userID] <= 0 {
				delete(s.agentConcurrentByUser, userID)
			}
		})
	}
}

func resolveAgentTarget(ctx context.Context, rawBaseURL string, resolver agentDNSResolver) (agentPinnedTarget, error) {
	trimmed := strings.TrimSpace(rawBaseURL)
	parsed, err := url.Parse(trimmed)
	if err != nil || parsed.Scheme != "https" || parsed.Host == "" || parsed.Opaque != "" {
		return agentPinnedTarget{}, errors.New("invalid provider URL")
	}
	if parsed.User != nil || parsed.RawQuery != "" || parsed.ForceQuery || parsed.Fragment != "" {
		return agentPinnedTarget{}, errors.New("provider URL cannot contain credentials, query, or fragment")
	}
	hostname := strings.TrimSuffix(strings.ToLower(parsed.Hostname()), ".")
	if hostname == "" || strings.ContainsAny(hostname, "\x00\r\n\t ") {
		return agentPinnedTarget{}, errors.New("invalid provider hostname")
	}
	port := parsed.Port()
	if port == "" {
		port = "443"
	} else {
		portNumber, portErr := strconv.Atoi(port)
		if portErr != nil || portNumber < 1 || portNumber > 65535 {
			return agentPinnedTarget{}, errors.New("invalid provider port")
		}
	}

	var addresses []netip.Addr
	if literal, parseErr := netip.ParseAddr(hostname); parseErr == nil {
		addresses = []netip.Addr{literal}
	} else {
		if resolver == nil {
			resolver = net.DefaultResolver
		}
		addresses, err = resolver.LookupNetIP(ctx, "ip", hostname)
		if err != nil || len(addresses) == 0 {
			return agentPinnedTarget{}, errors.New("provider DNS resolution failed")
		}
	}
	for _, address := range addresses {
		if !isPublicAgentAddress(address) {
			return agentPinnedTarget{}, errors.New("provider resolved to a non-public address")
		}
	}

	parsed.Scheme = "https"
	if port == "443" {
		if strings.Contains(hostname, ":") {
			parsed.Host = "[" + hostname + "]"
		} else {
			parsed.Host = hostname
		}
	} else {
		parsed.Host = net.JoinHostPort(hostname, port)
	}
	parsed.Path = strings.TrimRight(parsed.Path, "/") + "/chat/completions"
	parsed.RawPath = ""
	return agentPinnedTarget{
		URL:      parsed,
		Hostname: hostname,
		Port:     port,
		IP:       addresses[0].Unmap(),
	}, nil
}

func isPublicAgentAddress(address netip.Addr) bool {
	if !address.IsValid() || address.Zone() != "" {
		return false
	}
	address = address.Unmap()
	if !address.IsGlobalUnicast() || address.IsPrivate() || address.IsLoopback() || address.IsLinkLocalUnicast() || address.IsLinkLocalMulticast() || address.IsMulticast() || address.IsUnspecified() {
		return false
	}
	for _, prefix := range agentBlockedPrefixes {
		if prefix.Contains(address) {
			return false
		}
	}
	return true
}

func newPinnedAgentHTTPClient(target agentPinnedTarget, cfg Config) *http.Client {
	maxConnections := cfg.AgentMaxConcurrentPerUser
	if maxConnections <= 0 {
		maxConnections = defaultAgentMaxConcurrentPerUser
	}
	dialer := &net.Dialer{
		Timeout:   10 * time.Second,
		KeepAlive: 30 * time.Second,
	}
	transport := &http.Transport{
		Proxy:                 nil,
		ForceAttemptHTTP2:     true,
		DisableCompression:    true,
		MaxIdleConns:          4,
		MaxIdleConnsPerHost:   maxConnections,
		MaxConnsPerHost:       maxConnections,
		IdleConnTimeout:       30 * time.Second,
		TLSHandshakeTimeout:   10 * time.Second,
		ResponseHeaderTimeout: 45 * time.Second,
		TLSClientConfig: &tls.Config{
			MinVersion: tls.VersionTLS12,
			ServerName: target.Hostname,
		},
		DialContext: func(ctx context.Context, network, address string) (net.Conn, error) {
			pinnedAddress, err := pinnedAgentDialAddress(target, address)
			if err != nil {
				return nil, err
			}
			return dialer.DialContext(ctx, "tcp", pinnedAddress)
		},
	}
	return &http.Client{
		Transport: transport,
		CheckRedirect: func(_ *http.Request, _ []*http.Request) error {
			return errAgentRedirectBlocked
		},
	}
}

func pinnedAgentDialAddress(target agentPinnedTarget, requestedAddress string) (string, error) {
	host, port, err := net.SplitHostPort(requestedAddress)
	if err != nil || !strings.EqualFold(strings.TrimSuffix(host, "."), target.Hostname) || port != target.Port {
		return "", errors.New("refused unpinned provider connection")
	}
	return net.JoinHostPort(target.IP.String(), target.Port), nil
}

func (s *Server) agentDNSResolver() agentDNSResolver {
	if s.agentResolver != nil {
		return s.agentResolver
	}
	return net.DefaultResolver
}

func (s *Server) agentHTTPClient(target agentPinnedTarget) *http.Client {
	if s.agentClientFactory != nil {
		return s.agentClientFactory(target, s.cfg)
	}
	return newPinnedAgentHTTPClient(target, s.cfg)
}

func (s *Server) agentMaxRequestBytes() int64 {
	if s.cfg.AgentMaxRequestBytes > 0 {
		return s.cfg.AgentMaxRequestBytes
	}
	return defaultAgentMaxRequestBytes
}

func (s *Server) agentMaxResponseBytes() int64 {
	if s.cfg.AgentMaxResponseBytes > 0 {
		return s.cfg.AgentMaxResponseBytes
	}
	return defaultAgentMaxResponseBytes
}

func (s *Server) agentUpstreamTimeout() time.Duration {
	if s.cfg.AgentUpstreamTimeout > 0 {
		return s.cfg.AgentUpstreamTimeout
	}
	return defaultAgentUpstreamTimeout
}

func (s *Server) writeAgentJSONResponse(w http.ResponseWriter, upstreamResponse *http.Response) (agentTermination, int64) {
	maxBytes := s.agentMaxResponseBytes()
	body, err := io.ReadAll(io.LimitReader(upstreamResponse.Body, maxBytes+1))
	if err != nil {
		writeError(w, http.StatusBadGateway, "provider_unavailable", "provider response could not be read")
		return agentTermUnavailable, 0
	}
	if int64(len(body)) > maxBytes {
		writeError(w, http.StatusBadGateway, "provider_response_too_large", "provider response exceeded the relay limit")
		return agentTermSizeLimit, 0
	}
	w.Header().Set("Content-Type", "application/json")
	w.Header().Set("Cache-Control", "no-store")
	w.WriteHeader(upstreamResponse.StatusCode)
	written, writeErr := w.Write(body)
	if writeErr != nil {
		return agentTermCancelled, int64(written)
	}
	return agentTermCompleted, int64(written)
}

func (s *Server) streamAgentResponse(w http.ResponseWriter, upstreamResponse *http.Response) (agentTermination, int64) {
	flusher, ok := w.(http.Flusher)
	if !ok {
		writeError(w, http.StatusInternalServerError, "streaming_unavailable", "streaming is unavailable")
		return agentTermUnavailable, 0
	}
	w.Header().Set("Content-Type", "text/event-stream")
	w.Header().Set("Cache-Control", "no-store")
	w.Header().Set("X-Accel-Buffering", "no")
	w.Header().Set("Trailer", "X-Fittin-Agent-Termination")
	w.WriteHeader(upstreamResponse.StatusCode)
	flusher.Flush()

	remaining := s.agentMaxResponseBytes()
	var total int64
	buffer := make([]byte, 16<<10)
	for remaining > 0 {
		readSize := len(buffer)
		if int64(readSize) > remaining {
			readSize = int(remaining)
		}
		count, readErr := upstreamResponse.Body.Read(buffer[:readSize])
		if count > 0 {
			written, writeErr := w.Write(buffer[:count])
			remaining -= int64(written)
			total += int64(written)
			if writeErr != nil || written != count {
				w.Header().Set("X-Fittin-Agent-Termination", string(agentTermCancelled))
				return agentTermCancelled, total
			}
			flusher.Flush()
		}
		if readErr != nil {
			reason := agentTermUnavailable
			if errors.Is(readErr, io.EOF) {
				reason = agentTermCompleted
			}
			if errors.Is(readErr, errAgentIdleTimeout) {
				reason = agentTermIdleTimeout
			}
			w.Header().Set("X-Fittin-Agent-Termination", string(reason))
			return reason, total
		}
	}
	w.Header().Set("X-Fittin-Agent-Termination", string(agentTermSizeLimit))
	return agentTermSizeLimit, total
}

func writeAgentUpstreamError(w http.ResponseWriter, status int) {
	switch status {
	case http.StatusUnauthorized, http.StatusForbidden:
		writeError(w, http.StatusBadGateway, "provider_auth_failed", "provider rejected the supplied credential")
	case http.StatusTooManyRequests:
		writeError(w, http.StatusTooManyRequests, "provider_rate_limited", "provider rate limit reached")
	case http.StatusRequestTimeout, http.StatusGatewayTimeout:
		writeError(w, http.StatusGatewayTimeout, "provider_timeout", "provider response timed out")
	default:
		if status >= 400 && status < 500 {
			writeError(w, http.StatusBadGateway, "provider_request_rejected", "provider rejected the request")
			return
		}
		writeError(w, http.StatusBadGateway, "provider_unavailable", "provider is unavailable")
	}
}

func drainAgentResponse(body io.Reader, maxBytes int64) {
	_, _ = io.Copy(io.Discard, io.LimitReader(body, maxBytes))
}

func validJSONObject(payload json.RawMessage) bool {
	if len(payload) == 0 || !json.Valid(payload) {
		return false
	}
	var object map[string]json.RawMessage
	return json.Unmarshal(payload, &object) == nil && object != nil
}

func validAgentCredential(credential string) bool {
	return credential != "" && len(credential) <= 16<<10 && strings.TrimSpace(credential) == credential && !strings.ContainsAny(credential, "\r\n\x00")
}

func normalizedAgentMediaType(contentType string) string {
	if strings.TrimSpace(contentType) == "" {
		return "application/json"
	}
	mediaType, _, err := mime.ParseMediaType(contentType)
	if err != nil {
		return ""
	}
	return strings.ToLower(mediaType)
}
