import Foundation

// MARK: - NASA APOD 模型

struct NASAAPODItem: Codable {
    let date: String
    let explanation: String?
    let title: String
    let url: String
    let hdurl: String?
    let mediaType: String
    let copyright: String?

    enum CodingKeys: String, CodingKey {
        case date, explanation, title, url, hdurl
        case mediaType = "media_type"
        case copyright
    }

    var isImage: Bool { mediaType == "image" }
}

// MARK: - NASA APOD 服务

@MainActor
final class NASAService: ObservableObject {
    static let shared = NASAService()
    private let baseURL = "https://api.nasa.gov/planetary/apod"

    private var apiKey: String {
        let key = UserDefaults.standard.string(forKey: "nasa_api_key") ?? ""
        return key.isEmpty ? "DEMO_KEY" : key
    }

    /// 获取今日天文图片
    func fetchToday() async throws -> Wallpaper? {
        let url = URL(string: "\(baseURL)?api_key=\(apiKey)")!
        let item: NASAAPODItem = try await fetch(url: url)
        guard item.isImage else { return nil }
        return convert(item)
    }

    /// 获取最近 N 天的天文图片
    func fetchRecent(count: Int = 10) async throws -> [Wallpaper] {
        let url = URL(string: "\(baseURL)?api_key=\(apiKey)&count=\(count)")!
        let items: [NASAAPODItem] = try await fetch(url: url)
        return items.filter(\.isImage).map { convert($0) }
    }

    /// 获取指定日期的图片
    func fetchByDate(_ dateString: String) async throws -> Wallpaper? {
        let url = URL(string: "\(baseURL)?api_key=\(apiKey)&date=\(dateString)")!
        let item: NASAAPODItem = try await fetch(url: url)
        guard item.isImage else { return nil }
        return convert(item)
    }

    // MARK: - API 连通性测试
    func testConnection() async -> (success: Bool, message: String) {
        guard let url = URL(string: "\(baseURL)?api_key=\(apiKey)") else {
            return (false, "Invalid URL")
        }
        let (success, _, message) = await NetworkService.shared.quickConnect(
            to: url,
            method: "GET",
            timeout: 10
        )
        if success {
            return (true, "NASA APOD API 连接成功")
        }
        return (false, "连接失败: \(message)")
    }

    private func fetchRaw<T: Codable>(url: URL) async throws -> T {
        var request = URLRequest(url: url)
        request.timeoutInterval = 10
        let data = try await NetworkService.shared.fetchData(request: request)
        return try JSONDecoder().decode(T.self, from: data)
    }

    private func fetch<T: Codable>(url: URL) async throws -> T {
        var request = URLRequest(url: url)
        request.timeoutInterval = 15
        let data = try await NetworkService.shared.fetchData(request: request)
        return try JSONDecoder().decode(T.self, from: data)
    }

    private func convert(_ item: NASAAPODItem) -> Wallpaper {
        let imageURL = item.hdurl ?? item.url
        return Wallpaper(
            id: "nasa-\(item.date)",
            url: imageURL,
            shortUrl: item.url,
            views: 0, favorites: 0, downloads: nil,
            source: "nasa",
            purity: "sfw", category: "general",
            dimensionX: 3840, dimensionY: 2160,
            resolution: "4K",
            ratio: "1.77",
            fileSize: nil, fileType: "jpg", createdAt: item.date, colors: [],
            path: imageURL,
            thumbs: Wallpaper.Thumbs(large: imageURL, original: imageURL, small: item.url),
            tags: [Wallpaper.Tag(id: 0, name: item.title, alias: nil)],
            uploader: nil
        )
    }
}

