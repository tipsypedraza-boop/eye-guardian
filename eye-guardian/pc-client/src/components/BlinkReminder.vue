<template>
  <Transition name="reminder-fade">
    <div v-if="show" class="blink-reminder" :class="severityClass">
      <!-- 水滴动画 -->
      <div class="water-drops">
        <div 
          v-for="i in dropCount" 
          :key="i" 
          class="water-drop"
          :style="getDropStyle(i)"
        >
          💧
        </div>
      </div>
      
      <!-- 提醒内容 -->
      <div class="reminder-content">
        <div class="reminder-icon">{{ reminderIcon }}</div>
        <h3 class="reminder-title">{{ reminderTitle }}</h3>
        <p class="reminder-message">{{ message }}</p>
        
        <!-- 眨眼计数器 -->
        <div class="blink-counter">
          <div class="counter-label">距离上次眨眼</div>
          <div class="counter-value">{{ timeSinceLastBlink }}秒</div>
        </div>
        
        <!-- 眨眼频率 -->
        <div class="blink-rate-display">
          <span class="rate-label">当前频率:</span>
          <span class="rate-value" :class="rateClass">{{ blinkRate }} 次/分</span>
          <span class="rate-status">{{ blinkStatus.label }}</span>
        </div>
        
        <!-- 建议 -->
        <div class="advice-box">
          <p class="advice-text">{{ advice }}</p>
        </div>
        
        <!-- 练习按钮 -->
        <button class="practice-btn" @click="startPractice">
          开始眨眼练习
        </button>
      </div>
      
      <!-- 眼睛动画 -->
      <div class="eye-animation">
        <div class="eye" :class="{ blinking: isBlinking }">
          <div class="eye-ball">
            <div class="pupil"></div>
          </div>
          <div class="eyelid top"></div>
          <div class="eyelid bottom"></div>
        </div>
      </div>
    </div>
  </Transition>
</template>

<script setup>
import { ref, computed, watch } from 'vue'

const props = defineProps({
  show: Boolean,
  timeSinceLastBlink: { type: Number, default: 0 },
  blinkRate: { type: Number, default: 0 },
  blinkStatus: { type: Object, default: () => ({ level: 'normal', label: '正常', emoji: '😊' }) },
  advice: { type: String, default: '' },
})

const emit = defineEmits(['practice', 'dismiss'])

const isBlinking = ref(false)

// 严重程度样式
const severityClass = computed(() => {
  if (props.timeSinceLastBlink >= 15) return 'severity-danger'
  if (props.timeSinceLastBlink >= 10) return 'severity-warning'
  return 'severity-normal'
})

// 提醒图标
const reminderIcon = computed(() => {
  if (props.timeSinceLastBlink >= 15) return '🚨'
  if (props.timeSinceLastBlink >= 10) return '⚠️'
  return '💧'
})

// 提醒标题
const reminderTitle = computed(() => {
  if (props.timeSinceLastBlink >= 15) return '请立即眨眼！'
  if (props.timeSinceLastBlink >= 10) return '该眨眼了'
  return '眨眼提醒'
})

// 提醒消息
const message = computed(() => {
  if (props.timeSinceLastBlink >= 15) {
    return '您已经很久没有眨眼了，眼睛可能已经很干涩。请立即眨眼数次！'
  } else if (props.timeSinceLastBlink >= 10) {
    return '长时间不眨眼会导致眼睛干涩和疲劳，请眨眨眼睛。'
  } else {
    return '保持规律的眨眼频率，预防干眼症。'
  }
})

// 水滴数量
const dropCount = computed(() => {
  if (props.timeSinceLastBlink >= 15) return 12
  if (props.timeSinceLastBlink >= 10) return 8
  return 5
})

// 频率样式
const rateClass = computed(() => {
  const level = props.blinkStatus.level
  if (level === 'danger' || level === 'low') return 'rate-low'
  if (level === 'high') return 'rate-high'
  return 'rate-normal'
})

// 水滴样式
const getDropStyle = (index) => {
  const angle = (360 / dropCount.value) * index
  const radius = 120
  const x = Math.cos((angle * Math.PI) / 180) * radius
  const y = Math.sin((angle * Math.PI) / 180) * radius
  const delay = index * 0.1
  
  return {
    left: `calc(50% + ${x}px)`,
    top: `calc(50% + ${y}px)`,
    animationDelay: `${delay}s`,
  }
}

// 开始练习
const startPractice = () => {
  emit('practice')
}

// 眨眼动画
let blinkAnimationInterval = null

watch(() => props.show, (show) => {
  if (show) {
    // 启动眨眼动画
    blinkAnimationInterval = setInterval(() => {
      isBlinking.value = true
      setTimeout(() => {
        isBlinking.value = false
      }, 200)
    }, 2000)
  } else {
    // 停止动画
    if (blinkAnimationInterval) {
      clearInterval(blinkAnimationInterval)
      blinkAnimationInterval = null
    }
  }
})
</script>

<style scoped>
.blink-reminder {
  position: fixed;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
  z-index: 9999;
  pointer-events: auto;
}

/* 水滴动画 */
.water-drops {
  position: absolute;
  inset: 0;
  pointer-events: none;
}

.water-drop {
  position: absolute;
  font-size: 24px;
  animation: drop-fall 2s ease-in infinite;
  opacity: 0;
}

@keyframes drop-fall {
  0% {
    opacity: 0;
    transform: translateY(-20px) scale(0.5);
  }
  20% {
    opacity: 1;
    transform: translateY(0) scale(1);
  }
  80% {
    opacity: 1;
    transform: translateY(100px) scale(0.8);
  }
  100% {
    opacity: 0;
    transform: translateY(150px) scale(0.3);
  }
}

