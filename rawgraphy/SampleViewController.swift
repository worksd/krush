//
//  SampleViewController.swift
//  rawgraphy
//
//  Created by 이동호 on 1/4/25.
//

import UIKit

class SampleViewController: UIViewController {
    
    private var route: String
    
    init(route: String) {
        self.route = route
        super.init(nibName: nil, bundle: nil)
        self.modalPresentationStyle = .overFullScreen
        self.modalPresentationCapturesStatusBarAppearance = true // 상태바 제어 추가

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    private func setupView() {
        view.backgroundColor = .white
        
        let label = UILabel()
        label.text = "Hello World"
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    override func loadView() {
        // 기본 뷰 생성
        let mainView = UIView()
        mainView.backgroundColor = .white
        
        // Hello World 레이블 생성
        let label = UILabel()
        label.text = "Hello World"
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        
        // 레이블을 뷰에 추가
        mainView.addSubview(label)
        
        // 레이블 제약조건 설정
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: mainView.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: mainView.centerYAnchor)
        ])
        
        // 생성한 뷰를 컨트롤러의 view로 설정
        self.view = mainView
    }
}
