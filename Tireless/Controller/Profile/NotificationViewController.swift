//
//  NotificationViewController.swift
//  Tireless
//
//  Created by Hao on 2022/5/11.
//

import UIKit

class NotificationViewController: UIViewController {
    
    @IBOutlet weak var notifyView: UIView!
    
    @IBOutlet weak var datePicker: UIDatePicker!
    
    @IBOutlet weak var checkButton: UIButton!
    
    let maskView = UIView(frame: UIScreen.main.bounds)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setMaskView()
        setupLayout()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if touches.first?.view == self.view {
            maskView.removeFromSuperview()
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    private func setMaskView() {
        maskView.backgroundColor = .black
        maskView.alpha = 0
        presentingViewController?.view.addSubview(maskView)
        
        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.5, delay: 0) {
            self.maskView.alpha = 0.5
        }
    }
    
    private func setupLayout() {
        self.notifyView.layer.cornerRadius = 15
        self.checkButton.layer.cornerRadius = 15
        datePicker.setValue(UIColor.white, forKeyPath: "textColor")
    }
}
