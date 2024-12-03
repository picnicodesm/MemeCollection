//
//  SelectCategoryComponent.swift
//  MemeCollection
//
//  Created by 김상민 on 11/13/24.
//

import Foundation
import UIKit

class SelectCategoryComponent: UIStackView {
    private var titleLabel: UILabel!
    private var menuButton: UIButton!
    private var title: String
    private let database = DataBaseManager.shared
    private var selectedItem: String = ""
    
    
    init(title: String) {
        self.title = title
        super.init(frame: .zero)
        configureView(title: title)
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func getSelectedItem() -> Category? {
        return database.read(RealmCategory.self).first(where: { $0.name == selectedItem })?.toStruct()
    }
}

extension SelectCategoryComponent {
    private func configureView(title: String) {
        configureLabel(title: title)
        configureMenuButton()
        
        self.translatesAutoresizingMaskIntoConstraints = false
        self.axis = .vertical
        self.spacing = 3
        self.addArrangedSubview(titleLabel)
        self.addArrangedSubview(menuButton)
    }
    
    private func configureLabel(title: String) {
        titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 14)
        titleLabel.textColor = .lightGray
    }
    
    private func configureMenuButton() {
        menuButton = UIButton(type: .system)
        var buttonConfig = UIButton.Configuration.plain()
        var backgroundConfig = UIBackgroundConfiguration.clear()
        backgroundConfig.backgroundColor = .white
        backgroundConfig.cornerRadius = 10
        buttonConfig.title = "Empty"
        buttonConfig.baseForegroundColor = .black
        buttonConfig.background = backgroundConfig
        
        menuButton.configuration = buttonConfig
        
        var children: [UIMenuElement] = []
        let actionClosure = { [weak self] (action: UIAction) in
//            print(action.title)
            guard let self = self else { return }
            self.selectedItem = action.title
        }
        
        let categories = database.read(RealmCategory.self)
        
        if categories.count == 1 && categories.first!.isForFavorites {
            return
        } else {
            if let firstIndex = categories.firstIndex(where: { $0.isForFavorites != true }) {
                selectedItem = categories[firstIndex].name
            }
        }
        
        for category in categories {
            if category.isForFavorites {
                continue
            }
            let title = category.toStruct().getName()
            children.append(UIAction(title: title, handler: actionClosure))
        }
 
        menuButton.menu = UIMenu(options: .displayInline, children: children)
        
        menuButton.showsMenuAsPrimaryAction = true
        menuButton.changesSelectionAsPrimaryAction = true
        
        NSLayoutConstraint.activate([
            menuButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
}
