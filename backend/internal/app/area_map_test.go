package app

import (
	"bytes"
	"context"
	"errors"
	"image/png"
	"io"
	"net/http"
	"net/http/httptest"
	"os"
	"path/filepath"
	"strings"
	"testing"
	"time"
)

func TestAreaMapKeyFile(t *testing.T) {
	path := filepath.Join(t.TempDir(), "key")
	if err := os.WriteFile(path, []byte(strings.Repeat("a", 32)+"\n"), 0600); err != nil {
		t.Fatal(err)
	}
	key, err := loadAMapKey("", path)
	if err != nil || key != strings.Repeat("a", 32) {
		t.Fatal("key file")
	}
	if _, err = loadAMapKey("invalid-secret", ""); err == nil || strings.Contains(err.Error(), "invalid-secret") {
		t.Fatal("invalid key not redacted")
	}
	if err := os.WriteFile(path, []byte(strings.Repeat("a", 129)), 0600); err != nil {
		t.Fatal(err)
	}
	if _, err = loadAMapKey("", path); err == nil {
		t.Fatal("oversized file")
	}
}

func TestAreaMapProviderCanary(t *testing.T) {
	filename := os.Getenv("FITTIN_MAP_CANARY_KEY_FILE")
	if filename == "" {
		t.Skip("requires explicitly supplied private key file")
	}
	key, err := loadAMapKey("", filename)
	if err != nil {
		t.Fatal("key unavailable")
	}
	s := mapTestServer(nil)
	s.mapHTTPClient = nil
	s.cfg.AMapWebServiceKey = key
	w := mapTestRequest(s, mapBody, true)
	if w.Code != 200 {
		t.Fatalf("provider canary HTTP %d", w.Code)
	}
	image, err := png.DecodeConfig(bytes.NewReader(w.Body.Bytes()))
	if err != nil || image.Width != 600 || image.Height != 360 {
		t.Fatal("unexpected provider image")
	}
	t.Logf("real AMap canary: %dx%d PNG, %d bytes", image.Width, image.Height, w.Body.Len())
}

func mapTestRequest(s *Server, body string, authenticated bool) *httptest.ResponseRecorder {
	r := httptest.NewRequest("POST", "/v1/maps/area", strings.NewReader(body))
	if authenticated {
		token, _ := s.issueToken("map-user", "map@example.com")
		r.Header.Set("Authorization", "Bearer "+token)
	}
	w := httptest.NewRecorder()
	s.withAuth(s.handleAreaMap)(w, r)
	return w
}

func mapTestServer(rt http.RoundTripper) *Server {
	return &Server{cfg: Config{JWTSecret: "test", AccessTokenTTL: time.Hour, AMapWebServiceKey: strings.Repeat("a", 32)}, mapHTTPClient: &http.Client{Transport: rt, CheckRedirect: areaMapClient.CheckRedirect}}
}

const mapBody = `{"latitude":39.9,"longitude":116.4,"zoom":15}`
const mapPNG = "\x89PNG\r\n\x1a\n"

func TestAreaMapAuthAndStrictInput(t *testing.T) {
	calls := 0
	s := mapTestServer(agentRoundTripFunc(func(*http.Request) (*http.Response, error) { calls++; return nil, errors.New("unexpected") }))
	if w := mapTestRequest(s, mapBody, false); w.Code != 401 {
		t.Fatal(w.Code)
	}
	for _, body := range []string{`{}`, `{"latitude":91,"longitude":1,"zoom":15}`, `{"latitude":1,"longitude":1,"zoom":18}`, `{"latitude":1,"longitude":1,"zoom":15,"key":"external"}`, mapBody + `{}`, strings.Repeat("x", 1025)} {
		if w := mapTestRequest(s, body, true); w.Code != 400 {
			t.Fatalf("invalid input got %d", w.Code)
		}
	}
	if calls != 0 {
		t.Fatal("invalid input reached provider")
	}
	s.cfg.AMapWebServiceKey = ""
	if w := mapTestRequest(s, mapBody, true); w.Code != 503 {
		t.Fatal(w.Code)
	}
}

