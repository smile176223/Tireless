//
//  HomeHeaderView.swift
//  Tireless
//
//  Created by Hao on 2022/4/19.
//

import UIKit

class HomeHeaderView: UICollectionReusableView {
    var textLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.textColor = .white
        label.font = .bold(size: 20)
        return label
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
    }
    
    private func textLabelConstraints() {
        addSubview(textLabel)
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            textLabel.topAnchor.constraint(equalTo: topAnchor, constant: 15),
            textLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -15),
            textLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 25),
            textLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -25)
        ])
    }
}
