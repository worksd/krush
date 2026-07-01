//
//  rawgraphyApp.swift
//  rawgraphy
//
//  Created by 이동호 on 2024/12/25.
//

import SwiftUI
import KakaoSDKAuth
import KakaoSDKCommon
import SDWebImageSVGCoder
import LinkNavigator
import iamport_ios

@main
struct AppMain: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var navigator: LinkNavigator {
      delegate.navigator
    }
    
    init() {
        UITabBar.appearance().backgroundColor = UIColor.white
        KakaoSDK.initSDK(appKey: "198ee4b72a3466ab10d4b1ff27bbc695")
        setUpDependencies()
        
    }

  var body: some Scene {
    WindowGroup {
        ZStack {
            navigator.launch(paths: ["web"], items: ["route": "/splash"]).edgesIgnoringSafeArea(.all).background(.white)
        }.onOpenURL { url in
            print("onOpenURL url=\(url.absoluteString)")
            if (AuthApi.isKakaoTalkLoginUrl(url)) {
                _ = AuthController.handleOpenUrl(url: url)
                return
            }
            // 커스텀 스킴 딥링크 (rawgraphy://...) — 공용 핸들러로 처리
            delegate.handleDeepLink(url)
        }
        // 유니버설 링크 (https://...)는 onOpenURL이 아니라 이쪽으로 들어옴 (NSUserActivity)
        .onContinueUserActivity(NSUserActivityTypeBrowsingWeb) { activity in
            print("onContinueUserActivity url=\(String(describing: activity.webpageURL?.absoluteString))")
            if let url = activity.webpageURL {
                delegate.handleDeepLink(url)
            }
        }
    }
  }
    
    func setUpDependencies() {
        SDImageCodersManager.shared.addCoder(SDImageSVGCoder.shared)
    }
}
