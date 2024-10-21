//
//  MemeCell.swift
//  MemeCollection
//
//  Created by 김상민 on 10/18/24.
//

import UIKit

class MemeGridCell: UICollectionViewListCell, MemeCell {
    static let identifier = "MemeGridCell"
    private var thumbnailImageView: UIImageView!
    private var titleLabel: UILabel!
    private var activityIndicator: UIActivityIndicatorView!
    
    override init(frame: CGRect) {
        super .init(frame: frame)
        configureViews()
        configureIndicator()
        configureLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("error")
    }
    
    func configureCell(title: String) {
        self.titleLabel.text = title
    }
    
    func setThumbnail(imageData data: Data?) {
        guard let data = data else { return }
        guard let image = UIImage(data: data) else { return }
        thumbnailImageView.image = image
        thumbnailImageView.isHidden = false
        activityIndicator.stopAnimating()
    }
    
    func startIndicatorAnimation() {
        activityIndicator.startAnimating()
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
            thumbnailImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            thumbnailImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            thumbnailImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            thumbnailImageView.heightAnchor.constraint(equalTo: thumbnailImageView.widthAnchor, multiplier: 1),
            
            titleLabel.topAnchor.constraint(equalTo: thumbnailImageView.bottomAnchor, constant: 5),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
        ])
        
    }
}

