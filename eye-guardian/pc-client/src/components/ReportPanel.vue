<template>
  <Transition name="report-fade">
    <div v-if="visible" class="report-overlay" @click.self="$emit('close')">
      <div class="report-panel">
        <!-- 头部 -->
        <div class="report-header">
          <div class="header-top">
            <h2 class="report-title">健康报告</h2>
            <button class="report-close" @click="$emit('close')" aria-label="关闭">
              <svg width="16" height="16" viewBox="0 0 16 16" fill="none">
                <path d="M3 3l10 10M13 3L3 13" stroke="currentColor" stroke-width="2" stroke-linecap="round"/>
              </svg>
            </button>
          </div>
          <div class="period-tabs">
            <button
              v-for="p in ['today', 'week']"
              :key="p"
              class="period-tab"
              :class="{ active: period === p }"
              @click="period = p"
            >
              {{ p === 'today' ? '今日' : '本周' }}
            </button>
          </div>
        </div>

        <!-- 核心指标卡片 -->
        <div class="metrics-grid">
          <div class="metric-card">
            <div class="metric-icon">🌟</div>
            <div class="metric-value">{{ stats.avgHealth.toFixed(0) }}</div>
            <div class="metric-label">平均健康分</div>
          </div>
          <div class="metric-card">
            <div class="metric-icon">⏱️</div>
            <div class="metric-value">{{ stats.totalWorkTime }}h</div>
            <div class="metric-label">工作时长</div>
          </div>
          <div class="metric-card">
            <div class="metric-icon">☕</div>
            <div class="metric-value">{{ stats.restCount }}</div>
            <div class="metric-label">休息次数</div>
          </div>
          <div class="metric-card">
            <div class="metric-icon">⏭️</div>
            <div class="metric-value">{{ stats.snoozeCount }}</div>
            <div class="metric-label">推迟次数</div>
          </div>
        </div>

        <!-- 依从性评分 -->
        <div class="compliance-section">
          <h3 class="section-title">依从性评分</h3>
          <div class="compliance-bar">
            <div class="compliance-fill" :style="{ width: stats.compliance + '%' }">
              <span class="compliance-text">{{ stats.compliance }}%</span>
            </div>
          </div>
          <p class="compliance-desc">{{ complianceDesc }}</p>
        </div>

        <!-- 趋势图表 -->
        <div class="chart-section">
          <h3 class="section-title">健康趋势</h3>
          <svg class="trend-chart" viewBox="0 0 280 120" preserveAspectRatio="none">
            <!-- 网格线 -->
            <line v-for="i in 5" :key="'grid-' + i"
              :x1="0" :y1="i * 24" :x2="280" :y2="i * 24"
              stroke="rgba(0,0,0,0.05)" stroke-width="0.5" />
            
            <!-- 健康分折线 -->
            <polyline
              :points="healthPolyline"
              fill="none"
              stroke="#a9c2b6"
              stroke-width="2.5"
              stroke-linecap="round"
              stroke-linejoin="round"
            />
            <!-- 健康分面积 -->
            <polygon
              :points="healthPolygon"
              fill="url(#healthGradient)"
              opacity="0.3"
            />
            
            <!-- 疲劳度折线 -->
            <polyline
              :points="fatiguePolyline"
              fill="none"
              stroke="#d0b8b0"
              stroke-width="2"
              stroke-linecap="round"
              stroke-linejoin="round"
              stroke-dasharray="4 3"
            />

            <!-- 渐变定义 -->
            <defs>
              <linearGradient id="healthGradient" x1="0" y1="0" x2="0" y2="1">
                <stop offset="0%" stop-color="#a9c2b6" stop-opacity="0.6"/>
                <stop offset="100%" stop-color="#a9c2b6" stop-opacity="0.05"/>
              </linearGradient>
            </defs>
          </svg>
          <div class="chart-legend">
            <span class="legend-item"><span class="legend-dot health"></span>健康分</span>
            <span class="legend-item"><span class="legend-dot fatigue"></span>疲劳度</span>
          </div>
        </div>

        <!-- 建议 -->
        <div class="suggestions">
          <h3 class="section-title">💡 改善建议</h3>
          <ul class="suggestion-list">
            <li v-for="(tip, i) in suggestions" :key="i">{{ tip }}</li>
          </ul>
        </div>
      </div>
    </div>
  </Transition>
</template>

