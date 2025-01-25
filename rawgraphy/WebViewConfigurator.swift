//
//  WebViewConfigurator.swift
//  rawgraphy
//
//  Created by 이동호 on 1/24/25.
//
import WebKit

struct WebViewConfigurator {
    static func configure(_ webView: WKWebView) {
        webView.backgroundColor = .white
        webView.isOpaque = false
        webView.scrollView.backgroundColor = .white
        configureScrollView(webView.scrollView)
    }
    
    static func configureScrollView(_ scrollView: UIScrollView) {
        scrollView.bounces = false
        scrollView.alwaysBounceHorizontal = false
        scrollView.alwaysBounceVertical = false
        scrollView.isDirectionalLockEnabled = true
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 1.0
        scrollView.pinchGestureRecognizer?.isEnabled = false
    }
    
    static func loadURL(_ urlString: String, in webView: WKWebView) {
            guard let url = URL(string: urlString) else { return }
            let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "No Version"
            
            // 현재 UserAgent 가져오기
            webView.evaluateJavaScript("navigator.userAgent") { (result, error) in
                if let currentAgent = result as? String {
                    // 기존 UserAgent에 KloudNativeClient 추가
                    webView.customUserAgent = "\(currentAgent) KloudNativeClient/\(version)"
                    
                    // UserAgent 설정 후 URL 로드
                    webView.load(URLRequest(url: url))
                }
            }
        }
    
    static func addKloudEventScript(to configuration: WKWebViewConfiguration) {
        let script = KloudEventScript.generate()
        let userScript = WKUserScript(source: script,
                                    injectionTime: .atDocumentEnd,
                                    forMainFrameOnly: true)
        configuration.userContentController.addUserScript(userScript)
    }
}
