import { ref } from 'vue'
import { invoke } from '@tauri-apps/api/core'

const USER_ID = localStorage.getItem('user_id') || 'usr_default'
const CLIENT_ID = 'device_pc_' + Math.random().toString(36).slice(2, 8)
const WS_URL = `ws://localhost:8080/ws/${USER_ID}?client_id=${CLIENT_ID}`

export function useStateSync() {
  const state = ref({
    user_id: USER_ID,
    client_id: CLIENT_ID,
    timestamp: Date.now(),
    pet_level: 1,
    health_score: 100,
    accumulated_fatigue: 0,
    current_status: 'active',
    last_break_duration: 0,
  })

  let ws = null
  let syncInterval = null

  function connect() {
    try {
      ws = new WebSocket(WS_URL)

      ws.onmessage = (event) => {
        const incoming = JSON.parse(event.data)
        if (incoming.timestamp > state.value.timestamp) {
          state.value = incoming
        }
      }

      ws.onclose = () => {
        setTimeout(connect, 5000)
      }

      syncInterval = setInterval(pushState, 60_000)

      try { invoke('start_idle_watcher') } catch (e) { /* 非 Tauri 环境忽略 */ }
    } catch (e) {
      // 无后端时静默失败
    }
  }

  function disconnect() {
    ws?.close()
    clearInterval(syncInterval)
  }

  function pushState(status = null) {
    if (status) state.value.current_status = status
    state.value.timestamp = Date.now()
    if (ws?.readyState === WebSocket.OPEN) {
      ws.send(JSON.stringify(state.value))
    }
  }

  // 暴露给 Tauri 后端调用：系统进入空闲/锁屏时触发
  window.__pushIdleState = () => pushState('idle')
  window.__pushLockedState = () => pushState('screen_locked')

  return { state, connect, disconnect, pushState }
}
