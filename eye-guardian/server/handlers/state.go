package handlers

import (
	"encoding/json"
	"net/http"

	"eye-guardian/server/models"
	"eye-guardian/server/store"

	"github.com/gorilla/mux"
)

// GetState 获取用户最新状态 (移动端离线补偿时调用)
func GetState(w http.ResponseWriter, r *http.Request) {
	userID := mux.Vars(r)["user_id"]
	state, err := store.GetState(userID)
	if err != nil {
		http.Error(w, "state not found", http.StatusNotFound)
		return
	}
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(state)
}

// UpdateState 接收状态更新，执行 LWW 冲突解决
func UpdateState(w http.ResponseWriter, r *http.Request) {
	var incoming models.StatePayload
	if err := json.NewDecoder(r.Body).Decode(&incoming); err != nil {
		http.Error(w, "invalid payload", http.StatusBadRequest)
		return
	}

	current, err := store.GetState(incoming.UserID)
	if err != nil || incoming.Timestamp > current.Timestamp {
		// LWW: 新数据胜出，写入 Redis
		store.SetState(&incoming)
		// 持久化历史
		store.SaveHistory(incoming.UserID, incoming.ClientID, incoming.CurrentStatus,
			incoming.Timestamp, incoming.HealthScore, incoming.AccumulatedFatigue)
		// 广播给其他在线设备
		BroadcastToUser(incoming.UserID, incoming.ClientID, &incoming)
		w.WriteHeader(http.StatusOK)
	} else {
		// 旧数据，返回最新状态强制覆盖客户端
		w.Header().Set("Content-Type", "application/json")
		w.WriteHeader(http.StatusConflict)
		json.NewEncoder(w).Encode(current)
	}
}
