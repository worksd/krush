import SwiftUI
import WebKit
import LinkNavigator

struct RawgraphyWebView: UIViewRepresentable {
    let navigator: LinkNavigatorType
    let route: String

    // Apple 로그인 컨트롤러는 코디네이터로 주입
    private let appleController = MyAppleLoginController()

    // 세션/쿠키 공유 (탭 전환 시에도 동일 프로세스/세션 유지)
    private static let sharedProcessPool = WKProcessPool()
    @Binding var loadFailed: Bool

    func makeCoordinator() -> Coordinator {
        // WebViewCoordinator.swift 에서 정의한 Coordinator(navigator:appleController:) 사용
        Coordinator(navigator: navigator, appleController: appleController, onLoadFailedChange: { failed in
            // 메인쓰레드에서 상태 반영
            DispatchQueue.main.async {
                self.loadFailed = failed
            }
        })
    }

    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.processPool = Self.sharedProcessPool

        // 스크립트/메시지 채널 등록 (여기서 1회)
        config.userContentController.add(context.coordinator, name: "KloudEvent")
        WebViewConfigurator.addKloudEventScript(to: config)

        let webView = WKWebView(frame: .zero, configuration: config)
        webView.scrollView.contentInsetAdjustmentBehavior = .automatic
        WebViewConfigurator.configure(webView)

        // 코디네이터에 실제 인스턴스 바인딩 (웹 ↔ 네이티브 이벤트용)
        context.coordinator.bind(webView)

        // 최초 로드
        let defaultBase = "https://rawgraphy.com"
//        let defaultBase = "http://192.168.45.7:3000"
        let baseURL = UserDefaults.standard.string(forKey: "endpoint") ?? defaultBase
        
        WebViewConfigurator.loadURL("\(baseURL)\(route)", in: webView)

        print("makeUIView 생성: \(route)")
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        // route 변경 시에만 필요하다면 여기서 처리 (현재는 no-op)
    }

    static func dismantleUIView(_ uiView: WKWebView, coordinator: Coordinator) {
        // 중복 핸들러 방지용 정리
        uiView.configuration.userContentController.removeScriptMessageHandler(forName: "KloudEvent")
    }
}
