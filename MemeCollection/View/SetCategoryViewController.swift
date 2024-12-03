//
//  AddCategoryViewController.swift
//  MemeCollection
//
//  Created by 김상민 on 10/17/24.
//

import UIKit

class SetCategoryViewController: UIViewController {
    
    private var textField: UITextField!
    var viewModel: MainViewModel?
    private lazy var textFieldDidChanged: UIAction = UIAction { [unowned self] _ in
        guard let categoryText = self.textField.text else { return }
        if categoryText == "" {
            self.navigationItem.rightBarButtonItem?.isEnabled = false
        } else {
            self.navigationItem.rightBarButtonItem?.isEnabled = true
        }
    }

    // For edit
    private var isEditMode = false
    var editingCategoryId: UUID?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        configureView()
        textField.becomeFirstResponder()
    }
    
    func setToEditMode(of id: UUID) {
        isEditMode = true
        editingCategoryId = id
    }

}

// MARK: - Actions
extension SetCategoryViewController {
    @objc func doneTapped() {
        guard let vm = viewModel else {
            print("viewmodel doesn't exsist")
            return}
        
        if !isEditMode {
            let newCategory = Category(name: textField.text!, index: vm.categories.count)
            vm.addCategory(newCategory)
        } else {
            let newName = textField.text!
            if let id = editingCategoryId {
                vm.editCategoryName(of: id, to: newName)
            }
        }
        self.dismiss(animated: true)
    }
    
    @objc func cancelTapped() {
        self.dismiss(animated: true)
    }
}

// MARK: - View
extension SetCategoryViewController {
    private func configureView() {
        view.backgroundColor = .systemGray6
        self.navigationItem.title = isEditMode ? "Edit Category" : "New Category"
        configreNavBarItem()
        configureTextField()
    }
    
    private func configreNavBarItem() {
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelTapped))
        let rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneTapped))
        rightBarButtonItem.isEnabled = false
        self.navigationItem.rightBarButtonItem = rightBarButtonItem
    }
    
    private func configureTextField() {
        textField = UITextField()
        let textFieldFont = UIFont.systemFont(ofSize: 24, weight: .semibold)
        textField.borderStyle = .roundedRect
        textField.backgroundColor = .systemGray5
        textField.textAlignment = .center
        textField.placeholder = "Category Name"
        textField.font = textFieldFont
        textField.clearButtonMode = .whileEditing
        textField.addAction(textFieldDidChanged, for: .editingChanged)
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
