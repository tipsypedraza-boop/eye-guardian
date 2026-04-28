# 推送到 GitHub 指南

## 已排除的文件

以下大文件和临时文件已通过 `.gitignore` 排除：

- ✅ `go/` - Go 源码目录（约 500MB+）
- ✅ `md文件/` - 临时文档目录
- ✅ `node_modules/` - Node.js 依赖包
- ✅ `**/target/` - Rust 构建产物
- ✅ `**/dist/` - 前端构建产物
- ✅ `*.zip`, `*.exe`, `*.msi`, `*.deb` - 二进制文件

## 快速推送（推荐）

### Windows 用户：

```powershell
.\clean-and-push.ps1
```

### Linux/Mac 用户：

```bash
chmod +x clean-and-push.sh
./clean-and-push.sh
```

## 手动推送

### 1. 初始化 Git（如果还没有）

```bash
git init
git remote add origin https://github.com/tipsypedraza-boop/eye-guardian.git
```

### 2. 添加文件

```bash
git add .
```

### 3. 查看将要提交的文件

```bash
git status
```

确认没有大文件（如 go/、node_modules/ 等）

### 4. 提交

```bash
git commit -m "修复 GitHub Actions 并清理项目"
```

### 5. 推送到 GitHub

```bash
git branch -M main
git push -u origin main
```

### 6. 创建标签触发自动构建

```bash
git tag v1.3.0
git push origin v1.3.0
```

## 验证

推送后，访问：
- 仓库：https://github.com/tipsypedraza-boop/eye-guardian
- Actions：https://github.com/tipsypedraza-boop/eye-guardian/actions

## 项目结构（将上传的）

```
eye-guardian/
├── .github/
│   └── workflows/
│       └── build-release.yml    # GitHub Actions 配置
├── pc-client/
│   ├── src/                     # 源代码
│   ├── src-tauri/              # Tauri 配置
│   ├── package.json            # 依赖配置
│   └── vite.config.js          # Vite 配置
├── mobile-client/
│   ├── lib/                    # Flutter 源代码
│   └── pubspec.yaml            # Flutter 配置
├── server/
│   ├── main.go                 # Go 服务器
│   ├── handlers/               # 处理器
│   └── models/                 # 数据模型
├── .gitignore                  # Git 忽略规则
└── README.md                   # 项目说明
```

## 预计上传大小

约 5-10 MB（排除大文件后）

## 常见问题

### 推送失败：文件太大

如果仍然提示文件太大，检查：

```bash
# 查看将要提交的文件大小
git ls-files | xargs ls -lh

# 如果发现大文件，添加到 .gitignore
echo "大文件路径" >> .gitignore
git rm --cached 大文件路径
```

### 已经推送了大文件？

清理 Git 历史：

```bash
# 从历史中删除大文件
git filter-branch --force --index-filter \
  "git rm --cached --ignore-unmatch go/" \
  --prune-empty --tag-name-filter cat -- --all

# 强制推送
git push origin --force --all
```

### 需要更新远程仓库地址？

```bash
git remote set-url origin https://github.com/tipsypedraza-boop/eye-guardian.git
```
