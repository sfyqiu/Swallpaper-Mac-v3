import SwiftUI

/// 收藏列表视图
struct FavoritesListView: View {
    @ObservedObject private var favManager = WorkshopFavoritesManager.shared

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("我的收藏")
                .font(.system(size: 20, weight: .bold))
                .padding(.horizontal, 20)
                .padding(.top, 20)

            if favManager.favoriteItems.isEmpty {
                VStack(spacing: 12) {
                    Spacer()
                    Image(systemName: "heart")
                        .font(.system(size: 40))
                        .foregroundStyle(.secondary.opacity(0.4))
                    Text("暂无收藏")
                        .font(.system(size: 14))
                        .foregroundStyle(.secondary)
                    Text("浏览壁纸时点击 ❤️ 即可收藏")
                        .font(.system(size: 12))
                        .foregroundStyle(.tertiary)
                    Spacer()
                }
                .frame(maxWidth: .infinity)
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(favManager.favoriteItems) { item in
                            HStack(spacing: 12) {
                                if let urlStr = item.previewURL, let url = URL(string: urlStr) {
                                    AsyncImage(url: url) { phase in
                                        if let img = phase.image {
                                            img.resizable().aspectRatio(contentMode: .fill)
                                        } else {
                                            Color.gray.opacity(0.2)
                                        }
                                    }
                                    .frame(width: 80, height: 60)
                                    .cornerRadius(8)
                                }

                                VStack(alignment: .leading, spacing: 4) {
                                    Text(item.title)
                                        .font(.system(size: 13, weight: .medium))
                                        .lineLimit(1)
                                    Text("收藏于 \(item.addedAt.formatted(date: .abbreviated, time: .shortened))")
                                        .font(.system(size: 11))
                                        .foregroundStyle(.secondary)
                                }

                                Spacer()

                                Button("移除") {
                                    WorkshopFavoritesManager.shared.removeFavorite(id: item.id)
                                }
                                .controlSize(.small)

                                Button("下载") {
                                    NotificationCenter.default.post(
                                        name: .favoriteDownloadRequested,
                                        object: nil,
                                        userInfo: ["itemID": item.id, "pageURL": item.pageURL]
                                    )
                                }
                                .controlSize(.small)
                                .buttonStyle(.borderedProminent)
                            }
                            .padding(12)
                            .background(Color.white.opacity(0.04))
                            .cornerRadius(10)
                        }
                    }
                    .padding(20)
                }
            }
        }
        .frame(width: 500, height: 500)
    }
}

extension Notification.Name {
    static let favoriteDownloadRequested = Notification.Name("favoriteDownloadRequested")
}
