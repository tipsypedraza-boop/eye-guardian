<template>
  <div class="trend-chart">
    <div class="legend">
      <span class="legend-item health">健康分</span>
      <span class="legend-item fatigue">疲劳度</span>
    </div>
    <svg class="chart-svg" :viewBox="`0 0 ${W} ${H}`" preserveAspectRatio="none">
      <!-- 健康分区域 -->
      <defs>
        <linearGradient id="healthGrad" x1="0" y1="0" x2="0" y2="1">
          <stop offset="0%" stop-color="#a9c2b6" stop-opacity="0.45" />
          <stop offset="100%" stop-color="#a9c2b6" stop-opacity="0" />
        </linearGradient>
        <linearGradient id="fatigueGrad" x1="0" y1="0" x2="0" y2="1">
          <stop offset="0%" stop-color="#d0b8b0" stop-opacity="0.45" />
          <stop offset="100%" stop-color="#d0b8b0" stop-opacity="0" />
        </linearGradient>
      </defs>

      <!-- 网格线 -->
      <line v-for="y in gridLines" :key="y"
        :x1="0" :y1="y" :x2="W" :y2="y"
        stroke="rgba(0,0,0,0.04)" stroke-width="1"
      />

      <!-- 健康分面积 -->
      <path :d="healthArea" fill="url(#healthGrad)" />
      <!-- 健康分折线 -->
      <path :d="healthLine" fill="none" stroke="#a9c2b6" stroke-width="2"
        stroke-linecap="round" stroke-linejoin="round" />

      <!-- 疲劳度面积 -->
      <path :d="fatigueArea" fill="url(#fatigueGrad)" />
      <!-- 疲劳度折线 -->
      <path :d="fatigueLine" fill="none" stroke="#d0b8b0" stroke-width="2"
        stroke-linecap="round" stroke-linejoin="round" />

      <!-- 最新数据点 -->
      <circle v-if="points.length"
        :cx="points[points.length-1].x"
        :cy="points[points.length-1].hy"
        r="3" fill="#a9c2b6"
      />
      <circle v-if="points.length"
        :cx="points[points.length-1].x"
        :cy="points[points.length-1].fy"
        r="3" fill="#d0b8b0"
      />
    </svg>

    <!-- 空状态 -->
    <div v-if="history.length < 2" class="empty-hint">数据积累中…</div>
  </div>
</template>

<script setup>
import { computed } from 'vue'

const props = defineProps({ history: Array })

const W = 260
const H = 90
const PAD = 8

const gridLines = [H * 0.25, H * 0.5, H * 0.75]

const points = computed(() => {
  const data = props.history
  if (data.length < 2) return []
  return data.map((d, i) => {
    const x = PAD + (i / (data.length - 1)) * (W - PAD * 2)
    const hy = H - PAD - (d.health / 100) * (H - PAD * 2)
    const fy = H - PAD - (Math.min(d.fatigue, 60) / 60) * (H - PAD * 2)
    return { x, hy, fy }
  })
})

function buildLine(pts, key) {
  if (!pts.length) return ''
  return pts.map((p, i) => `${i === 0 ? 'M' : 'L'}${p.x.toFixed(1)},${p[key].toFixed(1)}`).join(' ')
}

function buildArea(pts, key) {
  if (!pts.length) return ''
  const line = buildLine(pts, key)
  const last = pts[pts.length - 1]
  const first = pts[0]
  return `${line} L${last.x.toFixed(1)},${H} L${first.x.toFixed(1)},${H} Z`
}

const healthLine  = computed(() => buildLine(points.value, 'hy'))
const healthArea  = computed(() => buildArea(points.value, 'hy'))
const fatigueLine = computed(() => buildLine(points.value, 'fy'))
const fatigueArea = computed(() => buildArea(points.value, 'fy'))
</script>

<style scoped>
.trend-chart {
  position: relative;
  width: 100%;
}

.legend {
  display: flex;
  gap: 14px;
  margin-bottom: 10px;
}

.legend-item {
  font-size: 10px;
  font-weight: 500;
  letter-spacing: 0.06em;
  display: flex;
  align-items: center;
  gap: 5px;
}
.legend-item::before {
  content: '';
  display: inline-block;
  width: 16px; height: 2px;
  border-radius: 2px;
}
.legend-item.health { color: #6a9a8e; }
.legend-item.health::before { background: #a9c2b6; }
.legend-item.fatigue { color: #9a7a72; }
.legend-item.fatigue::before { background: #d0b8b0; }

.chart-svg {
  width: 100%;
  height: 90px;
  overflow: visible;
}

.empty-hint {
  position: absolute;
  inset: 0;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 11px;
  color: rgba(74,82,96,0.3);
  letter-spacing: 0.06em;
  padding-top: 20px;
}
</style>