func TestAreaMapFixedProviderAndNoStore(t *testing.T) {
	calls := 0
	s := mapTestServer(agentRoundTripFunc(func(r *http.Request) (*http.Response, error) {
		calls++
		if r.URL.Scheme != "https" || r.URL.Host != "restapi.amap.com" || r.Header.Get("Authorization") != "" {
			t.Fatal("unsafe destination or forwarded auth")
		}
		if _, ok := r.Context().Deadline(); !ok {
			t.Fatal("missing deadline")
		}
		if calls == 1 {
			if r.URL.Path != "/v3/assistant/coordinate/convert" || r.URL.Query().Get("locations") != "116.4,39.9" {
				t.Fatal("conversion missing")
			}
			return agentResponse(200, "application/json", `{"status":"1","locations":"116.406,39.901"}`), nil
		}
		if r.URL.Path != "/v3/staticmap" || r.URL.Query().Get("location") != "116.406,39.901" || r.URL.Query().Has("paths") || r.URL.Query().Has("markers") {
			t.Fatal("bad static request")
		}
		return agentResponse(200, "image/png;charset=UTF-8", mapPNG), nil
	}))
	w := mapTestRequest(s, mapBody, true)
	if w.Code != 200 || w.Body.String() != mapPNG || w.Header().Get("Cache-Control") != "no-store" || calls != 2 {
		t.Fatalf("map response %d, calls %d", w.Code, calls)
	}
}

func TestAreaMapProviderErrorsAreBoundedAndRedacted(t *testing.T) {
	for _, mode := range []string{"redirect", "error", "large", "quota", "coordinate", "fake-image", "cancel"} {
		t.Run(mode, func(t *testing.T) {
			calls := 0
			s := mapTestServer(agentRoundTripFunc(func(r *http.Request) (*http.Response, error) {
				calls++
				if mode == "cancel" {
					return nil, context.Canceled
				}
				if mode == "error" {
					return nil, errors.New("secret-key and location 116.4,39.9")
				}
				if mode == "redirect" {
					r := agentResponse(302, "text/plain", "secret-key")
					r.Header.Set("Location", "https://example.com")
					return r, nil
				}
				if mode == "large" {
					return agentResponse(200, "application/json", strings.Repeat("x", 16385)), nil
				}
				if mode == "quota" {
					return agentResponse(200, "application/json", `{"status":"0","info":"secret-key"}`), nil
				}
				if mode == "coordinate" {
					return agentResponse(200, "application/json", `{"status":"1","locations":"NaN,39"}`), nil
				}
				if calls == 1 {
					return agentResponse(200, "application/json", `{"status":"1","locations":"116.4,39.9"}`), nil
				}
				return agentResponse(200, "image/png", "secret-key"), nil
			}))
			w := mapTestRequest(s, mapBody, true)
			if w.Code != 502 || strings.Contains(w.Body.String(), "secret-key") || strings.Contains(w.Body.String(), "116.4") {
				t.Fatalf("unsafe error %d %s", w.Code, w.Body.String())
			}
			if calls > 2 {
				t.Fatal("unexpected retry")
			}
		})
	}
	if areaMapClient.Transport.(*http.Transport).Proxy != nil {
		t.Fatal("environment proxy enabled")
	}
	if areaMapClient.CheckRedirect(nil, nil) != http.ErrUseLastResponse {
		t.Fatal("redirect enabled")
	}
}

func TestAreaMapGateBounds(t *testing.T) {
	var g mapRequestGate
	a, ok := g.acquire("a")
	if !ok {
		t.Fatal("first")
	}
	b, ok := g.acquire("b")
	if !ok {
		t.Fatal("second")
	}
	if _, ok = g.acquire("c"); ok {
		t.Fatal("concurrency")
	}
	a()
	b()
	for i := 0; i < 9; i++ {
		release, ok := g.acquire("a")
		if !ok {
			t.Fatal(i)
		}
		release()
	}
	if _, ok = g.acquire("a"); ok {
		t.Fatal("user rate")
	}
	g.requests = 30
	if _, ok = g.acquire("d"); ok {
		t.Fatal("global rate")
	}
	g.start = time.Now().Add(-2 * time.Minute)
	release, ok := g.acquire("a")
	if !ok {
		t.Fatal("window reset")
	}
	release()
}

func TestAreaMapImageLimitAndRequestCancellation(t *testing.T) {
	ctx, cancel := context.WithCancel(context.Background())
	cancel()
	client := &http.Client{Transport: agentRoundTripFunc(func(r *http.Request) (*http.Response, error) { return nil, r.Context().Err() })}
	if _, _, err := fetchMapProvider(ctx, client, "/v3/staticmap", nil, 2<<20); err == nil {
		t.Fatal("cancel")
	}
	client.Transport = agentRoundTripFunc(func(*http.Request) (*http.Response, error) {
		return &http.Response{StatusCode: 200, ContentLength: -1, Header: http.Header{"Content-Type": []string{"image/png"}}, Body: io.NopCloser(strings.NewReader(strings.Repeat("a", 1025)))}, nil
	})
	if _, _, err := fetchMapProvider(context.Background(), client, "/v3/staticmap", nil, 1024); err == nil {
		t.Fatal("size")
	}
}
