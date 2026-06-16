import Foundation
import SwiftUI
import AppKit

// MARK: - 动漫模块已删除，以下为编译兼容 stub

// Array safe subscript defined here (originally in Danmaku.swift)
extension Array {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}

// MARK: - AnimeViewModel stub
@MainActor
final class AnimeViewModel: ObservableObject {
    @Published var availableRules: [AnimeRule] = []
    @Published var selectedRule: AnimeRule?
    func releaseForegroundMemory() {}
}

// MARK: - AnimeDetailViewModel stub
@MainActor
final class AnimeDetailViewModel: ObservableObject {
    init(anime: AnimeSearchResult) {}
    func loadDetail() async {}
}

// MARK: - AnimeDetailSheet stub
struct AnimeDetailSheet: View {
    let anime: AnimeSearchResult
    @Binding var isPresented: Bool
    init(anime: AnimeSearchResult, isPresented: Binding<Bool>) {
        self.anime = anime; self._isPresented = isPresented
    }
    init(anime: AnimeSearchResult, selectedAnime: Binding<AnimeSearchResult?>) {
        self.anime = anime
        self._isPresented = Binding(get: { selectedAnime.wrappedValue != nil }, set: { if !$0 { selectedAnime.wrappedValue = nil } })
    }
    var body: some View { EmptyView() }
}

// MARK: - AnimeExploreView stub
struct AnimeExploreView: View {
    init(viewModel: AnimeViewModel, selectedAnime: Binding<AnimeSearchResult?>, isVisible: Bool) {}
    var body: some View { EmptyView() }
}

// MARK: - AnimeProgressStore stub
@MainActor
final class AnimeProgressStore: ObservableObject {
    static let shared = AnimeProgressStore()
    var animeSummaries: [String: AnimeWatchSummary] = [:]
    func restoreSavedData() {}
}

struct AnimeWatchSummary {
    let animeId: String = ""
    let animeTitle: String = ""
    let coverURL: String? = nil
    var lastEpisodeId: String? = nil
    var lastEpisodeNumber: String? = nil
    var watchedEpisodes: Int = 0
    var totalEpisodes: Int = 0
    var overallProgress: Double = 0
    var continueWatchingText: String? = nil
    var lastPlayedAt: Date? = nil
}

// MARK: - AnimeFavoriteStore stub
@MainActor
final class AnimeFavoriteStore: ObservableObject {
    static let shared = AnimeFavoriteStore()
    @Published var favorites: [AnimeSearchResult] = []
    var allFavorites: [AnimeSearchResult] { favorites }
    func removeFavorite(animeId: String) { favorites.removeAll { $0.id == animeId } }
    func restoreSavedData() {}
}

// MARK: - AnimeRuleStore stub (actor!)
actor AnimeRuleStore {
    static let shared = AnimeRuleStore()
    func clearInMemoryCache() async {}
    func allRules() async -> [AnimeRule] { [] }
    func removeRule(id: String) async throws {}
    func installRule(from url: URL) async throws -> AnimeRule {
        _ = url
        return AnimeRule(id: "", name: "", baseURL: "", searchURL: "")
    }
    func installRule(from urlStr: String) async throws -> AnimeRule {
        _ = urlStr
        return AnimeRule(id: "", name: "", baseURL: "", searchURL: "")
    }
}

// MARK: - AnimeWindowManager stub
@MainActor
final class AnimeWindowManager {
    static let shared = AnimeWindowManager()
    func closeAllWindowsForMemoryRelease() {}
}

// MARK: - AnimeVideoExtractor stub
@MainActor
final class AnimeVideoExtractor {
    static let shared = AnimeVideoExtractor()
    func cancel() {}
}

// MARK: - AnimeParserError
enum AnimeParserError: Error, LocalizedError {
    case invalidURL(String)
    case parseError(String)
    case noRulesAvailable
    case networkError(Error)
    case captchaRequired
    case noResult
    var errorDescription: String? { "\(self)" }
}

// MARK: - BangumiService stub
@MainActor
final class BangumiService {
    static let shared = BangumiService()
}

// MARK: - DanmakuService stub
@MainActor
final class DanmakuService {
    static let shared = DanmakuService()
}

// MARK: - DanmakuView stub
struct DanmakuView: View {
    var body: some View { EmptyView() }
}

// MARK: - Anime video enhancer stub
@MainActor
final class AnimeVideoEnhancer {
    static let shared = AnimeVideoEnhancer()
}

// MARK: - AnimeParser stub
@MainActor
final class AnimeParser {
    static let shared = AnimeParser()
}

// MARK: - AnimeCardView stub
struct AnimeCardView: View {
    let anime: AnimeSearchResult; let cardWidth: CGFloat
    var body: some View { EmptyView() }
}

// MARK: - AnimePortraitCard stub
struct AnimePortraitCard: View {
    let anime: AnimeSearchResult
    var body: some View { EmptyView() }
}

// MARK: - AnimeGridCell stub
struct AnimeGridCell: View {
    let anime: AnimeSearchResult; let cardWidth: CGFloat
    var body: some View { EmptyView() }
}

// MARK: - AnimeRulesMarketView stub
struct AnimeRulesMarketView: View {
    var body: some View { EmptyView() }
}

// MARK: - AnimePlayerWindow stub
struct AnimePlayerWindow: View {
    var body: some View { EmptyView() }
}

// MARK: - AnimeContentView stub
struct AnimeContentView: View {
    var body: some View { EmptyView() }
}

// MARK: - AnimeDetailView stub
struct AnimeDetailView: View {
    var body: some View { EmptyView() }
}

// MARK: - AnimeSearchHeuristics stub
enum AnimeSearchHeuristics {
    static func extractSearchTerms(from query: String) -> [String] { [query] }
}
