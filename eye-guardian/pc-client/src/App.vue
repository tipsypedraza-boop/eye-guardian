<template>
  <div class="app">
    <FluidBg />
    
    <!-- 全局关闭按钮 -->
    <button 
      class="app-close-btn" 
      @click="closeApp" 
      aria-label="关闭应用"
      title="关闭应用"
    >
      ×
    </button>

    <!-- 胶囊态 / 完整面板 切换容器 -->
    <div
      class="widget-wrap"
      :class="{ expanded: isExpanded }"
      @click.self="!isExpanded && (isExpanded = true)"
    >
      <!-- ── 胶囊态 ── -->
      <Transition name="capsule">
        <div v-if="!isExpanded" class="capsule" @click="isExpanded = true">
          <div 
            class="capsule-star" 
            :style="starGlowStyle"
            :class="{ 'capsule-star-wiggle': currentAction !== 'idle' }"
            @click.stop="triggerRandomAction"
          >
            {{ petEmoji }}
          </div>
          <div class="capsule-info">
            <!-- 环形进度：健康分 -->
            <svg class="ring-progress" viewBox="0 0 28 28">
              <circle cx="14" cy="14" r="11" class="ring-bg" />
              <circle cx="14" cy="14" r="11" class="ring-health"
                :style="{ strokeDashoffset: healthRingOffset }" />
            </svg>
            <span class="capsule-score">{{ state.health_score.toFixed(0) }}</span>
            <span class="capsule-dot" :class="state.current_status" />
          </div>
        </div>
      </Transition>

      <!-- ── 完整面板 ── -->
      <Transition name="panel">
        <div v-if="isExpanded" class="panel">
          <!-- 关闭按钮 -->
          <button class="close-btn" @click="isExpanded = false" aria-label="收起">
            <svg width="14" height="14" viewBox="0 0 14 14" fill="none">
              <path d="M2 2l10 10M12 2L2 12" stroke="currentColor" stroke-width="1.5" stroke-linecap="round"/>
            </svg>
          </button>

          <!-- 星星核心 -->
          <div class="star-core">
            <div class="star-halo" :style="haloStyle" />
            <div
              class="star-icon"
              :style="starGlowStyle"
              :class="{
                'star-wither': state.health_score < 30,
                'star-tired':  state.health_score < 60 && state.health_score >= 30,
                'star-reward': showReward,
                'star-action': currentAction !== 'idle',
                [`star-${currentAction}`]: currentAction !== 'idle',
              }"
              @click="triggerRandomAction"
              @mouseenter="onStarHover"
              @mouseleave="onStarLeave"
            >
              {{ petEmoji }}
              <!-- 动作气泡 -->
              <Transition name="bubble">
                <div v-if="actionBubble" class="action-bubble">{{ actionBubble }}</div>
              </Transition>
            </div>
            <div class="level-pill">Lv {{ state.pet_level }}</div>
            
            <!-- 粒子特效 -->
            <StarParticles 
              ref="particlesRef"
              :trigger="particleTrigger"
              :x="0"
              :y="0"
            />
          </div>

          <!-- 进度条区 -->
          <div class="bars">
            <div class="bar-row">
              <span class="bar-label">健康</span>
              <div class="bar-track">
                <div class="bar-fill health" :style="{ width: state.health_score + '%' }" />
              </div>
              <span class="bar-val health-val">{{ state.health_score.toFixed(0) }}</span>
            </div>
            <div class="bar-row">
              <span class="bar-label">疲劳</span>
              <div class="bar-track">
                <div class="bar-fill fatigue" :style="{ width: fatiguePct + '%' }" />
              </div>
              <span class="bar-val fatigue-val">{{ state.accumulated_fatigue }}m</span>
            </div>
          </div>

          <!-- 状态标签 -->
          <div class="status-pill" :class="state.current_status">
            <span class="status-dot" />{{ statusLabel }}
          </div>

          <!-- 控制按钮 -->
          <div class="ctrl-row">
            <button class="ctrl-pill fatigue-pill" @click="addFatigue">+ 疲劳</button>
            <button class="ctrl-pill rest-pill"    @click="rest">休息</button>
            <button class="ctrl-pill level-pill"   @click="levelUp">升级</button>
          </div>

          <!-- 音效控制 -->
          <div class="sound-toggle" @click="soundEffects.toggle()">
            <span class="sound-icon">{{ soundEffects.enabled.value ? '🔊' : '🔇' }}</span>
            <span class="sound-text">{{ soundEffects.enabled.value ? '音效开启' : '音效关闭' }}</span>
          </div>

          <!-- 免扰盾显示 -->
          <div v-if="healthScore.shields.value > 0" class="shield-display">
            <span class="shield-icon" v-for="i in healthScore.shields.value" :key="i">🛡️</span>
            <span class="shield-text">免扰盾 × {{ healthScore.shields.value }}</span>
          </div>

          <!-- 报告按钮 -->
          <button class="report-btn" @click="openReport">
            📊 查看报告
          </button>

          <!-- 摄像头设置按钮 -->
          <button class="camera-btn" @click="showCameraSettings = true">
            📷 视距检测
          </button>

          <!-- 迷你趋势 -->
          <TrendChart :history="history" class="mini-trend" />
        </div>
      </Transition>
    </div>

    <!-- 休息提醒 -->
    <BreakAlert v-if="showBreakAlert" @dismiss="dismissAlert" />

    <!-- 20-20-20 微休息 -->
    <MicroBreak v-if="showMicroBreak && !immersiveMode.shouldDegrade.value" @dismiss="dismissMicroBreak" />

    <!-- 沉浸模式边缘呼吸灯 -->
    <EdgeBreathLight 
      v-if="showMicroBreak && immersiveMode.shouldDegrade.value"
      :visible="true"
      type="micro"
      :show-text="true"
      @click="dismissMicroBreak"
    />

    <!-- 报告面板 -->
    <ReportPanel :visible="showReport" @close="showReport = false" />

    <!-- 视距预警 -->
    <DistanceWarning
      :show="faceDetection.isTooClose.value && faceDetection.enabled.value"
      :distance="faceDetection.distance.value"
      :warning-level="faceDetection.warningLevel.value"
      :safe-distance="faceDetection.SAFE_DISTANCE"
      :dismissible="false"
    />

    <!-- 摄像头设置 -->
    <CameraSettings
      :visible="showCameraSettings"
      :enabled="faceDetection.enabled.value"
      :camera-ready="faceDetection.cameraReady.value"
      :face-detected="faceDetection.faceDetected.value"
      :distance="faceDetection.distance.value"
      :safe-distance="faceDetection.SAFE_DISTANCE"
      :warning-distance="faceDetection.WARNING_DISTANCE"
      :danger-distance="faceDetection.DANGER_DISTANCE"
      :stats="faceDetection.stats.value"
      @close="showCameraSettings = false"
      @toggle="faceDetection.toggleDetection()"
      @reset-stats="faceDetection.resetStats()"
    />

    <!-- 眨眼提醒 -->
    <BlinkReminder
      :show="showBlinkReminder"
      :time-since-last-blink="blinkDetection.timeSinceLastBlink.value"
      :blink-rate="blinkDetection.blinkRate.value"
      :blink-status="blinkDetection.blinkStatus.value"
      :advice="blinkDetection.getBlinkAdvice()"
      @practice="showBlinkPractice = true; showBlinkReminder = false"
      @dismiss="showBlinkReminder = false"
    />

    <!-- 眨眼练习 -->
    <BlinkPractice
      :visible="showBlinkPractice"
      @close="showBlinkPractice = false"
      @complete="blinkDetection.resetStats()"
    />
  </div>