/* 提醒内容 */
.reminder-content {
  position: relative;
  z-index: 1;
  background: rgba(255, 255, 255, 0.95);
  backdrop-filter: blur(60px) saturate(1.4);
  border-radius: 32px;
  border: 2px solid rgba(255, 255, 255, 0.6);
  box-shadow: 0 30px 80px rgba(0, 0, 0, 0.2);
  padding: 40px;
  max-width: 420px;
  text-align: center;
}

.reminder-icon {
  font-size: 64px;
  margin-bottom: 16px;
  animation: icon-bounce 1s ease-in-out infinite;
}

@keyframes icon-bounce {
  0%, 100% { transform: translateY(0); }
  50% { transform: translateY(-10px); }
}

.reminder-title {
  font-size: 24px;
  font-weight: 700;
  color: var(--m-text);
  margin-bottom: 12px;
}

.reminder-message {
  font-size: 14px;
  color: var(--m-muted);
  line-height: 1.6;
  margin-bottom: 24px;
}

/* 眨眼计数器 */
.blink-counter {
  background: rgba(169, 194, 182, 0.12);
  border-radius: 16px;
  padding: 16px;
  margin-bottom: 16px;
}

.counter-label {
  font-size: 12px;
  color: var(--m-muted);
  margin-bottom: 8px;
}

.counter-value {
  font-size: 32px;
  font-weight: 700;
  color: var(--m-text);
  font-variant-numeric: tabular-nums;
}

/* 眨眼频率 */
.blink-rate-display {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
  margin-bottom: 20px;
  font-size: 13px;
}

.rate-label {
  color: var(--m-muted);
}

.rate-value {
  font-weight: 700;
  font-size: 16px;
}

.rate-value.rate-normal {
  color: #a9c2b6;
}

.rate-value.rate-low {
  color: #d0b8b0;
}

.rate-value.rate-high {
  color: #c8b87a;
}

.rate-status {
  padding: 2px 8px;
  border-radius: 999px;
  background: rgba(0, 0, 0, 0.05);
  font-size: 11px;
  font-weight: 500;
}

/* 建议 */
.advice-box {
  background: rgba(169, 194, 182, 0.08);
  border-radius: 12px;
  padding: 12px;
  margin-bottom: 20px;
}

.advice-text {
  font-size: 12px;
  color: var(--m-text);
  line-height: 1.6;
  margin: 0;
}

/* 练习按钮 */
.practice-btn {
  width: 100%;
  padding: 14px;
  border-radius: 16px;
  border: none;
  background: linear-gradient(135deg, #a9c2b6 0%, #8ab0a0 100%);
  color: white;
  font-size: 15px;
  font-weight: 600;
  font-family: inherit;
  cursor: pointer;
  transition: all 0.3s var(--spring-bounce);
  box-shadow: 0 4px 16px rgba(169, 194, 182, 0.3);
}

.practice-btn:hover {
  transform: translateY(-2px);
  box-shadow: 0 6px 24px rgba(169, 194, 182, 0.4);
}

.practice-btn:active {
  transform: translateY(0);
}

/* 眼睛动画 */
.eye-animation {
  position: absolute;
  bottom: -60px;
  left: 50%;
  transform: translateX(-50%);
  pointer-events: none;
}

.eye {
  position: relative;
  width: 80px;
  height: 50px;
  background: white;
  border-radius: 50%;
  overflow: hidden;
  box-shadow: 0 4px 16px rgba(0, 0, 0, 0.1);
}

.eye-ball {
  position: absolute;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
  width: 30px;
  height: 30px;
  background: #4a5260;
  border-radius: 50%;
  transition: transform 0.3s ease;
}

.pupil {
  position: absolute;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
  width: 15px;
  height: 15px;
  background: black;
  border-radius: 50%;
}

.eyelid {
  position: absolute;
  left: 0;
  right: 0;
  height: 50%;
  background: #f5e6d3;
  transition: transform 0.2s ease;
}

.eyelid.top {
  top: 0;
  border-radius: 50% 50% 0 0;
  transform-origin: bottom;
}

.eyelid.bottom {
  bottom: 0;
  border-radius: 0 0 50% 50%;
  transform-origin: top;
}

.eye.blinking .eyelid.top {
  transform: translateY(100%);
}

.eye.blinking .eyelid.bottom {
  transform: translateY(-100%);
}

/* 严重程度样式 */
.severity-warning .reminder-content {
  border-color: rgba(208, 184, 176, 0.6);
  animation: warning-pulse 2s ease-in-out infinite;
}

.severity-danger .reminder-content {
  border-color: rgba(208, 128, 128, 0.8);
  animation: danger-shake 0.5s ease-in-out infinite;
}

@keyframes warning-pulse {
  0%, 100% { box-shadow: 0 30px 80px rgba(0, 0, 0, 0.2); }
  50% { box-shadow: 0 30px 80px rgba(208, 184, 176, 0.4); }
}

@keyframes danger-shake {
  0%, 100% { transform: translateX(0); }
  25% { transform: translateX(-5px); }
  75% { transform: translateX(5px); }
}

/* 过渡动画 */
.reminder-fade-enter-active,
.reminder-fade-leave-active {
  transition: opacity 0.3s ease, transform 0.4s var(--spring);
}

.reminder-fade-enter-from,
.reminder-fade-leave-to {
  opacity: 0;
  transform: translate(-50%, -50%) scale(0.9);
}
</style>
