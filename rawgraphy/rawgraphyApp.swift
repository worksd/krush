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
            if (AuthApi.isKakaoTalkLoginUrl(url)) {
                _ = AuthController.handleOpenUrl(url: url)
                return
            }

            // 딥링크 처리: rawgraphy://lessons/1638 → /splash?link=/lessons/1638
            let path = "/" + (url.host ?? "") + url.path
            if path.count > 1 {
                navigator.replace(
                    paths: ["web"],
                    items: ["route": "/splash?link=\(path)"],
                    isAnimated: false
                )
            }
        }
    }
  }
    
    func setUpDependencies() {
        SDImageCodersManager.shared.addCoder(SDImageSVGCoder.shared)
    }
}