</template>

<script setup>
import { ref, computed, watch, onMounted, onUnmounted } from 'vue'
import FluidBg from './components/FluidBg.vue'
import TrendChart from './components/TrendChart.vue'
import BreakAlert from './components/BreakAlert.vue'
import MicroBreak from './components/MicroBreak.vue'
import ReportPanel from './components/ReportPanel.vue'
import EdgeBreathLight from './components/EdgeBreathLight.vue'
import StarParticles from './components/StarParticles.vue'
import DistanceWarning from './components/DistanceWarning.vue'
import CameraSettings from './components/CameraSettings.vue'
import BlinkReminder from './components/BlinkReminder.vue'
import BlinkPractice from './components/BlinkPractice.vue'
import { useStateSync } from './composables/useStateSync'
import { useHealthScore } from './composables/useHealthScore'
import { useFlowDetection, useImmersiveMode } from './composables/useFlowDetection'
import { useScreenAdjustment } from './composables/useScreenAdjustment'
import { useSoundEffects } from './composables/useSoundEffects'
import { useFaceDetection } from './composables/useFaceDetection'
import { useBlinkDetection } from './composables/useBlinkDetection'
import { invoke } from '@tauri-apps/api/core'

// 关闭应用
const closeApp = async () => {
  try {
    // 调用后端命令直接退出应用
    await invoke('close_app')
  } catch (error) {
    console.error('Failed to close app:', error)
    // 降级：尝试浏览器关闭
    window.close()
  }
}

const { state, connect, disconnect } = useStateSync()
const isExpanded     = ref(false)
const showBreakAlert = ref(false)
const showMicroBreak = ref(false)
const showReward     = ref(false)
const showReport     = ref(false)
const showCameraSettings = ref(false)
const showBlinkReminder = ref(false)
const showBlinkPractice = ref(false)
const history        = ref([{ health: 100, fatigue: 0 }])

// 星星动作系统
const currentAction = ref('idle')
const actionBubble = ref('')
const isHovering = ref(false)

// 动作列表
const actions = {
  idle: { duration: 0, bubble: '' },
  wave: { duration: 1500, bubble: '👋' },
  jump: { duration: 1200, bubble: '✨' },
  spin: { duration: 2000, bubble: '🌀' },
  bounce: { duration: 1500, bubble: '🎈' },
  shake: { duration: 1000, bubble: '😵' },
  dance: { duration: 2500, bubble: '💃' },
  sleep: { duration: 3000, bubble: '💤' },
  excited: { duration: 1800, bubble: '🎉' },
  think: { duration: 2000, bubble: '🤔' },
  love: { duration: 1500, bubble: '💖' },
}

// 新功能集成
const healthScore = useHealthScore()
const flowDetection = useFlowDetection()
const immersiveMode = useImmersiveMode()
const screenAdjust = useScreenAdjustment()
const soundEffects = useSoundEffects()
const faceDetection = useFaceDetection()
const blinkDetection = useBlinkDetection()

