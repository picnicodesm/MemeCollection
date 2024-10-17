//
//  AddCategoryViewController.swift
//  MemeCollection
//
//  Created by 김상민 on 10/17/24.
//

import UIKit

class AddCategoryViewController: UIViewController {
    
    private var textField: UITextField!
    var viewModel: CategoryViewModel?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        configureView()
        textField.becomeFirstResponder()
    }

}

// MARK: - Actions
extension AddCategoryViewController {
    @objc func doneTapped() {
        let newCategory = Category(name: textField.text!)
        viewModel?.addCategory(newCategory)
        self.dismiss(animated: true)
    }
    
    @objc func cancelTapped() {
        self.dismiss(animated: true)
    }
}

// MARK: - View
extension AddCategoryViewController {
    private func configureView() {
        view.backgroundColor = .systemGray6
        self.navigationItem.title = "New Category"
        configreNavBarItem()
        configureTextField()
    }
    
    private func configreNavBarItem() {
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelTapped))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneTapped))
    }
    
    private func configureTextField() {
        textField = UITextField()
        let textFieldFont = UIFont.systemFont(ofSize: 24, weight: .semibold)
        let textFieldAttributes: [NSAttributedString.Key: Any] = [.font: textFieldFont]
        let placeholderString = NSAttributedString(string: "Category Name", attributes: textFieldAttributes)
        
        textField.borderStyle = .roundedRect
        textField.backgroundColor = .systemGray5
        textField.textAlignment = .center
        textField.attributedPlaceholder = placeholderString
        textField.font = textFieldFont
        textField.clearButtonMode = .whileEditing
        textField.delegate = self
        
        textField.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(textField)
        
        NSLayoutConstraint.activate([
            textField.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            textField.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            textField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            textField.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
}

extension AddCategoryViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
//        print(textField.text)
        return true
    }
}
