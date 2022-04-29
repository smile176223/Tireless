//
//  LoadingLottie.swift
//  Tireless
//
//  Created by Hao on 2022/4/29.
//

import UIKit
import Lottie

class LoadingLottie: UIView {
    
    let animationView: AnimationView
    
    init(animationName: String) {
        self.animationView = AnimationView(name: animationName)
        super.init(frame: .zero)
        commonInit()
    }
    
    init() {
        self.animationView = AnimationView()
        super.init(frame: .zero)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func commonInit() {
        addSubview(animationView)
        animationView.translatesAutoresizingMaskIntoConstraints = false
        animationView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        animationView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        animationView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        animationView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        animationView.loopMode = .playOnce
    }
    
    func play() {
        animationView.play()
    }
    
}
