#!/usr/bin/env python3
"""
护眼精灵 - 占位符图标生成器
用于快速生成测试用的图标文件
"""

try:
    from PIL import Image, ImageDraw, ImageFont
    PIL_AVAILABLE = True
except ImportError:
    PIL_AVAILABLE = False
    print("⚠️  未安装 Pillow 库")
    print("安装命令: pip install Pillow")
    print()

import os
import sys

# 配置
ICONS_DIR = "src-tauri/icons"
BG_COLOR = "#A9C2B6"  # 莫兰迪绿
TEXT_COLOR = "#FFFFFF"  # 白色
TEXT = "EG"  # Eye Guardian 缩写

# 图标尺寸配置
ICON_SIZES = [
    ("32x32.png", 32),
    ("128x128.png", 128),
    ("128x128@2x.png", 256),
]


def hex_to_rgb(hex_color):
    """将十六进制颜色转换为 RGB"""
    hex_color = hex_color.lstrip('#')
    return tuple(int(hex_color[i:i+2], 16) for i in (0, 2, 4))


def create_icon(size, filename):
    """创建单个图标"""
    # 创建图像
    img = Image.new('RGBA', (size, size), hex_to_rgb(BG_COLOR) + (255,))
    draw = ImageDraw.Draw(img)
    
    # 绘制圆形背景
    margin = size // 8
    draw.ellipse([margin, margin, size - margin, size - margin], 
                 fill=hex_to_rgb(BG_COLOR) + (255,))
    
    # 添加文字
    font_size = size // 3
    try:
        # 尝试使用系统字体
        font = ImageFont.truetype("arial.ttf", font_size)
    except:
        # 如果失败，使用默认字体
        font = ImageFont.load_default()
    
    # 计算文字位置（居中）
    bbox = draw.textbbox((0, 0), TEXT, font=font)
    text_width = bbox[2] - bbox[0]
    text_height = bbox[3] - bbox[1]
    x = (size - text_width) // 2
    y = (size - text_height) // 2 - bbox[1]
    
    # 绘制文字
    draw.text((x, y), TEXT, fill=hex_to_rgb(TEXT_COLOR) + (255,), font=font)
    
    # 保存图标
    filepath = os.path.join(ICONS_DIR, filename)
    img.save(filepath, 'PNG')
    print(f"✅ 已创建: {filepath} ({size}x{size})")


def create_simple_icon(size, filename):
    """创建简单的纯色图标（不依赖 PIL）"""
    # 创建一个简单的 SVG，然后提示用户转换
    svg_content = f'''<?xml version="1.0" encoding="UTF-8"?>
<svg width="{size}" height="{size}" xmlns="http://www.w3.org/2000/svg">
  <rect width="{size}" height="{size}" fill="{BG_COLOR}" rx="{size//8}"/>
  <text x="50%" y="50%" font-size="{size//3}" fill="{TEXT_COLOR}" 
        text-anchor="middle" dominant-baseline="central" 
        font-family="Arial, sans-serif" font-weight="bold">{TEXT}</text>
</svg>'''
    
    svg_filepath = os.path.join(ICONS_DIR, filename.replace('.png', '.svg'))
    with open(svg_filepath, 'w', encoding='utf-8') as f:
        f.write(svg_content)
    
    print(f"📄 已创建 SVG: {svg_filepath}")
    return svg_filepath


def main():
    """主函数"""
    print("🎨 护眼精灵 - 占位符图标生成器")
    print("=" * 50)
    print()
    
    # 检查目录
    if not os.path.exists(ICONS_DIR):
        print(f"📁 创建图标目录: {ICONS_DIR}")
        os.makedirs(ICONS_DIR, exist_ok=True)
    
    if not PIL_AVAILABLE:
        print("⚠️  由于未安装 Pillow，将创建 SVG 文件")
        print("请使用在线工具将 SVG 转换为 PNG：")
        print("  - https://cloudconvert.com/svg-to-png")
        print("  - https://www.aconvert.com/image/svg-to-png/")
        print()
        
        svg_files = []
        for filename, size in ICON_SIZES:
            svg_file = create_simple_icon(size, filename)
            svg_files.append(svg_file)
        
        print()
        print("📋 后续步骤：")
        print("1. 将上述 SVG 文件上传到在线转换工具")
        print("2. 转换为对应尺寸的 PNG 文件")
        print("3. 下载并重命名为正确的文件名")
        print("4. 放置到 src-tauri/icons/ 目录")
        
    else:
        # 使用 PIL 创建图标
        for filename, size in ICON_SIZES:
            create_icon(size, filename)
        
        print()
        print("✅ 所有图标已创建完成！")
        print()
        print("📋 下一步：")
        print("1. 查看生成的图标: src-tauri/icons/")
        print("2. 如需自定义，请使用设计软件编辑")
        print("3. 运行构建脚本: ./build-deb.sh")
    
    print()
    print("💡 提示：这些是临时占位符图标，建议后续替换为专业设计的图标")


if __name__ == "__main__":
    try:
        main()
    except Exception as e:
        print(f"❌ 错误: {e}")
        sys.exit(1)
