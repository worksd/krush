//
//  MainViewController.swift
//  rawgraphy
//
//  Created by 이동호 on 1/3/25.
//

import SwiftUI
import UIKit

class MainViewController: UIViewController {
    private var hostingController: UIHostingController<MainView>!
    
    private var bootInfo: BootInfo
        
    init(bootInfo: BootInfo) {
        self.bootInfo = bootInfo
        super.init(nibName: nil, bundle: nil)
        self.modalPresentationStyle = .overFullScreen
        self.modalPresentationCapturesStatusBarAppearance = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        overrideUserInterfaceStyle = .light
    }
    
    override func loadView() {
        let mainView = MainView(bootInfo: bootInfo, push: { route in
            print("push " + route)
            let newWebViewController = WebViewController(route: route)
            newWebViewController.view.backgroundColor = .white
            self.navigationController?.pushViewController(newWebViewController, animated: true)
        }, clearAndPush: { route in
            // MainViewController 생성
            let webViewController = WebViewController(route: route)
           
           // 네비게이션 스택의 모든 뷰컨트롤러를 제거하고 새로운 루트 뷰컨트롤러 설정
           if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first {
               
               // 애니메이션과 함께 전환
               UIView.transition(with: window,
                                duration: 0.3,
                                options: .transitionCrossDissolve,
                                animations: {
                   let navigationController = UINavigationController(rootViewController: webViewController)
                   window.rootViewController = navigationController
               })
           }
        })
        
        hostingController = UIHostingController(rootView: mainView)
        hostingController.view.backgroundColor = .white
        
        view = UIView(frame: UIScreen.main.bounds)
        view.backgroundColor = .white
        addChild(hostingController)

        
        hostingController.view.frame = view.bounds
        hostingController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        // SafeArea 무시하고 전체 화면 채우기
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(hostingController.view)
        
        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: view.topAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        hostingController.didMove(toParent: self)
    }
}

extension MainViewController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
