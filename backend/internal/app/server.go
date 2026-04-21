package app

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"net/http"
	"os"
	"path/filepath"
	"strconv"
	"strings"
	"time"

	"github.com/golang-jwt/jwt/v5"
	"github.com/google/uuid"
	"github.com/jackc/pgx/v5/pgxpool"
	"golang.org/x/crypto/bcrypt"
)

type Server struct {
	cfg        Config
	db         *pgxpool.Pool
	httpServer *http.Server
}

type tableSpec struct {
	Name             string
	Columns          []string
	UpsertColumns    []string
	AllowedTimestamp map[string]bool
}

var syncTableSpecs = map[string]tableSpec{
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
		cfg: cfg,
		db:  pool,
	}

	mux := http.NewServeMux()
	mux.HandleFunc("/", server.handleRoot)
	mux.HandleFunc("/healthz", server.handleHealthz)
	mux.HandleFunc("/v1/auth/sign-up", server.handleSignUp)
	mux.HandleFunc("/v1/auth/sign-in", server.handleSignIn)
	mux.HandleFunc("/v1/auth/session", server.withAuth(server.handleSession))
	mux.HandleFunc("/v1/auth/sign-out", server.withAuth(server.handleSignOut))
	mux.HandleFunc("/v1/sync/upsert/", server.withAuth(server.handleSyncUpsert))
	mux.HandleFunc("/v1/sync/", server.withAuth(server.handleSync))
	mux.HandleFunc("/v1/files/progress-photos", server.withAuth(server.handleProgressPhotoUpload))

	server.httpServer = &http.Server{
		Addr:              cfg.Addr,
		Handler:           server.withCORS(mux),
		ReadHeaderTimeout: 5 * time.Second,
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
			if origin == "https://fittin.yimelo.cc" {
				w.Header().Set("Access-Control-Allow-Origin", origin)
				w.Header().Set("Access-Control-Allow-Headers", "Authorization, Content-Type")
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
	})
}

func (s *Server) handleHealthz(w http.ResponseWriter, r *http.Request) {
	writeJSON(w, http.StatusOK, map[string]any{"ok": true})
}

type authRequest struct {
	Email    string `json:"email"`
	Password string `json:"password"`
}

type authResponse struct {
	AccessToken string         `json:"accessToken"`
	User        map[string]any `json:"user"`
}

func (s *Server) handleSignUp(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		writeError(w, http.StatusMethodNotAllowed, "method not allowed")
		return
	}

	var req authRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		writeError(w, http.StatusBadRequest, "invalid auth payload")
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
	_, err = s.db.Exec(
		r.Context(),
		`insert into users (id, email, password_hash, display_name, created_at, updated_at)
		 values ($1, $2, $3, $4, now(), now())`,
		userID,
		req.Email,
		string(passwordHash),
		req.Email,
	)
	if err != nil {
		writeError(w, http.StatusConflict, "failed to create user")
		return
	}

	token, err := s.issueToken(userID, req.Email)
	if err != nil {
		writeError(w, http.StatusInternalServerError, "failed to issue token")
		return
	}

	writeJSON(w, http.StatusCreated, authResponse{
		AccessToken: token,
		User: map[string]any{
			"id":          userID,
			"email":       req.Email,
			"displayName": req.Email,
			"isAnonymous": false,
		},
	})
}

func (s *Server) handleSignIn(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		writeError(w, http.StatusMethodNotAllowed, "method not allowed")
		return
	}

	var req authRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		writeError(w, http.StatusBadRequest, "invalid auth payload")
		return
	}

	user, err := s.lookupUserByEmail(r.Context(), req.Email)
	if err != nil {
		writeError(w, http.StatusUnauthorized, "invalid credentials")
		return
	}

	if err := bcrypt.CompareHashAndPassword([]byte(user.PasswordHash), []byte(req.Password)); err != nil {
		writeError(w, http.StatusUnauthorized, "invalid credentials")
		return
	}

	token, err := s.issueToken(user.ID, user.Email)
	if err != nil {
		writeError(w, http.StatusInternalServerError, "failed to issue token")
		return
	}

	writeJSON(w, http.StatusOK, authResponse{
		AccessToken: token,
		User:        authUserPayload(user),
	})
}

func (s *Server) handleSession(w http.ResponseWriter, r *http.Request) {
	userID := r.Context().Value(contextKeyUserID{}).(string)
	user, err := s.lookupUserByID(r.Context(), userID)
	if err != nil {
		writeError(w, http.StatusUnauthorized, "session user no longer exists")
		return
	}
	writeJSON(w, http.StatusOK, authResponse{
		AccessToken: bearerToken(r.Header.Get("Authorization")),
		User:        authUserPayload(user),
	})
}

