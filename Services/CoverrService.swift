import Foundation

// MARK: - Coverr API 模型

struct CoverrSearchResponse: Codable {
    let page: Int
    let pages: Int
    let pageSize: Int
    let total: Int
    let hits: [CoverrVideo]

    enum CodingKeys: String, CodingKey {
        case page, pages, total, hits
        case pageSize = "page_size"
    }
}

struct CoverrVideo: Codable {
    let id: String
    let title: String
    let description: String?
    let poster: String?
    let thumbnail: String?
    let tags: [String]?
    let duration: String
    let maxWidth: Int?
    let maxHeight: Int?
    let aspectRatio: String?
    let isVertical: Bool?
    let downloads: Int?
    let views: Int?
    let urls: CoverrVideoURLs?
    let createdAt: String?
    let publishedAt: String?

    enum CodingKeys: String, CodingKey {
        case id, title, description, poster, thumbnail, tags
        case duration, downloads, views, urls
        case maxWidth = "max_width"
        case maxHeight = "max_height"
        case aspectRatio = "aspect_ratio"
        case isVertical = "is_vertical"
        case createdAt = "created_at"
        case publishedAt = "published_at"
    }
}

struct CoverrVideoURLs: Codable {
    let mp4: String?
    let mp4Preview: String?
    let mp4Download: String?

    enum CodingKeys: String, CodingKey {
        case mp4
        case mp4Preview = "mp4_preview"
        case mp4Download = "mp4_download"
    }
}

// MARK: - Coverr 服务

/// Coverr Free Videos API
/// 免费高质量 CC0 视频
/// 注册获取 API Key: https://coverr.co/developers
@MainActor
final class CoverrService: ObservableObject {
    static let shared = CoverrService()
    private let baseURL = "https://api.coverr.co"

    private var apiKey: String {
        UserDefaults.standard.string(forKey: "coverr_api_key") ?? ""
    }

    private var isConfigured: Bool {
        !apiKey.isEmpty
    }

    /// 获取视频列表
    func fetchVideos(page: Int = 0, pageSize: Int = 20, sort: String = "popular", includeURLs: Bool = true) async throws -> [MediaItem] {
        var url = URL(string: "\(baseURL)/videos?page=\(page)&page_size=\(pageSize)&sort=\(sort)&api_key=\(apiKey)")!
        if includeURLs { url = URL(string: "\(baseURL)/videos?page=\(page)&page_size=\(pageSize)&sort=\(sort)&urls=true&api_key=\(apiKey)")! }
        let response: CoverrSearchResponse = try await fetch(url: url)
        return response.hits.map { convert($0) }
    }

    /// 搜索视频
    func search(query: String, page: Int = 0, pageSize: Int = 20, sort: String = "popular") async throws -> (items: [MediaItem], total: Int) {
        guard let encoded = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            return ([], 0)
        }
        let url = URL(string: "\(baseURL)/videos?query=\(encoded)&page=\(page)&page_size=\(pageSize)&sort=\(sort)&urls=true&api_key=\(apiKey)")!
        let response: CoverrSearchResponse = try await fetch(url: url)
        return (response.hits.map { convert($0) }, response.total)
    }

    /// 获取单个视频详情
    func getVideo(id: String) async throws -> MediaItem {
        let url = URL(string: "\(baseURL)/videos/\(id)?api_key=\(apiKey)")!
        let video: CoverrVideo = try await fetch(url: url)
        return convert(video)
    }

    // MARK: - API 连通性测试
    func testConnection() async -> (success: Bool, message: String) {
        guard let url = URL(string: "\(baseURL)/videos?page_size=1&api_key=\(apiKey)") else {
            return (false, "Invalid URL")
        }
        let (success, _, message) = await NetworkService.shared.quickConnect(
            to: url,
            method: "GET",
            timeout: 10
        )
        if success {
            return (true, "Coverr API 连接成功")
        }
        return (false, "连接失败: \(message)")
    }

    private func fetchRaw<T: Codable>(url: URL) async throws -> T {
        var request = URLRequest(url: url)
        request.timeoutInterval = 10
        let data = try await NetworkService.shared.fetchData(request: request)
        return try JSONDecoder().decode(T.self, from: data)
    }

    // MARK: - 通用请求

    private func fetch<T: Codable>(url: URL) async throws -> T {
        var request = URLRequest(url: url)
        request.timeoutInterval = 15
        let data = try await NetworkService.shared.fetchData(request: request)
        return try JSONDecoder().decode(T.self, from: data)
    }

    // MARK: - 转换为 MediaItem

    private func convert(_ video: CoverrVideo) -> MediaItem {
        let videoURL = video.urls?.mp4.flatMap { URL(string: $0) }
            ?? URL(string: "https://coverr.co")!
        let posterURL = video.poster.flatMap { URL(string: $0) }
            ?? video.thumbnail.flatMap { URL(string: $0) }

        let w = video.maxWidth ?? 1920
        let h = video.maxHeight ?? 1080
        let resolution = "\(w)x\(h)"

        return MediaItem(
            slug: "coverr-\(video.id)",
            title: video.title,
            pageURL: URL(string: "https://coverr.co/videos/\(video.id)")!,
            thumbnailURL: posterURL ?? videoURL,
            resolutionLabel: resolution,
            collectionTitle: "Coverr",
            summary: video.description,
            previewVideoURL: videoURL,
            posterURL: posterURL,
            tags: video.tags ?? [],
            exactResolution: resolution,
            durationSeconds: Double(video.duration) ?? 0,
            downloadOptions: [],
            sourceName: "Coverr",
            isAnimatedImage: nil
        )
    }
}
