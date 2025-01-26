//
//  WebViewCoordinator.swift
//  rawgraphy
//
//  Created by 이동호 on 1/24/25.
//
import WebKit
import KakaoSDKUser
import iamport_ios
import LinkNavigator
import Toast

extension RawgraphyWebView {
    class Coordinator: NSObject, WKScriptMessageHandler {
        enum KloudEventType: String {
            case clearAndPush, push, replace, back, navigateMain, showToast, rootNext
            case sendAppleLogin, sendHapticFeedback, sendKakaoLogin, showDialog
            case requestPayment
        }

        var parent: RawgraphyWebView

        init(_ parent: RawgraphyWebView) {
            self.parent = parent
        }

        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            guard let body = message.body as? [String: Any],
                  let typeString = body["type"] as? String,
                  let type = KloudEventType(rawValue: typeString) else {
                return
            }
            print(type.rawValue + " : " + String(describing: body))
            handleEvent(type: type, data: body["data"])
        }

        private func handleEvent(type: KloudEventType, data: Any?) {
            switch type {
                case .clearAndPush:
                    handleClearAndPush(data)
                case .push:
                    handlePush(data)
                case .rootNext:
                    handleRootNext(data)
                case .replace:
                    handleReplace(data)
                case .back:
                    parent.navigator.back(isAnimated: true)
                case .showToast:
                    handleShowToast(data)
                case .navigateMain:
                    handleNavigateMain(data)
                case .sendAppleLogin:
                    handleAppleLogin()
                case .sendHapticFeedback:
                    HapticManager.shared.createImpact()
                case .sendKakaoLogin:
                    handleKakaoLogin()
                case .showDialog:
                    handleShowDialog(data)
                case .requestPayment:
                    handlePayment(data)
            }
        }

        private func handleClearAndPush(_ data: Any?) {
            guard let route = data as? String else {
                print("❌ Invalid data for string event")
                return
            }
            parent.navigator.replace(paths: ["web"], items: ["route": route], isAnimated: true)
        }

        private func handlePush(_ data: Any?) {
            guard let route = data as? String else {
                print("❌ Invalid data for string event")
                return
            }
            print("handle push " + route)
            parent.navigator.next(paths: ["web"], items: ["route": route], isAnimated: true)
        }
        
        private func handleRootNext(_ data: Any?) {
            guard let route = data as? String else {
                print("❌ Invalid data for string event")
                return
            }
            parent.navigator.rootNext(paths: ["web"], items: ["route": route], isAnimated: true)
        }

        private func handleReplace(_ data: Any?) {
            guard let route = data as? String else {
                print("❌ Invalid data for string event")
                return
            }
            parent.navigator.replace(paths: ["web"], items: ["route": route], isAnimated: true)
        }

        private func handleShowToast(_ data: Any?) {
            guard let dataString = data as? String else {
                print("❌ Invalid data for string event")
                return
            }
           // TODO: 토스트 메시지 구현
        }

        private func handleNavigateMain(_ data: Any?) {
            guard let dataString = data as? String,
                  let jsonData = dataString.data(using: .utf8) else {
                print("❌ Invalid data for sendBootInfo")
                return
            }
            let bootInfo = (try? JSONDecoder().decode(BootInfo.self, from: dataString)) ?? BootInfo(bottomMenuList: [], route: "")
            if bootInfo.route == "" {
                parent.navigator.replace(paths: ["main"], items: ["bootInfo": dataString], isAnimated: true)
            } else {
                parent.navigator.replace(paths: ["main", "web"], items: ["bootInfo": dataString, "route": bootInfo.route], isAnimated: true)
            }
        }

        private func handleAppleLogin() {
            print("sendAppleLogin")
            parent.appleController.showAppleLogin(onSuccessAppleLogin: { code in
                self.sendWebEvent(functionName: "onAppleLoginSuccess", data: ["code": code])
            })
        }

