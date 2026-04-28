import { ref, computed, watch, onMounted, onUnmounted } from 'vue'

/**
 * 屏幕色温/亮度自适应系统
 * 根据时间自动调节，支持应用白名单
 */
export function useScreenAdjustment() {
  const enabled = ref(true)
  const colorTemp = ref(6500)       // 色温 (K)，范围 2700-6500
  const brightness = ref(100)       // 亮度 (%)，范围 20-100
  
  // 应用白名单（这些应用运行时不调节色温）
  const whitelist = ref([
    'photoshop', 'illustrator', 'premiere', 'aftereffects',
    'lightroom', 'figma', 'sketch', 'blender', 'davinci'
  ])
  
  const isWhitelistAppRunning = ref(false)
  
  // 时间段配置
  const timeConfig = {
    sunrise: { hour: 6, temp: 4500, brightness: 80 },   // 日出
    morning: { hour: 9, temp: 6500, brightness: 100 },  // 上午
    noon: { hour: 12, temp: 6500, brightness: 100 },    // 中午
    afternoon: { hour: 15, temp: 6000, brightness: 95 },// 下午
    evening: { hour: 18, temp: 4500, brightness: 85 },  // 傍晚
    night: { hour: 21, temp: 3500, brightness: 70 },    // 夜晚
    midnight: { hour: 23, temp: 2700, brightness: 50 }, // 深夜
  }
  
  // 获取当前时间段配置
  const getCurrentConfig = () => {
    const now = new Date()
    const hour = now.getHours()
    
    // 找到最接近的时间段
    const periods = Object.entries(timeConfig).sort((a, b) => b[1].hour - a[1].hour)
    
    for (const [name, config] of periods) {
      if (hour >= config.hour) {
        return config
      }
    }
    
    // 默认返回深夜配置
    return timeConfig.midnight
  }
  
  // 平滑过渡到目标值
  const smoothTransition = (current, target, duration = 30000) => {
    const steps = 60
    const stepDuration = duration / steps
    const stepSize = (target - current) / steps
    let currentStep = 0
    
    return new Promise((resolve) => {
      const interval = setInterval(() => {
        currentStep++
        current += stepSize
        
        if (currentStep >= steps) {
          clearInterval(interval)
          resolve(target)
        }
      }, stepDuration)
    })
  }
  
  // 更新色温和亮度
  const updateSettings = async () => {
    if (!enabled.value || isWhitelistAppRunning.value) {
      // 恢复默认值
      colorTemp.value = 6500
      brightness.value = 100
      return
    }
    
    const config = getCurrentConfig()
    
    // 平滑过渡（30秒）
    await Promise.all([
      smoothTransition(colorTemp.value, config.temp),
      smoothTransition(brightness.value, config.brightness),
    ])
    
    colorTemp.value = config.temp
    brightness.value = config.brightness
  }
  
  // 检测白名单应用
  const checkWhitelistApps = async () => {
    if (typeof window.__TAURI__ === 'undefined') {
      isWhitelistAppRunning.value = false
      return
    }
    
    try {
      const { invoke } = window.__TAURI__.tauri
      const runningApps = await invoke('get_running_apps')
      
      isWhitelistAppRunning.value = runningApps.some(app =>
        whitelist.value.some(whiteApp =>
          app.toLowerCase().includes(whiteApp.toLowerCase())
        )
      )
    } catch (e) {
      console.warn('无法检测应用:', e)
      isWhitelistAppRunning.value = false
    }
  }
  
  // 应用色温滤镜（通过 CSS filter）
  const applyFilter = () => {
    if (typeof document === 'undefined') return
    
    const tempRatio = (6500 - colorTemp.value) / (6500 - 2700)
    const redShift = 1 + tempRatio * 0.15
    const blueShift = 1 - tempRatio * 0.3
    
    const filter = `
      brightness(${brightness.value}%)
      sepia(${tempRatio * 0.3})
      saturate(${1 - tempRatio * 0.1})
    `
    
    // 应用到 body 或创建全屏覆盖层
    let overlay = document.getElementById('screen-adjustment-overlay')
    
    if (!overlay) {
      overlay = document.createElement('div')
      overlay.id = 'screen-adjustment-overlay'
      overlay.style.cssText = `
        position: fixed;
        inset: 0;
        pointer-events: none;
        z-index: 999999;
        transition: all 0.5s ease;
      `
      document.body.appendChild(overlay)
    }
    
    if (enabled.value && !isWhitelistAppRunning.value) {
      overlay.style.background = `rgba(255, ${Math.round(200 - tempRatio * 50)}, ${Math.round(150 - tempRatio * 100)}, ${tempRatio * 0.15})`
      overlay.style.mixBlendMode = 'multiply'
    } else {
      overlay.style.background = 'transparent'
    }
  }
  
  // 监听变化
  watch([colorTemp, brightness, enabled, isWhitelistAppRunning], applyFilter)
  
  // 定时更新（每分钟检查一次）
  let updateInterval = null
  let whitelistCheckInterval = null
  
  const startAutoAdjust = () => {
    updateSettings()
    updateInterval = setInterval(updateSettings, 60000)
    
    checkWhitelistApps()
    whitelistCheckInterval = setInterval(checkWhitelistApps, 10000)
  }
  
  const stopAutoAdjust = () => {
    if (updateInterval) {
      clearInterval(updateInterval)
      updateInterval = null
    }
    if (whitelistCheckInterval) {
      clearInterval(whitelistCheckInterval)
      whitelistCheckInterval = null
    }
    
    // 移除覆盖层
    const overlay = document.getElementById('screen-adjustment-overlay')
    if (overlay) {
      overlay.remove()
    }
  }
  
  // 手动设置
  const setColorTemp = (temp) => {
    colorTemp.value = Math.max(2700, Math.min(6500, temp))
  }
  
  const setBrightness = (value) => {
    brightness.value = Math.max(20, Math.min(100, value))
  }
  
  // 添加/移除白名单应用
  const addToWhitelist = (appName) => {
    if (!whitelist.value.includes(appName.toLowerCase())) {
      whitelist.value.push(appName.toLowerCase())
    }
  }
  
  const removeFromWhitelist = (appName) => {
    whitelist.value = whitelist.value.filter(app => app !== appName.toLowerCase())
  }
  
  return {
    enabled,
    colorTemp,
    brightness,
    whitelist,
    isWhitelistAppRunning,
    
    startAutoAdjust,
    stopAutoAdjust,
    setColorTemp,
    setBrightness,
    addToWhitelist,
    removeFromWhitelist,
    updateSettings,
  }
}
