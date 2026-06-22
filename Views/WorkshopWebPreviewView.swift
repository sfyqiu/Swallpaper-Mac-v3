import SwiftUI
import WebKit

/// Steam Workshop 网页预览视图
struct WorkshopWebPreviewView: View {
    let url: URL
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            // 顶部栏
            HStack {
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 18))
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)

                Text("Steam 预览")
                    .font(.system(size: 14, weight: .medium))
                    .padding(.leading, 8)

                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)

            Divider()

            VStack(spacing: 24) {
                Spacer()

                Image(systemName: "safari")
                    .font(.system(size: 48))
                    .foregroundStyle(.blue.opacity(0.7))

                VStack(spacing: 8) {
                    Text("查看完整内容")
                        .font(.system(size: 16, weight: .bold))
                    Text("Steam 页面包含视频预览、评论、评分等信息\n将在浏览器中打开")
                        .font(.system(size: 13))
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                }

                Button(action: {
                    NSWorkspace.shared.open(url)
                    dismiss()
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "arrow.up.forward.app")
                        Text("在浏览器中打开")
                    }
                    .font(.system(size: 14, weight: .medium))
                    .padding(.horizontal, 24)
                    .padding(.vertical, 10)
                    .background(Color.blue.opacity(0.2))
                    .cornerRadius(8)
                }
                .buttonStyle(.plain)

                Spacer()
            }
        }
        .frame(width: 400, height: 320)
    }
}
