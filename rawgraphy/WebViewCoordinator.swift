// WebViewCoordinator.swift
import WebKit
import KakaoSDKUser
import PortOneSdk
import LinkNavigator
import Toast
import FirebaseMessaging

extension RawgraphyWebView {
    class Coordinator: NSObject, WKScriptMessageHandler, WKNavigationDelegate {

        enum KloudEventType: String {
            case clearAndPush, push, replace, back, navigateMain, showToast, rootNext, fullSheet, showBottomSheet, closeBottomSheet, refresh
            case sendAppleLogin, sendHapticFeedback, sendKakaoLogin, showDialog, changeWebEndpoint, openExternalBrowser
            case requestPayment, registerDevice
        }

        // 👇 변경 포인트
        private weak var webView: WKWebView?
        private let navigator: LinkNavigatorType
        private let appleController: MyAppleLoginController
        private var isFcmTokenSent = false
        private let onLoadFailedChange: (Bool) -> Void


        init(navigator: LinkNavigatorType,
             appleController: MyAppleLoginController,
             onLoadFailedChange: @escaping (Bool) -> Void) {
            self.navigator = navigator
            self.appleController = appleController
            self.onLoadFailedChange = onLoadFailedChange
        }

        // makeUIView에서 생성된 실제 인스턴스를 바인딩
        func bind(_ webView: WKWebView) {
            self.webView = webView
        }

        // MARK: - WKScriptMessageHandler
        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            guard let body = message.body as? [String: Any],
                  let typeString = body["type"] as? String,
                  let type = KloudEventType(rawValue: typeString) else { return }

