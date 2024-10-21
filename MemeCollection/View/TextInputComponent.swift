//
//  TextInputComponent.swift
//  MemeCollection
//
//  Created by 김상민 on 10/21/24.
//

import Foundation
import UIKit

class TextInputComponent: UIStackView {
    
    var titleLabel: UILabel!
    var textField: UITextField!
    var title: String
    var placeholder: String
    
    init(title: String, placeholder: String) {
        self.title = title
        self.placeholder = placeholder
        super.init(frame: .zero)
        configureView(title: title, placeholder: placeholder)
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
    private func configureView(title: String, placeholder: String) {
        configureLabel(title: title)
        configureTextField(placeholder: placeholder)
        
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
    
    private func configureTextField(placeholder: String) {
        textField = UITextField()
        let textFont = UIFont.systemFont(ofSize: 24, weight: .bold)
        textField.placeholder = placeholder
        textField.backgroundColor = .white
        textField.borderStyle = .roundedRect
        textField.clearButtonMode = .whileEditing
        textField.font = textFont
        
        NSLayoutConstraint.activate([
            textField.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    func setDelegate(_ delegate: UITextFieldDelegate) {
        textField.delegate = delegate
    }
}
