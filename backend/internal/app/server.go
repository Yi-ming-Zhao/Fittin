package app

import (
	"bytes"
	"context"
	"crypto/hmac"
	"crypto/sha256"
	"crypto/subtle"
	"encoding/base64"
	"encoding/json"
	"errors"
	"fmt"
	"image"
	_ "image/gif"
	_ "image/jpeg"
	_ "image/png"
	"io"
	"math"
	"net"
	"net/http"
	"os"
	"path/filepath"
	"strconv"
	"strings"
	"sync"
	"time"

	"github.com/golang-jwt/jwt/v5"
	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgconn"
	"github.com/jackc/pgx/v5/pgtype"
	"github.com/jackc/pgx/v5/pgxpool"
	"golang.org/x/crypto/bcrypt"
)

type Server struct {
	cfg             Config
	db              *pgxpool.Pool
	httpServer      *http.Server
	rateMu          sync.Mutex
	rateByIP        map[string]rateWindow
	rateLastCleanup time.Time

	agentMu               sync.Mutex
	agentRateByKey        map[string]rateWindow
	agentRateLastCleanup  time.Time
	agentConcurrentByUser map[string]int
	agentResolver         agentDNSResolver
	agentClientFactory    agentHTTPClientFactory
	agentStats            agentRelayMetrics
}

type rateWindow struct {
	started time.Time
	count   int
}

const maxRateLimitEntries = 10_000

type refreshCredentialMatch uint8

const (
	refreshCredentialInvalid refreshCredentialMatch = iota
	refreshCredentialCurrent
	refreshCredentialPreviousRace
	refreshCredentialPreviousReuse
)

type tableSpec struct {
	Name             string
	Columns          []string
	UpsertColumns    []string
	AllowedTimestamp map[string]bool
}

var syncTableSpecs = map[string]tableSpec{
	"user_content": {
		Name: "user_content",
		Columns: []string{
			"id", "user_id", "kind", "payload_json", "created_at", "updated_at",
			"deleted_at", "version", "last_modified_by_device_id",
		},
		UpsertColumns: []string{
			"user_id", "kind", "payload_json", "created_at", "updated_at",
			"deleted_at", "version", "last_modified_by_device_id",
		},
		AllowedTimestamp: map[string]bool{"updated_at": true, "created_at": true},
	},
	"plans": {
		Name: "plans",
		Columns: []string{
			"id", "user_id", "name", "description", "source_plan_id", "is_built_in",
			"raw_json", "created_at", "updated_at", "deleted_at", "version", "last_modified_by_device_id",
		},
		UpsertColumns: []string{
			"user_id", "name", "description", "source_plan_id", "is_built_in",
			"raw_json", "created_at", "updated_at", "deleted_at", "version", "last_modified_by_device_id",
		},
		AllowedTimestamp: map[string]bool{"updated_at": true, "created_at": true},
	},
	"plan_instances": {
		Name: "plan_instances",
		Columns: []string{
			"id", "user_id", "template_id", "current_workout_index", "current_states_json",
			"training_max_profile_json", "engine_state_json", "created_at", "updated_at",
			"deleted_at", "version", "last_modified_by_device_id",
		},
		UpsertColumns: []string{
			"user_id", "template_id", "current_workout_index", "current_states_json",
			"training_max_profile_json", "engine_state_json", "created_at", "updated_at",
			"deleted_at", "version", "last_modified_by_device_id",
		},
		AllowedTimestamp: map[string]bool{"updated_at": true, "created_at": true},
	},
	"workout_logs": {
		Name: "workout_logs",
		Columns: []string{
			"id", "user_id", "instance_id", "workout_id", "workout_name", "raw_json",
			"completed_at", "created_at", "updated_at", "deleted_at", "version", "last_modified_by_device_id",
		},
		UpsertColumns: []string{
			"user_id", "instance_id", "workout_id", "workout_name", "raw_json",
			"completed_at", "created_at", "updated_at", "deleted_at", "version", "last_modified_by_device_id",
		},
		AllowedTimestamp: map[string]bool{
			"updated_at": true, "created_at": true, "completed_at": true,
		},
	},
	"body_metrics": {
		Name: "body_metrics",
		Columns: []string{
			"id", "user_id", "timestamp", "weight_kg", "body_fat_percent", "waist_cm",
			"note", "created_at", "updated_at", "deleted_at", "version", "last_modified_by_device_id",
		},
		UpsertColumns: []string{
			"user_id", "timestamp", "weight_kg", "body_fat_percent", "waist_cm",
			"note", "created_at", "updated_at", "deleted_at", "version", "last_modified_by_device_id",
		},
		AllowedTimestamp: map[string]bool{
			"updated_at": true, "created_at": true, "timestamp": true,
		},
	},
	"progress_photos": {
		Name: "progress_photos",
		Columns: []string{
			"id", "user_id", "captured_at", "label", "storage_path", "metadata_json",
			"created_at", "updated_at", "deleted_at", "version", "last_modified_by_device_id",
		},
		UpsertColumns: []string{
			"user_id", "captured_at", "label", "storage_path", "metadata_json",
			"created_at", "updated_at", "deleted_at", "version", "last_modified_by_device_id",
		},
		AllowedTimestamp: map[string]bool{
			"updated_at": true, "created_at": true, "captured_at": true,
		},
	},
}

func NewServer() (*Server, error) {
	cfg, err := LoadConfig()
	if err != nil {
		return nil, err
	}

	pool, err := pgxpool.New(context.Background(), cfg.DatabaseURL)
	if err != nil {
		return nil, err
	}

	server := &Server{
		cfg:                   cfg,
		db:                    pool,
		rateByIP:              make(map[string]rateWindow),
		agentRateByKey:        make(map[string]rateWindow),
		agentConcurrentByUser: make(map[string]int),
	}
	pingCtx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()
	if err := pool.Ping(pingCtx); err != nil {
		pool.Close()
		return nil, fmt.Errorf("database readiness check: %w", err)
	}

	mux := http.NewServeMux()
	mux.HandleFunc("/", server.handleRoot)
	mux.HandleFunc("/healthz", server.handleHealthz)
	mux.HandleFunc("/readyz", server.handleReadyz)
	mux.HandleFunc("/v1/auth/sign-up", server.withNoStore(server.handleSignUp))
	mux.HandleFunc("/v1/auth/sign-in", server.withNoStore(server.handleSignIn))
	mux.HandleFunc("/v1/auth/refresh", server.withNoStore(server.handleRefresh))
	mux.HandleFunc("/v1/auth/session", server.withNoStore(server.withAuth(server.handleSession)))
	mux.HandleFunc("/v1/auth/sign-out", server.withNoStore(server.withAuth(server.handleSignOut)))
	mux.HandleFunc("/v1/sync/upsert/", server.withAuth(server.handleSyncUpsert))
	mux.HandleFunc("/v1/sync/", server.withAuth(server.handleSync))
	mux.HandleFunc("/v1/files/progress-photos", server.withAuth(server.handleProgressPhotoUpload))
	mux.HandleFunc("/v1/files/progress-photos/", server.withAuth(server.handleProgressPhotoDownload))
	mux.HandleFunc("/v1/agent/chat-completions", server.withAuth(server.handleAgentChatCompletions))

	server.httpServer = &http.Server{
		Addr:              cfg.Addr,
		Handler:           server.withCORS(server.withRateLimit(mux)),
		ReadHeaderTimeout: 5 * time.Second,
		ReadTimeout:       20 * time.Second,
		WriteTimeout:      max(30*time.Second, cfg.AgentUpstreamTimeout+5*time.Second),
		IdleTimeout:       60 * time.Second,
	}

	return server, nil
}

func (s *Server) Run() error {
	return s.httpServer.ListenAndServe()
}

func (s *Server) withCORS(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		origin := r.Header.Get("Origin")
		if origin != "" {
			w.Header().Set("Vary", "Origin")
			if s.cfg.AllowedOrigins[origin] {
				w.Header().Set("Access-Control-Allow-Origin", origin)
				w.Header().Set("Access-Control-Allow-Credentials", "true")
				w.Header().Set("Access-Control-Allow-Headers", "Authorization, Content-Type, X-Fittin-Auth-Version, X-Fittin-Auth-Platform, X-Fittin-Device-Id")
				w.Header().Set("Access-Control-Allow-Methods", "GET, POST, DELETE, OPTIONS")
			}
		}

		if r.Method == http.MethodOptions {
			w.WriteHeader(http.StatusNoContent)
			return
		}

		next.ServeHTTP(w, r)
	})
}

func (s *Server) withNoStore(next http.HandlerFunc) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		setNoStoreHeaders(w)
		next(w, r)
	}
}

