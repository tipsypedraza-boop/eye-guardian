<template>
  <!-- 色温滤镜：根据时间段叠加暖色半透明层 -->
  <div class="ct-filter" :style="filterStyle" />
</template>

<script setup>
import { ref, onMounted, onUnmounted } from 'vue'

// 根据当前小时计算暖色强度
// 06:00-09:00 晨间：轻微暖色
// 09:00-17:00 日间：无滤镜
// 17:00-20:00 黄昏：中等暖色
// 20:00-06:00 夜间：较强暖色（过滤蓝光）
function getWarmth(hour) {
  if (hour >= 9 && hour < 17)  return 0          // 日间无滤镜
  if (hour >= 17 && hour < 20) return 0.06        // 黄昏
  if (hour >= 20 || hour < 6)  return 0.13        // 夜间
  return 0.03                                      // 晨间
}

const filterStyle = ref({})

function update() {
  const h = new Date().getHours()
  const warmth = getWarmth(h)
  filterStyle.value = warmth === 0
    ? { opacity: 0 }
    : {
        opacity: warmth,
        background: 'linear-gradient(135deg, rgba(255,200,120,0.9) 0%, rgba(255,160,80,0.7) 100%)',
      }
}

let timer
onMounted(() => {
  update()
  // 每分钟检查一次
  timer = setInterval(update, 60_000)
})
onUnmounted(() => clearInterval(timer))
</script>

<style scoped>
.ct-filter {
  position: fixed;
  inset: 0;
  pointer-events: none;
  z-index: 5;
  transition: opacity 120s linear; /* 2分钟平滑过渡 */
  mix-blend-mode: multiply;
}
</style>