<script setup>
import { ref, computed, watch } from 'vue'

const props = defineProps({
  visible: Boolean,
  reportData: Object, // { daily: [], weekly: [] }
})

defineEmits(['close'])

const period = ref('today')

// 模拟数据（实际应从 props.reportData 获取）
const mockData = {
  today: [
    { time: '08:00', health: 100, fatigue: 0 },
    { time: '10:00', health: 85, fatigue: 20 },
    { time: '12:00', health: 75, fatigue: 35 },
    { time: '14:00', health: 90, fatigue: 10 },
    { time: '16:00', health: 70, fatigue: 45 },
    { time: '18:00', health: 65, fatigue: 55 },
    { time: '20:00', health: 80, fatigue: 20 },
  ],
  week: [
    { day: '周一', health: 75, fatigue: 40 },
    { day: '周二', health: 82, fatigue: 30 },
    { day: '周三', health: 68, fatigue: 50 },
    { day: '周四', health: 78, fatigue: 35 },
    { day: '周五', health: 72, fatigue: 45 },
    { day: '周六', health: 90, fatigue: 15 },
    { day: '周日', health: 88, fatigue: 20 },
  ],
}

const currentData = computed(() => mockData[period.value])

// 统计数据
const stats = computed(() => {
  const data = currentData.value
  const avgHealth = data.reduce((sum, d) => sum + d.health, 0) / data.length
  const totalWorkTime = period.value === 'today' ? 8.5 : 42
  const restCount = period.value === 'today' ? 3 : 18
  const snoozeCount = period.value === 'today' ? 1 : 5
  const compliance = Math.round((restCount / (restCount + snoozeCount)) * 100)
  
  return { avgHealth, totalWorkTime, restCount, snoozeCount, compliance }
})

// 依从性描述
const complianceDesc = computed(() => {
  const c = stats.value.compliance
  if (c >= 90) return '优秀！您很好地遵守了休息计划'
  if (c >= 70) return '良好，继续保持规律休息'
  if (c >= 50) return '尚可，建议减少推迟次数'
  return '需要改善，频繁推迟会影响健康'
})

// 图表折线点
const healthPolyline = computed(() => {
  const data = currentData.value
  const w = 280
  const h = 120
  return data.map((d, i) => {
    const x = (i / (data.length - 1)) * w
    const y = h - (d.health / 100) * h
    return `${x},${y}`
  }).join(' ')
})

const healthPolygon = computed(() => {
  return healthPolyline.value + ' 280,120 0,120'
})

const fatiguePolyline = computed(() => {
  const data = currentData.value
  const w = 280
  const h = 120
  return data.map((d, i) => {
    const x = (i / (data.length - 1)) * w
    const y = h - (d.fatigue / 60) * h
    return `${x},${y}`
  }).join(' ')
})

// 建议
const suggestions = computed(() => {
  const tips = []
  if (stats.value.avgHealth < 70) {
    tips.push('您的平均健康分偏低，建议增加休息频率')
  }
  if (stats.value.snoozeCount > stats.value.restCount * 0.3) {
    tips.push('推迟次数较多，尝试在提醒时立即休息')
  }
  if (stats.value.totalWorkTime > 40) {
    tips.push('工作时长较长，注意劳逸结合')
  }
  if (tips.length === 0) {
    tips.push('您的用眼习惯很健康，继续保持！')
  }
  return tips
})
</script>

<style scoped>
.report-overlay {
  position: fixed;
  inset: 0;
  background: rgba(0, 0, 0, 0.45);
  backdrop-filter: blur(8px);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1000;
  padding: 20px;
}

.report-panel {
  background: rgba(255, 255, 255, 0.95);
  backdrop-filter: blur(60px) saturate(1.4);
  border-radius: 24px;
  border: 1px solid rgba(255, 255, 255, 0.6);
  box-shadow: 0 30px 80px rgba(0, 0, 0, 0.15);
  width: 100%;
  max-width: 520px;
  max-height: 90vh;
  overflow-y: auto;
  padding: 32px;
}

/* 头部 */
.report-header {
  margin-bottom: 28px;
}

.header-top {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 16px;
}

.report-title {
  font-size: 22px;
  font-weight: 600;
  color: var(--m-text);
  letter-spacing: -0.02em;
}

.period-tabs {
  display: flex;
  gap: 6px;
  background: rgba(0, 0, 0, 0.04);
  padding: 3px;
  border-radius: 999px;
}

