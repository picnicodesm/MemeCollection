//
//  AddVideoViewController.swift
//  MemeCollection
//
//  Created by 김상민 on 10/21/24.
//

import UIKit
import Combine

// TODO: - 1. 저장로직 구현, viewmodel 구현

class AddVideoViewController: UIViewController {
    
    var textFieldsVStack: UIStackView!
    var thumbnailVStack: UIStackView!
    var thumbnailLabel: UILabel!
    var thumbnailImageView: UIImageView!
    let titleField = TextInputComponent(title: "TITLE", placeholder: "Write the title of the video", type: .title)
    let linkField = TextInputComponent(title: "LINK", placeholder: "Input video link", type: .link)
    let startTimeField = TextInputComponent(title: "START TIME", placeholder: "Start time of video", type: .startTime)
    
    let viewModel = AddVideoViewModel()
    
    var addAction: ((Video) -> Void)?
    lazy var didChanged: UIAction = UIAction { [unowned self] _ in
        guard let titleText = self.titleField.textField.text, let linkText = self.linkField.textField.text else { return }
        testLink(linkText)
    }
    
    var errorData: Data?
    
    // Combine
    var subscriptions = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        bind()
        
        Task {
            errorData = await viewModel.getErrorData()
        }
    }
    
    private func bind() {
        viewModel.$thumbnailData
            .receive(on: RunLoop.main)
            .sink { error in
                print(error)
            } receiveValue: { [unowned self] thumbnailData in
                if (thumbnailData != nil && thumbnailData == errorData) {
                    removeThumbnail()
                    linkField.setErrorUI(message: LinkError.keyError.rawValue)
                }
                else {
                    guard let thumbnailData = thumbnailData else { return }
                    self.thumbnailImageView.image = UIImage(data: thumbnailData)
                }
            }.store(in: &subscriptions)

    }
    
    private struct Constants {
        static let sideInsets: CGFloat = 24
        static let topInsets: CGFloat = 16
        static let stackSpacing: CGFloat = 16
    }

}

// MARK: - Actions
extension AddVideoViewController {
    @objc func doneTapped() {
        self.dismiss(animated: true)
    }
    
    @objc func cancelTapped() {
        self.dismiss(animated: true)
    }
    
    private func testLink(_ link: String) -> Bool {
        if !link.isEmpty {
            let (isSuccess, error, videoType, linkType, key) = viewModel.testLink(with: link)
            
            if isSuccess {
                linkField.removeErrorUI()
                Task {
                    await viewModel.setThumbnail(with: key!)
                }
                return true
            } else {
                guard let error = error else { return false }
                removeThumbnail()
                linkField.setErrorUI(message: error.rawValue)
                return false
            }
        } else {
            linkField.removeErrorUI()
            removeThumbnail()
            return false
        }
    }
    
    private func removeThumbnail() {
        thumbnailImageView.image = nil
    }
    
}

// MARK: - View
extension AddVideoViewController {
    private func configureView() {
        view.backgroundColor = .systemGray6
        self.navigationItem.title = "New Video"
        configreNavBarItem()
        configureTextFieldStackView()
        configureThumbnailVStack()
    }
    
    private func configreNavBarItem() {
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelTapped))
        let rightBarButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneTapped))
        rightBarButton.isEnabled = false
        self.navigationItem.rightBarButtonItem = rightBarButton
    }
    
    private func configureTextFieldStackView() {
        textFieldsVStack = UIStackView()
        textFieldsVStack.translatesAutoresizingMaskIntoConstraints = false
        textFieldsVStack.axis = .vertical
        textFieldsVStack.spacing = Constants.stackSpacing
        startTimeField.disableTextField()
        let _ = [titleField, linkField, startTimeField].map {
            $0.textField.addAction(didChanged, for: .editingChanged)
            textFieldsVStack.addArrangedSubview($0)
        }
        view.addSubview(textFieldsVStack)
        
        NSLayoutConstraint.activate([
            textFieldsVStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Constants.topInsets),
            textFieldsVStack.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: Constants.sideInsets),
            textFieldsVStack.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -Constants.sideInsets)
        ])
    }
    
    private func configureThumbnailVStack() {
        thumbnailVStack = UIStackView()
        thumbnailVStack.translatesAutoresizingMaskIntoConstraints = false
        thumbnailVStack.axis = .vertical
        thumbnailVStack.spacing = 3
        
        view.addSubview(thumbnailVStack)
        
        configureThumbnailLabel()
        configureThumbnailImageView()
    
        let _ = [thumbnailLabel, thumbnailImageView].map { thumbnailVStack.addArrangedSubview($0) }
     
        NSLayoutConstraint.activate([
            thumbnailVStack.topAnchor.constraint(equalTo: textFieldsVStack.bottomAnchor, constant: Constants.stackSpacing),
            thumbnailVStack.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: Constants.sideInsets),
            thumbnailVStack.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -Constants.sideInsets),
            thumbnailImageView.heightAnchor.constraint(equalTo: thumbnailImageView.widthAnchor, multiplier: 1.0)
        ])
    }
    
    private func configureThumbnailLabel() {
        thumbnailLabel = UILabel()
        thumbnailLabel.text = "THUMBNAIL"
        thumbnailLabel.font = .systemFont(ofSize: 16)
        thumbnailLabel.textColor = .lightGray
    }
    
    private func configureThumbnailImageView() {
        thumbnailImageView = UIImageView()
        thumbnailImageView.image = UIImage(systemName: "apple.logo")
        thumbnailImageView.backgroundColor = .gray
        thumbnailImageView.layer.cornerRadius = 20
        thumbnailImageView.clipsToBounds = true
    }
}
