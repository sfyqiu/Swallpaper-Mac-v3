import Foundation

// MARK: - Pexels API 模型

struct PexelsPhoto: Codable {
    let id: Int
    let width: Int
    let height: Int
    let url: String
    let photographer: String
    let photographerUrl: String
    let src: PexelsSource
    let alt: String?

    struct PexelsSource: Codable {
        let original: String
        let large2x: String
        let large: String
        let medium: String
        let small: String
        let portrait: String
        let landscape: String
        let tiny: String
    }
}

struct PexelsSearchResponse: Codable {
    let totalResults: Int
    let page: Int
    let perPage: Int
    let photos: [PexelsPhoto]
}

struct PexelsVideo: Codable {
    let id: Int
    let width: Int
    let height: Int
    let url: String
    let image: String?
    let duration: Int
    let videoFiles: [PexelsVideoFile]
    let videoPictures: [PexelsVideoPicture]

    struct PexelsVideoFile: Codable {
        let id: Int
        let quality: String
        let fileType: String
        let width: Int
        let height: Int
        let link: String
    }

    struct PexelsVideoPicture: Codable {
        let id: Int
        let picture: String
    }
}

struct PexelsVideoResponse: Codable {
    let totalResults: Int
    let page: Int
    let perPage: Int
    let videos: [PexelsVideo]
}

// MARK: - Pexels 服务

@MainActor
final class PexelsService: ObservableObject {
    static let shared = PexelsService()
    private let baseURL = "https://api.pexels.com"

    private var apiKey: String {
        UserDefaults.standard.string(forKey: "pexels_api_key") ?? "demo"
    }

    // MARK: - 照片

    func fetchCurated(page: Int = 1, perPage: Int = 30) async throws -> [Wallpaper] {
        let url = URL(string: "\(baseURL)/v1/curated?page=\(page)&per_page=\(perPage)")!
        let response: PexelsSearchResponse = try await fetch(url: url)
        return response.photos.map { convert($0) }
    }

    func searchPhotos(query: String, page: Int = 1, perPage: Int = 30) async throws -> (wallpapers: [Wallpaper], total: Int) {
        guard let encoded = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { return ([], 0) }
        let url = URL(string: "\(baseURL)/v1/search?query=\(encoded)&page=\(page)&per_page=\(perPage)")!
        let response: PexelsSearchResponse = try await fetch(url: url)
        return (response.photos.map { convert($0) }, response.totalResults)
    }

    // MARK: - 视频

    func fetchPopularVideos(page: Int = 1, perPage: Int = 20) async throws -> [MediaItem] {
        let url = URL(string: "\(baseURL)/videos/popular?page=\(page)&per_page=\(perPage)")!
        let response: PexelsVideoResponse = try await fetch(url: url)
        return response.videos.map { convertVideo($0) }
    }

    func searchVideos(query: String, page: Int = 1, perPage: Int = 20) async throws -> (items: [MediaItem], total: Int) {
        guard let encoded = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { return ([], 0) }
        let url = URL(string: "\(baseURL)/videos/search?query=\(encoded)&page=\(page)&per_page=\(perPage)")!
        let response: PexelsVideoResponse = try await fetch(url: url)
        return (response.videos.map { convertVideo($0) }, response.totalResults)
    }

    // MARK: - 通用

    /// API 连通性测试
    func testConnection() async -> (success: Bool, message: String) {
        guard let url = URL(string: "\(baseURL)/v1/curated?per_page=1") else {
            return (false, "Invalid URL")
        }
        let (success, _, message) = await NetworkService.shared.quickConnect(
            to: url,
            method: "GET",
            headers: ["Authorization": apiKey],
            timeout: 10
        )
        if success {
            return (true, "Pexels API 连接成功")
        }
        return (false, "连接失败: \(message)")
    }

    private func fetchRaw<T: Codable>(url: URL) async throws -> T {
        var request = URLRequest(url: url)
        request.setValue(apiKey, forHTTPHeaderField: "Authorization")
        request.timeoutInterval = 10
        let data = try await NetworkService.shared.fetchData(request: request)
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try decoder.decode(T.self, from: data)
    }

    private func fetch<T: Codable>(url: URL) async throws -> T {
        var request = URLRequest(url: url)
        request.setValue(apiKey, forHTTPHeaderField: "Authorization")
        request.timeoutInterval = 15
        let data = try await NetworkService.shared.fetchData(request: request)
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try decoder.decode(T.self, from: data)
    }

    private func convert(_ photo: PexelsPhoto) -> Wallpaper {
        let resolution = "\(photo.width)x\(photo.height)"
        let ratio = photo.height > 0 ? Double(photo.width) / Double(photo.height) : 1.77
        return Wallpaper(
            id: "pexels-\(photo.id)",
            url: photo.src.original,
            shortUrl: photo.src.large2x,
            views: 0, favorites: 0, downloads: nil,
            source: "pexels",
            purity: "sfw", category: "general",
            dimensionX: photo.width, dimensionY: photo.height,
            resolution: resolution,
            ratio: String(format: "%.2f", ratio),
            fileSize: nil, fileType: "jpg", createdAt: nil, colors: [],
            path: photo.src.original,
            thumbs: Wallpaper.Thumbs(large: photo.src.large, original: photo.src.original, small: photo.src.small),
            tags: nil, uploader: nil
        )
    }

    private func convertVideo(_ video: PexelsVideo) -> MediaItem {
        let bestFile = video.videoFiles
            .filter { $0.fileType == "video/mp4" }
            .sorted { ($0.width * $0.height) > ($1.width * $1.height) }
            .first
        let videoURL = bestFile.flatMap { URL(string: $0.link) } ?? URL(string: video.url)!
        let posterURL: URL = video.videoPictures.first.flatMap { URL(string: $0.picture) }
            ?? video.image.flatMap { URL(string: $0) }
            ?? URL(string: "https://images.pexels.com/lib/pexels-logo.png")!
        let resolution = bestFile.map { "\($0.width)x\($0.height)" } ?? "1920x1080"

        return MediaItem(
            slug: "pexels-video-\(video.id)",
            title: "Pexels Video",
            pageURL: URL(string: video.url)!,
            thumbnailURL: posterURL,
            resolutionLabel: resolution,
            collectionTitle: "Pexels",
            summary: nil,
            previewVideoURL: videoURL,
            posterURL: posterURL,
            tags: [],
            exactResolution: resolution,
            durationSeconds: Double(video.duration),
            downloadOptions: [],
            sourceName: "Pexels",
            isAnimatedImage: nil
        )
    }
}
