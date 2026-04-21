package app

import (
	"errors"
	"os"
)

type Config struct {
	Addr            string
	DatabaseURL     string
	JWTSecret       string
	FileStorageRoot string
}

func LoadConfig() (Config, error) {
	cfg := Config{
		Addr:            envOrDefault("FITTIN_BACKEND_ADDR", ":8081"),
		DatabaseURL:     os.Getenv("FITTIN_DATABASE_URL"),
		JWTSecret:       os.Getenv("FITTIN_JWT_SECRET"),
		FileStorageRoot: envOrDefault("FITTIN_FILE_STORAGE_ROOT", "./var/storage"),
	}

	if cfg.DatabaseURL == "" {
		return Config{}, errors.New("FITTIN_DATABASE_URL is required")
	}
	if cfg.JWTSecret == "" {
		return Config{}, errors.New("FITTIN_JWT_SECRET is required")
	}
	return cfg, nil
}

func envOrDefault(key, fallback string) string {
	if value := os.Getenv(key); value != "" {
		return value
	}
	return fallback
}
