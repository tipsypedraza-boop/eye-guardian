import { ref } from 'vue'

/**
 * 声音特效系统
 * 使用 Web Audio API 生成简单音效
 */
export function useSoundEffects() {
  const enabled = ref(true)
  const volume = ref(0.3)
  
  let audioContext = null
  
  // 初始化音频上下文
  const initAudio = () => {
    if (!audioContext && typeof window !== 'undefined') {
      audioContext = new (window.AudioContext || window.webkitAudioContext)()
    }
    return audioContext
  }
  
  // 播放音调
  const playTone = (frequency, duration, type = 'sine') => {
    if (!enabled.value) return
    
    const ctx = initAudio()
    if (!ctx) return
    
    const oscillator = ctx.createOscillator()
    const gainNode = ctx.createGain()
    
    oscillator.connect(gainNode)
    gainNode.connect(ctx.destination)
    
    oscillator.frequency.value = frequency
    oscillator.type = type
    
    gainNode.gain.setValueAtTime(volume.value, ctx.currentTime)
    gainNode.gain.exponentialRampToValueAtTime(0.01, ctx.currentTime + duration)
    
    oscillator.start(ctx.currentTime)
    oscillator.stop(ctx.currentTime + duration)
  }
  
  // 预定义音效
  const sounds = {
    // 跳跃音效
    jump: () => {
      playTone(523.25, 0.1, 'sine') // C5
      setTimeout(() => playTone(659.25, 0.1, 'sine'), 50) // E5
    },
    
    // 旋转音效
    spin: () => {
      const notes = [261.63, 329.63, 392.00, 523.25] // C4, E4, G4, C5
      notes.forEach((freq, i) => {
        setTimeout(() => playTone(freq, 0.08, 'triangle'), i * 100)
      })
    },
    
    // 爱心音效
    love: () => {
      playTone(659.25, 0.15, 'sine') // E5
      setTimeout(() => playTone(783.99, 0.15, 'sine'), 100) // G5
      setTimeout(() => playTone(1046.50, 0.2, 'sine'), 200) // C6
    },
    
    // 兴奋音效
    excited: () => {
      const notes = [523.25, 587.33, 659.25, 783.99, 1046.50]
      notes.forEach((freq, i) => {
        setTimeout(() => playTone(freq, 0.1, 'square'), i * 80)
      })
    },
    
    // 摇晃音效（低沉）
    shake: () => {
      playTone(130.81, 0.2, 'sawtooth') // C3
    },
    
    // 睡觉音效
    sleep: () => {
      playTone(220.00, 0.3, 'sine') // A3
      setTimeout(() => playTone(196.00, 0.4, 'sine'), 200) // G3
    },
    
    // 挥手音效
    wave: () => {
      playTone(440.00, 0.1, 'sine') // A4
      setTimeout(() => playTone(493.88, 0.1, 'sine'), 80) // B4
    },
    
    // 弹跳音效
    bounce: () => {
      [392.00, 329.63, 392.00, 329.63].forEach((freq, i) => {
        setTimeout(() => playTone(freq, 0.08, 'triangle'), i * 120)
      })
    },
    
    // 跳舞音效
    dance: () => {
      const rhythm = [523.25, 587.33, 659.25, 587.33, 523.25, 659.25, 783.99, 659.25]
      rhythm.forEach((freq, i) => {
        setTimeout(() => playTone(freq, 0.12, 'square'), i * 150)
      })
    },
    
    // 思考音效
    think: () => {
      playTone(349.23, 0.15, 'sine') // F4
      setTimeout(() => playTone(329.63, 0.15, 'sine'), 300) // E4
    },
    
    // 奖励音效
    reward: () => {
      const notes = [523.25, 659.25, 783.99, 1046.50, 1318.51]
      notes.forEach((freq, i) => {
        setTimeout(() => playTone(freq, 0.15, 'sine'), i * 100)
      })
    },
  }
  
  // 播放音效
  const play = (soundName) => {
    if (!enabled.value) return
    const sound = sounds[soundName]
    if (sound) {
      try {
        sound()
      } catch (e) {
        console.warn('音效播放失败:', e)
      }
    }
  }
  
  // 设置音量
  const setVolume = (val) => {
    volume.value = Math.max(0, Math.min(1, val))
  }
  
  // 切换开关
  const toggle = () => {
    enabled.value = !enabled.value
  }
  
  return {
    enabled,
    volume,
    play,
    setVolume,
    toggle,
  }
}
