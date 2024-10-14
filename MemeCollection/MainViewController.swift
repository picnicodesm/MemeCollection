//
//  ViewController.swift
//  MemeCollection
//
//  Created by 김상민 on 10/14/24.
//

import UIKit

class MainViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        configureNavigationBarItem()
        configureToolbar()
    }


}

extension MainViewController {
    private func configureView() {
        view.backgroundColor = .white
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationItem.title = "MemeCollection"
    }
    
    private func configureNavigationBarItem() {
        let rightBarButtonItem = editButtonItem
        self.navigationItem.rightBarButtonItem = rightBarButtonItem
    }
    
    private func configureToolbar() {
        self.navigationController?.isToolbarHidden = false
        
        let newCategoryButton = UIButton(type: .system)
        var newCategoryButtonnConfig = UIButton.Configuration.plain()
        newCategoryButtonnConfig.title = "New Category"
        newCategoryButtonnConfig.image = UIImage(systemName: "plus.circle.fill")
        newCategoryButtonnConfig.imagePadding = 10
        newCategoryButtonnConfig.imagePlacement = NSDirectionalRectEdge.leading
        newCategoryButtonnConfig.contentInsets = .zero
        newCategoryButton.configuration = newCategoryButtonnConfig
        
        let newReminderBarButtonItem = UIBarButtonItem(customView: newCategoryButton)
        let addListBarButtonItem = UIBarButtonItem(title: "New Video", style: .plain, target: nil, action: nil)
        let flexibleSpaceBarButtonItem = UIBarButtonItem(systemItem: .flexibleSpace)
        
        self.toolbarItems = [newReminderBarButtonItem, flexibleSpaceBarButtonItem, addListBarButtonItem]

    }
}
