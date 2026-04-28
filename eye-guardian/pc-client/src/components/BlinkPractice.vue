<template>
  <Transition name="practice-fade">
    <div v-if="visible" class="practice-overlay" @click.self="$emit('close')">
      <div class="practice-panel">
        <!-- 头部 -->
        <div class="practice-header">
          <h2 class="practice-title">👁️ 眨眼练习</h2>
          <button class="practice-close" @click="$emit('close')" aria-label="关闭">
            <svg width="16" height="16" viewBox="0 0 16 16" fill="none">
              <path d="M3 3l10 10M13 3L3 13" stroke="currentColor" stroke-width="2" stroke-linecap="round"/>
            </svg>
          </button>
        </div>

        <!-- 练习状态 -->
        <div v-if="!isActive" class="practice-intro">
          <div class="intro-icon">💧</div>
          <h3 class="intro-title">眨眼练习指南</h3>
          <p class="intro-desc">
            跟随提示进行眨眼练习，帮助缓解眼睛干涩，预防干眼症。
          </p>
          
          <div class="practice-steps">
            <div class="step-item">
              <span class="step-number">1</span>
              <span class="step-text">轻轻闭上眼睛</span>
            </div>
            <div class="step-item">
              <span class="step-number">2</span>
              <span class="step-text">保持 2-3 秒</span>
            </div>
            <div class="step-item">
              <span class="step-number">3</span>
              <span class="step-text">慢慢睁开眼睛</span>
            </div>
            <div class="step-item">
              <span class="step-number">4</span>
              <span class="step-text">重复 10 次</span>
            </div>
          </div>
          
          <button class="start-btn" @click="startPractice">
            开始练习
          </button>
        </div>

        <!-- 练习进行中 -->
        <div v-else class="practice-active">
          <!-- 进度 -->
          <div class="practice-progress">
            <div class="progress-text">{{ currentRound }} / {{ totalRounds }}</div>
            <div class="progress-bar">
              <div class="progress-fill" :style="{ width: progressPercent + '%' }" />
            </div>
          </div>

          <!-- 眼睛动画 -->
          <div class="big-eye" :class="{ closed: eyeClosed }">
            <div class="eye-outer">
              <div class="eye-inner">
                <div class="iris">
                  <div class="pupil"></div>
                  <div class="reflection"></div>
                </div>
              </div>
              <div class="upper-lid"></div>
              <div class="lower-lid"></div>
            </div>
          </div>

          <!-- 指令 -->
          <div class="instruction" :class="instructionClass">
            {{ instruction }}
          </div>

          <!-- 倒计时 -->
          <div v-if="countdown > 0" class="countdown">
            {{ countdown }}
          </div>

          <!-- 停止按钮 -->
          <button class="stop-btn" @click="stopPractice">
            停止练习
          </button>
        </div>

        <!-- 完成 -->
        <div v-if="completed" class="practice-complete">
          <div class="complete-icon">🎉</div>
          <h3 class="complete-title">练习完成！</h3>
          <p class="complete-message">
            您已完成 {{ totalRounds }} 次眨眼练习，眼睛应该感觉舒服多了。
          </p>
          
          <div class="complete-stats">
            <div class="stat-item">
              <div class="stat-value">{{ totalRounds }}</div>
              <div class="stat-label">完成次数</div>
            </div>
            <div class="stat-item">
              <div class="stat-value">{{ practiceTime }}s</div>
              <div class="stat-label">练习时长</div>
            </div>
          </div>
          
          <button class="done-btn" @click="$emit('close')">
            完成
          </button>
        </div>
      </div>
    </div>
  </Transition>
</template>

<script setup>
import { ref, computed, watch } from 'vue'

const props = defineProps({
  visible: Boolean,
})

const emit = defineEmits(['close', 'complete'])

const isActive = ref(false)
const completed = ref(false)
const currentRound = ref(0)
const totalRounds = ref(10)
const eyeClosed = ref(false)
const instruction = ref('')
const instructionClass = ref('')
const countdown = ref(0)
const practiceTime = ref(0)

let practiceInterval = null
let startTime = 0

const progressPercent = computed(() => {
  return (currentRound.value / totalRounds.value) * 100
})

// 开始练习
const startPractice = () => {
  isActive.value = true
  completed.value = false
  currentRound.value = 0
  practiceTime.value = 0
  startTime = Date.now()
  
  nextRound()
}

// 下一轮
const nextRound = () => {
  if (currentRound.value >= totalRounds.value) {
    completePractice()
    return
  }
  
  currentRound.value++
  
  // 阶段 1：准备
  instruction.value = '准备...'
  instructionClass.value = 'prepare'
  eyeClosed.value = false
  countdown.value = 3
  
  const countdownInterval = setInterval(() => {
    countdown.value--
    if (countdown.value <= 0) {
      clearInterval(countdownInterval)
      closeEyes()
    }
  }, 1000)
}

