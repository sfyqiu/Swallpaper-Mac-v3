import Foundation

/// Workshop 收藏管理器 — 存储收藏的壁纸 ID
@MainActor
final class WorkshopFavoritesManager: ObservableObject {
    static let shared = WorkshopFavoritesManager()

    @Published private(set) var favoriteIDs: Set<String> = []
    @Published private(set) var favoriteItems: [FavoriteWorkshopItem] = []

    private let defaultsKey = "workshop_favorites"

    struct FavoriteWorkshopItem: Identifiable, Codable {
        let id: String
        let title: String
        let previewURL: String?
        let pageURL: String
        let tags: [String]
        let addedAt: Date
    }

    private init() {
        loadFavorites()
    }

    func addFavorite(id: String, title: String, previewURL: String?, pageURL: String, tags: [String]) {
        if favoriteIDs.contains(id) { return }
        let item = FavoriteWorkshopItem(
            id: id, title: title, previewURL: previewURL,
            pageURL: pageURL, tags: tags, addedAt: Date()
        )
        favoriteIDs.insert(id)
        favoriteItems.append(item)
        saveFavorites()
    }

    func removeFavorite(id: String) {
        favoriteIDs.remove(id)
        favoriteItems.removeAll { $0.id == id }
        saveFavorites()
    }

    func isFavorite(id: String) -> Bool {
        return favoriteIDs.contains(id)
    }

    func toggleFavorite(id: String, title: String, previewURL: String?, pageURL: String, tags: [String]) {
        if isFavorite(id: id) {
            removeFavorite(id: id)
        } else {
            addFavorite(id: id, title: title, previewURL: previewURL, pageURL: pageURL, tags: tags)
        }
    }

    private func saveFavorites() {
        if let data = try? JSONEncoder().encode(favoriteItems) {
            UserDefaults.standard.set(data, forKey: defaultsKey)
        }
    }

    private func loadFavorites() {
        guard let data = UserDefaults.standard.data(forKey: defaultsKey),
              let items = try? JSONDecoder().decode([FavoriteWorkshopItem].self, from: data) else {
            return
        }
        favoriteItems = items
        favoriteIDs = Set(items.map { $0.id })
    }
}
