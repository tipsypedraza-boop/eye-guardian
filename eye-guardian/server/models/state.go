package models

// StatePayload 是跨端同步的核心数据结构
type StatePayload struct {
	UserID             string  `json:"user_id"`
	ClientID           string  `json:"client_id"`
	Timestamp          int64   `json:"timestamp"`
	PetLevel           int     `json:"pet_level"`
	HealthScore        float64 `json:"health_score"`
	AccumulatedFatigue int     `json:"accumulated_fatigue"`
	CurrentStatus      string  `json:"current_status"` // active | idle | screen_locked
	LastBreakDuration  int     `json:"last_break_duration"`
}
