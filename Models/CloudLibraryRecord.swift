import Foundation

// MARK: - 云盘记录类型

enum CloudLibraryItemKind: String, Codable, CaseIterable {
    case staticWallpaper
    case videoWallpaper
    case liveWallpaper
    case thumbnail
}

// MARK: - 云盘记录状态

enum CloudLibraryRecordStatus: String, Codable {
    case available
    case missing
    case needsDownload
    case needsRelink
}

// MARK: - 云盘库单条记录

struct CloudLibraryRecord: Codable, Identifiable {
    var id: String
    var kind: CloudLibraryItemKind
    var source: String
    var title: String?
    var remoteURL: String?
    var relativeFilePath: String
    var thumbnailPath: String?
    var createdAt: Date
    var updatedAt: Date
    var fileSize: Int64?
    var sha256: String?
    var status: CloudLibraryRecordStatus
}

// MARK: - 扫描结果

struct CloudLibraryScanResult {
    var totalRecords: Int
    var availableCount: Int
    var missingCount: Int
    var needsDownloadCount: Int
    var records: [CloudLibraryRecord]
    var manifest: CloudLibraryManifest

    static var empty: CloudLibraryScanResult {
        CloudLibraryScanResult(
            totalRecords: 0, availableCount: 0, missingCount: 0,
            needsDownloadCount: 0, records: [],
            manifest: CloudLibraryManifest.create(provider: .custom)
        )
    }
}

// MARK: - 同步模式

enum CloudSyncMode: String, Codable, CaseIterable {
    case auto = "auto"
    case manual = "manual"

    var displayName: String {
        switch self {
        case .auto: return "自动同步"
        case .manual: return "手动同步"
        }
    }

    var description: String {
        switch self {
        case .auto: return "新下载自动保存到云盘目录"
        case .manual: return "下载到本地，手动触发迁移"
        }
    }
}

// MARK: - 同步状态

enum CloudLibrarySyncStatus: Equatable {
    case disabled
    case ready
    case scanning
    case migrating
    case error(String)
}
