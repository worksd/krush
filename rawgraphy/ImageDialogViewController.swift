//
//  ImageDialogViewController.swift
//  rawgraphy
//
//  Created by 이동호 on 1/25/25.
//
import UIKit

class ImageDialogViewController: UIViewController {
    private let id: String
    private let hideForeverMessage: String?
    private let imageUrl: String
    private let imageRatio: Float
    private let ctaButtonText: String?
    private let onClick: (String) -> Void
    private let onClickHideDialog: (String, Bool) -> Void
    
    private var isHideForeverClicked = false
    
    private let hideForeverStack: UIStackView = {
        let stack = UIStackView()
        stack.spacing = 6
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let hideForeverIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "ic_check")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var closeButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "ic_circle_close"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(onDismss), for: .touchUpInside)
        button.isUserInteractionEnabled = true
        return button
    }()
    
    init(id: String,
         hideForeverMessage: String?,
         imageUrl: String,
         imageRatio: Float,
         ctaButtonText: String?,
         onClick: @escaping (String) -> Void,
         onClickHideDialog: @escaping (String, Bool) -> Void) {
        self.id = id
        self.hideForeverMessage = hideForeverMessage
        self.imageUrl = imageUrl
        self.imageRatio = imageRatio
        self.ctaButtonText = ctaButtonText
        self.onClick = onClick
        self.onClickHideDialog = onClickHideDialog
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .overFullScreen
        modalTransitionStyle = .crossDissolve
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupGestures()
        loadImage()
    }
    
    private func setupUI() {
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        
        view.addSubview(containerView)
        
        if let hideMessage = hideForeverMessage {
            hideForeverStack.addArrangedSubview(hideForeverIcon)
            hideForeverStack.addArrangedSubview(hideForeverLabel)
            view.addSubview(hideForeverStack)
            hideForeverLabel.text = hideMessage
            
            NSLayoutConstraint.activate([
                hideForeverStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
                hideForeverStack.bottomAnchor.constraint(equalTo: containerView.topAnchor, constant: -8),
                hideForeverIcon.widthAnchor.constraint(equalToConstant: 24),
                hideForeverIcon.heightAnchor.constraint(equalToConstant: 24)
            ])
        }
        
        containerView.addSubview(imageView)
        
        if let buttonText = ctaButtonText {
            containerView.addSubview(ctaButton)
            ctaButton.setTitle(buttonText, for: .normal)
            ctaButton.addTarget(self, action: #selector(imageTapped), for: .touchUpInside)
            ctaButton.isUserInteractionEnabled = true
        }
        
        view.addSubview(closeButton)
        
        NSLayoutConstraint.activate([
            containerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            containerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            containerView.widthAnchor.constraint(equalToConstant: 320),
            
            imageView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            imageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            imageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor, multiplier: CGFloat(1 / imageRatio)),
            imageView.widthAnchor.constraint(equalToConstant: CGFloat(320)),
            
            closeButton.topAnchor.constraint(equalTo: containerView.bottomAnchor, constant: 16),
            closeButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            closeButton.widthAnchor.constraint(equalToConstant: 44),
            closeButton.heightAnchor.constraint(equalToConstant: 44)
        ])
        
        if let _ = ctaButtonText {
            NSLayoutConstraint.activate([
                ctaButton.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 16),
                ctaButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
                ctaButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
                ctaButton.heightAnchor.constraint(equalToConstant: 48),
                ctaButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -16)
            ])
        } else {
            imageView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -16).isActive = true
        }
    }

    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill  // scaleAspectFill에서 변경
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 12
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private let hideForeverLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: 14, weight: .medium)  // 폰트 크기와 웨이트 조정
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // 스타일 수정
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 16
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var ctaButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .black
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .bold)
        button.layer.cornerRadius = 8
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private func setupGestures() {
        let hideForeverTap = UITapGestureRecognizer(target: self, action: #selector(hideForeverTapped))
        hideForeverStack.addGestureRecognizer(hideForeverTap)
        hideForeverStack.isUserInteractionEnabled = true
        
        let imageTap = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
        imageView.addGestureRecognizer(imageTap)
        imageView.isUserInteractionEnabled = true
        
    }
    
    private func loadImage() {
        guard let url = URL(string: imageUrl) else { return }
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            if let data = data, let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self?.imageView.image = image
                }
            }
        }.resume()
    }
    
    @objc private func imageTapped() {
        print("Image Tapped!")
        dismiss(animated: true)
        onClick(id)
    }
    
    @objc private func onDismss() {
        dismiss(animated: true)
    }
    
    @objc private func hideForeverTapped() {
        isHideForeverClicked.toggle()
        hideForeverIcon.image = UIImage(named: isHideForeverClicked ? "ic_check_filled" : "ic_check")
        onClickHideDialog(id, isHideForeverClicked)
    }
}

extension UIViewController {
    func showImageDialog(
        id: String,
        hideForeverMessage: String? = nil,
        imageUrl: String,
        imageRatio: Float,
        ctaButtonText: String? = nil,
        onDismiss: @escaping () -> Void = {},
        onClick: @escaping (String) -> Void,
        onClickHideDialog: @escaping (String, Bool) -> Void
    ) {
        let dialogVC = ImageDialogViewController(
            id: id,
            hideForeverMessage: hideForeverMessage,
            imageUrl: imageUrl,
            imageRatio: imageRatio,
            ctaButtonText: ctaButtonText,
            onClick: onClick,
            onClickHideDialog: onClickHideDialog
        )
        present(dialogVC, animated: true)
    }
}
