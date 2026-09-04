package app

import (
	"context"
	"net/http"
	"net/http/httptest"
	"os"
	"path/filepath"
	"strings"
	"testing"
	"time"

	"github.com/golang-jwt/jwt/v5"
	"github.com/google/uuid"
	"github.com/jackc/pgx/v5/pgconn"
	"github.com/jackc/pgx/v5/pgtype"
)

type recordingAuthExecutor struct {
	query string
	args  []any
}

func (executor *recordingAuthExecutor) Exec(_ context.Context, query string, args ...any) (pgconn.CommandTag, error) {
	executor.query = query
	executor.args = args
	return pgconn.NewCommandTag("INSERT 0 1"), nil
}

func TestRefreshTokenRoundTripUsesDigest(t *testing.T) {
	server := &Server{cfg: Config{JWTSecret: "test-secret"}}
	sessionID := uuid.NewString()
	token, storedHash, err := server.refreshTokenForRotation(sessionID, 0)
	if err != nil {
		t.Fatalf("refreshTokenForRotation returned error: %v", err)
	}
	parsedSessionID, parsedHash, err := parseRefreshToken(token)
	if err != nil {
		t.Fatalf("parseRefreshToken returned error: %v", err)
	}
	if parsedSessionID != sessionID {
		t.Fatalf("session id mismatch: got %q want %q", parsedSessionID, sessionID)
	}
	if !equalRefreshHash(storedHash, parsedHash) {
		t.Fatal("parsed digest did not match stored digest")
	}
	if strings.Contains(string(storedHash), token) {
		t.Fatal("stored digest unexpectedly contains the plaintext refresh token")
	}

	secondToken, secondHash, err := server.refreshTokenForRotation(sessionID, 1)
	if err != nil {
		t.Fatalf("second refreshTokenForRotation returned error: %v", err)
	}
	if secondToken == token || equalRefreshHash(storedHash, secondHash) {
		t.Fatal("refresh token generator reused a credential")
	}
}

func TestRefreshCapableSessionPersistsDigestAndUsesRollingTTL(t *testing.T) {
	server := &Server{cfg: Config{
		JWTSecret:       "test-secret",
		AccessTokenTTL:  15 * time.Minute,
		RefreshTokenTTL: 180 * 24 * time.Hour,
	}}
	executor := &recordingAuthExecutor{}
	startedAt := time.Now().UTC()

	issued, err := server.issueAuthSessionWithExecutor(
		context.Background(),
		executor,
		"user-1",
		"user@example.test",
		"device-1",
		true,
	)
	if err != nil {
		t.Fatalf("issue refresh-capable session: %v", err)
	}
	if !issued.HasRefreshToken || issued.RefreshToken == "" {
		t.Fatal("refresh-capable session omitted its refresh credential")
	}
	if got := issued.AccessTokenExpiresAt.Sub(startedAt); got < 14*time.Minute || got > 16*time.Minute {
		t.Fatalf("access TTL is not short-lived: %s", got)
	}
	if got := issued.RefreshTokenExpiresAt.Sub(startedAt); got < 179*24*time.Hour || got > 181*24*time.Hour {
		t.Fatalf("refresh TTL is not approximately 180 days: %s", got)
	}
	if !strings.Contains(executor.query, "refresh_token_hash") || len(executor.args) != 6 {
		t.Fatalf("refresh digest was not inserted: %q %#v", executor.query, executor.args)
	}
	storedHash, ok := executor.args[5].([]byte)
	if !ok {
		t.Fatalf("refresh digest argument has unexpected type: %T", executor.args[5])
	}
	parsedSessionID, expectedHash, err := parseRefreshToken(issued.RefreshToken)
	if err != nil {
		t.Fatalf("parse issued refresh token: %v", err)
	}
	if executor.args[0] != parsedSessionID || !equalRefreshHash(storedHash, expectedHash) {
		t.Fatal("stored session id or refresh digest does not match the issued token")
	}
	for _, arg := range executor.args {
		if value, ok := arg.(string); ok && value == issued.RefreshToken {
			t.Fatal("plaintext refresh credential was passed to persistence")
		}
	}
}

func TestParseRefreshTokenRejectsMalformedCredentials(t *testing.T) {
	for _, token := range []string{
		"",
		"missing-dot",
		"not-a-uuid.secret",
		uuid.NewString() + ".short",
		uuid.NewString() + ".%%%%",
	} {
		if _, _, err := parseRefreshToken(token); err == nil {
			t.Fatalf("expected malformed token %q to be rejected", token)
		}
	}
}

