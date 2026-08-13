package app

import (
	"net/http"
	"net/http/httptest"
	"strconv"
	"strings"
	"testing"
	"time"
)

func TestHandleRootReturnsServiceMetadata(t *testing.T) {
	server := &Server{}
	request := httptest.NewRequest(http.MethodGet, "/", nil)
	recorder := httptest.NewRecorder()

	server.handleRoot(recorder, request)

	if recorder.Code != http.StatusOK {
		t.Fatalf("expected 200, got %d", recorder.Code)
	}
	body := recorder.Body.String()
	if body == "" || !containsAll(body, "fittin-backend", "/healthz", "\"ok\":true") {
		t.Fatalf("unexpected response body: %s", body)
	}
}

func TestWithCORSPermitsPublicWebOrigin(t *testing.T) {
	server := &Server{cfg: Config{AllowedOrigins: map[string]bool{
		"https://fittin.hammerscholar.net": true,
	}}}
	handler := server.withCORS(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		writeJSON(w, http.StatusOK, map[string]any{"ok": true})
	}))

	request := httptest.NewRequest(http.MethodGet, "/healthz", nil)
	request.Header.Set("Origin", "https://fittin.hammerscholar.net")
	recorder := httptest.NewRecorder()

	handler.ServeHTTP(recorder, request)

	if recorder.Code != http.StatusOK {
		t.Fatalf("expected 200, got %d", recorder.Code)
	}
	if got := recorder.Header().Get("Access-Control-Allow-Origin"); got != "https://fittin.hammerscholar.net" {
		t.Fatalf("expected allow-origin header for public web origin, got %q", got)
	}
}

func TestWithCORSHandlesPreflight(t *testing.T) {
	server := &Server{cfg: Config{AllowedOrigins: map[string]bool{
		"https://fittin.hammerscholar.net": true,
	}}}
	handler := server.withCORS(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		t.Fatal("wrapped handler should not run for preflight")
	}))

	request := httptest.NewRequest(http.MethodOptions, "/healthz", nil)
	request.Header.Set("Origin", "https://fittin.hammerscholar.net")
	request.Header.Set("Access-Control-Request-Method", http.MethodGet)
	recorder := httptest.NewRecorder()

	handler.ServeHTTP(recorder, request)

	if recorder.Code != http.StatusNoContent {
		t.Fatalf("expected 204, got %d", recorder.Code)
	}
}

func TestWithCORSRejectsLegacyOrigin(t *testing.T) {
	server := &Server{cfg: Config{AllowedOrigins: map[string]bool{
		"https://fittin.hammerscholar.net": true,
	}}}
	handler := server.withCORS(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		writeJSON(w, http.StatusOK, map[string]any{"ok": true})
	}))
	request := httptest.NewRequest(http.MethodGet, "/healthz", nil)
	request.Header.Set("Origin", "https://fittin.yimelo.cc")
	recorder := httptest.NewRecorder()
	handler.ServeHTTP(recorder, request)
	if got := recorder.Header().Get("Access-Control-Allow-Origin"); got != "" {
		t.Fatalf("expected legacy origin to be rejected, got %q", got)
	}
}

func TestSafeStoragePathRejectsTraversal(t *testing.T) {
	root := t.TempDir()
	if _, err := safeStoragePath(root, "../../outside.jpg"); err == nil {
		t.Fatal("expected traversal path to be rejected")
	}
	path, err := safeStoragePath(root, "users/user-123/photo.jpg")
	if err != nil {
		t.Fatalf("expected safe path, got %v", err)
	}
	if !strings.HasPrefix(path, root) {
		t.Fatalf("safe path escaped root: %s", path)
	}
}

func TestNormalizeEmail(t *testing.T) {
	if got := normalizeEmail("  Person@Example.COM "); got != "person@example.com" {
		t.Fatalf("unexpected normalized email: %q", got)
	}
}

func TestClientIPAddressTrustsOnlyLoopbackProxy(t *testing.T) {
	proxied := httptest.NewRequest(http.MethodPost, "/v1/auth/sign-in", nil)
	proxied.RemoteAddr = "127.0.0.1:43120"
	proxied.Header.Set("X-Real-IP", "203.0.113.7")
	if got := clientIPAddress(proxied); got != "203.0.113.7" {
		t.Fatalf("expected trusted proxy client IP, got %q", got)
	}

	direct := httptest.NewRequest(http.MethodPost, "/v1/auth/sign-in", nil)
	direct.RemoteAddr = "198.51.100.4:43120"
	direct.Header.Set("X-Real-IP", "203.0.113.7")
	if got := clientIPAddress(direct); got != "198.51.100.4" {
		t.Fatalf("expected direct peer IP, got %q", got)
	}
}

