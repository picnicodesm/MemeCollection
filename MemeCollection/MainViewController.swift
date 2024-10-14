//
//  ViewController.swift
//  MemeCollection
//
//  Created by 김상민 on 10/14/24.
//

import UIKit

class MainViewController: UIViewController {
    
    var collectionView: UICollectionView!
    var dataSource: UICollectionViewDiffableDataSource<Section, Item>!
    let categories = ["Favorites", "Category 1", "Category 2", "Category 3"]
    
    typealias Item = String
    enum Section {
        case main
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        configureDataSource()
        configureNavigationBarItem()
        configureToolbar()
    }


}

extension MainViewController {
    private func configureDataSource() {
        collectionView.register(UICollectionViewListCell.self, forCellWithReuseIdentifier: "CollectionViewListCell")
        
        dataSource = UICollectionViewDiffableDataSource<Section, Item>(collectionView: collectionView, cellProvider: { collectionView, indexPath, item in
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionViewListCell", for: indexPath) as? UICollectionViewListCell else { return UICollectionViewCell() }
            
            var config = cell.defaultContentConfiguration()
            config.text = item
            
            cell.contentConfiguration = config
            
            return cell
        })
        
        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        snapshot.appendSections([.main])
        snapshot.appendItems(categories)
        dataSource.apply(snapshot)
    }
}


extension MainViewController: UICollectionViewDelegate {
    
}


extension MainViewController {
    private func configureView() {
        view.backgroundColor = .white
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationItem.title = "MemeCollection"
        
        var configuration = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
        configuration.headerMode = .none
        let layout = UICollectionViewCompositionalLayout.list(using: configuration)
        
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = dataSource
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(collectionView)
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