func TestClassifyRefreshCredentialDistinguishesRaceFromReuse(t *testing.T) {
	server := &Server{cfg: Config{JWTSecret: "test-secret"}}
	sessionID := uuid.NewString()
	_, currentHash, err := server.refreshTokenForRotation(sessionID, 2)
	if err != nil {
		t.Fatalf("new current refresh token: %v", err)
	}
	_, previousHash, err := server.refreshTokenForRotation(sessionID, 1)
	if err != nil {
		t.Fatalf("new previous refresh token: %v", err)
	}
	_, unrelatedHash, err := server.refreshTokenForRotation(sessionID, 3)
	if err != nil {
		t.Fatalf("new unrelated refresh token: %v", err)
	}
	now := time.Now().UTC()

	tests := []struct {
		name      string
		presented []byte
		rotatedAt pgtype.Timestamptz
		want      refreshCredentialMatch
	}{
		{
			name:      "current credential rotates",
			presented: currentHash,
			want:      refreshCredentialCurrent,
		},
		{
			name:      "concurrent previous credential asks client to retry",
			presented: previousHash,
			rotatedAt: pgtype.Timestamptz{Time: now.Add(-time.Second), Valid: true},
			want:      refreshCredentialPreviousRace,
		},
		{
			name:      "old previous credential is reuse",
			presented: previousHash,
			rotatedAt: pgtype.Timestamptz{Time: now.Add(-refreshRaceGrace - time.Second), Valid: true},
			want:      refreshCredentialPreviousReuse,
		},
		{
			name:      "unknown credential is invalid",
			presented: unrelatedHash,
			want:      refreshCredentialInvalid,
		},
	}

	for _, test := range tests {
		t.Run(test.name, func(t *testing.T) {
			got := classifyRefreshCredential(
				test.presented,
				currentHash,
				previousHash,
				test.rotatedAt,
				now,
			)
			if got != test.want {
				t.Fatalf("classification mismatch: got %d want %d", got, test.want)
			}
		})
	}
}

func TestConcurrentRefreshRequestsConvergeOnWinnerCredential(t *testing.T) {
	server := &Server{cfg: Config{JWTSecret: "test-secret"}}
	sessionID := uuid.NewString()
	presentedToken, presentedHash, err := server.refreshTokenForRotation(sessionID, 0)
	if err != nil {
		t.Fatalf("build presented token: %v", err)
	}
	winnerToken, winnerHash, err := server.refreshTokenForRotation(sessionID, 1)
	if err != nil {
		t.Fatalf("build winner token: %v", err)
	}
	now := time.Now().UTC()
	if !shouldRotateRefreshCredential(
		refreshCredentialCurrent,
		pgtype.Timestamptz{Time: now.Add(-refreshRaceGrace - time.Second), Valid: true},
		now,
	) {
		t.Fatal("an established current credential should rotate")
	}
	if got := classifyRefreshCredential(
		presentedHash,
		winnerHash,
		presentedHash,
		pgtype.Timestamptz{Time: now, Valid: true},
		now,
	); got != refreshCredentialPreviousRace {
		t.Fatalf("second waiter did not observe the winner: got %d", got)
	}
	if shouldRotateRefreshCredential(
		refreshCredentialCurrent,
		pgtype.Timestamptz{Time: now, Valid: true},
		now,
	) {
		t.Fatal("a current credential inside the convergence window rotated twice")
	}

	waiterToken, waiterHash, err := server.refreshTokenForRotation(sessionID, 1)
	if err != nil {
		t.Fatalf("reconstruct winner token: %v", err)
	}
	if waiterToken != winnerToken || !equalRefreshHash(waiterHash, winnerHash) {
		t.Fatal("concurrent waiter would return a different refresh credential")
	}
	if waiterToken == presentedToken {
		t.Fatal("concurrent waiter returned the already-rotated credential")
	}
}

func TestRefreshAndBootstrapMutationsHoldSessionRowLock(t *testing.T) {
	contents, err := os.ReadFile("server.go")
	if err != nil {
		t.Fatalf("read server source: %v", err)
	}
	source := string(contents)
	for _, functionName := range []string{"bootstrapRefreshSession", "rotateRefreshSession"} {
		start := strings.Index(source, "func (s *Server) "+functionName)
		if start < 0 {
			t.Fatalf("missing %s", functionName)
		}
		remainder := source[start+1:]
		endOffset := strings.Index(remainder, "\nfunc ")
		if endOffset < 0 {
			endOffset = len(remainder)
		}
		body := remainder[:endOffset]
		for _, required := range []string{"s.db.Begin(ctx)", "for update", "tx.Commit(ctx)"} {
			if !strings.Contains(body, required) {
				t.Fatalf("%s does not enforce %q inside one transaction", functionName, required)
			}
		}
	}
}