// 粒子特效
const particlesRef = ref(null)
const particleTrigger = ref('')

// 眨眼检测集成
watch(() => faceDetection.cameraReady.value, (ready) => {
  if (ready && faceDetection.enabled.value) {
    // 摄像头就绪后启动眨眼检测
    const videoElement = document.querySelector('video')
    if (videoElement) {
      blinkDetection.enabled.value = true
      blinkDetection.startDetection(videoElement)
    }
  }
})

watch(() => blinkDetection.needsBlink.value, (needs) => {
  if (needs && !showBlinkReminder.value) {
    showBlinkReminder.value = true
  }
})

// ── 20-20-20 定时器：每20分钟触发一次微休息 ──
let microTimer = null
const MICRO_INTERVAL = 20 * 60 * 1000  // 20min
// 开发调试用：const MICRO_INTERVAL = 20 * 1000

function startMicroTimer() {
  clearInterval(microTimer)
  microTimer = setInterval(() => {
    // 仅在活跃状态且无其他弹窗时触发
    // 心流感知：只在操作低谷时触发
    if (state.value.current_status === 'active' && 
        !showBreakAlert.value && 
        flowDetection.canInterrupt.value) {
      showMicroBreak.value = true
    }
  }, MICRO_INTERVAL)
}

const dismissMicroBreak = () => { 
  showMicroBreak.value = false
  healthScore.recordRest(true)
}

// ── 环形进度偏移量（胶囊态） ──
const RING_C = 2 * Math.PI * 11  // r=11
const healthRingOffset = computed(() =>
  RING_C * (1 - state.value.health_score / 100)
)

// ── 计算属性 ──
const fatiguePct = computed(() => Math.min(state.value.accumulated_fatigue / 60 * 100, 100))

const petEmoji = computed(() => {
  const s = state.value.health_score
  const action = currentAction.value
  
  // 根据动作显示不同表情
  if (action === 'love') return '😍'
  if (action === 'excited') return '🤩'
  if (action === 'sleep') return '😴'
  if (action === 'think') return '🤔'
  if (action === 'shake') return '😵'
  if (action === 'dance') return '🕺'
  
  // 根据健康分显示表情
  if (s >= 90) return '🌟'
  if (s >= 80) return '😊'
  if (s >= 60) return '🙂'
  if (s >= 40) return '😐'
  if (s >= 20) return '😴'
  return '💀'
})

const statusLabel = computed(() => ({
  active: '活跃', idle: '闲置', screen_locked: '锁屏',
}[state.value.current_status] || '活跃'))

const starGlowStyle = computed(() => {
  const a = state.value.health_score / 100
  return {
    filter: `drop-shadow(0 0 ${6 + a * 14}px rgba(169,194,182,${0.4 + a * 0.5}))`,
  }
})

const haloStyle = computed(() => ({
  opacity: 0.3 + state.value.health_score / 100 * 0.5,
}))

// ── 控制操作 ──
const addFatigue = () => {
  state.value.accumulated_fatigue = Math.min(state.value.accumulated_fatigue + 10, 60)
}

const rest = () => {
  const wasLow = state.value.health_score < 60
  state.value.accumulated_fatigue = 0
  state.value.health_score = Math.min(state.value.health_score + 15, 100)
  state.value.current_status = 'active'
  // 记录休息
  healthScore.recordRest(true)
  // 正向奖励动画
  if (wasLow) triggerReward()
  // 触发开心动作
  setTimeout(() => triggerAction('love'), 1300)
}

const levelUp = () => { 
  state.value.pet_level++
  // 升级时触发兴奋动作
  triggerAction('excited')
}

// 打开报告面板
const openReport = () => { 
  showReport.value = true
  // 打开报告时星星思考
  triggerAction('think')
}

function triggerReward() {
  showReward.value = true
  soundEffects.play('reward')
  // 触发星星粒子特效
  if (particlesRef.value) {
    particleTrigger.value = 'star'
    setTimeout(() => { particleTrigger.value = '' }, 100)
  }
  setTimeout(() => { showReward.value = false }, 1200)
}

// ── 星星动作系统 ──
const triggerAction = (actionName, withEffects = true) => {
  if (currentAction.value !== 'idle') return // 防止动作重叠
  
  const action = actions[actionName]
  if (!action) return
  
  currentAction.value = actionName
  actionBubble.value = action.bubble
  
  // 播放音效
  if (withEffects && soundEffects.enabled.value) {
    soundEffects.play(actionName)
  }
  
  // 触发粒子特效
  if (withEffects && particlesRef.value) {
    const particleType = getParticleType(actionName)
    if (particleType) {
      particleTrigger.value = particleType
      setTimeout(() => { particleTrigger.value = '' }, 100)
    }
  }
  
  setTimeout(() => {
    currentAction.value = 'idle'
    actionBubble.value = ''
  }, action.duration)
}

// 根据动作类型获取粒子特效类型
const getParticleType = (actionName) => {
  const mapping = {
    love: 'love',
    excited: 'confetti',
    jump: 'star',
    spin: 'sparkle',
    dance: 'confetti',
    sleep: 'sleep',
  }
  return mapping[actionName] || null
}

// 随机触发动作
const triggerRandomAction = () => {
  const availableActions = ['wave', 'jump', 'spin', 'bounce', 'dance', 'excited']
  const randomAction = availableActions[Math.floor(Math.random() * availableActions.length)]
  triggerAction(randomAction)
}

