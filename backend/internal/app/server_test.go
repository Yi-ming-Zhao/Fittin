package app

import (
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"
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
	server := &Server{}
	handler := server.withCORS(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		writeJSON(w, http.StatusOK, map[string]any{"ok": true})
	}))

	request := httptest.NewRequest(http.MethodGet, "/healthz", nil)
	request.Header.Set("Origin", "https://fittin.yimelo.cc")
	recorder := httptest.NewRecorder()

	handler.ServeHTTP(recorder, request)

	if recorder.Code != http.StatusOK {
		t.Fatalf("expected 200, got %d", recorder.Code)
	}
	if got := recorder.Header().Get("Access-Control-Allow-Origin"); got != "https://fittin.yimelo.cc" {
		t.Fatalf("expected allow-origin header for public web origin, got %q", got)
	}
}

func TestWithCORSHandlesPreflight(t *testing.T) {
	server := &Server{}
	handler := server.withCORS(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		t.Fatal("wrapped handler should not run for preflight")
	}))

	request := httptest.NewRequest(http.MethodOptions, "/healthz", nil)
	request.Header.Set("Origin", "https://fittin.yimelo.cc")
	request.Header.Set("Access-Control-Request-Method", http.MethodGet)
	recorder := httptest.NewRecorder()

	handler.ServeHTTP(recorder, request)

	if recorder.Code != http.StatusNoContent {
		t.Fatalf("expected 204, got %d", recorder.Code)
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
