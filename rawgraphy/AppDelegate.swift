//
//  AppDelegate.swift
//  rawgraphy
//
//  Created by 이동호 on 1/9/25.
//

import SwiftUI
import FirebaseCore
import FirebaseCrashlytics
import UserNotifications
import FirebaseMessaging
import iamport_ios
import KakaoSDKCommon
import KakaoSDKAuth
import LinkNavigator

// MARK: - AppDelegate
final class AppDelegate: UIResponder {
  let navigator = LinkNavigator(dependency: AppDependency(), builders: AppRouterGroup().routers)
}

extension AppDelegate: UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        // 파이어베이스 설정
        FirebaseApp.configure()
        
        // 앱 실행 시 사용자에게 알림 허용 권한을 받음
        UNUserNotificationCenter.current().delegate = self
        
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound] // 필요한 알림 권한을 설정
        UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions,
            completionHandler: { _, _ in }
        )
        
        // UNUserNotificationCenterDelegate를 구현한 메서드를 실행시킴
        application.registerForRemoteNotifications()
        
        // 파이어베이스 Meesaging 설정
        Messaging.messaging().delegate = self
        
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        print("AppDelegate open url=\(url.absoluteString)")
        if (AuthApi.isKakaoTalkLoginUrl(url)) {
            return AuthController.handleOpenUrl(url: url)
        }
        Iamport.shared.receivedURL(url)
        return false
      }

    // 유니버설 링크(https://...) 진입점. 웜/콜드 어느 쪽으로 들어오는지 확인용 + 실제 처리.
    func application(_ application: UIApplication,
                     continue userActivity: NSUserActivity,
                     restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        print("AppDelegate continue type=\(userActivity.activityType) url=\(String(describing: userActivity.webpageURL?.absoluteString))")
        if userActivity.activityType == NSUserActivityTypeBrowsingWeb, let url = userActivity.webpageURL {
            handleDeepLink(url)
            return true
        }
        return false
    }

    // 딥링크 공용 처리 (onOpenURL과 동일 로직) — navigator가 여기 있으므로 여기서 처리
    func handleDeepLink(_ url: URL) {
        print("handleDeepLink url=\(url.absoluteString)")
        var path: String
        if url.scheme == "https" || url.scheme == "http" {
            path = url.path
        } else {
            path = "/" + (url.host ?? "") + url.path
        }
        if let query = url.query, !query.isEmpty {
            path += "?\(query)"
        }
        guard path.count > 1 else {
            print("handleDeepLink skipped (empty path) url=\(url.absoluteString)")
            return
        }
        let encodedLink = path.addingPercentEncoding(withAllowedCharacters: .alphanumerics) ?? path
        print("handleDeepLink route=/splash?link=\(encodedLink)")
        navigator.replace(
            paths: ["web"],
            items: ["route": "/splash?link=\(encodedLink)"],
            isAnimated: false
        )
    }
    
    
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    
    // 백그라운드에서 푸시 알림을 탭했을 때 실행
    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("APNS token: \(deviceToken)")
        Messaging.messaging().apnsToken = deviceToken
    }
    
    // Foreground(앱 켜진 상태)에서도 알림 오는 설정
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        let hideNotification = userInfo["hideNotification"] as? String ?? "false"
        let endpoints = (userInfo["endpointsToRefresh"] as? String ?? "").split(separator: ",").map { String($0) }

        print("willPresent" + hideNotification)
        print("willPresent: " + endpoints.joined(separator: ", "))
        if !endpoints.isEmpty {
            NotificationCenter.default.post(
                name: Notification.Name("RefreshWebView"),
                object: nil,
                userInfo: ["endpoints": endpoints]
            )
        }
        if hideNotification == "true" {
            completionHandler([])
            return
        }

        // 이미 이미지 첨부 처리된 재발행 알림이면 그대로 표시 (무한 재발행 방지)
        if userInfo["_imageAttached"] as? Bool == true {
            completionHandler([.list, .banner, .sound])
            return
        }

        // 포그라운드에서 fcm_options.image 가 있으면 직접 다운로드 후 첨부해서 재발행
        // (NSE는 백그라운드/종료 상태에서만 호출되므로 포그라운드에선 메인 앱이 처리)
        if let fcmOptions = userInfo["fcm_options"] as? [String: Any],
           let imageURLString = fcmOptions["image"] as? String,
           let imageURL = URL(string: imageURLString) {
            presentWithImageAttachment(imageURL: imageURL, original: notification, completionHandler: completionHandler)
            return
        }

        completionHandler([.list, .banner, .sound])
    }

    private func presentWithImageAttachment(imageURL: URL,
                                            original: UNNotification,
                                            completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        URLSession.shared.downloadTask(with: imageURL) { tempURL, _, error in
            guard let tempURL else {
                print("foreground image download failed: \(String(describing: error))")
                DispatchQueue.main.async { completionHandler([.list, .banner, .sound]) }
                return
            }

            let ext = imageURL.pathExtension.isEmpty ? "jpg" : imageURL.pathExtension
            let renamedURL = tempURL.deletingPathExtension().appendingPathExtension(ext)
            try? FileManager.default.moveItem(at: tempURL, to: renamedURL)

            do {
                let attachment = try UNNotificationAttachment(identifier: "fcm-image", url: renamedURL, options: nil)

                let originalContent = original.request.content
                let content = UNMutableNotificationContent()
                content.title = originalContent.title
                content.subtitle = originalContent.subtitle
                content.body = originalContent.body
                content.sound = originalContent.sound
                content.badge = originalContent.badge
                content.categoryIdentifier = originalContent.categoryIdentifier
                content.threadIdentifier = originalContent.threadIdentifier
                content.attachments = [attachment]

                // 재발행 시 무한 루프 방지 마커 추가 + fcm_options 제거
                var newUserInfo = originalContent.userInfo
                newUserInfo["_imageAttached"] = true
                newUserInfo.removeValue(forKey: "fcm_options")
                content.userInfo = newUserInfo

                let request = UNNotificationRequest(
                    identifier: original.request.identifier + ".fg",
                    content: content,
                    trigger: nil
                )
                UNUserNotificationCenter.current().add(request) { addError in
                    if let addError {
                        print("foreground re-issue failed: \(addError)")
                    }
                }
                DispatchQueue.main.async { completionHandler([]) }
            } catch {
                print("foreground attachment creation failed: \(error)")
                DispatchQueue.main.async { completionHandler([.list, .banner, .sound]) }
            }
        }.resume()
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse) async {
        let userInfo = response.notification.request.content.userInfo
        let route = userInfo["route"] as? String ?? ""
        print("didReceive" + route)
        print(route)
        if route != "" {
            navigator.next(paths: ["web"], items: ["route": route], isAnimated: true)
        }
    }
}

extension AppDelegate: MessagingDelegate {
    
    // 파이어베이스 MessagingDelegate 설정
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
      print("Firebase registration token: \(String(describing: fcmToken))")

      let dataDict: [String: String] = ["token": fcmToken ?? ""]
      NotificationCenter.default.post(
        name: Notification.Name("FCMToken"),
        object: nil,
        userInfo: dataDict
      )
      // Note: This callback is fired at each app startup and whenever a new token is generated.
    }
}


extension UIApplication: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
}

extension UINavigationController: ObservableObject, UIGestureRecognizerDelegate {
    override open func viewDidLoad() {
        super.viewDidLoad()
        interactivePopGestureRecognizer?.delegate = self
    }

    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return viewControllers.count > 1
    }
    
    public func makeInteractivePopGesture(){

    }
}