// 鼠标悬停
const onStarHover = () => {
  isHovering.value = true
  if (Math.random() > 0.5) {
    triggerAction('wave')
  }
}

const onStarLeave = () => {
  isHovering.value = false
}

// 根据健康状态自动触发动作
const autoTriggerAction = () => {
  if (currentAction.value !== 'idle') return
  
  const health = state.value.health_score
  const fatigue = state.value.accumulated_fatigue
  
  if (health >= 90 && fatigue < 20) {
    // 健康且精力充沛：偶尔跳跃或旋转
    if (Math.random() > 0.95) {
      const actions = ['jump', 'spin', 'dance']
      triggerAction(actions[Math.floor(Math.random() * actions.length)])
    }
  } else if (health < 30 || fatigue > 50) {
    // 疲劳状态：偶尔摇晃或睡觉
    if (Math.random() > 0.9) {
      triggerAction(Math.random() > 0.5 ? 'shake' : 'sleep')
    }
  } else if (health < 60) {
    // 一般状态：偶尔思考
    if (Math.random() > 0.93) {
      triggerAction('think')
    }
  } else {
    // 正常状态：偶尔挥手
    if (Math.random() > 0.97) {
      triggerAction('wave')
    }
  }
}

// 定时自动触发动作
let actionInterval = null
const startActionLoop = () => {
  actionInterval = setInterval(autoTriggerAction, 5000) // 每5秒检查一次
}

const stopActionLoop = () => {
  if (actionInterval) {
    clearInterval(actionInterval)
    actionInterval = null
  }
}

// 特殊时刻触发动作
const onSpecialMoment = (moment) => {
  const momentActions = {
    morning: 'wave',      // 早上打招呼
    noon: 'think',        // 中午思考
    evening: 'sleep',     // 晚上困了
    achievement: 'excited', // 达成成就
    warning: 'shake',     // 警告
  }
  
  const action = momentActions[moment]
  if (action) {
    setTimeout(() => triggerAction(action), 500)
  }
}

// 检测特殊时刻
const checkSpecialMoments = () => {
  const hour = new Date().getHours()
  
  if (hour === 9 && Math.random() > 0.5) {
    onSpecialMoment('morning')
  } else if (hour === 12 && Math.random() > 0.5) {
    onSpecialMoment('noon')
  } else if (hour >= 22 && Math.random() > 0.5) {
    onSpecialMoment('evening')
  }
}

// ── 监听 ──
watch(() => state.value.accumulated_fatigue, (v) => {
  if (v >= 60) {
    showBreakAlert.value = true
    // 疲劳时星星摇晃
    triggerAction('shake')
  }
  history.value.push({ health: state.value.health_score, fatigue: v })
  if (history.value.length > 12) history.value.shift()
})

// 监听健康分变化
watch(() => state.value.health_score, (newVal, oldVal) => {
  if (newVal > oldVal && newVal >= 80) {
    // 健康分提升到高分时跳跃
    if (Math.random() > 0.7) {
      setTimeout(() => triggerAction('jump'), 500)
    }
  } else if (newVal < oldVal && newVal < 40) {
    // 健康分下降到低分时摇晃
    if (Math.random() > 0.6) {
      setTimeout(() => triggerAction('shake'), 500)
    }
  }
})

// 监听等级变化
watch(() => state.value.pet_level, (newVal, oldVal) => {
  if (newVal > oldVal) {
    // 升级时跳舞庆祝
    setTimeout(() => triggerAction('dance'), 800)
  }
})

// 同步眨眼数据到健康评分
watch(() => blinkDetection.blinkRate.value, (rate) => {
  healthScore.updateBlinkRate(rate)
})

const dismissAlert = (snoozed) => {
  showBreakAlert.value = false
  if (!snoozed) {
    // 真正休息：给予奖励
    state.value.accumulated_fatigue = 0
    state.value.current_status = 'active'
    healthScore.recordRest(true)
    triggerReward()
  } else {
    // 推迟休息
    healthScore.recordRest(false)
  }
}

onMounted(() => {
  try { connect() } catch (e) {}
  startMicroTimer()
  startActionLoop()
  
  // 启动新功能
  flowDetection.startListening()
  flowDetection.startUpdateLoop()
  immersiveMode.startListening()
  screenAdjust.startAutoAdjust()
  
  // 每小时检查特殊时刻
  const specialMomentInterval = setInterval(checkSpecialMoments, 60 * 60 * 1000)
  checkSpecialMoments() // 立即检查一次
  
  // 清理函数
  onUnmounted(() => {
    clearInterval(specialMomentInterval)
  })
})

onUnmounted(() => {
  disconnect()
  clearInterval(microTimer)
  stopActionLoop()
  
  // 清理新功能
  flowDetection.stopListening()
  flowDetection.stopUpdateLoop()
  immersiveMode.stopListening()
  screenAdjust.stopAutoAdjust()
})
</script>

<style>
@import url('https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600&display=swap');

*, *::before, *::after { margin: 0; padding: 0; box-sizing: border-box; }

