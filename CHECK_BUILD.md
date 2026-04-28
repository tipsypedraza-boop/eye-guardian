# ✅ 标签已推送！

## 构建状态

标签 **v1.3.0** 已成功推送到 GitHub，自动构建已触发。

### 查看构建进度

访问 GitHub Actions 页面：
https://github.com/tipsypedraza-boop/eye-guardian/actions

### 构建内容

GitHub Actions 正在构建：
- ✅ **Windows**: MSI 和 NSIS 安装包
- ✅ **Linux**: DEB 包
- ✅ **macOS**: DMG 镜像

### 预计时间

- Windows 构建：约 10-15 分钟
- Linux 构建：约 8-12 分钟
- macOS 构建：约 10-15 分钟
- **总计：约 30-40 分钟**

### 下载安装包

构建完成后，访问：
https://github.com/tipsypedraza-boop/eye-guardian/releases/tag/v1.3.0

## 下次创建新版本

使用便捷脚本：

```bash
.\create-release.bat
```

然后输入版本号（如 1.3.1），脚本会自动：
1. 创建标签 v1.3.1
2. 推送到 GitHub
3. 触发自动构建

## 手动创建标签

```bash
# 创建标签
git tag v1.3.1

# 推送标签
git push origin v1.3.1
```

## 常用链接

- **仓库**: https://github.com/tipsypedraza-boop/eye-guardian
- **Actions**: https://github.com/tipsypedraza-boop/eye-guardian/actions
- **Releases**: https://github.com/tipsypedraza-boop/eye-guardian/releases
- **当前版本**: https://github.com/tipsypedraza-boop/eye-guardian/releases/tag/v1.3.0

## 如果构建失败

1. 查看 Actions 日志找出错误
2. 修复代码后提交
3. 删除旧标签并重新创建：

```bash
# 删除本地标签
git tag -d v1.3.0

# 删除远程标签
git push origin :refs/tags/v1.3.0

# 重新创建并推送
git tag v1.3.0
git push origin v1.3.0
```

---

🎉 构建正在进行中，请耐心等待约 30-40 分钟！
