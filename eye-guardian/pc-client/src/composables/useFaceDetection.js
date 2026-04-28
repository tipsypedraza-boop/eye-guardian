import { ref, computed } from 'vue'

/**
 * 人脸检测与视距预警系统
 * 使用 MediaPipe Face Detection 或 TensorFlow.js FaceMesh
 */
export function useFaceDetection() {
  const enabled = ref(false)
  const cameraReady = ref(false)
  const faceDetected = ref(false)
  const distance = ref(0)              // 估算距离（cm）
  const isTooClose = ref(false)        // 是否距离过近
  const warningLevel = ref(0)          // 警告级别 0-3
  
  // 配置
  const SAFE_DISTANCE = 40             // 安全距离（cm）
  const WARNING_DISTANCE = 30          // 警告距离（cm）
  const DANGER_DISTANCE = 20           // 危险距离（cm）
  const CHECK_INTERVAL = 1000          // 检测间隔（ms）
  
  // 摄像头和检测相关
  let videoElement = null
  let stream = null
  let detectionInterval = null
  let faceDetector = null
  
  // 统计数据
  const stats = ref({
    totalChecks: 0,
    tooCloseCount: 0,
    averageDistance: 0,
    lastWarningTime: null,
  })
  
  // 警告级别描述
  const warningLevelDesc = computed(() => {
    switch (warningLevel.value) {
      case 0: return '距离安全'
      case 1: return '稍微靠近'
      case 2: return '距离过近'
      case 3: return '非常危险'
      default: return '未检测'
    }
  })
  
  // 初始化摄像头
  const initCamera = async () => {
    try {
      // 请求摄像头权限
      stream = await navigator.mediaDevices.getUserMedia({
        video: {
          width: { ideal: 640 },
          height: { ideal: 480 },
          facingMode: 'user',
        },
      })
      
      // 创建隐藏的 video 元素
      if (!videoElement) {
        videoElement = document.createElement('video')
        videoElement.style.display = 'none'
        videoElement.autoplay = true
        videoElement.playsInline = true
        document.body.appendChild(videoElement)
      }
      
      videoElement.srcObject = stream
      
      // 等待视频加载
      await new Promise((resolve) => {
        videoElement.onloadedmetadata = () => {
          videoElement.play()
          resolve()
        }
      })
      
      cameraReady.value = true
      console.log('📷 摄像头初始化成功')
      return true
    } catch (error) {
      console.error('摄像头初始化失败:', error)
      cameraReady.value = false
      return false
    }
  }
  
  // 初始化人脸检测器（使用简化版本）
  const initDetector = async () => {
    try {
      // 尝试使用 MediaPipe Face Detection
      if (typeof window.FaceDetection !== 'undefined') {
        faceDetector = new window.FaceDetection({
          locateFile: (file) => {
            return `https://cdn.jsdelivr.net/npm/@mediapipe/face_detection/${file}`
          },
        })
        
        faceDetector.setOptions({
          model: 'short',
          minDetectionConfidence: 0.5,
        })
        
        console.log('✅ MediaPipe Face Detection 已加载')
        return true
      }
      
      // 降级方案：使用简化的人脸检测
      console.log('⚠️ 使用简化人脸检测')
      return true
    } catch (error) {
      console.error('人脸检测器初始化失败:', error)
      return false
    }
  }
  
  // 估算人脸距离（基于人脸宽度）
  const estimateDistance = (faceWidth) => {
    // 假设平均人脸宽度为 14cm
    // 使用相似三角形原理：distance = (realWidth × focalLength) / pixelWidth
    // 简化公式：distance ≈ k / faceWidth
    const k = 8000 // 经验常数，需要根据实际摄像头校准
    return Math.round(k / faceWidth)
  }
  
  // 简化的人脸检测（使用 Canvas API）
  const detectFaceSimple = async () => {
    if (!videoElement || !cameraReady.value) return null
    
    try {
      // 创建 canvas 进行图像处理
      const canvas = document.createElement('canvas')
      const ctx = canvas.getContext('2d')
      canvas.width = videoElement.videoWidth
      canvas.height = videoElement.videoHeight
      
      // 绘制当前帧
      ctx.drawImage(videoElement, 0, 0)
      
      // 获取图像数据
      const imageData = ctx.getImageData(0, 0, canvas.width, canvas.height)
      
      // 简化检测：寻找肤色区域
      const skinPixels = detectSkinColor(imageData)
      
      if (skinPixels.length > 1000) {
        // 计算边界框
        const bounds = calculateBounds(skinPixels)
        const faceWidth = bounds.maxX - bounds.minX
        
        if (faceWidth > 50) { // 最小人脸宽度阈值
          return {
            detected: true,
            width: faceWidth,
            bounds,
          }
        }
      }
      
      return { detected: false }
    } catch (error) {
      console.error('人脸检测错误:', error)
      return null
    }
  }
  
  // 检测肤色像素
  const detectSkinColor = (imageData) => {
    const pixels = []
    const data = imageData.data
    
    for (let i = 0; i < data.length; i += 4) {
      const r = data[i]
      const g = data[i + 1]
      const b = data[i + 2]
      
      // 简化的肤色检测（YCbCr 色彩空间）
      if (isSkinColor(r, g, b)) {
        const x = (i / 4) % imageData.width
        const y = Math.floor(i / 4 / imageData.width)
        pixels.push({ x, y })
      }
    }
    
    return pixels
  }
  
  // 判断是否为肤色
  const isSkinColor = (r, g, b) => {
    // 简化的肤色判断规则
    return (
      r > 95 && g > 40 && b > 20 &&
      r > g && r > b &&
      Math.abs(r - g) > 15 &&
      r - Math.min(g, b) > 15
    )
  }
  
  // 计算边界框
  const calculateBounds = (pixels) => {
    let minX = Infinity, maxX = -Infinity
    let minY = Infinity, maxY = -Infinity
    
    pixels.forEach(({ x, y }) => {
      minX = Math.min(minX, x)
      maxX = Math.max(maxX, x)
      minY = Math.min(minY, y)
      maxY = Math.max(maxY, y)
    })
    
    return { minX, maxX, minY, maxY }
  }
  
  // 执行检测
  const performDetection = async () => {
    if (!enabled.value || !cameraReady.value) return
    
    const result = await detectFaceSimple()
    
    stats.value.totalChecks++
    
    if (result && result.detected) {
      faceDetected.value = true
      
      // 估算距离
      const estimatedDistance = estimateDistance(result.width)
      distance.value = estimatedDistance
      
      // 更新平均距离
      stats.value.averageDistance = Math.round(
        (stats.value.averageDistance * (stats.value.totalChecks - 1) + estimatedDistance) /
        stats.value.totalChecks
      )
      
      // 判断警告级别
      if (estimatedDistance < DANGER_DISTANCE) {
        warningLevel.value = 3
        isTooClose.value = true
        stats.value.tooCloseCount++
        stats.value.lastWarningTime = Date.now()
      } else if (estimatedDistance < WARNING_DISTANCE) {
        warningLevel.value = 2
        isTooClose.value = true
        stats.value.tooCloseCount++
        stats.value.lastWarningTime = Date.now()
      } else if (estimatedDistance < SAFE_DISTANCE) {
        warningLevel.value = 1
        isTooClose.value = false
      } else {
        warningLevel.value = 0
        isTooClose.value = false
      }
    } else {
      faceDetected.value = false
      warningLevel.value = 0
      isTooClose.value = false
    }
  }
  
  // 启动检测
  const startDetection = async () => {
    if (enabled.value) return
    
    // 初始化摄像头
    const cameraOk = await initCamera()
    if (!cameraOk) {
      console.error('无法启动摄像头')
      return false
    }
    
    // 初始化检测器
    await initDetector()
    
    // 开始定期检测
    enabled.value = true
    detectionInterval = setInterval(performDetection, CHECK_INTERVAL)
    
    console.log('👁️ 视距检测已启动')
    return true
  }
  
  // 停止检测
  const stopDetection = () => {
    enabled.value = false
    
    // 停止定时器
    if (detectionInterval) {
      clearInterval(detectionInterval)
      detectionInterval = null
    }
    
    // 关闭摄像头
    if (stream) {
      stream.getTracks().forEach(track => track.stop())
      stream = null
    }
    
    // 移除 video 元素
    if (videoElement) {
      videoElement.remove()
      videoElement = null
    }
    
    // 重置状态
    cameraReady.value = false
    faceDetected.value = false
    isTooClose.value = false
    warningLevel.value = 0
    
    console.log('👁️ 视距检测已停止')
  }
  
  // 切换检测
  const toggleDetection = async () => {
    if (enabled.value) {
      stopDetection()
    } else {
      await startDetection()
    }
  }
  
  // 重置统计
  const resetStats = () => {
    stats.value = {
      totalChecks: 0,
      tooCloseCount: 0,
      averageDistance: 0,
      lastWarningTime: null,
    }
  }
  
  // 获取依从性评分
  const getComplianceScore = () => {
    if (stats.value.totalChecks === 0) return 100
    const ratio = stats.value.tooCloseCount / stats.value.totalChecks
    return Math.round((1 - ratio) * 100)
  }
  
  return {
    // 状态
    enabled,
    cameraReady,
    faceDetected,
    distance,
    isTooClose,
    warningLevel,
    warningLevelDesc,
    stats,
    
    // 方法
    startDetection,
    stopDetection,
    toggleDetection,
    resetStats,
    getComplianceScore,
    
    // 配置
    SAFE_DISTANCE,
    WARNING_DISTANCE,
    DANGER_DISTANCE,
  }
}
