//
//  AddVideoViewController.swift
//  MemeCollection
//
//  Created by 김상민 on 10/21/24.
//

import UIKit
import Combine

class SetVideoViewController: UIViewController {
    private var containerScrollView: UIScrollView!
    private var contentView: UIView!
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
        testCanSave()
    }
    private lazy var linkTextFieldDidChanged: UIAction = UIAction { [unowned self] _ in
        guard let titleText = self.titleField.getText(),
              let linkText = self.linkField.getText() else { return }
        testLink(linkText)
    }
    private lazy var startTextFieldDidChanged: UIAction = UIAction { [unowned self] _ in
        guard let startTimeText = self.startTimeField.getText() else { return }
        testCanSave()
    }
    
    private var linkFlag = false
    private let testLinkVM = TestLinkViewModel()
    var memesVM: MemesViewModel!
    
    /// Data for comparison with error data caused by an invalid key.
    private var errorData: Data?
    
    // Combine
    private var subscriptions = Set<AnyCancellable>()
    
    var categoryId: UUID?
    
    /// Used when editMode is true for setting current video's information.
    /// If this page is not edit mode, the property must be nil.
    var currentVideo: Video? = nil
    private var isEditMode = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        bind()
        Task {
            errorData = await testLinkVM.getErrorData()
        }
    }
    
    private func bind() {
        testLinkVM.$thumbnailData
            .receive(on: RunLoop.main)
            .sink(receiveValue: { [unowned self] thumbnailData in
                if (thumbnailData != nil && thumbnailData == errorData) {
                    failedGettingThumbnail()
                }
                else { // thumbnailData는 nil이 되지 않는가?
                    succeededGettingThumbnail(of: thumbnailData)
                }
            }).store(in: &subscriptions)
    }
    
    func setToEditMode(with video: Video) {
        self.currentVideo = video
        self.isEditMode = true
    }
    
    private struct Constants {
        static let sideInsets: CGFloat = 24
        static let topInsets: CGFloat = 16
        static let stackSpacing: CGFloat = 16
        static let cornerRadius: CGFloat = 20
        static let titleSpacing: CGFloat = 3
        static let multiplier: CGFloat = 1.0
        
        struct Font {
            static let fontSize: CGFloat = 16
        }
    }
}

// MARK: - Actions
extension SetVideoViewController {
    @objc func doneTapped() {
        guard let title = titleField.getText(),
              let startTimeText = startTimeField.getText(),
              let categoryId = self.categoryId,
              let thumbnailData = testLinkVM.thumbnailData
        else {
            // Alert with message "save failed" and dismiss
            return }
        
        let imageManager = ImageManager.shared
        let startTime = startTimeText == "" ? 0 : Int(startTimeText)!
        let mobileLink = testLinkVM.getMobileLink(startFrom: startTime)!
        let videoInfo = testLinkVM.getVideoInfo()
        
        guard let (imageIdentifier, compressedImage) = imageManager.getCompleteIdentifier(of: thumbnailData, with: title) else {
            // comopressed failed
            return
        }
        
        if let currentVideo = currentVideo, isEditMode {
            let editVideo = Video(id: currentVideo.getId(), name: title, urlString: mobileLink, type: videoInfo.videoType!.rawValue, isFavorite: currentVideo.getIsFavorite(), thumbnailIdentifier: imageIdentifier, categoryId: categoryId, index: currentVideo.getIndex(), favoriteIndex: currentVideo.getFavoriteIndex(), startTime: startTime)
            
            imageManager.removeImage(of: currentVideo.getThumbnailIdentifier())
            memesVM.editVideo(editVideo)
            let _ = imageManager.saveImage(imageData: compressedImage, as: imageIdentifier)
            self.dismiss(animated: true)
            return
        }
        
        guard imageManager.saveImage(imageData: compressedImage, as: imageIdentifier)
        else {
            // Alert with message "save failed"
            return
        }
        
        let newVideo = Video(name: title, urlString: mobileLink, type: videoInfo.videoType!.rawValue, isFavorite: false, thumbnailIdentifier: imageIdentifier, categoryId: categoryId, index: memesVM.memes.count, startTime: startTime)
        
        memesVM.addVideo(newVideo)
        self.dismiss(animated: true)
    }
    
    @objc func cancelTapped() {
        self.dismiss(animated: true)
    }
    
    private func addObserverToTextFileds() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow(_:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil)
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else {
            return
        }
        containerScrollView.contentInset.bottom = keyboardFrame.size.height
    }

    
    @objc func keyboardWillHide() {
        let contentInset = UIEdgeInsets.zero
        containerScrollView.contentInset = contentInset
        containerScrollView.horizontalScrollIndicatorInsets = contentInset
        containerScrollView.verticalScrollIndicatorInsets = contentInset
    }
}

