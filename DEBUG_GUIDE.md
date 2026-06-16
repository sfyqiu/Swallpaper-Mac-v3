# Swallpaper-Mac-v2 调试指南

## 环境信息

- **仓库**: https://github.com/sfyqiu/Swallpaper-Mac-v2
- **本地路径**: `~/Desktop/Claude code项目/Swallpaper-Mac-v2-fresh/`
- **当前版本**: v1.3.29
- **分支**: main
- **编译方式**: GitHub Actions → Build DMG workflow (push main 自动触发)
- **平台**: macOS 14.0+, Swift 6.2
- **构建**: GitHub Actions (macos-15, xcodegen → xcodebuild → DMG → Release)

## 项目架构概览

```
Swallpaper-Mac-v2-fresh/
├── App/SwallpaperApp.swift          # 应用入口 + AppDelegate (窗口管理)
├── Services/
│   ├── NetworkService.swift         # 网络请求层 (actor, 重试, 代理, quickConnect)
│   ├── WallpaperSourceManager.swift # 壁纸源切换管理 (启动源选择)
│   ├── CloudLibrarySyncService.swift # 云盘同步库
│   ├── PexelsService.swift          # Pexels 照片+视频
│   ├── NASAService.swift            # NASA APOD
│   ├── CoverrService.swift          # Coverr 免费视频
│   ├── UnsplashService.swift        # Unsplash 照片
│   └── ...                          # 其他50+服务文件
├── ViewModels/
│   ├── SettingsViewModel.swift      # 设置页逻辑
│   └── ...
├── Views/
│   ├── SettingsView.swift           # 设置页 (侧边栏+内容区)
│   ├── ContentView.swift            # 主界面容器
│   └── ...
├── Models/Wallpaper.swift
├── VERSION                          # 版本号文件
└── .github/workflows/ci.yml        # CI (push main 自动触发)
```

---

## 一、设置窗口自动消失 (v1.3.22)

### 症状
打开设置界面，切换到其他应用（如 TextEdit）再回到 Swallpaper，设置窗口不见了，需要重新打开。

### 根因
**文件**: [App/SwallpaperApp.swift](App/SwallpaperApp.swift)

`AppDelegate.applicationShouldHandleReopen`（Dock 图标点击时触发）中无条件调用 `showMainWindow()`。
该方法内部执行 `window.makeKeyAndOrderFront(nil)`，强制把**主窗口**提到最前面并设为 key window，
把先前可见的设置窗口覆盖在了主窗口之下。

### 修复 (line 388)
```swift
@MainActor func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
    // 有可见窗口（如设置窗口）时不调 showMainWindow()，让 macOS 自行处理窗口排序
    if !flag {
        showMainWindow()
    }
    return true
}
```
- `hasVisibleWindows = true`（设置窗口可见）：跳过 `showMainWindow()`，macOS 自然把设置窗口置前
- `hasVisibleWindows = false`（无可见窗口）：正常显示主窗口

### 设置窗口架构
- 独立 NSWindow（非 sheet/popover），通过 `settingsWindowController`（NSWindowController）管理
- `isReleasedWhenClosed = false`（关闭只是隐藏，不释放窗口对象）
- 系统红绿灯关闭按钮隐藏，改用 SettingsView 内的自定义 X 按钮
- **没有设置 delegate**（`windowShouldClose` 只绑定到主窗口）
- 创造位置: `createAndShowSettingsWindow()` 第 708 行
- 关闭按钮回调: `(NSApp.keyWindow ?? NSApp.mainWindow)?.performClose(nil)`
- 窗口复用: `showSettingsWindow()` 先检查 `settingsWindowController?.window` 是否存在

### 调试要点
- 设置窗口关闭→只是隐藏，控制器和窗口对象仍存活
- `hideMainWindow()` 和 `releaseForegroundMemoryNow()` 都会检查设置窗口是否可见（可见则不隐藏 Dock 图标）
- 如果设置窗口可见但用户看不到，优先检查 `applicationShouldHandleReopen` 逻辑

---

## 二、API 连通性 + 启动慢 (v1.3.20)

### 症状
- 换新电脑后 API 测试全红、壁纸一直加载中
- 所有壁纸源"同时"加载慢

### 根因
1. `URLSession.configuration` 默认 `waitsForConnectivity = true`，GFW 下某些域名 TCP 被 RST/丢包，
   系统等待 30-60s 才超时，导致界面挂起
2. 启动源选择逻辑：检测到 VPN（utun 接口）就认为 Wallhaven 可达，
   但**分隧道 VPN** 只代理浏览器流量，不代理非浏览器请求

