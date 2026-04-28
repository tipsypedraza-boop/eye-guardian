<template>
  <Transition name="alert-fade" appear>
    <div class="overlay" :class="{ 'force-mode': isForced }">

      <!-- 强制模式：全屏变暗遮罩 -->
      <div v-if="isForced" class="force-overlay">
        <p class="force-msg">🔒 强制休息中，请离开屏幕…</p>
        <div class="force-countdown">{{ forceCountdown }}s</div>
      </div>

      <!-- 正常弹窗 -->
      <div v-else class="alert-card">
        <div class="alert-glow" />

        <div class="alert-icon">👁️</div>
        <h2 class="alert-title">该休息了</h2>
        <p class="alert-desc">
          你已连续用眼 <strong>60 分钟</strong>，请离开屏幕休息 5 分钟。
        </p>

        <!-- 推迟次数提示 -->
        <div v-if="snoozeLeft > 0" class="snooze-hint">
          还可推迟 <span class="snooze-count">{{ snoozeLeft }}</span> 次
        </div>
        <div v-else class="snooze-hint warn">推迟次数已用完，即将强制休息</div>

        <!-- 倒计时环 -->
        <div class="countdown-wrap">
          <svg class="countdown-ring" viewBox="0 0 64 64">
            <circle cx="32" cy="32" r="28" class="ring-bg" />
            <circle cx="32" cy="32" r="28" class="ring-fill" :style="ringStyle" />
          </svg>
          <span class="countdown-num">{{ countdown }}</span>
        </div>

        <div class="actions">
          <button class="btn primary" @click="startRest">开始休息</button>
          <button
            class="btn ghost"
            :disabled="snoozeLeft <= 0"
            :class="{ disabled: snoozeLeft <= 0 }"
            @click="snooze"
          >稍后提醒 ({{ snoozeLeft }})</button>
        </div>
      </div>

    </div>
  </Transition>
</template>

<script setup>
import { ref, computed, onMounted, onUnmounted } from 'vue'

const emit = defineEmits(['dismiss'])

const MAX_SNOOZE   = 2       // 最多推迟2次
const FORCE_DELAY  = 10      // 倒计时归零后N秒进入强制模式（生产用300s）
const FORCE_LOCK   = 15      // 强制模式持续秒数

const countdown    = ref(FORCE_DELAY)
const snoozeLeft   = ref(MAX_SNOOZE)
const isForced     = ref(false)
const forceCountdown = ref(FORCE_LOCK)

const circumference = 2 * Math.PI * 28

const ringStyle = computed(() => ({
  strokeDashoffset: circumference * (1 - countdown.value / FORCE_DELAY),
}))

let countTimer, forceTimer

function startCountdown() {
  clearInterval(countTimer)
  countdown.value = FORCE_DELAY
  countTimer = setInterval(() => {
    if (countdown.value > 0) {
      countdown.value--
    } else {
      // 倒计时结束：若还有推迟次数则自动推迟，否则强制
      clearInterval(countTimer)
      if (snoozeLeft.value > 0) {
        snooze()
      } else {
        enterForceMode()
      }
    }
  }, 1000)
}

function snooze() {
  if (snoozeLeft.value <= 0) return
  snoozeLeft.value--
  emit('dismiss', true)   // true = snoozed
}

function startRest() {
  clearInterval(countTimer)
  clearInterval(forceTimer)
  emit('dismiss', false)  // false = actually rested
}

function enterForceMode() {
  isForced.value = true
  forceCountdown.value = FORCE_LOCK
  forceTimer = setInterval(() => {
    if (forceCountdown.value > 0) {
      forceCountdown.value--
    } else {
      clearInterval(forceTimer)
      startRest()
    }
  }, 1000)
}

onMounted(() => startCountdown())
onUnmounted(() => {
  clearInterval(countTimer)
  clearInterval(forceTimer)
})
</script>

<style scoped>
.overlay {
  position: fixed; inset: 0;
  background: rgba(232,237,223,0.55);
  backdrop-filter: blur(16px);
  display: flex; align-items: center; justify-content: center;
  z-index: 999;
  transition: background 0.5s ease;
}

