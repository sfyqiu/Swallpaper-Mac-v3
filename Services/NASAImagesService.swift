import Foundation

// MARK: - NASA Images API 模型

struct NASAImagesSearchResponse: Codable {
    let collection: NASAImagesCollection
}

struct NASAImagesCollection: Codable {
    let metadata: NASAImagesMetadata?
    let items: [NASAImagesItem]?
    let links: [NASAImagesPageLink]?
}

struct NASAImagesMetadata: Codable {
    let totalHits: Int

    enum CodingKeys: String, CodingKey {
        case totalHits = "total_hits"
    }
}

struct NASAImagesItem: Codable {
    let href: String
    let data: [NASAImageData]
    let links: [NASAImageLink]?
}

struct NASAImageData: Codable {
    let center: String?
    let title: String
    let nasaId: String
    let mediaType: String
    let keywords: [String]?
    let dateCreated: String?
    let description: String?
    let secondaryCreator: String?
    let album: [String]?
    let location: String?
    let description508: String?

    enum CodingKeys: String, CodingKey {
        case center, title, keywords, album, location, description
        case nasaId = "nasa_id"
        case mediaType = "media_type"
        case dateCreated = "date_created"
        case secondaryCreator = "secondary_creator"
        case description508 = "description_508"
    }
}

struct NASAImageLink: Codable {
    let href: String
    let rel: String?
    let render: String?
}

struct NASAImagesPageLink: Codable {
    let rel: String
    let href: String
    let prompt: String?
}

// MARK: - NASA Images 服务

/// images.nasa.gov 公开搜索 API
/// 无需 API Key，不限速
@MainActor
final class NASAImagesService: ObservableObject {
    static let shared = NASAImagesService()
    private let baseURL = "https://images-api.nasa.gov"
    private let imageCDN = "https://images-assets.nasa.gov/image"

    /// 搜索 NASA 图片
    /// - Parameters:
    ///   - query: 搜索关键词
    ///   - page: 页码（从1开始）
    ///   - pageSize: 每页数量（最大100）
    /// - Returns: (壁纸列表, 总结果数)
    func search(query: String, page: Int = 1, pageSize: Int = 30) async throws -> (wallpapers: [Wallpaper], total: Int) {
        guard let encoded = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            return ([], 0)
        }
        let url = URL(string: "\(baseURL)/search?q=\(encoded)&media_type=image&page=\(page)&page_size=\(pageSize)")!
        let response: NASAImagesSearchResponse = try await fetch(url: url)
        let images = response.collection.items?
            .filter { $0.data.first?.mediaType == "image" }
            .map { convert($0) } ?? []
        let total = response.collection.metadata?.totalHits ?? 0
        return (images, total)
    }

    /// 获取流行/推荐图片（使用搜索热门关键词）
    func fetchPopular(page: Int = 1) async throws -> [Wallpaper] {
        let queries = ["nebula", "galaxy", "planet", "moon", "mars", "sun", "space", "earth", "astronaut", "satellite"]
        let query = queries.randomElement() ?? "space"
        let (wallpapers, _) = try await search(query: query, page: page)
        return wallpapers
    }

    /// 按分类搜索
    func fetchByCategory(_ category: String, page: Int = 1) async throws -> (wallpapers: [Wallpaper], total: Int) {
        return try await search(query: category, page: page, pageSize: 30)
    }

    // MARK: - 通用请求

    private func fetch<T: Codable>(url: URL) async throws -> T {
        var request = URLRequest(url: url)
        request.timeoutInterval = 15
        let data = try await NetworkService.shared.fetchData(request: request)
        return try JSONDecoder().decode(T.self, from: data)
    }

    // MARK: - 转换为 Wallpaper

    private func convert(_ item: NASAImagesItem) -> Wallpaper {
        let info = item.data.first ?? NASAImageData(
            center: nil, title: "NASA Image", nasaId: "unknown",
            mediaType: "image", keywords: nil, dateCreated: nil,
            description: nil, secondaryCreator: nil, album: nil,
            location: nil, description508: nil
        )

        let nasaId = info.nasaId
        let previewURL = item.links?.first(where: { $0.rel == "preview" })?.href
            ?? item.links?.first?.href
            ?? "\(imageCDN)/\(nasaId)/\(nasaId)~thumb.jpg"

        // 构造原始大图 URL
        let origURL = "\(imageCDN)/\(nasaId)/\(nasaId)~orig.jpg"

        let createdAt = info.dateCreated.map { String($0.prefix(10)) }
        let ratio = 1.77 // NASA 图片比例多样，默认 16:9

        return Wallpaper(
            id: "nasa-images-\(nasaId)",
            url: origURL,
            shortUrl: origURL,
            views: 0, favorites: 0, downloads: nil,
            source: "nasa-images",
            purity: "sfw", category: "general",
            dimensionX: 3840, dimensionY: 2160,
            resolution: "4K",
            ratio: String(format: "%.2f", ratio),
            fileSize: nil, fileType: "jpg", createdAt: createdAt, colors: [],
            path: origURL,
            thumbs: Wallpaper.Thumbs(
                large: previewURL,
                original: origURL,
                small: previewURL
            ),
            tags: (info.keywords ?? []).prefix(10).map {
                Wallpaper.Tag(id: 0, name: $0, alias: nil)
            },
            uploader: nil
        )
    }
}
