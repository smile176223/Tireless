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
    
    var createGroupButton: UIButton = {
        let button = UIButton()
        button.setTitle("發起揪團", for: .normal)
        button.titleLabel?.font = .regular(size: 15)
        button.setTitleColor(UIColor.themeBG, for: .normal)
        button.backgroundColor = .themeYellow
        return button
    }()
    
    var isCreateButtonTap: (() -> Void)?

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
        createGroupButton.isHidden = true
        createGroupButton.addTarget(self, action: #selector(createButtonTap), for: .touchUpInside)
        createGroupButton.layer.cornerRadius = 12
    }
    
    @objc func createButtonTap() {
        isCreateButtonTap?()
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
        
        addSubview(createGroupButton)
        createGroupButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            createGroupButton.centerYAnchor.constraint(equalTo: textLabel.centerYAnchor),
            createGroupButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -25),
            createGroupButton.widthAnchor.constraint(equalToConstant: 80)
        ])
    }
}
