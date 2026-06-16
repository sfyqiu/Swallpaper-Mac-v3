# Swallpaper

<p align="center">
  <a href="README.md">🇨🇳 简体中文</a> | <a href="README.en.md">🇺🇸 English</a> | <a href="README.ja.md">🇯🇵 日本語</a>
</p>

<p align="center">
  <img src="Docs/logo.png" width="120" height="120" />
</p>

<p align="center">
  <samp>
    <b>macOS 开源 ACG 一站式应用</b><br>
    <b>静态壁纸 · 动态壁纸 · 动漫视频</b><br>
    <b>多源聚合，全场景覆盖</b>
  </samp>
</p>

<p align="center">
  <samp>
    基于 <a href="https://github.com/sfyqiu/WaifuX"><b>WaifuX</b></a> 深度二次开发<br>
    感谢原作者的开源贡献
  </samp>
</p>

<p align="center">
  <a href="https://github.com/sfyqiu/Swallpaper-Mac/releases">
    <img src="https://img.shields.io/github/v/release/sfyqiu/Swallpaper-Mac?color=6366f1&style=flat-square" alt="Release">
  </a>
  <a href="LICENSE">
    <img src="https://img.shields.io/badge/License-GPL--3.0-06b6d4?style=flat-square" alt="License">
  </a>
  <a href="https://github.com/sfyqiu/Swallpaper-Mac/stargazers">
    <img src="https://img.shields.io/github/stars/sfyqiu/Swallpaper-Mac?color=f59e0b&style=flat-square" alt="Stars">
  </a>
  <a href="https://github.com/sfyqiu/Swallpaper-Mac/forks">
    <img src="https://img.shields.io/github/forks/sfyqiu/Swallpaper-Mac?color=10b981&style=flat-square" alt="Forks">
  </a>
  <a href="https://github.com/sfyqiu/Swallpaper-Mac/releases">
    <img src="https://img.shields.io/github/downloads/sfyqiu/Swallpaper-Mac/total?color=8b5cf6&style=flat-square" alt="Downloads">
  </a>
  <a href="https://sfyqiu.github.io/Swallpaper-Mac">
    <img src="https://img.shields.io/badge/Website-🌐-ec4899?style=flat-square" alt="Website">
  </a>
</p>

---

## 📸 界面预览

<table width="100%">
  <tr>
    <td width="50%"><img src="screenshots/首页.png" width="100%" /><br><p align="center">首页 - 精选推荐</p></td>
    <td width="50%"><img src="screenshots/壁纸.png" width="100%" /><br><p align="center">壁纸浏览 - 多源聚合</p></td>
  </tr>
  <tr>
    <td width="50%"><img src="screenshots/动态壁纸.png" width="100%" /><br><p align="center">动态壁纸 · 视频 - 多源聚合</p></td>
    <td width="50%"><img src="screenshots/不同壁纸源api测试.png" width="100%" /><br><p align="center">API 连通性测试 - 多源管理</p></td>
  </tr>
  <tr>
    <td width="50%"><img src="screenshots/云盘同步.png" width="100%" /><br><p align="center">云盘同步库 - 多端共享</p></td>
    <td width="50%"><img src="screenshots/我的库壁纸.png" width="100%" /><br><p align="center">我的库 - 壁纸管理</p></td>
  </tr>
</table>

---

## ✨ 功能一览

| 功能 | 状态 | 说明 |
|------|:----:|------|
| 🖼 **多源壁纸** | ✅ | 6 大壁纸源：Wallhaven / 4K Wallpapers / Unsplash / Pexels / NASA APOD / NASA Images，4K/8K 全覆盖 |
| 🎬 **动态壁纸** | ✅ | MotionBG + Wallpaper Engine（场景/Web），让桌面"活"起来 |
| 🎥 **视频资源** | ✅ | Coverr / Pexels Videos / MotionBG / DongTai 多源视频聚合 |
| 📺 **动漫视频** | ✅ | 内置多源解析引擎，追番观影一站式完成 |
| ☁️ **云盘同步库** | ✅ | iCloud / OneDrive / Dropbox / Google Drive / 坚果云 / 百度网盘，自动/手动同步，批量迁移，原子切换 |
| 🔍 **智能搜索与筛选** | ✅ | 关键词、标签、分类、颜色、分辨率等多维度筛选 |
| ⭐ **收藏系统** | ✅ | 收藏喜欢的壁纸、视频，建立个人 ACG 资源库 |
| ⚡️ **一键设为桌面** | ✅ | 浏览中即可快速设置为桌面壁纸或动态桌面 |
| 🖱️ **详情页上下翻页** | ✅ | 打开壁纸详情后，滚动鼠标或按 ↑ ↓ 方向键快速切换上一张/下一张壁纸 |
| 🖥️ **多显示器支持** | ✅ | 支持为每个显示器分别设置不同壁纸，多屏用户福音 |
| 📥 **本地数据导入** | ✅ | 支持导入本地壁纸文件夹，统一管理个人壁纸收藏 |
| 🧪 **API 连通性测试** | ✅ | 一键并行测试所有 API 源连通性，快速诊断网络问题 |
| 🚀 **高性能缓存** | ✅ | Kingfisher 智能缓存（80MB 内存 / 500MB 磁盘）、并发下载、缩略图降采样 |
| 🎨 **界面优化** | ✅ | 暗色材质风格、一键切换壁纸源、分段选择器即时响应、自定义更换间隔 |
| 🧊 **Wallpaper Engine 渲染 (Beta)** | ✅ | 实验性兼容：**场景（Scene）** + **Web**（HTML/JS），内置渲染管线<br>⚠️ **仅支持 Apple Silicon（arm64），Intel 暂不支持** |
| 🔄 **规则自动更新** | ✅ | 通过 GitHub 远程加载规则配置，源站改版可快速适配 |

