<template>
  <div class="particles-container">
    <Transition name="particle" v-for="particle in particles" :key="particle.id">
      <div
        v-if="particle.visible"
        class="particle"
        :style="{
          left: particle.x + 'px',
          top: particle.y + 'px',
          fontSize: particle.size + 'px',
          animationDuration: particle.duration + 's',
        }"
      >
        {{ particle.emoji }}
      </div>
    </Transition>
  </div>
</template>

<script setup>
import { ref, watch } from 'vue'

const props = defineProps({
  trigger: String, // 触发类型：'love', 'star', 'sparkle', 'sleep', 'confetti'
  x: { type: Number, default: 0 },
  y: { type: Number, default: 0 },
})

const particles = ref([])
let particleId = 0

// 粒子配置
const particleConfigs = {
  love: { emojis: ['💖', '💕', '💗', '💓'], count: 8, spread: 60 },
  star: { emojis: ['⭐', '✨', '🌟', '💫'], count: 12, spread: 80 },
  sparkle: { emojis: ['✨', '💫', '⚡'], count: 15, spread: 100 },
  sleep: { emojis: ['💤', '😴'], count: 5, spread: 40 },
  confetti: { emojis: ['🎉', '🎊', '🎈', '🎁', '🌈'], count: 20, spread: 120 },
}

const emit = (type) => {
  const config = particleConfigs[type]
  if (!config) return

  for (let i = 0; i < config.count; i++) {
    const angle = (Math.PI * 2 * i) / config.count
    const distance = Math.random() * config.spread + 20
    const emoji = config.emojis[Math.floor(Math.random() * config.emojis.length)]
    
    const particle = {
      id: particleId++,
      emoji,
      x: props.x + Math.cos(angle) * distance,
      y: props.y + Math.sin(angle) * distance,
      size: Math.random() * 10 + 12,
      duration: Math.random() * 0.5 + 0.8,
      visible: true,
    }
    
    particles.value.push(particle)
    
    // 动画结束后移除
    setTimeout(() => {
      particle.visible = false
      setTimeout(() => {
        const index = particles.value.indexOf(particle)
        if (index > -1) particles.value.splice(index, 1)
      }, 300)
    }, particle.duration * 1000)
  }
}

watch(() => props.trigger, (newVal) => {
  if (newVal) {
    emit(newVal)
  }
})

defineExpose({ emit })
</script>

<style scoped>
.particles-container {
  position: absolute;
  inset: 0;
  pointer-events: none;
  overflow: visible;
  z-index: 100;
}

.particle {
  position: absolute;
  pointer-events: none;
  animation: particle-float linear forwards;
  opacity: 1;
}

@keyframes particle-float {
  0% {
    opacity: 1;
    transform: translate(0, 0) scale(0.5) rotate(0deg);
  }
  50% {
    opacity: 1;
    transform: translate(var(--tx, 0), var(--ty, -30px)) scale(1) rotate(180deg);
  }
  100% {
    opacity: 0;
    transform: translate(calc(var(--tx, 0) * 1.5), calc(var(--ty, -30px) * 2)) scale(0.3) rotate(360deg);
  }
}

.particle-enter-active {
  transition: opacity 0.2s ease;
}

.particle-leave-active {
  transition: opacity 0.3s ease;
}

.particle-enter-from,
.particle-leave-to {
  opacity: 0;
}
</style>
