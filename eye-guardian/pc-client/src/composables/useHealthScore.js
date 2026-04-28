import { ref, computed, watch } from 'vue'

/**
 * 健康评分综合计算系统
 * 综合考虑：依从性、坐姿、眨眼频率、工作时长
 */
export function useHealthScore() {
  // 基础数据
  const restCompleted = ref(0)      // 完成的休息次数
  const restSnoozed = ref(0)        // 推迟的休息次数
  const postureScore = ref(100)     // 坐姿评分 (0-100)
  const blinkRate = ref(15)         // 眨眼频率 (次/分钟，正常12-20)
  const workDuration = ref(0)       // 连续工作时长 (分钟)
  
  // 免扰盾系统
  const shields = ref(0)            // 当前免扰盾数量
  const maxShields = ref(3)         // 最大免扰盾数量
  const shieldActive = ref(false)   // 是否激活免扰盾
  
  // 依从性评分 (0-100)
  const complianceScore = computed(() => {
    const total = restCompleted.value + restSnoozed.value
    if (total === 0) return 100
    return Math.round((restCompleted.value / total) * 100)
  })
  
  // 眨眼评分 (0-100)
  const blinkScore = computed(() => {
    const rate = blinkRate.value
    if (rate >= 12 && rate <= 20) return 100
    if (rate < 12) {
      // 眨眼过少，线性扣分
      return Math.max(0, Math.round((rate / 12) * 100))
    }
    // 眨眼过多也不正常，但扣分较少
    return Math.max(60, Math.round(100 - (rate - 20) * 2))
  })
  
  // 工作时长评分 (0-100)
  const durationScore = computed(() => {
    const minutes = workDuration.value
    if (minutes <= 50) return 100
    if (minutes <= 90) {
      // 50-90分钟，线性衰减
      return Math.round(100 - ((minutes - 50) / 40) * 30)
    }
    // 超过90分钟，快速衰减
    return Math.max(0, Math.round(70 - (minutes - 90) * 0.5))
  })
  
  // 综合健康分 (加权平均)
  const healthScore = computed(() => {
    if (shieldActive.value) {
      // 免扰盾激活时，保持高分
      return Math.max(85, healthScore.value)
    }
    
    const weights = {
      compliance: 0.35,  // 依从性权重最高
      posture: 0.25,     // 坐姿次之
      blink: 0.20,       // 眨眼
      duration: 0.20,    // 工作时长
    }
    
    const score = 
      complianceScore.value * weights.compliance +
      postureScore.value * weights.posture +
      blinkScore.value * weights.blink +
      durationScore.value * weights.duration
    
    return Math.round(Math.max(0, Math.min(100, score)))
  })
  
  // 健康等级
  const healthLevel = computed(() => {
    const score = healthScore.value
    if (score >= 90) return { level: 'excellent', label: '优秀', emoji: '🌟' }
    if (score >= 75) return { level: 'good', label: '良好', emoji: '😊' }
    if (score >= 60) return { level: 'fair', label: '一般', emoji: '😐' }
    if (score >= 40) return { level: 'poor', label: '较差', emoji: '😴' }
    return { level: 'critical', label: '危险', emoji: '💀' }
  })
  
  // 免扰盾相关方法
  const earnShield = () => {
    if (shields.value < maxShields.value) {
      shields.value++
      return true
    }
    return false
  }
  
  const useShield = () => {
    if (shields.value > 0) {
      shields.value--
      shieldActive.value = true
      // 免扰盾持续2小时
      setTimeout(() => {
        shieldActive.value = false
      }, 2 * 60 * 60 * 1000)
      return true
    }
    return false
  }
  
  // 检查是否可以获得免扰盾
  // 连续3天健康分 >= 85 可获得1个免扰盾
  const consecutiveGoodDays = ref(0)
  
  watch(healthScore, (newScore) => {
    // 每日结束时检查（这里简化为分数变化时检查）
    if (newScore >= 85) {
      consecutiveGoodDays.value++
      if (consecutiveGoodDays.value >= 3) {
        if (earnShield()) {
          consecutiveGoodDays.value = 0
          // 触发通知
          console.log('🛡️ 恭喜！您获得了一个免扰盾')
        }
      }
    } else {
      consecutiveGoodDays.value = 0
    }
  })
  
  // 记录休息
  const recordRest = (completed = true) => {
    if (completed) {
      restCompleted.value++
      workDuration.value = 0  // 重置工作时长
    } else {
      restSnoozed.value++
    }
  }
  
  // 更新工作时长
  const updateWorkDuration = (minutes) => {
    workDuration.value = minutes
  }
  
  // 更新坐姿评分
  const updatePostureScore = (score) => {
    postureScore.value = Math.max(0, Math.min(100, score))
  }
  
  // 更新眨眼频率
  const updateBlinkRate = (rate) => {
    blinkRate.value = rate
  }
  
  // 重置每日数据
  const resetDaily = () => {
    restCompleted.value = 0
    restSnoozed.value = 0
    workDuration.value = 0
    postureScore.value = 100
    blinkRate.value = 15
  }
  
  return {
    // 评分数据
    healthScore,
    healthLevel,
    complianceScore,
    postureScore,
    blinkScore,
    durationScore,
    
    // 免扰盾
    shields,
    maxShields,
    shieldActive,
    useShield,
    earnShield,
    consecutiveGoodDays,
    
    // 方法
    recordRest,
    updateWorkDuration,
    updatePostureScore,
    updateBlinkRate,
    resetDaily,
    
    // 原始数据（用于调试）
    restCompleted,
    restSnoozed,
    blinkRate,
    workDuration,
  }
}
