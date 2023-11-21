//
//  QuickLoginViewModel.swift
//  Tireless
//
//  Created by Liam on 2023/11/21.
//

import Foundation
import AuthenticationServices

final class QuickLoginViewModel: NSObject, ObservableObject {
    @Published var loginResult: Result<Void, Error>?
    private var nonce: String?
    private let firebaseAuth: FirebaseAuth
    
    init(nonce: String? = nil, firebaseAuth: FirebaseAuth = FirebaseAuthManager()) {
        self.nonce = nonce
        self.firebaseAuth = firebaseAuth
    }
}

extension QuickLoginViewModel: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIdCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            guard let appleIdToken = appleIdCredential.identityToken,
                  let token = String(data: appleIdToken, encoding: .utf8),
                  let currentNonce = nonce else {
                return
            }
            
            firebaseAuth.signInWithApple(idToken: token, nonce: currentNonce) { result in
                switch result {
                case .success:
                    self.loginResult = .success(())
                    
                case let .failure(error):
                    self.loginResult = .failure(error)
                }
            }
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        loginResult = .failure(error)
    }
    
    func performAppleSignIn() {
        let provider = ASAuthorizationAppleIDProvider()
        let request = provider.createRequest()
        request.requestedScopes = [.fullName, .email]
        let randomNonce = CryptoKitHelper.randomNonceString()
        nonce = randomNonce
        request.nonce = CryptoKitHelper.sha256(randomNonce)
        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.performRequests()
    }
}

