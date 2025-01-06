//
//  Home.swift
//  rawgraphy
//
//  Created by 이동호 on 2025/01/01.
//
import SwiftUI
import WebKit
import Toast


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
    

    private let baseURL = "http://192.168.45.45:3000"

    init(
        route: String,
        sendBootInfo: @escaping (BootInfo) -> Void = { _ in },
        clearAndPush: @escaping (String) -> Void = { _ in },
        push: @escaping (String) -> Void = { _ in },
        replace: @escaping (String) -> Void = { _ in },
        back: @escaping () -> Void = {},
        navigateMain: @escaping (BootInfo) -> Void = { _ in }
    ) {
        self.route = route
        self.sendBootInfo = sendBootInfo
        self.clearAndPush = clearAndPush
        self.push = push
        self.replace = replace
        self.back = back
        self.navigateMain = navigateMain
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
                sendBootInfo: function(data) { sendMessage('sendBootInfo', data); },
                clearAndPush: function(data) { sendMessage('clearAndPush', data); },
                push: function(data) { sendMessage('push', data); },
                replace: function(data) { sendMessage('replace', data); },
                back: function() { sendMessage('back'); },
                clearToken: function() { sendMessage('clearToken'); },
                navigateMain: function(data) { sendMessage('navigateMain', data); },
                showToast: function(data) { sendMessage('showToast', data); }
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
            case sendBootInfo, clearAndPush, push, replace, back, navigateMain, showToast
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
            case .sendBootInfo:
                handleSendBootInfo(data: data)
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
                ToastManager.shared.showToast(message: dataString)
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
