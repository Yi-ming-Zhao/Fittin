package app

import (
	"errors"
	"os"
	"strconv"
	"strings"
)

type Config struct {
	Addr            string
	DatabaseURL     string
	JWTSecret       string
	FileStorageRoot string
	AllowedOrigins  map[string]bool
	MaxUploadBytes  int64
	RateLimitPerMin int
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