            print(type.rawValue + " : " + String(describing: body))
            handleEvent(type: type, data: body["data"])
        }
        
        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            onLoadFailedChange(false)
        }
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            onLoadFailedChange(false)
        }
        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            print("❌ didFailProvisionalNavigation:", error.localizedDescription)
            onLoadFailedChange(true)
        }
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            print("❌ didFail:", error.localizedDescription)
            onLoadFailedChange(true)
        }

        private func handleEvent(type: KloudEventType, data: Any?) {
            switch type {
            case .clearAndPush:      handleClearAndPush(data)
            case .refresh:           handleRefresh(data)
            case .fullSheet:         handleFullSheet(data)
            case .push:              handlePush(data)
            case .rootNext:          handleRootNext(data)
            case .replace:           handleReplace(data)
            case .back:              navigator.back(isAnimated: true)
            case .showToast:         handleShowToast(data)
            case .navigateMain:      handleNavigateMain(data)
            case .sendAppleLogin:    handleAppleLogin()
            case .sendHapticFeedback:HapticManager.shared.createImpact()
            case .sendKakaoLogin:    handleKakaoLogin()
            case .showDialog:        handleShowDialog(data)
            case .requestPayment:    handlePayment(data)
            case .registerDevice:    sendFcmToken()
            case .showBottomSheet:   showBottomSheet(data)
            case .closeBottomSheet:  closeBottomSheet()
            case .changeWebEndpoint: handleWebEndpoint(data)
            case .openExternalBrowser: handleOpenExternalBrowser(data)
            }
        }

        // ………… 이하 로직은 기존과 동일하되,
        // parent.navigator → navigator
        // parent.appleController → appleController
        // WebEventHandler.sendWebEvent(... parent.webView) → self.webView

        private func handleWebEndpoint(_ data: Any?) {
            guard let endpoint = data as? String else { return }
            UserDefaults.standard.set(endpoint, forKey: "endpoint")
        }

        private func handleOpenExternalBrowser(_ data: Any?) {
            guard let url = data as? String, let u = URL(string: url) else { return }
            UIApplication.shared.open(u)
        }

        private func showBottomSheet(_ data: Any?) {
            guard let route = data as? String else { return }
            navigator.customSheet(
                paths: ["web"],
                items: ["route" : route],
                isAnimated: true,
                iPhonePresentationStyle: .popover,
                iPadPresentationStyle: .popover,
                prefersLargeTitles: .none
            )
        }

        private func closeBottomSheet() {
            navigator.close(isAnimated: true) { }
        }

        private func handleClearAndPush(_ data: Any?) {
            guard let route = data as? String else { return }
            navigator.replace(paths: ["web"], items: ["route": route], isAnimated: true)
        }

        private func handleRefresh(_ data: Any?) {
            guard let route = data as? String else { return }
            navigator.rootReloadLast(items: ["route": route], isAnimated: true)
        }

        private func handleFullSheet(_ data: Any?) {
            guard let route = data as? String else { return }
            navigator.fullSheet(paths: ["web"], items: ["route": route], isAnimated: true, prefersLargeTitles: false)
        }

        private func handlePush(_ data: Any?) {
            guard let routeInfo = data as? String else { return }
            navigator.next(paths: ["web"], items: ["route": routeInfo], isAnimated: true)
        }

        private func handleRootNext(_ data: Any?) {
            guard let route = data as? String else { return }
            navigator.rootNext(paths: ["web"], items: ["route": route], isAnimated: true)
        }

        private func handleReplace(_ data: Any?) {
            guard let route = data as? String else { return }
            navigator.replace(paths: ["web"], items: ["route": route], isAnimated: true)
        }

        private func handleShowToast(_ data: Any?) {
            guard let _ = data as? String else { return }
            // TODO: 토스트 처리
        }

        private func handleNavigateMain(_ data: Any?) {
            guard let dataString = data as? String else { return }
            let bootInfo = (try? JSONDecoder().decode(BootInfo.self, from: Data(dataString.utf8)))
                ?? BootInfo(bottomMenuList: [], route: "")
            if bootInfo.route.isEmpty {
                navigator.replace(paths: ["main"], items: ["bootInfo": dataString], isAnimated: true)
            } else {
                navigator.replace(paths: ["main", "web"],
                                  items: ["bootInfo": dataString, "route": bootInfo.route],
                                  isAnimated: true)
            }
        }

        private func handleAppleLogin() {
            print("sendAppleLogin")
            appleController.showAppleLogin(onSuccessAppleLogin: { [weak self] code, name in
                self?.sendWebEvent(functionName: "onAppleLoginSuccess", data: ["code": code, "name": name])
            })
        }

        private func handleKakaoLogin() {
            if (UserApi.isKakaoTalkLoginAvailable()) {
                UserApi.shared.loginWithKakaoTalk { [weak self] (oauthToken, error) in
                    if let error = error {
                        print("카카오톡 로그인 에러", error)
                    } else {
                        self?.sendWebEvent(functionName: "onKakaoLoginSuccess",
                                           data: ["code": oauthToken?.accessToken ?? ""])
                    }
                }
            } else {
                UserApi.shared.loginWithKakaoAccount { [weak self] (oauthToken, error) in
                    if let error = error {
                        print("카카오계정 로그인 에러", error)
                    } else {
                        self?.sendWebEvent(functionName: "onKakaoLoginSuccess",
                                           data: ["code": oauthToken?.accessToken ?? ""])
                    }
                }
            }
        }

        private func onClickDialog (dialogInfo: KloudDialogInfo) {
            sendWebEvent(functionName: "onDialogConfirm", data: [
                "id": dialogInfo.id,
                "type": dialogInfo.type,
                "route": dialogInfo.route,
                "hideForeverMessage": dialogInfo.hideForeverMessage,
                "imageUrl": dialogInfo.imageUrl,
                "imageRatio": dialogInfo.imageRatio,
                "title": dialogInfo.title,
                "message": dialogInfo.message,
                "ctaButtonText": dialogInfo.ctaButtonText,
                "customData": dialogInfo.customData
            ])
        }

        private func handleShowDialog(_ data: Any?) {
            guard let dataString = data as? String else { return }
            do {
                let dialogInfo = try JSONDecoder().decode(KloudDialogInfo.self, from: Data(dataString.utf8))
                if dialogInfo.type == KloudDialogType.image.rawValue {
                    showDialog(dialogInfo: dialogInfo)
                } else if dialogInfo.type == KloudDialogType.simple.rawValue {
                    let alertModel = Alert(
                        title: dialogInfo.title,
                        message: dialogInfo.message,
                        buttons: [.init(title: dialogInfo.confirmTitle, style: .default, action: {
                            self.onClickDialog(dialogInfo: dialogInfo)
                        })],
                        flagType: .default
                    )
                    navigator.alert(target: .default, model: alertModel)
                } else if dialogInfo.type == KloudDialogType.yesOrNo.rawValue {
                    let alertModel = Alert(
                        title: dialogInfo.title,
                        message: dialogInfo.message,
                        buttons: [
                            .init(title: dialogInfo.confirmTitle, style: .default, action: {
                                self.onClickDialog(dialogInfo: dialogInfo)
                            }),
                            .init(title: dialogInfo.cancelTitle, style: .cancel, action: {})
                        ],
                        flagType: .default
                    )
                    navigator.alert(target: .default, model: alertModel)
                }
            } catch {
                print("❌ Dialog parsing error:", error)
            }
        }

        private func showDialog(dialogInfo: KloudDialogInfo) {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first,
               let root = window.rootViewController {
                root.showImageDialog(
                    id: dialogInfo.id,
                    hideForeverMessage: dialogInfo.hideForeverMessage,
                    imageUrl: dialogInfo.imageUrl ?? "",
                    imageRatio: dialogInfo.imageRatio ?? 1.0,
                    ctaButtonText: dialogInfo.ctaButtonText,
                    onDismiss: {},
                    onClick: { [weak self] _ in
                        self?.onClickDialog(dialogInfo: dialogInfo)
                    },
                    onClickHideDialog: { [weak self] id, isHidden in
                        self?.sendWebEvent(functionName: "onHideDialogConfirm",
                                           data: ["id": id, "clicked": isHidden])
                    }
                )
            }
        }
        
        private func topMostViewController() -> UIViewController? {
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let window = windowScene.windows.first,
                  var top = window.rootViewController else { return nil }

            while let presented = top.presentedViewController { top = presented }
            return top
        }

        private func handlePayment(_ data: Any?) {
            guard let dataString = data as? String,
                  let top = topMostViewController() else { return }

            do {
                let info = try JSONDecoder().decode(PaymentInfo.self, from: Data(dataString.utf8))

                let params: [String: Any] = [
                    "storeId": info.storeId,
                    "channelKey": info.channelKey,
                    "paymentId": info.paymentId,
                    "orderName": info.orderName,
                    "totalAmount": info.price,
                    "customer":  [
                        "fullName": info.userId
                    ],
                    "currency": "KRW",
                    "payMethod": "CARD",
                    "appScheme": "rawgraphy://"
                ]

                DispatchQueue.main.async(execute: { [weak self] in
                    guard let self = self else { return }

                    MyPortOneLauncher.present(from: top, params: params, onCompletion: { result in
                        switch result {
                        case .success(let payload):
                            print("결제 성공: \(payload)")
                            self.sendWebEvent(functionName: "onPaymentSuccess",
                                              data: ["paymentId": payload.paymentId])

                        case .failure(let error):
                            print("결제 실패: \(error)")
                            self.sendWebEvent(functionName: "onErrorInvoked",
                                              data: ["paymentId": info.paymentId,
                                                     "message": error.localizedDescription])
                        }
                    })
                })
            } catch {
                print("❌ Payment parsing error:", error)
            }
        }

        private func sendFcmToken() {
            Messaging.messaging().token { [weak self] token, error in
                if let error = error {
                    print("Error fetching FCM token: \(error)")
                    return
                }
                let udid = UIDevice.current.identifierForVendor?.uuidString ?? ""
                self?.sendWebEvent(functionName: "onFcmTokenComplete",
                                   data: ["fcmToken": token ?? "", "udid": udid])
            }
        }

        private func sendWebEvent(functionName: String, data: [String: Any]) {
            print("functionName = \(functionName)")
            print("data = \(data)")
            guard let webView else { return }
            WebEventHandler.sendWebEvent(functionName: functionName, data: data, webView: webView)
        }
    }
}
