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
        webView.load(URLRequest(url: url))
    }
    
    static func addKloudEventScript(to configuration: WKWebViewConfiguration) {
        let script = KloudEventScript.generate()
        let userScript = WKUserScript(source: script,
                                    injectionTime: .atDocumentEnd,
                                    forMainFrameOnly: true)
        configuration.userContentController.addUserScript(userScript)
    }
}
