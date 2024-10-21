//
//  MemesViewController.swift
//  MemeCollection
//
//  Created by 김상민 on 10/18/24.
//

import UIKit

enum CellMode {
    case grid
    case editList
    case list
}

class MemesViewController: UIViewController {
    
    private var collectionView: UICollectionView!
    private var dataSource: UICollectionViewDiffableDataSource<Section, Item>!
    
    var cellMode: CellMode = .grid {
        didSet {
            updateCollectionView()
        }
    }
    var categoryTitle: String?
    var mock = ["Meme 1", "Meme 2", "Meme 3", "Meme 4", "Meme 5", "Meme 6", "MEMEMEMEMMEMEMEMEEMEMEMEME"]
    
    typealias Item = String
    enum Section {
        case main
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        configureGridDataSource()
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        collectionView.isEditing = editing
        if cellMode == .grid {
            cellMode = .editList
        } else if cellMode == .editList {
            cellMode = .grid
        }
    }
    
    private struct Constants {
        static var sideConstraints: CGFloat = 0
    }
}

// MARK: - Actions
extension MemesViewController {
    private func swipeAction(_ indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "") { [weak self] deleteAction, view, completion in
            guard let self = self else { return }
            //            self.deleteItem.send(indexPath)
            completion(true)
        }
        deleteAction.image = UIImage(systemName: "trash.fill")
        
        let editAction = UIContextualAction(style: .normal, title: "") { (action, view, completion) in

            print("editAction!")
            completion(true)
        }
        editAction.image = UIImage(systemName: "info.circle.fill")
        editAction.backgroundColor = .lightGray
        
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
}


// MARK: - DataSource
extension MemesViewController {
    private func configureGridDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Section, Item>(collectionView: collectionView, cellProvider: { collectionView, indexPath, item in
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MemeGridCell.identifier, for: indexPath) as? MemeGridCell else { return UICollectionViewCell() }
            
            cell.configureCell(title: item)
            cell.startIndicatorAnimation()
            
            return cell
        })
        updateSnapshot(mock)
    }
    
    private func configureEditListDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Section, Item>(collectionView: collectionView, cellProvider: { collectionView, indexPath, item in
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MemeEditListCell.identifier, for: indexPath) as? MemeEditListCell else { return UICollectionViewCell() }
            
            cell.configureCell(title: item)
            cell.accessories = [.delete(displayed: .whenEditing),
                                .reorder(displayed: .whenEditing),
                                .detail(displayed: .whenEditing),]
            return cell
        })
        updateSnapshot(mock)
    }
    
    private func configureListDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Section, Item>(collectionView: collectionView, cellProvider: { collectionView, indexPath, item in
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MemeListCell.identifier, for: indexPath) as? MemeListCell else { return UICollectionViewCell() }
            
            cell.configureCell(title: item)
            cell.startIndicatorAnimation()
            cell.accessories = [.delete(displayed: .whenEditing),
                                .reorder(displayed: .whenEditing),
                                .detail(displayed: .whenEditing),]
            return cell
        })
        updateSnapshot(mock)
    }
    
    private func updateSnapshot(_ items: [String]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        snapshot.appendSections([.main])
        snapshot.appendItems(items)
        dataSource.apply(snapshot)
    }
}

// MARK: - Configure View
extension MemesViewController {
    private func configureView() {
        configureNavBar()
        configureCollectionView()
        configureToolbar()
    }
    
    private func configureNavBar() {
        self.navigationItem.title = categoryTitle
        self.navigationItem.rightBarButtonItem = editButtonItem
    }
    
    private func configureCollectionView() {
        let layout = getGridLayout()
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(MemeGridCell.self, forCellWithReuseIdentifier: MemeGridCell.identifier)
        collectionView.register(MemeEditListCell.self, forCellWithReuseIdentifier: MemeEditListCell.identifier)
        collectionView.register(MemeListCell.self, forCellWithReuseIdentifier: MemeListCell.identifier)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.backgroundColor = .systemGroupedBackground
        
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: Constants.sideConstraints),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -Constants.sideConstraints),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func updateCollectionView() {
        switch cellMode {
        case .grid:
            configureGridDataSource()
            collectionView.setCollectionViewLayout(getGridLayout(), animated: false)
        case .editList:
            configureEditListDataSource()
            collectionView.setCollectionViewLayout(getEditableListLayout(), animated: false)
        case .list:
            configureListDataSource()
            collectionView.setCollectionViewLayout(getListLayout(), animated: false)
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
        
        let rightToolbarButton = UIBarButtonItem(title: "View as")
        
        let viewGridAction = UIAction(title: "Grid", image: UIImage(systemName: "square.grid.2x2")) { [weak self] _ in
            self?.setEditing(false, animated: false)
            self?.cellMode = .grid
        }
        let viewListAction = UIAction(title: "List", image: UIImage(systemName: "list.bullet")) { [weak self] _ in
            self?.setEditing(false, animated: false)
            self?.cellMode = .list
        }
        rightToolbarButton.menu = UIMenu(options: .displayInline, children: [viewListAction, viewGridAction])
        
        let leftToolbarButtonItem = UIBarButtonItem(customView: leftToolbarButton)
        let rightToolbarButtonItem = rightToolbarButton
        let flexibleSpaceBarButtonItem = UIBarButtonItem(systemItem: .flexibleSpace)
        
        self.toolbarItems = [leftToolbarButtonItem, flexibleSpaceBarButtonItem, rightToolbarButtonItem]
    }
}

// MARK: - Layout
extension MemesViewController {
    private func getGridLayout() -> UICollectionViewCompositionalLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5), heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(180))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        group.interItemSpacing = .fixed(16)
        
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 25
        section.contentInsets = .init(top: 0, leading: 24, bottom: 0, trailing: 24)
        
        let layout = UICollectionViewCompositionalLayout(section: section)
        
        return layout
    }
    
    private func getEditableListLayout() -> UICollectionViewCompositionalLayout {
        var configuration = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
        configuration.headerMode = .none
        configuration.trailingSwipeActionsConfigurationProvider = swipeAction
        let layout = UICollectionViewCompositionalLayout.list(using: configuration)
        
        return layout
    }
    
    private func getListLayout() -> UICollectionViewCompositionalLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(80))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 15
        section.contentInsets = .init(top: 0, leading: 24, bottom: 0, trailing: 24)
        
        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }
}