        private func handleKakaoLogin() {
            if (UserApi.isKakaoTalkLoginAvailable()) {
                UserApi.shared.loginWithKakaoTalk { [weak self] (oauthToken, error) in
                    if let error = error {
                        print("카카오톡 로그인 에러")
                        print(error)
                    } else {
                        print("loginWithKakaoTalk() success.")
                        self?.sendWebEvent(
                            functionName: "onKakaoLoginSuccess",
                            data: ["code": oauthToken?.accessToken ?? ""]
                        )
                    }
                }
            } else {
                UserApi.shared.loginWithKakaoAccount { [weak self] (oauthToken, error) in
                    if let error = error {
                        print("카카오계정 로그인 에러")
                        print(error)
                    } else {
                        print("loginWithKakaoAccount() success.")
                        self?.sendWebEvent(
                            functionName: "onKakaoLoginSuccess",
                            data: ["code": oauthToken?.accessToken ?? ""]
                        )
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
                "ctaButtonText": dialogInfo.ctaButtonText
            ])
        }

        private func handleShowDialog(_ data: Any?) {
            guard let dataString = data as? String else {
                print("❌ Invalid data type for DialogInfo")
                return
            }

            print("rawString = \(dataString)")

            do {
                let dialogInfo = try JSONDecoder().decode(KloudDialogInfo.self, from: dataString.data(using: .utf8) ?? Data())
                if dialogInfo.type == KloudDialogType.image.rawValue {
                    showDialog(dialogInfo: dialogInfo)
                } else if dialogInfo.type == KloudDialogType.simple.rawValue {
                    let alertModel = Alert(
                        title: dialogInfo.title,
                        message: dialogInfo.message,
                        buttons: [.init(title: "확인", style: .default, action: {})],
                        flagType: .default
                    )
                    parent.navigator.alert(target: .default, model: alertModel)
                } else if dialogInfo.type == KloudDialogType.yesOrNo.rawValue {
                    let alertModel = Alert(
                        title: dialogInfo.title,
                        message: dialogInfo.message,
                        buttons: [.init(title: "확인", style: .default, action: {
                            self.onClickDialog(dialogInfo: dialogInfo)
                        }), .init(title: "취소", style: .cancel, action: {})],
                        flagType: .default
                    )
                    parent.navigator.alert(target: .default, model: alertModel)
                }
            } catch {
                print("❌ Dialog parsing error:", error)
            }
        }
        
        private func showDialog(dialogInfo: KloudDialogInfo) {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                           let window = windowScene.windows.first,
                           let rootViewController = window.rootViewController {
                            
                            rootViewController.showImageDialog(
                                id: dialogInfo.id,
                                hideForeverMessage: dialogInfo.hideForeverMessage,
                                imageUrl: dialogInfo.imageUrl ?? "",
                                imageRatio: dialogInfo.imageRatio ?? 1.0,
                                ctaButtonText: dialogInfo.ctaButtonText,
                                onDismiss: {},
                                onClick: { [weak self] id in
                                    self?.onClickDialog(dialogInfo: dialogInfo)
                                },
                                onClickHideDialog: { [weak self] id, isHidden in
                                    self?.sendWebEvent(
                                        functionName: "onHideDialogConfirm",
                                        data: [
                                            "id": id,
                                            "clicked": isHidden
                                        ]
                                    )
                                }
                            )
                        }
        }

        private func handlePayment(_ data: Any?) {
            guard let dataString = data as? String else {
                print("❌ Invalid data type for DialogInfo")
                return
            }
            
            do {
                let paymentInfo = try JSONDecoder().decode(PaymentInfo.self, from: dataString.data(using: .utf8) ?? Data())
                let payment = IamportPayment(
                    pg: paymentInfo.pg,
                    merchant_uid: paymentInfo.paymentId,
                    amount: paymentInfo.amount
                ).then {
                    $0.pay_method = paymentInfo.method
                    $0.name = paymentInfo.orderName
                    $0.buyer_name = paymentInfo.userId
                    $0.app_scheme = paymentInfo.scheme
                }

                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let window = windowScene.windows.first,
                   let rootViewController = window.rootViewController {
                    
                    Iamport.shared.payment(
                        viewController: rootViewController,
                        userCode: paymentInfo.userCode,
                        payment: payment
                    ) { [weak self] response in
                        if response?.success == true {
                            self?.sendWebEvent(
                                functionName: "onPaymentSuccess",
                                data: [
                                    "paymentId": response?.merchant_uid,
                                    "transactionId": response?.imp_uid
                                ]
                            )
                        } else {
                            self?.sendWebEvent(functionName: "onErrorInvoked", data: ["code": response?.error_code])
                        }
                    }
                }
            } catch {
                print("❌ Payment parsing error:", error)
            }
        }

        private func sendWebEvent(functionName: String, data: [String: Any]) {
            WebEventHandler.sendWebEvent(functionName: functionName, data: data, webView: parent.webView)
        }
    }
}
