//
//  TextInputComponent.swift
//  MemeCollection
//
//  Created by 김상민 on 10/21/24.
//

import Foundation
import UIKit

class TextInputComponent: UIStackView {
    enum InputType {
        case title, link, startTime
        
        var textFont: UIFont {
            switch self {
            case .title:
                return UIFont.systemFont(ofSize: 20, weight: .bold)
            default:
                return UIFont.systemFont(ofSize: 14, weight: .medium)
            }
        }
    }
    
    private var titleLabel: UILabel!
    private var textField: UITextField!
    private var title: String
    private var placeholder: String
    private let errorLabel = UILabel()
    private let inputType: InputType
    var delegate: UITextFieldDelegate? {
        didSet {
            textField.delegate = delegate
        }
    }
    
    init(title: String, placeholder: String, type: InputType) {
        self.title = title
        self.placeholder = placeholder
        self.inputType = type
        super.init(frame: .zero)
        configureView(title: title, placeholder: placeholder, type: type)
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func getText() -> String? {
        return textField.text
    }
    
    func addAction(_ action: UIAction) {
        textField.addAction(action, for: .editingChanged)
    }
    
    func setText(to text: String) {
        textField.text = text
    }
    
    func setKeyboartType(to type: UIKeyboardType) {
        textField.keyboardType = type
    }
    
    func enableTextField() {
        textField.backgroundColor = .white
        textField.isEnabled = true
        textField.placeholder = placeholder
        if inputType == .startTime {
            setErrorUI(message: "시작 시간이 영상의 길이보가 길 경우, 영상이 재생되지 않을 수 있습니다.")
        }
    }
 
    func disableTextField() {
        textField.text = ""
        textField.backgroundColor = .systemGray5
        textField.isEnabled = false
        if inputType == .startTime {
            textField.placeholder = "쇼츠가 아닐 경우 입력할 수 있습니다."
        }
        removeErrorUI()
    }
    
    func setErrorUI(message: String) {
        errorLabel.text = message
        errorLabel.font = UIFont.systemFont(ofSize: 12)
        errorLabel.textColor = .red
        errorLabel.numberOfLines = 2
        errorLabel.translatesAutoresizingMaskIntoConstraints = false
        DispatchQueue.main.async {
            self.addArrangedSubview(self.errorLabel)
        }
    }
    
    func removeErrorUI() {
        DispatchQueue.main.async {
            self.removeArrangedSubview(self.errorLabel)
            self.errorLabel.removeFromSuperview()
        }
    }
    
}

extension TextInputComponent {
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
        titleLabel.font = .systemFont(ofSize: 14)
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
            textField.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
}