func (s *Server) handleSignOut(w http.ResponseWriter, r *http.Request) {
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
	if err := json.NewDecoder(r.Body).Decode(&row); err != nil {
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
		writeError(w, http.StatusInternalServerError, err.Error())
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

		deletedRow, err := s.softDeleteSyncRow(r.Context(), spec, userID, parts[1])
		if err != nil {
			status := http.StatusInternalServerError
			if errors.Is(err, errNotFound) {
				status = http.StatusNotFound
			}
			writeError(w, status, err.Error())
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

		rows, err := s.fetchSyncRows(r.Context(), spec, userID, timestampColumn, since)
		if err != nil {
			writeError(w, http.StatusInternalServerError, err.Error())
			return
		}

		writeJSON(w, http.StatusOK, map[string]any{
			"table": spec.Name,
			"rows":  rows,
		})
		return
	}
	writeError(w, http.StatusMethodNotAllowed, "method not allowed")
}

func (s *Server) handleProgressPhotoUpload(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		writeError(w, http.StatusMethodNotAllowed, "method not allowed")
		return
	}
	if err := r.ParseMultipartForm(20 << 20); err != nil {
		writeError(w, http.StatusBadRequest, "invalid multipart payload")
		return
	}

	userID := r.FormValue("userId")
	photoID := r.FormValue("photoId")
	file, _, err := r.FormFile("file")
	if err != nil {
		writeError(w, http.StatusBadRequest, "missing file")
		return
	}
	defer file.Close()

	storagePath := filepath.Join("users", userID, "progress_photos", photoID, "original.jpg")
	absolutePath := filepath.Join(s.cfg.FileStorageRoot, storagePath)
	if err := os.MkdirAll(filepath.Dir(absolutePath), 0o755); err != nil {
		writeError(w, http.StatusInternalServerError, "failed to prepare storage directory")
		return
	}

	out, err := os.Create(absolutePath)
	if err != nil {
		writeError(w, http.StatusInternalServerError, "failed to create destination file")
		return
	}
	defer out.Close()
	if _, err := out.ReadFrom(file); err != nil {
		writeError(w, http.StatusInternalServerError, "failed to persist uploaded file")
		return
	}

	writeJSON(w, http.StatusCreated, map[string]any{
		"storagePath": filepath.ToSlash(storagePath),
	})
}

type contextKeyUserID struct{}
type contextKeyEmail struct{}

func (s *Server) withAuth(next http.HandlerFunc) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		tokenString := bearerToken(r.Header.Get("Authorization"))
		if tokenString == "" {
			writeError(w, http.StatusUnauthorized, "missing bearer token")
			return
		}
		claims := jwt.MapClaims{}
		_, err := jwt.ParseWithClaims(tokenString, claims, func(token *jwt.Token) (any, error) {
			return []byte(s.cfg.JWTSecret), nil
		})
		if err != nil {
			writeError(w, http.StatusUnauthorized, "invalid bearer token")
			return
		}

		userID, _ := claims["sub"].(string)
		email, _ := claims["email"].(string)
		if userID == "" {
			writeError(w, http.StatusUnauthorized, "invalid bearer token")
			return
		}

		ctx := context.WithValue(r.Context(), contextKeyUserID{}, userID)
		ctx = context.WithValue(ctx, contextKeyEmail{}, email)
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
		email,
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
	return normalized, nil
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
		return typed, nil
	case float32:
		return float64(typed), nil
	case int:
		return float64(typed), nil
	case int64:
		return float64(typed), nil
	case json.Number:
		return typed.Float64()
	case string:
		return strconv.ParseFloat(typed, 64)
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
		 returning row_to_json(target)`,
		spec.Name,
		strings.Join(spec.Columns, ", "),
		strings.Join(placeholders, ", "),
		strings.Join(updateClauses, ", "),
	)

	var encoded []byte
	if err := s.db.QueryRow(ctx, query, args...).Scan(&encoded); err != nil {
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
) ([]map[string]any, error) {
	query := fmt.Sprintf(
		`select coalesce(json_agg(row_to_json(records)), '[]'::json)
		   from (
		         select %s
		           from %s
		          where user_id = $1
		            and ($2::timestamptz is null or %s >= $2)
		          order by updated_at asc, id asc
		        ) as records`,
		strings.Join(spec.Columns, ", "),
		spec.Name,
		timestampColumn,
	)

	var encoded []byte
	if err := s.db.QueryRow(ctx, query, userID, since).Scan(&encoded); err != nil {
		return nil, err
	}
	return decodeJSONRows(encoded)
}

func (s *Server) softDeleteSyncRow(
	ctx context.Context,
	spec tableSpec,
	userID string,
	recordID string,
) (map[string]any, error) {
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

func (s *Server) issueToken(userID, email string) (string, error) {
	claims := jwt.MapClaims{
		"sub":   userID,
		"email": email,
		"exp":   time.Now().Add(24 * time.Hour).Unix(),
		"iat":   time.Now().Unix(),
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

func writeJSON(w http.ResponseWriter, status int, payload any) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(status)
	_ = json.NewEncoder(w).Encode(payload)
}

func writeError(w http.ResponseWriter, status int, message string) {
	writeJSON(w, status, map[string]any{"error": message})
}
