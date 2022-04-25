//
//  GroupPlanView.swift
//  Tireless
//
//  Created by Hao on 2022/4/25.
//

import UIKit

class GroupPlanView: UIView {
    
    var isBackButtonTap: (() -> Void)?
    
    var isJoinButtonTap: (() -> Void)?
    
    private var imageView: UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleAspectFill
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
        label.textColor = .white
        label.font = .bold(size: 30)
        label.textAlignment = .left
        return label
    }()
    
    private var infoLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .regular(size: 15)
        label.textAlignment = .left
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        return label
    }()
    
    private var timesDaysLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .bold(size: 20)
        label.textAlignment = .left
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        return label
    }()
    
    private var createdUserLabel: UILabel = {
        let label = UILabel()
        label.textColor = .themeYellow
        label.font = .bold(size: 20)
        label.text = "發起人"
        label.textAlignment = .left
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        return label
    }()
    
    private var createdUserImage: UILabel = {
        let label = UILabel()
        label.font = .bold(size: 20)
        label.textColor = .white
        return label
    }()
    
    private var joinUserLabel: UILabel = {
        let label = UILabel()
        label.textColor = .themeYellow
        label.font = .bold(size: 20)
        label.text = "參與團員"
        label.textAlignment = .left
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        return label
    }()
    
    var joinUserImage: UILabel = {
        let label = UILabel()
        label.font = .bold(size: 20)
        label.textColor = .white
        return label
    }()
    
    private var backButton: UIButton = {
        let button = UIButton()
        let image = UIImage(named: "Icons_Back")
        button.setBackgroundImage(image, for: .normal)
        return button
    }()
    
    var joinButton: UIButton = {
        let button = UIButton()
        button.layer.cornerRadius = 16
        button.backgroundColor = .themeBGSecond
        button.setTitle("加入揪團", for: .normal)
        button.titleLabel?.font = .bold(size: 20)
        button.titleLabel?.textColor = .white
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
        labelConstraints()
        self.backgroundColor = .themeBG
        backButton.addTarget(self, action: #selector(backButtonTap), for: .touchUpInside)
        joinButton.addTarget(self, action: #selector(joinButtonTap), for: .touchUpInside)
    }
    
    @objc private func backButtonTap() {
        isBackButtonTap?()
    }
    @objc private func joinButtonTap() {
        isJoinButtonTap?()
    }
    
    func setupLayout(groupPlan: GroupPlans, plan: Plans) {
        imageView.image = UIImage(named: plan.planImage)
        titleLabel.text = groupPlan.planName
        infoLabel.text = plan.planDetail
        createdUserImage.text = groupPlan.createdName
        if groupPlan.planName == "棒式" {
            timesDaysLabel.text = "\(groupPlan.planTimes)秒/\(groupPlan.planDays)天"
        } else {
            timesDaysLabel.text = "\(groupPlan.planTimes)次/\(groupPlan.planDays)天"
        }
//        for index in userId {
//            joinUserImage.text = index.userId
//        }
    }
    
    private func viewConstraints() {
        addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            imageView.heightAnchor.constraint(equalToConstant: UIScreen.main.bounds.height / 3.5)
        ])
        addSubview(bottomView)
        bottomView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            bottomView.heightAnchor.constraint(equalToConstant: UIScreen.main.bounds.height * 3/4),
            bottomView.leadingAnchor.constraint(equalTo: leadingAnchor),
            bottomView.trailingAnchor.constraint(equalTo: trailingAnchor),
            bottomView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    private func buttonConstraints() {
        addSubview(backButton)
        backButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            backButton.topAnchor.constraint(equalTo: topAnchor, constant: 60),
            backButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 25)
        ])
        bottomView.addSubview(joinButton)
        joinButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            joinButton.bottomAnchor.constraint(equalTo: bottomView.bottomAnchor, constant: -30),
            joinButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            joinButton.widthAnchor.constraint(equalToConstant: 150)
        ])
    }
    
    private func labelConstraints() {
        bottomView.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: bottomView.topAnchor, constant: 50),
            titleLabel.leadingAnchor.constraint(equalTo: bottomView.leadingAnchor, constant: 25),
            titleLabel.trailingAnchor.constraint(greaterThanOrEqualTo: bottomView.trailingAnchor, constant: -25)
        ])
        bottomView.addSubview(infoLabel)
        infoLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            infoLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            infoLabel.leadingAnchor.constraint(equalTo: bottomView.leadingAnchor, constant: 25),
            infoLabel.trailingAnchor.constraint(equalTo: bottomView.trailingAnchor, constant: -25)
        ])
        bottomView.addSubview(timesDaysLabel)
        timesDaysLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            timesDaysLabel.topAnchor.constraint(equalTo: infoLabel.bottomAnchor, constant: 15),
            timesDaysLabel.leadingAnchor.constraint(equalTo: bottomView.leadingAnchor, constant: 25),
            timesDaysLabel.trailingAnchor.constraint(equalTo: bottomView.trailingAnchor, constant: -25)
        ])
        bottomView.addSubview(createdUserLabel)
        createdUserLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            createdUserLabel.topAnchor.constraint(equalTo: timesDaysLabel.bottomAnchor, constant: 15),
            createdUserLabel.leadingAnchor.constraint(equalTo: bottomView.leadingAnchor, constant: 25),
            createdUserLabel.trailingAnchor.constraint(equalTo: bottomView.trailingAnchor, constant: -25)
        ])
        bottomView.addSubview(createdUserImage)
        createdUserImage.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            createdUserImage.topAnchor.constraint(equalTo: createdUserLabel.bottomAnchor, constant: 10),
            createdUserImage.leadingAnchor.constraint(equalTo: bottomView.leadingAnchor, constant: 25),
            createdUserImage.trailingAnchor.constraint(greaterThanOrEqualTo: bottomView.trailingAnchor, constant: -25)
        ])
        bottomView.addSubview(joinUserLabel)
        joinUserLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            joinUserLabel.topAnchor.constraint(equalTo: createdUserImage.bottomAnchor, constant: 25),
            joinUserLabel.leadingAnchor.constraint(equalTo: bottomView.leadingAnchor, constant: 25),
            joinUserLabel.trailingAnchor.constraint(equalTo: bottomView.trailingAnchor, constant: -25)
        ])
        bottomView.addSubview(joinUserImage)
        joinUserImage.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            joinUserImage.topAnchor.constraint(equalTo: joinUserLabel.bottomAnchor, constant: 10),
            joinUserImage.leadingAnchor.constraint(equalTo: bottomView.leadingAnchor, constant: 25),
            joinUserImage.trailingAnchor.constraint(equalTo: bottomView.trailingAnchor, constant: -25)
        ])
 
    }
}
