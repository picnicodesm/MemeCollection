//
//  AddVideoViewController.swift
//  MemeCollection
//
//  Created by 김상민 on 10/21/24.
//

import UIKit

class AddVideoViewController: UIViewController {
    
    var vStack: UIStackView!
    let titleField = TextInputComponent(title: "TITLE", placeholder: "Write the title of the video", type: .title)
    let linkField = TextInputComponent(title: "LINK", placeholder: "Input video link", type: .link)
    let startTimeField = TextInputComponent(title: "START TIME", placeholder: "Start time of video", type: .startTime)
    
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
        configureStackView()
    }
    
    private func configreNavBarItem() {
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelTapped))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneTapped))
    }
    
    private func configureStackView() {
        vStack = UIStackView()
        vStack.translatesAutoresizingMaskIntoConstraints = false
        vStack.axis = .vertical
        vStack.spacing = Constants.stackSpacing
        let _ = [titleField, linkField, startTimeField].map { vStack.addArrangedSubview($0) }
        view.addSubview(vStack)
        
        NSLayoutConstraint.activate([
            vStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Constants.topInsets),
            vStack.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: Constants.sideInsets),
            vStack.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -Constants.sideInsets)
        ])
    }
    
}

extension AddVideoViewController: UITextFieldDelegate {
    
}