// 闭眼
const closeEyes = () => {
  instruction.value = '闭上眼睛'
  instructionClass.value = 'close'
  eyeClosed.value = true
  countdown.value = 0
  
  setTimeout(() => {
    holdClosed()
  }, 500)
}

// 保持闭眼
const holdClosed = () => {
  instruction.value = '保持...'
  instructionClass.value = 'hold'
  countdown.value = 3
  
  const holdInterval = setInterval(() => {
    countdown.value--
    if (countdown.value <= 0) {
      clearInterval(holdInterval)
      openEyes()
    }
  }, 1000)
}

// 睁眼
const openEyes = () => {
  instruction.value = '睁开眼睛'
  instructionClass.value = 'open'
  eyeClosed.value = false
  countdown.value = 0
  
  setTimeout(() => {
    rest()
  }, 500)
}

// 休息
const rest = () => {
  instruction.value = '休息一下'
  instructionClass.value = 'rest'
  countdown.value = 2
  
  const restInterval = setInterval(() => {
    countdown.value--
    if (countdown.value <= 0) {
      clearInterval(restInterval)
      nextRound()
    }
  }, 1000)
}

// 停止练习
const stopPractice = () => {
  isActive.value = false
  if (practiceInterval) {
    clearInterval(practiceInterval)
    practiceInterval = null
  }
}

// 完成练习
const completePractice = () => {
  isActive.value = false
  completed.value = true
  practiceTime.value = Math.round((Date.now() - startTime) / 1000)
  emit('complete')
}

// 重置
watch(() => props.visible, (visible) => {
  if (!visible) {
    isActive.value = false
    completed.value = false
    currentRound.value = 0
    stopPractice()
  }
})
</script>

<style scoped>
.practice-overlay {
  position: fixed;
  inset: 0;
  background: rgba(0, 0, 0, 0.5);
  backdrop-filter: blur(8px);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 10000;
  padding: 20px;
}

.practice-panel {
  background: rgba(255, 255, 255, 0.95);
  backdrop-filter: blur(60px) saturate(1.4);
  border-radius: 24px;
  border: 1px solid rgba(255, 255, 255, 0.6);
  box-shadow: 0 30px 80px rgba(0, 0, 0, 0.15);
  width: 100%;
  max-width: 480px;
  padding: 32px;
}

/* 头部 */
.practice-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 28px;
}

.practice-title {
  font-size: 22px;
  font-weight: 600;
  color: var(--m-text);
}

.practice-close {
  width: 32px;
  height: 32px;
  border-radius: 50%;
  border: none;
  background: rgba(0, 0, 0, 0.05);
  color: var(--m-muted);
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: all 0.2s var(--spring);
}

.practice-close:hover {
  background: rgba(0, 0, 0, 0.1);
  transform: scale(1.1);
}

/* 介绍 */
.practice-intro {
  text-align: center;
}

.intro-icon {
  font-size: 64px;
  margin-bottom: 16px;
}

.intro-title {
  font-size: 20px;
  font-weight: 600;
  color: var(--m-text);
  margin-bottom: 12px;
}

.intro-desc {
  font-size: 14px;
  color: var(--m-muted);
  line-height: 1.6;
  margin-bottom: 28px;
}

.practice-steps {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 12px;
  margin-bottom: 28px;
}

.step-item {
  display: flex;
  align-items: center;
  gap: 10px;
  padding: 12px;
  background: rgba(169, 194, 182, 0.08);
  border-radius: 12px;
}

