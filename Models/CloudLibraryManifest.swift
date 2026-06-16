import Foundation

// MARK: - 云盘同步库 Manifest

struct CloudLibraryManifest: Codable {
    var schemaVersion: Int
    var libraryID: String
    var appName: String
    var createdAt: Date
    var updatedAt: Date
    var lastDeviceName: String
    var provider: CloudProvider
    var records: CloudLibraryRecordCounts

    static let currentSchemaVersion = 1
    static let appName = "Swallpaper"
    static let manifestFileName = "manifest.json"

    static func create(provider: CloudProvider) -> CloudLibraryManifest {
        CloudLibraryManifest(
            schemaVersion: currentSchemaVersion,
            libraryID: UUID().uuidString,
            appName: appName,
            createdAt: Date(),
            updatedAt: Date(),
            lastDeviceName: Host.current().localizedName ?? "Unknown Mac",
            provider: provider,
            records: CloudLibraryRecordCounts()
        )
    }

    /// manifest.json 的文件名
    static func manifestURL(in libraryURL: URL) -> URL {
        libraryURL.appendingPathComponent(manifestFileName, isDirectory: false)
    }
}

struct CloudLibraryRecordCounts: Codable {
    var wallpapers: Int = 0
    var media: Int = 0
    var favorites: Int = 0
    var downloads: Int = 0
}
