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
}
