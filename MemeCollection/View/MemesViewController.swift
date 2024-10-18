//
//  MemesViewController.swift
//  MemeCollection
//
//  Created by 김상민 on 10/18/24.
//

import UIKit

class MemesViewController: UIViewController {
    
    private var collectionView: UICollectionView!
    private var dataSource: UICollectionViewDiffableDataSource<Section, Item>!
    
    var categoryTitle: String?
    var mock = ["Meme 1", "Meme 2", "Meme 3", "Meme 4"]
    
    typealias Item = String
    enum Section {
        case main
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        configureDataSource()
    }
    
    private struct Constants {
        static let sideConstraints: CGFloat = 24
    }
}


// MARK: - DataSource
extension MemesViewController {
    private func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Section, Item>(collectionView: collectionView, cellProvider: { collectionView, indexPath, item in
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MemeCell.identifier, for: indexPath) as? MemeCell else { return UICollectionViewCell() }
            
            cell.configureCell(title: item)
            
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
        view.backgroundColor = .white
        
        configureNavBar()
        configureCollectionView()
    }
    
    private func configureNavBar() {
        self.navigationItem.title = categoryTitle
    }
    
    private func configureCollectionView() {
        let layout = configureLayout()
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(MemeCell.self, forCellWithReuseIdentifier: MemeCell.identifier)
        collectionView.showsVerticalScrollIndicator = false
        
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: Constants.sideConstraints),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -Constants.sideConstraints),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func configureLayout() -> UICollectionViewCompositionalLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5), heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(180))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        group.interItemSpacing = .fixed(16)
        
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 25
        
        let layout = UICollectionViewCompositionalLayout(section: section)
        
        return layout
    }
}

