//
//  MemeCell.swift
//  MemeCollection
//
//  Created by 김상민 on 10/18/24.
//

import UIKit

class MemeGridCell: UICollectionViewListCell, MemeCell {
    typealias ButtonAction = () -> Void
    static let identifier = "MemeGridCell"
    private var thumbnailImageView: UIImageView!
    private var titleLabel: UILabel!
    private var activityIndicator: UIActivityIndicatorView!
    private var favoriteButton: UIButton!
    var buttonAction: ButtonAction?
    
    override init(frame: CGRect) {
        super .init(frame: frame)
        configureViews()
        configureIndicator()
        configureLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("error")
    }
    
    
    func configureCell(title: String, isFavorite: Bool) {
        self.titleLabel.text = title
        if var buttonConfig = favoriteButton.configuration {
            buttonConfig.image = isFavorite ? UIImage(systemName: "heart.fill") : UIImage(systemName: "heart")
            buttonConfig.baseForegroundColor = isFavorite ? .red : .black
            favoriteButton.configuration = buttonConfig
        }
    }
    
    func setThumbnail(_ image: UIImage) {
        thumbnailImageView.image = image
        thumbnailImageView.isHidden = false
        activityIndicator.stopAnimating()
    }
    
    func startIndicatorAnimation() {
        activityIndicator.startAnimating()
    }
    
    func addAction(_ action: ButtonAction?) {
        self.buttonAction = action
    }

    @objc func toggleFavorite() {
        buttonAction?()
    }
}

extension MemeGridCell {
    private func configureIndicator() {
        let activityIndicator = UIActivityIndicatorView()
        
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.hidesWhenStopped = true
        activityIndicator.startAnimating()
        self.activityIndicator = activityIndicator
        contentView.addSubview(activityIndicator)
        
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: thumbnailImageView.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: thumbnailImageView.centerYAnchor)
        ])
    }
    
    private func configureViews() {
        var backgroundConfig = self.defaultBackgroundConfiguration()
        backgroundConfig.backgroundColor = .clear
        self.backgroundConfiguration = backgroundConfig
        
        let thumbnailImageView = UIImageView()
        thumbnailImageView.translatesAutoresizingMaskIntoConstraints = false
        thumbnailImageView.isHidden = true
        thumbnailImageView.clipsToBounds = true
        thumbnailImageView.layer.cornerRadius = 10
        
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        titleLabel.textAlignment = .left
        
        let favoriteButton = UIButton()
        favoriteButton.translatesAutoresizingMaskIntoConstraints = false
        var buttonConfig = UIButton.Configuration.plain()
        buttonConfig.image = UIImage(systemName: "heart")
        buttonConfig.baseForegroundColor = .black
        favoriteButton.configuration = buttonConfig
        favoriteButton.addTarget(self, action: #selector(toggleFavorite), for: .touchUpInside)
    
        contentView.addSubview(thumbnailImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(favoriteButton)
        
        self.thumbnailImageView = thumbnailImageView
        self.titleLabel = titleLabel
        self.favoriteButton = favoriteButton
    }
    
    private func configureLayout() {
        NSLayoutConstraint.activate([
            thumbnailImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            thumbnailImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            thumbnailImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            thumbnailImageView.heightAnchor.constraint(equalTo: thumbnailImageView.widthAnchor, multiplier: 1),
            
            titleLabel.topAnchor.constraint(equalTo: thumbnailImageView.bottomAnchor, constant: 5),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: favoriteButton.leadingAnchor),
            
            favoriteButton.widthAnchor.constraint(equalToConstant: 25),
            favoriteButton.heightAnchor.constraint(equalTo: favoriteButton.widthAnchor, multiplier: 1),
            favoriteButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            favoriteButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -5)
        ])
        
    }
}