### 修复
1. **新增 `NetworkService.quickConnect()`** — [Services/NetworkService.swift](Services/NetworkService.swift)
   - 使用独立临时 URLSession，`waitsForConnectivity = false`，默认 8s 超时
   - 继承当前 session 的代理配置
   - 各 API 源的 `testConnection()` 全部改用 quickConnect
   - ⚠️ 临时 session 记得用 `invalidateAndCancel()` 释放（不是 `invalidate()`）

2. **启动源选择改进** — [Services/WallpaperSourceManager.swift](Services/WallpaperSourceManager.swift)
   - VPN 检测后不再直接认定 Wallhaven 可达
   - 改为实际调用 `quickConnect()` 验证 Wallhaven 是否通
   - 不通则回退到 4K Wallpapers（无需 API Key）

### 区分 VPN 慢 vs API 慢
- 所有源同时慢 → VPN 出口带宽瓶颈
- 关 VPN 后无需 Key 的源（4K、MotionBG）变快 → VPN 速度问题
- 个别源慢 → 该源 API/服务器问题

---

## 三、SwallpaperApp 生命周期关键方法

| 方法 | 触发时机 | 作用 |
|---|---|---|
| `applicationShouldHandleReopen` | 点击 Dock 图标 | 恢复窗口显示 |
| `showMainWindow()` | 主动调用 | 创建/显示主窗口，取消延迟释放 |
| `hideMainWindow()` | 点击关闭按钮 | orderOut 主窗口 |
| `releaseForegroundMemoryNow()` | 状态栏菜单释放内存 | 立即释放前台资源 |
| `releaseForegroundResourcesForHiddenWindow()` | hideMainWindow 内部 | post 通知、清缓存、`contentView = nil` |

### 窗口生命周期
- **主窗口隐藏**: `orderOut` → 150ms 延迟 → post `appDidHideWindow` → 再 150ms 延迟 → `contentView = nil`
- **主窗口恢复**: `showMainWindow()` 检测 `window?.contentView == nil` 时重新挂载 ContentView
- **延迟释放**: `delayedReleaseTask`（Task），可被 `showMainWindow()` 取消，避免隐藏/恢复竞争

### 通知
- `appDidHideWindow` — 主窗口隐藏后发出，观察者清理轻量级状态
- `appShouldReleaseForegroundMemory` — 释放前台内存前发出，各 View 监听后清缓存

---

## 四、调试流程

### 设置窗口不见了
1. 查 `applicationShouldHandleReopen` → `showMainWindow()` 是否无条件调用
2. 查 `hideMainWindow()` 的 `delayedReleaseTask` 是否意外影响设置窗口
3. 查 `releaseForegroundMemoryNow()` 是否被误触发

### API 不通 / 壁纸加载卡死
1. 打开设置 → API 连通性测试，看哪些源慢
2. 查对应 Service 的 `testConnection()` 是否用了 `quickConnect()`（不是原始 URLSession）
3. 查 GFW 环境 + VPN 分隧道策略
4. 查 `NetworkService` 的 `waitsForConnectivity` 设置

### 换新电脑首次启动
1. 查 `WallpaperSourceManager.performStartupSourceSelection()` 的 VPN 检测逻辑
2. 查 `quickCheckWallhaven()` 是否执行
3. 查 `pingGoogle()` 是否改用 `quickConnect()`

### 编译 / CI 失败
1. 查自家 Swift 版本是否匹配（Swift 6.2 / Xcode 26.4）
2. 查 `URLSession` API 变更（没有 `invalidate()`，用 `invalidateAndCancel()`）
3. CI 跳过 Build：检查 tag 是否已存在，需要 bump 版本或删 tag

---

## 五、关键文件速查

| 文件 | 主要职责 | 关键方法/属性 |
|---|---|---|
| [App/SwallpaperApp.swift](App/SwallpaperApp.swift) | AppDelegate、窗口管理 | `showMainWindow()`, `hideMainWindow()`, `showSettingsWindow()`, `applicationShouldHandleReopen`, `releaseForegroundMemoryNow()` |
| [Services/NetworkService.swift](Services/NetworkService.swift) | 网络请求（actor） | `quickConnect()`, `fetchData()`, `executeWithRetry()`, `updateProxyConfiguration()` |
| [Services/WallpaperSourceManager.swift](Services/WallpaperSourceManager.swift) | 壁纸源管理 | `performStartupSourceSelection()`, `quickCheckWallhaven()`, `pingGoogle()` |
| [Views/SettingsView.swift](Views/SettingsView.swift) | 设置界面 | `SettingsTab`, 各设置 Tab 子视图 |
| [ViewModels/SettingsViewModel.swift](ViewModels/SettingsViewModel.swift) | 设置逻辑 | `testAllAPIs()`, API key 存取 |
| [Views/ContentView.swift](Views/ContentView.swift) | 主界面容器 | `releaseForegroundMemory()`, `openSettingsWindow()`, `hideMainWindow()` |
| [project.yml](project.yml) | XcodeGen 配置 | 依赖、Bundle ID、部署目标 |
| [VERSION](VERSION) | 版本号 | CI 自动读此文件打 tag |

