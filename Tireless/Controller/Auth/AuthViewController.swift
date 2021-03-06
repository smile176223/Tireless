//
//  AuthViewController.swift
//  Tireless
//
//  Created by Hao on 2022/4/26.
//

import UIKit
import AuthenticationServices
import JGProgressHUD

class AuthViewController: UIViewController {
    
    @IBOutlet private weak var authView: UIView!
    
    @IBOutlet private weak var appleView: UIView!
    
    @IBOutlet private weak var emailTextField: UITextField!
    
    @IBOutlet private weak var passwordTextField: UITextField!
    
    @IBOutlet private weak var signInButton: UIButton!
    
    private var currentNonce: String?
    
    let viewModel = AuthViewModel()
    
    private let hud = JGProgressHUD(style: .dark)
    
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
        hud.show(in: self.view)
        AuthManager.shared.signInWithFirebase(email: emailText, password: passwordText) { result in
            print(result)
            ProgressHUD.showSuccess(text: "登入成功")
            self.finishPresent()
        } failure: { error in
            self.hud.textLabel.text = error
            self.hud.indicatorView = JGProgressHUDErrorIndicatorView()
            self.hud.show(in: self.view)
            self.hud.dismiss(afterDelay: 1.0)
        }

    }
    
    @IBAction func signUpButtonTap(_ sender: UIButton) {
        signUpPush()
    }
    
    @IBAction func privacyPoliciesButtonTap(_ sender: UIButton) {
        guard let webVC = UIStoryboard.auth.instantiateViewController(withIdentifier: "\(WebkitViewController.self)")
                as? WebkitViewController
        else {
            return
        }
        webVC.viewModel = WebkitViewModel(
            urlString: "https://pages.flycricket.io/tireless-1/privacy.html")
        self.navigationItem.backButtonTitle = ""
        self.navigationController?.pushViewController(webVC, animated: true)
    }
    
    @IBAction func eulaButtonTap(_ sender: UIButton) {
        guard let webVC = UIStoryboard.auth.instantiateViewController(withIdentifier: "\(WebkitViewController.self)")
                as? WebkitViewController
        else {
            return
        }
        webVC.viewModel = WebkitViewModel(
            urlString: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")
        self.navigationItem.backButtonTitle = ""
        self.navigationController?.pushViewController(webVC, animated: true)
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
        emailTextField.attributedPlaceholder = NSAttributedString(string: "信箱",
                                                                  attributes: [.foregroundColor: UIColor.darkGray])
        passwordTextField.attributedPlaceholder = NSAttributedString(string: "密碼",
                                                                     attributes: [.foregroundColor: UIColor.darkGray])
    }
}

extension AuthViewController: ASAuthorizationControllerDelegate {
    
    func authorizationController(controller: ASAuthorizationController,
                                 didCompleteWithAuthorization authorization: ASAuthorization) {
        hud.show(in: self.view)
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            guard let nonce = currentNonce,
                  let appleIDToken = appleIDCredential.identityToken,
                  let idTokenString = String(data: appleIDToken, encoding: .utf8),
                  let appleName = appleIDCredential.fullName else {
                return
            }
            let formatter = PersonNameComponentsFormatter()
            formatter.style = .default
            var name = formatter.string(from: appleName)
            AuthManager.shared.signInWithApple(idToken: idTokenString,
                                               nonce: nonce,
                                               appleName: name) { [weak self] result in
                guard let self = self else {
                    return
                }
                switch result {
                case .success(let authResult):
                    AuthManager.shared.getCurrentUser { result in
                        switch result {
                        case .success(let bool):
                            print(bool)
                            if bool == true {
//                                ProgressHUD.showSuccess(text: "登入成功")
                            }
                        case .failure(let error):
                            self.hud.textLabel.text = "登入失敗"
                            self.hud.indicatorView = JGProgressHUDErrorIndicatorView()
                            self.hud.show(in: self.view)
                            self.hud.dismiss(afterDelay: 1.0)
                            print(error)
                        }
                    }
                    if name == "" {
                        name = "Tireless"
                    }
                    self.viewModel.getUser(email: authResult.user.email ?? "",
                                            userId: authResult.user.uid,
                                            name: name,
                                            picture: "")
                    self.viewModel.createUser()
                    ProgressHUD.showSuccess(text: "登入成功")
                    self.finishPresent()
                case .failure(let error):
                    ProgressHUD.showFailure(text: "登入失敗")
                    print(error)
                }
            }
        }
    }
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print("didCompleteWithError: \(error.localizedDescription)")
    }
    
    private func finishPresent() {
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