func setNoStoreHeaders(w http.ResponseWriter) {
	w.Header().Set("Cache-Control", "no-store")
	w.Header().Set("Pragma", "no-cache")
}

func (s *Server) handleRoot(w http.ResponseWriter, r *http.Request) {
	if r.URL.Path != "/" {
		writeError(w, http.StatusNotFound, "not found")
		return
	}
	if r.Method != http.MethodGet && r.Method != http.MethodHead {
		writeError(w, http.StatusMethodNotAllowed, "method not allowed")
		return
	}

	writeJSON(w, http.StatusOK, map[string]any{
		"service": "fittin-backend",
		"ok":      true,
		"healthz": "/healthz",
		"readyz":  "/readyz",
	})
}

func (s *Server) handleHealthz(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodGet && r.Method != http.MethodHead {
		writeError(w, http.StatusMethodNotAllowed, "method_not_allowed", "method not allowed")
		return
	}
	writeJSON(w, http.StatusOK, map[string]any{"ok": true})
}

func (s *Server) handleReadyz(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodGet && r.Method != http.MethodHead {
		writeError(w, http.StatusMethodNotAllowed, "method_not_allowed", "method not allowed")
		return
	}
	ctx, cancel := context.WithTimeout(r.Context(), 2*time.Second)
	defer cancel()
	if s.db == nil || s.db.Ping(ctx) != nil {
		writeError(w, http.StatusServiceUnavailable, "database_unavailable", "database is unavailable")
		return
	}
	writeJSON(w, http.StatusOK, map[string]any{"ok": true, "ready": true})
}

func (s *Server) withRateLimit(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		if strings.HasPrefix(r.URL.Path, "/v1/auth/") {
			setNoStoreHeaders(w)
		}
		if r.Method == http.MethodOptions || !isRateLimitedRequest(r) {
			next.ServeHTTP(w, r)
			return
		}
		limit := s.cfg.RateLimitPerMin
		if limit <= 0 {
			limit = 60
		}
		host := clientIPAddress(r)
		now := time.Now()
		s.rateMu.Lock()
		if s.rateLastCleanup.IsZero() || now.Sub(s.rateLastCleanup) >= time.Minute {
			for candidate, entry := range s.rateByIP {
				if now.Sub(entry.started) >= 2*time.Minute {
					delete(s.rateByIP, candidate)
				}
			}
			s.rateLastCleanup = now
		}
		if _, exists := s.rateByIP[host]; !exists && len(s.rateByIP) >= maxRateLimitEntries {
			s.rateMu.Unlock()
			w.Header().Set("Retry-After", "60")
			writeError(w, http.StatusTooManyRequests, "rate_limited", "too many requests")
			return
		}
		window := s.rateByIP[host]
		if window.started.IsZero() || now.Sub(window.started) >= time.Minute {
			window = rateWindow{started: now}
		}
		window.count++
		s.rateByIP[host] = window
		s.rateMu.Unlock()
		if window.count > limit {
			w.Header().Set("Retry-After", "60")
			writeError(w, http.StatusTooManyRequests, "rate_limited", "too many requests")
			return
		}
		next.ServeHTTP(w, r)
	})
}

func clientIPAddress(r *http.Request) string {
	host, _, err := net.SplitHostPort(r.RemoteAddr)
	if err != nil {
		host = r.RemoteAddr
	}
	remoteIP := net.ParseIP(strings.TrimSpace(host))
	if remoteIP != nil && remoteIP.IsLoopback() {
		forwarded := strings.TrimSpace(r.Header.Get("X-Real-IP"))
		if parsed := net.ParseIP(forwarded); parsed != nil {
			return parsed.String()
		}
	}
	if remoteIP != nil {
		return remoteIP.String()
	}
	return strings.TrimSpace(host)
}

func isRateLimitedRequest(r *http.Request) bool {
	if strings.HasPrefix(r.URL.Path, "/v1/auth/") {
		return true
	}
	return r.Method != http.MethodGet && strings.HasPrefix(r.URL.Path, "/v1/")
}

type authRequest struct {
	Email    string `json:"email"`
	Password string `json:"password"`
}

type authResponse struct {
	AccessToken           string         `json:"accessToken"`
	AccessTokenExpiresAt  string         `json:"accessTokenExpiresAt,omitempty"`
	RefreshToken          string         `json:"refreshToken,omitempty"`
	RefreshTokenExpiresAt string         `json:"refreshTokenExpiresAt,omitempty"`
	HasRefreshToken       bool           `json:"hasRefreshToken,omitempty"`
	User                  map[string]any `json:"user"`
}

type issuedAuthSession struct {
	AccessToken           string
	AccessTokenExpiresAt  time.Time
	RefreshToken          string
	RefreshTokenExpiresAt time.Time
	HasRefreshToken       bool
}

const (
	authProtocolVersionHeader = "X-Fittin-Auth-Version"
	authPlatformHeader        = "X-Fittin-Auth-Platform"
	refreshCookieName         = "fittin_refresh"
	maxRefreshBodyBytes       = 8 << 10
	refreshRaceGrace          = 15 * time.Second
)

func (s *Server) handleSignUp(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		writeError(w, http.StatusMethodNotAllowed, "method not allowed")
		return
	}

	var req authRequest
	if err := decodeJSONBody(w, r, &req, 64<<10); err != nil {
		writeError(w, http.StatusBadRequest, "invalid auth payload")
		return
	}
	req.Email = normalizeEmail(req.Email)
	if req.Email == "" || !strings.Contains(req.Email, "@") {
		writeError(w, http.StatusBadRequest, "invalid_email", "a valid email is required")
		return
	}
	passwordBytes := len([]byte(req.Password))
	if passwordBytes < 10 || passwordBytes > 72 {
		writeError(w, http.StatusBadRequest, "invalid_password", "password must be between 10 and 72 bytes")
		return
	}
	if req.Email == "" || req.Password == "" {
		writeError(w, http.StatusBadRequest, "email and password are required")
		return
	}

	passwordHash, err := bcrypt.GenerateFromPassword([]byte(req.Password), bcrypt.DefaultCost)
	if err != nil {
		writeError(w, http.StatusInternalServerError, "failed to hash password")
		return
	}

	userID := uuid.NewString()
	tx, err := s.db.Begin(r.Context())
	if err != nil {
		writeError(w, http.StatusServiceUnavailable, "database_unavailable", "account service is temporarily unavailable")
		return
	}
	defer tx.Rollback(r.Context())
	_, err = tx.Exec(
		r.Context(),
		`insert into users (id, email, password_hash, display_name, created_at, updated_at)
		 values ($1, $2, $3, $4, now(), now())`,
		userID,
		req.Email,
		string(passwordHash),
		req.Email,
	)
	if err != nil {
		var pgErr *pgconn.PgError
		if errors.As(err, &pgErr) && pgErr.Code == "23505" {
			writeError(w, http.StatusConflict, "email_in_use", "an account already exists for this email")
			return
		}
		writeError(w, http.StatusServiceUnavailable, "database_unavailable", "account service is temporarily unavailable")
		return
	}

	credentials, err := s.issueAuthSessionWithExecutor(
		r.Context(),
		tx,
		userID,
		req.Email,
		r.Header.Get("X-Fittin-Device-Id"),
		supportsRefreshSessions(r),
	)
	if err != nil {
		writeError(w, http.StatusServiceUnavailable, "database_unavailable", "account service is temporarily unavailable")
		return
	}
	if err := tx.Commit(r.Context()); err != nil {
		writeError(w, http.StatusServiceUnavailable, "database_unavailable", "account service is temporarily unavailable")
		return
	}

	s.writeAuthResponse(w, r, http.StatusCreated, credentials, map[string]any{
		"id":          userID,
		"email":       req.Email,
		"displayName": req.Email,
		"isAnonymous": false,
	})
}

func (s *Server) handleSignIn(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		writeError(w, http.StatusMethodNotAllowed, "method not allowed")
		return
	}

	var req authRequest
	if err := decodeJSONBody(w, r, &req, 64<<10); err != nil {
		writeError(w, http.StatusBadRequest, "invalid auth payload")
		return
	}
	req.Email = normalizeEmail(req.Email)
	if req.Email == "" || len([]byte(req.Password)) > 72 {
		writeError(w, http.StatusUnauthorized, "invalid_credentials", "invalid credentials")
		return
	}

	user, err := s.lookupUserByEmail(r.Context(), req.Email)
	if err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			writeError(w, http.StatusUnauthorized, "invalid_credentials", "invalid credentials")
			return
		}
		writeError(w, http.StatusServiceUnavailable, "database_unavailable", "account service is temporarily unavailable")
		return
	}

	if err := bcrypt.CompareHashAndPassword([]byte(user.PasswordHash), []byte(req.Password)); err != nil {
		writeError(w, http.StatusUnauthorized, "invalid_credentials", "invalid credentials")
		return
	}

	credentials, err := s.issueAuthSessionWithExecutor(
		r.Context(),
		s.db,
		user.ID,
		user.Email,
		r.Header.Get("X-Fittin-Device-Id"),
		supportsRefreshSessions(r),
	)
	if err != nil {
		writeError(w, http.StatusServiceUnavailable, "database_unavailable", "account service is temporarily unavailable")
		return
	}

	s.writeAuthResponse(w, r, http.StatusOK, credentials, authUserPayload(user))
}

