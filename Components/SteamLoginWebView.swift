import SwiftUI
import WebKit

// MARK: - Steam Login WebView
/// 基于 WKWebView 的 Steam 登录视图
/// 打开 Steam OpenID 登录页面，用户登录后获取 Session Cookie
struct SteamLoginWebView: NSViewRepresentable {
    @Binding var isLoggedIn: Bool
    @Binding var steamID: String
    @Binding var isLoading: Bool
    @Binding var currentURL: String
    @Binding var navigateToSubscriptionCount: Int
    @Binding var navigateToCustomURL: String
    var onLoginSuccess: ((String) -> Void)?

    func makeNSView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.websiteDataStore = .default()
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = context.coordinator
        webView.allowsBackForwardNavigationGestures = true
        context.coordinator.webView = webView
        let loginURL = URL(string: "https://steamcommunity.com/login/home/?goto=")!
        webView.load(URLRequest(url: loginURL))
        return webView
    }

    func updateNSView(_ nsView: WKWebView, context: Context) {
        context.coordinator.checkNavigateTrigger(navigateToSubscriptionCount, webView: nsView)
        context.coordinator.checkNavigateToCustomURL(navigateToCustomURL, webView: nsView)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    private enum NavigationState {
        case initial
        case hasSteamID(String)
        case onProfileSubscriptionPage(String)
    }

    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: SteamLoginWebView
        weak var webView: WKWebView?
        private var state: NavigationState = .initial
        private var lastNavigateTriggerCount = 0
        private let redirectURL = "https://steamcommunity.com/myworkshopfiles/?appid=431960&sort=score&browsefilter=mysubscriptions"

        private func profileSubscriptionURL(steamID: String) -> URL? {
            let urlString = "https://steamcommunity.com/profiles/\(steamID)/myworkshopfiles/?appid=431960&sort=score&browsefilter=mysubscriptions&view=imagewall&p=1&numperpage=30"
            return URL(string: urlString)
        }

        init(_ parent: SteamLoginWebView) { self.parent = parent }

        func checkNavigateTrigger(_ count: Int, webView: WKWebView) {
            guard count > lastNavigateTriggerCount else { return }
            lastNavigateTriggerCount = count
            navigateToSubscription(webView: webView)
        }

        private var lastCustomURL: String = ""

        func checkNavigateToCustomURL(_ urlString: String, webView: WKWebView) {
            let trimmed = urlString.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmed.isEmpty, trimmed != lastCustomURL else { return }
            lastCustomURL = trimmed
            DispatchQueue.main.async {
                self.parent.currentURL = trimmed
                self.parent.navigateToCustomURL = ""
            }
            guard let url = Self.makeURL(from: trimmed) else { return }
            webView.load(URLRequest(url: url))
        }

        private static func makeURL(from string: String) -> URL? {
            let trimmed = string.trimmingCharacters(in: .whitespacesAndNewlines)
            if trimmed.isEmpty { return nil }
            if let url = URL(string: trimmed), url.scheme != nil { return url }
            return URL(string: "https://\(trimmed)")
        }

        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            DispatchQueue.main.async {
                self.parent.isLoading = true
                if let url = webView.url { self.parent.currentURL = url.absoluteString }
            }
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            DispatchQueue.main.async {
                self.parent.isLoading = false
                if let url = webView.url { self.parent.currentURL = url.absoluteString }
            }
            guard let url = webView.url else { return }
            let urlString = url.absoluteString

            switch state {
            case .initial:
                if urlString.contains("myworkshopfiles") && urlString.contains("browsefilter=mysubscriptions") {
                    if let sid = extractSteamIDFromProfileURL(urlString) {
                        reachProfilePage(steamID: sid); return
                    }
                    if let vanity = extractVanityNameFromProfileURL(urlString) {
                        reachProfilePage(steamID: vanity); return
                    }
                    tryExtractSteamIDFromPage(webView: webView); return
                }
                if urlString.contains("openid.claimed_id") || urlString.contains("openid.identity") {
                    extractSteamIDFromOpenID(url: url, webView: webView); return
                }
                if !isLoginPage(urlString), urlString.contains("steamcommunity.com") {
                    tryExtractSteamIDFromPage(webView: webView)
                    setLoggedInWithoutID(); return
                }
            case .hasSteamID:
                if urlString.contains("myworkshopfiles") && urlString.contains("browsefilter=mysubscriptions") {
                    if let sid = extractSteamIDFromProfileURL(urlString) { reachProfilePage(steamID: sid) }
                    else if let vanity = extractVanityNameFromProfileURL(urlString) { reachProfilePage(steamID: vanity) }
                }
            case .onProfileSubscriptionPage:
                break
            }
        }

        func navigateToSubscription(webView: WKWebView) {
            if case let .hasSteamID(sid) = state, let url = profileSubscriptionURL(steamID: sid) {
                state = .initial
                webView.load(URLRequest(url: url))
                return
            }
            guard let url = URL(string: redirectURL) else { return }
            state = .initial
            webView.load(URLRequest(url: url))
        }

        private func reachProfilePage(steamID: String) {
            state = .onProfileSubscriptionPage(steamID)
            DispatchQueue.main.async {
                self.parent.steamID = steamID
                self.parent.isLoggedIn = true
                self.parent.onLoginSuccess?(steamID)
            }
        }

        private func setLoggedInWithoutID() {
            state = .hasSteamID("")
            DispatchQueue.main.async { self.parent.isLoggedIn = true }
        }

        private func setLoggedInWithID(_ steamID: String) {
            state = .hasSteamID(steamID)
            DispatchQueue.main.async {
                self.parent.steamID = steamID
                self.parent.isLoggedIn = true
            }
        }

        private func isLoginPage(_ urlString: String) -> Bool {
            urlString.contains("login/home") || urlString.contains("openid/login")
        }

        private func extractSteamIDFromProfileURL(_ urlString: String) -> String? {
            let pattern = "/profiles/(\\d{17})/"
            guard let regex = try? NSRegularExpression(pattern: pattern),
                  let match = regex.firstMatch(in: urlString, range: NSRange(urlString.startIndex..., in: urlString)) else { return nil }
            return String(urlString[Range(match.range(at: 1), in: urlString)!])
        }

        private func extractVanityNameFromProfileURL(_ urlString: String) -> String? {
            let pattern = "/id/([a-zA-Z0-9_-]+)"
            guard let regex = try? NSRegularExpression(pattern: pattern),
                  let match = regex.firstMatch(in: urlString, range: NSRange(urlString.startIndex..., in: urlString)) else { return nil }
            return String(urlString[Range(match.range(at: 1), in: urlString)!])
        }

        private func tryExtractSteamIDFromPage(webView: WKWebView) {
            webView.evaluateJavaScript("document.body.innerHTML") { result, error in
                guard let html = result as? String else { return }
                if let id = self.extractSteamIDFromPageHTML(html) { self.setLoggedInWithID(id); return }
                if let id = self.extractSteamIDFromPageLinks(html) { self.setLoggedInWithID(id); return }
                if let vanityName = self.extractVanityNameFromCurrentURL() {
                    AppLogger.info(.media, "Using vanity name from URL: \(vanityName)")
                    self.setLoggedInWithID(vanityName); return
                }
                if let url = webView.url?.absoluteString,
                   url.contains("myworkshopfiles") && url.contains("browsefilter=mysubscriptions") {
                    self.checkPageHasWorkshopItems(webView: webView)
                }
            }
        }

        private func extractSteamIDFromPageLinks(_ html: String) -> String? {
            let pattern = "/profiles/(\\d{17})"
            guard let regex = try? NSRegularExpression(pattern: pattern),
                  let match = regex.firstMatch(in: html, range: NSRange(html.startIndex..., in: html)) else { return nil }
            return String(html[Range(match.range(at: 1), in: html)!])
        }

        private func extractVanityNameFromCurrentURL() -> String? {
            guard let url = webView?.url?.absoluteString else { return nil }
            let pattern = "/id/([a-zA-Z0-9_-]+)/"
            guard let regex = try? NSRegularExpression(pattern: pattern),
                  let match = regex.firstMatch(in: url, range: NSRange(url.startIndex..., in: url)) else { return nil }
            return String(url[Range(match.range(at: 1), in: url)!])
        }

        private func checkPageHasWorkshopItems(webView: WKWebView) {
            let js = """
            (function() {
                var items = document.querySelectorAll('.workshopItem, .workshopItemSubscription, [id*=\"Subscription\"], a[href*=\"/sharedfiles/filedetails/?id=\"]');
                return items.length;
            })()
            """
            webView.evaluateJavaScript(js) { result, error in
                guard let count = result as? Int, count > 0 else { return }
                AppLogger.info(.media, "Page has \(count) workshop items, marking as logged in")
                self.setLoggedInWithoutID()
            }
        }

        private func extractSteamIDFromPageHTML(_ html: String) -> String? {
            let patterns = [
                "steamid=\"(\\d{17})\"", "\"steamid\":\"(\\d{17})\"", "profile/(\\d{17})",
                "\"steamid64\":\"(\\d{17})\"", "\"accountid\":\"(\\d{5,10})\"", "\"accountid\":(\\d{5,10})",
                "g_steamID\\s*=\\s*\"(\\d{17})\"", "g_steamID\\s*=\\s*'(\\d{17})'",
                "\"steamid\":\\s*\"(\\d{17})\"", "data-steamid=\"(\\d{17})\"",
                "/profiles/(\\d{17})", "openid\\.claimed_id.*?(\\d{17})",
                "SteamId[\"']?\\s*[:=]\\s*[\"']?(\\d{17})"
            ]
            for pattern in patterns {
                guard let regex = try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive]),
                      let match = regex.firstMatch(in: html, range: NSRange(html.startIndex..., in: html)) else { continue }
                let id = String(html[Range(match.range(at: 1), in: html)!])
                if id.count >= 5 && id.count <= 10, let accountID = UInt64(id) {
                    return String(accountID + 76561197960265728)
                }
                if id.count == 17 { return id }
            }
            return nil
        }

        private func extractSteamIDFromOpenID(url: URL, webView: WKWebView) {
            if let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
               let queryItems = components.queryItems {
                for item in queryItems {
                    if item.name == "openid.identity" || item.name == "openid.claimed_id" {
                        if let value = item.value {
                            let components = value.components(separatedBy: "/")
                            if let steamID = components.last, steamID.count == 17, steamID.allSatisfy(\.isNumber) {
                                self.setLoggedInWithID(steamID); return
                            }
                        }
                    }
                }
            }
        }

        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            DispatchQueue.main.async { self.parent.isLoading = false }
        }

        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            DispatchQueue.main.async { self.parent.isLoading = false }
        }
    }
}

