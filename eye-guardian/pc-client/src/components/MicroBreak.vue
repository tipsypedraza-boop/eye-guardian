<template>
  <Transition name="micro-fade" appear>
    <!-- 非全屏：右下角轻量提示，不打断工作 -->
    <div class="micro-wrap">
      <div class="micro-card">
        <div class="micro-glow" />

        <div class="micro-header">
          <span class="micro-icon">👁️</span>
          <div class="micro-titles">
            <p class="micro-title">20-20-20 微休息</p>
            <p class="micro-sub">注视 6 米外的物体 20 秒</p>
          </div>
          <button class="micro-close" @click="$emit('dismiss')" aria-label="关闭">✕</button>
        </div>

        <!-- 20秒倒计时进度条 -->
        <div class="micro-progress-wrap">
          <div class="micro-progress-track">
            <div class="micro-progress-fill" :style="{ width: progressPct + '%' }" />
          </div>
          <span class="micro-countdown">{{ countdown }}s</span>
        </div>

        <!-- 呼吸引导圆 -->
        <div class="breath-circle" :class="{ exhale: breathPhase === 'exhale' }">
          <span class="breath-text">{{ breathPhase === 'inhale' ? '望远' : '放松' }}</span>
        </div>

        <button class="micro-done-btn" @click="$emit('dismiss')">完成 ✓</button>
      </div>
    </div>
  </Transition>
</template>

<script setup>
import { ref, computed, onMounted, onUnmounted } from 'vue'

defineEmits(['dismiss'])

const TOTAL = 20
const countdown  = ref(TOTAL)
const breathPhase = ref('inhale')

const progressPct = computed(() => (1 - countdown.value / TOTAL) * 100)

let countTimer, breathTimer

onMounted(() => {
  // 倒计时
  countTimer = setInterval(() => {
    if (countdown.value > 0) countdown.value--
  }, 1000)

  // 呼吸节奏：4秒一循环
  breathTimer = setInterval(() => {
    breathPhase.value = breathPhase.value === 'inhale' ? 'exhale' : 'inhale'
  }, 4000)
})

onUnmounted(() => {
  clearInterval(countTimer)
  clearInterval(breathTimer)
})
</script>

<style scoped>
/* 右下角悬浮，不遮挡主界面 */
.micro-wrap {
  position: fixed;
  bottom: 28px;
  right: 28px;
  z-index: 500;
}

.micro-card {
  position: relative;
  width: 280px;
  background: rgba(255,255,255,0.22);
  backdrop-filter: blur(40px) saturate(1.5);
  -webkit-backdrop-filter: blur(40px) saturate(1.5);
  border: 1px solid rgba(255,255,255,0.38);
  border-radius: 24px;
  padding: 18px 18px 16px;
  box-shadow: 0 12px 40px rgba(0,0,0,0.08);
  overflow: hidden;
}

.micro-glow {
  position: absolute;
  top: -40px; right: -20px;
  width: 140px; height: 140px;
  background: radial-gradient(circle, rgba(169,194,182,0.3) 0%, transparent 70%);
  pointer-events: none;
}

/* 头部 */
.micro-header {
  display: flex;
  align-items: center;
  gap: 10px;
  margin-bottom: 14px;
}

.micro-icon { font-size: 22px; flex-shrink: 0; }

.micro-titles { flex: 1; }

.micro-title {
  font-size: 13px;
  font-weight: 600;
  color: #4a5260;
  line-height: 1.3;
}

.micro-sub {
  font-size: 11px;
  color: #8a9aaa;
  margin-top: 2px;
}

.micro-close {
  background: none;
  border: none;
  font-size: 12px;
  color: #8a9aaa;
  cursor: pointer;
  padding: 4px;
  border-radius: 50%;
  width: 22px; height: 22px;
  display: flex; align-items: center; justify-content: center;
  transition: all 0.2s ease;
  flex-shrink: 0;
}
.micro-close:hover { background: rgba(0,0,0,0.06); color: #4a5260; }

/* 进度条 */
.micro-progress-wrap {
  display: flex;
  align-items: center;
  gap: 8px;
  margin-bottom: 14px;
}

.micro-progress-track {
  flex: 1;
  height: 5px;
  background: rgba(0,0,0,0.07);
  border-radius: 999px;
  overflow: hidden;
}

.micro-progress-fill {
  height: 100%;
  background: linear-gradient(90deg, #b8d4c8, #a9c2b6);
  border-radius: 999px;
  transition: width 1s linear;
  box-shadow: 0 0 6px rgba(169,194,182,0.6);
}

.micro-countdown {
  font-size: 11px;
  font-weight: 600;
  color: #6a9a8e;
  width: 24px;
  text-align: right;
  flex-shrink: 0;
}

/* 呼吸引导圆 */
.breath-circle {
  width: 64px; height: 64px;
  border-radius: 50%;
  background: radial-gradient(circle, rgba(169,194,182,0.35) 0%, rgba(169,194,182,0.1) 100%);
  border: 1.5px solid rgba(169,194,182,0.5);
  display: flex; align-items: center; justify-content: center;
  margin: 0 auto 14px;
  transition: all 4s cubic-bezier(0.4, 0, 0.2, 1);
  animation: breath-in 4s ease-in-out infinite;
}

.breath-circle.exhale {
  animation: breath-out 4s ease-in-out infinite;
}

@keyframes breath-in {
  0%   { transform: scale(0.85); opacity: 0.7; }
  100% { transform: scale(1.15); opacity: 1; }
}
@keyframes breath-out {
  0%   { transform: scale(1.15); opacity: 1; }
  100% { transform: scale(0.85); opacity: 0.7; }
}

.breath-text {
  font-size: 11px;
  font-weight: 500;
  color: #5a7a6e;
  letter-spacing: 0.04em;
}

/* 完成按钮 */
.micro-done-btn {
  width: 100%;
  padding: 9px;
  border-radius: 999px;
  border: 1px solid rgba(169,194,182,0.4);
  background: rgba(169,194,182,0.15);
  font-size: 12px;
  font-weight: 500;
  font-family: inherit;
  color: #5a7a6e;
  cursor: pointer;
  transition: all 0.25s cubic-bezier(0.34, 1.56, 0.64, 1);
}
.micro-done-btn:hover {
  background: rgba(169,194,182,0.28);
  transform: scale(1.02);
}
.micro-done-btn:active { transform: scale(0.97); }

/* 入场动画：从右下角滑入 */
.micro-fade-enter-active { transition: all 0.45s cubic-bezier(0.34, 1.56, 0.64, 1); }
.micro-fade-leave-active { transition: all 0.25s ease; }
.micro-fade-enter-from  { opacity: 0; transform: translateY(16px) scale(0.92); }
.micro-fade-leave-to    { opacity: 0; transform: translateY(8px) scale(0.96); }
</style>
