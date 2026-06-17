import Foundation
import SwiftSoup

// MARK: - Wallsflow 数据模型

struct WallsflowCategory: Hashable, Codable {
    let id: Int
    let name: String
    let slug: String
}

struct WallsflowListItem: Hashable, Codable {
    let id: String
    let title: String
    let detailURL: URL
    let categoryName: String
    let categorySlug: String?
    let posterURL: URL?
    let videoURL: URL?
    let rating: Int?
    let commentsCount: Int?
    let author: String?
    let authorURL: URL?
}

struct WallsflowDetail: Hashable, Codable {
    let id: String
    let title: String
    let canonicalURL: URL
    let description: String?
    let publishedAt: Date?
    let author: String?
    let authorURL: URL?
    let categoryName: String?
    let categorySlug: String?
    let posterURL: URL?
    let videoURL: URL?
    let tags: [String]
    let sourceName: String?
    let sourceURL: URL?
    let resolution: String?
    let width: Int?
    let height: Int?
    let fileSizeText: String?
    let fileSizeBytes: Int64?
    let rating: Int?
    let commentsCount: Int?
    let downloadURL: URL?
    let downloadId: String?
}

// MARK: - 分页结果

struct WallsflowListPage: Equatable {
    let items: [MediaItem]
    let nextPagePath: String?
    let totalPages: Int?
}

// MARK: - Wallsflow 分类定义

extension WallsflowCategory {
    static let allCategories: [WallsflowCategory] = [
        WallsflowCategory(id: 1,  name: "Live Wallpapers",           slug: "live-wallpapers"),
        WallsflowCategory(id: 28, name: "Winter Live Wallpapers",    slug: "winter"),
        WallsflowCategory(id: 2,  name: "Games Live Wallpapers",     slug: "games"),
        WallsflowCategory(id: 3,  name: "Cars Live Wallpapers",      slug: "cars"),
        WallsflowCategory(id: 4,  name: "Anime Live Wallpapers",     slug: "anime"),
        WallsflowCategory(id: 5,  name: "Minimalist Live Wallpapers",slug: "minimalist"),
        WallsflowCategory(id: 6,  name: "Graphics Live Wallpapers",  slug: "graphics"),
        WallsflowCategory(id: 7,  name: "Animals Live Wallpapers",   slug: "animals"),
        WallsflowCategory(id: 8,  name: "Nature Live Wallpapers",    slug: "nature"),
        WallsflowCategory(id: 9,  name: "Space Live Wallpapers",     slug: "space"),
        WallsflowCategory(id: 10, name: "Movies Live Wallpapers",    slug: "movies"),
        WallsflowCategory(id: 11, name: "People Live Wallpapers",    slug: "people"),
        WallsflowCategory(id: 12, name: "Pixel Art Live Wallpapers", slug: "pixel-art"),
        WallsflowCategory(id: 13, name: "Other Live Wallpapers",     slug: "other"),
    ]
}

// MARK: - Wallsflow 服务

