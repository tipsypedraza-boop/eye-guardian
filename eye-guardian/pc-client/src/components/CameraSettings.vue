<template>
  <Transition name="settings-fade">
    <div v-if="visible" class="settings-overlay" @click.self="$emit('close')">
      <div class="settings-panel">
        <!-- 头部 -->
        <div class="settings-header">
          <h2 class="settings-title">📷 视距检测设置</h2>
          <button class="settings-close" @click="$emit('close')" aria-label="关闭">
            <svg width="16" height="16" viewBox="0 0 16 16" fill="none">
              <path d="M3 3l10 10M13 3L3 13" stroke="currentColor" stroke-width="2" stroke-linecap="round"/>
            </svg>
          </button>
        </div>

        <!-- 开关 -->
        <div class="setting-item">
          <div class="setting-label">
            <span class="label-text">启用视距检测</span>
            <span class="label-desc">使用摄像头监测观看距离</span>
          </div>
          <button 
            class="toggle-switch" 
            :class="{ active: enabled }"
            @click="$emit('toggle')"
          >
            <span class="toggle-slider" />
          </button>
        </div>

        <!-- 状态显示 -->
        <div v-if="enabled" class="status-section">
          <div class="status-item">
            <span class="status-icon">{{ cameraReady ? '✅' : '⏳' }}</span>
            <span class="status-text">摄像头状态: {{ cameraReady ? '就绪' : '初始化中' }}</span>
          </div>
          <div class="status-item">
            <span class="status-icon">{{ faceDetected ? '👤' : '❓' }}</span>
            <span class="status-text">人脸检测: {{ faceDetected ? '已检测到' : '未检测到' }}</span>
          </div>
          <div v-if="faceDetected" class="status-item">
            <span class="status-icon">📏</span>
            <span class="status-text">当前距离: {{ distance }}cm</span>
          </div>
        </div>

        <!-- 距离配置 -->
        <div class="config-section">
          <h3 class="section-title">距离阈值</h3>
          
          <div class="config-item">
            <label class="config-label">安全距离</label>
            <div class="config-input-group">
              <input 
                type="number" 
                class="config-input"
                :value="safeDistance"
                @input="$emit('update:safeDistance', Number($event.target.value))"
                min="30"
                max="100"
              />
              <span class="config-unit">cm</span>
            </div>
          </div>
          
          <div class="config-item">
            <label class="config-label">警告距离</label>
            <div class="config-input-group">
              <input 
                type="number" 
                class="config-input"
                :value="warningDistance"
                @input="$emit('update:warningDistance', Number($event.target.value))"
                min="20"
                max="50"
              />
              <span class="config-unit">cm</span>
            </div>
          </div>
          
          <div class="config-item">
            <label class="config-label">危险距离</label>
            <div class="config-input-group">
              <input 
                type="number" 
                class="config-input"
                :value="dangerDistance"
                @input="$emit('update:dangerDistance', Number($event.target.value))"
                min="10"
                max="30"
              />
              <span class="config-unit">cm</span>
            </div>
          </div>
        </div>

        <!-- 统计信息 -->
        <div v-if="enabled && stats" class="stats-section">
          <h3 class="section-title">统计数据</h3>
          
          <div class="stats-grid">
            <div class="stat-card">
              <div class="stat-value">{{ stats.totalChecks }}</div>
              <div class="stat-label">检测次数</div>
            </div>
            <div class="stat-card">
              <div class="stat-value">{{ stats.averageDistance }}cm</div>
              <div class="stat-label">平均距离</div>
            </div>
            <div class="stat-card">
              <div class="stat-value">{{ complianceScore }}%</div>
              <div class="stat-label">依从性</div>
            </div>
            <div class="stat-card">
              <div class="stat-value">{{ stats.tooCloseCount }}</div>
              <div class="stat-label">过近次数</div>
            </div>
          </div>
          
          <button class="reset-btn" @click="$emit('reset-stats')">
            重置统计
          </button>
        </div>

        <!-- 隐私说明 -->
        <div class="privacy-notice">
          <p class="privacy-icon">🔒</p>
          <p class="privacy-text">
            所有视频处理完全在本地进行，不会上传任何图像数据。
            摄像头仅用于距离检测，不会录制或存储视频。
          </p>
        </div>
      </div>
    </div>
  </Transition>
</template>

<script setup>
import { computed } from 'vue'

const props = defineProps({
  visible: Boolean,
  enabled: Boolean,
  cameraReady: Boolean,
  faceDetected: Boolean,
  distance: { type: Number, default: 0 },
  safeDistance: { type: Number, default: 40 },
  warningDistance: { type: Number, default: 30 },
  dangerDistance: { type: Number, default: 20 },
  stats: Object,
})

defineEmits(['close', 'toggle', 'update:safeDistance', 'update:warningDistance', 'update:dangerDistance', 'reset-stats'])

const complianceScore = computed(() => {
  if (!props.stats || props.stats.totalChecks === 0) return 100
  const ratio = props.stats.tooCloseCount / props.stats.totalChecks
  return Math.round((1 - ratio) * 100)
})
</script>

