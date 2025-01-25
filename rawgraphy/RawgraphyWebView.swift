import SwiftUI
import WebKit
import KakaoSDKUser
import LinkNavigator
import AuthenticationServices
import iamport_ios

struct RawgraphyWebView: UIViewRepresentable {
    let navigator: LinkNavigatorType
    let appleController = MyAppleLoginController()
    let route: String
    
    // 웹뷰를 private이 아닌 internal로 변경
    var webView: WKWebView
//    private let baseURL = "http://192.168.45.138:3000"
    private let baseURL = "https://kloud-alpha.vercel.app"
    
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
        WebViewConfigurator.loadURL(baseURL + route, in: webView)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: Context) -> WKWebView {
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {}
}
