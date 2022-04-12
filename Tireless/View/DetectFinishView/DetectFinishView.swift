//
//  DetectFinishView.swift
//  Tireless
//
//  Created by Hao on 2022/4/12.
//

import UIKit
import Lottie

class DetectFinishView: UIView {
    
    @IBOutlet weak var alertView: UIView!
    
    @IBOutlet weak var downButton: UIButton!
    
    @IBOutlet weak var shareButton: UIButton!
    
    @IBOutlet weak var lineView: UIView!
    
    @IBOutlet weak var lottieView: AnimationView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
        lottieDone()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        guard let view = loadViewFromNib() else { return }
        view.frame = self.bounds
        self.addSubview(view)
    } 
    
    private func loadViewFromNib() -> UIView? {
        let nib = UINib(nibName: "\(DetectFinishView.self)", bundle: nil)
        return nib.instantiate(withOwner: self, options: nil).first as? UIView
    }
    
    private func setupUI() {
        self.backgroundColor = .clear
        alertView.layer.cornerRadius = 20
        downButton.layer.cornerRadius = 12
        shareButton.layer.cornerRadius = 12
        lineView.layer.cornerRadius = 5
    }
    
    private func lottieDone() {
        lottieView.contentMode = .scaleAspectFit
        lottieView.animationSpeed = 1
        lottieView.loopMode = .loop
        lottieView.play()
    }
    
}
