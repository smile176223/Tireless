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
    
    @IBOutlet weak var signUpButton: UIButton!
    
    let viewModel = AuthViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLayout()
    }
    
    private func setupLayout() {
        signUpButton.layer.cornerRadius = 20
        nameTextField.attributedPlaceholder = NSAttributedString(string: "Name",
                                                                 attributes: [.foregroundColor: UIColor.darkGray])
        emailTextField.attributedPlaceholder = NSAttributedString(string: "Email",
                                                                  attributes: [.foregroundColor: UIColor.darkGray])
        passwordTextField.attributedPlaceholder = NSAttributedString(string: "Password",
                                                                     attributes: [.foregroundColor: UIColor.darkGray])
    }
    @IBAction func signUpButtonTap(_ sender: UIButton) {
        guard let emailText = emailTextField.text,
              let passwordText = passwordTextField.text,
              let nameText = nameTextField.text else {
            return
        }
        AuthManager.shared.signUpWithFirebase(email: emailText, password: passwordText) { [weak self] result in
            switch result {
            case .success(let authResult):
                self?.viewModel.getUser(email: authResult.user.email ?? "",
                                        userId: authResult.user.uid,
                                        name: nameText,
                                        picture: "")
                self?.viewModel.createUser()
                self?.finishPresent()
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func finishPresent() {
        self.view.window?.rootViewController?.dismiss(animated: false, completion: nil)
        if let tabBarController = self.presentingViewController as? UITabBarController {
            tabBarController.selectedIndex = 3
        }
    }
}
