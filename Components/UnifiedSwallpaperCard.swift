import SwiftUI
import Kingfisher

// MARK: - 统一卡片组件
/// 统一的 Swallpaper 卡片组件，替代 WallpaperCardView / MediaCardView / LiquidGlassWallpaperCard / LibraryCards
/// 通过 CardConfig 控制所有变体

struct SwallpaperCardConfig {
    let title: String
    let subtitle: String?
    let imageURL: URL?
    let badge: String?
    let badgeColor: Color?
    let stats: [CardStat]
    let onTap: () -> Void

    var cornerRadius: CGFloat = 22
    var cardWidth: CGFloat = 280
    var thumbnailHeight: CGFloat = 190
    var isEditing: Bool = false
    var isSelected: Bool = false
    var progress: Double?
    var progressLabel: String?

    struct CardStat: Identifiable {
        let id = UUID()
        let label: String
        let value: String
        let icon: String?
        let tint: Color
    }
}

// MARK: - 卡片

struct SwallpaperCard: View {
    let config: SwallpaperCardConfig
    @State private var isHovered = false

    var body: some View {
        Button(action: config.onTap) {
            VStack(alignment: .leading, spacing: 0) {
                thumbnailArea
                infoArea
            }
            .frame(width: config.cardWidth, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: config.cornerRadius, style: .continuous)
                    .fill(Color(hex: "1A1D24").opacity(0.6))
            )
            .clipShape(RoundedRectangle(cornerRadius: config.cornerRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: config.cornerRadius, style: .continuous)
                    .stroke(Color.white.opacity(isHovered ? 0.12 : 0.06), lineWidth: 0.8)
            )
            .scaleEffect(isHovered ? 1.01 : 1.0)
            .animation(.easeOut(duration: 0.16), value: isHovered)
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            if !config.isEditing {
                isHovered = hovering
            }
        }
    }

    // MARK: - 缩略图

    private var thumbnailArea: some View {
        ZStack {
            if let url = config.imageURL {
                KFImage(url)
                    .setProcessor(DownsamplingImageProcessor(size: CGSize(width: 512, height: 512)))
                    .cacheMemoryOnly(false)
                    .cancelOnDisappear(true)
                    .fade(duration: 0.3)
                    .resizable()
                    .scaledToFill()
                    .frame(width: config.cardWidth, height: config.thumbnailHeight)
                    .clipped()
            } else {
                skeletonThumbnail
            }

            // 编辑复选框
            if config.isEditing {
                VStack {
                    HStack {
                        Image(systemName: config.isSelected ? "checkmark.circle.fill" : "circle")
                            .font(.system(size: 22, weight: .semibold))
                            .foregroundStyle(config.isSelected ? LiquidGlassColors.primaryPink : .white.opacity(0.8))
                            .padding(12)
                        Spacer()
                    }
                    Spacer()
                }
            }

            // 徽章
            if let badge = config.badge, !config.isEditing {
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Text(badge)
                            .font(.system(size: 10.5, weight: .bold, design: .monospaced))
                            .foregroundStyle(.white.opacity(0.82))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(Capsule(style: .continuous).fill(Color.black.opacity(0.4)))
                            .padding(12)
                    }
                }
            }

            // 进度条
            if let progress = config.progress, progress < 1.0 {
                VStack {
                    Spacer()
                    ProgressView(value: progress)
                        .tint(config.badgeColor ?? LiquidGlassColors.accentCyan)
                        .scaleEffect(x: 1, y: 1.5)
                        .padding(.horizontal, 14)
                        .padding(.bottom, 8)
                }
            }
        }
        .frame(width: config.cardWidth, height: config.thumbnailHeight)
    }

    // MARK: - 信息区

    private var infoArea: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(config.title)
                .font(.system(size: 14.5, weight: .bold))
                .foregroundStyle(.white.opacity(0.92))
                .lineLimit(2)

            if let subtitle = config.subtitle {
                Text(subtitle)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(.white.opacity(0.56))
                    .lineLimit(1)
            }

            if !config.stats.isEmpty {
                HStack(spacing: 16) {
                    ForEach(config.stats) { stat in
                        HStack(spacing: 4) {
                            if let icon = stat.icon {
                                Image(systemName: icon)
                                    .font(.system(size: 10, weight: .medium))
                            }
                            Text(stat.value)
                                .font(.system(size: 11, weight: .semibold, design: .monospaced))
                        }
                        .foregroundStyle(stat.tint)
                    }
                }
                .padding(.top, 2)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .frame(width: config.cardWidth, alignment: .leading)
    }

    // MARK: - 骨架

    private var skeletonThumbnail: some View {
        Rectangle()
            .fill(Color.white.opacity(0.05))
            .frame(width: config.cardWidth, height: config.thumbnailHeight)
            .overlay(
                Image(systemName: "photo")
                    .font(.system(size: 28, weight: .light))
                    .foregroundStyle(.white.opacity(0.2))
            )
    }
}

