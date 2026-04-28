#!/bin/bash
# 清理并推送到 GitHub 的脚本

echo "=== Eye Guardian - 清理并推送到 GitHub ==="
echo ""

# 1. 检查 Git 状态
echo "1. 检查 Git 状态..."
git status

echo ""
echo "=== 将要排除的大文件/目录 ==="
echo "- go/ (Go 源码，约 500MB+)"
echo "- md文件/ (临时文档)"
echo "- node_modules/ (依赖包)"
echo "- **/target/ (Rust 构建产物)"
echo "- **/dist/ (前端构建产物)"
echo "- *.zip, *.exe, *.msi, *.deb (二进制文件)"
echo ""

# 2. 确认
read -p "是否继续？(y/n) " confirm
if [ "$confirm" != "y" ]; then
    echo "已取消"
    exit 1
fi

# 3. 添加所有文件（.gitignore 会自动排除）
echo ""
echo "2. 添加文件到 Git..."
git add .

# 4. 显示将要提交的文件
echo ""
echo "3. 将要提交的文件："
git status

# 5. 提交
echo ""
read -p "输入提交信息（默认：'修复 GitHub Actions 并清理项目'）: " commitMsg
if [ -z "$commitMsg" ]; then
    commitMsg="修复 GitHub Actions 并清理项目"
fi

echo ""
echo "4. 提交更改..."
git commit -m "$commitMsg"

# 6. 推送
echo ""
echo "5. 推送到 GitHub..."
git push origin main

echo ""
echo "=== 完成！==="
echo ""
echo "下一步：创建标签触发自动构建"
echo "  git tag v1.3.0"
echo "  git push origin v1.3.0"
echo ""