func (s *Server) handleSession(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodGet && r.Method != http.MethodHead {
		writeError(w, http.StatusMethodNotAllowed, "method_not_allowed", "method not allowed")
		return
	}
	userID := r.Context().Value(contextKeyUserID{}).(string)
	user, err := s.lookupUserByID(r.Context(), userID)
	if err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			writeError(w, http.StatusUnauthorized, "session_invalid", "session user no longer exists")
			return
		}
		writeError(w, http.StatusServiceUnavailable, "database_unavailable", "account service is temporarily unavailable")
		return
	}
	credentials := issuedAuthSession{AccessToken: bearerToken(r.Header.Get("Authorization"))}
	if supportsRefreshSessions(r) {
		sessionID, _ := r.Context().Value(contextKeySessionID{}).(string)
		credentials, err = s.bootstrapRefreshSession(
			r.Context(),
			sessionID,
			user.ID,
			user.Email,
		)
		if err != nil {
			if errors.Is(err, errAuthSessionInactive) || errors.Is(err, pgx.ErrNoRows) {
				writeError(w, http.StatusUnauthorized, "session_invalid", "session has expired or was revoked")
				return
			}
			writeError(w, http.StatusServiceUnavailable, "database_unavailable", "session upgrade is temporarily unavailable")
			return
		}
	}
	s.writeAuthResponse(w, r, http.StatusOK, credentials, authUserPayload(user))
}

func (s *Server) handleRefresh(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		writeError(w, http.StatusMethodNotAllowed, "method_not_allowed", "method not allowed")
		return
	}
	if !supportsRefreshSessions(r) {
		writeError(w, http.StatusBadRequest, "refresh_protocol_required", "refresh protocol version 2 is required")
		return
	}

	refreshToken, err := refreshTokenFromRequest(w, r)
	if err != nil {
		var maxBytesError *http.MaxBytesError
		if errors.As(err, &maxBytesError) {
			writeError(w, http.StatusRequestEntityTooLarge, "refresh_request_too_large", "refresh request is too large")
			return
		}
		if errors.Is(err, errRefreshCredentialMissing) {
			writeError(w, http.StatusUnauthorized, "refresh_invalid", "refresh session is invalid")
			return
		}
		writeError(w, http.StatusBadRequest, "invalid_refresh_request", "invalid refresh request")
		return
	}
	credentials, user, status, code, err := s.rotateRefreshSession(r.Context(), refreshToken)
	if err != nil {
		writeError(w, status, code, refreshErrorMessage(code))
		return
	}
	s.writeAuthResponse(w, r, http.StatusOK, credentials, authUserPayload(user))
}

func (s *Server) handleSignOut(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		writeError(w, http.StatusMethodNotAllowed, "method not allowed")
		return
	}
	if sessionID, _ := r.Context().Value(contextKeySessionID{}).(string); sessionID != "" {
		if _, err := s.db.Exec(r.Context(), `update auth_sessions set revoked_at = now() where id = $1`, sessionID); err != nil {
			writeError(w, http.StatusServiceUnavailable, "database_unavailable", "sign-out is temporarily unavailable")
			return
		}
	}
	if isWebAuthClient(r) {
		clearRefreshCookie(w, r)
	}
	writeJSON(w, http.StatusOK, map[string]any{"ok": true})
}

func (s *Server) handleSyncUpsert(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		writeError(w, http.StatusMethodNotAllowed, "method not allowed")
		return
	}

	table := strings.TrimPrefix(r.URL.Path, "/v1/sync/upsert/")
	spec, ok := syncTableSpecs[table]
	if !ok {
		writeError(w, http.StatusBadRequest, "missing table name")
		return
	}

	var row map[string]any
	if err := decodeJSONBody(w, r, &row, 2<<20); err != nil {
		writeError(w, http.StatusBadRequest, "invalid sync payload")
		return
	}

	userID := r.Context().Value(contextKeyUserID{}).(string)
	normalized, err := normalizeSyncRow(spec, row, userID)
	if err != nil {
		writeError(w, http.StatusBadRequest, err.Error())
		return
	}

	savedRow, err := s.upsertSyncRow(r.Context(), spec, normalized)
	if err != nil {
		status := http.StatusInternalServerError
		code := "sync_failed"
		if errors.Is(err, errSyncOwnershipConflict) {
			status = http.StatusConflict
			code = "sync_ownership_conflict"
		} else if errors.Is(err, errSyncVersionConflict) {
			status = http.StatusConflict
			code = "sync_conflict"
		}
		if status >= http.StatusInternalServerError {
			writeError(w, http.StatusServiceUnavailable, "database_unavailable", "sync service is temporarily unavailable")
		} else {
			writeError(w, status, code, err.Error())
		}
		return
	}

	writeJSON(w, http.StatusOK, map[string]any{
		"table": table,
		"row":   savedRow,
	})
}

func (s *Server) handleSync(w http.ResponseWriter, r *http.Request) {
	trimmed := strings.TrimPrefix(r.URL.Path, "/v1/sync/")
	parts := strings.Split(strings.Trim(trimmed, "/"), "/")
	if len(parts) == 0 || parts[0] == "" {
		writeError(w, http.StatusBadRequest, "missing table name")
		return
	}

	spec, ok := syncTableSpecs[parts[0]]
	if !ok {
		writeError(w, http.StatusBadRequest, "missing table name")
		return
	}
	userID := r.Context().Value(contextKeyUserID{}).(string)

	if r.Method == http.MethodDelete {
		if len(parts) != 2 {
			writeError(w, http.StatusBadRequest, "missing record id")
			return
		}

		var expectedVersion *int
		if rawVersion := r.URL.Query().Get("version"); rawVersion != "" {
			parsed, err := strconv.Atoi(rawVersion)
			if err != nil || parsed < 1 {
				writeError(w, http.StatusBadRequest, "invalid sync delete version")
				return
			}
			expectedVersion = &parsed
		}
		deletedRow, err := s.softDeleteSyncRow(
			r.Context(),
			spec,
			userID,
			parts[1],
			expectedVersion,
			r.URL.Query().Get("deviceId"),
		)
		if err != nil {
			status := http.StatusInternalServerError
			code := "sync_delete_failed"
			if errors.Is(err, errNotFound) {
				status = http.StatusNotFound
				code = "not_found"
			} else if errors.Is(err, errSyncVersionConflict) {
				status = http.StatusConflict
				code = "sync_conflict"
			}
			writeError(w, status, code, err.Error())
			return
		}

		writeJSON(w, http.StatusOK, map[string]any{
			"table": parts[0],
			"row":   deletedRow,
		})
		return
	}
	if r.Method == http.MethodGet {
		queryUserID := r.URL.Query().Get("userId")
		if queryUserID != "" && queryUserID != userID {
			writeError(w, http.StatusForbidden, "userId does not match authenticated user")
			return
		}

		timestampColumn := r.URL.Query().Get("timestampColumn")
		if timestampColumn == "" {
			timestampColumn = "updated_at"
		}
		if !spec.AllowedTimestamp[timestampColumn] {
			writeError(w, http.StatusBadRequest, "unsupported timestamp column")
			return
		}

		var since *time.Time
		if rawSince := r.URL.Query().Get("since"); rawSince != "" {
			parsed, err := time.Parse(time.RFC3339, rawSince)
			if err != nil {
				writeError(w, http.StatusBadRequest, "invalid since timestamp")
				return
			}
			since = &parsed
		}
		limit := 200
		if rawLimit := r.URL.Query().Get("limit"); rawLimit != "" {
			parsed, err := strconv.Atoi(rawLimit)
			if err != nil || parsed < 1 || parsed > 500 {
				writeError(w, http.StatusBadRequest, "invalid limit")
				return
			}
			limit = parsed
		}
		var cursorUpdatedAt *time.Time
		cursorID := r.URL.Query().Get("cursorId")
		if rawCursor := r.URL.Query().Get("cursorUpdatedAt"); rawCursor != "" {
			parsed, err := time.Parse(time.RFC3339, rawCursor)
			if err != nil || cursorID == "" {
				writeError(w, http.StatusBadRequest, "invalid sync cursor")
				return
			}
			cursorUpdatedAt = &parsed
		}

		rows, err := s.fetchSyncRows(r.Context(), spec, userID, timestampColumn, since, cursorUpdatedAt, cursorID, limit+1)
		if err != nil {
			writeError(w, http.StatusServiceUnavailable, "database_unavailable", "sync service is temporarily unavailable")
			return
		}

		hasMore := len(rows) > limit
		if hasMore {
			rows = rows[:limit]
		}
		payload := map[string]any{
			"table":   spec.Name,
			"rows":    rows,
			"hasMore": hasMore,
		}
		if hasMore && len(rows) > 0 {
			last := rows[len(rows)-1]
			payload["nextCursor"] = map[string]any{
				"updatedAt": last["updated_at"],
				"id":        last["id"],
			}
		}
		writeJSON(w, http.StatusOK, payload)
		return
	}
	writeError(w, http.StatusMethodNotAllowed, "method not allowed")
}

