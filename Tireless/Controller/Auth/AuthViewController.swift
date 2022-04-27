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
    
    @IBOutlet weak var segmetedControl: UISegmentedControl!
    
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var checkButton: UIButton!
    
    var currentNonce: String?
    
    let viewModel = AuthViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLayout()
        makeSigninWithAppleButton()
    
    }
    
    private func makeSigninWithAppleButton() {
        let appleIDButton: ASAuthorizationAppleIDButton =
        ASAuthorizationAppleIDButton(type: .signIn, style: .whiteOutline)
        appleIDButton.addTarget(self, action: #selector(pressSignInWithAppleButton), for: .touchUpInside)
        
        appleIDButton.frame = self.appleView.bounds
        self.appleView.addSubview(appleIDButton)
        appleIDButton.cornerRadius = 15
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
        segmetedControl.setTitleTextAttributes([.foregroundColor: UIColor.themeYellow!,
                                                .font: UIFont.bold(size: 15)!], for: .normal)
        segmetedControl.setTitleTextAttributes([.foregroundColor: UIColor.white,
                                                .font: UIFont.bold(size: 15)!], for: .selected)
        checkButton.layer.cornerRadius = 20
        authView.clipsToBounds = true
        authView.layer.cornerRadius = 25
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
            AuthManager.shared.signInWithApple(idToken: idTokenString,
                                               nonce: nonce,
                                               appleName: name) { [weak self] result in
                switch result {
                case .success(let authResult):
                    AuthManager.shared.getCurrentUser()
                    if name == "" {
                        name = "Tireless User"
                    }
                    self?.viewModel.getUser(email: authResult.user.email ?? "",
                                            userId: authResult.user.uid,
                                            name: name,
                                            picture: "")
                    self?.viewModel.createUser()
                    self?.finishPresent()
                case .failure(let error):
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
            tabBarController.selectedIndex = 4
        }
    }
}

extension AuthViewController: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
}
