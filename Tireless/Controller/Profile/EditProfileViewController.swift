//
//  EditProfileViewController.swift
//  Tireless
//
//  Created by Hao on 2022/5/15.
//

import UIKit

class EditProfileViewController: UIViewController {
    
    @IBOutlet private weak var editView: UIView!
    
    @IBOutlet private weak var nameTextField: UITextField!
    
    @IBOutlet private weak var checkButton: UIButton!
    
    private let maskView = UIView(frame: UIScreen.main.bounds)
    
    var checkbuttonTapped: (() -> Void)?
    
    let viewModel = EditProfileViewModel()

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
        self.editView.layer.cornerRadius = 15
        self.checkButton.layer.cornerRadius = 15
        self.nameTextField.text = viewModel.userName
    }
    
    @IBAction func checkButtonTap(_ sender: UIButton) {
        guard let name = nameTextField.text else {
            return
        }
        viewModel.changeUserName(name: name) {
            self.checkbuttonTapped?()
        }
        maskView.removeFromSuperview()
        self.dismiss(animated: true, completion: nil)
    }
}