func (s *Server) handleProgressPhotoUpload(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		writeError(w, http.StatusMethodNotAllowed, "method not allowed")
		return
	}
	maxBytes := s.cfg.MaxUploadBytes
	if maxBytes <= 0 {
		maxBytes = 10 << 20
	}
	r.Body = http.MaxBytesReader(w, r.Body, maxBytes+(1<<20))
	if err := r.ParseMultipartForm(maxBytes); err != nil {
		writeError(w, http.StatusRequestEntityTooLarge, "upload_too_large", "invalid or oversized multipart payload")
		return
	}

	userID := r.Context().Value(contextKeyUserID{}).(string)
	if suppliedUserID := strings.TrimSpace(r.FormValue("userId")); suppliedUserID != "" && suppliedUserID != userID {
		writeError(w, http.StatusForbidden, "owner_mismatch", "userId does not match authenticated user")
		return
	}
	photoID := strings.TrimSpace(r.FormValue("photoId"))
	if _, err := uuid.Parse(photoID); err != nil {
		writeError(w, http.StatusBadRequest, "invalid_photo_id", "photoId must be a UUID")
		return
	}
	file, _, err := r.FormFile("file")
	if err != nil {
		writeError(w, http.StatusBadRequest, "missing file")
		return
	}
	defer file.Close()
	data, err := io.ReadAll(io.LimitReader(file, maxBytes+1))
	if err != nil {
		writeError(w, http.StatusBadRequest, "invalid_image", "failed to read image")
		return
	}
	if int64(len(data)) == 0 || int64(len(data)) > maxBytes {
		writeError(w, http.StatusRequestEntityTooLarge, "upload_too_large", "image exceeds upload limit")
		return
	}
	contentType := http.DetectContentType(data)
	extension := imageExtension(contentType)
	if extension == "" {
		writeError(w, http.StatusUnsupportedMediaType, "invalid_image", "only JPEG, PNG, and GIF images are accepted")
		return
	}
	imageConfig, _, err := image.DecodeConfig(bytes.NewReader(data))
	if err != nil || imageConfig.Width <= 0 || imageConfig.Height <= 0 || imageConfig.Width > 12000 || imageConfig.Height > 12000 || int64(imageConfig.Width)*int64(imageConfig.Height) > 40_000_000 {
		writeError(w, http.StatusBadRequest, "invalid_image", "image dimensions are invalid or too large")
		return
	}

	storagePath := filepath.Join("users", userID, "progress_photos", photoID, "original"+extension)
	absolutePath, err := safeStoragePath(s.cfg.FileStorageRoot, storagePath)
	if err != nil {
		writeError(w, http.StatusBadRequest, "invalid_storage_path", "invalid storage path")
		return
	}
	if err := os.MkdirAll(filepath.Dir(absolutePath), 0o700); err != nil {
		writeError(w, http.StatusInternalServerError, "failed to prepare storage directory")
		return
	}

	out, err := os.CreateTemp(filepath.Dir(absolutePath), ".upload-*")
	if err != nil {
		writeError(w, http.StatusInternalServerError, "failed to create destination file")
		return
	}
	temporaryPath := out.Name()
	defer os.Remove(temporaryPath)
	if err := out.Chmod(0o600); err != nil {
		out.Close()
		writeError(w, http.StatusInternalServerError, "failed to secure uploaded file")
		return
	}
	if _, err := out.Write(data); err != nil {
		out.Close()
		writeError(w, http.StatusInternalServerError, "failed to persist uploaded file")
		return
	}
	if err := out.Sync(); err != nil {
		out.Close()
		writeError(w, http.StatusInternalServerError, "failed to persist uploaded file")
		return
	}
	if err := out.Close(); err != nil {
		writeError(w, http.StatusInternalServerError, "failed to persist uploaded file")
		return
	}
	if err := os.Rename(temporaryPath, absolutePath); err != nil {
		writeError(w, http.StatusInternalServerError, "failed to activate uploaded file")
		return
	}

	writeJSON(w, http.StatusCreated, map[string]any{
		"storagePath": filepath.ToSlash(storagePath),
		"contentType": contentType,
		"size":        len(data),
	})
}

func (s *Server) handleProgressPhotoDownload(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodGet && r.Method != http.MethodHead {
		writeError(w, http.StatusMethodNotAllowed, "method not allowed")
		return
	}
	photoID := strings.TrimSpace(strings.TrimPrefix(r.URL.Path, "/v1/files/progress-photos/"))
	if _, err := uuid.Parse(photoID); err != nil {
		writeError(w, http.StatusBadRequest, "invalid_photo_id", "photo id must be a UUID")
		return
	}
	userID := r.Context().Value(contextKeyUserID{}).(string)
	var storagePath string
	err := s.db.QueryRow(
		r.Context(),
		`select storage_path from progress_photos where id = $1 and user_id = $2 and deleted_at is null`,
		photoID,
		userID,
	).Scan(&storagePath)
	if err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			writeError(w, http.StatusNotFound, "photo_not_found", "progress photo not found")
			return
		}
		writeError(w, http.StatusServiceUnavailable, "database_unavailable", "photo service is temporarily unavailable")
		return
	}
	if !validProgressPhotoStoragePath(userID, photoID, storagePath) {
		writeError(w, http.StatusInternalServerError, "invalid_storage_path", "stored photo path is invalid")
		return
	}
	absolutePath, err := safeStoragePath(s.cfg.FileStorageRoot, storagePath)
	if err != nil {
		writeError(w, http.StatusInternalServerError, "invalid_storage_path", "stored photo path is invalid")
		return
	}
	file, err := os.Open(absolutePath)
	if err != nil {
		if errors.Is(err, os.ErrNotExist) {
			writeError(w, http.StatusNotFound, "photo_file_missing", "progress photo file is unavailable")
			return
		}
		writeError(w, http.StatusInternalServerError, "photo_read_failed", "failed to read progress photo")
		return
	}
	defer file.Close()
	info, err := file.Stat()
	if err != nil || !info.Mode().IsRegular() {
		writeError(w, http.StatusInternalServerError, "photo_read_failed", "failed to read progress photo")
		return
	}
	header := make([]byte, 512)
	n, _ := file.Read(header)
	_, _ = file.Seek(0, io.SeekStart)
	w.Header().Set("Content-Type", http.DetectContentType(header[:n]))
	w.Header().Set("Content-Length", strconv.FormatInt(info.Size(), 10))
	w.Header().Set("Cache-Control", "private, max-age=3600")
	w.Header().Set("X-Content-Type-Options", "nosniff")
	if r.Method == http.MethodHead {
		w.WriteHeader(http.StatusOK)
		return
	}
	w.WriteHeader(http.StatusOK)
	_, _ = io.Copy(w, file)
}

func imageExtension(contentType string) string {
	switch contentType {
	case "image/jpeg":
		return ".jpg"
	case "image/png":
		return ".png"
	case "image/gif":
		return ".gif"
	default:
		return ""
	}
}

func safeStoragePath(root, relative string) (string, error) {
	cleanRoot, err := filepath.Abs(root)
	if err != nil {
		return "", err
	}
	joined, err := filepath.Abs(filepath.Join(cleanRoot, filepath.Clean(relative)))
	if err != nil {
		return "", err
	}
	if joined != cleanRoot && !strings.HasPrefix(joined, cleanRoot+string(os.PathSeparator)) {
		return "", errors.New("path escapes storage root")
	}
	return joined, nil
}

type contextKeyUserID struct{}
type contextKeyEmail struct{}
type contextKeySessionID struct{}

