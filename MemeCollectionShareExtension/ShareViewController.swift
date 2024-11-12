//
//  ShareViewController.swift
//  MemeCollectionShareExtension
//
//  Created by 김상민 on 11/12/24.
//

import UIKit
import Social

class ShareViewController: UIViewController {
    let navigationBar: UINavigationBar = {
        let navbar = UINavigationBar()
        navbar.translatesAutoresizingMaskIntoConstraints = false
        return navbar
    }()

    let label: UILabel = {
        let label = UILabel()
        label.text = "Hello Share Component"
        label.translatesAutoresizingMaskIntoConstraints = false

        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureLayout()
        configureNavbar()
    }
    
    func configureNavbar() {
        let titleItem = UINavigationItem(title: "Add Video")
        navigationBar.setItems([titleItem], animated: false)
    }
    
    func configureLayout() {
        view.backgroundColor = .systemGray6
        
        view.addSubview(navigationBar)
        view.addSubview(label)
        
        NSLayoutConstraint.activate([
            navigationBar.topAnchor.constraint(equalTo: view.topAnchor),
            navigationBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            navigationBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }
}
