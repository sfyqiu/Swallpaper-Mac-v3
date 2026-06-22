import SwiftUI
import WebKit

/// Steam Workshop 网页预览视图
struct WorkshopWebPreviewView: View {
    let url: URL
    @Environment(\.dismiss) private var dismiss
    @State private var loadFailed = false

    var body: some View {
        VStack(spacing: 0) {
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

            if loadFailed {
                VStack(spacing: 12) {
                    Spacer()
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 32))
                        .foregroundStyle(.orange)
                    Text("Steam 页面加载失败")
                        .font(.system(size: 14, weight: .medium))
                    Text("可能是该内容需要登录 Steam 才能查看")
                        .font(.system(size: 12))
                        .foregroundStyle(.secondary)
                    Button("在浏览器中打开") {
                        NSWorkspace.shared.open(url)
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.small)
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                WebView(url: url, loadFailed: $loadFailed)
            }
        }
        .frame(width: 900, height: 700)
    }
}

private struct WebView: NSViewRepresentable {
    let url: URL
    @Binding var loadFailed: Bool

    func makeNSView(context: Context) -> WKWebView {
    @State private var isLoading = true

    func makeNSView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.preferences.setValue(true, forKey: "developerExtrasEnabled")
        config.defaultWebpagePreferences.allowsContentJavaScript = true
        config.websiteDataStore = .default()

        let web = WKWebView(frame: .zero, configuration: config)
        web.allowsBackForwardNavigationGestures = true
        web.navigationDelegate = context.coordinator
        web.customUserAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.0 Safari/605.1.15"

        let req = URLRequest(url: url)
        web.load(req)
        return web
    }

    func updateNSView(_ nsView: WKWebView, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(loadFailed: $loadFailed)
    }

    class Coordinator: NSObject, WKNavigationDelegate {
        @Binding var loadFailed: Bool

        init(loadFailed: Binding<Bool>) {
            _loadFailed = loadFailed
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            // 检查是否 Steam 的错误页面
            webView.evaluateJavaScript("document.title") { result, _ in
                if let title = result as? String,
                   title.contains("抱歉") || title.contains("Error") || title == "" {
                    DispatchQueue.main.async {
                        self.loadFailed = true
                    }
                }
            }
        }

        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            if (error as NSError).code != NSURLErrorCancelled {
                DispatchQueue.main.async { self.loadFailed = true }
            }
        }

        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            DispatchQueue.main.async { self.loadFailed = true }
        }
    }
}
