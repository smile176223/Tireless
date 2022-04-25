//
//  HomeViewCell.swift
//  Tireless
//
//  Created by Hao on 2022/4/19.
//

import Foundation
import UIKit

class HomeViewCell: UICollectionViewCell {
    
    lazy var textLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .black
        label.numberOfLines = 0
        return label
    }()
    
    lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.alpha = 1
        return imageView
    }()
    
    lazy var masksView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.alpha = 0.5
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        textLabelConstraints()
        self.backgroundColor = .themeBG
        self.layer.cornerRadius = 12
        self.contentView.backgroundColor = .white
    }
    
    private func textLabelConstraints() {
        
        addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        addSubview(masksView)
        masksView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            masksView.topAnchor.constraint(equalTo: imageView.topAnchor),
            masksView.bottomAnchor.constraint(equalTo: imageView.bottomAnchor),
            masksView.leadingAnchor.constraint(equalTo: imageView.leadingAnchor),
            masksView.trailingAnchor.constraint(equalTo: imageView.trailingAnchor)
        ])
        
        addSubview(textLabel)
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            textLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            textLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            textLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            textLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8)
        ])
    }
}
