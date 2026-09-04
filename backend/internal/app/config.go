package app

import (
	"errors"
	"os"
	"strconv"
	"strings"
	"time"
)

type Config struct {
	Addr            string
	DatabaseURL     string
	JWTSecret       string
	FileStorageRoot string
	AllowedOrigins  map[string]bool
	MaxUploadBytes  int64
	RateLimitPerMin int
	AccessTokenTTL  time.Duration
	RefreshTokenTTL time.Duration

	AgentUpstreamTimeout      time.Duration
	AgentMaxRequestBytes      int64
	AgentMaxResponseBytes     int64
	AgentMaxConcurrentPerUser int
	AgentRateLimitPerMin      int
}

func LoadConfig() (Config, error) {
	cfg := Config{
		Addr:            envOrDefault("FITTIN_BACKEND_ADDR", ":8081"),
		DatabaseURL:     os.Getenv("FITTIN_DATABASE_URL"),
		JWTSecret:       os.Getenv("FITTIN_JWT_SECRET"),
		FileStorageRoot: envOrDefault("FITTIN_FILE_STORAGE_ROOT", "./var/storage"),
		AllowedOrigins:  parseOrigins(envOrDefault("FITTIN_ALLOWED_ORIGINS", "https://fittin.hammerscholar.net")),
		MaxUploadBytes:  int64(envIntOrDefault("FITTIN_MAX_UPLOAD_BYTES", 10<<20)),
		RateLimitPerMin: envIntOrDefault("FITTIN_RATE_LIMIT_PER_MINUTE", 60),
		AccessTokenTTL:  time.Duration(envIntOrDefault("FITTIN_ACCESS_TOKEN_TTL_MINUTES", 15)) * time.Minute,
		RefreshTokenTTL: time.Duration(envIntOrDefault("FITTIN_REFRESH_TOKEN_TTL_DAYS", 180)) * 24 * time.Hour,

		AgentUpstreamTimeout:      time.Duration(envIntOrDefault("FITTIN_AGENT_UPSTREAM_TIMEOUT_SECONDS", 300)) * time.Second,
		AgentMaxRequestBytes:      int64(envIntOrDefault("FITTIN_AGENT_MAX_REQUEST_BYTES", 512<<10)),
		AgentMaxResponseBytes:     int64(envIntOrDefault("FITTIN_AGENT_MAX_RESPONSE_BYTES", 8<<20)),
		AgentMaxConcurrentPerUser: envIntOrDefault("FITTIN_AGENT_MAX_CONCURRENT_PER_USER", 2),
		AgentRateLimitPerMin:      envIntOrDefault("FITTIN_AGENT_RATE_LIMIT_PER_MINUTE", 12),
	}

	if cfg.DatabaseURL == "" {
		return Config{}, errors.New("FITTIN_DATABASE_URL is required")
	}
	if cfg.JWTSecret == "" {
		return Config{}, errors.New("FITTIN_JWT_SECRET is required")
	}
	return cfg, nil
}

func parseOrigins(value string) map[string]bool {
	origins := make(map[string]bool)
	for _, origin := range strings.Split(value, ",") {
		origin = strings.TrimSpace(origin)
		if origin != "" {
			origins[origin] = true
		}
	}
	return origins
}

func envIntOrDefault(key string, fallback int) int {
	value := strings.TrimSpace(os.Getenv(key))
	if value == "" {
		return fallback
	}
	parsed, err := strconv.Atoi(value)
	if err != nil || parsed <= 0 {
		return fallback
	}
	return parsed
}

func envOrDefault(key, fallback string) string {
	if value := os.Getenv(key); value != "" {
		return value
	}
	return fallback
}