:root {
  /* 莫兰迪调色板 */
  --m-bg:      #E8EDDF;
  --m-blue:    #CFDBD5;
  --m-rose:    #F5CBBA;
  --m-green:   #A9C2B6;
  --m-fatigue: #D0B8B0;
  --m-text:    #4a5260;
  --m-muted:   #8a9aaa;
  --m-glass:   rgba(255,255,255,0.12);
  --m-border:  rgba(255,255,255,0.28);
  --spring:    cubic-bezier(0.25, 1, 0.5, 1);
  --spring-bounce: cubic-bezier(0.34, 1.56, 0.64, 1);
}

body {
  font-family: 'Inter', -apple-system, sans-serif;
  background: var(--m-bg);
  overflow: hidden;
}

.app {
  width: 100vw;
  height: 100vh;
  display: flex;
  align-items: center;
  justify-content: center;
  position: relative;
}

/* ── 外层容器：胶囊 → 面板 形变 ── */
.widget-wrap {
  position: relative;
  z-index: 10;
  /* 胶囊尺寸 */
  width: 160px;
  height: 48px;
  border-radius: 999px;
  transition:
    width  0.55s var(--spring),
    height 0.55s var(--spring),
    border-radius 0.45s var(--spring);
  will-change: width, height, border-radius;
}

.widget-wrap.expanded {
  width: 320px;
  height: auto;
  min-height: 420px;
  border-radius: 32px;
}

/* ── 液态毛玻璃基底 ── */
.widget-wrap::before {
  content: '';
  position: absolute;
  inset: 0;
  border-radius: inherit;
  background: rgba(255,255,255,0.13);
  backdrop-filter: blur(60px) saturate(1.6);
  -webkit-backdrop-filter: blur(60px) saturate(1.6);
  border: 1px solid rgba(255,255,255,0.30);
  box-shadow:
    0 20px 60px rgba(0,0,0,0.06),
    0 4px 16px rgba(0,0,0,0.04),
    0 1px 0 rgba(255,255,255,0.5) inset;
  transition: border-radius 0.45s var(--spring);
  pointer-events: none;
}

/* 全局关闭应用按钮 */
.app-close-btn {
  position: fixed;
  top: 8px;
  right: 8px;
  width: 24px;
  height: 24px;
  border: none;
  background: rgba(255, 255, 255, 0.15);
  backdrop-filter: blur(10px);
  border-radius: 50%;
  color: var(--m-text);
  font-size: 18px;
  line-height: 1;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  opacity: 0.5;
  transition: all 0.2s var(--spring-bounce);
  z-index: 9999;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
}

.app-close-btn:hover {
  opacity: 1;
  background: rgba(255, 100, 100, 0.3);
  transform: scale(1.15);
  color: #ff6b6b;
  box-shadow: 0 4px 12px rgba(255, 107, 107, 0.3);
}

/* ── 胶囊态 ── */
.capsule {
  position: absolute;
  inset: 0;
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 0 16px;
  cursor: pointer;
  user-select: none;
}

.capsule-star {
  font-size: 22px;
  transition: transform 0.3s var(--spring-bounce);
  animation: float-star 3s ease-in-out infinite;
  cursor: pointer;
}

.capsule:hover .capsule-star {
  transform: scale(1.15);
}

.capsule-star-wiggle {
  animation: capsule-wiggle 0.8s ease-in-out infinite;
}

@keyframes capsule-wiggle {
  0%, 100% { transform: rotate(0deg); }
  25% { transform: rotate(-10deg) scale(1.1); }
  50% { transform: rotate(10deg) scale(1.1); }
  75% { transform: rotate(-10deg) scale(1.1); }
}

.capsule-info {
  display: flex;
  align-items: center;
  gap: 8px;
}

.capsule-score {
  font-size: 15px;
  font-weight: 600;
  color: var(--m-text);
  letter-spacing: -0.02em;
}

