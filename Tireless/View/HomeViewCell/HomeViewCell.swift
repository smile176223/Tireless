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
        label.textAlignment = .left
        label.textColor = .white
        label.numberOfLines = 0
        label.font = .bold(size: 25)
        return label
    }()
    
    lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.alpha = 1
        return imageView
    }()
    
    var viewModel: DefaultPlansViewModel?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    func setup(viewModel: DefaultPlansViewModel) {
        self.viewModel = viewModel
        layoutCell()
    }
    
    func layoutCell() {
        textLabel.text = viewModel?.defaultPlans.planName
        imageView.image = UIImage(named: viewModel?.defaultPlans.planName ?? "")
    }
    
    private func commonInit() {
        textLabelConstraints()
        self.backgroundColor = .themeBG
        self.layer.cornerRadius = 20
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
        
        addSubview(textLabel)
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            textLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15),
            textLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -15),
            textLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -15)
            
        ])
    }
}
