package main

import (
	"log"

	"github.com/Yi-ming-Zhao/Fittin/backend/internal/app"
)

func main() {
	server, err := app.NewServer()
	if err != nil {
		log.Fatalf("create server: %v", err)
	}
	if err := server.Run(); err != nil {
		log.Fatalf("run server: %v", err)
	}
}
