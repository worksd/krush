import SwiftUI
import WebKit
import LinkNavigator

struct RawgraphyWebView: UIViewRepresentable {
    let navigator: LinkNavigatorType
    let appleController = MyAppleLoginController()
    let route: String
    
    // 웹뷰를 private이 아닌 internal로 변경
    var webView: WKWebView
    
    init(navigator: LinkNavigatorType, route: String) {
        self.navigator = navigator
        self.route = route
        
        let configuration = WKWebViewConfiguration()
        let webView = WKWebView(frame: .zero, configuration: configuration)
        self.webView = webView
        
        // Coordinator 생성 및 설정
        let coordinator = Coordinator(self)
        configuration.userContentController.add(coordinator, name: "KloudEvent")
        
        WebViewConfigurator.addKloudEventScript(to: configuration)
        WebViewConfigurator.configure(webView)
        let defaultUrl = "https://rawgraphy.com"
        let baseURL = UserDefaults.standard.string(forKey: "endpoint") ?? defaultUrl
        WebViewConfigurator.loadURL(baseURL + route, in: webView)
//        WebViewConfigurator.loadURL("http://192.168.0.12:3000" + route, in: webView)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: Context) -> WKWebView {
        NotificationCenter.default.addObserver(forName: Notification.Name("RefreshWebView"),
                                               object: nil,
                                               queue: .main) { notification in
            print("📬 Received RefreshWebView notification")

            guard let userInfo = notification.userInfo else {
                print("⚠️ No userInfo found in notification")
                return
            }

            print("📦 userInfo: \(userInfo)")

            guard let endpoints = userInfo["endpoints"] as? [String] else {
                print("⚠️ 'endpoints' not found or not a [String] in userInfo")
                return
            }

            guard let fullURL = webView.url,
                  let components = URLComponents(url: fullURL, resolvingAgainstBaseURL: false) else {
                print("⚠️ WebView URL is nil or malformed")
                return
            }

            let path = components.path
            let query = components.query
            let pathAndQuery = query != nil ? "\(path)?\(query!)" : path

            print("🌐 Full WebView URL: \(fullURL.absoluteString)")
            print("🧩 Parsed path + query: \(pathAndQuery)")
            print("🗂️ Endpoints to refresh: \(endpoints)")

            let matched = endpoints.filter { pathAndQuery.hasPrefix($0) }

            if !matched.isEmpty {
                print("✅ Match found! Matching endpoint(s): \(matched)")
                print("🔁 Reloading WebView...")
                webView.reload()
            } else {
                print("❌ No matching endpoint. Skipping reload.")
            }
        }

        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {}
}
