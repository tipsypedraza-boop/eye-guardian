<template>
  <Transition name="warning-fade">
    <div v-if="show" class="distance-warning" :class="warningClass">
      <!-- 模糊遮罩 -->
      <div class="blur-overlay" :style="blurStyle" />
      
      <!-- 警告内容 -->
      <div class="warning-content">
        <div class="warning-icon">{{ warningIcon }}</div>
        <h3 class="warning-title">{{ warningTitle }}</h3>
        <p class="warning-message">{{ warningMessage }}</p>
        
        <!-- 距离显示 -->
        <div class="distance-display">
          <div class="distance-bar">
            <div class="distance-fill" :style="distanceBarStyle" />
            <div class="distance-marker safe" :style="{ left: safeMarkerPos }" />
          </div>
          <div class="distance-labels">
            <span class="distance-value">当前: {{ distance }}cm</span>
            <span class="distance-safe">安全: ≥{{ safeDistance }}cm</span>
          </div>
        </div>
        
        <!-- 提示 -->
        <div class="warning-tips">
          <p class="tip-item">💡 请将身体向后移动</p>
          <p class="tip-item">💡 保持至少 {{ safeDistance }}cm 距离</p>
        </div>
        
        <!-- 关闭按钮 -->
        <button v-if="dismissible" class="dismiss-btn" @click="$emit('dismiss')">
          知道了
        </button>
      </div>
    </div>
  </Transition>
</template>

<script setup>
import { computed } from 'vue'

const props = defineProps({
  show: Boolean,
  distance: { type: Number, default: 0 },
  warningLevel: { type: Number, default: 0 },
  safeDistance: { type: Number, default: 40 },
  dismissible: { type: Boolean, default: true },
})

defineEmits(['dismiss'])

// 警告样式类
const warningClass = computed(() => {
  switch (props.warningLevel) {
    case 3: return 'level-danger'
    case 2: return 'level-warning'
    case 1: return 'level-caution'
    default: return ''
  }
})

// 警告图标
const warningIcon = computed(() => {
  switch (props.warningLevel) {
    case 3: return '🚨'
    case 2: return '⚠️'
    case 1: return '⚡'
    default: return '👁️'
  }
})

// 警告标题
const warningTitle = computed(() => {
  switch (props.warningLevel) {
    case 3: return '距离过近！'
    case 2: return '请注意距离'
    case 1: return '稍微靠近了'
    default: return '距离检测'
  }
})

// 警告消息
const warningMessage = computed(() => {
  switch (props.warningLevel) {
    case 3: return '您离屏幕太近了，长期如此会严重损害视力！'
    case 2: return '您离屏幕有点近，建议向后移动一些'
    case 1: return '距离稍微有点近，注意保持安全距离'
    default: return '保持良好的观看距离'
  }
})

// 模糊强度
const blurStyle = computed(() => {
  const intensity = Math.min(props.warningLevel * 3, 10)
  return {
    backdropFilter: `blur(${intensity}px)`,
    opacity: props.warningLevel * 0.15,
  }
})

// 距离条样式
const distanceBarStyle = computed(() => {
  const percentage = Math.min((props.distance / props.safeDistance) * 100, 100)
  let color = '#a9c2b6' // 安全色
  
  if (props.warningLevel === 3) {
    color = '#d08080' // 危险色
  } else if (props.warningLevel === 2) {
    color = '#d0b8b0' // 警告色
  } else if (props.warningLevel === 1) {
    color = '#c8b87a' // 注意色
  }
  
  return {
    width: percentage + '%',
    background: `linear-gradient(90deg, ${color} 0%, ${color}dd 100%)`,
  }
})

// 安全标记位置
const safeMarkerPos = computed(() => {
  return '100%'
})
</script>

<style scoped>
.distance-warning {
  position: fixed;
  inset: 0;
  z-index: 10000;
  display: flex;
  align-items: center;
  justify-content: center;
  pointer-events: auto;
}

.blur-overlay {
  position: absolute;
  inset: 0;
  background: rgba(0, 0, 0, 0.3);
  transition: all 0.5s ease;
}

.warning-content {
  position: relative;
  z-index: 1;
  background: rgba(255, 255, 255, 0.95);
  backdrop-filter: blur(60px) saturate(1.4);
  border-radius: 32px;
  border: 2px solid rgba(255, 255, 255, 0.6);
  box-shadow: 0 30px 80px rgba(0, 0, 0, 0.2);
  padding: 40px;
  max-width: 480px;
  text-align: center;
  animation: warning-shake 0.5s ease-in-out;
}

