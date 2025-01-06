//
//  rawgraphyApp.swift
//  rawgraphy
//
//  Created by 이동호 on 2024/12/25.
//

import SwiftUI

@main
struct AppMain: App {
    
    init() {
        UITabBar.appearance().backgroundColor = UIColor.white
        
    }

  var body: some Scene {
    WindowGroup {
        ZStack {
            WebView(
                route: "/splash",
                clearAndPush: { route in
                    print(route)
                    
                    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                       let window = windowScene.windows.first,
                       let rootViewController = window.rootViewController {
                        
                        let webViewController = WebViewController(route: route)
                        let navigationController = UINavigationController(rootViewController: webViewController)
                        navigationController.modalPresentationStyle = .fullScreen
                        rootViewController.view.backgroundColor = .white
                        rootViewController.present(navigationController, animated: true)
                    }
                },
                navigateMain: { bootInfo in
                    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                       let window = windowScene.windows.first,
                       let rootViewController = window.rootViewController {
                        
                        let webViewController = MainViewController(bootInfo: bootInfo)
                        let navigationController = UINavigationController(rootViewController: webViewController)
                        navigationController.modalPresentationStyle = .fullScreen
                        rootViewController.view.backgroundColor = .white
                        rootViewController.present(navigationController, animated: true)
                        
                    }
                }
            )
            ZStack {
                Color.black
                Image("Logo")
            }
        }
    }
  }
}
