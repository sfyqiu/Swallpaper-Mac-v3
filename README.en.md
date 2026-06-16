# Swallpaper

<p align="center">
  <a href="README.md">🇨🇳 简体中文</a> | <a href="README.en.md">🇺🇸 English</a> | <a href="README.ja.md">🇯🇵 日本語</a>
</p>

<p align="center">
  <img src="Docs/logo.png" width="120" height="120" />
</p>

<p align="center">
  <samp>
    <b>Open Source All-in-One ACG App for macOS</b><br>
    <b>Static Wallpapers · Dynamic Wallpapers · Anime Videos</b><br>
    <b>Multi-source Aggregation, Full-scenario Coverage</b>
  </samp>
</p>

<p align="center">
  <samp>
    Deeply redeveloped from <a href="https://github.com/sfyqiu/WaifuX"><b>WaifuX</b></a><br>
    Thanks to the original author for the open-source contribution
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

## 📸 Preview

<table width="100%">
  <tr>
    <td width="50%"><img src="screenshots/首页.png" width="100%" /><br><p align="center">Home - Featured</p></td>
    <td width="50%"><img src="screenshots/壁纸.png" width="100%" /><br><p align="center">Wallpapers - Multi-source</p></td>
  </tr>
  <tr>
    <td width="50%"><img src="screenshots/动态壁纸.png" width="100%" /><br><p align="center">Live Wallpapers & Videos</p></td>
    <td width="50%"><img src="screenshots/不同壁纸源api测试.png" width="100%" /><br><p align="center">API Connectivity Test</p></td>
  </tr>
  <tr>
    <td width="50%"><img src="screenshots/云盘同步.png" width="100%" /><br><p align="center">Cloud Library Sync</p></td>
    <td width="50%"><img src="screenshots/我的库壁纸.png" width="100%" /><br><p align="center">My Library - Wallpapers</p></td>
  </tr>
</table>

---

## ✨ Features

| Feature | Status | Description |
|---------|:------:|-------------|
| 🖼 **Multi-source Wallpapers** | ✅ | 6 wallpaper sources: Wallhaven / 4K Wallpapers / Unsplash / Pexels / NASA APOD / NASA Images, full 4K/8K coverage |
| 🎬 **Dynamic Wallpapers** | ✅ | MotionBG + Wallpaper Engine (Scene/Web) — bring your desktop to life |
| 🎥 **Video Sources** | ✅ | Coverr / Pexels Videos / MotionBG / DongTai multi-source video aggregation |
| 📺 **Anime Videos** | ✅ | Built-in multi-source parsing engine for streaming and watching anime |
| ☁️ **Cloud Library Sync** | ✅ | iCloud / OneDrive / Dropbox / Google Drive / Nutstore / Baidu Netdisk, auto/manual sync, batch migration, atomic switching |
| 🔍 **Smart Search & Filter** | ✅ | Keywords, tags, categories, color, resolution — find exactly what you want |
| ⭐ **Collections** | ✅ | Save favorite wallpapers and videos to build your personal ACG library |
| ⚡️ **One-click Apply** | ✅ | Set as desktop wallpaper or dynamic desktop directly while browsing |
| 🖱️ **Detail View Navigation** | ✅ | In wallpaper detail view, scroll up/down or press ↑ ↓ arrow keys to quickly switch between wallpapers |
| 🖥️ **Multi-display Support** | ✅ | Set different wallpapers for each display — perfect for multi-monitor setups |
| 📥 **Local Data Import** | ✅ | Import local wallpaper folders for unified management of personal collections |
| 🧪 **API Connectivity Test** | ✅ | One-click parallel test of all API sources to quickly diagnose network issues |
| 🚀 **High-performance Cache** | ✅ | Kingfisher smart cache (80MB memory / 500MB disk), concurrent downloads, thumbnail downsampling |
| 🎨 **UI Refinements** | ✅ | Dark material style, one-click source cycling, instant segmented picker, custom change interval |
| 🧊 **Wallpaper Engine Rendering (Beta)** | ✅ | Experimental: **Scene** (OpenGL) + **Web** (HTML/JS) via built-in renderer<br>⚠️ **Apple Silicon (arm64) only; Intel not supported** |
| 🔄 **Auto-updating Rules** | ✅ | Rule configurations loaded remotely via GitHub — quick adaptation when source sites change |

