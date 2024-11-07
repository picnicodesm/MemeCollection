//
//  MemeListCell.swift
//  MemeCollection
//
//  Created by 김상민 on 10/18/24.
//

import UIKit

class MemeListCell: UICollectionViewListCell, MemeCell {
    static let identifier = "MemeListCell"
    private var thumbnailImageView: UIImageView!
    private var titleLabel: UILabel!
    private var activityIndicator: UIActivityIndicatorView!
    
    override init(frame: CGRect) {
        super .init(frame: frame)
        configureViews()
        configureLayout()
        configureIndicator()
    }
    
    required init?(coder: NSCoder) {
        fatalError("error")
    }
    
    func configureCell(title: String) {
        self.titleLabel.text = title
    }
    
    func setThumbnail(_ image: UIImage) { 
        thumbnailImageView.image = image
        thumbnailImageView.isHidden = false
        activityIndicator.stopAnimating()
    }
    
    func startIndicatorAnimation() {
        activityIndicator.startAnimating()
    }
}

extension MemeListCell {
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
        backgroundConfig.backgroundColor = .green
        backgroundConfig.cornerRadius = 10
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
        
        contentView.addSubview(thumbnailImageView)
        contentView.addSubview(titleLabel)
        
        self.thumbnailImageView = thumbnailImageView
        self.titleLabel = titleLabel
    }
    
    private func configureLayout() {
        NSLayoutConstraint.activate([
            thumbnailImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            thumbnailImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            thumbnailImageView.widthAnchor.constraint(equalToConstant: 80),
            thumbnailImageView.heightAnchor.constraint(equalTo: thumbnailImageView.widthAnchor, multiplier: 1),
            
            titleLabel.centerYAnchor.constraint(equalTo: thumbnailImageView.centerYAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: thumbnailImageView.trailingAnchor, constant: 10),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -20)
        ])
    }
}