@keyframes warning-shake {
  0%, 100% { transform: translateX(0); }
  10%, 30%, 50%, 70%, 90% { transform: translateX(-5px); }
  20%, 40%, 60%, 80% { transform: translateX(5px); }
}

.warning-icon {
  font-size: 64px;
  margin-bottom: 16px;
  animation: icon-pulse 1.5s ease-in-out infinite;
}

@keyframes icon-pulse {
  0%, 100% { transform: scale(1); }
  50% { transform: scale(1.1); }
}

.warning-title {
  font-size: 28px;
  font-weight: 700;
  color: var(--m-text);
  margin-bottom: 12px;
  letter-spacing: -0.02em;
}

.warning-message {
  font-size: 15px;
  color: var(--m-muted);
  line-height: 1.6;
  margin-bottom: 28px;
}

/* 距离显示 */
.distance-display {
  margin-bottom: 24px;
}

.distance-bar {
  position: relative;
  height: 12px;
  background: rgba(0, 0, 0, 0.08);
  border-radius: 999px;
  overflow: visible;
  margin-bottom: 12px;
}

.distance-fill {
  height: 100%;
  border-radius: 999px;
  transition: width 0.5s var(--spring), background 0.3s ease;
  box-shadow: 0 0 12px currentColor;
}

.distance-marker {
  position: absolute;
  top: 50%;
  transform: translate(-50%, -50%);
  width: 4px;
  height: 20px;
  background: #a9c2b6;
  border-radius: 2px;
  box-shadow: 0 0 8px rgba(169, 194, 182, 0.6);
}

.distance-marker::before {
  content: '✓';
  position: absolute;
  top: -24px;
  left: 50%;
  transform: translateX(-50%);
  font-size: 12px;
  color: #a9c2b6;
}

.distance-labels {
  display: flex;
  justify-content: space-between;
  font-size: 12px;
  font-weight: 500;
}

.distance-value {
  color: var(--m-text);
  font-weight: 600;
}

.distance-safe {
  color: var(--m-muted);
}

/* 提示 */
.warning-tips {
  background: rgba(169, 194, 182, 0.08);
  border-radius: 16px;
  padding: 16px;
  margin-bottom: 24px;
}

.tip-item {
  font-size: 13px;
  color: var(--m-text);
  line-height: 1.8;
  margin: 0;
  text-align: left;
}

.tip-item + .tip-item {
  margin-top: 8px;
}

/* 关闭按钮 */
.dismiss-btn {
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

.dismiss-btn:hover {
  transform: translateY(-2px);
  box-shadow: 0 6px 24px rgba(169, 194, 182, 0.4);
}

.dismiss-btn:active {
  transform: translateY(0);
}

/* 警告级别样式 */
.level-caution .warning-content {
  border-color: rgba(200, 184, 122, 0.6);
}

.level-warning .warning-content {
  border-color: rgba(208, 184, 176, 0.6);
  animation: warning-shake 0.5s ease-in-out, warning-glow 2s ease-in-out infinite;
}

.level-danger .warning-content {
  border-color: rgba(208, 128, 128, 0.8);
  animation: warning-shake 0.5s ease-in-out, warning-glow-danger 1s ease-in-out infinite;
}

@keyframes warning-glow {
  0%, 100% { box-shadow: 0 30px 80px rgba(0, 0, 0, 0.2); }
  50% { box-shadow: 0 30px 80px rgba(208, 184, 176, 0.4); }
}

@keyframes warning-glow-danger {
  0%, 100% { box-shadow: 0 30px 80px rgba(0, 0, 0, 0.2); }
  50% { box-shadow: 0 30px 80px rgba(208, 128, 128, 0.5); }
}

/* 过渡动画 */
.warning-fade-enter-active,
.warning-fade-leave-active {
  transition: opacity 0.3s ease;
}

.warning-fade-enter-active .warning-content {
  transition: transform 0.4s var(--spring), opacity 0.3s ease;
}

.warning-fade-leave-active .warning-content {
  transition: transform 0.3s ease, opacity 0.25s ease;
}

.warning-fade-enter-from,
.warning-fade-leave-to {
  opacity: 0;
}

.warning-fade-enter-from .warning-content {
  transform: scale(0.9) translateY(20px);
  opacity: 0;
}

.warning-fade-leave-to .warning-content {
  transform: scale(0.95);
  opacity: 0;
}
</style>