func TestShortAccessTokenUsesConfiguredTTLAndClaims(t *testing.T) {
	server := &Server{cfg: Config{
		JWTSecret:      "test-secret",
		AccessTokenTTL: 15 * time.Minute,
	}}
	now := time.Now().UTC().Truncate(time.Second)
	token, err := server.issueTokenWithSessionTTL(
		"user-1",
		"user@example.test",
		"session-1",
		now,
		server.accessTokenTTL(),
	)
	if err != nil {
		t.Fatalf("issueTokenWithSessionTTL returned error: %v", err)
	}
	claims := jwt.MapClaims{}
	_, err = jwt.ParseWithClaims(token, claims, func(_ *jwt.Token) (any, error) {
		return []byte("test-secret"), nil
	})
	if err != nil {
		t.Fatalf("issued token did not parse: %v", err)
	}
	expiresAt, err := claims.GetExpirationTime()
	if err != nil || expiresAt == nil {
		t.Fatalf("issued token has no valid expiry: %v", err)
	}
	if got, want := expiresAt.Time, now.Add(15*time.Minute); !got.Equal(want) {
		t.Fatalf("expiry mismatch: got %s want %s", got, want)
	}
	if claims["typ"] != "access" || claims["iss"] != "fittin" {
		t.Fatalf("missing typed access claims: %#v", claims)
	}
}

func TestWebAuthResponseSetsSecureHTTPOnlyRefreshCookie(t *testing.T) {
	server := &Server{}
	request := httptest.NewRequest(http.MethodPost, "/v1/auth/refresh", nil)
	request.Header.Set(authPlatformHeader, "web")
	request.Header.Set("X-Forwarded-Proto", "https")
	recorder := httptest.NewRecorder()
	expiresAt := time.Now().UTC().Add(180 * 24 * time.Hour)

	server.writeAuthResponse(
		recorder,
		request,
		http.StatusOK,
		issuedAuthSession{
			AccessToken:           "access",
			RefreshToken:          "session.secret",
			RefreshTokenExpiresAt: expiresAt,
			HasRefreshToken:       true,
		},
		map[string]any{"id": "user-1"},
	)

	cookies := recorder.Result().Cookies()
	if len(cookies) != 1 {
		t.Fatalf("expected one refresh cookie, got %d", len(cookies))
	}
	cookie := cookies[0]
	if cookie.Name != refreshCookieName || cookie.Value != "session.secret" {
		t.Fatalf("unexpected refresh cookie: %#v", cookie)
	}
	if !cookie.HttpOnly || !cookie.Secure || cookie.SameSite != http.SameSiteStrictMode {
		t.Fatalf("refresh cookie lacks security attributes: %#v", cookie)
	}
	if strings.Contains(recorder.Body.String(), "session.secret") {
		t.Fatal("Web auth response exposed the refresh credential in JSON")
	}
}

func TestAuthProtocolNegotiationProtectsLegacyClients(t *testing.T) {
	legacy := httptest.NewRequest(http.MethodGet, "/v1/auth/session", nil)
	if supportsRefreshSessions(legacy) {
		t.Fatal("legacy client unexpectedly negotiated refresh sessions")
	}
	current := httptest.NewRequest(http.MethodGet, "/v1/auth/session", nil)
	current.Header.Set(authProtocolVersionHeader, "2")
	if !supportsRefreshSessions(current) {
		t.Fatal("v2 client did not negotiate refresh sessions")
	}
}

func TestAuthResponsesAreNeverCacheable(t *testing.T) {
	server := &Server{}
	handler := server.withNoStore(func(w http.ResponseWriter, _ *http.Request) {
		writeJSON(w, http.StatusOK, map[string]any{"ok": true})
	})
	recorder := httptest.NewRecorder()
	handler(recorder, httptest.NewRequest(http.MethodGet, "/v1/auth/session", nil))
	if got := recorder.Header().Get("Cache-Control"); got != "no-store" {
		t.Fatalf("unexpected Cache-Control: %q", got)
	}
	if got := recorder.Header().Get("Pragma"); got != "no-cache" {
		t.Fatalf("unexpected Pragma: %q", got)
	}
}

func TestRefreshRejectsMissingWebCookieAsDefinitiveAuthFailure(t *testing.T) {
	server := &Server{}
	request := httptest.NewRequest(http.MethodPost, "/v1/auth/refresh", strings.NewReader("{}"))
	request.Header.Set(authProtocolVersionHeader, "2")
	request.Header.Set(authPlatformHeader, "web")
	recorder := httptest.NewRecorder()

	server.handleRefresh(recorder, request)

	if recorder.Code != http.StatusUnauthorized {
		t.Fatalf("expected 401, got %d: %s", recorder.Code, recorder.Body.String())
	}
	if !strings.Contains(recorder.Body.String(), `"code":"refresh_invalid"`) {
		t.Fatalf("missing typed refresh error: %s", recorder.Body.String())
	}
}

