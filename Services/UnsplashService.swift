import Foundation

// MARK: - Unsplash API 模型

struct UnsplashPhoto: Codable {
    let id: String
    let width: Int
    let height: Int
    let color: String?
    let description: String?
    let altDescription: String?
    let urls: UnsplashURLs
    let likes: Int
    let user: UnsplashUser

    struct UnsplashURLs: Codable {
        let raw: String
        let full: String
        let regular: String
        let small: String
        let thumb: String
    }

    struct UnsplashUser: Codable {
        let username: String
        let name: String?
    }
}

struct UnsplashSearchResponse: Codable {
    let total: Int
    let totalPages: Int
    let results: [UnsplashPhoto]
}

// MARK: - Unsplash 服务

@MainActor
final class UnsplashService: ObservableObject {
    static let shared = UnsplashService()

    private let baseURL = "https://api.unsplash.com"
    /// 免费 Access Key（Demo 级别，限速 50次/小时。用户可在设置中替换为自己的 Key）
    private var accessKey: String {
        UserDefaults.standard.string(forKey: "unsplash_access_key") ?? "demo"
    }

    private let pageSize = 30

    // MARK: - 获取照片列表

    func fetchPhotos(page: Int = 1) async throws -> [Wallpaper] {
        let url = URL(string: "\(baseURL)/photos?page=\(page)&per_page=\(pageSize)&order_by=latest")!
        let photos: [UnsplashPhoto] = try await fetch(url: url)
        return photos.map { convert($0) }
    }

    // MARK: - 搜索

    func search(query: String, page: Int = 1) async throws -> (wallpapers: [Wallpaper], total: Int) {
        guard let encoded = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            return ([], 0)
        }
        let url = URL(string: "\(baseURL)/search/photos?query=\(encoded)&page=\(page)&per_page=\(pageSize)")!
        let response: UnsplashSearchResponse = try await fetch(url: url)
        return (response.results.map { convert($0) }, response.total)
    }

    // MARK: - 分类浏览（用搜索模拟）

    func fetchByCategory(_ category: String, page: Int = 1) async throws -> (wallpapers: [Wallpaper], total: Int) {
        return try await search(query: category, page: page)
    }

    // MARK: - API 连通性测试
    func testConnection() async -> (success: Bool, message: String) {
        guard let url = URL(string: "\(baseURL)/photos?per_page=1") else {
            return (false, "Invalid URL")
        }
        let (success, _, message) = await NetworkService.shared.quickConnect(
            to: url,
            method: "GET",
            headers: ["Authorization": "Client-ID \(accessKey)", "Accept-Version": "v1"],
            timeout: 10
        )
        if success {
            return (true, "Unsplash API 连接成功")
        }
        return (false, "连接失败: \(message)")
    }

    private func fetchRaw<T: Codable>(url: URL) async throws -> T {
        var request = URLRequest(url: url)
        request.setValue("Client-ID \(accessKey)", forHTTPHeaderField: "Authorization")
        request.setValue("v1", forHTTPHeaderField: "Accept-Version")
        request.timeoutInterval = 10
        let data = try await NetworkService.shared.fetchData(request: request)
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try decoder.decode(T.self, from: data)
    }

    // MARK: - 通用请求

    private func fetch<T: Codable>(url: URL) async throws -> T {
        var request = URLRequest(url: url)
        request.setValue("Client-ID \(accessKey)", forHTTPHeaderField: "Authorization")
        request.setValue("v1", forHTTPHeaderField: "Accept-Version")
        request.timeoutInterval = 15
        let data = try await NetworkService.shared.fetchData(request: request)
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try decoder.decode(T.self, from: data)
    }

    // MARK: - 转换为 Wallpaper

    private func convert(_ photo: UnsplashPhoto) -> Wallpaper {
        let resolution = "\(photo.width)x\(photo.height)"
        let ratio = photo.height > 0 ? Double(photo.width) / Double(photo.height) : 1.77

        return Wallpaper(
            id: "unsplash-\(photo.id)",
            url: photo.urls.raw,
            shortUrl: photo.urls.full,
            views: photo.likes,
            favorites: 0,
            downloads: nil,
            source: "unsplash",
            purity: "sfw",
            category: "general",
            dimensionX: photo.width,
            dimensionY: photo.height,
            resolution: resolution,
            ratio: String(format: "%.2f", ratio),
            fileSize: nil,
            fileType: "jpg",
            createdAt: nil,
            colors: photo.color.map { [$0.replacingOccurrences(of: "#", with: "")] } ?? [],
            path: photo.urls.raw,
            thumbs: Wallpaper.Thumbs(
                large: photo.urls.regular,
                original: photo.urls.raw,
                small: photo.urls.small
            ),
            tags: nil,
            uploader: nil
        )
    }
}
