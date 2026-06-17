import SwiftUI

// MARK: - 下载进度页面

struct DownloadsView: View {
    @StateObject private var downloadService = DownloadTaskService.shared
    @State private var selectedFilter: DownloadFilter = .all

    enum DownloadFilter: String, CaseIterable {
        case all = "全部"
        case downloading = "下载中"
        case completed = "已完成"
        case failed = "失败"
    }

    var body: some View {
        VStack(spacing: 0) {
            // 标题
            HStack {
                Text(t("downloads"))
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(Color.white.opacity(0.85))
                Spacer()
                if !downloadService.tasks.isEmpty {
                    Button(t("clear")) {
                        for task in downloadService.tasks where task.status == .completed || task.status == .failed {
                            downloadService.removeTask(id: task.id)
                        }
                    }
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(Color(hex: "FF453A"))
                }
            }
            .padding(.horizontal, 28)
            .padding(.top, 20)
            .padding(.bottom, 16)

            // 筛选标签
            HStack(spacing: 12) {
                ForEach(DownloadFilter.allCases, id: \.self) { filter in
                    TagChip(
                        title: filterTitle(filter),
                        isSelected: selectedFilter == filter
                    ) {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            selectedFilter = filter
                        }
                    }
                }
                Spacer()
            }
            .padding(.horizontal, 28)
            .padding(.bottom, 16)

            // 任务列表
            ScrollView(.vertical, showsIndicators: false) {
                LazyVStack(spacing: 12) {
                    let filteredTasks = filteredTasks()
                    if filteredTasks.isEmpty {
                        emptyState
                    } else {
                        ForEach(filteredTasks) { task in
                            DownloadTaskRow(task: task, downloadService: downloadService)
                        }
                    }
                }
                .padding(.horizontal, 28)
                .padding(.bottom, 40)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.opacity(0.95))
    }

    @ViewBuilder
    private var emptyState: some View {
        VStack(spacing: 12) {
            Spacer().frame(height: 60)
            Image(systemName: "arrow.down.circle")
                .font(.system(size: 40))
                .foregroundStyle(Color.white.opacity(0.3))
            Text(emptyText)
                .font(.system(size: 14))
                .foregroundStyle(Color.white.opacity(0.5))
        }
    }

    private func filteredTasks() -> [DownloadTask] {
        let all = downloadService.tasks
        switch selectedFilter {
        case .all: return all
        case .downloading: return all.filter { $0.status == .downloading || $0.status == .pending || $0.status == .paused }
        case .completed: return all.filter { $0.status == .completed }
        case .failed: return all.filter { $0.status == .failed }
        }
    }

    private func filterTitle(_ filter: DownloadFilter) -> String {
        let count: Int
        switch filter {
        case .all: count = downloadService.tasks.count
        case .downloading: count = downloadService.tasks.filter { $0.status == .downloading || $0.status == .pending || $0.status == .paused }.count
        case .completed: count = downloadService.tasks.filter { $0.status == .completed }.count
        case .failed: count = downloadService.tasks.filter { $0.status == .failed }.count
        }
        return "\(filter.rawValue) (\(count))"
    }

    private var emptyText: String {
        switch selectedFilter {
        case .all: return "暂无下载任务"
        case .downloading: return "没有正在下载的任务"
        case .completed: return "没有已完成的任务"
        case .failed: return "没有失败的任务"
        }
    }
}

// MARK: - 下载任务行

private struct DownloadTaskRow: View {
    let task: DownloadTask
    let downloadService: DownloadTaskService
    @ObservedObject private var arcSettings = ArcBackgroundSettings.shared

    var body: some View {
        HStack(spacing: 12) {
            // 图标/缩略图
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.white.opacity(0.06))
                    .frame(width: 48, height: 48)
                Image(systemName: iconName)
                    .font(.system(size: 18))
                    .foregroundStyle(iconColor)
            }

            // 信息
            VStack(alignment: .leading, spacing: 4) {
                Text(task.title)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(Color.white.opacity(0.85))
                    .lineLimit(1)

                Text(statusText)
                    .font(.system(size: 11))
                    .foregroundStyle(Color.white.opacity(0.5))
            }

            Spacer()

            // 进度/操作
            VStack(alignment: .trailing, spacing: 4) {
                if task.status == .downloading {
                    Text("\(Int(task.progress * 100))%")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(accentColor)

                    ProgressView(value: task.progress)
                        .progressViewStyle(.linear)
                        .tint(accentColor)
                        .frame(width: 80)
                }

                if task.status == .completed {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 18))
                        .foregroundStyle(Color.green)
                }

                if task.status == .failed {
                    Button(t("retry")) {
                        // 重试逻辑 — 调用方需重新触发下载
                    }
                    .font(.system(size: 11))
                    .foregroundStyle(Color(hex: "FF453A"))
                }

                if task.status == .paused {
                    Text("已暂停")
                        .font(.system(size: 11))
                        .foregroundStyle(Color.orange)
                }

                if task.status == .pending {
                    Text("等待中")
                        .font(.system(size: 11))
                        .foregroundStyle(Color.white.opacity(0.5))
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.04))
        )
        .contextMenu {
            if task.status == .downloading || task.status == .pending {
                Button("暂停") { downloadService.pauseTask(id: task.id) }
            }
            if task.status == .paused {
                Button("继续") { downloadService.resumeTask(id: task.id) }
            }
            Button("取消") { downloadService.cancelTask(id: task.id) }
            Button("移除记录") { downloadService.removeTask(id: task.id) }
        }
    }

    private var iconName: String {
        switch task.status {
        case .downloading: return "arrow.down.circle"
        case .completed: return "checkmark.circle"
        case .failed: return "exclamationmark.circle"
        case .paused: return "pause.circle"
        case .pending: return "clock"
        case .cancelled: return "xmark.circle"
        }
    }

    private var iconColor: Color {
        switch task.status {
        case .downloading: return .blue
        case .completed: return .green
        case .failed: return .red
        case .paused: return .orange
        case .pending: return .gray
        case .cancelled: return .gray
        }
    }

    private var statusText: String {
        switch task.status {
        case .downloading: return "下载中..."
        case .completed: return task.completedAt?.formatted(date: .abbreviated, time: .shortened) ?? "已完成"
        case .failed: return "下载失败"
        case .paused: return "已暂停"
        case .pending: return "排队等待中"
        case .cancelled: return "已取消"
        }
    }

    private var accentColor: Color {
        Color(hex: "6366F1")
    }
}