extension SetVideoViewController {
    private func testLink(_ link: String) {
        linkField.removeErrorUI()
        if !link.isEmpty {
            let (isSuccess, error, _, _, key) = testLinkVM.testLink(with: link)
            
            if isSuccess {
                Task {
                    await testLinkVM.setThumbnail(with: key!)
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
        guard let titleText = self.titleField.getText() else { return }
        if !titleText.isEmpty && linkFlag {
            self.navigationItem.rightBarButtonItem?.isEnabled = true
        } else {
            self.navigationItem.rightBarButtonItem?.isEnabled = false
        }
    }
    
    private func testFailedByEmptyText() {
        removeThumbnail()
        startTimeField.disableTextField()
        linkFlag = false
        testCanSave()
    }
    
    private func testFailedByInvalidLink(error: LinkError) {
        linkField.setErrorUI(message: error.rawValue)
        testFailedByEmptyText()
    }
    
    private func succeededGettingThumbnail(of thumbnailData: Data?) {
        guard let thumbnailData = thumbnailData else { return }
        guard let videoType = testLinkVM.getVideoInfo().videoType else { return }
        self.thumbnailImageView.image = UIImage(data: thumbnailData)
        if videoType == .video {
            self.startTimeField.enableTextField()
        }
        linkFlag = true
        testCanSave()
    }
    
    private func failedGettingThumbnail() {
        linkField.setErrorUI(message: LinkError.keyError.rawValue)
        testFailedByEmptyText()
    }
}

// MARK: - View
extension SetVideoViewController {
    private func configureView() {
        self.navigationItem.title = isEditMode ? "Edit Video" : "New Video"
        view.backgroundColor = .systemGray6
        configureScrollView()
        configureContentView()
        configreNavBarItem()
        configureTextFieldStackView()
        configureThumbnailVStack()
    }
    
    
    private func configureScrollView() {
        containerScrollView = UIScrollView()
        containerScrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(containerScrollView)
        
        NSLayoutConstraint.activate([
            containerScrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            containerScrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            containerScrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            containerScrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    
    private func configureContentView() {
        contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        containerScrollView.addSubview(contentView)

        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: containerScrollView.topAnchor),
            contentView.centerXAnchor.constraint(equalTo: containerScrollView.centerXAnchor),
            contentView.widthAnchor.constraint(equalTo: containerScrollView.widthAnchor),
            contentView.bottomAnchor.constraint(equalTo: containerScrollView.bottomAnchor),
        ])
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
        titleField.addAction(titleTextFieldDidChanged)
        linkField.addAction(linkTextFieldDidChanged)
        startTimeField.addAction(startTextFieldDidChanged)
        startTimeField.setKeyboartType(to: .numberPad)
        startTimeField.disableTextField()
        addObserverToTextFileds()
        startTimeField.delegate = self
        
        if let currentVideo = currentVideo {
            if isEditMode {
                titleField.setText(to: currentVideo.getName())
                linkField.setText(to: currentVideo.getUrlString())
                testLink(currentVideo.getUrlString())
            }
            
            if isEditMode && currentVideo.getVideoType() == .video {
                startTimeField.enableTextField()
                startTimeField.setText(to: currentVideo.getStartTime())
            } else {
                startTimeField.disableTextField()
            }
        }
        
        let _ = [titleField, linkField, startTimeField].map {
            textFieldsVStack.addArrangedSubview($0)
        }
        contentView.addSubview(textFieldsVStack)
        
        NSLayoutConstraint.activate([
            textFieldsVStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Constants.topInsets),
            textFieldsVStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.sideInsets),
            textFieldsVStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.sideInsets),
        ])
    }
    
    
    private func configureThumbnailVStack() {
        thumbnailVStack = UIStackView()
        thumbnailVStack.translatesAutoresizingMaskIntoConstraints = false
        thumbnailVStack.axis = .vertical
        thumbnailVStack.spacing = Constants.titleSpacing
        
        contentView.addSubview(thumbnailVStack)
        
        configureThumbnailLabel()
        configureThumbnailImageView()
        
        let _ = [thumbnailLabel, thumbnailImageView].map { thumbnailVStack.addArrangedSubview($0) }
        
        NSLayoutConstraint.activate([
            thumbnailVStack.topAnchor.constraint(equalTo: textFieldsVStack.bottomAnchor, constant: Constants.stackSpacing),
            thumbnailVStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.sideInsets),
            thumbnailVStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.sideInsets),
            thumbnailVStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            thumbnailImageView.heightAnchor.constraint(equalTo: thumbnailImageView.widthAnchor, multiplier: Constants.multiplier),
        ])
    }
    
    
    private func configureThumbnailLabel() {
        thumbnailLabel = UILabel()
        thumbnailLabel.text = "THUMBNAIL"
        thumbnailLabel.font = .systemFont(ofSize: Constants.Font.fontSize)
        thumbnailLabel.textColor = .lightGray
    }
    
    
    private func configureThumbnailImageView() {
        thumbnailImageView = UIImageView()
        thumbnailImageView.image = nil
        thumbnailImageView.backgroundColor = .lightGray
        thumbnailImageView.layer.cornerRadius = Constants.cornerRadius
        thumbnailImageView.clipsToBounds = true
    }
}

// MARK: - Delegate
extension SetVideoViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard string.isEmpty || Int(string) != nil else { return false }
        return true
    }
}
