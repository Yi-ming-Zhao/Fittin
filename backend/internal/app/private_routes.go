package app

import (
	"bytes"
	"crypto/sha256"
	"encoding/hex"
	"encoding/json"
	"errors"
	"io"
	"math"
	"net/http"
	"os"
	"path/filepath"
	"reflect"
	"regexp"
	"strconv"
	"strings"
	"time"

	"github.com/google/uuid"
)

var routeHashPattern = regexp.MustCompile(`^[a-f0-9]{64}$`)

type privateRouteManifest struct {
	Version int             `json:"version"`
	Session json.RawMessage `json:"session"`
	Chunks  []string        `json:"chunks"`
	Deleted bool            `json:"deleted,omitempty"`
}

type routeManifestWrite struct {
	ExpectedVersion int             `json:"expectedVersion"`
	Session         json.RawMessage `json:"session"`
	Chunks          []string        `json:"chunks"`
}

// Routes never enter generic sync, public file serving, Agent tools or logs.
// Authentication supplies the owner; clients cannot name another user's path.
func (s *Server) handlePrivateRoute(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Cache-Control", "no-store")
	w.Header().Set("X-Content-Type-Options", "nosniff")
	owner, _ := r.Context().Value(contextKeyUserID{}).(string)
	if _, err := uuid.Parse(owner); err != nil {
		writeError(w, 401, "invalid_owner")
		return
	}
	if r.URL.Path == "/v1/private-routes/" {
		s.listPrivateRoutes(w, r, owner)
		return
	}
	parts := strings.Split(strings.TrimPrefix(r.URL.Path, "/v1/private-routes/"), "/")
	if len(parts) != 2 && len(parts) != 3 {
		writeError(w, 404, "route_not_found")
		return
	}
	id := strings.TrimPrefix(parts[0], "cardio-record:")
	if _, err := uuid.Parse(id); err != nil || parts[0] != "cardio-record:"+id {
		writeError(w, 400, "invalid_route_id")
		return
	}
	isManifest := len(parts) == 2 && parts[1] == "manifest"
	isChunk := len(parts) == 3 && parts[1] == "chunks" && routeHashPattern.MatchString(parts[2])
	if !isManifest && !isChunk {
		writeError(w, 404, "route_not_found")
		return
	}
	directory, err := safeStoragePath(s.cfg.FileStorageRoot, filepath.Join("users", owner, "private_routes", id))
	if err != nil {
		writeError(w, 400, "invalid_route_path")
		return
	}
	s.routeMu.Lock()
	defer s.routeMu.Unlock()
	manifestPath := filepath.Join(directory, "manifest.json")
	var existing privateRouteManifest
	raw, readErr := os.ReadFile(manifestPath)
	if readErr == nil {
		if json.Unmarshal(raw, &existing) != nil {
			writeError(w, 500, "route_storage_failed")
			return
		}
	} else if !errors.Is(readErr, os.ErrNotExist) {
		writeError(w, 500, "route_storage_failed")
		return
	}
	switch r.Method {
	case http.MethodGet:
		if readErr != nil {
			writeError(w, 404, "route_not_found")
			return
		}
		if isManifest {
			writeJSON(w, 200, existing)
			return
		}
		if existing.Deleted {
			writeError(w, 404, "route_not_found")
			return
		}
		referenced := false
		for _, hash := range existing.Chunks {
			if hash == parts[2] {
				referenced = true
				break
			}
		}
		if !referenced {
			writeError(w, 404, "route_not_found")
			return
		}
		data, err := os.ReadFile(filepath.Join(directory, parts[2]+".json"))
		if err != nil || routeDigest(data) != parts[2] {
			writeError(w, 500, "route_chunk_unavailable")
			return
		}
		w.Header().Set("Content-Type", "application/json")
		w.Write(data)
	case http.MethodDelete:
		if !isManifest {
			writeError(w, 405, "method_not_allowed")
			return
		}
		version, err := strconv.Atoi(r.URL.Query().Get("version"))
		if err != nil || version < 0 {
			writeError(w, 400, "invalid_route_version")
			return
		}
		if existing.Version != version {
			writeError(w, 409, "route_conflict")
			return
		}
		// Keep only a content-free version tombstone. Resetting to zero would
		// let an old approval delete a newly uploaded route (an ABA conflict).
		version = existing.Version
		if !existing.Deleted {
			version++
		}
		tombstone, _ := json.Marshal(privateRouteManifest{Version: version, Deleted: true})
		if err := writePrivateRouteFile(manifestPath, tombstone); err != nil {
			writeError(w, 500, "route_delete_failed")
			return
		}
		entries, err := os.ReadDir(directory)
		if err != nil {
			writeError(w, 500, "route_delete_failed")
			return
		}
		for _, entry := range entries {
			if entry.Name() != "manifest.json" {
				if err := os.Remove(filepath.Join(directory, entry.Name())); err != nil {
					writeError(w, 500, "route_delete_failed")
					return
				}
			}
		}
		w.WriteHeader(http.StatusNoContent)
	case http.MethodPut:
		data, err := io.ReadAll(http.MaxBytesReader(w, r.Body, 256<<10))
		if err != nil {
			writeError(w, 413, "route_too_large")
			return
		}
		if isChunk {
			if routeDigest(data) != parts[2] || !validRouteChunk(data) {
				writeError(w, 400, "invalid_route_chunk")
				return
			}
			target := filepath.Join(directory, parts[2]+".json")
			if old, err := os.ReadFile(target); err == nil && bytes.Equal(old, data) {
				w.WriteHeader(204)
				return
			}
			// Bound incomplete uploads too. Repeated failed imports cannot fill the disk.
			if entries, _ := os.ReadDir(directory); len(entries) >= 258 {
				writeError(w, 413, "route_chunk_limit")
				return
			}
			ownerRoot := filepath.Dir(directory)
			var used int64
			_ = filepath.WalkDir(ownerRoot, func(path string, entry os.DirEntry, walkErr error) error {
				if walkErr == nil && entry.Type().IsRegular() {
					if info, e := entry.Info(); e == nil {
						used += info.Size()
					}
				}
				return nil
			})
			if used+int64(len(data)) > 200<<20 {
				writeError(w, 413, "route_storage_limit")
				return
			}
			if err := writePrivateRouteFile(target, data); err != nil {
				writeError(w, 500, "route_write_failed")
				return
			}
			w.WriteHeader(201)
			return
		}
		var input routeManifestWrite
		decoder := json.NewDecoder(bytes.NewReader(data))
		decoder.DisallowUnknownFields()
		if decoder.Decode(&input) != nil || decoder.Decode(new(any)) != io.EOF || input.ExpectedVersion < 0 || len(input.Chunks) == 0 || len(input.Chunks) > 256 || !validRouteSession(input.Session, parts[0]) {
			writeError(w, 400, "invalid_route_manifest")
			return
		}
		// An identical retried commit is idempotent; a changed snapshot requires
		// the exact version shown to the user before confirmation.
		identical := equalRouteSession(existing.Session, input.Session) && len(existing.Chunks) == len(input.Chunks)
		for i, hash := range input.Chunks {
			if !routeHashPattern.MatchString(hash) {
				writeError(w, 400, "invalid_route_chunk_hash")
				return
			}
			if identical && existing.Chunks[i] != hash {
				identical = false
			}
			chunk, e := os.ReadFile(filepath.Join(directory, hash+".json"))
			if e != nil || routeDigest(chunk) != hash {
				writeError(w, 409, "route_chunk_missing")
				return
			}
		}
		if identical {
			writeJSON(w, 200, existing)
			return
		}
		if input.ExpectedVersion != existing.Version {
			writeError(w, 409, "route_conflict")
			return
		}
		next := privateRouteManifest{Version: existing.Version + 1, Session: input.Session, Chunks: input.Chunks}
		encoded, _ := json.Marshal(next)
		if err := writePrivateRouteFile(manifestPath, encoded); err != nil {
			writeError(w, 500, "route_write_failed")
			return
		}
		// Superseded chunks contain precise locations; remove them after the new
		// manifest is durable, while reads/deletes are held by the same route lock.
		keep := map[string]bool{"manifest.json": true}
		for _, hash := range input.Chunks {
			keep[hash+".json"] = true
		}
		entries, _ := os.ReadDir(directory)
		for _, entry := range entries {
			if !keep[entry.Name()] {
				_ = os.Remove(filepath.Join(directory, entry.Name()))
			}
		}
		writeJSON(w, 200, next)
	default:
		writeError(w, 405, "method_not_allowed")
	}
}

