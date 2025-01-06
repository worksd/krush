import SwiftUI
import WebKit
import Toast

class WebViewController: UIViewController {
    private var route: String
    private var hostingController: UIHostingController<WebView>!
    
    init(route: String) {
        self.route = route
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
    }
    
    override func loadView() {
        let webView = WebView(
            route: route,
            clearAndPush: { route in
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
            },
            push: { route in
                print("push \(route)")
                let newWebViewController = WebViewController(route: route)
                newWebViewController.view.backgroundColor = .white
                self.navigationController?.pushViewController(newWebViewController, animated: true)
            }, back: {
                self.navigationController?.popViewController(animated: true)
            },
            navigateMain: { bootInfo in
                // MainViewController 생성
               let mainViewController = MainViewController(bootInfo: bootInfo)
               
               // 네비게이션 스택의 모든 뷰컨트롤러를 제거하고 새로운 루트 뷰컨트롤러 설정
               if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let window = windowScene.windows.first {
                   
                   // 애니메이션과 함께 전환
                   UIView.transition(with: window,
                                    duration: 0.3,
                                    options: .transitionCrossDissolve,
                                    animations: {
                       let navigationController = UINavigationController(rootViewController: mainViewController)
                       window.rootViewController = navigationController
                   })
               }
            }
        )
        
        hostingController = UIHostingController(rootView: webView)
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

extension WebViewController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
