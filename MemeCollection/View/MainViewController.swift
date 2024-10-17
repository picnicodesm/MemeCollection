//
//  ViewController.swift
//  MemeCollection
//
//  Created by 김상민 on 10/14/24.
//

import UIKit
import Combine

class MainViewController: UIViewController {
    
    var collectionView: UICollectionView!
    var dataSource: UICollectionViewDiffableDataSource<Section, Item>!
    let viewModel = MainViewModel()
    let deleteItem = PassthroughSubject<IndexPath, Never>()
    
    
    var subscriptions = Set<AnyCancellable>()
    
    
    typealias Item = Category
    enum Section {
        case main
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        configureDataSource()
        bind()
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        collectionView.isEditing = editing
    }
    
    func bind() {
        viewModel.$categories
            .receive(on: RunLoop.main)
            .sink { [unowned self] categories in
            self.updateSnapshot(categories)
        }
        .store(in: &subscriptions)
        
        deleteItem.sink { [unowned self] indexPath in
            let deleteItem = viewModel.categories[indexPath.item]
            viewModel.deleteCategory(deleteItem)
        }
        .store(in: &subscriptions)
    }
}

// MARK: - DataSource
extension MainViewController {
    private func configureDataSource() {
        collectionView.register(UICollectionViewListCell.self, forCellWithReuseIdentifier: "CollectionViewListCell")
        
        dataSource = UICollectionViewDiffableDataSource<Section, Item>(collectionView: collectionView, cellProvider: { collectionView, indexPath, item in
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionViewListCell", for: indexPath) as? UICollectionViewListCell else { return UICollectionViewCell() }
            
            var config = cell.defaultContentConfiguration()
            config.text = item.getName()
            cell.contentConfiguration = config
            cell.accessories = [.delete(displayed: .whenEditing), .reorder(displayed: .whenEditing), .detail(displayed: .whenEditing), .disclosureIndicator(displayed: .whenNotEditing)]
            return cell
        })
        
        dataSource.reorderingHandlers.canReorderItem = { item in
            return true
        }
        
        dataSource.reorderingHandlers.didReorder = { [weak self] transaction in
            if let updatedBackingStore = self?.viewModel.categories.applying(transaction.difference) {
                self?.viewModel.updateCategoryOrder(to: updatedBackingStore)
            }
        }
    }
    
    private func updateSnapshot(_ items: [Category]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        snapshot.appendSections([.main])
        snapshot.appendItems(items)
        dataSource.apply(snapshot)
    }
}

// MARK: - Actions
extension MainViewController {
    private func swipeAction(_ indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "") { [weak self] deleteAction, view, completion in
            guard let self = self else { return }
            self.deleteItem.send(indexPath)
            completion(true)
        }
        deleteAction.image = UIImage(systemName: "trash.fill")
        
        let editAction = UIContextualAction(style: .normal, title: "") { (action, view, completion) in
            print("editAction!")
            completion(true)
        }
        editAction.image = UIImage(systemName: "info.circle.fill")
        editAction.backgroundColor = .lightGray
        
        return UISwipeActionsConfiguration(actions: [deleteAction, editAction])
    }
    
    private func deleteItem(at indexPath: IndexPath) {
        guard var snapshot = dataSource?.snapshot() else { return }
        if let item = dataSource.itemIdentifier(for: indexPath) {
            snapshot.deleteItems([item])
            dataSource.apply(snapshot, animatingDifferences: true)
        }
    }
    
    @objc private func openNewCategoryView() {
        let newCategoryView = AddCategoryViewController()
        newCategoryView.viewModel = self.viewModel
        let navigationViewController = UINavigationController(rootViewController: newCategoryView)
        self.present(navigationViewController, animated: true)
    }
    
}

// MARK: - Configure View
extension MainViewController {
    private func configureView() {
        view.backgroundColor = .white
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationItem.title = "MemeCollection"
        
        configureCollectionView()
        configureNavigationBarItem()
        configureToolbar()
    }
    
    private func configureCollectionView() {
        var configuration = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
        configuration.headerMode = .none
        configuration.trailingSwipeActionsConfigurationProvider = swipeAction
        let layout = UICollectionViewCompositionalLayout.list(using: configuration)
        
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(collectionView)
    }
    
    private func configureNavigationBarItem() {
        self.navigationItem.rightBarButtonItem = editButtonItem
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Order", style: .plain, target: self, action: #selector(testOrder))
    }
    
    @objc func testOrder() {
        for item in viewModel.categories {
            print(item.getName())
        }
    }
    
    private func configureToolbar() {
        self.navigationController?.isToolbarHidden = false
        
        let leftToolbarButton = UIButton(type: .system)
        var leftToolbarButtonConfig = UIButton.Configuration.plain()
        leftToolbarButtonConfig.title = "Add Video"
        leftToolbarButtonConfig.image = UIImage(systemName: "plus.circle.fill")
        leftToolbarButtonConfig.imagePadding = 10
        leftToolbarButtonConfig.imagePlacement = NSDirectionalRectEdge.leading
        leftToolbarButtonConfig.contentInsets = .zero
        leftToolbarButton.configuration = leftToolbarButtonConfig
        
        let leftToolbarButtonItem = UIBarButtonItem(customView: leftToolbarButton)
        let rightToolbarButtonItem = UIBarButtonItem(title: "New Category", style: .plain, target: self, action: #selector(openNewCategoryView))
        let flexibleSpaceBarButtonItem = UIBarButtonItem(systemItem: .flexibleSpace)
        
        self.toolbarItems = [leftToolbarButtonItem, flexibleSpaceBarButtonItem, rightToolbarButtonItem]
    }
}


