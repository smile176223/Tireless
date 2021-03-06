//
//  PlanDetailView.swift
//  Tireless
//
//  Created by Hao on 2022/4/20.
//

import UIKit
import Lottie

class PlanDetailView: UIView {
    
    var backButtonTapped: (() -> Void)?
    
    var createButtonTapped: ((String, String) -> Void)?

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
    
    private var daysLabel: UILabel = {
        let label = UILabel()
        label.font = .bold(size: 20)
        label.text = "天數"
        label.textColor = .white
        return label
    }()
    
    private var daysCounter = CounterView()
    
    private var timesLabel: UILabel = {
        let label = UILabel()
        label.font = .bold(size: 20)
        label.text = "次數"
        label.textColor = .white
        return label
    }()
    
    private var timesCounter = CounterView()
    
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
        createButton.addTarget(self, action: #selector(createButtonTap), for: .touchUpInside)
        daysCounter.setInputField(7)
        timesCounter.setInputField(10)
    }
    
    @objc private func backButtonTap() {
        backButtonTapped?()
    }
    
    @objc private func createButtonTap() {
        createButtonTapped?(daysCounter.getInputField(), timesCounter.getInputField())
    }
    
    func setupLayout(plan: DefaultPlans) {
        titleLabel.text = plan.planName
        imageView.image = UIImage(named: plan.planImage)
        infoLabel.text = plan.planDetail
        setLottie(plan.planLottie)
        if plan.planName == "棒式" {
            timesLabel.text = "秒數"
        }
    }
    
    func setLottie(_ name: String) {
        var lottieAnimate = AnimationView()
        lottieAnimate = .init(name: name)
        lottieAnimate.contentMode = .scaleAspectFit
        lottieAnimate.loopMode = .loop
        lottieAnimate.play()
        bottomView.addSubview(lottieAnimate)
        lottieAnimate.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            lottieAnimate.topAnchor.constraint(equalTo: bottomView.topAnchor, constant: 200),
            lottieAnimate.bottomAnchor.constraint(equalTo: bottomView.bottomAnchor, constant: -150),
            lottieAnimate.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            lottieAnimate.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10)
        ])
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
        bottomView.addSubview(createButton)
        createButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            createButton.bottomAnchor.constraint(equalTo: bottomView.bottomAnchor, constant: -30),
            createButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            createButton.widthAnchor.constraint(equalToConstant: 130)
        ])
        bottomView.addSubview(daysCounter)
        daysCounter.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            daysCounter.bottomAnchor.constraint(equalTo: bottomView.bottomAnchor, constant: -100),
            daysCounter.centerXAnchor.constraint(equalTo: centerXAnchor, constant: -80),
            daysCounter.widthAnchor.constraint(equalToConstant: 130),
            daysCounter.heightAnchor.constraint(equalToConstant: 45)
        ])
        bottomView.addSubview(timesCounter)
        timesCounter.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            timesCounter.bottomAnchor.constraint(equalTo: bottomView.bottomAnchor, constant: -100),
            timesCounter.centerXAnchor.constraint(equalTo: centerXAnchor, constant: 80),
            timesCounter.widthAnchor.constraint(equalToConstant: 130),
            timesCounter.heightAnchor.constraint(equalToConstant: 45)
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
        bottomView.addSubview(daysLabel)
        daysLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            daysLabel.bottomAnchor.constraint(equalTo: daysCounter.topAnchor, constant: -10),
            daysLabel.centerXAnchor.constraint(equalTo: daysCounter.centerXAnchor)
        ])
        bottomView.addSubview(timesLabel)
        timesLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            timesLabel.bottomAnchor.constraint(equalTo: timesCounter.topAnchor, constant: -10),
            timesLabel.centerXAnchor.constraint(equalTo: timesCounter.centerXAnchor)
        ])
    }
}
