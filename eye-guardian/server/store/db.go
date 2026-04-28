package store

import (
	"database/sql"
	"log"

	_ "github.com/lib/pq"
)

var DB *sql.DB

func InitDB(dsn string) {
	var err error
	DB, err = sql.Open("postgres", dsn)
	if err != nil {
		log.Fatalf("Failed to connect to PostgreSQL: %v", err)
	}

	// 创建历史记录表
	_, err = DB.Exec(`
		CREATE TABLE IF NOT EXISTS health_history (
			id SERIAL PRIMARY KEY,
			user_id VARCHAR(64) NOT NULL,
			client_id VARCHAR(64),
			timestamp BIGINT NOT NULL,
			health_score FLOAT,
			accumulated_fatigue INT,
			current_status VARCHAR(32),
			created_at TIMESTAMP DEFAULT NOW()
		)
	`)
	if err != nil {
		log.Fatalf("Failed to create table: %v", err)
	}
}

func SaveHistory(userID, clientID, status string, timestamp int64, healthScore float64, fatigue int) error {
	_, err := DB.Exec(
		`INSERT INTO health_history (user_id, client_id, timestamp, health_score, accumulated_fatigue, current_status)
		 VALUES ($1, $2, $3, $4, $5, $6)`,
		userID, clientID, timestamp, healthScore, fatigue, status,
	)
	return err
}
