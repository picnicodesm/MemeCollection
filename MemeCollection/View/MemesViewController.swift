//
//  MemesViewController.swift
//  MemeCollection
//
//  Created by 김상민 on 10/18/24.
//

import UIKit
import Combine

enum CellMode {
    case grid
    case editList
    case list
}

class MemesViewController: UIViewController {
    private var collectionView: UICollectionView!
    private var dataSource: UICollectionViewDiffableDataSource<Section, Item>!
    private var enterToEditing = false
    var memesVM: MemesViewModel!
    var category: Category!
    var categoryUpdateHandler: ((Bool) -> Void)?
    var cellMode: CellMode = .grid {
        didSet {
            updateCollectionView()
        }
    }
    
    typealias Item = Video
    enum Section {
        case main
    }
    
    // Combine
    private var subscriptions = Set<AnyCancellable>()
    private let deleteVideoSubject = PassthroughSubject<IndexPath, Never>()
    private let itemSelectedSubject = PassthroughSubject<IndexPath, Never>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        configureGridDataSource()
        bind()
        NotificationCenter.default.addObserver(self, selector: #selector(refreshData), name: .checkVideoUpdateFromShareExtension, object: nil)
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        enterToEditing = editing
        if cellMode == .list {
            configureListDataSource()
        }
        
        super.setEditing(editing, animated: animated)
        collectionView.isEditing = editing
        if cellMode == .grid {
            cellMode = .editList
        } else if cellMode == .editList {
            cellMode = .grid
        }
    }
    
    func initialSetup(memesVM: MemesViewModel, updateHandler: @escaping (Bool) -> Void) {
        self.memesVM = memesVM
        self.category = memesVM.category
        self.categoryUpdateHandler = updateHandler
    }
    
    private func bind() {
        memesVM.$memes
            .receive(on: RunLoop.main)
            .sink { [unowned self] memes in
                self.updateSnapshot(memes)
                categoryUpdateHandler?(true)
            }.store(in: &subscriptions)
        
        deleteVideoSubject
            .sink { [unowned self] indexPath in
                let deleteItem = self.memesVM.memes[indexPath.item]
                let _ = self.memesVM.deleteVideo(deleteItem)
            }.store(in: &subscriptions)
        
        itemSelectedSubject
            .sink { indexPath in
                let destination = MemeVideoViewController()
                destination.memesVM = self.memesVM
                destination.currentIndex = indexPath.item
                self.navigationController?.pushViewController(destination, animated: true)
            }.store(in: &subscriptions)
    }
    
    @objc func refreshData() {
        memesVM.refreshMemes()
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
            
            let alert = UIAlertController(title: "해당 영상을 삭제하시겠습니까?", message: "삭제한 영상은 복구할 수 없습니다.", preferredStyle: .alert)
            let success = UIAlertAction(title: "삭제", style: .destructive) { _ in
                self.deleteVideoSubject.send(indexPath)
            }
            let cancel = UIAlertAction(title: "취소", style: .cancel)
            alert.addAction(success)
            alert.addAction(cancel)
            
            present(alert, animated: true)
            completion(true)
        }
        deleteAction.image = UIImage(systemName: "trash.fill")
        
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
    
    private func openAddVideoPage() -> UIAction {
        return UIAction { [weak self] _ in
            let destination = SetVideoViewController()
            destination.categoryId = self?.category.getId()
            destination.memesVM = self?.memesVM
            let navigationVC = UINavigationController(rootViewController: destination)
            self?.present(navigationVC, animated: true)
        }
    }
    
    private func openEditVideoPage(of video: Video) {
        let destination = SetVideoViewController()
        destination.categoryId = self.category.getId()
        destination.memesVM = self.memesVM
        destination.setToEditMode(with: video)
        let navigationVC = UINavigationController(rootViewController: destination)
        self.present(navigationVC, animated: true)
    }
}

