<template>
  <div class="status-bar">
    <!-- 健康分 -->
    <div class="metric">
      <div class="metric-header">
        <span class="label">健康分</span>
        <span class="value health-val">{{ displayHealth }}</span>
      </div>
      <div class="track">
        <div
          class="fill health-fill"
          :style="{ width: state.health_score + '%' }"
        />
        <div class="track-glow health-glow" :style="{ width: state.health_score + '%' }" />
      </div>
    </div>

    <!-- 疲劳度 -->
    <div class="metric">
      <div class="metric-header">
        <span class="label">疲劳度</span>
        <span class="value fatigue-val">{{ state.accumulated_fatigue }}<em>min</em></span>
      </div>
      <div class="track">
        <div
          class="fill fatigue-fill"
          :style="{ width: fatiguePct + '%' }"
        />
        <div class="track-glow fatigue-glow" :style="{ width: fatiguePct + '%' }" />
      </div>
    </div>

    <!-- 状态标签 -->
    <div class="status-badge" :class="state.current_status">
      <span class="dot" />
      {{ statusLabel }}
    </div>
  </div>
</template>

<script setup>
import { computed, ref, watch } from 'vue'

const props = defineProps({ state: Object })

// 数值平滑显示
const displayHealth = ref(props.state.health_score)
watch(() => props.state.health_score, (val) => {
  // 用 requestAnimationFrame 做流体数字过渡
  const start = displayHealth.value
  const end = val
  const duration = 800
  const startTime = performance.now()
  const step = (now) => {
    const t = Math.min((now - startTime) / duration, 1)
    const ease = t < 0.5 ? 2 * t * t : -1 + (4 - 2 * t) * t
    displayHealth.value = +(start + (end - start) * ease).toFixed(1)
    if (t < 1) requestAnimationFrame(step)
  }
  requestAnimationFrame(step)
})

const fatiguePct = computed(() => Math.min(props.state.accumulated_fatigue / 60 * 100, 100))

const statusLabel = computed(() => ({
  active: '活跃',
  idle: '闲置',
  screen_locked: '锁屏',
}[props.state.current_status] || '活跃'))
</script>

<style scoped>
.status-bar {
  display: flex;
  flex-direction: column;
  gap: 18px;
  width: 100%;
  max-width: 300px;
}

.metric { display: flex; flex-direction: column; gap: 8px; }

.metric-header {
  display: flex;
  justify-content: space-between;
  align-items: baseline;
}

.label {
  font-size: 11px;
  font-weight: 500;
  letter-spacing: 0.08em;
  color: var(--morandi-muted, #7a7f8e);
  text-transform: uppercase;
}

.value {
  font-size: 18px;
  font-weight: 600;
  letter-spacing: -0.02em;
}
.value em { font-size: 11px; font-style: normal; font-weight: 400; margin-left: 2px; opacity: 0.7; }

.health-val { color: #8ecfcf; }
.fatigue-val { color: #bf9b8e; }

/* 进度条轨道 */
.track {
  position: relative;
  height: 6px;
  background: rgba(255,255,255,0.07);
  border-radius: 6px;
  overflow: visible;
}

.fill {
  height: 100%;
  border-radius: 6px;
  transition: width 1s cubic-bezier(0.4, 0, 0.2, 1);
  position: relative;
  z-index: 1;
}

.health-fill {
  background: linear-gradient(90deg, #5a9fa0 0%, #8ecfcf 100%);
}

.fatigue-fill {
  background: linear-gradient(90deg, #7a5a4a 0%, #bf9b8e 100%);
}

/* 进度条发光拖尾 */
.track-glow {
  position: absolute;
  top: 50%;
  left: 0;
  height: 12px;
  transform: translateY(-50%);
  border-radius: 6px;
  filter: blur(6px);
  opacity: 0.5;
  transition: width 1s cubic-bezier(0.4, 0, 0.2, 1);
  pointer-events: none;
}

.health-glow { background: #8ecfcf; }
.fatigue-glow { background: #bf9b8e; }

/* 状态徽章 */
.status-badge {
  display: inline-flex;
  align-items: center;
  gap: 7px;
  align-self: flex-start;
  font-size: 12px;
  font-weight: 500;
  padding: 6px 14px;
  border-radius: 20px;
  background: rgba(142,207,207,0.10);
  border: 1px solid rgba(142,207,207,0.20);
  color: #8ecfcf;
  letter-spacing: 0.04em;
  transition: all 0.4s ease;
}

.status-badge.idle {
  background: rgba(191,191,142,0.10);
  border-color: rgba(191,191,142,0.20);
  color: #bfbf8e;
}

.status-badge.screen_locked {
  background: rgba(142,155,191,0.10);
  border-color: rgba(142,155,191,0.20);
  color: #8e9bbf;
}

.dot {
  width: 6px; height: 6px;
  border-radius: 50%;
  background: currentColor;
  box-shadow: 0 0 6px currentColor;
  animation: pulse-dot 2s ease-in-out infinite;
}

@keyframes pulse-dot {
  0%, 100% { opacity: 1; transform: scale(1); }
  50%       { opacity: 0.5; transform: scale(0.7); }
}
</style>