// Inventory contains summaries only, including interrupted uploads so the owner
// can delete them even after deleting the ordinary activity summary.
func (s *Server) listPrivateRoutes(w http.ResponseWriter, r *http.Request, owner string) {
	if r.Method != http.MethodGet {
		writeError(w, 405, "method_not_allowed")
		return
	}
	directory, err := safeStoragePath(s.cfg.FileStorageRoot, filepath.Join("users", owner, "private_routes"))
	if err != nil {
		writeError(w, 400, "invalid_route_path")
		return
	}
	s.routeMu.Lock()
	defer s.routeMu.Unlock()
	entries, err := os.ReadDir(directory) // sorted names give a stable cursor
	if err != nil && !errors.Is(err, os.ErrNotExist) {
		writeError(w, 500, "route_storage_failed")
		return
	}
	items := make([]map[string]any, 0, 50)
	cursor := r.URL.Query().Get("after")
	next := ""
	for _, entry := range entries {
		if !entry.IsDir() || entry.Name() <= cursor {
			continue
		}
		if _, err := uuid.Parse(entry.Name()); err != nil {
			continue
		}
		if len(items) == 50 {
			next = strings.TrimPrefix(items[len(items)-1]["id"].(string), "cardio-record:")
			break
		}
		item := map[string]any{"id": "cardio-record:" + entry.Name(), "version": 0, "incomplete": true}
		raw, err := os.ReadFile(filepath.Join(directory, entry.Name(), "manifest.json"))
		if err == nil {
			var manifest privateRouteManifest
			var session map[string]any
			if json.Unmarshal(raw, &manifest) != nil {
				writeError(w, 500, "route_storage_failed")
				return
			}
			item["version"] = manifest.Version
			if manifest.Deleted {
				children, e := os.ReadDir(filepath.Join(directory, entry.Name()))
				if e != nil {
					writeError(w, 500, "route_storage_failed")
					return
				}
				if len(children) <= 1 {
					continue
				}
				items = append(items, item)
				continue
			}
			if json.Unmarshal(manifest.Session, &session) != nil {
				writeError(w, 500, "route_storage_failed")
				return
			}
			item["incomplete"] = false
			for _, key := range []string{"activityName", "activityTypeId", "startedAt", "activeMilliseconds", "distanceMeters"} {
				item[key] = session[key]
			}
		} else if !errors.Is(err, os.ErrNotExist) {
			writeError(w, 500, "route_storage_failed")
			return
		}
		items = append(items, item)
	}
	writeJSON(w, 200, map[string]any{"items": items, "nextCursor": next})
}

