<template>
  <div class="pet-container">
    <!-- 外层光晕 -->
    <div class="halo" :style="haloStyle" />
    <!-- 星星图标 -->
    <div class="pet-wrap" :style="petWrapStyle">
      <span class="pet-emoji">{{ petEmoji }}</span>
      <div class="inner-glow" :style="innerGlowStyle" />
    </div>
    <!-- 等级徽章 -->
    <div class="level-badge">
      <span class="level-label">LEVEL</span>
      <span class="level-num">{{ state.pet_level }}</span>
    </div>
  </div>
</template>

<script setup>
import { computed } from 'vue'

const props = defineProps({ state: Object })

const petEmoji = computed(() => {
  const s = props.state.health_score
  if (s >= 80) return '🌟'
  if (s >= 50) return '😊'
  if (s >= 20) return '😴'
  return '💀'
})

// 旋转速度与健康分挂钩：越健康转越快
const rotationDuration = computed(() => {
  const base = 6
  const speed = base + (100 - props.state.health_score) * 0.12
  return `${speed}s`
})

// 发光强度与健康分挂钩
const glowIntensity = computed(() => props.state.health_score / 100)

const haloStyle = computed(() => ({
  opacity: glowIntensity.value * 0.6,
  animationDuration: rotationDuration.value,
}))

const innerGlowStyle = computed(() => ({
  opacity: glowIntensity.value,
  boxShadow: `0 0 ${20 + props.state.health_score * 0.6}px rgba(142,207,207,${glowIntensity.value * 0.8})`,
}))

const petWrapStyle = computed(() => ({
  transform: `scale(${0.85 + props.state.pet_level * 0.03})`,
  animationDuration: rotationDuration.value,
}))
</script>

<style scoped>
.pet-container {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 16px;
  position: relative;
}

/* 外层光晕环 */
.halo {
  position: absolute;
  width: 160px; height: 160px;
  border-radius: 50%;
  background: conic-gradient(
    from 0deg,
    transparent 0%,
    rgba(142,207,207,0.25) 30%,
    rgba(122,155,191,0.2) 60%,
    transparent 100%
  );
  animation: halo-spin linear infinite;
  filter: blur(8px);
  top: -10px;
}

@keyframes halo-spin {
  from { transform: rotate(0deg); }
  to   { transform: rotate(360deg); }
}

/* 图标容器 */
.pet-wrap {
  position: relative;
  width: 120px; height: 120px;
  display: flex; align-items: center; justify-content: center;
  border-radius: 50%;
  background: rgba(255,255,255,0.04);
  border: 1px solid rgba(255,255,255,0.10);
  transition: transform 0.8s cubic-bezier(0.34, 1.56, 0.64, 1);
  animation: float 6s ease-in-out infinite;
}

@keyframes float {
  0%, 100% { transform: translateY(0px); }
  50%       { transform: translateY(-8px); }
}

.pet-emoji {
  font-size: 56px;
  position: relative;
  z-index: 1;
  filter: drop-shadow(0 0 12px rgba(142,207,207,0.4));
  transition: filter 1s ease;
}

.inner-glow {
  position: absolute;
  inset: 0;
  border-radius: 50%;
  transition: all 1.2s cubic-bezier(0.4, 0, 0.2, 1);
}

/* 等级徽章 */
.level-badge {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 2px;
  background: rgba(142,207,207,0.10);
  border: 1px solid rgba(142,207,207,0.20);
  border-radius: 12px;
  padding: 6px 18px;
}

.level-label {
  font-size: 9px;
  letter-spacing: 0.15em;
  color: rgba(142,207,207,0.6);
  font-weight: 500;
}

.level-num {
  font-size: 22px;
  font-weight: 600;
  color: var(--morandi-cyan, #8ecfcf);
  line-height: 1;
}
</style>
