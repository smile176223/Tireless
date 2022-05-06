//
//  AuthViewController.swift
//  Tireless
//
//  Created by Hao on 2022/4/26.
//

import UIKit
import AuthenticationServices

class AuthViewController: UIViewController {
    
    @IBOutlet weak var authView: UIView!
    
    @IBOutlet weak var appleView: UIView!
    
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var signInButton: UIButton!
    
    var currentNonce: String?
    
    let viewModel = AuthViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLayout()
        makeSigninWithAppleButton()
    
    }
    @IBAction func signInButtonTap(_ sender: UIButton) {
        guard let emailText = emailTextField.text,
              let passwordText = passwordTextField.text else {
            return
        }
        ProgressHUD.show()
        AuthManager.shared.signInWithFirebase(email: emailText, password: passwordText) { result in
            switch result {
            case .success(let result):
                print(result)
                ProgressHUD.showSuccess(text: "登入成功")
                self.finishPresent()
            case .failure(let error):
                ProgressHUD.showSuccess(text: "登入失敗")
                print(error)
            }
        }
    }
    
    @IBAction func signUpButtonTap(_ sender: UIButton) {
        signUpPush()
    }
    
    private func makeSigninWithAppleButton() {
        let appleIDButton: ASAuthorizationAppleIDButton =
        ASAuthorizationAppleIDButton(type: .signIn, style: .whiteOutline)
        appleIDButton.addTarget(self, action: #selector(pressSignInWithAppleButton), for: .touchUpInside)
        
        appleIDButton.frame = self.appleView.bounds
        self.appleView.addSubview(appleIDButton)
        appleIDButton.cornerRadius = 12
        appleIDButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            appleIDButton.topAnchor.constraint(equalTo: appleView.topAnchor),
            appleIDButton.bottomAnchor.constraint(equalTo: appleView.bottomAnchor),
            appleIDButton.leadingAnchor.constraint(equalTo: appleView.leadingAnchor),
            appleIDButton.trailingAnchor.constraint(equalTo: appleView.trailingAnchor)
        ])
    }
    
    @objc func pressSignInWithAppleButton() {
        let appleIDRequest: ASAuthorizationAppleIDRequest =
        ASAuthorizationAppleIDProvider().createRequest()
        appleIDRequest.requestedScopes = [.fullName, .email]

        self.currentNonce = CryptoKitHelper.randomNonceString()
        appleIDRequest.nonce = CryptoKitHelper.sha256(currentNonce!)
        
        let controller: ASAuthorizationController =
        ASAuthorizationController(authorizationRequests: [appleIDRequest])
        controller.delegate = self
        controller.presentationContextProvider = self
        controller.performRequests()
    }
    
    private func setupLayout() {
        signInButton.layer.cornerRadius = 12
        authView.clipsToBounds = true
        authView.layer.cornerRadius = 15
        authView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        emailTextField.attributedPlaceholder = NSAttributedString(string: "Email",
                                                                  attributes: [.foregroundColor: UIColor.darkGray])
        passwordTextField.attributedPlaceholder = NSAttributedString(string: "Password",
                                                                     attributes: [.foregroundColor: UIColor.darkGray])
    }
}

extension AuthViewController: ASAuthorizationControllerDelegate {
    
    func authorizationController(controller: ASAuthorizationController,
                                 didCompleteWithAuthorization authorization: ASAuthorization) {
        
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            guard let nonce = currentNonce else {
                return
            }
            guard let appleIDToken = appleIDCredential.identityToken else {
                return
            }
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                return
            }
            guard let appleName = appleIDCredential.fullName else {
                return
            }
            let formatter = PersonNameComponentsFormatter()
            formatter.style = .default
            var name = formatter.string(from: appleName)
            ProgressHUD.show()
            AuthManager.shared.signInWithApple(idToken: idTokenString,
                                               nonce: nonce,
                                               appleName: name) { [weak self] result in
                switch result {
                case .success(let authResult):
                    AuthManager.shared.getCurrentUser { result in
                        switch result {
                        case .success(let bool):
                            print(bool)
                            ProgressHUD.showSuccess(text: "登入成功")
                        case .failure(let error):
                            ProgressHUD.showSuccess(text: "登入失敗")
                            print(error)
                        }
                    }
                    if name == "" {
                        name = "Tireless"
                    }
                    self?.viewModel.getUser(email: authResult.user.email ?? "",
                                            userId: authResult.user.uid,
                                            name: name,
                                            picture: "")
                    self?.viewModel.createUser()
                    self?.finishPresent()
                case .failure(let error):
                    ProgressHUD.showSuccess(text: "登入失敗")
                    print(error)
                }
            }
        }
    }
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print("didCompleteWithError: \(error.localizedDescription)")
    }
    
    func finishPresent() {
        self.view.window?.rootViewController?.dismiss(animated: false, completion: nil)
        if let tabBarController = self.presentingViewController as? UITabBarController {
            tabBarController.selectedIndex = 3
        }
    }
    
    private func signUpPush() {
        guard let signupVC = storyboard?.instantiateViewController(withIdentifier: "\(SignUpViewController.self)")
                as? SignUpViewController
        else {
            return
        }
        self.navigationItem.backButtonTitle = ""
        self.navigationController?.pushViewController(signupVC, animated: true)
    }
}

extension AuthViewController: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
}