---

## 六、版本迭代规则

每次修改代码后:
1. 递增 [VERSION](VERSION) 文件中的版本号
2. `git add` + `git commit` + `git push`
3. CI 自动触发构建，生成 DMG Release
4. tag 已存在时 CI 跳过 Build，需 bump 版本或删旧 tag

## 回退指南
- **稳定版本 tag**: `v1.3.16-stable`
- **回退命令**: `git checkout v1.3.16-stable` 然后 bump 版本号 push
- 也可以直接 revert 到 commit `618c50a`

---

## 七、轮播刷新 / SFW 过滤 / 列表跳转修复 (v1.3.27 → v1.3.29)

### 7.1 轮播刷新按钮没有拿到新图

#### 症状
点击轮播刷新按钮（`arrow.clockwise`），图没有换成新的，看起来只是原地打乱了。

#### 根因
**文件**: [ViewModels/WallpaperViewModel.swift](ViewModels/WallpaperViewModel.swift)

`featuredFromMainSource()` 内部调用的是 `fetchWallpapers(parameters:)`，该方法会**根据 `sourceManager.activeSource` 调度请求**：

```swift
private func fetchWallpapers(parameters:) -> ... {
    switch sourceManager.activeSource {
    case .wallhaven:      → fetchFromWallhaven(parameters:)       ✅ 正确
    case .fourKWallpapers → fetchFromFallbackSource(.fourK, ...)  ❌ 丢失 categories 位掩码
    case .unsplash:       → fetchFromUnsplash(parameters:)        ❌ 3 个分类返回相同数据
    }
}
```

当活跃源不是 Wallhaven 时（例如 4K Wallpapers 或 Unsplash），3 个分类请求（general/anime/people）的 `categories: "100"/"010"/"001"` 位掩码会被丢弃或映射为相同结果，导致刷新无效。

#### 修复 (v1.3.28)
`featuredFromMainSource()` 改为直接调用 `fetchFromWallhaven(parameters:)`，**绕过源调度**：

```swift
async let general = fetchFromWallhaven(parameters: makeParams(categories: "100"))
async let anime = fetchFromWallhaven(parameters: makeParams(categories: "010"))
async let people = fetchFromWallhaven(parameters: makeParams(categories: "001"))
```

同时扩大随机范围：
- `topRange` 随机选项从 `[1d, 3d, 1w, 1M]` 增加为 `[1d, 3d, 1w, 1M, 3M]`
- `page` 从 `1...3` 扩大到 `1...5`

`refreshFeaturedForCarousel()` 仍然并行调用 4K Wallpapers 作为第二源混搭。

#### 调试要点
- 检查 `activeSource`：Settings → API 设置 → 当前数据源
- 如果活跃源不是 Wallhaven，`featuredFromMainSource()` 改`fetchFromWallhaven` 前会路由到错误的数据源
- 改后始终绕道直接调用 Wallhaven API，不依赖 `activeSource`

---

### 7.2 首页栏目内容没有过滤成人内容

#### 症状
轮播图已经限制为 SFW，但下面"最新壁纸"栏目仍出现 NSFW 壁纸。

#### 根因
**文件**: [Views/HomeContentView.swift](Views/HomeContentView.swift)

`reshuffleShelves()` 构造 `shuffledRecentWallpapers` 时没有客户端侧 SFW 过滤：

```swift
// ❌ 无客户端 SFW 过滤，只依赖 API 层的 purity: "100"
let latest = Array(viewModel.latestWallpapers.prefix(10))
```

API 层传递 `purity: "100"` 通常足够，但一旦 Wallhaven 返回异常数据（或 API 配置变化），没有兜底保护。

#### 修复 (v1.3.29)
在 `reshuffleShelves()` 中添加 `.filter { $0.purity.lowercased() == "sfw" }`：

```swift
let latest = Array(viewModel.latestWallpapers.prefix(10))
    .filter { $0.purity.lowercased() == "sfw" }
```

轮播图 `heroItems` 之前已有该过滤（v1.3.27），补全了 shelves 的缺失。

---

### 7.3 栏目标题带 "chevron.right" 图标但点不动

#### 症状
"最新壁纸"和"热门动态壁纸"栏目标题行有 `❯` 图标暗示可点击，但点上去没有任何反应。只有点击具体卡片才跳转。