.capsule-dot {
  width: 7px; height: 7px;
  border-radius: 50%;
  background: var(--m-green);
  box-shadow: 0 0 6px var(--m-green);
  animation: pulse-dot 2s ease-in-out infinite;
}
.capsule-dot.idle          { background: #c8b87a; box-shadow: 0 0 6px #c8b87a; }
.capsule-dot.screen_locked { background: var(--m-muted); box-shadow: none; }

/* 胶囊环形进度 */
.ring-progress {
  width: 28px; height: 28px;
  transform: rotate(-90deg);
  flex-shrink: 0;
}
.ring-bg {
  fill: none;
  stroke: rgba(0,0,0,0.08);
  stroke-width: 2.5;
}
.ring-health {
  fill: none;
  stroke: #a9c2b6;
  stroke-width: 2.5;
  stroke-linecap: round;
  stroke-dasharray: v-bind(RING_C);
  transition: stroke-dashoffset 1s var(--spring);
}

/* ── 完整面板 ── */
.panel {
  position: relative;
  padding: 28px 24px 24px;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 20px;
}

/* 关闭按钮 */
.close-btn {
  position: absolute;
  top: 14px; right: 14px;
  width: 28px; height: 28px;
  border-radius: 50%;
  border: none;
  background: rgba(255,255,255,0.18);
  color: var(--m-muted);
  cursor: pointer;
  display: flex; align-items: center; justify-content: center;
  transition: all 0.2s var(--spring-bounce);
}
.close-btn:hover {
  background: rgba(255,255,255,0.35);
  transform: scale(1.1) rotate(90deg);
  color: var(--m-text);
}

/* ── 星星核心 ── */
.star-core {
  position: relative;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 10px;
  margin-top: 8px;
}

.star-halo {
  position: absolute;
  width: 110px; height: 110px;
  border-radius: 50%;
  background: radial-gradient(circle, rgba(169,194,182,0.45) 0%, transparent 70%);
  top: 50%; left: 50%;
  transform: translate(-50%, -50%);
  transition: opacity 1s ease;
  pointer-events: none;
  animation: halo-breathe 4s ease-in-out infinite;
}

@keyframes halo-breathe {
  0%, 100% { transform: translate(-50%,-50%) scale(1); }
  50%       { transform: translate(-50%,-50%) scale(1.18); }
}

.star-icon {
  font-size: 58px;
  animation: float-star 4s ease-in-out infinite;
  transition: filter 1s ease;
  position: relative;
  z-index: 1;
  cursor: pointer;
  user-select: none;
}

.star-icon:hover {
  transform: scale(1.1);
}

/* 动作气泡 */
.action-bubble {
  position: absolute;
  top: -35px;
  left: 50%;
  transform: translateX(-50%);
  font-size: 24px;
  animation: bubble-float 0.6s ease-out;
  pointer-events: none;
}

@keyframes bubble-float {
  0% {
    opacity: 0;
    transform: translateX(-50%) translateY(10px) scale(0.5);
  }
  50% {
    opacity: 1;
    transform: translateX(-50%) translateY(-5px) scale(1.1);
  }
  100% {
    opacity: 1;
    transform: translateX(-50%) translateY(0) scale(1);
  }
}

.bubble-enter-active {
  animation: bubble-float 0.6s ease-out;
}

.bubble-leave-active {
  transition: opacity 0.3s ease;
}

.bubble-leave-to {
  opacity: 0;
}

/* ── 星星动作动画 ── */

/* 挥手 */
.star-icon.star-wave {
  animation: star-wave 1.5s ease-in-out !important;
}

@keyframes star-wave {
  0%, 100% { transform: rotate(0deg); }
  10%, 30%, 50%, 70%, 90% { transform: rotate(-15deg); }
  20%, 40%, 60%, 80% { transform: rotate(15deg); }
}

/* 跳跃 */
.star-icon.star-jump {
  animation: star-jump 1.2s cubic-bezier(0.34, 1.56, 0.64, 1) !important;
}

@keyframes star-jump {
  0%, 100% { transform: translateY(0); }
  30% { transform: translateY(-40px); }
  50% { transform: translateY(-50px) scale(1.1); }
  70% { transform: translateY(-30px); }
}

/* 旋转 */
.star-icon.star-spin {
  animation: star-spin 2s ease-in-out !important;
}

@keyframes star-spin {
  0% { transform: rotate(0deg) scale(1); }
  25% { transform: rotate(180deg) scale(1.15); }
  50% { transform: rotate(360deg) scale(1); }
  75% { transform: rotate(540deg) scale(1.15); }
  100% { transform: rotate(720deg) scale(1); }
}

/* 弹跳 */
.star-icon.star-bounce {
  animation: star-bounce 1.5s cubic-bezier(0.68, -0.55, 0.265, 1.55) !important;
}

@keyframes star-bounce {
  0%, 100% { transform: translateY(0) scale(1); }
  10% { transform: translateY(-20px) scale(1.1, 0.9); }
  20% { transform: translateY(0) scale(0.95, 1.05); }
  30% { transform: translateY(-30px) scale(1.05, 0.95); }
  40% { transform: translateY(0) scale(0.98, 1.02); }
  50% { transform: translateY(-15px) scale(1.02, 0.98); }
  60% { transform: translateY(0) scale(1); }
}

/* 摇晃（疲劳） */
.star-icon.star-shake {
  animation: star-shake 1s ease-in-out !important;
}

@keyframes star-shake {
  0%, 100% { transform: translateX(0) rotate(0deg); }
  10%, 30%, 50%, 70%, 90% { transform: translateX(-8px) rotate(-5deg); }
  20%, 40%, 60%, 80% { transform: translateX(8px) rotate(5deg); }
}

/* 跳舞 */
.star-icon.star-dance {
  animation: star-dance 2.5s ease-in-out !important;
}

@keyframes star-dance {
  0%, 100% { transform: rotate(0deg) translateY(0); }
  12.5% { transform: rotate(-10deg) translateY(-10px) translateX(-5px); }
  25% { transform: rotate(10deg) translateY(0) translateX(5px); }
  37.5% { transform: rotate(-10deg) translateY(-10px) translateX(-5px); }
  50% { transform: rotate(10deg) translateY(0) translateX(5px) scale(1.1); }
  62.5% { transform: rotate(-10deg) translateY(-10px) translateX(-5px); }
  75% { transform: rotate(10deg) translateY(0) translateX(5px); }
  87.5% { transform: rotate(-10deg) translateY(-10px) translateX(-5px); }
}

/* 睡觉 */
.star-icon.star-sleep {
  animation: star-sleep 3s ease-in-out !important;
}

@keyframes star-sleep {
  0%, 100% { transform: rotate(0deg) translateY(0); }
  20% { transform: rotate(-15deg) translateY(5px); }
  40%, 60%, 80% { 
    transform: rotate(-15deg) translateY(5px) scale(0.95);
    opacity: 0.7;
  }
}

/* 兴奋 */
.star-icon.star-excited {
  animation: star-excited 1.8s cubic-bezier(0.68, -0.55, 0.265, 1.55) !important;
}

@keyframes star-excited {
  0%, 100% { transform: scale(1) rotate(0deg); }
  10% { transform: scale(1.3) rotate(-10deg); }
  20% { transform: scale(0.9) rotate(10deg); }
  30% { transform: scale(1.2) rotate(-10deg); }
  40% { transform: scale(0.95) rotate(10deg); }
  50% { transform: scale(1.15) rotate(0deg); }
  60% { transform: scale(1) rotate(-5deg); }
  70% { transform: scale(1.1) rotate(5deg); }
  80% { transform: scale(1) rotate(0deg); }
}

/* 思考 */
.star-icon.star-think {
  animation: star-think 2s ease-in-out !important;
}

@keyframes star-think {
  0%, 100% { transform: rotate(0deg); }
  25% { transform: rotate(-8deg) translateY(-5px); }
  50% { transform: rotate(8deg) translateY(-5px); }
  75% { transform: rotate(-8deg) translateY(-5px); }
}

/* 爱心 */
.star-icon.star-love {
  animation: star-love 1.5s ease-in-out !important;
}

@keyframes star-love {
  0%, 100% { transform: scale(1); filter: brightness(1); }
  25% { transform: scale(1.2); filter: brightness(1.3) hue-rotate(10deg); }
  50% { transform: scale(1.1) rotate(5deg); filter: brightness(1.5) hue-rotate(20deg); }
  75% { transform: scale(1.15) rotate(-5deg); filter: brightness(1.3) hue-rotate(10deg); }
}

/* 疲劳衰退：轻微抖动+变暗 */
.star-icon.star-tired {
  animation: float-star 4s ease-in-out infinite, star-tired-shake 3s ease-in-out infinite;
  filter: saturate(0.5) brightness(0.85) !important;
}

/* 枯萎：明显抖动+灰暗+缩小 */
.star-icon.star-wither {
  animation: star-wither-anim 1.5s ease-in-out infinite;
  filter: saturate(0.2) brightness(0.7) !important;
}

/* 奖励：爆发闪光 */
.star-icon.star-reward {
  animation: star-reward-burst 0.6s var(--spring-bounce) forwards !important;
}

@keyframes float-star {
  0%, 100% { transform: translateY(0); }
  50%       { transform: translateY(-7px); }
}

@keyframes star-tired-shake {
  0%, 100% { transform: translateY(0) rotate(0deg); }
  25%       { transform: translateY(-4px) rotate(-2deg); }
  75%       { transform: translateY(-2px) rotate(2deg); }
}

@keyframes star-wither-anim {
  0%, 100% { transform: translateY(0) scale(0.88) rotate(0deg); }
  20%       { transform: translateY(2px) scale(0.85) rotate(-4deg); }
  50%       { transform: translateY(-2px) scale(0.9) rotate(3deg); }
  80%       { transform: translateY(1px) scale(0.86) rotate(-2deg); }
}

@keyframes star-reward-burst {
  0%   { transform: scale(1); filter: brightness(1); }
  30%  { transform: scale(1.4); filter: brightness(1.8) saturate(1.5); }
  60%  { transform: scale(0.95); filter: brightness(1.2); }
  100% { transform: scale(1); filter: brightness(1); }
}

.level-pill {
  background: rgba(169,194,182,0.22);
  border: 1px solid rgba(169,194,182,0.40);
  border-radius: 999px;
  padding: 4px 14px;
  font-size: 11px;
  font-weight: 600;
  color: #5a7a6e;
  letter-spacing: 0.06em;
}

/* ── 进度条 ── */
.bars {
  width: 100%;
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.bar-row {
  display: flex;
  align-items: center;
  gap: 10px;
}

.bar-label {
  font-size: 10px;
  font-weight: 500;
  letter-spacing: 0.08em;
  color: var(--m-muted);
  width: 26px;
  text-transform: uppercase;
}

.bar-track {
  flex: 1;
  height: 8px;
  background: rgba(255,255,255,0.35);
  border-radius: 999px;
  overflow: hidden;
  box-shadow: inset 0 1px 3px rgba(0,0,0,0.06);
}

.bar-fill {
  height: 100%;
  border-radius: 999px;
  transition: width 1s var(--spring);
}

.bar-fill.health {
  background: linear-gradient(90deg, #b8d4c8 0%, #a9c2b6 100%);
  box-shadow: 0 0 8px rgba(169,194,182,0.5);
}

.bar-fill.fatigue {
  background: linear-gradient(90deg, #c8b0a8 0%, #d0b8b0 100%);
  box-shadow: 0 0 8px rgba(208,184,176,0.5);
}

.bar-val {
  font-size: 11px;
  font-weight: 600;
  width: 28px;
  text-align: right;
}
.health-val { color: #6a9a8e; }
.fatigue-val { color: #9a7a72; }

/* ── 状态标签 ── */
.status-pill {
  display: inline-flex;
  align-items: center;
  gap: 6px;
  padding: 5px 14px;
  border-radius: 999px;
  font-size: 11px;
  font-weight: 500;
  letter-spacing: 0.04em;
  background: rgba(169,194,182,0.18);
  border: 1px solid rgba(169,194,182,0.35);
  color: #5a7a6e;
  transition: all 0.4s var(--spring);
}
.status-pill.idle {
  background: rgba(200,184,122,0.18);
  border-color: rgba(200,184,122,0.35);
  color: #7a6a3a;
}
.status-pill.screen_locked {
  background: rgba(138,154,170,0.15);
  border-color: rgba(138,154,170,0.30);
  color: var(--m-muted);
}

.status-dot {
  width: 6px; height: 6px;
  border-radius: 50%;
  background: currentColor;
  box-shadow: 0 0 5px currentColor;
  animation: pulse-dot 2s ease-in-out infinite;
}

@keyframes pulse-dot {
  0%, 100% { opacity: 1; transform: scale(1); }
  50%       { opacity: 0.5; transform: scale(0.65); }
}

/* ── 控制按钮 ── */
.ctrl-row {
  display: flex;
  gap: 8px;
  width: 100%;
}

.ctrl-pill {
  flex: 1;
  padding: 9px 6px;
  border-radius: 999px;
  border: 1px solid rgba(255,255,255,0.30);
  background: rgba(255,255,255,0.18);
  font-size: 11px;
  font-weight: 500;
  font-family: inherit;
  color: var(--m-text);
  cursor: pointer;
  transition: all 0.25s var(--spring-bounce);
  backdrop-filter: blur(8px);
  white-space: nowrap;
}

.ctrl-pill:hover {
  transform: translateY(-2px) scale(1.04);
  background: rgba(255,255,255,0.30);
  box-shadow: 0 6px 20px rgba(0,0,0,0.07);
}
.ctrl-pill:active {
  transform: scale(0.95);
}

.fatigue-pill:hover { border-color: rgba(208,184,176,0.6); color: #9a7a72; }
.rest-pill:hover    { border-color: rgba(169,194,182,0.6); color: #5a7a6e; }
.level-pill:hover   { border-color: rgba(200,184,122,0.6); color: #7a6a3a; }

/* ── 音效控制 ── */
.sound-toggle {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
  padding: 8px 14px;
  background: rgba(255,255,255,0.15);
  border: 1px solid rgba(255,255,255,0.25);
  border-radius: 999px;
  font-size: 11px;
  color: var(--m-text);
  cursor: pointer;
  transition: all 0.25s var(--spring-bounce);
  user-select: none;
}

.sound-toggle:hover {
  background: rgba(255,255,255,0.25);
  transform: scale(1.05);
}

.sound-toggle:active {
  transform: scale(0.95);
}

.sound-icon {
  font-size: 16px;
  transition: transform 0.3s var(--spring-bounce);
}

.sound-toggle:hover .sound-icon {
  transform: scale(1.2);
}

.sound-text {
  font-weight: 500;
  letter-spacing: 0.02em;
}

/* ── 免扰盾显示 ── */
.shield-display {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 8px 14px;
  background: rgba(169,194,182,0.12);
  border: 1px solid rgba(169,194,182,0.30);
  border-radius: 999px;
  font-size: 12px;
  color: #5a7a6e;
  font-weight: 500;
}

.shield-icon {
  font-size: 14px;
  animation: shield-float 2s ease-in-out infinite;
}

@keyframes shield-float {
  0%, 100% { transform: translateY(0); }
  50% { transform: translateY(-3px); }
}

.shield-text {
  letter-spacing: 0.02em;
}

/* ── 报告按钮 ── */
.report-btn {
  width: 100%;
  padding: 10px;
  border-radius: 12px;
  border: 1px solid rgba(255,255,255,0.30);
  background: rgba(255,255,255,0.18);
  font-size: 12px;
  font-weight: 500;
  font-family: inherit;
  color: var(--m-text);
  cursor: pointer;
  transition: all 0.25s var(--spring-bounce);
  backdrop-filter: blur(8px);
}

.report-btn:hover {
  transform: translateY(-2px);
  background: rgba(255,255,255,0.30);
  box-shadow: 0 6px 20px rgba(0,0,0,0.07);
}

.report-btn:active {
  transform: scale(0.98);
}

/* ── 摄像头按钮 ── */
.camera-btn {
  width: 100%;
  padding: 10px;
  border-radius: 12px;
  border: 1px solid rgba(255,255,255,0.30);
  background: rgba(255,255,255,0.18);
  font-size: 12px;
  font-weight: 500;
  font-family: inherit;
  color: var(--m-text);
  cursor: pointer;
  transition: all 0.25s var(--spring-bounce);
  backdrop-filter: blur(8px);
}

.camera-btn:hover {
  transform: translateY(-2px);
  background: rgba(255,255,255,0.30);
  box-shadow: 0 6px 20px rgba(0,0,0,0.07);
}

.camera-btn:active {
  transform: scale(0.98);
}

/* ── 迷你趋势 ── */
.mini-trend {
  width: 100%;
  opacity: 0.75;
}

/* ── 过渡动画 ── */
.capsule-enter-active { transition: opacity 0.2s ease 0.1s; }
.capsule-leave-active { transition: opacity 0.15s ease; }
.capsule-enter-from, .capsule-leave-to { opacity: 0; }

.panel-enter-active { transition: opacity 0.3s ease 0.2s, transform 0.4s var(--spring) 0.15s; }
.panel-leave-active { transition: opacity 0.2s ease; }
.panel-enter-from   { opacity: 0; transform: translateY(8px) scale(0.97); }
.panel-leave-to     { opacity: 0; }
</style>