/* 强制模式：更深的遮罩 */
.overlay.force-mode {
  background: rgba(20, 24, 20, 0.88);
  backdrop-filter: blur(32px);
}

/* 强制模式全屏内容 */
.force-overlay {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 24px;
}

.force-msg {
  font-size: 18px;
  font-weight: 500;
  color: rgba(255,255,255,0.75);
  letter-spacing: 0.04em;
}

.force-countdown {
  font-size: 72px;
  font-weight: 300;
  color: rgba(169,194,182,0.9);
  letter-spacing: -0.04em;
  line-height: 1;
}

/* 正常弹窗卡片 */
.alert-card {
  position: relative;
  background: rgba(255,255,255,0.22);
  backdrop-filter: blur(60px) saturate(1.5);
  border: 1px solid rgba(255,255,255,0.38);
  border-radius: 32px;
  padding: 36px 32px 28px;
  text-align: center;
  max-width: 300px;
  width: 90%;
  box-shadow: 0 20px 60px rgba(0,0,0,0.07);
  overflow: hidden;
}

.alert-glow {
  position: absolute;
  top: -60px; left: 50%;
  transform: translateX(-50%);
  width: 200px; height: 200px;
  background: radial-gradient(circle, rgba(169,194,182,0.35) 0%, transparent 70%);
  pointer-events: none;
}

.alert-icon { font-size: 36px; margin-bottom: 10px; }

.alert-title {
  font-size: 17px;
  font-weight: 600;
  color: #4a5260;
  margin-bottom: 8px;
}

.alert-desc {
  font-size: 12px;
  line-height: 1.7;
  color: #8a9aaa;
  margin-bottom: 12px;
}
.alert-desc strong { color: #6a9a8e; font-weight: 500; }

/* 推迟提示 */
.snooze-hint {
  font-size: 11px;
  color: #8a9aaa;
  background: rgba(0,0,0,0.04);
  border-radius: 999px;
  padding: 4px 12px;
  margin-bottom: 4px;
}
.snooze-hint.warn {
  color: #b07a6a;
  background: rgba(176,122,106,0.10);
}
.snooze-count {
  font-weight: 700;
  color: #6a9a8e;
}

/* 倒计时环 */
.countdown-wrap {
  position: relative;
  width: 64px; height: 64px;
  margin: 12px auto 20px;
}

.countdown-ring { width: 64px; height: 64px; transform: rotate(-90deg); }
.ring-bg  { fill: none; stroke: rgba(0,0,0,0.06); stroke-width: 4; }
.ring-fill {
  fill: none;
  stroke: #a9c2b6;
  stroke-width: 4;
  stroke-linecap: round;
  stroke-dasharray: v-bind(circumference);
  transition: stroke-dashoffset 1s linear;
}

.countdown-num {
  position: absolute; inset: 0;
  display: flex; align-items: center; justify-content: center;
  font-size: 18px; font-weight: 600; color: #6a9a8e;
}

.actions { display: flex; gap: 8px; justify-content: center; }

.btn {
  padding: 10px 20px;
  border-radius: 999px;
  border: none;
  cursor: pointer;
  font-size: 12px;
  font-weight: 500;
  font-family: inherit;
  transition: all 0.25s cubic-bezier(0.34, 1.56, 0.64, 1);
}
.btn:hover { transform: scale(1.05); }
.btn:active { transform: scale(0.97); }

.btn.primary {
  background: linear-gradient(135deg, #b8d4c8, #a9c2b6);
  color: #2a4a3e;
}
.btn.ghost {
  background: rgba(255,255,255,0.25);
  border: 1px solid rgba(255,255,255,0.40);
  color: #8a9aaa;
}
.btn.disabled {
  opacity: 0.4;
  cursor: not-allowed;
  transform: none !important;
}

.alert-fade-enter-active { transition: all 0.4s cubic-bezier(0.34, 1.56, 0.64, 1); }
.alert-fade-leave-active { transition: all 0.25s ease; }
.alert-fade-enter-from  { opacity: 0; transform: scale(0.88); }
.alert-fade-leave-to    { opacity: 0; transform: scale(0.95); }
</style>