.period-tab {
  padding: 6px 16px;
  border: none;
  background: transparent;
  border-radius: 999px;
  font-size: 13px;
  font-weight: 500;
  color: var(--m-muted);
  cursor: pointer;
  transition: all 0.25s var(--spring);
  font-family: inherit;
}

.period-tab.active {
  background: white;
  color: var(--m-text);
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.08);
}

.report-close {
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
  flex-shrink: 0;
}

.report-close:hover {
  background: rgba(0, 0, 0, 0.1);
  transform: scale(1.1);
}

/* 指标卡片 */
.metrics-grid {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 12px;
  margin-bottom: 24px;
}

.metric-card {
  background: rgba(255, 255, 255, 0.6);
  border: 1px solid rgba(255, 255, 255, 0.8);
  border-radius: 16px;
  padding: 18px;
  text-align: center;
  transition: transform 0.2s var(--spring);
}

.metric-card:hover {
  transform: translateY(-2px);
}

.metric-icon {
  font-size: 28px;
  margin-bottom: 8px;
}

.metric-value {
  font-size: 26px;
  font-weight: 700;
  color: var(--m-text);
  letter-spacing: -0.03em;
  margin-bottom: 4px;
}

.metric-label {
  font-size: 11px;
  color: var(--m-muted);
  font-weight: 500;
  letter-spacing: 0.04em;
}

/* 依从性 */
.compliance-section {
  margin-bottom: 24px;
}

.section-title {
  font-size: 14px;
  font-weight: 600;
  color: var(--m-text);
  margin-bottom: 12px;
}

.compliance-bar {
  height: 32px;
  background: rgba(0, 0, 0, 0.04);
  border-radius: 999px;
  overflow: hidden;
  margin-bottom: 8px;
}

.compliance-fill {
  height: 100%;
  background: linear-gradient(90deg, #a9c2b6 0%, #8ab0a0 100%);
  border-radius: 999px;
  display: flex;
  align-items: center;
  justify-content: flex-end;
  padding-right: 14px;
  transition: width 1s var(--spring);
  box-shadow: 0 0 12px rgba(169, 194, 182, 0.4);
}

.compliance-text {
  font-size: 13px;
  font-weight: 700;
  color: white;
  text-shadow: 0 1px 2px rgba(0, 0, 0, 0.2);
}

.compliance-desc {
  font-size: 12px;
  color: var(--m-muted);
  line-height: 1.5;
}

/* 图表 */
.chart-section {
  margin-bottom: 24px;
}

.trend-chart {
  width: 100%;
  height: 120px;
  margin-bottom: 12px;
}

.chart-legend {
  display: flex;
  gap: 16px;
  justify-content: center;
}

.legend-item {
  display: flex;
  align-items: center;
  gap: 6px;
  font-size: 11px;
  color: var(--m-muted);
}

.legend-dot {
  width: 10px;
  height: 10px;
  border-radius: 50%;
}

.legend-dot.health {
  background: #a9c2b6;
}

.legend-dot.fatigue {
  background: #d0b8b0;
}

/* 建议 */
.suggestions {
  background: rgba(169, 194, 182, 0.08);
  border-radius: 16px;
  padding: 18px;
}

.suggestion-list {
  list-style: none;
  margin: 0;
  padding: 0;
}

.suggestion-list li {
  font-size: 13px;
  color: var(--m-text);
  line-height: 1.7;
  padding-left: 18px;
  position: relative;
  margin-bottom: 8px;
}

.suggestion-list li:last-child {
  margin-bottom: 0;
}

.suggestion-list li::before {
  content: '•';
  position: absolute;
  left: 0;
  color: var(--m-green);
  font-weight: bold;
}

/* 过渡动画 */
.report-fade-enter-active,
.report-fade-leave-active {
  transition: opacity 0.3s ease;
}

.report-fade-enter-active .report-panel {
  transition: transform 0.4s var(--spring), opacity 0.3s ease;
}

.report-fade-leave-active .report-panel {
  transition: transform 0.3s ease, opacity 0.25s ease;
}

.report-fade-enter-from,
.report-fade-leave-to {
  opacity: 0;
}

.report-fade-enter-from .report-panel {
  transform: scale(0.92) translateY(20px);
  opacity: 0;
}

.report-fade-leave-to .report-panel {
  transform: scale(0.96);
  opacity: 0;
}
</style>
