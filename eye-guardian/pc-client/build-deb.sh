#!/bin/bash

# 护眼精灵 - Linux DEB 打包脚本
# 适用于国产操作系统（统信UOS、麒麟等）

set -e

echo "🚀 开始构建护眼精灵 Linux DEB 安装包..."

# 颜色定义
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# 检查依赖
echo -e "${BLUE}📦 检查构建依赖...${NC}"

# 检查 Node.js
if ! command -v node &> /dev/null; then
    echo -e "${RED}❌ 未找到 Node.js，请先安装 Node.js${NC}"
    exit 1
fi

# 检查 npm
if ! command -v npm &> /dev/null; then
    echo -e "${RED}❌ 未找到 npm，请先安装 npm${NC}"
    exit 1
fi

# 检查 Rust
if ! command -v cargo &> /dev/null; then
    echo -e "${RED}❌ 未找到 Rust，请先安装 Rust${NC}"
    echo "安装命令: curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh"
    exit 1
fi

echo -e "${GREEN}✅ 依赖检查通过${NC}"

# 安装前端依赖
echo -e "${BLUE}📦 安装前端依赖...${NC}"
npm install

# 构建前端
echo -e "${BLUE}🔨 构建前端资源...${NC}"
npm run build

# 安装 Tauri CLI（如果未安装）
if ! command -v cargo-tauri &> /dev/null; then
    echo -e "${BLUE}📦 安装 Tauri CLI...${NC}"
    cargo install tauri-cli
fi

# 构建 Tauri 应用
echo -e "${BLUE}🔨 构建 Tauri 应用...${NC}"
cd src-tauri
cargo tauri build --target x86_64-unknown-linux-gnu

# 检查构建结果
if [ -f "target/release/bundle/deb/*.deb" ]; then
    echo -e "${GREEN}✅ DEB 包构建成功！${NC}"
    echo -e "${GREEN}📦 安装包位置: $(pwd)/target/release/bundle/deb/${NC}"
    ls -lh target/release/bundle/deb/*.deb
else
    echo -e "${RED}❌ DEB 包构建失败${NC}"
    exit 1
fi

# 显示安装包信息
echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}🎉 构建完成！${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${BLUE}安装方法：${NC}"
echo "  sudo dpkg -i target/release/bundle/deb/*.deb"
echo ""
echo -e "${BLUE}卸载方法：${NC}"
echo "  sudo apt remove eye-guardian"
echo ""
echo -e "${BLUE}支持的系统：${NC}"
echo "  - 统信 UOS"
echo "  - 银河麒麟"
echo "  - 深度 Deepin"
echo "  - Ubuntu / Debian 系列"
echo ""
