package main

import (
	"log"
	"net/http"
	"os"

	"eye-guardian/server/handlers"
	"eye-guardian/server/store"

	"github.com/gorilla/mux"
)

func getEnv(key, fallback string) string {
	if v := os.Getenv(key); v != "" {
		return v
	}
	return fallback
}

func main() {
	store.InitRedis(getEnv("REDIS_ADDR", "localhost:6379"))
	store.InitDB(getEnv("DB_DSN", "postgres://eye:eye123@localhost:5432/eye_guardian?sslmode=disable"))

	r := mux.NewRouter()

	// REST API
	r.HandleFunc("/api/state/{user_id}", handlers.GetState).Methods("GET")
	r.HandleFunc("/api/state", handlers.UpdateState).Methods("POST")

	// WebSocket
	r.HandleFunc("/ws/{user_id}", handlers.HandleWebSocket)

	log.Println("Server running on :8080")
	log.Fatal(http.ListenAndServe(":8080", r))
}