---

## 🖼 壁纸与视频源

Swallpaper 聚合了多个优质壁纸和视频源的公开 API，为用户提供丰富的内容选择。

### 壁纸源

| 源 | 类型 | 需要 API Key | Key 申请地址 |
|---|:---:|:---:|---|
| [Wallhaven](https://wallhaven.cc) | 壁纸 | 需要 | [wallhaven.cc/settings/account](https://wallhaven.cc/settings/account) |
| [4K Wallpapers](https://4kwallpapers.com) | 壁纸 | 无需 | — |
| [Unsplash](https://unsplash.com) | 壁纸 | 需要（demo 回退） | [unsplash.com/developers](https://unsplash.com/developers) |
| [Pexels](https://www.pexels.com) | 壁纸 + 视频 | 需要（demo 回退） | [pexels.com/api](https://www.pexels.com/api/) |
| [NASA APOD](https://apod.nasa.gov) | 天文每日图片 | 可选（DEMO_KEY） | [api.nasa.gov](https://api.nasa.gov/) |
| [NASA Images](https://images.nasa.gov) | 公开天文图片 | 无需 | — |

### 视频源

| 源 | 类型 | 需要 API Key | Key 申请地址 |
|---|:---:|:---:|---|
| [Coverr](https://coverr.co) | 免费 CC0 视频 | 需要 | [coverr.co/developers](https://coverr.co/developers) |
| [Pexels Videos](https://www.pexels.com) | 免费素材视频 | 需要 | [pexels.com/api](https://www.pexels.com/api/) |
| [MotionBG](https://motionbgs.com) | 动态壁纸 | 无需 | — |
| [Wallpaper Engine](https://store.steampowered.com/app/431960/Wallpaper_Engine/) | Workshop 动态壁纸 | 无需 | — |
| [DongTai](https://www.dongtai.com) | 动态壁纸 | 无需 | — |

> 💡 在「设置 → API Key」中输入对应的 Key 即可启用各源。可使用内置的 **API 连通性测试** 按钮一键验证所有 API 是否可达。

---

## ☁️ 云盘同步库

Swallpaper 支持将壁纸和视频库同步到主流云盘，在多台 Mac 之间无缝共享资源库。

### 支持的云盘

| 云盘 | 自动检测 |
|------|:---:|
| iCloud Drive | ✅ |
| OneDrive | ✅ |
| Dropbox | ✅ |
| Google Drive | ✅ |
| 坚果云 | ✅ |
| 百度网盘 | ✅ |
| 自定义路径 | ✅ |

### 核心功能

- **自动同步** — 下载的壁纸/视频自动写入云盘目录，任何设备都能即时访问
- **手动同步** — 下载到本地，手动触发迁移，适合流量有限的场景
- **批量迁移** — 一键将现有本地库全部迁移到云盘
- **新电脑导入** — 新设备上登录同一云盘，一键将云盘中的壁纸和视频导入到本地库，换机无忧
- **原子切换** — 切换云盘时无需先停用再启用，下载路径不会中断
- **错误弹窗** — 云盘不可用时主动弹窗提醒，而非静默失败

> 💡 在「设置 → 云盘同步」中配置和管理你的云同步库。

---

## 📥 安装

### 方式一：官网下载（推荐）

👉 **[https://sfyqiu.github.io/Swallpaper-Mac](https://sfyqiu.github.io/Swallpaper-Mac)**

### 方式二：GitHub Releases

👉 **[Releases](https://github.com/sfyqiu/Swallpaper-Mac/releases)**

### 方式三：Homebrew

```bash
brew tap sfyqiu/swallpaper
brew install --cask swallpaper
```

> ⚠️ 首次打开可能需要在「系统设置 → 隐私与安全性」中允许运行。

---

## 🌐 网络要求

> ⚠️ **中国大陆用户请注意**

Swallpaper 的主要数据源 [Wallhaven](https://wallhaven.cc) 托管在海外服务器，**在中国大陆地区直接访问可能存在网络问题**。如遇到无法加载内容的情况，请确保网络环境可以正常访问境外网站。

---

## 🛠 系统要求

- **macOS 14.0+**（Sonoma 及以上版本）
- 支持 **Apple Silicon（M 系列）** 和 **Intel** 芯片的 Mac

---

## 🔧 规则引擎

Swallpaper 采用动态规则机制，爬取逻辑与客户端分离：

- 规则托管于独立仓库：**[Swallpaper-Profiles](https://github.com/sfyqiu/Swallpaper-Mac-Profiles)**
- 应用启动时自动同步最新规则
- 支持用户自定义导入规则
- 源站页面结构调整时，仅需更新规则即可适配，无需发版

```
应用启动 → 检查规则更新 → 加载最新规则 → 正常使用
                ↑________________________|
                   （远程仓库更新后自动同步）
```

---

## 🌍 多语言支持

| 语言 | 状态 |
|------|:----:|
| 🇨🇳 简体中文 | ✅ 完整支持 |
| 🇺🇸 English | ✅ Full Support |
| 🇯🇵 日本語 | ✅ 完全対応 |

---

## ☕ 支持开源

Swallpaper 是一个**完全免费、开源**的个人项目。开发和维护一个 macOS 原生应用需要投入大量时间和精力——从界面设计到功能实现，从 Bug 修复到规则适配，每一个版本背后都是业余时间的持续投入。

如果你觉得 Swallpaper 对你有帮助，**给项目点个 Star ⭐️** 是对开发者最大的鼓励！

感谢使用 Swallpaper 💜

---

## 📄 开源协议

本项目基于 [GNU General Public License v3.0 (GPL-3.0)](LICENSE) 开源。

---

## ⚠️ 免责声明

### 1. 内容聚合声明
Swallpaper 本身**不存储、不托管任何内容**，仅作为第三方内容的聚合与展示工具：
- [Wallhaven](https://wallhaven.cc) 壁纸通过其公开 API 获取
- [MotionBGs](https://motionbgs.com) 内容由用户自行配置源地址
- 动漫视频解析源由用户自行提供与配置
- 所有内容的版权归原网站及原作者所有

### 2. Wallpaper Engine 兼容性声明（实验性 / Beta）
Swallpaper **并非 Wallpaper Engine 官方产品**，与 Valve Corporation、Kristjan Skutta / Wallpaper Engine 及其关联方**不存在任何官方合作、赞助或隶属关系**。应用内集成的 Wallpaper Engine 场景渲染功能属于**实验性第三方兼容实现**，基于用户自行拥有的 Workshop 内容或本地文件进行 OpenGL 渲染，仅供个人学习、研究与 interoperability（互操作性）目的使用。
- 用户**必须自行合法拥有** Wallpaper Engine 软件许可及相关 Workshop 内容的合法使用权
- 本应用不会、也无法验证用户是否拥有相应内容的合法授权
- 若用户未购买 Wallpaper Engine 或未获得内容授权，请**不要**使用本功能
- 因使用本功能产生的任何版权、许可或服务条款争议，**由用户自行承担全部法律责任**
- **本软件本身不包含任何 Wallpaper Engine 的版权数据、Workshop 内容、着色器、模型或纹理。** 所有渲染所需的素材均来源于用户自行提供的本地文件或 Workshop 订阅，本应用仅在运行时读取并渲染这些用户已有的数据

### 3. 第三方软件与素材声明
- 本应用包含对第三方专有格式（如 PKG）的结构解析，仅用于在 macOS 平台上实现互操作性
- 用户通过本应用加载、播放或展示的任何第三方素材（包括但不限于壁纸、视频、音频、模型、Shader），其合法性、版权归属及使用授权均由用户自行负责
- 开发者不对用户上传、导入或访问的任何第三方内容的合法性做任何担保

### 4. 使用限制
- 请严格遵守各内容平台的服务条款与最终用户许可协议（EULA）
- 禁止将本应用用于任何侵犯知识产权、传播非法内容或违反适用法律法规的行为
- 本应用仅供个人学习研究使用，**禁止商业性再分发或用于非法营利**

### 5. 责任限制
本应用按「**原样（AS IS）**」提供，开发者不对以下情形承担任何责任：
- 因网络波动、第三方服务变更、源站屏蔽等原因导致的内容无法加载
- 因用户设备配置、系统更新、驱动兼容性（特别是 OpenGL / GPU 驱动）导致的渲染异常、崩溃或硬件损坏
- 因用户违反当地法律法规或第三方服务条款而产生的任何法律纠纷、行政处罚或经济损失
- 因用户误操作、数据丢失或其他不可抗力导致的任何直接或间接损失

**使用本应用即表示您已充分理解并同意上述全部条款。如您不同意，请立即停止使用并卸载本应用。**

---

## 🌟 Star 历史

<p align="center">
  <img src="https://api.star-history.com/svg?repos=sfyqiu/Swallpaper-Mac&type=Date" alt="Star History Chart">
</p>

---

<p align="center">
  <samp>
    Made with 💜 by <a href="https://github.com/sfyqiu">@sfyqiu</a>
  </samp>
</p>

<p align="center">
  <a href="https://github.com/sfyqiu/Swallpaper-Mac/stargazers">
    <img src="https://img.shields.io/github/stars/sfyqiu/Swallpaper-Mac?style=social" alt="Stars">
  </a>
</p>