func TestNormalizeProgressPhotoRowBindsStorageToOwner(t *testing.T) {
	spec := syncTableSpecs["progress_photos"]
	photoID := "3f5b1d64-4549-4dd7-a808-0de15af47f48"
	row := map[string]any{
		"id":           photoID,
		"version":      1,
		"storage_path": "users/user-123/progress_photos/" + photoID + "/original.jpg",
	}
	if _, err := normalizeSyncRow(spec, row, "user-123"); err != nil {
		t.Fatalf("expected owner-bound photo path, got %v", err)
	}

	row["storage_path"] = "users/other-user/progress_photos/" + photoID + "/original.jpg"
	if _, err := normalizeSyncRow(spec, row, "user-123"); err == nil {
		t.Fatal("expected cross-owner photo path to be rejected")
	}
}

func TestNormalizeSyncRowRequiresPositiveIntegralVersion(t *testing.T) {
	spec := syncTableSpecs["plans"]
	base := map[string]any{"id": "plan-1", "version": 1.5}
	if _, err := normalizeSyncRow(spec, base, "user-123"); err == nil {
		t.Fatal("expected fractional version to be rejected")
	}
	base["version"] = 0
	if _, err := normalizeSyncRow(spec, base, "user-123"); err == nil {
		t.Fatal("expected non-positive version to be rejected")
	}
}

func TestWithAuthRejectsMissingBearerToken(t *testing.T) {
	server := &Server{cfg: Config{JWTSecret: "test-secret"}}
	handler := server.withAuth(func(w http.ResponseWriter, r *http.Request) {
		t.Fatal("protected handler should not run without a token")
	})

	request := httptest.NewRequest(http.MethodGet, "/v1/auth/session", nil)
	recorder := httptest.NewRecorder()

	handler(recorder, request)

	if recorder.Code != http.StatusUnauthorized {
		t.Fatalf("expected 401, got %d", recorder.Code)
	}
}

func TestGlobalRateLimitStateHasHardEntryLimit(t *testing.T) {
	now := time.Now()
	server := &Server{
		cfg:             Config{RateLimitPerMin: 60},
		rateByIP:        make(map[string]rateWindow),
		rateLastCleanup: now,
	}
	for index := 0; index < maxRateLimitEntries; index++ {
		server.rateByIP["existing-"+strconv.Itoa(index)] = rateWindow{
			started: now,
			count:   1,
		}
	}
	handler := server.withRateLimit(http.HandlerFunc(func(w http.ResponseWriter, _ *http.Request) {
		t.Fatal("request from a new key must fail closed when the limiter is full")
	}))
	request := httptest.NewRequest(http.MethodPost, "/v1/agent/chat-completions", nil)
	request.RemoteAddr = "8.8.8.8:43120"
	recorder := httptest.NewRecorder()

	handler.ServeHTTP(recorder, request)

	if recorder.Code != http.StatusTooManyRequests {
		t.Fatalf("expected 429, got %d", recorder.Code)
	}
	if len(server.rateByIP) != maxRateLimitEntries {
		t.Fatalf("global rate table grew past hard limit: %d", len(server.rateByIP))
	}
}

func TestWithAuthAllowsValidSessionToken(t *testing.T) {
	server := &Server{cfg: Config{JWTSecret: "test-secret"}}
	token, err := server.issueToken("user-123", "user@example.com")
	if err != nil {
		t.Fatalf("issueToken returned error: %v", err)
	}

	handler := server.withAuth(func(w http.ResponseWriter, r *http.Request) {
		userID, _ := r.Context().Value(contextKeyUserID{}).(string)
		email, _ := r.Context().Value(contextKeyEmail{}).(string)
		writeJSON(w, http.StatusOK, map[string]any{
			"userId": userID,
			"email":  email,
		})
	})

	request := httptest.NewRequest(http.MethodGet, "/v1/auth/session", nil)
	request.Header.Set("Authorization", "Bearer "+token)
	recorder := httptest.NewRecorder()

	handler(recorder, request)

	if recorder.Code != http.StatusOK {
		t.Fatalf("expected 200, got %d", recorder.Code)
	}
	body := recorder.Body.String()
	if body == "" || !containsAll(body, "user-123", "user@example.com") {
		t.Fatalf("unexpected response body: %s", body)
	}
}

func TestProtectedSyncRouteRequiresTableNameAfterAuth(t *testing.T) {
	server := &Server{cfg: Config{JWTSecret: "test-secret"}}
	token, err := server.issueToken("user-123", "user@example.com")
	if err != nil {
		t.Fatalf("issueToken returned error: %v", err)
	}

	handler := server.withAuth(server.handleSync)
	request := httptest.NewRequest(http.MethodGet, "/v1/sync/", nil)
	request.Header.Set("Authorization", "Bearer "+token)
	recorder := httptest.NewRecorder()

	handler(recorder, request)

	if recorder.Code != http.StatusBadRequest {
		t.Fatalf("expected 400, got %d", recorder.Code)
	}
}

func containsAll(body string, needles ...string) bool {
	for _, needle := range needles {
		if !strings.Contains(body, needle) {
			return false
		}
	}
	return true
}