// MARK: - DataSource
extension MemesViewController {
    private func configureGridDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Section, Item>(collectionView: collectionView, cellProvider: { collectionView, indexPath, item in
            
            let toggleFavoriteAction = { [unowned self] in
                self.memesVM.toggleFavorite(of: item)
            }
            
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MemeGridCell.identifier, for: indexPath) as? MemeGridCell else { return UICollectionViewCell() }
            
            cell.configureCell(title: item.getName(), isFavorite: item.getIsFavorite())
            cell.startIndicatorAnimation()
            cell.addAction(toggleFavoriteAction)
            if let thumbnailImage = ImageManager.shared.getSavedImage(of: item.getThumbnailIdentifier()) {
                cell.setThumbnail(thumbnailImage)
            }
            
            return cell
        })
        
        updateSnapshot(memesVM.memes)
    }
    
    
    private func configureEditListDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Section, Item>(collectionView: collectionView, cellProvider: { [unowned self] collectionView, indexPath, item in
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MemeEditListCell.identifier, for: indexPath) as? MemeEditListCell else { return UICollectionViewCell() }
            
            cell.configureCell(title: item.getName())

            if self.category.getIsForFavortie() {
                cell.accessories = [.reorder(displayed: .whenEditing),
                                    .detail(displayed: .whenEditing, actionHandler: { [unowned self] in
                                        let editVideo = memesVM.memes[indexPath.item]
                                        self.openEditVideoPage(of: editVideo)
                                    }),]
            } else {
                cell.accessories = [.delete(displayed: .whenEditing),
                                    .reorder(displayed: .whenEditing),
                                    .detail(displayed: .whenEditing, actionHandler: { [unowned self] in
                                        let editVideo = memesVM.memes[indexPath.item]
                                        self.openEditVideoPage(of: editVideo)
                                    }),]
            }
            
            return cell
        })
        
        dataSource.reorderingHandlers.canReorderItem = { item in
            return true
        }
        
        dataSource.reorderingHandlers.didReorder = { [weak self] transaction in
            if let updatedBackingStore = self?.memesVM.memes.applying(transaction.difference) {
                self?.memesVM.updateVideoOrder(to: updatedBackingStore)
            }
        }
        
        updateSnapshot(memesVM.memes)
    }
    
    
    private func configureListDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Section, Item>(collectionView: collectionView, cellProvider: { [unowned self] collectionView, indexPath, item in
            
            let toggleFavoriteAction = { [unowned self] in
                self.memesVM.toggleFavorite(of: item)
            }
            
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MemeListCell.identifier, for: indexPath) as? MemeListCell else { return UICollectionViewCell() }
            
            let deleteHandler = { [unowned self] in
                let alert = UIAlertController(title: "\(item.getName())", message: "해당 영상을 삭제하시겠습니까?\n(삭제한 영상은 복구할 수 없습니다.)", preferredStyle: .alert)
                let success = UIAlertAction(title: "삭제", style: .destructive) { _ in
                    self.deleteVideoSubject.send(indexPath)
                }
                let cancel = UIAlertAction(title: "취소", style: .cancel)
                alert.addAction(success)
                alert.addAction(cancel)
                
                present(alert, animated: true)
            }
            
            cell.configureCell(title: item.getName(), isFavorite: item.getIsFavorite())
            cell.startIndicatorAnimation()
            cell.addAction(toggleFavoriteAction)
            if enterToEditing {
                cell.hideFavoriteBtn()
            } else {
                cell.showFavoriteBtn()
            }
            
            if self.category.getIsForFavortie() {
                cell.accessories = [.reorder(displayed: .whenEditing),
                                    .detail(displayed: .whenEditing, actionHandler: { [unowned self] in
                                        let editVideo = memesVM.memes[indexPath.item]
                                        self.openEditVideoPage(of: editVideo)
                                    }),]
            } else {
                cell.accessories = [.delete(displayed: .whenEditing, actionHandler: deleteHandler),
                                    .reorder(displayed: .whenEditing),
                                    .detail(displayed: .whenEditing, actionHandler: { [unowned self] in
                                        let editVideo = memesVM.memes[indexPath.item]
                                        self.openEditVideoPage(of: editVideo)
                                    }),]
            }
            
            if let thumbnailImage = ImageManager.shared.getSavedImage(of: item.getThumbnailIdentifier()) {
                cell.setThumbnail(thumbnailImage)
            }
            
            return cell
        })
        
        dataSource.reorderingHandlers.canReorderItem = { item in
            return true
        }
        
        dataSource.reorderingHandlers.didReorder = { [weak self] transaction in
            if let updatedBackingStore = self?.memesVM.memes.applying(transaction.difference) {
                self?.memesVM.updateVideoOrder(to: updatedBackingStore)
            }
        }
        
        updateSnapshot(memesVM.memes)
    }
    
    private func updateSnapshot(_ items: [Video]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        snapshot.appendSections([.main])
        snapshot.appendItems(items)
        dataSource.applySnapshotUsingReloadData(snapshot)
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
        self.navigationItem.title = category.getName()
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
        collectionView.delegate = self
        
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
        leftToolbarButton.addAction(openAddVideoPage(), for: .touchUpInside)
        
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
        
        if category.getIsForFavortie() == true {
            self.toolbarItems = [flexibleSpaceBarButtonItem, rightToolbarButton]
        } else {
            self.toolbarItems = [leftToolbarButtonItem, flexibleSpaceBarButtonItem, rightToolbarButtonItem]
        }
    }
}

// MARK: - Layout
extension MemesViewController {
    private func getGridLayout() -> UICollectionViewCompositionalLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5), heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(200))
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

// MARK: - Delegate
extension MemesViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.collectionView.deselectItem(at: indexPath, animated: false)
        itemSelectedSubject.send(indexPath)
    }
}