func TestRefreshRejectsOversizedNativePayload(t *testing.T) {
	server := &Server{}
	body := `{"refreshToken":"` + strings.Repeat("x", int(maxRefreshBodyBytes)) + `"}`
	request := httptest.NewRequest(http.MethodPost, "/v1/auth/refresh", strings.NewReader(body))
	request.Header.Set(authProtocolVersionHeader, "2")
	request.Header.Set(authPlatformHeader, "native")
	recorder := httptest.NewRecorder()

	server.handleRefresh(recorder, request)

	if recorder.Code != http.StatusRequestEntityTooLarge {
		t.Fatalf("expected 413, got %d: %s", recorder.Code, recorder.Body.String())
	}
	if !strings.Contains(recorder.Body.String(), `"code":"refresh_request_too_large"`) {
		t.Fatalf("missing typed size error: %s", recorder.Body.String())
	}
}

func TestAuthRateLimitResponseIsTypedAndNeverCacheable(t *testing.T) {
	server := &Server{
		cfg:      Config{RateLimitPerMin: 1},
		rateByIP: make(map[string]rateWindow),
	}
	handler := server.withRateLimit(http.HandlerFunc(func(w http.ResponseWriter, _ *http.Request) {
		w.WriteHeader(http.StatusNoContent)
	}))
	request := func() *http.Request {
		req := httptest.NewRequest(http.MethodPost, "/v1/auth/refresh", strings.NewReader("{}"))
		req.RemoteAddr = "203.0.113.10:4321"
		return req
	}

	first := httptest.NewRecorder()
	handler.ServeHTTP(first, request())
	if first.Code != http.StatusNoContent {
		t.Fatalf("first request should pass, got %d", first.Code)
	}
	second := httptest.NewRecorder()
	handler.ServeHTTP(second, request())
	if second.Code != http.StatusTooManyRequests {
		t.Fatalf("expected rate limit, got %d: %s", second.Code, second.Body.String())
	}
	if !strings.Contains(second.Body.String(), `"code":"rate_limited"`) {
		t.Fatalf("missing typed rate error: %s", second.Body.String())
	}
	if got := second.Header().Get("Cache-Control"); got != "no-store" {
		t.Fatalf("rate response may be cached: %q", got)
	}
}

func TestAccessTokenFailuresUseTypedErrors(t *testing.T) {
	server := &Server{cfg: Config{JWTSecret: "test-secret"}}
	handler := server.withAuth(func(w http.ResponseWriter, _ *http.Request) {
		w.WriteHeader(http.StatusNoContent)
	})
	expired, err := server.issueTokenWithSessionTTL(
		"user-1",
		"user@example.test",
		"session-1",
		time.Now().UTC().Add(-2*time.Minute),
		time.Minute,
	)
	if err != nil {
		t.Fatalf("issue expired access token: %v", err)
	}

	tests := []struct {
		name  string
		token string
		code  string
	}{
		{name: "missing", code: "missing_bearer_token"},
		{name: "invalid", token: "not-a-jwt", code: "access_token_invalid"},
		{name: "expired", token: expired, code: "access_token_expired"},
	}
	for _, test := range tests {
		t.Run(test.name, func(t *testing.T) {
			request := httptest.NewRequest(http.MethodGet, "/v1/auth/session", nil)
			if test.token != "" {
				request.Header.Set("Authorization", "Bearer "+test.token)
			}
			recorder := httptest.NewRecorder()
			handler(recorder, request)
			if recorder.Code != http.StatusUnauthorized {
				t.Fatalf("expected 401, got %d: %s", recorder.Code, recorder.Body.String())
			}
			if !strings.Contains(recorder.Body.String(), `"code":"`+test.code+`"`) {
				t.Fatalf("missing typed access error %q: %s", test.code, recorder.Body.String())
			}
		})
	}
}

func TestRefreshMigrationStoresOnlyDigests(t *testing.T) {
	path := filepath.Join("..", "..", "migrations", "20260905_000004_refresh_sessions.sql")
	contents, err := os.ReadFile(path)
	if err != nil {
		t.Fatalf("read refresh migration: %v", err)
	}
	sql := string(contents)
	for _, required := range []string{
		"refresh_token_hash bytea",
		"previous_refresh_token_hash bytea",
		"rotation_counter bigint",
	} {
		if !strings.Contains(sql, required) {
			t.Fatalf("refresh migration missing %q", required)
		}
	}
	if strings.Contains(sql, "refresh_token text") {
		t.Fatal("refresh migration must not persist plaintext credentials")
	}
}