func (s *Server) withAuth(next http.HandlerFunc) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		tokenString := bearerToken(r.Header.Get("Authorization"))
		if tokenString == "" {
			writeError(w, http.StatusUnauthorized, "missing_bearer_token", "missing bearer token")
			return
		}
		claims := jwt.MapClaims{}
		parser := jwt.NewParser(jwt.WithValidMethods([]string{jwt.SigningMethodHS256.Alg()}))
		_, err := parser.ParseWithClaims(tokenString, claims, func(token *jwt.Token) (any, error) {
			return []byte(s.cfg.JWTSecret), nil
		})
		if err != nil {
			if errors.Is(err, jwt.ErrTokenExpired) {
				writeError(w, http.StatusUnauthorized, "access_token_expired", "access token has expired")
			} else {
				writeError(w, http.StatusUnauthorized, "access_token_invalid", "invalid access token")
			}
			return
		}

		userID, _ := claims["sub"].(string)
		email, _ := claims["email"].(string)
		sessionID, _ := claims["jti"].(string)
		if userID == "" {
			writeError(w, http.StatusUnauthorized, "access_token_invalid", "invalid access token")
			return
		}
		if sessionID != "" && s.db != nil {
			var active bool
			err := s.db.QueryRow(
				r.Context(),
				`select exists(select 1 from auth_sessions where id = $1 and user_id = $2 and revoked_at is null and expires_at > now())`,
				sessionID,
				userID,
			).Scan(&active)
			if err != nil {
				writeError(w, http.StatusServiceUnavailable, "database_unavailable", "session service is temporarily unavailable")
				return
			}
			if !active {
				writeError(w, http.StatusUnauthorized, "session_invalid", "session has expired or was revoked")
				return
			}
		}

		ctx := context.WithValue(r.Context(), contextKeyUserID{}, userID)
		ctx = context.WithValue(ctx, contextKeyEmail{}, email)
		ctx = context.WithValue(ctx, contextKeySessionID{}, sessionID)
		next(w, r.WithContext(ctx))
	}
}

type authUserRecord struct {
	ID           string
	Email        string
	DisplayName  string
	PasswordHash string
}

var errNotFound = errors.New("record not found")
var errSyncOwnershipConflict = errors.New("sync record id belongs to another user")
var errSyncVersionConflict = errors.New("sync record has a newer or competing version")

func authUserPayload(user authUserRecord) map[string]any {
	return map[string]any{
		"id":          user.ID,
		"email":       user.Email,
		"displayName": user.DisplayName,
		"isAnonymous": false,
	}
}

func (s *Server) lookupUserByEmail(ctx context.Context, email string) (authUserRecord, error) {
	var user authUserRecord
	err := s.db.QueryRow(
		ctx,
		`select id, email, coalesce(nullif(display_name, ''), email), password_hash
		   from users
		  where lower(email) = lower($1)`,
		normalizeEmail(email),
	).Scan(&user.ID, &user.Email, &user.DisplayName, &user.PasswordHash)
	return user, err
}

func (s *Server) lookupUserByID(ctx context.Context, userID string) (authUserRecord, error) {
	var user authUserRecord
	err := s.db.QueryRow(
		ctx,
		`select id, email, coalesce(nullif(display_name, ''), email), password_hash
		   from users
		  where id = $1`,
		userID,
	).Scan(&user.ID, &user.Email, &user.DisplayName, &user.PasswordHash)
	return user, err
}

func normalizeSyncRow(spec tableSpec, row map[string]any, userID string) (map[string]any, error) {
	id, _ := row["id"].(string)
	if strings.TrimSpace(id) == "" {
		return nil, errors.New("sync row must include id")
	}

	if rawUserID, ok := row["user_id"]; ok {
		parsedUserID, _ := rawUserID.(string)
		if parsedUserID != "" && parsedUserID != userID {
			return nil, errors.New("sync row user_id does not match authenticated user")
		}
	}
	row["user_id"] = userID

	normalized := make(map[string]any, len(spec.Columns))
	for _, column := range spec.Columns {
		value, ok := row[column]
		if !ok {
			normalized[column] = nil
			continue
		}
		parsed, err := normalizeColumnValue(column, value)
		if err != nil {
			return nil, fmt.Errorf("invalid %s: %w", column, err)
		}
		normalized[column] = parsed
	}
	version, ok := normalized["version"].(int)
	if !ok || version < 1 {
		return nil, errors.New("sync row version must be a positive integer")
	}
	if spec.Name == "progress_photos" {
		if _, err := uuid.Parse(id); err != nil {
			return nil, errors.New("progress photo id must be a UUID")
		}
		storagePath, _ := normalized["storage_path"].(string)
		if !validProgressPhotoStoragePath(userID, id, storagePath) {
			return nil, errors.New("progress photo storage_path does not match its authenticated owner and id")
		}
	}
	return normalized, nil
}

func validProgressPhotoStoragePath(userID, photoID, storagePath string) bool {
	clean := filepath.ToSlash(filepath.Clean(strings.TrimSpace(storagePath)))
	prefix := "users/" + userID + "/progress_photos/" + photoID + "/original"
	return clean == prefix+".jpg" || clean == prefix+".png" || clean == prefix+".gif"
}

func normalizeColumnValue(column string, value any) (any, error) {
	if value == nil {
		return nil, nil
	}

	switch column {
	case "is_built_in":
		switch typed := value.(type) {
		case bool:
			return typed, nil
		case string:
			return strings.EqualFold(typed, "true"), nil
		default:
			return nil, errors.New("expected boolean")
		}
	case "current_workout_index", "version":
		return normalizeIntValue(value)
	case "weight_kg", "body_fat_percent", "waist_cm":
		return normalizeFloatValue(value)
	case "created_at", "updated_at", "deleted_at", "completed_at", "captured_at", "timestamp":
		switch typed := value.(type) {
		case string:
			if typed == "" {
				return nil, nil
			}
			parsed, err := time.Parse(time.RFC3339, typed)
			if err != nil {
				return nil, err
			}
			return parsed.UTC(), nil
		default:
			return nil, errors.New("expected RFC3339 timestamp")
		}
	default:
		return value, nil
	}
}

func normalizeIntValue(value any) (int, error) {
	switch typed := value.(type) {
	case int:
		return typed, nil
	case int32:
		return int(typed), nil
	case int64:
		return int(typed), nil
	case float64:
		if math.IsNaN(typed) || math.IsInf(typed, 0) || math.Trunc(typed) != typed {
			return 0, errors.New("expected integer")
		}
		return int(typed), nil
	case json.Number:
		parsed, err := typed.Int64()
		return int(parsed), err
	case string:
		parsed, err := strconv.Atoi(typed)
		return parsed, err
	default:
		return 0, errors.New("expected integer")
	}
}

func normalizeFloatValue(value any) (float64, error) {
	switch typed := value.(type) {
	case float64:
		if math.IsNaN(typed) || math.IsInf(typed, 0) {
			return 0, errors.New("expected finite number")
		}
		return typed, nil
	case float32:
		if math.IsNaN(float64(typed)) || math.IsInf(float64(typed), 0) {
			return 0, errors.New("expected finite number")
		}
		return float64(typed), nil
	case int:
		return float64(typed), nil
	case int64:
		return float64(typed), nil
	case json.Number:
		parsed, err := typed.Float64()
		if err != nil || math.IsNaN(parsed) || math.IsInf(parsed, 0) {
			return 0, errors.New("expected finite number")
		}
		return parsed, nil
	case string:
		parsed, err := strconv.ParseFloat(typed, 64)
		if err != nil || math.IsNaN(parsed) || math.IsInf(parsed, 0) {
			return 0, errors.New("expected finite number")
		}
		return parsed, nil
	default:
		return 0, errors.New("expected number")
	}
}

func (s *Server) upsertSyncRow(ctx context.Context, spec tableSpec, row map[string]any) (map[string]any, error) {
	placeholders := make([]string, 0, len(spec.Columns))
	args := make([]any, 0, len(spec.Columns))
	for index, column := range spec.Columns {
		placeholders = append(placeholders, fmt.Sprintf("$%d", index+1))
		args = append(args, row[column])
	}

	updateClauses := make([]string, 0, len(spec.UpsertColumns))
	for _, column := range spec.UpsertColumns {
		updateClauses = append(updateClauses, fmt.Sprintf("%s = excluded.%s", column, column))
	}

	query := fmt.Sprintf(
		`insert into %s as target (%s)
		 values (%s)
		 on conflict (id) do update
		     set %s
		 where target.user_id = excluded.user_id
		   and (
		        excluded.version > target.version
		        or (
		             excluded.version = target.version
		             and coalesce(excluded.last_modified_by_device_id, '') = coalesce(target.last_modified_by_device_id, '')
		           )
		       )
		 returning row_to_json(target)`,
		spec.Name,
		strings.Join(spec.Columns, ", "),
		strings.Join(placeholders, ", "),
		strings.Join(updateClauses, ", "),
	)

	var encoded []byte
	if err := s.db.QueryRow(ctx, query, args...).Scan(&encoded); err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			var existingUserID string
			lookupQuery := fmt.Sprintf(`select user_id from %s where id = $1`, spec.Name)
			lookupErr := s.db.QueryRow(ctx, lookupQuery, row["id"]).Scan(&existingUserID)
			if errors.Is(lookupErr, pgx.ErrNoRows) {
				return nil, err
			}
			if lookupErr != nil {
				return nil, lookupErr
			}
			if existingUserID != row["user_id"] {
				return nil, errSyncOwnershipConflict
			}
			return nil, errSyncVersionConflict
		}
		return nil, err
	}
	return decodeJSONRow(encoded)
}