#### 根因
**文件**: [Views/HomeContentView.swift](Views/HomeContentView.swift)

`HomeShelfSection` 和 `HomeMediaSection` 的标题行只是一个 `HStack` + `Text` + `Image`，**没有包裹 `Button`**，也没有 `onTapGesture`：

```swift
// ❌ 只是装饰性 UI，不可点击
HStack(spacing: 10) {
    Text(title)
    Image(systemName: "chevron.right")
    Spacer()
}
```

#### 修复 (v1.3.29)
- 为 `HomeShelfSection`、`HomeMediaSection` 添加 `var onNavigate: (() -> Void)?` 参数
- 将标题行包裹在 `Button` 中：

```swift
Button(action: { onNavigate?() }) {
    HStack(spacing: 10) {
        Text(title)
        Image(systemName: "chevron.right")
        Spacer()
    }
}
.buttonStyle(.plain)
```

- `contentSections` 中同时传递 `onNavigate`（标题行点击）和 `onSelect`（卡片点击）两个回调

---

### 7.4 代码签名 — 另一台 Mac 上 Gatekeeper 拦截

#### 症状
在另一台 Mac 上双击 DMG 挂载后打开 Swallpaper.app，提示"无法验证开发者"。

#### 根因
**文件**: [.github/workflows/ci.yml](.github/workflows/ci.yml)、[scripts/package.sh](scripts/package.sh)

当前 CI 和本地打包都使用 **ad-hoc 签名（`CODE_SIGN_IDENTITY="-"`）**，没有 Apple Developer ID 证书：

```bash
# ci.yml 中 archive/export 全部禁用签名
CODE_SIGN_IDENTITY="-"
CODE_SIGNING_REQUIRED=NO
CODE_SIGNING_ALLOWED=NO
```

`package.sh` 中的 `find_codesign_identity()` 试图查找 Developer ID 或 Apple Development 证书，但本地和 CI 均不存在，最终也使用 ad-hoc 签名。

#### 当前方案
在目标 Mac 上绕过 Gatekeeper：
1. 挂载 DMG 后 **不要双击** app
2. **右键点击** Swallpaper.app → 选择「打开」
3. 弹出确认对话框 → 点击「打开」
4. 或去「系统设置 → 隐私与安全性」→ 点击「仍要打开」

首次绕过后，后续使用不受影响。

#### 彻底解决方案（需要 $99 Apple Developer Program）
1. 创建 **Developer ID Application** 证书
2. 将证书导出为 `.p12`，base64 编码后存入 GitHub Secret `CERTIFICATE_BASE64`
3. 创建 **App Store Connect API Key** 用于 notarization
4. 在 CI 中添加 Keychain 导入 + notarytool 公证步骤

---

### 7.5 新 Mac 首次启动行为

#### API Key
- Wallhaven API Key 存储在本地 Keychain 中，**新 Mac 上不存在**
- 需要在 Settings → API Key 中重新输入
- 不填 API Key 也能正常浏览 SFW 壁纸（Wallhaven 允许公开访问 SFW）
- API Key 无效时测试显示红色 "API Key 无效 (401)"

#### 数据源自动降级
`WallpaperSourceManager.performStartupSourceSelection()` 在新 Mac 上执行：
1. 检测 VPN 是否启用
2. VPN 启用 → 验证 Wallhaven 实际可达性
3. VPN 未启用 → ping Google（5s 超时）
4. Wallhaven/Google 不可达 → 自动切换到 4K Wallpapers（无需 API Key，无需翻墙）

#### 调试流程
1. `testAllAPIs()` 在 Settings 中执行
2. 查看 `isInitialSourceSelectionComplete` 是否在 10s 内变为 true
3. 查看 `WallpaperSourceManager` 日志（Xcode 控制台）定位源选择决策

---

## 八、关键文件速查（更新）

| 文件 | 新增职责 | 关键方法/属性 |
|---|---|---|
| [ViewModels/WallpaperViewModel.swift](ViewModels/WallpaperViewModel.swift) | 轮播刷新 | `refreshFeaturedForCarousel()`, `featuredFromMainSource()` |
| [Views/HomeContentView.swift](Views/HomeContentView.swift) | 首页轮播、Shelf 跳转 | `shuffleCarousel()`, `reshuffleShelves()`, `heroItems`, `contentSections` |
| [scripts/package.sh](scripts/package.sh) | 打包 + 签名 | `find_codesign_identity()`, `sign_exported_app()` |

## 重要约束
- `SettingsViewModel` init 中不能读 `UserDefaults`（macOS 26 崩溃）
- 所有仓库引用必须指向 `sfyqiu/Swallpaper-Mac-v2`
- `UpdateChecker` 的 repo 和 apiURL 必须用 v2