<style scoped>
.settings-overlay {
  position: fixed;
  inset: 0;
  background: rgba(0, 0, 0, 0.5);
  backdrop-filter: blur(8px);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 2000;
  padding: 20px;
}

.settings-panel {
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
.settings-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 28px;
}

.settings-title {
  font-size: 22px;
  font-weight: 600;
  color: var(--m-text);
  letter-spacing: -0.02em;
}

.settings-close {
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
}

.settings-close:hover {
  background: rgba(0, 0, 0, 0.1);
  transform: scale(1.1);
}

/* 设置项 */
.setting-item {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 20px;
  background: rgba(255, 255, 255, 0.6);
  border: 1px solid rgba(255, 255, 255, 0.8);
  border-radius: 16px;
  margin-bottom: 20px;
}

.setting-label {
  flex: 1;
}

.label-text {
  display: block;
  font-size: 15px;
  font-weight: 600;
  color: var(--m-text);
  margin-bottom: 4px;
}

.label-desc {
  display: block;
  font-size: 12px;
  color: var(--m-muted);
}

/* 开关 */
.toggle-switch {
  position: relative;
  width: 52px;
  height: 28px;
  background: rgba(0, 0, 0, 0.1);
  border-radius: 999px;
  border: none;
  cursor: pointer;
  transition: background 0.3s ease;
}

.toggle-switch.active {
  background: linear-gradient(135deg, #a9c2b6 0%, #8ab0a0 100%);
}

.toggle-slider {
  position: absolute;
  top: 3px;
  left: 3px;
  width: 22px;
  height: 22px;
  background: white;
  border-radius: 50%;
  transition: transform 0.3s var(--spring-bounce);
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.15);
}

.toggle-switch.active .toggle-slider {
  transform: translateX(24px);
}

/* 状态 */
.status-section {
  margin-bottom: 24px;
}

.status-item {
  display: flex;
  align-items: center;
  gap: 10px;
  padding: 12px;
  background: rgba(169, 194, 182, 0.08);
  border-radius: 12px;
  margin-bottom: 8px;
  font-size: 13px;
  color: var(--m-text);
}

.status-icon {
  font-size: 18px;
}

/* 配置 */
.config-section,
.stats-section {
  margin-bottom: 24px;
}

.section-title {
  font-size: 14px;
  font-weight: 600;
  color: var(--m-text);
  margin-bottom: 16px;
}

.config-item {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 12px;
}

.config-label {
  font-size: 13px;
  color: var(--m-text);
  font-weight: 500;
}

.config-input-group {
  display: flex;
  align-items: center;
  gap: 8px;
}

.config-input {
  width: 80px;
  padding: 8px 12px;
  border: 1px solid rgba(0, 0, 0, 0.1);
  border-radius: 8px;
  background: white;
  font-size: 14px;
  font-family: inherit;
  color: var(--m-text);
  text-align: center;
}

.config-input:focus {
  outline: none;
  border-color: var(--m-green);
}

.config-unit {
  font-size: 12px;
  color: var(--m-muted);
  font-weight: 500;
}

/* 统计 */
.stats-grid {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 12px;
  margin-bottom: 16px;
}

.stat-card {
  background: rgba(255, 255, 255, 0.6);
  border: 1px solid rgba(255, 255, 255, 0.8);
  border-radius: 12px;
  padding: 16px;
  text-align: center;
}

.stat-value {
  font-size: 24px;
  font-weight: 700;
  color: var(--m-text);
  margin-bottom: 4px;
}

.stat-label {
  font-size: 11px;
  color: var(--m-muted);
  font-weight: 500;
}

.reset-btn {
  width: 100%;
  padding: 10px;
  border-radius: 12px;
  border: 1px solid rgba(0, 0, 0, 0.1);
  background: rgba(255, 255, 255, 0.6);
  font-size: 13px;
  font-weight: 500;
  font-family: inherit;
  color: var(--m-text);
  cursor: pointer;
  transition: all 0.2s var(--spring);
}

.reset-btn:hover {
  background: rgba(255, 255, 255, 0.8);
  transform: translateY(-1px);
}

/* 隐私说明 */
.privacy-notice {
  background: rgba(169, 194, 182, 0.08);
  border-radius: 16px;
  padding: 16px;
  text-align: center;
}

.privacy-icon {
  font-size: 24px;
  margin-bottom: 8px;
}

.privacy-text {
  font-size: 12px;
  color: var(--m-muted);
  line-height: 1.6;
  margin: 0;
}

/* 过渡动画 */
.settings-fade-enter-active,
.settings-fade-leave-active {
  transition: opacity 0.3s ease;
}

.settings-fade-enter-active .settings-panel {
  transition: transform 0.4s var(--spring), opacity 0.3s ease;
}

.settings-fade-leave-active .settings-panel {
  transition: transform 0.3s ease, opacity 0.25s ease;
}

.settings-fade-enter-from,
.settings-fade-leave-to {
  opacity: 0;
}

.settings-fade-enter-from .settings-panel {
  transform: scale(0.92) translateY(20px);
  opacity: 0;
}

.settings-fade-leave-to .settings-panel {
  transform: scale(0.96);
  opacity: 0;
}
</style>