.step-number {
  width: 28px;
  height: 28px;
  border-radius: 50%;
  background: linear-gradient(135deg, #a9c2b6 0%, #8ab0a0 100%);
  color: white;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 14px;
  font-weight: 700;
  flex-shrink: 0;
}

.step-text {
  font-size: 13px;
  color: var(--m-text);
  font-weight: 500;
}

.start-btn {
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

.start-btn:hover {
  transform: translateY(-2px);
  box-shadow: 0 6px 24px rgba(169, 194, 182, 0.4);
}

/* 练习中 */
.practice-active {
  text-align: center;
}

.practice-progress {
  margin-bottom: 32px;
}

.progress-text {
  font-size: 18px;
  font-weight: 700;
  color: var(--m-text);
  margin-bottom: 12px;
}

.progress-bar {
  height: 8px;
  background: rgba(0, 0, 0, 0.08);
  border-radius: 999px;
  overflow: hidden;
}

.progress-fill {
  height: 100%;
  background: linear-gradient(90deg, #a9c2b6 0%, #8ab0a0 100%);
  border-radius: 999px;
  transition: width 0.5s var(--spring);
  box-shadow: 0 0 12px rgba(169, 194, 182, 0.5);
}

/* 大眼睛 */
.big-eye {
  margin: 40px auto;
  width: 200px;
  height: 120px;
  position: relative;
}

.eye-outer {
  position: relative;
  width: 100%;
  height: 100%;
  background: white;
  border-radius: 50%;
  box-shadow: 0 8px 32px rgba(0, 0, 0, 0.15);
  overflow: hidden;
}

.eye-inner {
  position: absolute;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
  width: 80%;
  height: 80%;
}

.iris {
  position: absolute;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
  width: 60px;
  height: 60px;
  background: radial-gradient(circle, #6a9a8e 0%, #4a7a6e 100%);
  border-radius: 50%;
}

.pupil {
  position: absolute;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
  width: 30px;
  height: 30px;
  background: black;
  border-radius: 50%;
}

.reflection {
  position: absolute;
  top: 20%;
  left: 30%;
  width: 15px;
  height: 15px;
  background: rgba(255, 255, 255, 0.8);
  border-radius: 50%;
}

.upper-lid,
.lower-lid {
  position: absolute;
  left: 0;
  right: 0;
  height: 50%;
  background: #f5e6d3;
  transition: transform 0.3s ease;
}

.upper-lid {
  top: 0;
  border-radius: 50% 50% 0 0;
  transform-origin: bottom;
}

.lower-lid {
  bottom: 0;
  border-radius: 0 0 50% 50%;
  transform-origin: top;
}

.big-eye.closed .upper-lid {
  transform: translateY(100%);
}

.big-eye.closed .lower-lid {
  transform: translateY(-100%);
}

/* 指令 */
.instruction {
  font-size: 24px;
  font-weight: 700;
  color: var(--m-text);
  margin-bottom: 20px;
  min-height: 32px;
  transition: all 0.3s ease;
}

.instruction.close {
  color: #a9c2b6;
}

.instruction.hold {
  color: #8ab0a0;
}

.instruction.open {
  color: #6a9a8e;
}

.instruction.rest {
  color: var(--m-muted);
}

/* 倒计时 */
.countdown {
  font-size: 48px;
  font-weight: 700;
  color: var(--m-green);
  margin-bottom: 20px;
  animation: countdown-pulse 1s ease-in-out infinite;
}

@keyframes countdown-pulse {
  0%, 100% { transform: scale(1); opacity: 1; }
  50% { transform: scale(1.2); opacity: 0.8; }
}

.stop-btn {
  padding: 10px 24px;
  border-radius: 12px;
  border: 1px solid rgba(0, 0, 0, 0.1);
  background: rgba(255, 255, 255, 0.6);
  font-size: 13px;
  font-weight: 500;
  font-family: inherit;
  color: var(--m-text);
  cursor: pointer;
  transition: all 0.2s var(--spring);
}

.stop-btn:hover {
  background: rgba(255, 255, 255, 0.8);
}

/* 完成 */
.practice-complete {
  text-align: center;
}

.complete-icon {
  font-size: 64px;
  margin-bottom: 16px;
  animation: complete-bounce 0.6s var(--spring-bounce);
}

@keyframes complete-bounce {
  0% { transform: scale(0); }
  50% { transform: scale(1.2); }
  100% { transform: scale(1); }
}

.complete-title {
  font-size: 24px;
  font-weight: 700;
  color: var(--m-text);
  margin-bottom: 12px;
}

.complete-message {
  font-size: 14px;
  color: var(--m-muted);
  line-height: 1.6;
  margin-bottom: 28px;
}

.complete-stats {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 12px;
  margin-bottom: 28px;
}

.stat-item {
  background: rgba(169, 194, 182, 0.08);
  border-radius: 12px;
  padding: 16px;
}

.stat-value {
  font-size: 28px;
  font-weight: 700;
  color: var(--m-text);
  margin-bottom: 4px;
}

.stat-label {
  font-size: 12px;
  color: var(--m-muted);
}

.done-btn {
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

.done-btn:hover {
  transform: translateY(-2px);
  box-shadow: 0 6px 24px rgba(169, 194, 182, 0.4);
}

/* 过渡动画 */
.practice-fade-enter-active,
.practice-fade-leave-active {
  transition: opacity 0.3s ease;
}

.practice-fade-enter-active .practice-panel {
  transition: transform 0.4s var(--spring), opacity 0.3s ease;
}

.practice-fade-leave-active .practice-panel {
  transition: transform 0.3s ease, opacity 0.25s ease;
}

.practice-fade-enter-from,
.practice-fade-leave-to {
  opacity: 0;
}

.practice-fade-enter-from .practice-panel {
  transform: scale(0.92) translateY(20px);
  opacity: 0;
}

.practice-fade-leave-to .practice-panel {
  transform: scale(0.96);
  opacity: 0;
}
</style>
