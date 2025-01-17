//
//  Home.swift
//  rawgraphy
//
//  Created by 이동호 on 2025/01/01.
//
import SwiftUI
import WebKit

struct WebView: UIViewRepresentable {
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    let route: String

    var sendBootInfo: ((BootInfo) -> Void)
    var clearAndPush: (String) -> Void
    var navigateMain: (BootInfo) -> Void
    var push: (String) -> Void
    var replace: (String) -> Void
    var back: () -> Void
    var sendAppleLogin: () -> Void

    private let baseURL = "http://192.168.0.18:3000"

    init(
        route: String,
        sendBootInfo: @escaping (BootInfo) -> Void = { _ in },
        clearAndPush: @escaping (String) -> Void = { _ in },
        push: @escaping (String) -> Void = { _ in },
        replace: @escaping (String) -> Void = { _ in },
        back: @escaping () -> Void = {},
        navigateMain: @escaping (BootInfo) -> Void = { _ in },
        sendAppleLogin: @escaping () -> Void = {}
    ) {
        self.route = route
        self.sendBootInfo = sendBootInfo
        self.clearAndPush = clearAndPush
        self.push = push
        self.replace = replace
        self.back = back
        self.navigateMain = navigateMain
        self.sendAppleLogin = sendAppleLogin
    }

    func makeUIView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        configuration.userContentController.add(context.coordinator, name: "KloudEvent")
        
        addKloudEventScript(to: configuration)

        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.backgroundColor = .white
        webView.isOpaque = false // 투명도 제거
        
        // 스크롤뷰 배경색도 흰색으로 설정
        webView.scrollView.backgroundColor = .white
        configureWebView(webView)
        loadURL(in: webView)
        
        WebViewContainer.shared.webView = webView
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        loadURL(in: uiView)
    }

    private func addKloudEventScript(to configuration: WKWebViewConfiguration) {
        let script = """
            var meta = document.createElement('meta');
            meta.name = 'viewport';
            meta.content = 'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no';
            document.getElementsByTagName('head')[0].appendChild(meta);
            window.KloudEvent = {
                clearAndPush: function(data) { sendMessage('clearAndPush', data); },
                push: function(data) { sendMessage('push', data); },
                replace: function(data) { sendMessage('replace', data); },
                back: function() { sendMessage('back'); },
                clearToken: function() { sendMessage('clearToken'); },
                navigateMain: function(data) { sendMessage('navigateMain', data); },
                showToast: function(data) { sendMessage('showToast', data); },
                sendHapticFeedback: function() { sendMessage('sendHapticFeedback'); },
                sendAppleLogin: function() { sendMessage('sendAppleLogin'); }
            };

            function sendMessage(type, data = null) {
                window.webkit.messageHandlers.KloudEvent.postMessage({ type, data });
            }
        """
        let userScript = WKUserScript(source: script, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        configuration.userContentController.addUserScript(userScript)
    }

    private func configureWebView(_ webView: WKWebView) {
        webView.scrollView.bounces = false
        webView.scrollView.alwaysBounceHorizontal = false
        webView.scrollView.alwaysBounceVertical = false
        webView.scrollView.isDirectionalLockEnabled = true
        webView.scrollView.minimumZoomScale = 1.0
        webView.scrollView.maximumZoomScale = 1.0
        webView.scrollView.pinchGestureRecognizer?.isEnabled = false
    }

    private func loadURL(in webView: WKWebView) {
        guard let url = URL(string: baseURL + route) else { return }
        webView.load(URLRequest(url: url))
    }
}

// MARK: - Coordinator
extension WebView {
    class Coordinator: NSObject, WKScriptMessageHandler {
        enum KloudEventType: String {
            case clearAndPush, push, replace, back, navigateMain, showToast, sendAppleLogin, sendHapticFeedback
        }

        var parent: WebView

        init(_ parent: WebView) {
            self.parent = parent
        }

        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            guard let body = message.body as? [String: Any],
                  let typeString = body["type"] as? String,
                  let type = KloudEventType(rawValue: typeString) else {
                return
            }
            
            print(body["data"]!)
            print(typeString)

            handleEvent(type: type, data: body["data"])
        }

        private func handleEvent(type: KloudEventType, data: Any?) {
            switch type {
            case .clearAndPush:
                guard let dataString = data as? String else {
                    print("❌ Invalid data for string event")
                    return
                }
                self.parent.clearAndPush(dataString)
            case .push:
                guard let dataString = data as? String else {
                    print("❌ Invalid data for string event")
                    return
                }
                self.parent.push(dataString)
            case .replace:
                handleStringEvent(data: data, action: parent.replace)
            case .back:
                DispatchQueue.main.async { self.parent.back() }
            case .showToast:
                guard let dataString = data as? String else {
                    print("❌ Invalid data for string event")
                    return
                }
                // TODO : 토스트 보여주기
                
            case .navigateMain:
                guard let dataString = data as? String,
                      let jsonData = dataString.data(using: .utf8) else {
                    print("❌ Invalid data for sendBootInfo")
                    return
                }
                do {
                    let bootInfo = try JSONDecoder().decode(BootInfo.self, from: jsonData)
                    DispatchQueue.main.async { self.parent.navigateMain(bootInfo) }
                } catch {
                    print("❌ Parsing error:", error)
                }
                case .sendAppleLogin:
                    self.parent.sendAppleLogin()
                case .sendHapticFeedback:
                    HapticManager().createImpact()
            }

            
        }

        private func handleSendBootInfo(data: Any?) {
            guard let dataString = data as? String,
                  let jsonData = dataString.data(using: .utf8) else {
                print("❌ Invalid data for sendBootInfo")
                return
            }

            do {
                let bootInfo = try JSONDecoder().decode(BootInfo.self, from: jsonData)
                DispatchQueue.main.async { self.parent.sendBootInfo(bootInfo) }
            } catch {
                print("❌ Parsing error:", error)
            }
        }

        private func handleStringEvent(data: Any?, action: ((String) -> Void)?) {
            guard let dataString = data as? String else {
                print("❌ Invalid data for string event")
                return
            }
            DispatchQueue.main.async { action?(dataString) }
        }
        
    }
}

class HapticManager {
    static let shared = HapticManager()
    
    private var generator: UIImpactFeedbackGenerator?
    
    init() {
        setupGenerator()
    }
    
    func setupGenerator() {
        generator = UIImpactFeedbackGenerator()
        generator?.prepare()
    }
    
    func createImpact(style: UIImpactFeedbackGenerator.FeedbackStyle = .heavy) {
        generator?.impactOccurred()
    }
    
    func release() {
        generator = nil
    }
}


class WebViewContainer {
    static let shared = WebViewContainer()
    var webView: WKWebView?
    
    private init() {}
    
    func sendWebEvent(functionName: String, data: [String: Any]) {
        print("sendWebEvent \(functionName), \(data)")
        guard let webView = self.webView else { return }
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: data, options: [])
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                DispatchQueue.main.async {
                    let script = "javascript:\(functionName)(\(jsonString));"
                    webView.evaluateJavaScript(script) { (result, error) in
                        if let error = error {
                            print("에러: \(error.localizedDescription)")
                        }
                    }
                }
            }
        } catch {
            print("에러: \(error.localizedDescription)")
        }
    }
}
