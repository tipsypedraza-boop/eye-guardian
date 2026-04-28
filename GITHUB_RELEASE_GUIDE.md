# GitHub 自动构建和发布指南

## 问题已修复 ✅

已修复以下问题：
- ✅ 添加了 `tauri:build` 脚本到 package.json
- ✅ 更新了 GitHub Actions 工作流使用正确的脚本名称

## 如何触发自动构建

### 方法 1: 推送标签（推荐）

```bash
# 1. 提交所有更改
git add .
git commit -m "修复 GitHub Actions 构建配置"

# 2. 创建并推送标签
git tag v1.3.0
git push origin main
git push origin v1.3.0
```

### 方法 2: 手动触发

1. 访问你的 GitHub 仓库
2. 点击 "Actions" 标签
3. 选择 "Build and Release" 工作流
4. 点击 "Run workflow" 按钮
5. 选择分支（通常是 main）
6. 点击绿色的 "Run workflow" 按钮

## 构建产物

成功后会生成：
- **Windows**: `.msi` 和 `.exe` 安装包
- **Linux**: `.deb` 包
- **macOS**: `.dmg` 镜像

## 查看构建状态

1. 访问 GitHub 仓库的 Actions 页面
2. 查看最新的工作流运行
3. 如果失败，点击查看详细日志

## 常见问题

### 构建失败？

检查以下内容：
- ✅ 确保所有文件都已提交并推送
- ✅ 检查 Actions 日志中的错误信息
- ✅ 确认 `eye-guardian/pc-client/icons/` 目录中有所需的图标文件

### 没有看到 Release？

- 只有推送标签（如 v1.3.0）时才会创建 Release
- 手动触发只会生成 artifacts，不会创建 Release

### 如何下载构建产物？

1. 进入 Actions 页面
2. 点击成功的工作流运行
3. 滚动到底部的 "Artifacts" 部分
4. 下载需要的包

## 下一步

推送更改到 GitHub：

```bash
git add .
git commit -m "修复 GitHub Actions 构建配置"
git push origin main
```

然后创建标签触发发布：

```bash
git tag v1.3.0
git push origin v1.3.0
```
