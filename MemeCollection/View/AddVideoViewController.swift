//
//  AddVideoViewController.swift
//  MemeCollection
//
//  Created by 김상민 on 10/21/24.
//

import UIKit

// TODO: - 1. 저장로직 구현, viewmodel 구현

class AddVideoViewController: UIViewController {
    
    var textFieldsVStack: UIStackView!
    var thumbnailVStack: UIStackView!
    var thumbnailLabel: UILabel!
    var thumbnailImageView: UIImageView!
    let titleField = TextInputComponent(title: "TITLE", placeholder: "Write the title of the video", type: .title)
    let linkField = TextInputComponent(title: "LINK", placeholder: "Input video link", type: .link)
    let startTimeField = TextInputComponent(title: "START TIME", placeholder: "Start time of video", type: .startTime)
    var addAction: ((Video) -> Void)?
    lazy var didChanged: UIAction = UIAction { [unowned self] _ in
        guard let text1 = self.titleField.textField.text, let text2 = self.linkField.textField.text else { return }
        if (!text1.isEmpty && !text2.isEmpty) {
            self.navigationItem.rightBarButtonItem?.isEnabled = true
        } else {
            self.navigationItem.rightBarButtonItem?.isEnabled = false
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
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
        let _ = [titleField, linkField, startTimeField].map {
            $0.textField.addAction(didChanged, for: .editingChanged)
            $0.setDelegate(self)
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
    }
}

extension AddVideoViewController: UITextFieldDelegate {

}
