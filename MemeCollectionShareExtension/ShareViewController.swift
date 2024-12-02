//
//  ShareViewController.swift
//  MemeCollectionShareExtension
//
//  Created by 김상민 on 11/12/24.
//

import UIKit
import Social
import RealmSwift
import Combine
import UniformTypeIdentifiers

enum EndExtension: Error {
    case none
    case error
}

class ShareViewController: UIViewController {
    private var containerScrollView: UIScrollView!
    private var contentView: UIView!
    private var navigationBar: UINavigationBar!
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
    private let menuButton = SelectCategoryComponent(title: "Category")
    
    private lazy var titleTextFieldDidChanged: UIAction = UIAction { [unowned self] _ in
        guard let titleText = self.titleField.getText() else { return }
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
    private let videoManager = VideoManager()
    private let database = DataBaseManager.shared
    private var categories: [Category] {
        return database.read(RealmCategory.self).map { $0.toStruct() }
    }
    
    /// Data for comparison with error data caused by an invalid key.
    private var errorData: Data?
    
    // Combine
    private var subscriptions = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()
        if database.read(RealmCategory.self).count == 1 {
            showAlert()
            return
        }
        configureView()
        bind()
        getLinkFromExtension()
        Task {
            errorData = await testLinkVM.getErrorData()
        }
    }
    
    private func bind() {
        testLinkVM.$thumbnailData
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
        static let cornerRadius: CGFloat = 20
        static let titleSpacing: CGFloat = 3
        static let multiplier: CGFloat = 1.0
        
        struct Font {
            static let fontSize: CGFloat = 16
        }
    }
}

// MARK: - Actions
extension ShareViewController {
    
    @objc func doneTapped() {
        guard let title = titleField.getText(),
              let startTimeText = startTimeField.getText(),
              let categoryId = menuButton.getSelectedItem()?.getId(),
              let index = database.read(of: RealmCategory.self, with: categoryId)?.videos.count,
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
            print("failed get compressed Image")
            return
        }
        
        guard imageManager.saveImage(imageData: compressedImage, as: imageIdentifier)
        else {
            print("failed")
            // Alert with message "save failed"
            return
        }
        
        let newVideo = Video(name: title, urlString: mobileLink, type: videoInfo.videoType!.rawValue, isFavorite: false, thumbnailIdentifier: imageIdentifier, categoryId: categoryId, index: index, startTime: startTime)
        
        videoManager.addVideo(newVideo, to: categoryId)
        
        self.extensionContext?.cancelRequest(withError: EndExtension.none)
    }
    
    @objc func cancelTapped() {
        self.extensionContext?.cancelRequest(withError: EndExtension.none)
    }
}

extension ShareViewController {
    private func showAlert() {
        let alert = UIAlertController(
            title: "Empty Category",
            message: "There is no category, create your new category first.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "확인", style: .default, handler: { _ in
            self.extensionContext?.completeRequest(returningItems: nil, completionHandler: nil)
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    private func getLinkFromExtension() {
        guard let extensionItem = extensionContext?.inputItems.first as? NSExtensionItem else { return }
        guard let itemProvider = extensionItem.attachments?.first else { return }
        
        if itemProvider.hasItemConformingToTypeIdentifier(UTType.url.identifier) { // Youtube Web에서 동작
            itemProvider.loadItem(forTypeIdentifier: UTType.url.identifier, options: nil) { (url, error) in
                if let shareURL = url as? URL {
                    DispatchQueue.main.async {
                        self.linkField.setText(to: shareURL.absoluteString)
                    }
                    self.testLink(shareURL.absoluteString)
                } else {
                    print("URL 읽기 실패: \(String(describing: error))")
                }
            }
        } else if itemProvider.hasItemConformingToTypeIdentifier(UTType.plainText.identifier) { // Youtbue App에서 동작
            itemProvider.loadItem(forTypeIdentifier: UTType.plainText.identifier, options: nil) { (text, error) in
                if let string = text as? String, let shareURL = URL(string: string) {
                    DispatchQueue.main.async {
                        self.linkField.setText(to: shareURL.absoluteString)
                    }
                    self.testLink(shareURL.absoluteString)
                } else {
                    print("URL 읽기 실패: \(String(describing: error))")
                }
            }
    }
                                  }
    
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
            navigationBar.items?[0].rightBarButtonItem?.isEnabled = true
        } else {
            navigationBar.items?[0].rightBarButtonItem?.isEnabled = false
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
extension ShareViewController {
    private func configureView() {
        view.backgroundColor = .systemGray6
        configreNavBarItem()
        configureScrollView()
        configureContentView()
        configureTextFieldStackView()
        configureMenuButton()
        configureThumbnailVStack()
    }
    
    private func configureScrollView() {
        containerScrollView = UIScrollView()
        containerScrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(containerScrollView)
        
        NSLayoutConstraint.activate([
            containerScrollView.topAnchor.constraint(equalTo: navigationBar.bottomAnchor),
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
            contentView.bottomAnchor.constraint(equalTo: containerScrollView.bottomAnchor)
        ])
    }
    
    
    private func configreNavBarItem() {
        navigationBar = UINavigationBar()
        navigationBar.translatesAutoresizingMaskIntoConstraints = false
        let navItem = UINavigationItem(title: "Add Video")
        navItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelTapped))
        let rightBarButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneTapped))
        rightBarButton.isEnabled = false
        navItem.rightBarButtonItem = rightBarButton
        navigationBar.setItems([navItem], animated: false)
        
        view.addSubview(navigationBar)
        
        NSLayoutConstraint.activate([
            navigationBar.topAnchor.constraint(equalTo: view.topAnchor),
            navigationBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            navigationBar.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
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
        
        let _ = [titleField, linkField, startTimeField].map {
            textFieldsVStack.addArrangedSubview($0)
        }
        contentView.addSubview(textFieldsVStack)
        
        NSLayoutConstraint.activate([
            textFieldsVStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Constants.topInsets),
            textFieldsVStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.sideInsets),
            textFieldsVStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.sideInsets)
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
            thumbnailVStack.topAnchor.constraint(equalTo: menuButton.bottomAnchor, constant: Constants.stackSpacing),
            thumbnailVStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.sideInsets),
            thumbnailVStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.sideInsets),
            thumbnailVStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            thumbnailImageView.heightAnchor.constraint(equalTo: thumbnailImageView.widthAnchor, multiplier: Constants.multiplier)
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
    
    
    private func configureMenuButton() {
        contentView.addSubview(menuButton)
        
        NSLayoutConstraint.activate([
            menuButton.topAnchor.constraint(equalTo: textFieldsVStack.bottomAnchor,constant: Constants.stackSpacing),
            menuButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.sideInsets),
            menuButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.sideInsets),
        ])
    }
}
