//
//  ToastManager.swift
//  rawgraphy
//
//  Created by 이동호 on 1/5/25.
//

import UIKit
import Toast

class ToastManager {
    static let shared = ToastManager()
    
    // toastWindow 속성 선언 추가
    private var toastWindow: UIWindow? = nil
    
    private init() {} // private 생성자
    
    func showToast(message: String) {
        DispatchQueue.main.async {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                // 기존 토스트 윈도우가 있다면 제거
                self.toastWindow?.isHidden = true
                self.toastWindow = nil
                
                // 새로운 윈도우 생성
                let window = UIWindow(windowScene: windowScene)
                window.backgroundColor = .clear
                window.windowLevel = .alert + 100 // 매우 높은 윈도우 레벨 설정
                window.isUserInteractionEnabled = false // 터치 이벤트 무시
                
                let toastVC = UIViewController()
                toastVC.view.backgroundColor = .clear
                window.rootViewController = toastVC
                window.makeKeyAndVisible()
                
                // 토스트 스타일 설정
                var style = ToastStyle()
                style.backgroundColor = UIColor.black.withAlphaComponent(0.7)
                style.messageColor = .white
                style.messageFont = .systemFont(ofSize: 14)
                 
                // 토스트 표시
                toastVC.view.makeToast(message,
                                     duration: 3,
                                     position: .bottom,
                                     style: style) { _ in
                    // 토스트가 사라진 후 윈도우 제거
                    self.toastWindow = nil
                }
                
                self.toastWindow = window
            }
        }
    }
}
