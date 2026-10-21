package app

import (
	"context"
	"encoding/json"
	"fmt"
	"net/http"
	"net/http/httptest"
	"os"
	"path/filepath"
	"strings"
	"testing"
)

func TestPrivateRouteIsolationCommitConflictAndDelete(t *testing.T) {
	s := &Server{cfg: Config{FileStorageRoot: t.TempDir()}}
	id := "cardio-record:11111111-1111-4111-8111-111111111111"
	owner := "22222222-2222-4222-8222-222222222222"
	other := "33333333-3333-4333-8333-333333333333"
	request := func(user, method, path, body string) *httptest.ResponseRecorder {
		r := httptest.NewRequest(method, "/v1/private-routes/"+id+path, strings.NewReader(body))
		r = r.WithContext(context.WithValue(r.Context(), contextKeyUserID{}, user))
		w := httptest.NewRecorder()
		s.handlePrivateRoute(w, r)
		return w
	}
	chunk := `{"points":[{"latitude":30,"longitude":120,"timestamp":"2026-10-21T01:00:00Z","segment":0,"coordinateSystem":"WGS84"}]}`
	hash := routeDigest([]byte(chunk))
	if got := request(owner, "PUT", "/chunks/"+hash, chunk); got.Code != 201 {
		t.Fatalf("upload: %d %s", got.Code, got.Body.String())
	}
	if got := request(owner, "PUT", "/chunks/"+hash, chunk); got.Code != 204 {
		t.Fatalf("retry: %d", got.Code)
	}
	if got := request(owner, "GET", "/chunks/"+hash, ""); got.Code != 404 {
		t.Fatalf("staging must not be downloadable: %d", got.Code)
	}
	session := map[string]any{"id": id, "phase": "finished", "startedAt": "2026-10-21T01:00:00Z", "activityName": "Run", "elapsedMilliseconds": 60000, "activeMilliseconds": 60000, "distanceMeters": 100}
	manifest := func(version int) string {
		body, _ := json.Marshal(map[string]any{"expectedVersion": version, "session": session, "chunks": []string{hash}})
		return string(body)
	}
	if got := request(owner, "PUT", "/manifest", manifest(0)); got.Code != 200 {
		t.Fatalf("commit: %d %s", got.Code, got.Body.String())
	}
	if got := request(owner, "PUT", "/manifest", manifest(0)); got.Code != 200 {
		t.Fatalf("commit retry: %d", got.Code)
	}
	// A real HTTP client may pretty-print or reorder fields. Marshal compacts
	// RawMessage when saving; wire-byte comparison incorrectly rejected retries.
	reordered := `{"expectedVersion":0,"session":{
		"phase":"finished", "id":"` + id + `", "distanceMeters":100,
		"activeMilliseconds":60000, "elapsedMilliseconds":60000,
		"activityName":"Run", "startedAt":"2026-10-21T01:00:00Z"
	},"chunks":["` + hash + `"]}`
	if got := request(owner, "PUT", "/manifest", reordered); got.Code != 200 {
		t.Fatalf("formatted/reordered retry: %d", got.Code)
	}
	session["activityName"] = "Changed"
	if got := request(owner, "PUT", "/manifest", manifest(0)); got.Code != 409 {
		t.Fatalf("stale commit: %d", got.Code)
	}
	if got := request(other, "GET", "/manifest", ""); got.Code != 404 {
		t.Fatalf("other owner manifest: %d", got.Code)
	}
	if got := request(other, "GET", "/chunks/"+hash, ""); got.Code != 404 {
		t.Fatalf("other owner chunk: %d", got.Code)
	}
	if got := request(owner, "GET", "/chunks/"+hash, ""); got.Code != 200 || got.Body.String() != chunk || got.Header().Get("Cache-Control") != "no-store" {
		t.Fatal("download did not preserve private chunk")
	}
	if got := request(owner, "DELETE", "/manifest?version=0", ""); got.Code != 409 {
		t.Fatalf("stale deletion: %d", got.Code)
	}
	if got := request(owner, "DELETE", "/manifest?version=1", ""); got.Code != 204 {
		t.Fatalf("delete: %d", got.Code)
	}
	if got := request(owner, "GET", "/chunks/"+hash, ""); got.Code != 404 {
		t.Fatalf("deleted chunk: %d", got.Code)
	}
	if got := request(owner, "PUT", "/chunks/"+hash, chunk); got.Code != 201 {
		t.Fatalf("reupload: %d", got.Code)
	}
	if got := request(owner, "PUT", "/manifest", manifest(0)); got.Code != 409 {
		t.Fatalf("reset version accepted: %d", got.Code)
	}
	if got := request(owner, "PUT", "/manifest", manifest(2)); got.Code != 200 {
		t.Fatalf("recreate: %d %s", got.Code, got.Body.String())
	}
	if got := request(owner, "DELETE", "/manifest?version=1", ""); got.Code != 409 {
		t.Fatalf("old deletion removed new route: %d", got.Code)
	}
	if got := request(owner, "GET", "/chunks/"+hash, ""); got.Code != 200 {
		t.Fatal("new route was lost")
	}
}

