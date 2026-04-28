<template>
  <div class="control-panel">
    <div class="btn-grid">
      <button class="ctrl-btn fatigue-btn" @click="addFatigue" title="模拟用眼疲劳">
        <span class="btn-icon">😵</span>
        <span class="btn-label">增加疲劳</span>
        <span class="btn-sub">+10 min</span>
      </button>

      <button class="ctrl-btn rest-btn" @click="rest" title="模拟休息恢复">
        <span class="btn-icon">😌</span>
        <span class="btn-label">休息</span>
        <span class="btn-sub">疲劳清零</span>
      </button>

      <button class="ctrl-btn health-btn" @click="decreaseHealth" title="模拟健康下降">
        <span class="btn-icon">📉</span>
        <span class="btn-label">降低健康</span>
        <span class="btn-sub">-10 分</span>
      </button>

      <button class="ctrl-btn level-btn" @click="levelUp" title="模拟升级">
        <span class="btn-icon">⬆️</span>
        <span class="btn-label">升级</span>
        <span class="btn-sub">Lv +1</span>
      </button>
    </div>

    <!-- 状态切换 -->
    <div class="status-switcher">
      <button
        v-for="s in statuses"
        :key="s.value"
        class="status-chip"
        :class="{ active: state.current_status === s.value }"
        @click="setStatus(s.value)"
      >
        {{ s.label }}
      </button>
    </div>
  </div>
</template>

<script setup>
const props = defineProps({ state: Object })
const emit = defineEmits(['update'])

const statuses = [
  { value: 'active', label: '🟢 活跃' },
  { value: 'idle',   label: '🟡 闲置' },
  { value: 'screen_locked', label: '🔒 锁屏' },
]

const addFatigue = () => emit('update', {
  accumulated_fatigue: Math.min(props.state.accumulated_fatigue + 10, 60),
})

const rest = () => emit('update', {
  accumulated_fatigue: 0,
  health_score: Math.min(props.state.health_score + 10, 100),
  current_status: 'active',
})

const decreaseHealth = () => emit('update', {
  health_score: Math.max(props.state.health_score - 10, 0),
})

const levelUp = () => emit('update', {
  pet_level: props.state.pet_level + 1,
})

const setStatus = (s) => emit('update', { current_status: s })
</script>

<style scoped>
.control-panel { display: flex; flex-direction: column; gap: 14px; }

.btn-grid {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 8px;
}

.ctrl-btn {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 3px;
  padding: 12px 8px;
  border-radius: 14px;
  border: 1px solid rgba(255,255,255,0.08);
  background: rgba(255,255,255,0.04);
  cursor: pointer;
  font-family: inherit;
  transition: all 0.25s cubic-bezier(0.34, 1.56, 0.64, 1);
  color: var(--morandi-text, #c8cdd8);
}

.ctrl-btn:hover {
  transform: translateY(-2px) scale(1.03);
  background: rgba(255,255,255,0.08);
  border-color: rgba(255,255,255,0.15);
}
.ctrl-btn:active {
  transform: scale(0.96);
}

.btn-icon { font-size: 20px; }
.btn-label { font-size: 11px; font-weight: 500; letter-spacing: 0.04em; }
.btn-sub { font-size: 10px; color: var(--morandi-muted, #7a7f8e); }

.fatigue-btn:hover { border-color: rgba(191,155,142,0.4); box-shadow: 0 4px 16px rgba(191,155,142,0.15); }
.rest-btn:hover    { border-color: rgba(142,207,207,0.4); box-shadow: 0 4px 16px rgba(142,207,207,0.15); }
.health-btn:hover  { border-color: rgba(155,143,191,0.4); box-shadow: 0 4px 16px rgba(155,143,191,0.15); }
.level-btn:hover   { border-color: rgba(191,191,142,0.4); box-shadow: 0 4px 16px rgba(191,191,142,0.15); }

/* 状态切换 */
.status-switcher {
  display: flex;
  gap: 6px;
  flex-wrap: wrap;
}

.status-chip {
  flex: 1;
  min-width: 0;
  padding: 7px 6px;
  border-radius: 10px;
  border: 1px solid rgba(255,255,255,0.08);
  background: rgba(255,255,255,0.03);
  font-size: 11px;
  font-family: inherit;
  color: var(--morandi-muted, #7a7f8e);
  cursor: pointer;
  transition: all 0.2s ease;
  white-space: nowrap;
  text-align: center;
}

.status-chip:hover {
  background: rgba(255,255,255,0.07);
  color: var(--morandi-text, #c8cdd8);
}

.status-chip.active {
  background: rgba(142,207,207,0.12);
  border-color: rgba(142,207,207,0.30);
  color: #8ecfcf;
}
</style>
