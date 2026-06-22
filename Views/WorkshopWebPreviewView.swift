import SwiftUI
import WebKit

/// Steam Workshop 网页预览视图
struct WorkshopWebPreviewView: View {
    let url: URL
    @Environment(\.dismiss) private var dismiss

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

            WebView(url: url)
        }
        .frame(width: 900, height: 700)
    }
}

private struct WebView: NSViewRepresentable {
    let url: URL
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

        var req = URLRequest(url: url)
        req.setValue("text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8", forHTTPHeaderField: "Accept")
        req.setValue("https://steamcommunity.com", forHTTPHeaderField: "Referer")
        web.load(req)
        return web
    }

    func updateNSView(_ nsView: WKWebView, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    class Coordinator: NSObject, WKNavigationDelegate {
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            // Steam 页面加载完成后，尝试隐藏不需要的元素
            webView.evaluateJavaScript("""
                var style = document.createElement('style');
                style.textContent = `
                    .responsive_page_menu_ctn, .responsive_header, .game_suggestions_list,
                    #global_header, .footer_content_ctn { display: none !important; }
                    .responsive_page_content { margin-top: 0 !important; }
                `;
                document.head.appendChild(style);
            """)
        }

        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {}
        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            print("[WorkshopWebPreview] Failed: \(error.localizedDescription)")
        }
    }
}
