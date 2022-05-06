//
//  SignUpViewController.swift
//  Tireless
//
//  Created by Hao on 2022/4/29.
//

import UIKit

class SignUpViewController: UIViewController {
    
    @IBOutlet weak var nameTextField: UITextField!
    
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var checkPasswordTextField: UITextField!
    
    @IBOutlet weak var signUpButton: UIButton!
    
    let viewModel = AuthViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLayout()
    }
    
    private func setupLayout() {
        signUpButton.layer.cornerRadius = 12
        nameTextField.attributedPlaceholder = NSAttributedString(string: "Name",
                                                                 attributes: [.foregroundColor: UIColor.darkGray])
        emailTextField.attributedPlaceholder = NSAttributedString(string: "Email",
                                                                  attributes: [.foregroundColor: UIColor.darkGray])
        passwordTextField.attributedPlaceholder = NSAttributedString(string: "Password",
                                                                     attributes: [.foregroundColor: UIColor.darkGray])
        checkPasswordTextField.attributedPlaceholder = NSAttributedString(string: "Check Password",
                                                                     attributes: [.foregroundColor: UIColor.darkGray])
    }
    @IBAction func signUpButtonTap(_ sender: UIButton) {
        guard let emailText = emailTextField.text,
              let passwordText = passwordTextField.text,
              let nameText = nameTextField.text,
              let checkText = checkPasswordTextField.text else {
            return
        }
        if nameText.isEmpty == true {
            makeAlert(show: "姓名不能為空")
            return
        }
        if emailText.isEmpty == true {
            makeAlert(show: "信箱不能為空")
            return
        }
        if passwordText.isEmpty == true {
            makeAlert(show: "密碼不能為空")
            return
        }
        if checkText.isEmpty == true {
            makeAlert(show: "確認密碼不能為空")
            return
        }
        if passwordText != checkText {
            makeAlert(show: "密碼不一致")
            return
        }
        AuthManager.shared.signUpWithFirebase(email: emailText,
                                              password: passwordText) { [weak self] authResult in
            self?.viewModel.getUser(email: authResult.user.email ?? "",
                                    userId: authResult.user.uid,
                                    name: nameText,
                                    picture: "")
            self?.viewModel.createUser()
            self?.finishPresent()
        } failure: { errorText in
            self.makeAlert(show: errorText)
        }
    }
    
    func finishPresent() {
        self.view.window?.rootViewController?.dismiss(animated: false, completion: nil)
        if let tabBarController = self.presentingViewController as? UITabBarController {
            tabBarController.selectedIndex = 3
        }
    }
    
    func makeAlert(show: String) {
        let alertController = UIAlertController(title: "錯誤", message: show, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "ok", style: .default) { _ in
            alertController.dismiss(animated: true)
        }
        alertController.addAction(okAction)
        self.present(alertController, animated: true)
    }

}
