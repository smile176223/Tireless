//
//  SignUpViewController.swift
//  Tireless
//
//  Created by Hao on 2022/4/29.
//

import UIKit
import JGProgressHUD

class SignUpViewController: UIViewController {
    
    @IBOutlet weak var nameTextField: UITextField!
    
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var checkPasswordTextField: UITextField!
    
    @IBOutlet weak var signUpButton: UIButton!
    
    let viewModel = AuthViewModel()
    
    let hud = JGProgressHUD(style: .dark)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLayout()
    }
    
    private func setupLayout() {
        signUpButton.layer.cornerRadius = 12
        nameTextField.attributedPlaceholder = NSAttributedString(string: "姓名",
                                                                 attributes: [.foregroundColor: UIColor.darkGray])
        emailTextField.attributedPlaceholder = NSAttributedString(string: "信箱",
                                                                  attributes: [.foregroundColor: UIColor.darkGray])
        passwordTextField.attributedPlaceholder = NSAttributedString(string: "密碼",
                                                                     attributes: [.foregroundColor: UIColor.darkGray])
        checkPasswordTextField.attributedPlaceholder = NSAttributedString(string: "確認密碼",
                                                                     attributes: [.foregroundColor: UIColor.darkGray])
    }
    @IBAction func signUpButtonTap(_ sender: UIButton) {
        guard let emailText = emailTextField.text,
              let passwordText = passwordTextField.text,
              let nameText = nameTextField.text,
              let checkText = checkPasswordTextField.text else {
            return
        }
        if nameText.isEmpty {
            makeAlert(show: "姓名不能為空")
            return
        }
        if emailText.isEmpty {
            makeAlert(show: "信箱不能為空")
            return
        }
        if passwordText.isEmpty {
            makeAlert(show: "密碼不能為空")
            return
        }
        if checkText.isEmpty {
            makeAlert(show: "確認密碼不能為空")
            return
        }
        if passwordText != checkText {
            makeAlert(show: "密碼不一致")
            return
        }
        hud.show(in: self.view)
        
        viewModel.signUpWithFirebase(email: emailText, password: passwordText, name: nameText) { [weak self] in
            self?.finishPresent()
        } failure: { errorText in
            self.hud.textLabel.text = errorText
            self.hud.indicatorView = JGProgressHUDErrorIndicatorView()
            self.hud.show(in: self.view)
            self.hud.dismiss(afterDelay: 1.0)
        }

    }
    
    func finishPresent() {
        self.view.window?.rootViewController?.dismiss(animated: false, completion: nil)
        if let tabBarController = self.presentingViewController as? UITabBarController {
            tabBarController.selectedIndex = 3
        }
    }
    
    func makeAlert(show: String) {
        let okAction = UIAlertAction(title: "ok", style: .cancel)
        presentAlert(withTitle: "錯誤", message: show, style: .alert, actions: [okAction])
    }

}
