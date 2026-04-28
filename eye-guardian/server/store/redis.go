package store

import (
	"context"
	"encoding/json"
	"time"

	"eye-guardian/server/models"

	"github.com/redis/go-redis/v9"
)

var rdb *redis.Client
var ctx = context.Background()

func InitRedis(addr string) {
	rdb = redis.NewClient(&redis.Options{Addr: addr})
}

func GetState(userID string) (*models.StatePayload, error) {
	val, err := rdb.Get(ctx, "state:"+userID).Result()
	if err != nil {
		return nil, err
	}
	var state models.StatePayload
	if err := json.Unmarshal([]byte(val), &state); err != nil {
		return nil, err
	}
	return &state, nil
}

func SetState(state *models.StatePayload) error {
	data, err := json.Marshal(state)
	if err != nil {
		return err
	}
	return rdb.Set(ctx, "state:"+state.UserID, data, 24*time.Hour).Err()
}
