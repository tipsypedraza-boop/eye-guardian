<template>
  <Transition name="edge-fade">
    <div v-if="visible" class="edge-light-container">
      <!-- 顶部边缘光 -->
      <div class="edge-light top" :style="lightStyle" />
      <!-- 右侧边缘光 -->
      <div class="edge-light right" :style="lightStyle" />
      <!-- 底部边缘光 -->
      <div class="edge-light bottom" :style="lightStyle" />
      <!-- 左侧边缘光 -->
      <div class="edge-light left" :style="lightStyle" />
      
      <!-- 角落提示文字（可选） -->
      <div v-if="showText" class="corner-hint">
        <span class="hint-icon">👁️</span>
        <span class="hint-text">{{ hintText }}</span>
      </div>
    </div>
  </Transition>
</template>

<script setup>
import { ref, computed, watch, onMounted, onUnmounted } from 'vue'

const props = defineProps({
  visible: Boolean,
  type: {
    type: String,
    default: 'rest',  // 'rest' | 'micro' | 'warning'
  },
  showText: {
    type: Boolean,
    default: false,
  },
})

// 根据类型设置颜色和提示文字
const config = computed(() => {
  switch (props.type) {
    case 'micro':
      return {
        color: 'rgba(169, 194, 182, 0.6)',  // 莫兰迪绿
        text: '20秒微休息',
      }
    case 'warning':
      return {
        color: 'rgba(208, 184, 176, 0.7)',  // 莫兰迪棕
        text: '该休息了',
      }
    default:
      return {
        color: 'rgba(169, 194, 182, 0.5)',
        text: '注意休息',
      }
  }
})

const hintText = computed(() => config.value.text)

// 呼吸动画样式
const breathPhase = ref(0)

const lightStyle = computed(() => ({
  boxShadow: `0 0 ${20 + breathPhase.value * 30}px ${config.value.color}`,
  background: config.value.color,
  opacity: 0.4 + breathPhase.value * 0.3,
}))

// 呼吸动画循环
let breathInterval = null

const startBreathing = () => {
  let phase = 0
  let direction = 1
  
  breathInterval = setInterval(() => {
    phase += direction * 0.05
    
    if (phase >= 1) {
      phase = 1
      direction = -1
    } else if (phase <= 0) {
      phase = 0
      direction = 1
    }
    
    breathPhase.value = phase
  }, 50)  // 20fps
}

const stopBreathing = () => {
  if (breathInterval) {
    clearInterval(breathInterval)
    breathInterval = null
  }
}

watch(() => props.visible, (visible) => {
  if (visible) {
    startBreathing()
  } else {
    stopBreathing()
  }
})

onMounted(() => {
  if (props.visible) {
    startBreathing()
  }
})

onUnmounted(() => {
  stopBreathing()
})
</script>

<style scoped>
.edge-light-container {
  position: fixed;
  inset: 0;
  pointer-events: none;
  z-index: 9999;
}

.edge-light {
  position: absolute;
  transition: box-shadow 0.3s ease, opacity 0.3s ease;
}

.edge-light.top {
  top: 0;
  left: 0;
  right: 0;
  height: 3px;
}

.edge-light.right {
  top: 0;
  right: 0;
  bottom: 0;
  width: 3px;
}

.edge-light.bottom {
  bottom: 0;
  left: 0;
  right: 0;
  height: 3px;
}

.edge-light.left {
  top: 0;
  left: 0;
  bottom: 0;
  width: 3px;
}

/* 角落提示 */
.corner-hint {
  position: absolute;
  top: 20px;
  right: 20px;
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 10px 16px;
  background: rgba(0, 0, 0, 0.75);
  backdrop-filter: blur(12px);
  border-radius: 999px;
  color: white;
  font-size: 13px;
  font-weight: 500;
  pointer-events: auto;
  cursor: pointer;
  animation: hint-pulse 2s ease-in-out infinite;
}

.hint-icon {
  font-size: 16px;
}

.hint-text {
  letter-spacing: 0.02em;
}

@keyframes hint-pulse {
  0%, 100% {
    transform: scale(1);
    opacity: 0.9;
  }
  50% {
    transform: scale(1.05);
    opacity: 1;
  }
}

/* 过渡动画 */
.edge-fade-enter-active,
.edge-fade-leave-active {
  transition: opacity 0.5s ease;
}

.edge-fade-enter-from,
.edge-fade-leave-to {
  opacity: 0;
}
</style>
