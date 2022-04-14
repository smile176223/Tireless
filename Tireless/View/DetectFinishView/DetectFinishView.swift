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
    
    @IBOutlet weak var lottieUploadView: AnimationView!
    
    var isShareButtonTap: (() -> Void)?
    
    var isFinishButtonTap: (() -> Void)?
    
    var startFrame: CGFloat = 0
    
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
        downButton.layer.cornerRadius = 12
        shareButton.layer.cornerRadius = 12
        lineView.layer.cornerRadius = 5
        alertView.layer.cornerRadius = 20
        alertView.layer.shadowOffset = CGSize(width: 5, height: 5)
        alertView.layer.shadowOpacity = 0.7
        alertView.layer.shadowRadius = 5
        alertView.layer.shadowColor = UIColor(red: 44.0/255.0, green: 62.0/255.0, blue: 80.0/255.0, alpha: 1.0).cgColor
    }
    
    private func lottieDone() {
        lottieView.contentMode = .scaleAspectFit
        lottieView.animationSpeed = 1
        lottieView.loopMode = .loop
        lottieView.play()
    }
    
    func lottieProgress(_ toFrame: CGFloat) {
        lottieView.isHidden = true
        lottieUploadView.contentMode = .scaleAspectFit
        lottieUploadView.play(fromProgress: startFrame, toProgress: toFrame, loopMode: .playOnce) { _ in
            if self.startFrame == 1.0 {
                self.lottieUploadView.pause()
            }
        }
        startFrame = toFrame
    }
    
    @IBAction func shareButtonTap(_ sender: UIButton) {
        isShareButtonTap?()
    }
    
    @IBAction func finishButtonTap(_ sender: UIButton) {
        isFinishButtonTap?()
    }
    
}