func routeDigest(data []byte) string { sum := sha256.Sum256(data); return hex.EncodeToString(sum[:]) }

// Persisting a RawMessage compacts whitespace. Retries must compare the JSON
// value rather than its wire formatting or object-key order.
func equalRouteSession(a, b json.RawMessage) bool {
	var left, right any
	return json.Unmarshal(a, &left) == nil && json.Unmarshal(b, &right) == nil && reflect.DeepEqual(left, right)
}

func writePrivateRouteFile(path string, data []byte) error {
	if err := os.MkdirAll(filepath.Dir(path), 0700); err != nil {
		return err
	}
	file, err := os.CreateTemp(filepath.Dir(path), ".route-*")
	if err != nil {
		return err
	}
	defer os.Remove(file.Name())
	defer file.Close()
	if err = file.Chmod(0600); err != nil {
		return err
	}
	if _, err = file.Write(data); err != nil {
		return err
	}
	if err = file.Sync(); err != nil {
		return err
	}
	if err = file.Close(); err != nil {
		return err
	}
	return os.Rename(file.Name(), path)
}

func validRouteChunk(data []byte) bool {
	var input struct {
		Points []struct {
			Latitude    *float64 `json:"latitude"`
			Longitude   *float64 `json:"longitude"`
			Timestamp   string   `json:"timestamp"`
			Accuracy    *float64 `json:"accuracyMeters"`
			Altitude    *float64 `json:"altitudeMeters"`
			Segment     int      `json:"segment"`
			Coordinates string   `json:"coordinateSystem"`
		} `json:"points"`
	}
	decoder := json.NewDecoder(bytes.NewReader(data))
	decoder.DisallowUnknownFields()
	if decoder.Decode(&input) != nil || decoder.Decode(new(any)) != io.EOF || len(input.Points) == 0 || len(input.Points) > 500 {
		return false
	}
	for _, point := range input.Points {
		if point.Latitude == nil || point.Longitude == nil || math.Abs(*point.Latitude) > 90 || math.Abs(*point.Longitude) > 180 || point.Segment < 0 || point.Coordinates != "WGS84" {
			return false
		}
		if _, err := time.Parse(time.RFC3339Nano, point.Timestamp); err != nil {
			return false
		}
		if point.Accuracy != nil && *point.Accuracy < 0 {
			return false
		}
	}
	return true
}

func validRouteSession(data []byte, id string) bool {
	if len(data) > 64<<10 {
		return false
	}
	var session map[string]any
	if json.Unmarshal(data, &session) != nil || session["id"] != id || session["phase"] != "finished" {
		return false
	}
	allowed := map[string]bool{}
	for _, key := range []string{"id", "sport", "startedAt", "activityTypeId", "activityName", "phase", "elapsedMilliseconds", "activeMilliseconds", "distanceMeters", "segment", "laps", "pauses", "autoPauseEnabled", "autoPaused", "lapStartMeters", "lapStartMilliseconds", "nextSplitMeters"} {
		allowed[key] = true
	}
	for key := range session {
		if !allowed[key] {
			return false
		}
	}
	elapsed, ok := session["elapsedMilliseconds"].(float64)
	if !ok || elapsed < 0 || elapsed > 7*24*3600000 {
		return false
	}
	active, ok := session["activeMilliseconds"].(float64)
	if !ok || active < 0 || active > elapsed {
		return false
	}
	distance, ok := session["distanceMeters"].(float64)
	if !ok || distance < 0 || distance > 10000000 {
		return false
	}
	started, ok := session["startedAt"].(string)
	if !ok {
		return false
	}
	if _, err := time.Parse(time.RFC3339Nano, started); err != nil {
		return false
	}
	name, ok := session["activityName"].(string)
	return ok && len(name) <= 320
}