func TestPrivateRouteInventoryIncludesStagingAndIsOwnerScoped(t *testing.T) {
	s := &Server{cfg: Config{FileStorageRoot: t.TempDir()}}
	owner := "22222222-2222-4222-8222-222222222222"
	for i := 0; i < 51; i++ {
		id := fmt.Sprintf("11111111-1111-4111-8111-%012d", i)
		if err := os.MkdirAll(filepath.Join(s.cfg.FileStorageRoot, "users", owner, "private_routes", id), 0700); err != nil {
			t.Fatal(err)
		}
	}
	list := func(user, after string) map[string]any {
		r := httptest.NewRequest("GET", "/v1/private-routes/?after="+after, nil)
		r = r.WithContext(context.WithValue(r.Context(), contextKeyUserID{}, user))
		w := httptest.NewRecorder()
		s.handlePrivateRoute(w, r)
		if w.Code != 200 || w.Header().Get("Cache-Control") != "no-store" {
			t.Fatalf("inventory: %d", w.Code)
		}
		var data map[string]any
		if err := json.Unmarshal(w.Body.Bytes(), &data); err != nil {
			t.Fatal(err)
		}
		return data
	}
	first := list(owner, "")
	if len(first["items"].([]any)) != 50 || first["nextCursor"] == "" {
		t.Fatal("first page")
	}
	if first["items"].([]any)[0].(map[string]any)["version"] != float64(0) {
		t.Fatal("staging deletion version")
	}
	last := list(owner, first["nextCursor"].(string))
	if len(last["items"].([]any)) != 1 || last["nextCursor"] != "" {
		t.Fatal("last page")
	}
	if len(list("33333333-3333-4333-8333-333333333333", "")["items"].([]any)) != 0 {
		t.Fatal("owner leak")
	}
}

func TestPrivateRouteRequestSizeDigestAndInternalFields(t *testing.T) {
	s := &Server{cfg: Config{FileStorageRoot: t.TempDir()}}
	id := "cardio-record:11111111-1111-4111-8111-111111111111"
	request := func(suffix, body string) int {
		r := httptest.NewRequest("PUT", "/v1/private-routes/"+id+suffix, strings.NewReader(body))
		r = r.WithContext(context.WithValue(r.Context(), contextKeyUserID{}, "22222222-2222-4222-8222-222222222222"))
		w := httptest.NewRecorder()
		s.handlePrivateRoute(w, r)
		return w.Code
	}
	if code := request("/chunks/"+strings.Repeat("0", 64), strings.Repeat("x", (256<<10)+1)); code != 413 {
		t.Fatalf("size: %d", code)
	}
	chunk := `{"points":[{"latitude":30,"longitude":120,"timestamp":"2026-10-21T01:00:00Z","segment":0,"coordinateSystem":"WGS84"}]}`
	if code := request("/chunks/"+strings.Repeat("0", 64), chunk); code != 400 {
		t.Fatalf("digest: %d", code)
	}
	session := `{"id":"` + id + `","phase":"finished","startedAt":"2026-10-21T01:00:00Z","ownerUserId":"other"}`
	if validRouteSession([]byte(session), id) {
		t.Fatal("accepted owner field")
	}
}

func TestPrivateRouteRejectsAuthTraversalAndMalformedCoordinates(t *testing.T) {
	s := &Server{cfg: Config{FileStorageRoot: t.TempDir(), JWTSecret: "unit-test-only"}}
	r := httptest.NewRequest(http.MethodGet, "/v1/private-routes/cardio-record:11111111-1111-4111-8111-111111111111/manifest", nil)
	w := httptest.NewRecorder()
	s.withAuth(s.handlePrivateRoute)(w, r)
	if w.Code != 401 {
		t.Fatalf("authentication: %d", w.Code)
	}
	for _, data := range []string{
		`{"points":[]}`,
		`{"points":[{"latitude":91,"longitude":120,"timestamp":"2026-10-21T01:00:00Z","coordinateSystem":"WGS84"}]}`,
		`{"points":[{"latitude":30,"longitude":120,"timestamp":"2026-10-21T01:00:00Z","coordinateSystem":"GCJ02"}]}`,
		`{"points":[{"latitude":30,"longitude":120,"timestamp":"bad","coordinateSystem":"WGS84"}]}`,
		`{"points":[{"latitude":30,"longitude":120,"timestamp":"2026-10-21T01:00:00Z","coordinateSystem":"WGS84","owner":"other"}]}`,
	} {
		if validRouteChunk([]byte(data)) {
			t.Fatal("accepted malformed route")
		}
	}
	for _, path := range []string{"../../other/manifest", "cardio-record:bad/manifest", "cardio-record:11111111-1111-4111-8111-111111111111/chunks/../manifest"} {
		r := httptest.NewRequest("GET", "/v1/private-routes/"+path, nil)
		r = r.WithContext(context.WithValue(r.Context(), contextKeyUserID{}, "22222222-2222-4222-8222-222222222222"))
		w := httptest.NewRecorder()
		s.handlePrivateRoute(w, r)
		if w.Code < 400 {
			t.Fatalf("accepted invalid path %s", path)
		}
	}
}