/// Wallsflow.com 动态壁纸源服务
///
/// 通过 HTML 解析获取 wallsflow.com 的动态壁纸列表和详情。
/// 支持分类浏览、分页和搜索。
actor WallsflowService {
    static let shared = WallsflowService()

    private let networkService = NetworkService.shared
    private let baseURL = URL(string: "https://wallsflow.com")!

    // 简易内存缓存
    private var listCache: [String: WallsflowListPage] = [:]
    private var detailCache: [String: MediaItem] = [:]

    private let userAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.0 Safari/605.1.15"

    private var defaultHeaders: [String: String] {
        [
            "User-Agent": userAgent,
            "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
            "Accept-Language": "en-US,en;q=0.9",
            "Referer": "https://wallsflow.com/",
            "Cache-Control": "no-cache",
        ]
    }

    private init() {}

    // MARK: - 列表页获取

    /// 获取分类首页 / 最新列表
    func fetchCategory(slug: String, page: Int = 1) async throws -> WallsflowListPage {
        let url: URL
        if slug == "live-wallpapers" {
            if page <= 1 {
                url = baseURL.appendingPathComponent("live-wallpapers/")
            } else {
                url = baseURL.appendingPathComponent("live-wallpapers/page/\(page)/")
            }
        } else {
            if page <= 1 {
                url = baseURL.appendingPathComponent("live-wallpapers/\(slug)/")
            } else {
                url = baseURL.appendingPathComponent("live-wallpapers/\(slug)/page/\(page)/")
            }
        }

        let cacheKey = url.absoluteString
        if let cached = listCache[cacheKey] {
            return cached
        }

        let html = try await networkService.fetchString(from: url, headers: defaultHeaders)
        let page = try parseListPage(html: html, sourceURL: url)
        listCache[cacheKey] = page
        return page
    }

    /// 获取首页 / 最新内容
    func fetchHome(page: Int = 1) async throws -> WallsflowListPage {
        return try await fetchCategory(slug: "live-wallpapers", page: page)
    }

    // MARK: - 搜索

    /// 搜索动态壁纸
    func search(query: String, page: Int = 1) async throws -> WallsflowListPage {
        let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query
        let url = URL(string: "https://wallsflow.com/index.php?do=search&subaction=search&search_start=\(page)&full_search=0&result_from=\(1 + (page - 1) * 10)&story=\(encodedQuery)")!

        let cacheKey = url.absoluteString
        if let cached = listCache[cacheKey] {
            return cached
        }

        let html = try await networkService.fetchString(from: url, headers: defaultHeaders)
        let page = try parseListPage(html: html, sourceURL: url)
        listCache[cacheKey] = page
        return page
    }

    // MARK: - 详情页获取

    /// 获取详情页数据
    func fetchDetail(url detailURL: URL) async throws -> MediaItem {
        let cacheKey = detailURL.absoluteString
        if let cached = detailCache[cacheKey] {
            return cached
        }

        let html = try await networkService.fetchString(from: detailURL, headers: defaultHeaders)
        guard let item = try? parseDetailPage(html: html, pageURL: detailURL) else {
            throw WallsflowError.parseFailed("详情页解析失败")
        }
        detailCache[cacheKey] = item
        return item
    }

    /// 从列表项补全详情
    func enrichListItem(_ item: MediaItem) async throws -> MediaItem {
        if !item.downloadOptions.isEmpty || item.previewVideoURL != nil {
            return item
        }
        return try await fetchDetail(url: item.pageURL)
    }

    // MARK: - 清除缓存

    func clearCache() {
        listCache.removeAll()
        detailCache.removeAll()
    }
}

// MARK: - HTML 解析

private extension WallsflowService {

    func parseListPage(html: String, sourceURL: URL) throws -> WallsflowListPage {
        let document = try SwiftSoup.parse(html)
        let articleElements = try document.select("article.story")
        var items: [MediaItem] = []

        for article in articleElements {
            guard let item = try? parseListItem(article: article) else { continue }
            items.append(item)
        }

        let totalPages = parsePagination(document: document)
        let nextPagePath = parseNextPagePath(document: document, currentURL: sourceURL)

        return WallsflowListPage(
            items: items,
            nextPagePath: nextPagePath,
            totalPages: totalPages
        )
    }

    func parseListItem(article: Element) throws -> MediaItem? {
        let detailLink = try article.select("a[href*=\"/live-wallpapers/\"][href$=\".html\"]").first()
            ?? article.select("a[href*=\"\\.html\"]").first()
        guard let link = detailLink else { return nil }

        let href = try link.attr("href")
        let fullURL: URL
        if href.hasPrefix("http") {
            guard let url = URL(string: href) else { return nil }
            fullURL = url
        } else {
            fullURL = baseURL.appendingPathComponent(href.hasPrefix("/") ? String(href.dropFirst()) : href)
        }

        let id = extractID(from: href) ?? fullURL.lastPathComponent.replacingOccurrences(of: ".html", with: "")
        let title = try link.text().trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: " Live Wallpaper$", with: "", options: .regularExpression)

