#!/bin/bash

# Eye Guardian - Linux DEB 打包脚本
# 适用于：统信UOS、银河麒麟、深度Deepin、Ubuntu、Debian 等

set -e

echo "=========================================="
echo "Eye Guardian - Linux DEB 打包"
echo "=========================================="
echo ""

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 检查是否在 Linux 系统上运行
if [[ "$OSTYPE" != "linux-gnu"* ]]; then
    echo -e "${RED}错误: 此脚本只能在 Linux 系统上运行${NC}"
    echo "如果你在 Windows 上，请使用 WSL2 或虚拟机"
    exit 1
fi

# 检查必要的依赖
echo -e "${YELLOW}[1/6] 检查系统依赖...${NC}"

check_command() {
    if ! command -v $1 &> /dev/null; then
        echo -e "${RED}错误: 未找到 $1${NC}"
        echo "请安装: sudo apt install $2"
        exit 1
    else
        echo -e "${GREEN}✓ $1 已安装${NC}"
    fi
}

check_command "node" "nodejs"
check_command "npm" "npm"
check_command "cargo" "cargo"
check_command "rustc" "rustc"

# 检查 Rust 版本
RUST_VERSION=$(rustc --version | awk '{print $2}')
echo -e "${GREEN}✓ Rust 版本: $RUST_VERSION${NC}"

# 安装系统依赖（如果需要）
echo ""
echo -e "${YELLOW}[2/6] 检查 Tauri 依赖...${NC}"

DEPS_NEEDED=false

# 检查必要的开发库
for pkg in libwebkit2gtk-4.0-dev build-essential curl wget file libssl-dev libgtk-3-dev libayatana-appindicator3-dev librsvg2-dev; do
    if ! dpkg -l | grep -q "^ii  $pkg"; then
        DEPS_NEEDED=true
        break
    fi
done

if [ "$DEPS_NEEDED" = true ]; then
    echo -e "${YELLOW}需要安装系统依赖，请输入 sudo 密码：${NC}"
    sudo apt update
    sudo apt install -y \
        libwebkit2gtk-4.0-dev \
        build-essential \
        curl \
        wget \
        file \
        libssl-dev \
        libgtk-3-dev \
        libayatana-appindicator3-dev \
        librsvg2-dev
    echo -e "${GREEN}✓ 系统依赖安装完成${NC}"
else
    echo -e "${GREEN}✓ 所有系统依赖已安装${NC}"
fi

# 安装 Node.js 依赖
echo ""
echo -e "${YELLOW}[3/6] 安装 Node.js 依赖...${NC}"
npm install
echo -e "${GREEN}✓ Node.js 依赖安装完成${NC}"

# 清理旧的构建文件
echo ""
echo -e "${YELLOW}[4/6] 清理旧的构建文件...${NC}"
rm -rf dist
rm -rf src-tauri/target/release/bundle
echo -e "${GREEN}✓ 清理完成${NC}"

# 构建前端
echo ""
echo -e "${YELLOW}[5/6] 构建前端资源...${NC}"
npm run build
echo -e "${GREEN}✓ 前端构建完成${NC}"

# 构建 DEB 包
echo ""
echo -e "${YELLOW}[6/6] 构建 DEB 安装包...${NC}"
npm run tauri build -- --bundles deb

# 检查构建结果
DEB_FILE=$(find src-tauri/target/release/bundle/deb -name "*.deb" 2>/dev/null | head -n 1)

if [ -f "$DEB_FILE" ]; then
    DEB_SIZE=$(du -h "$DEB_FILE" | cut -f1)
    echo ""
    echo -e "${GREEN}=========================================="
    echo "✓ DEB 包构建成功！"
    echo "==========================================${NC}"
    echo ""
    echo -e "${GREEN}安装包位置：${NC}"
    echo "  $DEB_FILE"
    echo ""
    echo -e "${GREEN}文件大小：${NC} $DEB_SIZE"
    echo ""
    echo -e "${YELLOW}安装方法：${NC}"
    echo "  sudo dpkg -i $DEB_FILE"
    echo ""
    echo -e "${YELLOW}或者双击 DEB 文件使用图形界面安装${NC}"
    echo ""
else
    echo -e "${RED}错误: 未找到生成的 DEB 包${NC}"
    exit 1
fi
