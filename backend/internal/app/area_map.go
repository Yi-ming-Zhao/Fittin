package app

import (
	"context"
	"encoding/json"
	"errors"
	"io"
	"math"
	"net/http"
	"net/url"
	"strconv"
	"strings"
	"sync"
	"time"
)

// No coordinates, credentials or provider responses are retained in this gate.
type mapRequestGate struct {
	mu               sync.Mutex
	start            time.Time
	users            map[string]int
	requests, active int
}

func (g *mapRequestGate) acquire(user string) (func(), bool) {
	g.mu.Lock()
	defer g.mu.Unlock()
	if time.Since(g.start) >= time.Minute {
		g.start, g.requests, g.users = time.Now(), 0, make(map[string]int)
	}
	if g.active >= 2 || g.requests >= 30 || g.users[user] >= 10 {
		return nil, false
	}
	g.requests++
	g.users[user]++
	g.active++
	return func() { g.mu.Lock(); g.active--; g.mu.Unlock() }, true
}

var areaMapClient = &http.Client{
	Timeout:       15 * time.Second,
	Transport:     &http.Transport{Proxy: nil, ResponseHeaderTimeout: 10 * time.Second, MaxIdleConnsPerHost: 2},
	CheckRedirect: func(*http.Request, []*http.Request) error { return http.ErrUseLastResponse },
}

var errAreaMap = errors.New("map unavailable")

func (s *Server) handleAreaMap(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Cache-Control", "no-store")
	if r.Method != http.MethodPost {
		writeError(w, 405, "method_not_allowed", "POST required")
		return
	}
	if s.cfg.AMapWebServiceKey == "" {
		writeError(w, 503, "map_unavailable", "Map unavailable")
		return
	}
	var input struct {
		Latitude  *float64 `json:"latitude"`
		Longitude *float64 `json:"longitude"`
		Zoom      int      `json:"zoom"`
	}
	decoder := json.NewDecoder(http.MaxBytesReader(w, r.Body, 1024))
	decoder.DisallowUnknownFields()
	if err := decoder.Decode(&input); err != nil {
		writeError(w, 400, "invalid_map_request", "Invalid map request")
		return
	}
	var extra any
	if decoder.Decode(&extra) != io.EOF || input.Latitude == nil || input.Longitude == nil ||
		!validMapCoordinate(*input.Latitude, *input.Longitude) || input.Zoom < 3 || input.Zoom > 17 {
		writeError(w, 400, "invalid_map_request", "Invalid map request")
		return
	}
	user, _ := r.Context().Value(contextKeyUserID{}).(string)
	if user == "" {
		writeError(w, 401, "authentication_required", "Sign in required")
		return
	}
	release, ok := s.mapGate.acquire(user)
	if !ok {
		w.Header().Set("Retry-After", "60")
		writeError(w, 429, "map_rate_limited", "Try again later")
		return
	}
	defer release()
	ctx, cancel := context.WithTimeout(r.Context(), 15*time.Second)
	defer cancel()
	client := s.mapHTTPClient
	if client == nil {
		client = areaMapClient
	}
	point := strconv.FormatFloat(*input.Longitude, 'f', -1, 64) + "," + strconv.FormatFloat(*input.Latitude, 'f', -1, 64)
	converted, _, err := fetchMapProvider(ctx, client, "/v3/assistant/coordinate/convert", url.Values{
		"key": {s.cfg.AMapWebServiceKey}, "locations": {point}, "coordsys": {"gps"}, "output": {"JSON"},
	}, 16<<10)
	var result struct {
		Status    string `json:"status"`
		Locations string `json:"locations"`
	}
	if err != nil || json.Unmarshal(converted, &result) != nil || result.Status != "1" || !validMapLocation(result.Locations) {
		writeError(w, 502, "map_unavailable", "Map unavailable")
		return
	}
	if ctx.Err() != nil {
		return
	}
	image, kind, err := fetchMapProvider(ctx, client, "/v3/staticmap", url.Values{
		"key": {s.cfg.AMapWebServiceKey}, "location": {result.Locations}, "zoom": {strconv.Itoa(input.Zoom)},
		"size": {"600*360"}, "scale": {"1"}, "markers": {"mid,0xB64337,A:" + result.Locations},
	}, 2<<20)
	if err != nil || (kind != "image/png" && kind != "image/jpeg") || http.DetectContentType(image) != kind {
		writeError(w, 502, "map_unavailable", "Map unavailable")
		return
	}
	w.Header().Set("Content-Type", kind)
	w.Header().Set("X-Content-Type-Options", "nosniff")
	w.WriteHeader(http.StatusOK)
	_, _ = w.Write(image)
}

func validMapCoordinate(lat, lon float64) bool {
	return !math.IsNaN(lat) && !math.IsNaN(lon) && math.Abs(lat) <= 90 && math.Abs(lon) <= 180
}

func validMapLocation(value string) bool {
	parts := strings.Split(value, ",")
	if len(parts) != 2 {
		return false
	}
	lon, e1 := strconv.ParseFloat(parts[0], 64)
	lat, e2 := strconv.ParseFloat(parts[1], 64)
	return e1 == nil && e2 == nil && validMapCoordinate(lat, lon)
}

func fetchMapProvider(ctx context.Context, client *http.Client, path string, query url.Values, limit int64) ([]byte, string, error) {
	u := url.URL{Scheme: "https", Host: "restapi.amap.com", Path: path, RawQuery: query.Encode()}
	req, err := http.NewRequestWithContext(ctx, http.MethodGet, u.String(), nil)
	if err != nil {
		return nil, "", errAreaMap
	}
	response, err := client.Do(req)
	if err != nil {
		return nil, "", errAreaMap
	}
	defer response.Body.Close()
	if response.StatusCode != 200 || response.ContentLength > limit {
		return nil, "", errAreaMap
	}
	data, err := io.ReadAll(io.LimitReader(response.Body, limit+1))
	if err != nil || int64(len(data)) > limit {
		return nil, "", errAreaMap
	}
	return data, strings.ToLower(strings.TrimSpace(strings.Split(response.Header.Get("Content-Type"), ";")[0])), nil
}
