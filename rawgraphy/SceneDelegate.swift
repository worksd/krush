//
//  SceneDelegate.swift
//  rawgraphy
//
//  Created by 이동호 on 1/22/25.
//

import KakaoSDKAuth
import SwiftUI


class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        if let url = URLContexts.first?.url {
            if (AuthApi.isKakaoTalkLoginUrl(url)) {
                _ = AuthController.handleOpenUrl(url: url)
            }
        }
    }
    
}
