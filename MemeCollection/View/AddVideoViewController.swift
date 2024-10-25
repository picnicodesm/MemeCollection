//
//  AddVideoViewController.swift
//  MemeCollection
//
//  Created by 김상민 on 10/21/24.
//

import UIKit
import Combine

class AddVideoViewController: UIViewController {
    private var textFieldsVStack: UIStackView!
    private var thumbnailVStack: UIStackView!
    private var thumbnailLabel: UILabel!
    private var thumbnailImageView: UIImageView!
    private let titleField = TextInputComponent(title: "TITLE",
                                                placeholder: "Write the title of the video",
                                                type: .title)
    private let linkField = TextInputComponent(title: "LINK",
                                               placeholder: "Input video link",
                                               type: .link)
    private let startTimeField = TextInputComponent(title: "START TIME",
                                                    placeholder: "Start time of video",
                                                    type: .startTime)
    
    private lazy var titleTextFieldDidChanged: UIAction = UIAction { [unowned self] _ in
        guard let titleText = self.titleField.textField.text else { return }
        testCanSave()
        
    }
    private lazy var linkTextFieldDidChanged: UIAction = UIAction { [unowned self] _ in
        guard let titleText = self.titleField.textField.text,
              let linkText = self.linkField.textField.text else { return }
        testLink(linkText)
        testCanSave()
    }
    
    private var linkFlag = false
    private let viewModel = AddVideoViewModel()
    
    /// Data for comparison with error data caused by an invalid key.
    private var errorData: Data?
    
    // Combine
    private var subscriptions = Set<AnyCancellable>()
    
    var addAction: ((Video) -> Void)?
    var category: Category?
    
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
                    failedGettingThumbnail()
                }
                else {
                    succeededGettingThumbnail(of: thumbnailData)
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
        guard let title = titleField.textField.text,
              let startTimeText = startTimeField.textField.text,
              let category = self.category,
              let thumbnailData = viewModel.thumbnailData
        else {
            // Alert with message "save failed" and dismiss
            return }
        
        let imageManager = ImageManager.shared
        let startTime = startTimeText == "" ? 0 : Int(startTimeText)!
        let mobileLink = viewModel.getMobileLink(startFrom: startTime)!
        let videoInfo = viewModel.getVideoInfo()
        
        guard let (imageIdentifier, compressedImage) = imageManager.getCompleteIdentifier(of: thumbnailData, with: title) else {
            // comopressed failed
            return
        }
        
        guard imageManager.saveImage(imageData: compressedImage, as: imageIdentifier)
        else {
            // Alert with message "save failed"
            return
        }
        
        let newVideo = Video(name: title, urlString: mobileLink, type: videoInfo.videoType!, isFavorite: false, thumbnailIdentifier: imageIdentifier, category: category, startTime: startTime)
        
        addAction?(newVideo)
        self.dismiss(animated: true)
    }
    
    @objc func cancelTapped() {
        self.dismiss(animated: true)
    }
}

extension AddVideoViewController {
    private func testLink(_ link: String) {
        if !link.isEmpty {
            let (isSuccess, error, _, _, key) = viewModel.testLink(with: link)
            
            if isSuccess {
                linkField.removeErrorUI()
                Task {
                    await viewModel.setThumbnail(with: key!)
                }
            } else {
                testFailedByInvalidLink(error: error!)
            }
        } else {
            testFailedByEmptyText()
        }
    }
    
    private func removeThumbnail() {
        thumbnailImageView.image = nil
    }
    
    private func testCanSave() {
        guard let titleText = self.titleField.textField.text else { return }
        if !titleText.isEmpty && linkFlag {
            self.navigationItem.rightBarButtonItem?.isEnabled = true
        } else {
            self.navigationItem.rightBarButtonItem?.isEnabled = false
        }
    }
    
    private func testFailedByEmptyText() {
        linkField.removeErrorUI()
        removeThumbnail()
        startTimeField.disableTextField()
        linkFlag = false
    }
    
    private func testFailedByInvalidLink(error: LinkError) {
        removeThumbnail()
        linkField.setErrorUI(message: error.rawValue)
        startTimeField.disableTextField()
        linkFlag = false
    }
    
    private func succeededGettingThumbnail(of thumbnailData: Data?) {
        guard let thumbnailData = thumbnailData else { return }
        guard let videoType = viewModel.getVideoInfo().videoType else { return }
        self.thumbnailImageView.image = UIImage(data: thumbnailData)
        if videoType == .video {
            self.startTimeField.enableTextField()
        }
        linkFlag = true
        testCanSave()
    }
    
    private func failedGettingThumbnail() {
        removeThumbnail()
        linkField.setErrorUI(message: LinkError.keyError.rawValue)
        self.startTimeField.disableTextField()
        linkFlag = false
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
        titleField.textField.addAction(titleTextFieldDidChanged, for: .editingChanged)
        linkField.textField.addAction(linkTextFieldDidChanged, for: .editingChanged)
        startTimeField.textField.keyboardType = .numberPad
        let _ = [titleField, linkField, startTimeField].map {
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
        thumbnailImageView.image = nil
        thumbnailImageView.backgroundColor = .lightGray
        thumbnailImageView.layer.cornerRadius = 20
        thumbnailImageView.clipsToBounds = true
    }
}
