# Claude Handoff — Swallpaper-Mac-v2 调试交接

你接手的是 Swallpaper-Mac-v2 项目的调试工作。上一轮 Claude (Opus 4.7) 已经完成了第一轮问题诊断和修复，目前 v1.3.19 正在 GitHub Actions 编译。这份文档让你能无缝接手。

## 用户背景

- 用户在中国大陆，使用 VPN
- 项目是一个 macOS ACG 壁纸应用 (SwiftUI + AppKit)，基于 WaifuX 二次开发
- 用户在 GitHub Actions 上编译 DMG，在新电脑上测试
- **当前问题**: 新电脑安装后填入 API key，壁纸一直加载不出来

## 仓库信息

- **GitHub**: https://github.com/sfyqiu/Swallpaper-Mac-v2
- **本地路径**: `~/Desktop/Claude code项目/Swallpaper-Mac-v2-fresh/`
- **当前版本**: v1.3.19
- **分支**: main
- **GitHub Token**: 向用户索取，用户有一枚仅 repo 权限的 Personal Access Token。

## 首次接手步骤

```bash
cd ~/Desktop/Claude\ code项目/Swallpaper-Mac-v2-fresh
git pull origin main
cat VERSION  # 确认当前版本号
```

## 上一轮诊断的发现

### 问题 1: 壁纸加载时序问题（主要问题）

**根因**: App 启动时 `initialLoad()` 在用户输入 API key **之前**就执行了。Wallhaven 无 key 请求失败后，首页显示骨架屏 (HeroSkeletonView)。用户之后在设置中输入 key，但**没有任何机制触发重新加载**。

**加载链路**:
```
AppDelegate.restoreAllDataAsync()
  → WallpaperSourceManager.performStartupSourceSelection()
    → 检测 VPN (utun接口) → 保留 Wallhaven 源
  → ContentView.task 等待 isInitialSourceSelectionComplete
  → WallpaperViewModel.initialLoad()
    → search() + fetchFeaturedAndUpdate() ← 此时 API key 为空!
    → Wallhaven API 返回 401 → 静默失败
    → featuredWallpapers = [] → 首页显示骨架屏

用户打开设置 → 输入 API key → 保存成功 → 但无重触发!
```

**修复**: 
- 在 `DownloadPathManager.swift` 新增通知名 `wallpaperAPIKeyDidChange`
- `SettingsViewModel` 的 API key setter 发送此通知
- `WallpaperViewModel` 监听通知 → 自动调用 `refresh()` 重新加载

### 问题 2: API 连通性测试不含 Wallhaven

旧版 `testAllAPIs()` 只测 Unsplash/Pexels/Coverr/NASA。用户看到"全绿"但主源 Wallhaven 其实不可用。

**修复**: 新增 `testWallhavenConnection()` 方法，用 HEAD 请求测试 Wallhaven API，显示 API key 是否有效。

### 问题 3: 云盘同步只有上传，没有导入

用户设计云盘同步的初衷是换电脑后从云盘恢复壁纸。但旧版只有 upload (recordDownload, migrateCurrentLibrary)，缺少 cloud → local 的导入。

**修复**: 在 `CloudLibrarySyncService` 新增:
- `importMissingFromCloud()` — 扫描云盘 metadata，复制文件到本地下载目录，注册到 WallpaperLibraryService/MediaLibraryService
- `autoImportOnStartupIfNeeded()` — 启动时自动检测并导入
- 设置页新增「从云盘导入到本地」按钮
- 启用云盘时自动触发导入

### 尝试但回滚的修改

`waitsForConnectivity = false` — 本想解决 GFW 丢包时永久挂起的问题，但导致所有 API 测试变红。已回滚为 `true`。

### 编译错误修复

Wallpaper.fileSize 是 `Int?`，MediaItem.fileSize 是 `Int64?`，CloudLibraryRecord.fileSize 是 `Int64?`。 当初错误地对两者都做了 `.flatMap(Int.init)`，已在 v1.3.19 修复。

## 已修改的文件清单

| 文件 | 改动类型 |
|------|---------|
| `App/SwallpaperApp.swift` | 启动时触发云盘自动导入 |
| `Services/DownloadPathManager.swift` | 新增 `wallpaperAPIKeyDidChange` 通知名 |
| `Services/NetworkService.swift` | waitsForConnectivity 回滚 (保持 true) |
| `Services/CloudLibrarySyncService.swift` | 新增 ~200 行: importMissingFromCloud + 辅助方法 |
| `ViewModels/SettingsViewModel.swift` | API key 通知发送 + testWallhavenConnection + importFromCloud |
| `ViewModels/WallpaperViewModel.swift` | 监听 API key 变更通知 → 自动 refresh |
| `Views/SettingsView.swift` | 手动导入按钮 + 启用云盘后自动导入 |
| `VERSION` | 1.3.16 → 1.3.19 |

## 后续调试方向

如果测试后问题仍然存在，优先级排查:

1. **Wallhaven API 是否真的可达**: 让用户点「API 连通性测试」，看 Wallhaven 那一行是绿还是红。如果红，检查 VPN 是否真正全局代理（有些 VPN 只代理浏览器）。
2. **API key 格式**: Wallhaven API key 是 32 位字符串，确认没多复制空格。
3. **4K 回退源是否可用**: 关闭 VPN → 重启 App → 应该自动切到 4KWallpapers → 测试 `4kwallpapers.com` 在国内是否可达。
4. **云盘导入**: 确认旧电脑上云盘 metadata JSON 文件格式正确，新电脑上能读到。

## 编译和发布流程

每次修改代码后:
```bash
# 1. 递增版本号
echo "1.3.XX" > VERSION

# 2. 提交推送
git add <改动的文件> VERSION
git commit -m "fix: 描述修改内容"
git push origin main

# 3. 触发 DMG 编译
curl -X POST \
  -H "Authorization: token <GITHUB_TOKEN>" \
  -H "Accept: application/vnd.github+json" \
  "https://api.github.com/repos/sfyqiu/Swallpaper-Mac-v2/actions/workflows/build-dmg.yml/dispatches" \
  -d '{"ref":"main"}'

# 4. 监控编译状态 (替换 RUN_ID)
curl -s -H "Authorization: token <GITHUB_TOKEN>" \
  "https://api.github.com/repos/sfyqiu/Swallpaper-Mac-v2/actions/runs/<RUN_ID>" \
  | python3 -c "import json,sys; d=json.load(sys.stdin); print(d['status'],d['conclusion'])"

# 5. 如果编译失败，获取错误日志
curl -sL -H "Authorization: token <GITHUB_TOKEN>" \
  "https://api.github.com/repos/sfyqiu/Swallpaper-Mac-v2/actions/runs/<RUN_ID>/jobs" \
  | python3 -c "import json,sys; [print(j['id']) for j in json.load(sys.stdin)['jobs'] if j['conclusion']=='failure']"
# 拿到 JOB_ID 后:
curl -sL -H "Authorization: token <GITHUB_TOKEN>" \
  "https://api.github.com/repos/sfyqiu/Swallpaper-Mac-v2/actions/jobs/<JOB_ID>/logs" \
  -o /tmp/log.txt && grep "error:" /tmp/log.txt
```

## 用户偏好

- 用户要求版本号严格递增，每次修改都要 bump VERSION
- 用户在中国大陆，网络受限，需要 VPN 访问 GitHub 和 API
- 代码注释用中文，用户用中文交流
- 修改完成后主动推送并触发编译，不要让用户手动操作
- DMG 编译失败后要自动分析错误、修复、重新编译