        let posterURL: URL? = {
            if let img = try? article.select("img[src*=\"cloud.wallsflow.com/posts/\"]").first(),
               let src = try? img.attr("src"),
               let url = URL(string: src) { return url }
            return nil
        }()

        let videoURL: URL? = {
            if let videoDiv = try? article.select("[data-video-src]").first(),
               let src = try? videoDiv.attr("data-video-src"),
               let url = URL(string: src) { return url }
            if let source = try? article.select("video source[data-src]").first(),
               let src = try? source.attr("data-src"),
               let url = URL(string: src) { return url }
            return nil
        }()

        let categoryName: String = {
            if let breadcrumb = try? article.select("a[href*=\"/live-wallpapers/\"][href$=\"/\"]").first(),
               let text = try? breadcrumb.text().trimmingCharacters(in: .whitespacesAndNewlines), !text.isEmpty {
                return text
            }
            return "Live Wallpapers"
        }()

        let rating: Int? = {
            if let ratingSpan = try? article.select("span[data-ratig-layer-id] .ratingtypeplusminus").first(),
               let text = try? ratingSpan.text().trimmingCharacters(in: .whitespacesAndNewlines),
               let value = Int(text) { return value }
            return nil
        }()

        let author: String? = {
            if let img = try? article.select("img[title^=\"Author:\"]").first(),
               let title = try? img.attr("title") {
                return title.replacingOccurrences(of: "Author: ", with: "")
            }
            return nil
        }()

        let slug = "wf_\(id)"
        let sourceNameValue = t("wallsflow")

        var downloadOptions: [MediaDownloadOption] = []
        if let videoURL {
            let option = MediaDownloadOption(
                label: "Original",
                fileSizeLabel: "",
                detailText: "Original MP4",
                remoteURL: videoURL
            )
            downloadOptions = [option]
        }