// MARK: - 预置配置

extension SwallpaperCardConfig {
    /// 壁纸卡片
    static func wallpaper(
        title: String,
        resolution: String,
        imageURL: URL?,
        views: Int,
        favorites: Int,
        purity: String? = nil,
        onTap: @escaping () -> Void
    ) -> SwallpaperCardConfig {
        var stats: [CardStat] = [
            CardStat(label: "views", value: compactNumber(views), icon: "eye", tint: LiquidGlassColors.textTertiary),
            CardStat(label: "favs", value: compactNumber(favorites), icon: "heart", tint: LiquidGlassColors.primaryPink)
        ]
        return SwallpaperCardConfig(
            title: title,
            subtitle: resolution,
            imageURL: imageURL,
            badge: purity,
            badgeColor: purity == "NSFW" ? LiquidGlassColors.primaryPink : LiquidGlassColors.onlineGreen,
            stats: stats,
            onTap: onTap
        )
    }

    /// 媒体卡片
    static func media(
        title: String,
        subtitle: String,
        imageURL: URL?,
        badge: String?,
        onTap: @escaping () -> Void
    ) -> SwallpaperCardConfig {
        SwallpaperCardConfig(
            title: title,
            subtitle: subtitle,
            imageURL: imageURL,
            badge: badge,
            badgeColor: LiquidGlassColors.accentCyan,
            stats: [],
            onTap: onTap
        )
    }

    private static func compactNumber(_ value: Int) -> String {
        if value >= 1_000_000 { return String(format: "%.1fM", Double(value) / 1_000_000) }
        if value >= 1_000 { return String(format: "%.1fK", Double(value) / 1_000) }
        return "\(value)"
    }
}

// MARK: - 横排卡片（图书馆/收藏用）

struct SwallpaperHorizontalCard: View {
    let config: SwallpaperCardConfig
    @State private var isHovered = false

    var body: some View {
        Button(action: config.onTap) {
            HStack(spacing: 0) {
                // 缩略图
                ZStack {
                    if let url = config.imageURL {
                        KFImage(url)
                            .setProcessor(DownsamplingImageProcessor(size: CGSize(width: 256, height: 256)))
                            .cacheMemoryOnly(false)
                            .cancelOnDisappear(true)
                            .fade(duration: 0.3)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 120, height: 80)
                            .clipped()
                    } else {
                        Rectangle()
                            .fill(Color.white.opacity(0.05))
                            .frame(width: 120, height: 80)
                    }

                    if let progress = config.progress, progress < 1.0 {
                        ProgressView(value: progress)
                            .tint(config.badgeColor ?? .white)
                            .padding(.horizontal, 8)
                    }
                }
                .frame(width: 120, height: 80)

                // 信息
                VStack(alignment: .leading, spacing: 4) {
                    Text(config.title)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.9))
                        .lineLimit(2)
                    if let subtitle = config.subtitle {
                        Text(subtitle)
                            .font(.system(size: 11, weight: .medium))
                            .foregroundStyle(.white.opacity(0.5))
                            .lineLimit(1)
                    }
                }
                .padding(.horizontal, 12)
                .frame(width: config.cardWidth - 120, alignment: .leading)

                Spacer()
            }
            .frame(width: config.cardWidth, height: 80)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color(hex: "1A1D24").opacity(0.4))
            )
        }
        .buttonStyle(.plain)
        .scaleEffect(isHovered ? 1.01 : 1.0)
        .animation(.easeOut(duration: 0.16), value: isHovered)
        .onHover { hovering in
            if !config.isEditing { isHovered = hovering }
        }
    }
}
