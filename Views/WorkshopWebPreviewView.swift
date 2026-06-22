import SwiftUI
import WebKit

/// Steam Workshop 网页预览视图
struct WorkshopWebPreviewView: View {
    let url: URL
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            // 顶部工具栏
            HStack {
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 18))
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)

                Text("Steam 网页预览")
                    .font(.system(size: 14, weight: .medium))
                    .padding(.leading, 8)

                Spacer()

                Button(action: { NSWorkspace.shared.open(url) }) {
                    Image(systemName: "safari")
                        .font(.system(size: 14))
                }
                .buttonStyle(.plain)
                .help("在浏览器中打开")
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)

            Divider()

            // WKWebView
            WebView(url: url)
        }
        .frame(width: 900, height: 700)
    }
}

private struct WebView: NSViewRepresentable {
    let url: URL

    func makeNSView(context: Context) -> WKWebView {
        let web = WKWebView()
        web.allowsBackForwardNavigationGestures = true
        web.customUserAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko)"
        web.load(URLRequest(url: url))
        return web
    }

    func updateNSView(_ nsView: WKWebView, context: Context) {}
}
