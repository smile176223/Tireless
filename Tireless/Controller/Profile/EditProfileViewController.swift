//
//  EditProfileViewController.swift
//  Tireless
//
//  Created by Hao on 2022/5/15.
//

import UIKit

class EditProfileViewController: UIViewController {
    
    @IBOutlet weak var editView: UIView!
    
    @IBOutlet weak var nameTextField: UITextField!
    
    @IBOutlet weak var checkButton: UIButton!
    
    let maskView = UIView(frame: UIScreen.main.bounds)
    
    var isCheckbuttonTap: (() -> Void)?
    
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
        self.nameTextField.text = AuthManager.shared.currentUserData?.name
    }
    
    @IBAction func checkButtonTap(_ sender: UIButton) {
        guard let name = nameTextField.text else { return }
        ProfileManager.shared.changeUserName(name: name) { result in
            switch result {
            case .success(let text):
                AuthManager.shared.getCurrentUser { result in
                    switch result {
                    case .success(let bool):
                        print(bool)
                        self.isCheckbuttonTap?()
                        ProgressHUD.showSuccess(text: "修改成功")
                    case .failure(let error):
                        print(error)
                    }
                }
                print(text)
            case .failure(let error):
//                if let tryerror = error as? TirelessError {
//                    tryerror.text
//                }
                ProgressHUD.showFailure()
                print(error)
            }
        }
        maskView.removeFromSuperview()
        self.dismiss(animated: true, completion: nil)
    }
}
