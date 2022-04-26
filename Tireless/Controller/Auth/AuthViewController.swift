//
//  AuthViewController.swift
//  Tireless
//
//  Created by Hao on 2022/4/26.
//

import UIKit
import CryptoKit
import AuthenticationServices
import FirebaseAuth

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
        
        self.currentNonce = randomNonceString()
        appleIDRequest.nonce = sha256(currentNonce!)
        
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
        checkButton.layer.cornerRadius = 25
        authView.clipsToBounds = true
        authView.layer.cornerRadius = 25
        authView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        
    }
    
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length
        
        while remainingLength > 0 {
            let randoms: [UInt8] = (0 ..< 16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    print("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
                }
                return random
            }
            
            randoms.forEach { random in
                if remainingLength == 0 {
                    return
                }
                
                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }
        
        return result
    }
    
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            return String(format: "%02x", $0)
        }.joined()
        
        return hashString
    }
}

extension AuthViewController: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController,
                                 didCompleteWithAuthorization authorization: ASAuthorization) {
        
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            guard let nonce = currentNonce else {
                print("Invalid state: A login callback was received, but no login request was sent.")
                return
            }
            guard let appleIDToken = appleIDCredential.identityToken else {
                print("Failed to fetch identity token")
                return
            }
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                print("Failed to decode identity token")
                return
            }
            let firebaseCredential = OAuthProvider.credential(withProviderID: "apple.com",
                                                              idToken: idTokenString,
                                                              rawNonce: nonce)
            
            Auth.auth().signIn(with: firebaseCredential) { [weak self] (authResult, error) in
                if let error = error {
                    print(error)
                    return
                }
                guard let authResult = authResult else {
                    return
                }
                guard let appleName = appleIDCredential.fullName else {
                    return
                }
                let formatter = PersonNameComponentsFormatter()
                formatter.style = .default
                let name = formatter.string(from: appleName)
                UserManager.shared.getCurrentUser()
                if name != "" {
                    self?.viewModel.getUser(email: authResult.user.email ?? "",
                                            userId: authResult.user.uid,
                                            name: name,
                                            picture: "")
                    self?.viewModel.createUser()
                }
                self?.finishPresent()
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
