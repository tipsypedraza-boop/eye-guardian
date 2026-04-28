# 护眼精灵 PC 客户端

> 智能护眼应用，守护您的视力健康

---

## 🚀 快速开始

### 开发环境运行

```bash
# 安装依赖
npm install

# 启动开发服务器
npm run dev

# 在浏览器中打开
# http://localhost:5173
```

### 构建生产版本

```bash
# 构建前端资源
npm run build

# 构建 Tauri 应用（需要 Rust 环境）
cd src-tauri
cargo tauri build
```

---

## 📦 打包 DEB 安装包

### 前置准备

1. **创建应用图标**

```bash
# Windows
python create-placeholder-icons.py
# 或双击运行 create-placeholder-icons.bat

# Linux
python3 create-placeholder-icons.py
```

2. **准备 Linux 环境**

- 使用 WSL2（Windows 用户推荐）
- 使用 Linux 虚拟机
- 使用真实 Linux 系统

### 构建步骤（Linux 环境）

```bash
# 1. 安装系统依赖（首次需要）
sudo apt update
sudo apt install -y libwebkit2gtk-4.0-dev build-essential curl wget \
  libssl-dev libgtk-3-dev libayatana-appindicator3-dev librsvg2-dev

# 2. 安装 Node.js（首次需要）
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt install -y nodejs

# 3. 安装 Rust（首次需要）
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
source $HOME/.cargo/env

# 4. 执行构建
chmod +x build-deb.sh
./build-deb.sh
```

### 构建产物

```
src-tauri/target/release/bundle/deb/eye-guardian_1.3.0_amd64.deb
```

---

## 📚 详细文档

- [下一步操作指南](../NEXT_STEPS.md) - 快速开始
- [构建指南](../BUILD_GUIDE.md) - 详细构建步骤
- [图标设置指南](../ICON_SETUP_GUIDE.md) - 图标创建方法
- [打包状态报告](../PACKAGING_STATUS.md) - 当前状态
- [功能总览](../COMPLETE_FEATURES_OVERVIEW.md) - 应用功能

---

## 🛠️ 技术栈

- **前端框架**：Vue 3 Composition API
- **构建工具**：Vite 5
- **桌面框架**：Tauri 1.5
- **语言**：JavaScript + Rust
- **样式**：CSS（莫兰迪配色 + 液态毛玻璃）
- **动画**：CSS + Canvas + WebGL
- **视觉检测**：MediaPipe / 图像处理
- **音效**：Web Audio API

---

## 📁 项目结构

```
pc-client/
├── src/                      # 前端源码
│   ├── components/           # Vue 组件
│   │   ├── PetView.vue      # 星星生命体
│   │   ├── BreakAlert.vue   # 休息提醒
│   │   ├── MicroBreak.vue   # 微休息
│   │   ├── ReportPanel.vue  # 健康报告
│   │   ├── DistanceWarning.vue  # 视距预警
│   │   ├── BlinkReminder.vue    # 眨眼提醒
│   │   └── ...
│   ├── composables/          # 组合式函数
│   │   ├── useHealthScore.js    # 健康评分
│   │   ├── useFaceDetection.js  # 人脸检测
│   │   ├── useBlinkDetection.js # 眨眼检测
│   │   ├── useFlowDetection.js  # 心流感知
│   │   └── ...
│   ├── App.vue              # 根组件
│   └── main.js              # 入口文件
├── src-tauri/               # Tauri 后端
│   ├── src/                 # Rust 源码
│   ├── icons/               # 应用图标
│   ├── tauri.conf.json      # Tauri 配置
│   └── Cargo.toml           # Rust 依赖
├── dist/                    # 构建产物
├── package.json             # 前端依赖
├── vite.config.js           # Vite 配置
├── build-deb.sh             # 构建脚本
├── create-placeholder-icons.py   # 图标生成器
└── README.md                # 本文档
```

---

## ✨ 核心功能

### 1. 数字生命体养成
- 星星生命体状态可视化
- 11 种动作动画
- 5 种粒子特效
- 音效系统

### 2. 智能定时提醒
- 20-20-20 微休息
- 长休息提醒
- 强制模式
- 心流感知

### 3. 健康监测
- 视距预警（摄像头）
- 眨眼频率检测
- 健康评分系统
- 可视化报告

### 4. 智能适配
- 沉浸模式降级
- 色温/亮度自适应
- 应用白名单

---

## 🎨 设计特色

- **莫兰迪配色**：柔和、护眼
- **液态毛玻璃**：现代、优雅
- **弹簧物理动效**：自然、流畅
- **WebGL 动态背景**：生动、有机

---

## 🔧 开发命令

```bash
# 安装依赖
npm install

# 开发模式
npm run dev

# 构建前端
npm run build

# 构建 Tauri 应用
npm run tauri build

# 开发模式（Tauri）
npm run tauri dev
```

---

## 📝 配置文件

- `package.json` - 前端依赖和脚本
- `vite.config.js` - Vite 构建配置
- `src-tauri/tauri.conf.json` - Tauri 应用配置
- `src-tauri/Cargo.toml` - Rust 依赖

---

## 🐛 常见问题

### Q: 开发服务器启动失败

**解决**：
```bash
# 删除 node_modules 重新安装
rm -rf node_modules package-lock.json
npm install
```

### Q: Tauri 构建失败

**解决**：
```bash
# 确保安装了 Rust
rustc --version

# 更新 Rust
rustup update stable

# 清理缓存重新构建
cd src-tauri
cargo clean
cargo tauri build
```

### Q: 摄像头无法访问

**解决**：
- 检查浏览器权限设置
- 确保摄像头未被其他应用占用
- 使用 HTTPS 或 localhost

---

## 📞 需要帮助？

- 查看 [详细文档](../NEXT_STEPS.md)
- 参考 [Tauri 官方文档](https://tauri.app/)
- 参考 [Vue 3 文档](https://vuejs.org/)

---

**版本**：v1.3.0  
**更新日期**：2026-04-27  
**作者**：Eye Guardian Team
