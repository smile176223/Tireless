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
    
    @IBOutlet var authView: UIView!
    
    var currentNonce: String?
    
    let viewModel = AuthViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        authView.layer.cornerRadius = 20
        
        let appleIDButton: ASAuthorizationAppleIDButton =
        ASAuthorizationAppleIDButton(type: .signIn, style: .whiteOutline)
        appleIDButton.addTarget(self, action: #selector(pressSignInWithAppleButton), for: .touchUpInside)
        
        appleIDButton.frame = self.authView.bounds
        self.authView.addSubview(appleIDButton)
        appleIDButton.cornerRadius = 15
        appleIDButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            appleIDButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            appleIDButton.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
            appleIDButton.widthAnchor.constraint(equalToConstant: 300),
            appleIDButton.heightAnchor.constraint(equalToConstant: 55)
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
                    fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
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
                guard let name = appleIDCredential.fullName else {
                    return
                }
                let formatter = PersonNameComponentsFormatter()
                formatter.style = .default
                self?.viewModel.getUser(email: authResult.user.email ?? "",
                                        userId: authResult.user.uid,
                                        name: formatter.string(from: name),
                                        picture: "")
                self?.viewModel.createUser()
                self?.dismiss(animated: true)
            }
        }
    }
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        
        switch error {
        case ASAuthorizationError.canceled:
            print(error)
        case ASAuthorizationError.failed:
            print(error)
        case ASAuthorizationError.invalidResponse:
            print(error)
        case ASAuthorizationError.notHandled:
            print(error)
        case ASAuthorizationError.unknown:
            print(error)
        default:
            break
        }
        print("didCompleteWithError: \(error.localizedDescription)")
    }
}

extension AuthViewController: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
}