// MARK: - Steam Login Sheet
/// 包装 SteamLoginWebView 的 Sheet 视图
struct SteamLoginSheet: View {
    @Binding var isPresented: Bool
    @State private var isLoggedIn = false
    @State private var steamID = ""
    @State private var isLoading = false
    @State private var currentURL = ""
    @State private var urlBarText = ""
    @State private var navigateToSubscriptionCount = 0
    @State private var navigateToCustomURL = ""
    @State private var isOnSubscriptionPage = false

    @EnvironmentObject var workshopSourceManager: WorkshopSourceManager

    var body: some View {
        VStack(spacing: 0) {
            // 标题栏
            HStack {
                Text(t("steamLogin.title"))
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(.white)
                Spacer()
                Button(action: { isPresented = false }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundStyle(.white.opacity(0.6))
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)

            // 地址栏
            HStack(spacing: 8) {
                Image(systemName: "lock")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(.green.opacity(0.7))
                TextField("输入网址...", text: $urlBarText)
                    .textFieldStyle(.plain)
                    .font(.system(size: 12, design: .monospaced))
                    .foregroundStyle(.white.opacity(0.85))
                    .onSubmit { navigateToCustomURL = urlBarText }
                if !urlBarText.isEmpty {
                    Button { urlBarText = "" } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 12))
                            .foregroundStyle(.white.opacity(0.4))
                    }
                    .buttonStyle(.plain)
                }
                Button { navigateToCustomURL = urlBarText } label: {
                    Image(systemName: "arrow.right")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(width: 28, height: 22)
                        .background(RoundedRectangle(cornerRadius: 6).fill(Color.accentColor.opacity(0.8)))
                }
                .buttonStyle(.plain)
                .disabled(urlBarText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.white.opacity(0.08))
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.white.opacity(0.12), lineWidth: 1))
            )
            .padding(.horizontal, 20)
            .padding(.bottom, 12)

            Divider().background(Color.white.opacity(0.1))

            // WebView
            ZStack {
                SteamLoginWebView(
                    isLoggedIn: $isLoggedIn,
                    steamID: $steamID,
                    isLoading: $isLoading,
                    currentURL: $currentURL,
                    navigateToSubscriptionCount: $navigateToSubscriptionCount,
                    navigateToCustomURL: $navigateToCustomURL,
                    onLoginSuccess: { id in
                        workshopSourceManager.steamProfileID = id
                        workshopSourceManager.refreshStoredSteamCredentials()
                        isOnSubscriptionPage = true
                    }
                )
                if isLoading {
                    VStack {
                        ProgressView().controlSize(.large)
                        Text(t("steamLogin.loading"))
                            .font(.system(size: 13))
                            .foregroundStyle(.white.opacity(0.6))
                            .padding(.top, 8)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.black.opacity(0.5))
                }
            }

            Divider().background(Color.white.opacity(0.1))

            // 底部状态栏
            HStack {
                if isOnSubscriptionPage {
                    HStack(spacing: 6) {
                        Image(systemName: "checkmark.circle.fill").foregroundStyle(.green)
                        Text(t("steamLogin.reachedSubPage"))
                            .font(.system(size: 12)).foregroundStyle(.white.opacity(0.7))
                    }
                } else if isLoggedIn {
                    HStack(spacing: 6) {
                        Image(systemName: "checkmark.circle.fill").foregroundStyle(.green)
                        Text(t("steamLogin.loggedInGoSub"))
                            .font(.system(size: 12)).foregroundStyle(.white.opacity(0.7))
                    }
                } else {
                    HStack(spacing: 6) {
                        Image(systemName: "info.circle").foregroundStyle(.orange)
                        Text(t("steamLogin.pleaseLoginAbove"))
                            .font(.system(size: 12)).foregroundStyle(.white.opacity(0.7))
                    }
                }
                Spacer()
                if isOnSubscriptionPage {
                    Button(t("steamLogin.confirmSync")) {
                        Task {
                            await WebViewCookieSync.syncWKWebsiteDataStoreToSharedHTTPCookieStorage()
                            if !steamID.isEmpty {
                                workshopSourceManager.steamProfileID = steamID
                                workshopSourceManager.refreshStoredSteamCredentials()
                            }
                            isPresented = false
                        }
                    }
                    .buttonStyle(.plain)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 16).padding(.vertical, 8)
                    .background(RoundedRectangle(cornerRadius: 8).fill(Color.accentColor))
                } else if isLoggedIn {
                    Button(t("steamLogin.goToSubPage")) { navigateToSubscriptionCount += 1 }
                    .buttonStyle(.plain)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 16).padding(.vertical, 8)
                    .background(RoundedRectangle(cornerRadius: 8).fill(Color.accentColor))
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
        }
        .onChange(of: currentURL) { _, newURL in urlBarText = newURL }
        .frame(width: 800, height: 650)
        .background(Color(nsColor: .windowBackgroundColor))
    }
}
