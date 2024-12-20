//
//  ViewController.swift
//  MemeCollection
//
//  Created by 김상민 on 10/14/24.
//

import UIKit
import Combine

class MainViewController: UIViewController {
    
    private var collectionView: UICollectionView!
    private var dataSource: UICollectionViewDiffableDataSource<Section, Item>!
    private let viewModel = MainViewModel()
    private let deleteItem = PassthroughSubject<IndexPath, Never>()
    private let cellSelectEvent = PassthroughSubject<Category, Never>()
    private let cellIdentifier = "CollectionViewListCell"
    
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
        NotificationCenter.default.addObserver(self, selector: #selector(refreshData), name: .checkVideoUpdateFromShareExtension, object: nil)
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
            self.viewModel.deleteCategory(indexPath)
        }
        .store(in: &subscriptions)
        
        cellSelectEvent
            .receive(on: RunLoop.main)
            .sink { [unowned self] category in
                let vm = MemesViewModel(of: category)
                let destination = MemesViewController()
                destination.initialSetup(memesVM: vm) { isUpdated in // 로직 수정 생각해보기
                    if isUpdated {
                        self.viewModel.refreshCategory()
                    }
                }
                navigationController?.pushViewController(destination, animated: true)
            }
            .store(in: &subscriptions)
    }
    
    @objc func refreshData() {
        viewModel.refreshCategory()
    }
}

// MARK: - DataSource
extension MainViewController {
    private func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Section, Item>(collectionView: collectionView, cellProvider: { collectionView, indexPath, item in
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionViewListCell", for: indexPath) as? UICollectionViewListCell else { return UICollectionViewCell() }
            
            var config = cell.defaultContentConfiguration()
            config.text = item.getName()
            cell.contentConfiguration = config
            
            if item.getIsForFavortie() {
                cell.accessories = [
                    .reorder(displayed: .whenEditing),
                    .disclosureIndicator(displayed: .whenNotEditing),
                    .label(text: "\(self.viewModel.getVideoNums(of: item))", displayed: .whenNotEditing)
                ]
            } else {
                cell.accessories = [
                    .delete(displayed: .whenEditing),
                    .reorder(displayed: .whenEditing),
                    .detail(displayed: .whenEditing, actionHandler: { [unowned self] in
                        self.openEditCategoryView(with: indexPath)
                    }),
                    .disclosureIndicator(displayed: .whenNotEditing),
                    .label(text: "\(self.viewModel.getVideoNums(of: item))", displayed: .whenNotEditing)
                ]
            }
            
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
        dataSource.applySnapshotUsingReloadData(snapshot)
    }
}

// MARK: - Actions
extension MainViewController {
    private func swipeAction(_ indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        if viewModel.categories[indexPath.item].getIsForFavortie() { return nil }
        
        let deleteAction = UIContextualAction(style: .destructive, title: "deleteCategory") { [weak self] deleteAction, view, completion in
            
            guard let self = self else { return }
        
            let alert = UIAlertController(title: "해당 카테고리를 삭제하시겠습니까?", message: "삭제한 카테고리는 복구할 수 없습니다. 또한, 해당 카테고리 안의 영상들이 모두 삭제됩니다.", preferredStyle: .alert)
            let success = UIAlertAction(title: "삭제", style: .destructive) { _ in
                self.deleteItem.send(indexPath)
            }
            let cancel = UIAlertAction(title: "취소", style: .cancel)
            alert.addAction(success)
            alert.addAction(cancel)
            
            present(alert, animated: true)
            completion(true)
        }
        deleteAction.image = UIImage(systemName: "trash.fill")
        
        let editAction = UIContextualAction(style: .normal, title: "") { [weak self] (action, view, completion) in
            guard let self = self else { return }
            self.openEditCategoryView(with: indexPath)
            completion(true)
        }
        editAction.image = UIImage(systemName: "info.circle.fill")
        editAction.backgroundColor = .lightGray
        
        if collectionView.isEditing {
            return UISwipeActionsConfiguration(actions: [deleteAction])
        }
        
        return UISwipeActionsConfiguration(actions: [deleteAction, editAction])
    }
    
    private func openEditCategoryView(with indexPath: IndexPath) {
        let newCategoryView = SetCategoryViewController()
        newCategoryView.viewModel = self.viewModel
        let editingCategoryId = viewModel.categories[indexPath.item].getId()
        newCategoryView.setToEditMode(of: editingCategoryId)
        let navigationViewController = UINavigationController(rootViewController: newCategoryView)
        self.present(navigationViewController, animated: true)
    }
    
    @objc private func openNewCategoryView() {
        let newCategoryView = SetCategoryViewController()
        newCategoryView.viewModel = self.viewModel
        let navigationViewController = UINavigationController(rootViewController: newCategoryView)
        self.present(navigationViewController, animated: true)
    }
    
    /*
    @objc func testOrder() {
        let db = DataBaseManager.shared
        print(db.read(RealmCategory.self))
 
    }
    */
    
}

// MARK: - Configure View
extension MainViewController {
    private func configureView() {        
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
        collectionView.register(UICollectionViewListCell.self, forCellWithReuseIdentifier: cellIdentifier)
        collectionView.delegate = self
        
        view.addSubview(collectionView)
    }
    
    private func configureNavigationBarItem() {
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationItem.title = "MemeCollection"
        self.navigationItem.backButtonTitle = "Back"
        self.navigationItem.rightBarButtonItem = editButtonItem
//        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Order", style: .plain, target: self, action: #selector(testOrder))
    }
    
    private func configureToolbar() {
        self.navigationController?.isToolbarHidden = false
        
        /* Add Video Button in Main View having selecting category
        let leftToolbarButton = UIButton(type: .system)
        var leftToolbarButtonConfig = UIButton.Configuration.plain()
        leftToolbarButtonConfig.title = "Add Video"
        leftToolbarButtonConfig.image = UIImage(systemName: "plus.circle.fill")
        leftToolbarButtonConfig.imagePadding = 10
        leftToolbarButtonConfig.imagePlacement = NSDirectionalRectEdge.leading
        leftToolbarButtonConfig.contentInsets = .zero
        leftToolbarButton.configuration = leftToolbarButtonConfig
        
        let leftToolbarButtonItem = UIBarButtonItem(customView: leftToolbarButton)
        */
        
        let rightToolbarButtonItem = UIBarButtonItem(title: "New Category", style: .plain, target: self, action: #selector(openNewCategoryView))
        let flexibleSpaceBarButtonItem = UIBarButtonItem(systemItem: .flexibleSpace)
        
        self.toolbarItems = [flexibleSpaceBarButtonItem, rightToolbarButtonItem]
    }
}

// MARK: - Delegate
extension MainViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
              let category = viewModel.categories[indexPath.item]
              self.collectionView.deselectItem(at: indexPath, animated: false)
              cellSelectEvent.send(category)
    }
}
