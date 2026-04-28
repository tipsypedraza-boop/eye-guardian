<template>
  <canvas ref="canvas" class="fluid-canvas" />
</template>

<script setup>
import { ref, onMounted, onUnmounted } from 'vue'

const canvas = ref(null)
let gl, program, buf, raf
let startTime = performance.now()

const VERT = `
attribute vec2 a_pos;
void main() { gl_Position = vec4(a_pos, 0.0, 1.0); }
`

const FRAG = `
precision highp float;
uniform vec2  u_res;
uniform float u_time;

// ── 工具函数 ──
vec2 hash2(vec2 p) {
  p = vec2(dot(p, vec2(127.1, 311.7)), dot(p, vec2(269.5, 183.3)));
  return fract(sin(p) * 43758.5453);
}

float smoothNoise(vec2 p) {
  vec2 i = floor(p), f = fract(p);
  vec2 u = f * f * (3.0 - 2.0 * f);
  float a = dot(hash2(i),              f);
  float b = dot(hash2(i + vec2(1,0)),  f - vec2(1,0));
  float c = dot(hash2(i + vec2(0,1)),  f - vec2(0,1));
  float d = dot(hash2(i + vec2(1,1)),  f - vec2(1,1));
  return mix(mix(a,b,u.x), mix(c,d,u.x), u.y);
}

float fbm(vec2 p) {
  float v = 0.0, a = 0.5;
  mat2 rot = mat2(0.8660, 0.5, -0.5, 0.8660);
  for (int i = 0; i < 4; i++) {
    v += a * smoothNoise(p);
    p  = rot * p * 2.1;
    a *= 0.48;
  }
  return v * 0.5 + 0.5;
}

// ── 莫兰迪浅色拼色调色板（6色） ──
// c0 极浅灰绿  #EAF0E6
// c1 雾霾蓝    #C8D8D4
// c2 藕粉      #F2C9C0
// c3 奶茶米    #EDE0D0
// c4 薰衣草灰  #D8D0E8
// c5 浅苔绿    #C8DBC8
vec3 palette(float t) {
  vec3 c0 = vec3(0.918, 0.941, 0.902);
  vec3 c1 = vec3(0.784, 0.847, 0.831);
  vec3 c2 = vec3(0.949, 0.788, 0.753);
  vec3 c3 = vec3(0.929, 0.878, 0.816);
  vec3 c4 = vec3(0.847, 0.816, 0.910);
  vec3 c5 = vec3(0.784, 0.859, 0.784);

  // 分段平滑插值，形成色块拼接感
  float s = t * 5.0;
  int   idx = int(floor(s));
  float frac = smoothstep(0.0, 1.0, fract(s));

  vec3 cols[6];
  cols[0] = c0; cols[1] = c1; cols[2] = c2;
  cols[3] = c3; cols[4] = c4; cols[5] = c5;

  vec3 from = cols[clamp(idx,   0, 5)];
  vec3 to   = cols[clamp(idx+1, 0, 5)];
  return mix(from, to, frac);
}

void main() {
  vec2 uv = gl_FragCoord.xy / u_res;
  // 保持宽高比
  vec2 st = uv;
  st.x *= u_res.x / u_res.y;

  float t = u_time * 0.10;

  // 第一层：大尺度色块分区（慢速流动）
  vec2 q1 = vec2(
    fbm(st * 1.2 + vec2(t * 0.3, 0.0)),
    fbm(st * 1.2 + vec2(0.0, t * 0.25))
  );

  // 第二层：中尺度扭曲（产生液化边界）
  vec2 q2 = vec2(
    fbm(st * 2.4 + 2.0 * q1 + vec2(1.7 + t * 0.18, 9.2)),
    fbm(st * 2.4 + 2.0 * q1 + vec2(8.3,             2.8 + t * 0.15))
  );

  // 第三层：细节扰动（边界羽化）
  float f = fbm(st * 3.0 + 3.0 * q2 + vec2(t * 0.12));

  // 用 f 值索引调色板，产生多色块拼色效果
  // 加入位置偏移让不同区域呈现不同颜色
  float colorIdx = f + length(q1) * 0.4 + q2.x * 0.3;
  colorIdx = fract(colorIdx * 0.85 + 0.1);

  vec3 col = palette(colorIdx);

  // 色块边界处轻微加深，强化拼色感
  float edge = abs(fract(colorIdx * 5.0) - 0.5) * 2.0;
  edge = smoothstep(0.6, 1.0, edge);
  col *= 1.0 - edge * 0.06;

  // 极轻暗角
  vec2 vd = uv - 0.5;
  float vign = 1.0 - dot(vd, vd) * 0.35;
  col *= vign;

  gl_FragColor = vec4(col, 1.0);
}
`

function compile(type, src) {
  const s = gl.createShader(type)
  gl.shaderSource(s, src)
  gl.compileShader(s)
  return s
}

function init() {
  const c = canvas.value
  gl = c.getContext('webgl', { antialias: false, powerPreference: 'low-power' })
  if (!gl) return

  program = gl.createProgram()
  gl.attachShader(program, compile(gl.VERTEX_SHADER, VERT))
  gl.attachShader(program, compile(gl.FRAGMENT_SHADER, FRAG))
  gl.linkProgram(program)
  gl.useProgram(program)

  // 全屏四边形
  buf = gl.createBuffer()
  gl.bindBuffer(gl.ARRAY_BUFFER, buf)
  gl.bufferData(gl.ARRAY_BUFFER,
    new Float32Array([-1,-1, 1,-1, -1,1, 1,1]), gl.STATIC_DRAW)

  const loc = gl.getAttribLocation(program, 'a_pos')
  gl.enableVertexAttribArray(loc)
  gl.vertexAttribPointer(loc, 2, gl.FLOAT, false, 0, 0)

  resize()
  render()
}

function resize() {
  const c = canvas.value
  if (!c) return
  c.width  = c.offsetWidth
  c.height = c.offsetHeight
  if (gl) gl.viewport(0, 0, c.width, c.height)
}

function render() {
  if (!gl || !canvas.value) return
  const t = (performance.now() - startTime) / 1000

  gl.uniform2f(gl.getUniformLocation(program, 'u_res'),
    canvas.value.width, canvas.value.height)
  gl.uniform1f(gl.getUniformLocation(program, 'u_time'), t)
  gl.drawArrays(gl.TRIANGLE_STRIP, 0, 4)

  raf = requestAnimationFrame(render)
}

const ro = new ResizeObserver(resize)

onMounted(() => {
  init()
  ro.observe(canvas.value)
})

onUnmounted(() => {
  cancelAnimationFrame(raf)
  ro.disconnect()
  if (gl) {
    gl.deleteProgram(program)
    gl.deleteBuffer(buf)
  }
})
</script>

<style scoped>
.fluid-canvas {
  position: fixed;
  inset: 0;
  width: 100%;
  height: 100%;
  z-index: 0;
  display: block;
}
</style>