        return MediaItem(
            slug: slug,
            title: title,
            pageURL: fullURL,
            thumbnailURL: posterURL ?? fullURL,
            resolutionLabel: "动态壁纸",
            collectionTitle: categoryName,
            summary: nil,
            previewVideoURL: videoURL,
            posterURL: posterURL,
            tags: [categoryName].compactMap { $0 },
            exactResolution: nil,
            durationSeconds: nil,
            downloadOptions: downloadOptions,
            sourceName: sourceNameValue,
            isAnimatedImage: false,
            subscriptionCount: nil,
            favoriteCount: nil,
            viewCount: nil,
            ratingScore: rating.map(Double.init),
            authorName: author,
            authorSteamID: nil,
            authorAvatarURL: nil,
            fileSize: nil,
            createdAt: nil,
            updatedAt: nil
        )
    }

    func parsePagination(document: Document) -> Int? {
        guard let pagesDiv = try? document.select("div.pages").first() else { return nil }
        let links = try? pagesDiv.select("a")
        guard let linkElements = links else { return nil }
        var maxPage = 1
        for link in linkElements {
            if let text = try? link.text(), let num = Int(text) {
                maxPage = max(maxPage, num)
            }
        }
        return maxPage > 1 ? maxPage : nil
    }

    func parseNextPagePath(document: Document, currentURL: URL) -> String? {
        if let nextLink = try? document.select("span.page_next a").first(),
           let href = try? nextLink.attr("href"), !href.isEmpty {
            return href
        }
        guard let pagesDiv = try? document.select("div.pages").first() else { return nil }
        let links = try? pagesDiv.select("a")
        guard let linkElements = links, !linkElements.isEmpty else { return nil }
        let currentBaseName = currentURL.lastPathComponent
        let currentPage: Int
        if currentBaseName == "live-wallpapers" || currentBaseName == "" || currentBaseName.hasSuffix("/") {
            currentPage = 1
        } else if let pageNum = Int(currentBaseName.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)) {
            currentPage = pageNum
        } else {
            currentPage = 1
        }
        var maxPage = 1
        for link in linkElements {
            if let text = try? link.text(), let num = Int(text) {
                maxPage = max(maxPage, num)
            }
        }
        if currentPage < maxPage {
            let nextPage = currentPage + 1
            var nextURL = currentURL
            if currentBaseName.hasPrefix("page/") || currentBaseName.contains("page") {
                let parent = currentURL.deletingLastPathComponent()
                nextURL = parent.appendingPathComponent("page/\(nextPage)/")
            } else {
                nextURL = currentURL.appendingPathComponent("page/\(nextPage)/")
            }
            return nextURL.absoluteString
        }
        return nil
    }

    func parseDetailPage(html: String, pageURL: URL) throws -> MediaItem? {
        let document = try SwiftSoup.parse(html)
        if let item = try parseDetailPageJSONLD(document: document, pageURL: pageURL) {
            return item
        }
        return try parseDetailPageDOM(document: document, pageURL: pageURL)
    }

    func parseDetailPageJSONLD(document: Document, pageURL: URL) throws -> MediaItem? {
        guard let ldScript = try? document.select("script[type=\"application/ld+json\"]").first(),
              let jsonText = try? ldScript.html(),
              let data = jsonText.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else { return nil }

        let graph = json["@graph"] as? [[String: Any]] ?? (json["@graph"] == nil ? [json] : nil)
        guard let graphArray = graph else { return nil }
        guard let article = graphArray.first(where: { ($0["@type"] as? String) == "Article" }) else { return nil }

        let headline = article["headline"] as? String ?? article["name"] as? String ?? ""
        let description = article["description"] as? String
        let imageURL = (article["image"] as? String).flatMap(URL.init)

        let authorName: String? = {
            if let author = article["author"] as? [String: Any] {
                return author["name"] as? String
            }
            return nil
        }()

        let publishedAt: Date? = {
            if let dateStr = article["datePublished"] as? String {
                let formatter = ISO8601DateFormatter()
                formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
                return formatter.date(from: dateStr) ?? ISO8601DateFormatter().date(from: dateStr)
            }
            return nil
        }()

        let (videoURL, tags, resolution, fileSizeText, _, _, _) = parseDetailSupplemental(document: document)
        let id = extractID(from: pageURL.absoluteString) ?? pageURL.lastPathComponent.replacingOccurrences(of: ".html", with: "")
        let (exactResolution, _, _) = parseResolution(resolution)
        let fileSizeBytes = parseFileSize(fileSizeText)

        let categoryName: String? = {
            if let breadcrumbList = graphArray.first(where: { ($0["@type"] as? String) == "BreadcrumbList" }),
               let itemListElement = breadcrumbList["itemListElement"] as? [[String: Any]],
               itemListElement.count >= 3,
               let item = itemListElement[2]["item"] as? [String: Any],
               let name = item["name"] as? String { return name }
            return nil
        }()

        let sourceNameValue = t("wallsflow")

        var detailDownloadOptions: [MediaDownloadOption] = []
        if let videoURL {
            let option = MediaDownloadOption(
                label: "Original",
                fileSizeLabel: fileSizeText ?? "",
                detailText: resolution ?? "Original MP4",
                remoteURL: videoURL
            )
            detailDownloadOptions = [option]
        }

        return MediaItem(
            slug: "wf_\(id)",
            title: headline.replacingOccurrences(of: " Live Wallpaper", with: ""),
            pageURL: pageURL,
            thumbnailURL: imageURL ?? pageURL,
            resolutionLabel: resolution ?? "动态壁纸",
            collectionTitle: categoryName,
            summary: description,
            previewVideoURL: videoURL,
            posterURL: imageURL,
            tags: tags,
            exactResolution: exactResolution,
            durationSeconds: nil,
            downloadOptions: detailDownloadOptions,
            sourceName: sourceNameValue,
            isAnimatedImage: false,
            subscriptionCount: nil,
            favoriteCount: nil,
            viewCount: nil,
            ratingScore: nil,
            authorName: authorName,
            authorSteamID: nil,
            authorAvatarURL: nil,
            fileSize: fileSizeBytes,
            createdAt: publishedAt,
            updatedAt: nil
        )
    }

    func parseDetailPageDOM(document: Document, pageURL: URL) throws -> MediaItem? {
        let title = (try? document.select("h1").first()?.text()) ?? ""

        let imageURL: URL? = {
            if let meta = try? document.select("meta[property=\"og:image\"]").first(),
               let content = try? meta.attr("content"),
               let url = URL(string: content) { return url }
            return nil
        }()

        let description: String? = {
            if let meta = try? document.select("meta[name=\"description\"]").first(),
               let content = try? meta.attr("content"), !content.isEmpty { return content }
            if let shareData = try? document.select("[data-description]").first(),
               let desc = try? shareData.attr("data-description"), !desc.isEmpty { return desc }
            return nil
        }()

        let (videoURL, tags, resolution, fileSizeText, _, _, _) = parseDetailSupplemental(document: document)
        let id = extractID(from: pageURL.absoluteString) ?? pageURL.lastPathComponent.replacingOccurrences(of: ".html", with: "")
        let sourceNameValue = t("wallsflow")
        let (exactResolution, _, _) = parseResolution(resolution)
        let fileSizeBytes = parseFileSize(fileSizeText)

        var detailDownloadOptions: [MediaDownloadOption] = []
        if let videoURL {
            let option = MediaDownloadOption(
                label: "Original",
                fileSizeLabel: fileSizeText ?? "",
                detailText: resolution ?? "Original MP4",
                remoteURL: videoURL
            )
            detailDownloadOptions = [option]
        }

        return MediaItem(
            slug: "wf_\(id)",
            title: title.replacingOccurrences(of: " Live Wallpaper", with: ""),
            pageURL: pageURL,
            thumbnailURL: imageURL ?? pageURL,
            resolutionLabel: resolution ?? "动态壁纸",
            collectionTitle: nil,
            summary: description,
            previewVideoURL: videoURL,
            posterURL: imageURL,
            tags: tags,
            exactResolution: exactResolution,
            durationSeconds: nil,
            downloadOptions: detailDownloadOptions,
            sourceName: sourceNameValue,
            isAnimatedImage: false,
            subscriptionCount: nil,
            favoriteCount: nil,
            viewCount: nil,
            ratingScore: nil,
            authorName: nil,
            authorSteamID: nil,
            authorAvatarURL: nil,
            fileSize: fileSizeBytes,
            createdAt: nil,
            updatedAt: nil
        )
    }

    func parseDetailSupplemental(document: Document) -> (videoURL: URL?, tags: [String], resolution: String?, fileSizeText: String?, sourceName: String?, sourceURL: URL?, downloadURL: URL?) {
        let videoURL: URL? = {
            if let videoDiv = try? document.select("[data-video-src]").first(),
               let src = try? videoDiv.attr("data-video-src"),
               let url = URL(string: src) { return url }
            if let source = try? document.select("video source[data-src]").first(),
               let src = try? source.attr("data-src"),
               let url = URL(string: src) { return url }
            return nil
        }()

        let tags: [String] = {
            if let hashtagEl = try? document.select("[data-hashtags]").first() {
                let html = (try? hashtagEl.attr("data-hashtags")) ?? ""
                let pattern = "/tags/([^/]+)/"
                if let regex = try? NSRegularExpression(pattern: pattern) {
                    let nsRange = NSRange(html.startIndex..<html.endIndex, in: html)
                    let matches = regex.matches(in: html, range: nsRange)
                    return matches.compactMap { match -> String? in
                        guard let range = Range(match.range(at: 1), in: html) else { return nil }
                        return String(html[range]).replacingOccurrences(of: "-", with: " ").capitalized
                    }
                }
            }
            return []
        }()

        let resolution: String? = {
            let body = try? document.body()?.text() ?? ""
            if let bodyText = body {
                let pattern = "Resolution:\\s*([^\\n]+)"
                if let regex = try? NSRegularExpression(pattern: pattern),
                   let match = regex.firstMatch(in: bodyText, range: NSRange(bodyText.startIndex..<bodyText.endIndex, in: bodyText)),
                   let range = Range(match.range(at: 1), in: bodyText) {
                    return String(bodyText[range]).trimmingCharacters(in: .whitespaces)
                }
            }
            if let link = try? document.select("a[href*=\"/xfsearch/resolution/\"]").first(),
               let text = try? link.text().trimmingCharacters(in: .whitespacesAndNewlines), !text.isEmpty { return text }
            return nil
        }()

        let fileSizeText: String? = {
            let body = try? document.body()?.text() ?? ""
            if let bodyText = body {
                let pattern = "File size:\\s*([^\\n]+)"
                if let regex = try? NSRegularExpression(pattern: pattern),
                   let match = regex.firstMatch(in: bodyText, range: NSRange(bodyText.startIndex..<bodyText.endIndex, in: bodyText)),
                   let range = Range(match.range(at: 1), in: bodyText) {
                    return String(bodyText[range]).trimmingCharacters(in: .whitespaces)
                }
            }
            return nil
        }()

        let sourceName: String? = {
            let body = try? document.body()?.text() ?? ""
            if let bodyText = body {
                let pattern = "Source:\\s*([^\\n]+)"
                if let regex = try? NSRegularExpression(pattern: pattern),
                   let match = regex.firstMatch(in: bodyText, range: NSRange(bodyText.startIndex..<bodyText.endIndex, in: bodyText)),
                   let range = Range(match.range(at: 1), in: bodyText) {
                    return String(bodyText[range]).trimmingCharacters(in: .whitespaces)
                }
            }
            return nil
        }()

        let sourceURL: URL? = {
            if let link = try? document.select("a[href*=\"steamcommunity.com\"]").first(),
               let href = try? link.attr("href") { return URL(string: href) }
            return nil
        }()

        let downloadURL: URL? = {
            if let link = try? document.select("a[href*=\"index.php?do=download&id=\"]").first(),
               let href = try? link.attr("href") {
                return URL(string: href.hasPrefix("http") ? href : "https://wallsflow.com\(href)")
            }
            return nil
        }()

        return (videoURL, tags, resolution, fileSizeText, sourceName, sourceURL, downloadURL)
    }

    func extractID(from urlString: String) -> String? {
        let pattern = "/(\\d+)-[^/]+\\.html"
        if let regex = try? NSRegularExpression(pattern: pattern),
           let match = regex.firstMatch(in: urlString, range: NSRange(urlString.startIndex..<urlString.endIndex, in: urlString)),
           let range = Range(match.range(at: 1), in: urlString) {
            return String(urlString[range])
        }
        return nil
    }

    func parseResolution(_ resolution: String?) -> (exactResolution: String?, width: Int?, height: Int?) {
        guard let res = resolution else { return (nil, nil, nil) }
        let cleaned = res
            .replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: "×", with: "x")
            .replacingOccurrences(of: "X", with: "x")
        let parts = cleaned.split(separator: "x")
        guard parts.count == 2,
              let w = Int(parts[0]),
              let h = Int(parts[1]) else {
            return (resolution, nil, nil)
        }
        return ("\(w)x\(h)", w, h)
    }

    func parseFileSize(_ text: String?) -> Int64? {
        guard let text = text else { return nil }
        let cleaned = text.lowercased().trimmingCharacters(in: .whitespaces)
        let numberStr = cleaned.replacingOccurrences(of: #"[^0-9\.]+"#, with: "", options: .regularExpression)
        guard let value = Double(numberStr) else { return nil }
        if cleaned.contains("gb") { return Int64(value * 1_073_741_824) }
        if cleaned.contains("mb") { return Int64(value * 1_048_576) }
        if cleaned.contains("kb") { return Int64(value * 1_024) }
        return Int64(value)
    }
}

// MARK: - 错误类型

enum WallsflowError: LocalizedError {
    case parseFailed(String)
    case invalidURL
    case notFound

    var errorDescription: String? {
        switch self {
        case .parseFailed(let detail): return "Wallsflow 解析失败: \(detail)"
        case .invalidURL: return "无效的 Wallsflow URL"
        case .notFound: return "Wallsflow 内容未找到"
        }
    }
}