func (s *Server) fetchSyncRows(
	ctx context.Context,
	spec tableSpec,
	userID string,
	timestampColumn string,
	since *time.Time,
	cursorUpdatedAt *time.Time,
	cursorID string,
	limit int,
) ([]map[string]any, error) {
	query := fmt.Sprintf(
		`select coalesce(json_agg(row_to_json(records)), '[]'::json)
		   from (
		         select %s
		           from %s
		          where user_id = $1
		            and ($2::timestamptz is null or %s >= $2)
		            and ($3::timestamptz is null or (updated_at, id) > ($3, $4))
		          order by updated_at asc, id asc
		          limit $5
		        ) as records`,
		strings.Join(spec.Columns, ", "),
		spec.Name,
		timestampColumn,
	)

	var encoded []byte
	if err := s.db.QueryRow(ctx, query, userID, since, cursorUpdatedAt, cursorID, limit).Scan(&encoded); err != nil {
		return nil, err
	}
	return decodeJSONRows(encoded)
}

func (s *Server) softDeleteSyncRow(
	ctx context.Context,
	spec tableSpec,
	userID string,
	recordID string,
	expectedVersion *int,
	deviceID string,
) (map[string]any, error) {
	if expectedVersion != nil {
		query := fmt.Sprintf(
			`update %s
			    set deleted_at = coalesce(deleted_at, now()),
			        updated_at = now(),
			        version = $3,
			        last_modified_by_device_id = nullif($4, '')
			  where id = $1
			    and user_id = $2
			    and (
			         version < $3
			         or (version = $3 and coalesce(last_modified_by_device_id, '') = $4)
			        )
			  returning row_to_json(%s)`,
			spec.Name,
			spec.Name,
		)
		var encoded []byte
		err := s.db.QueryRow(
			ctx,
			query,
			recordID,
			userID,
			*expectedVersion,
			strings.TrimSpace(deviceID),
		).Scan(&encoded)
		if err == nil {
			return decodeJSONRow(encoded)
		}
		if !errors.Is(err, pgx.ErrNoRows) {
			return nil, err
		}
		var exists bool
		lookup := fmt.Sprintf(
			`select exists(select 1 from %s where id = $1 and user_id = $2)`,
			spec.Name,
		)
		if err := s.db.QueryRow(ctx, lookup, recordID, userID).Scan(&exists); err != nil {
			return nil, err
		}
		if !exists {
			return nil, errNotFound
		}
		return nil, errSyncVersionConflict
	}
	query := fmt.Sprintf(
		`update %s
		    set deleted_at = coalesce(deleted_at, now()),
		        updated_at = now(),
		        version = version + 1
		  where id = $1
		    and user_id = $2
		  returning row_to_json(%s)`,
		spec.Name,
		spec.Name,
	)

	var encoded []byte
	if err := s.db.QueryRow(ctx, query, recordID, userID).Scan(&encoded); err != nil {
		if strings.Contains(err.Error(), "no rows in result set") {
			return nil, errNotFound
		}
		return nil, err
	}
	return decodeJSONRow(encoded)
}

func decodeJSONRow(encoded []byte) (map[string]any, error) {
	var row map[string]any
	if err := json.Unmarshal(encoded, &row); err != nil {
		return nil, err
	}
	return row, nil
}

func decodeJSONRows(encoded []byte) ([]map[string]any, error) {
	var rows []map[string]any
	if err := json.Unmarshal(encoded, &rows); err != nil {
		return nil, err
	}
	return rows, nil
}

func supportsRefreshSessions(r *http.Request) bool {
	return strings.TrimSpace(r.Header.Get(authProtocolVersionHeader)) == "2"
}

var (
	errRefreshCredentialMissing = errors.New("refresh credential is required")
	errAuthSessionInactive      = errors.New("auth session is no longer active")
)

func isWebAuthClient(r *http.Request) bool {
	return strings.EqualFold(strings.TrimSpace(r.Header.Get(authPlatformHeader)), "web")
}

func (s *Server) accessTokenTTL() time.Duration {
	if s.cfg.AccessTokenTTL > 0 {
		return s.cfg.AccessTokenTTL
	}
	return 15 * time.Minute
}

func (s *Server) refreshTokenTTL() time.Duration {
	if s.cfg.RefreshTokenTTL > 0 {
		return s.cfg.RefreshTokenTTL
	}
	return 180 * 24 * time.Hour
}

func (s *Server) issueAuthSessionWithExecutor(
	ctx context.Context,
	executor commandExecutor,
	userID string,
	email string,
	deviceID string,
	refreshCapable bool,
) (issuedAuthSession, error) {
	if !refreshCapable {
		token, err := s.issueSessionTokenWithExecutor(ctx, executor, userID, email, deviceID)
		return issuedAuthSession{AccessToken: token}, err
	}

	now := time.Now().UTC()
	sessionID := uuid.NewString()
	refreshToken, refreshHash, err := s.refreshTokenForRotation(sessionID, 0)
	if err != nil {
		return issuedAuthSession{}, err
	}
	accessExpiry := now.Add(s.accessTokenTTL())
	accessToken, err := s.issueTokenWithSessionTTL(userID, email, sessionID, now, s.accessTokenTTL())
	if err != nil {
		return issuedAuthSession{}, err
	}
	refreshExpiry := now.Add(s.refreshTokenTTL())
	_, err = executor.Exec(
		ctx,
		`insert into auth_sessions (
			id, user_id, issued_at, expires_at, device_id,
			refresh_token_hash, refresh_token_rotated_at, last_refreshed_at
		 ) values ($1, $2, $3, $4, nullif($5, ''), $6, $3, $3)`,
		sessionID,
		userID,
		now,
		refreshExpiry,
		strings.TrimSpace(deviceID),
		refreshHash,
	)
	if err != nil {
		return issuedAuthSession{}, err
	}
	return issuedAuthSession{
		AccessToken:           accessToken,
		AccessTokenExpiresAt:  accessExpiry,
		RefreshToken:          refreshToken,
		RefreshTokenExpiresAt: refreshExpiry,
		HasRefreshToken:       true,
	}, nil
}

func (s *Server) bootstrapRefreshSession(
	ctx context.Context,
	sessionID string,
	userID string,
	email string,
) (issuedAuthSession, error) {
	if sessionID == "" {
		return issuedAuthSession{}, errors.New("session id is required")
	}
	tx, err := s.db.Begin(ctx)
	if err != nil {
		return issuedAuthSession{}, err
	}
	defer tx.Rollback(ctx)

	var storedUserID string
	var sessionExpiry time.Time
	var revokedAt pgtype.Timestamptz
	var refreshHash []byte
	var rotationCounter int64
	err = tx.QueryRow(
		ctx,
		`select user_id, expires_at, revoked_at, refresh_token_hash, rotation_counter
		   from auth_sessions
		  where id = $1
		  for update`,
		sessionID,
	).Scan(&storedUserID, &sessionExpiry, &revokedAt, &refreshHash, &rotationCounter)
	if err != nil {
		return issuedAuthSession{}, err
	}
	if storedUserID != userID || revokedAt.Valid || !sessionExpiry.After(time.Now().UTC()) {
		return issuedAuthSession{}, errAuthSessionInactive
	}

	now := time.Now().UTC()
	refreshToken, newHash, err := s.refreshTokenForRotation(sessionID, rotationCounter)
	if err != nil {
		return issuedAuthSession{}, err
	}
	sessionExpiry = now.Add(s.refreshTokenTTL())
	if len(refreshHash) == 0 {
		_, err = tx.Exec(
			ctx,
			`update auth_sessions
			    set refresh_token_hash = $2,
			        refresh_token_rotated_at = $3,
			        last_refreshed_at = $3,
			        expires_at = $4
			  where id = $1`,
			sessionID,
			newHash,
			now,
			sessionExpiry,
		)
		if err != nil {
			return issuedAuthSession{}, err
		}
	} else if equalRefreshHash(refreshHash, newHash) {
		// Bootstrap is idempotent. Repeated or concurrent upgrades return the
		// same current credential instead of rotating it again and racing the
		// delivery of an older response.
		_, err = tx.Exec(
			ctx,
			`update auth_sessions
			    set last_refreshed_at = $2,
			        expires_at = $3
			  where id = $1`,
			sessionID,
			now,
			sessionExpiry,
		)
		if err != nil {
			return issuedAuthSession{}, err
		}
	} else {
		// Sessions created by an earlier random-token implementation cannot be
		// reconstructed. Convert them once to the counter-derived format while
		// holding the row lock; every concurrent waiter then returns this value.
		rotationCounter++
		refreshToken, newHash, err = s.refreshTokenForRotation(sessionID, rotationCounter)
		if err != nil {
			return issuedAuthSession{}, err
		}
		_, err = tx.Exec(
			ctx,
			`update auth_sessions
			    set previous_refresh_token_hash = refresh_token_hash,
			        refresh_token_hash = $2,
			        refresh_token_rotated_at = $3,
			        last_refreshed_at = $3,
			        expires_at = $4,
			        rotation_counter = $5
			  where id = $1`,
			sessionID,
			newHash,
			now,
			sessionExpiry,
			rotationCounter,
		)
		if err != nil {
			return issuedAuthSession{}, err
		}
	}

	accessToken, err := s.issueTokenWithSessionTTL(userID, email, sessionID, now, s.accessTokenTTL())
	if err != nil {
		return issuedAuthSession{}, err
	}
	if err := tx.Commit(ctx); err != nil {
		return issuedAuthSession{}, err
	}
	return issuedAuthSession{
		AccessToken:           accessToken,
		AccessTokenExpiresAt:  now.Add(s.accessTokenTTL()),
		RefreshToken:          refreshToken,
		RefreshTokenExpiresAt: sessionExpiry,
		HasRefreshToken:       true,
	}, nil
}

