package handlers

import (
	"encoding/json"
	"log"
	"net/http"
	"sync"

	"eye-guardian/server/models"

	"github.com/gorilla/mux"
	"github.com/gorilla/websocket"
)

var upgrader = websocket.Upgrader{
	CheckOrigin: func(r *http.Request) bool { return true },
}

// 在线连接池: userID -> clientID -> conn
var connPool = make(map[string]map[string]*websocket.Conn)
var poolMu sync.RWMutex

// HandleWebSocket 处理 PC 端 WebSocket 长连接
func HandleWebSocket(w http.ResponseWriter, r *http.Request) {
	userID := mux.Vars(r)["user_id"]
	clientID := r.URL.Query().Get("client_id")

	conn, err := upgrader.Upgrade(w, r, nil)
	if err != nil {
		log.Printf("WebSocket upgrade error: %v", err)
		return
	}
	defer conn.Close()

	// 注册连接
	poolMu.Lock()
	if connPool[userID] == nil {
		connPool[userID] = make(map[string]*websocket.Conn)
	}
	connPool[userID][clientID] = conn
	poolMu.Unlock()

	defer func() {
		poolMu.Lock()
		delete(connPool[userID], clientID)
		poolMu.Unlock()
	}()

	log.Printf("Client connected: user=%s client=%s", userID, clientID)

	for {
		_, msg, err := conn.ReadMessage()
		if err != nil {
			log.Printf("Client disconnected: user=%s client=%s", userID, clientID)
			break
		}

		var state models.StatePayload
		if err := json.Unmarshal(msg, &state); err != nil {
			continue
		}

		// 复用 REST 逻辑处理状态更新
		// 直接写入 Redis 并广播
		BroadcastToUser(userID, clientID, &state)
	}
}

// BroadcastToUser 将状态广播给同一用户的其他在线设备
func BroadcastToUser(userID, senderClientID string, state *models.StatePayload) {
	poolMu.RLock()
	defer poolMu.RUnlock()

	clients, ok := connPool[userID]
	if !ok {
		return
	}

	data, _ := json.Marshal(state)
	for clientID, conn := range clients {
		if clientID == senderClientID {
			continue // 不回发给发送方
		}
		if err := conn.WriteMessage(websocket.TextMessage, data); err != nil {
			log.Printf("Broadcast error to %s: %v", clientID, err)
		}
	}
}
