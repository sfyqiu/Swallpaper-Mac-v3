import Foundation

// MARK: - 云盘提供商

enum CloudProvider: String, CaseIterable, Codable, Identifiable {
    case iCloudDrive
    case oneDrive
    case dropbox
    case googleDrive
    case nutstore
    case baiduNetdisk
    case custom

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .iCloudDrive: return "iCloud Drive"
        case .oneDrive: return "OneDrive"
        case .dropbox: return "Dropbox"
        case .googleDrive: return "Google Drive"
        case .nutstore: return "坚果云"
        case .baiduNetdisk: return "百度网盘"
        case .custom: return "自定义文件夹"
        }
    }

    var iconName: String {
        switch self {
        case .iCloudDrive: return "icloud.fill"
        case .oneDrive: return "externaldrive.fill.badge.icloud"
        case .dropbox: return "tray.full.fill"
        case .googleDrive: return "externaldrive.fill"
        case .nutstore: return "leaf.fill"
        case .baiduNetdisk: return "square.grid.3x3.fill"
        case .custom: return "folder.fill"
        }
    }

    var subtitle: String {
        switch self {
        case .iCloudDrive: return "macOS 系统自带"
        case .oneDrive: return "Microsoft 云存储"
        case .dropbox: return "老牌同步云盘"
        case .googleDrive: return "Google 云存储"
        case .nutstore: return "国内老牌同步盘"
        case .baiduNetdisk: return "百度网盘同步空间"
        case .custom: return "任意本机目录"
        }
    }

    /// 建议检测路径列表
    var suggestedPaths: [String] {
        switch self {
        case .iCloudDrive:
            return [
                "~/Library/Mobile Documents/com~apple~CloudDocs/"
            ]
        case .oneDrive:
            return [
                "~/Library/CloudStorage/OneDrive-*",
                "~/OneDrive"
            ]
        case .dropbox:
            return [
                "~/Library/CloudStorage/Dropbox/",
                "~/Dropbox"
            ]
        case .googleDrive:
            return [
                "~/Library/CloudStorage/GoogleDrive-*",
                "~/Google Drive"
            ]
        case .nutstore:
            return [
                "~/Nutstore Files",
                "~/坚果云",
                "~/Library/CloudStorage/Nutstore*"
            ]
        case .baiduNetdisk:
            return [
                "~/百度网盘",
                "~/BaiduNetdisk",
                "~/Library/CloudStorage/BaiduNetdisk*"
            ]
        case .custom:
            return []
        }
    }

    /// 检测云盘是否已安装/有本地目录
    func detectRootURL() -> URL? {
        let home = FileManager.default.homeDirectoryForCurrentUser

        for pattern in suggestedPaths {
            if pattern.contains("*") {
                // 通配符路径：扫描父目录下匹配项
                let parentPath = (pattern as NSString).deletingLastPathComponent
                    .replacingOccurrences(of: "~", with: home.path)
                let prefix = (pattern as NSString).lastPathComponent
                    .replacingOccurrences(of: "*", with: "")
                let parentURL = URL(fileURLWithPath: parentPath, isDirectory: true)
                if let contents = try? FileManager.default.contentsOfDirectory(atPath: parentURL.path) {
                    if let match = contents.first(where: { $0.hasPrefix(prefix) }) {
                        return parentURL.appendingPathComponent(match, isDirectory: true)
                    }
                }
            } else {
                let path = pattern.replacingOccurrences(of: "~", with: home.path)
                let url = URL(fileURLWithPath: path, isDirectory: true)
                var isDir: ObjCBool = false
                if FileManager.default.fileExists(atPath: url.path, isDirectory: &isDir), isDir.boolValue {
                    return url
                }
            }
        }
        return nil
    }
}

// MARK: - 检测结果

struct DetectedCloudProvider: Identifiable {
    let provider: CloudProvider
    let isDetected: Bool
    let detectedURL: URL?
    let suggestedPath: String

    var id: String { provider.rawValue }

    var statusText: String {
        isDetected ? "已检测" : "未检测到，请手动选择"
    }
}

// MARK: - 云盘检测工具

enum CloudProviderDetector {
    static func detectAll() -> [DetectedCloudProvider] {
        CloudProvider.allCases.map { provider in
            DetectedCloudProvider(
                provider: provider,
                isDetected: provider.detectRootURL() != nil,
                detectedURL: provider.detectRootURL(),
                suggestedPath: provider.suggestedPaths.first ?? ""
            )
        }
    }
}