func refreshTokenFromRequest(w http.ResponseWriter, r *http.Request) (string, error) {
	if isWebAuthClient(r) {
		cookie, err := r.Cookie(refreshCookieName)
		if err != nil || strings.TrimSpace(cookie.Value) == "" {
			return "", errRefreshCredentialMissing
		}
		return strings.TrimSpace(cookie.Value), nil
	}
	var req struct {
		RefreshToken string `json:"refreshToken"`
	}
	if err := decodeJSONBody(w, r, &req, maxRefreshBodyBytes); err != nil {
		return "", err
	}
	if strings.TrimSpace(req.RefreshToken) == "" {
		return "", errRefreshCredentialMissing
	}
	return strings.TrimSpace(req.RefreshToken), nil
}

func (s *Server) rotateRefreshSession(
	ctx context.Context,
	refreshToken string,
) (issuedAuthSession, authUserRecord, int, string, error) {
	sessionID, presentedHash, err := parseRefreshToken(refreshToken)
	if err != nil {
		return issuedAuthSession{}, authUserRecord{}, http.StatusUnauthorized, "refresh_invalid", err
	}
	tx, err := s.db.Begin(ctx)
	if err != nil {
		return issuedAuthSession{}, authUserRecord{}, http.StatusServiceUnavailable, "database_unavailable", err
	}
	defer tx.Rollback(ctx)

	var userID string
	var sessionExpiry time.Time
	var revokedAt pgtype.Timestamptz
	var currentHash []byte
	var previousHash []byte
	var rotatedAt pgtype.Timestamptz
	var lastRefreshedAt pgtype.Timestamptz
	var rotationCounter int64
	err = tx.QueryRow(
		ctx,
		`select user_id, expires_at, revoked_at, refresh_token_hash,
		        previous_refresh_token_hash, refresh_token_rotated_at,
		        last_refreshed_at, rotation_counter
		   from auth_sessions
		  where id = $1
		  for update`,
		sessionID,
	).Scan(
		&userID,
		&sessionExpiry,
		&revokedAt,
		&currentHash,
		&previousHash,
		&rotatedAt,
		&lastRefreshedAt,
		&rotationCounter,
	)
	if errors.Is(err, pgx.ErrNoRows) {
		return issuedAuthSession{}, authUserRecord{}, http.StatusUnauthorized, "refresh_invalid", err
	}
	if err != nil {
		return issuedAuthSession{}, authUserRecord{}, http.StatusServiceUnavailable, "database_unavailable", err
	}
	if revokedAt.Valid {
		return issuedAuthSession{}, authUserRecord{}, http.StatusUnauthorized, "session_revoked", errors.New("session revoked")
	}
	now := time.Now().UTC()
	if !sessionExpiry.After(now) {
		return issuedAuthSession{}, authUserRecord{}, http.StatusUnauthorized, "refresh_expired", errors.New("refresh expired")
	}
	credentialMatch := classifyRefreshCredential(presentedHash, currentHash, previousHash, rotatedAt, now)
	switch credentialMatch {
	case refreshCredentialPreviousRace:
		// The row lock proves another request completed the rotation first. The
		// counter-derived token lets concurrent requests converge on that same
		// credential without storing plaintext refresh tokens.
	case refreshCredentialPreviousReuse:
		_, updateErr := tx.Exec(
			ctx,
			`update auth_sessions
				    set revoked_at = $2, refresh_reuse_detected_at = $2
				  where id = $1`,
			sessionID,
			now,
		)
		if updateErr != nil {
			return issuedAuthSession{}, authUserRecord{}, http.StatusServiceUnavailable, "database_unavailable", updateErr
		}
		if commitErr := tx.Commit(ctx); commitErr != nil {
			return issuedAuthSession{}, authUserRecord{}, http.StatusServiceUnavailable, "database_unavailable", commitErr
		}
		return issuedAuthSession{}, authUserRecord{}, http.StatusUnauthorized, "refresh_reused", errors.New("refresh token reused")
	case refreshCredentialInvalid:
		return issuedAuthSession{}, authUserRecord{}, http.StatusUnauthorized, "refresh_invalid", errors.New("refresh token invalid")
	case refreshCredentialCurrent:
		// Rotate below unless this is a duplicate request in the short
		// convergence window opened by bootstrap or another refresh.
	}

	var responseRefreshToken string
	refreshExpiry := sessionExpiry
	if shouldRotateRefreshCredential(credentialMatch, lastRefreshedAt, now) {
		rotationCounter++
		responseRefreshToken, currentHash, err = s.refreshTokenForRotation(sessionID, rotationCounter)
		if err != nil {
			return issuedAuthSession{}, authUserRecord{}, http.StatusInternalServerError, "refresh_issue_failed", err
		}
		refreshExpiry = now.Add(s.refreshTokenTTL())
		_, err = tx.Exec(
			ctx,
			`update auth_sessions
			    set previous_refresh_token_hash = refresh_token_hash,
			        refresh_token_hash = $2,
			        refresh_token_rotated_at = $3,
			        last_refreshed_at = $3,
			        expires_at = $4,
			        rotation_counter = $5
			  where id = $1`,
			sessionID,
			currentHash,
			now,
			refreshExpiry,
			rotationCounter,
		)
		if err != nil {
			return issuedAuthSession{}, authUserRecord{}, http.StatusServiceUnavailable, "database_unavailable", err
		}
	} else {
		var expectedHash []byte
		responseRefreshToken, expectedHash, err = s.refreshTokenForRotation(sessionID, rotationCounter)
		if err != nil {
			return issuedAuthSession{}, authUserRecord{}, http.StatusInternalServerError, "refresh_issue_failed", err
		}
		if !equalRefreshHash(expectedHash, currentHash) {
			// Compatibility fallback for a session whose current token predates
			// counter-derived rotation. The client can retry after the winner's
			// credential has been persisted.
			return issuedAuthSession{}, authUserRecord{}, http.StatusConflict, "refresh_race", errors.New("refresh already rotated")
		}
	}

	var user authUserRecord
	err = tx.QueryRow(
		ctx,
		`select id, email, coalesce(nullif(display_name, ''), email), password_hash
		   from users
		  where id = $1`,
		userID,
	).Scan(&user.ID, &user.Email, &user.DisplayName, &user.PasswordHash)
	if err != nil {
		return issuedAuthSession{}, authUserRecord{}, http.StatusUnauthorized, "session_invalid", err
	}
	accessToken, err := s.issueTokenWithSessionTTL(user.ID, user.Email, sessionID, now, s.accessTokenTTL())
	if err != nil {
		return issuedAuthSession{}, authUserRecord{}, http.StatusInternalServerError, "refresh_issue_failed", err
	}
	if err := tx.Commit(ctx); err != nil {
		return issuedAuthSession{}, authUserRecord{}, http.StatusServiceUnavailable, "database_unavailable", err
	}
	return issuedAuthSession{
		AccessToken:           accessToken,
		AccessTokenExpiresAt:  now.Add(s.accessTokenTTL()),
		RefreshToken:          responseRefreshToken,
		RefreshTokenExpiresAt: refreshExpiry,
		HasRefreshToken:       true,
	}, user, http.StatusOK, "", nil
}

