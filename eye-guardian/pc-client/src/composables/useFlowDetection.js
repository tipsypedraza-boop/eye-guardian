import { ref, computed } from 'vue'

/**
 * 心流感知系统
 * 监测键鼠 APM (Actions Per Minute)，在操作低谷时触发提醒
 */
export function useFlowDetection() {
  const keyPresses = ref([])        // 按键时间戳数组
  const mouseClicks = ref([])       // 鼠标点击时间戳数组
  const mouseMoves = ref([])        // 鼠标移动时间戳数组
  
  const isInFlow = ref(false)       // 是否处于心流状态
  const canInterrupt = ref(true)    // 是否可以打断
  
  // APM 阈值配置
  const FLOW_THRESHOLD = 60         // 高于此 APM 视为心流状态
  const LOW_ACTIVITY_THRESHOLD = 20 // 低于此 APM 视为低谷期
  const WINDOW_SIZE = 60 * 1000     // 统计窗口：1分钟
  
  // 计算当前 APM
  const currentAPM = computed(() => {
    const now = Date.now()
    const recentKeys = keyPresses.value.filter(t => now - t < WINDOW_SIZE)
    const recentClicks = mouseClicks.value.filter(t => now - t < WINDOW_SIZE)
    const recentMoves = mouseMoves.value.filter(t => now - t < WINDOW_SIZE)
    
    // 鼠标移动权重较低
    return recentKeys.length + recentClicks.length + Math.floor(recentMoves.length / 10)
  })
  
  // 更新心流状态
  const updateFlowState = () => {
    const apm = currentAPM.value
    
    if (apm >= FLOW_THRESHOLD) {
      isInFlow.value = true
      canInterrupt.value = false
    } else if (apm <= LOW_ACTIVITY_THRESHOLD) {
      isInFlow.value = false
      canInterrupt.value = true
    } else {
      // 中等活跃度，保持之前的状态
      canInterrupt.value = !isInFlow.value
    }
  }
  
  // 记录按键
  const recordKeyPress = () => {
    const now = Date.now()
    keyPresses.value.push(now)
    
    // 清理旧数据
    keyPresses.value = keyPresses.value.filter(t => now - t < WINDOW_SIZE)
    updateFlowState()
  }
  
  // 记录鼠标点击
  const recordMouseClick = () => {
    const now = Date.now()
    mouseClicks.value.push(now)
    mouseClicks.value = mouseClicks.value.filter(t => now - t < WINDOW_SIZE)
    updateFlowState()
  }
  
  // 记录鼠标移动
  const recordMouseMove = () => {
    const now = Date.now()
    // 节流：最多每秒记录10次
    if (mouseMoves.value.length === 0 || now - mouseMoves.value[mouseMoves.value.length - 1] > 100) {
      mouseMoves.value.push(now)
      mouseMoves.value = mouseMoves.value.filter(t => now - t < WINDOW_SIZE)
    }
    updateFlowState()
  }
  
  // 启动监听
  const startListening = () => {
    if (typeof window === 'undefined') return
    
    window.addEventListener('keydown', recordKeyPress)
    window.addEventListener('click', recordMouseClick)
    window.addEventListener('mousemove', recordMouseMove)
  }
  
  // 停止监听
  const stopListening = () => {
    if (typeof window === 'undefined') return
    
    window.removeEventListener('keydown', recordKeyPress)
    window.removeEventListener('click', recordMouseClick)
    window.removeEventListener('mousemove', recordMouseMove)
  }
  
  // 定期更新状态（每5秒）
  let updateInterval = null
  const startUpdateLoop = () => {
    updateInterval = setInterval(updateFlowState, 5000)
  }
  
  const stopUpdateLoop = () => {
    if (updateInterval) {
      clearInterval(updateInterval)
      updateInterval = null
    }
  }
  
  return {
    currentAPM,
    isInFlow,
    canInterrupt,
    startListening,
    stopListening,
    startUpdateLoop,
    stopUpdateLoop,
  }
}

/**
 * 沉浸模式检测
 * 检测全屏应用、会议软件等，自动降级提醒
 */
export function useImmersiveMode() {
  const isFullscreen = ref(false)
  const isInMeeting = ref(false)
  const shouldDegrade = ref(false)  // 是否应该降级提醒
  
  // 检测全屏状态
  const checkFullscreen = () => {
    if (typeof document === 'undefined') return
    
    isFullscreen.value = !!(
      document.fullscreenElement ||
      document.webkitFullscreenElement ||
      document.mozFullScreenElement ||
      document.msFullscreenElement
    )
    
    updateDegradeState()
  }
  
  // 检测会议软件（通过 Tauri 调用）
  const checkMeetingApps = async () => {
    if (typeof window.__TAURI__ === 'undefined') return
    
    try {
      // 调用 Tauri 后端检测进程
      const { invoke } = window.__TAURI__.tauri
      const runningApps = await invoke('get_running_apps')
      
      // 会议软件列表
      const meetingApps = [
        'zoom', 'teams', 'skype', 'discord', 'slack',
        'webex', 'meet', 'feishu', 'dingtalk', 'wechat'
      ]
      
      isInMeeting.value = runningApps.some(app =>
        meetingApps.some(meeting => app.toLowerCase().includes(meeting))
      )
    } catch (e) {
      console.warn('无法检测会议软件:', e)
    }
    
    updateDegradeState()
  }
  
  // 更新降级状态
  const updateDegradeState = () => {
    shouldDegrade.value = isFullscreen.value || isInMeeting.value
  }
  
  // 启动监听
  const startListening = () => {
    if (typeof document === 'undefined') return
    
    document.addEventListener('fullscreenchange', checkFullscreen)
    document.addEventListener('webkitfullscreenchange', checkFullscreen)
    document.addEventListener('mozfullscreenchange', checkFullscreen)
    document.addEventListener('msfullscreenchange', checkFullscreen)
    
    // 定期检测会议软件（每30秒）
    const meetingCheckInterval = setInterval(checkMeetingApps, 30000)
    checkMeetingApps() // 立即检测一次
    
    return () => {
      clearInterval(meetingCheckInterval)
    }
  }
  
  // 停止监听
  const stopListening = () => {
    if (typeof document === 'undefined') return
    
    document.removeEventListener('fullscreenchange', checkFullscreen)
    document.removeEventListener('webkitfullscreenchange', checkFullscreen)
    document.removeEventListener('mozfullscreenchange', checkFullscreen)
    document.removeEventListener('msfullscreenchange', checkFullscreen)
  }
  
  return {
    isFullscreen,
    isInMeeting,
    shouldDegrade,
    startListening,
    stopListening,
  }
}
