import { ref, computed } from 'vue'

/**
 * 眨眼频率检测系统
 * 监测眨眼频率，预防干眼症
 */
export function useBlinkDetection() {
  const enabled = ref(false)
  const isDetecting = ref(false)
  const blinkCount = ref(0)
  const lastBlinkTime = ref(0)
  const blinkRate = ref(0)              // 眨眼频率（次/分钟）
  const needsBlink = ref(false)         // 是否需要眨眼提醒
  const timeSinceLastBlink = ref(0)     // 距离上次眨眼的时间（秒）
  
  // 配置
  const NORMAL_BLINK_RATE_MIN = 12      // 正常眨眼频率下限（次/分钟）
  const NORMAL_BLINK_RATE_MAX = 20      // 正常眨眼频率上限（次/分钟）
  const BLINK_WARNING_THRESHOLD = 10    // 眨眼过少警告阈值（秒）
  const BLINK_DANGER_THRESHOLD = 15     // 眨眼过少危险阈值（秒）
  const DETECTION_INTERVAL = 100        // 检测间隔（ms）
  const RATE_CALC_WINDOW = 60000        // 频率计算窗口（1分钟）
  
  // 眨眼历史记录
  const blinkHistory = ref([])
  const MAX_HISTORY = 100
  
  // 统计数据
  const stats = ref({
    totalBlinks: 0,
    sessionDuration: 0,
    averageRate: 0,
    longestInterval: 0,
    warningCount: 0,
  })
  
  // 眨眼状态
  const blinkStatus = computed(() => {
    if (timeSinceLastBlink.value >= BLINK_DANGER_THRESHOLD) {
      return { level: 'danger', label: '危险', emoji: '🚨' }
    } else if (timeSinceLastBlink.value >= BLINK_WARNING_THRESHOLD) {
      return { level: 'warning', label: '警告', emoji: '⚠️' }
    } else if (blinkRate.value < NORMAL_BLINK_RATE_MIN) {
      return { level: 'low', label: '偏低', emoji: '😐' }
    } else if (blinkRate.value > NORMAL_BLINK_RATE_MAX) {
      return { level: 'high', label: '偏高', emoji: '😅' }
    } else {
      return { level: 'normal', label: '正常', emoji: '😊' }
    }
  })
  
  // 眨眼频率评分（0-100）
  const blinkScore = computed(() => {
    const rate = blinkRate.value
    if (rate >= NORMAL_BLINK_RATE_MIN && rate <= NORMAL_BLINK_RATE_MAX) {
      return 100
    } else if (rate < NORMAL_BLINK_RATE_MIN) {
      // 眨眼过少，线性扣分
      return Math.max(0, Math.round((rate / NORMAL_BLINK_RATE_MIN) * 100))
    } else {
      // 眨眼过多，轻微扣分
      return Math.max(60, Math.round(100 - (rate - NORMAL_BLINK_RATE_MAX) * 2))
    }
  })
  
  // 眼睛纵横比（EAR - Eye Aspect Ratio）
  // 用于判断眼睛是否闭合
  let previousEAR = 0
  let eyeClosedFrames = 0
  const EAR_THRESHOLD = 0.21            // 眼睛闭合阈值
  const CONSECUTIVE_FRAMES = 2          // 连续帧数判定为眨眼
  
  // 计算眼睛纵横比
  const calculateEAR = (eyeLandmarks) => {
    if (!eyeLandmarks || eyeLandmarks.length < 6) return 0
    
    // 眼睛关键点（简化版）
    // 假设 eyeLandmarks 包含 6 个点：[左外角, 左内角, 上眼睑1, 上眼睑2, 下眼睑1, 下眼睑2]
    const [p1, p2, p3, p4, p5, p6] = eyeLandmarks
    
    // 计算垂直距离
    const vertical1 = Math.sqrt(Math.pow(p3.x - p5.x, 2) + Math.pow(p3.y - p5.y, 2))
    const vertical2 = Math.sqrt(Math.pow(p4.x - p6.x, 2) + Math.pow(p4.y - p6.y, 2))
    
    // 计算水平距离
    const horizontal = Math.sqrt(Math.pow(p1.x - p2.x, 2) + Math.pow(p1.y - p2.y, 2))
    
    // EAR = (vertical1 + vertical2) / (2 * horizontal)
    return (vertical1 + vertical2) / (2 * horizontal)
  }
  
  // 检测眨眼（简化版 - 基于像素变化）
  const detectBlinkSimple = (videoElement) => {
    if (!videoElement) return false
    
    try {
      const canvas = document.createElement('canvas')
      const ctx = canvas.getContext('2d')
      canvas.width = videoElement.videoWidth
      canvas.height = videoElement.videoHeight
      
      ctx.drawImage(videoElement, 0, 0)
      
      // 获取眼部区域（假设在画面中上部）
      const eyeRegionY = Math.floor(canvas.height * 0.3)
      const eyeRegionHeight = Math.floor(canvas.height * 0.2)
      const imageData = ctx.getImageData(0, eyeRegionY, canvas.width, eyeRegionHeight)
      
      // 计算平均亮度
      let totalBrightness = 0
      for (let i = 0; i < imageData.data.length; i += 4) {
        const r = imageData.data[i]
        const g = imageData.data[i + 1]
        const b = imageData.data[i + 2]
        totalBrightness += (r + g + b) / 3
      }
      const avgBrightness = totalBrightness / (imageData.data.length / 4)
      
      // 简化判断：亮度突然下降可能是眨眼
      const brightnessChange = Math.abs(avgBrightness - previousEAR)
      previousEAR = avgBrightness
      
      if (brightnessChange > 15) { // 阈值可调
        eyeClosedFrames++
        if (eyeClosedFrames >= CONSECUTIVE_FRAMES) {
          eyeClosedFrames = 0
          return true
        }
      } else {
        eyeClosedFrames = 0
      }
      
      return false
    } catch (error) {
      console.error('眨眼检测错误:', error)
      return false
    }
  }
  
  // 记录眨眼
  const recordBlink = () => {
    const now = Date.now()
    
    // 防抖：距离上次眨眼至少 200ms
    if (now - lastBlinkTime.value < 200) return
    
    blinkCount.value++
    stats.value.totalBlinks++
    
    // 记录间隔
    if (lastBlinkTime.value > 0) {
      const interval = (now - lastBlinkTime.value) / 1000
      if (interval > stats.value.longestInterval) {
        stats.value.longestInterval = Math.round(interval)
      }
    }
    
    lastBlinkTime.value = now
    timeSinceLastBlink.value = 0
    needsBlink.value = false
    
    // 添加到历史记录
    blinkHistory.value.push(now)
    if (blinkHistory.value.length > MAX_HISTORY) {
      blinkHistory.value.shift()
    }
    
    // 计算眨眼频率
    calculateBlinkRate()
  }
  
  // 计算眨眼频率
  const calculateBlinkRate = () => {
    const now = Date.now()
    const recentBlinks = blinkHistory.value.filter(
      time => now - time < RATE_CALC_WINDOW
    )
    
    if (recentBlinks.length > 0) {
      // 眨眼次数 / 时间窗口（分钟）
      const minutes = RATE_CALC_WINDOW / 60000
      blinkRate.value = Math.round(recentBlinks.length / minutes)
    } else {
      blinkRate.value = 0
    }
    
    // 更新平均频率
    if (stats.value.sessionDuration > 0) {
      stats.value.averageRate = Math.round(
        (stats.value.totalBlinks / stats.value.sessionDuration) * 60
      )
    }
  }
  
  // 更新距离上次眨眼的时间
  const updateTimeSinceLastBlink = () => {
    if (lastBlinkTime.value > 0) {
      timeSinceLastBlink.value = Math.round((Date.now() - lastBlinkTime.value) / 1000)
      
      // 检查是否需要提醒
      if (timeSinceLastBlink.value >= BLINK_WARNING_THRESHOLD) {
        needsBlink.value = true
        if (timeSinceLastBlink.value >= BLINK_DANGER_THRESHOLD) {
          stats.value.warningCount++
        }
      }
    }
  }
  
  // 检测循环
  let detectionInterval = null
  let statsInterval = null
  let videoElement = null
  
  const startDetection = (video) => {
    if (isDetecting.value) return
    
    videoElement = video
    isDetecting.value = true
    lastBlinkTime.value = Date.now()
    
    // 开始检测循环
    detectionInterval = setInterval(() => {
      if (!enabled.value || !videoElement) return
      
      const blinked = detectBlinkSimple(videoElement)
      if (blinked) {
        recordBlink()
      }
      
      updateTimeSinceLastBlink()
    }, DETECTION_INTERVAL)
    
    // 统计更新循环
    statsInterval = setInterval(() => {
      if (enabled.value) {
        stats.value.sessionDuration++
        calculateBlinkRate()
      }
    }, 1000)
    
    console.log('👁️ 眨眼检测已启动')
  }
  
  const stopDetection = () => {
    isDetecting.value = false
    
    if (detectionInterval) {
      clearInterval(detectionInterval)
      detectionInterval = null
    }
    
    if (statsInterval) {
      clearInterval(statsInterval)
      statsInterval = null
    }
    
    videoElement = null
    console.log('👁️ 眨眼检测已停止')
  }
  
  // 手动记录眨眼（用于测试）
  const manualBlink = () => {
    recordBlink()
  }
  
  // 重置统计
  const resetStats = () => {
    blinkCount.value = 0
    blinkHistory.value = []
    stats.value = {
      totalBlinks: 0,
      sessionDuration: 0,
      averageRate: 0,
      longestInterval: 0,
      warningCount: 0,
    }
  }
  
  // 获取眨眼建议
  const getBlinkAdvice = () => {
    const rate = blinkRate.value
    const timeSince = timeSinceLastBlink.value
    
    if (timeSince >= BLINK_DANGER_THRESHOLD) {
      return '您已经很久没有眨眼了！请立即眨眼数次，让眼睛休息。'
    } else if (timeSince >= BLINK_WARNING_THRESHOLD) {
      return '注意眨眼！长时间不眨眼会导致眼睛干涩。'
    } else if (rate < NORMAL_BLINK_RATE_MIN) {
      return '您的眨眼频率偏低，建议有意识地增加眨眼次数。'
    } else if (rate > NORMAL_BLINK_RATE_MAX) {
      return '您的眨眼频率偏高，可能是眼睛不适，建议休息。'
    } else {
      return '眨眼频率正常，继续保持！'
    }
  }
  
  return {
    // 状态
    enabled,
    isDetecting,
    blinkCount,
    blinkRate,
    needsBlink,
    timeSinceLastBlink,
    blinkStatus,
    blinkScore,
    stats,
    
    // 方法
    startDetection,
    stopDetection,
    manualBlink,
    resetStats,
    getBlinkAdvice,
    
    // 配置
    NORMAL_BLINK_RATE_MIN,
    NORMAL_BLINK_RATE_MAX,
    BLINK_WARNING_THRESHOLD,
    BLINK_DANGER_THRESHOLD,
  }
}