func (s *Server) refreshTokenForRotation(sessionID string, rotationCounter int64) (string, []byte, error) {
	if _, err := uuid.Parse(sessionID); err != nil || rotationCounter < 0 || strings.TrimSpace(s.cfg.JWTSecret) == "" {
		return "", nil, errors.New("invalid refresh token inputs")
	}
	mac := hmac.New(sha256.New, []byte(s.cfg.JWTSecret))
	_, _ = mac.Write([]byte("fittin-refresh-v1\x00"))
	_, _ = mac.Write([]byte(sessionID))
	_, _ = mac.Write([]byte("\x00"))
	_, _ = mac.Write([]byte(strconv.FormatInt(rotationCounter, 10)))
	secret := mac.Sum(nil)
	token := sessionID + "." + base64.RawURLEncoding.EncodeToString(secret)
	hash := sha256.Sum256([]byte(token))
	return token, hash[:], nil
}

func parseRefreshToken(token string) (string, []byte, error) {
	sessionID, secret, ok := strings.Cut(strings.TrimSpace(token), ".")
	if !ok || sessionID == "" || secret == "" {
		return "", nil, errors.New("invalid refresh token")
	}
	if _, err := uuid.Parse(sessionID); err != nil {
		return "", nil, errors.New("invalid refresh token")
	}
	decoded, err := base64.RawURLEncoding.DecodeString(secret)
	if err != nil || len(decoded) != 32 {
		return "", nil, errors.New("invalid refresh token")
	}
	hash := sha256.Sum256([]byte(token))
	return sessionID, hash[:], nil
}

func equalRefreshHash(left, right []byte) bool {
	return len(left) == sha256.Size && len(right) == sha256.Size && subtle.ConstantTimeCompare(left, right) == 1
}

func classifyRefreshCredential(
	presented []byte,
	current []byte,
	previous []byte,
	rotatedAt pgtype.Timestamptz,
	now time.Time,
) refreshCredentialMatch {
	if equalRefreshHash(presented, current) {
		return refreshCredentialCurrent
	}
	if !equalRefreshHash(presented, previous) {
		return refreshCredentialInvalid
	}
	if rotatedAt.Valid && now.Sub(rotatedAt.Time) <= refreshRaceGrace {
		return refreshCredentialPreviousRace
	}
	return refreshCredentialPreviousReuse
}

func shouldRotateRefreshCredential(
	credentialMatch refreshCredentialMatch,
	lastRefreshedAt pgtype.Timestamptz,
	now time.Time,
) bool {
	if credentialMatch != refreshCredentialCurrent {
		return false
	}
	return !lastRefreshedAt.Valid || now.Sub(lastRefreshedAt.Time) > refreshRaceGrace
}

func refreshErrorMessage(code string) string {
	switch code {
	case "refresh_race":
		return "refresh was already rotated; retry with the latest credential"
	case "database_unavailable":
		return "session service is temporarily unavailable"
	case "refresh_expired":
		return "refresh session has expired"
	case "session_revoked", "refresh_reused":
		return "refresh session has been revoked"
	default:
		return "refresh session is invalid"
	}
}

func (s *Server) writeAuthResponse(
	w http.ResponseWriter,
	r *http.Request,
	status int,
	credentials issuedAuthSession,
	user map[string]any,
) {
	response := authResponse{
		AccessToken:     credentials.AccessToken,
		HasRefreshToken: credentials.HasRefreshToken,
		User:            user,
	}
	if !credentials.AccessTokenExpiresAt.IsZero() {
		response.AccessTokenExpiresAt = credentials.AccessTokenExpiresAt.UTC().Format(time.RFC3339)
	}
	if !credentials.RefreshTokenExpiresAt.IsZero() {
		response.RefreshTokenExpiresAt = credentials.RefreshTokenExpiresAt.UTC().Format(time.RFC3339)
	}
	if credentials.RefreshToken != "" {
		if isWebAuthClient(r) {
			setRefreshCookie(w, r, credentials.RefreshToken, credentials.RefreshTokenExpiresAt)
		} else {
			response.RefreshToken = credentials.RefreshToken
		}
	}
	writeJSON(w, status, response)
}

func setRefreshCookie(w http.ResponseWriter, r *http.Request, token string, expiresAt time.Time) {
	http.SetCookie(w, &http.Cookie{
		Name:     refreshCookieName,
		Value:    token,
		Path:     "/",
		Expires:  expiresAt,
		MaxAge:   int(time.Until(expiresAt).Seconds()),
		HttpOnly: true,
		Secure:   requestUsesHTTPS(r),
		SameSite: http.SameSiteStrictMode,
	})
}

func clearRefreshCookie(w http.ResponseWriter, r *http.Request) {
	http.SetCookie(w, &http.Cookie{
		Name:     refreshCookieName,
		Value:    "",
		Path:     "/",
		Expires:  time.Unix(1, 0),
		MaxAge:   -1,
		HttpOnly: true,
		Secure:   requestUsesHTTPS(r),
		SameSite: http.SameSiteStrictMode,
	})
}

func requestUsesHTTPS(r *http.Request) bool {
	return r.TLS != nil || strings.EqualFold(strings.TrimSpace(r.Header.Get("X-Forwarded-Proto")), "https")
}

func (s *Server) issueToken(userID, email string) (string, error) {
	return s.issueTokenWithSession(userID, email, uuid.NewString(), time.Now())
}

func (s *Server) issueSessionToken(ctx context.Context, userID, email, deviceID string) (string, error) {
	return s.issueSessionTokenWithExecutor(ctx, s.db, userID, email, deviceID)
}

type commandExecutor interface {
	Exec(context.Context, string, ...any) (pgconn.CommandTag, error)
}

func (s *Server) issueSessionTokenWithExecutor(ctx context.Context, executor commandExecutor, userID, email, deviceID string) (string, error) {
	now := time.Now().UTC()
	sessionID := uuid.NewString()
	token, err := s.issueTokenWithSession(userID, email, sessionID, now)
	if err != nil {
		return "", err
	}
	_, err = executor.Exec(
		ctx,
		`insert into auth_sessions (id, user_id, issued_at, expires_at, device_id) values ($1, $2, $3, $4, nullif($5, ''))`,
		sessionID,
		userID,
		now,
		now.Add(24*time.Hour),
		strings.TrimSpace(deviceID),
	)
	if err != nil {
		return "", err
	}
	return token, nil
}

func (s *Server) issueTokenWithSession(userID, email, sessionID string, now time.Time) (string, error) {
	return s.issueTokenWithSessionTTL(userID, email, sessionID, now, 24*time.Hour)
}

func (s *Server) issueTokenWithSessionTTL(
	userID string,
	email string,
	sessionID string,
	now time.Time,
	ttl time.Duration,
) (string, error) {
	claims := jwt.MapClaims{
		"sub":   userID,
		"email": email,
		"jti":   sessionID,
		"typ":   "access",
		"iss":   "fittin",
		"aud":   "fittin-api",
		"exp":   now.Add(ttl).Unix(),
		"iat":   now.Unix(),
	}
	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
	return token.SignedString([]byte(s.cfg.JWTSecret))
}

func bearerToken(header string) string {
	if header == "" {
		return ""
	}
	parts := strings.SplitN(header, " ", 2)
	if len(parts) != 2 || !strings.EqualFold(parts[0], "bearer") {
		return ""
	}
	return parts[1]
}

func normalizeEmail(email string) string {
	return strings.ToLower(strings.TrimSpace(email))
}

func decodeJSONBody(w http.ResponseWriter, r *http.Request, destination any, maxBytes int64) error {
	r.Body = http.MaxBytesReader(w, r.Body, maxBytes)
	decoder := json.NewDecoder(r.Body)
	decoder.UseNumber()
	if err := decoder.Decode(destination); err != nil {
		return err
	}
	var trailing any
	if err := decoder.Decode(&trailing); !errors.Is(err, io.EOF) {
		if err == nil {
			return errors.New("multiple JSON values are not allowed")
		}
		return err
	}
	return nil
}

func writeJSON(w http.ResponseWriter, status int, payload any) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(status)
	_ = json.NewEncoder(w).Encode(payload)
}

func writeError(w http.ResponseWriter, status int, fields ...string) {
	code := "request_failed"
	message := http.StatusText(status)
	if len(fields) == 1 {
		message = fields[0]
	}
	if len(fields) >= 2 {
		code = fields[0]
		message = fields[1]
	}
	writeJSON(w, status, map[string]any{"error": message, "code": code})
}