---

## 🖼 Wallpaper & Video Sources

Swallpaper aggregates public APIs from multiple high-quality sources for a rich content experience.

### Wallpaper Sources

| Source | Type | API Key Required | Where to Get Key |
|---|:---:|:---:|---|
| [Wallhaven](https://wallhaven.cc) | Wallpaper | Required | [wallhaven.cc/settings/account](https://wallhaven.cc/settings/account) |
| [4K Wallpapers](https://4kwallpapers.com) | Wallpaper | Not required | — |
| [Unsplash](https://unsplash.com) | Wallpaper | Required (demo fallback) | [unsplash.com/developers](https://unsplash.com/developers) |
| [Pexels](https://www.pexels.com) | Photos + Videos | Required (demo fallback) | [pexels.com/api](https://www.pexels.com/api/) |
| [NASA APOD](https://apod.nasa.gov) | Astronomy Daily | Optional (DEMO_KEY) | [api.nasa.gov](https://api.nasa.gov/) |
| [NASA Images](https://images.nasa.gov) | Public Astronomy | Not required | — |

### Video Sources

| Source | Type | API Key Required | Where to Get Key |
|---|:---:|:---:|---|
| [Coverr](https://coverr.co) | Free CC0 Videos | Required | [coverr.co/developers](https://coverr.co/developers) |
| [Pexels Videos](https://www.pexels.com) | Free Stock Videos | Required | [pexels.com/api](https://www.pexels.com/api/) |
| [MotionBG](https://motionbgs.com) | Live Wallpapers | Not required | — |
| [Wallpaper Engine](https://store.steampowered.com/app/431960/Wallpaper_Engine/) | Workshop Wallpapers | Not required | — |
| [DongTai](https://www.dongtai.com) | Dynamic Wallpapers | Not required | — |

> 💡 Enter your API keys in "Settings → API Key" to enable each source. Use the built-in **API Connectivity Test** button to verify all APIs are reachable.

---

## ☁️ Cloud Library Sync

Swallpaper supports syncing your wallpaper and video library to major cloud drives, enabling seamless sharing across multiple Macs.

### Supported Cloud Drives

| Cloud Drive | Auto-detection |
|-------------|:---:|
| iCloud Drive | ✅ |
| OneDrive | ✅ |
| Dropbox | ✅ |
| Google Drive | ✅ |
| Nutstore | ✅ |
| Baidu Netdisk | ✅ |
| Custom Path | ✅ |

### Key Features

- **Auto Sync** — Downloads automatically go to cloud directory; all devices have instant access
- **Manual Sync** — Download locally, trigger migration manually — ideal for limited bandwidth
- **Batch Migration** — One-click migration of entire existing library to cloud
- **New Device Import** — Sign in to the same cloud drive on a new Mac, import all wallpapers and videos to local library with one click
- **Atomic Switching** — Switch cloud providers without disable/enable gaps; download paths stay uninterrupted
- **Error Alerts** — Active alert dialogs when cloud drive is unavailable, instead of silent failures

> 💡 Configure and manage your cloud sync library in "Settings → Cloud Sync".

---

## 📥 Installation

### Method 1: Official Website (Recommended)

👉 **[https://sfyqiu.github.io/Swallpaper-Mac](https://sfyqiu.github.io/Swallpaper-Mac)**

### Method 2: GitHub Releases

👉 **[Releases](https://github.com/sfyqiu/Swallpaper-Mac/releases)**

### Method 3: Homebrew

```bash
brew tap sfyqiu/swallpaper
brew install --cask swallpaper
```

> ⚠️ On first launch, you may need to allow execution in "System Settings → Privacy & Security".

---

## 🌐 Network Requirements

> ⚠️ **Note for users in mainland China**

Swallpaper's primary data source, [Wallhaven](https://wallhaven.cc), is hosted on overseas servers. **Direct access from mainland China may be affected by network restrictions.** If you experience issues loading content, please ensure your network can access international websites.

---

## 🛠 System Requirements

- **macOS 14.0+** (Sonoma or later)
- Supports both **Apple Silicon (M-series)** and **Intel** Macs

---

## 🔧 Rule Engine

Swallpaper uses a dynamic rule system with scraping logic decoupled from the client:

- Rules are hosted in a separate repository: **[Swallpaper-Profiles](https://github.com/sfyqiu/Swallpaper-Mac-Profiles)**
- Latest rules are automatically synced on app startup
- Supports custom user-imported rules
- When source site layouts change, only rules need updating — no app release required

```
App Launch → Check for Updates → Load Latest Rules → Ready to Use
                    ↑________________________|
                     (Auto-sync when remote repo updates)
```

---

## 🌍 Multi-language Support

| Language | Status |
|----------|:------:|
| 🇨🇳 简体中文 | ✅ Full Support |
| 🇺🇸 English | ✅ Full Support |
| 🇯🇵 日本語 | ✅ Full Support |

---

## ☕ Support Open Source

Swallpaper is a **completely free and open-source** personal project. Developing and maintaining a native macOS application requires significant time and effort — from UI design and feature implementation to bug fixes and rule adaptations, every version is built on continuous personal dedication.

If you find Swallpaper helpful, **giving a Star ⭐️** is the best way to support development!

Thank you for using Swallpaper 💜

---

## 📄 License

This project is open-sourced under the [GNU General Public License v3.0 (GPL-3.0)](LICENSE).

---

## ⚠️ Disclaimer

### 1. Content Aggregation
Swallpaper does **not store or host any content** itself — it acts solely as an aggregator and viewer for third-party content:
- [Wallhaven](https://wallhaven.cc) wallpapers are fetched via their public API
- [MotionBGs](https://motionbgs.com) content is configured by users themselves
- Anime video parsing sources are provided and configured by users
- All content copyrights belong to the original websites and authors

### 2. Wallpaper Engine Compatibility (Experimental / Beta)
Swallpaper is **NOT an official Wallpaper Engine product** and has **no official partnership, sponsorship, or affiliation** with Valve Corporation, Kristjan Skutta / Wallpaper Engine, or their associated entities. The integrated Wallpaper Engine scene rendering feature is an **experimental third-party compatibility implementation** that performs OpenGL rendering using Workshop content or local files which the user already owns, and is intended solely for personal study, research, and interoperability purposes.
- Users **must legally own** a valid Wallpaper Engine software license and the legal right to use any related Workshop content
- This application does not and cannot verify whether the user holds a legitimate license or authorization for any content
- If you have not purchased Wallpaper Engine or do not hold the necessary rights, **do not use this feature**
- Any copyright, licensing, or terms-of-service disputes arising from the use of this feature are the **sole responsibility of the user**
- **This software does not contain any copyrighted Wallpaper Engine data, Workshop content, shaders, models, or textures.** All rendering materials are sourced from local files or Workshop subscriptions provided by the user. This application only reads and renders such user-owned data at runtime

### 3. Third-Party Software and Assets
- This application contains structural parsers for certain proprietary formats (e.g., PKG) used solely to achieve interoperability on macOS
- The legality, copyright ownership, and usage authorization of any third-party assets (including but not limited to wallpapers, videos, audio, models, and shaders) loaded, played, or displayed through this application are the sole responsibility of the user
- The developer makes no guarantees regarding the legality of any third-party content uploaded, imported, or accessed by users

### 4. Usage Restrictions
- Please strictly comply with the terms of service and end-user license agreements (EULA) of all content platforms
- The use of this application for any intellectual property infringement, illegal content distribution, or violation of applicable laws and regulations is strictly prohibited
- This application is for personal study and research use only; **commercial redistribution or illegal profit-making is prohibited**

### 5. Limitation of Liability
This application is provided **"AS IS"**, and the developer assumes no liability for:
- Content loading failures caused by network fluctuations, third-party service changes, or source-site blocking
- Rendering anomalies, crashes, or hardware damage caused by user device configurations, system updates, or driver compatibility issues (particularly OpenGL / GPU drivers)
- Any legal disputes, administrative penalties, or economic losses arising from the user's violation of local laws, regulations, or third-party terms of service
- Any direct or indirect losses caused by user error, data loss, or other force majeure events

**By using this application, you acknowledge that you have fully read, understood, and agreed to all of the above terms. If you do not agree, please stop using and uninstall this application immediately.**

---

## 🌟 Star History

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
