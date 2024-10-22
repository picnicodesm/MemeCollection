//
//  TextInputComponent.swift
//  MemeCollection
//
//  Created by 김상민 on 10/21/24.
//

import Foundation
import UIKit

enum InputType {
    case title, link, startTime
    
    var textFont: UIFont {
        switch self {
        case .title:
            return UIFont.systemFont(ofSize: 24, weight: .bold)
        default:
            return UIFont.systemFont(ofSize: 16, weight: .medium)
        }
    }
}

class TextInputComponent: UIStackView {
    var titleLabel: UILabel!
    var textField: UITextField!
    var title: String
    var placeholder: String
    
    init(title: String, placeholder: String, type: InputType) {
        self.title = title
        self.placeholder = placeholder
        super.init(frame: .zero)
        configureView(title: title, placeholder: placeholder, type: type)
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setDelegate(_ delegate: UITextFieldDelegate) {
        textField.delegate = delegate
    }
    
    func enableTextField() {
        textField.isEnabled = true
    }
    
    func disableTextField() {
        textField.isEnabled = false
    }
    
    private func configureView(title: String, placeholder: String, type: InputType) {
        configureLabel(title: title)
        configureTextField(placeholder: placeholder, type: type)
        
        self.translatesAutoresizingMaskIntoConstraints = false
        self.axis = .vertical
        self.spacing = 3
        self.addArrangedSubview(titleLabel)
        self.addArrangedSubview(textField)
    }
    
    private func configureLabel(title: String) {
        titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 16)
        titleLabel.textColor = .lightGray
    }
    
    private func configureTextField(placeholder: String, type: InputType) {
        textField = UITextField()
        textField.placeholder = placeholder
        textField.backgroundColor = .white
        textField.borderStyle = .roundedRect
        textField.clearButtonMode = .whileEditing
        textField.font = type.textFont
        
        NSLayoutConstraint.activate([
            textField.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
}
