//
//  PlanDetailView.swift
//  Tireless
//
//  Created by Hao on 2022/4/20.
//

import UIKit

class PlanDetailView: UIView {
    
    var isBackButtonTap: (() -> Void)?
    
    private var imageView: UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleAspectFill
        image.image = UIImage(named: "Cover")
        return image
    }()
    
    private var bottomView: UIView = {
        let view = UIView()
        view.backgroundColor = .themeBG
        view.clipsToBounds = true
        view.layer.cornerRadius = 25
        view.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        return view
    }()
    
    private var titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.textColor = .white
        label.font = .bold(size: 20)
        label.text = "Squat"
        label.textAlignment = .left
        return label
    }()
    
    private var createButton: UIButton = {
        let button = UIButton()
        button.layer.cornerRadius = 16
        button.backgroundColor = .themeBGSecond
        button.setTitle("建立計畫", for: .normal)
        button.titleLabel?.font = .bold(size: 20)
        button.titleLabel?.textColor = .white
        return button
    }()
    
    private var backButton: UIButton = {
        let button = UIButton()
        let image = UIImage(named: "Icons_Back")
        button.setBackgroundImage(image, for: .normal)
        return button
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
        viewConstraints()
        buttonConstraints()
        self.backgroundColor = .themeBG
        backButton.addTarget(self, action: #selector(backButtonTap), for: .touchUpInside)
    }
    
    @objc private func backButtonTap() {
        isBackButtonTap?()
    }
    
    private func viewConstraints() {
        addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            imageView.heightAnchor.constraint(equalToConstant: UIScreen.main.bounds.height / 2)
        ])
        
        addSubview(bottomView)
        bottomView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            bottomView.heightAnchor.constraint(equalToConstant: UIScreen.main.bounds.height * 3/4),
            bottomView.leadingAnchor.constraint(equalTo: leadingAnchor),
            bottomView.trailingAnchor.constraint(equalTo: trailingAnchor),
            bottomView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        bottomView.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: bottomView.topAnchor, constant: 100),
            titleLabel.leadingAnchor.constraint(equalTo: bottomView.leadingAnchor, constant: 25),
            titleLabel.trailingAnchor.constraint(greaterThanOrEqualTo: bottomView.trailingAnchor, constant: -25)
        ])
    }
    
    private func buttonConstraints() {
        addSubview(backButton)
        backButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            backButton.topAnchor.constraint(equalTo: topAnchor, constant: 60),
            backButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 25)
        ])
        
        bottomView.addSubview(createButton)
        createButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            createButton.bottomAnchor.constraint(equalTo: bottomView.bottomAnchor, constant: -40),
            createButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            createButton.widthAnchor.constraint(equalToConstant: 150)
        ])
    }
}
