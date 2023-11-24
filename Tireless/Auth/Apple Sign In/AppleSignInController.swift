//
//  AppleSignInController.swift
//  Tireless
//
//  Created by Liam on 2023/11/21.
//

import Foundation
import Combine
import AuthenticationServices

public protocol AppleIDCredential {
    var identityToken: Data? { get }
    var user: String { get }
    var fullName: PersonNameComponents? { get }
}

extension ASAuthorizationAppleIDCredential: AppleIDCredential {}

public class AppleSignInController: NSObject {

    private let authServices: AuthServices
    private var authSubject: PassthroughSubject<AuthData, AuthError>?
    private var currentNonce: String?
    
    init(authServices: AuthServices = FirebaseAuthManager(), authSubject: PassthroughSubject<AuthData, AuthError>? = nil, currentNonce: String? = nil) {
        self.authServices = authServices
        self.authSubject = authSubject
        self.currentNonce = currentNonce
    }
    
    public func authenticate(_ controller: ASAuthorizationController, nonce: String) -> AnyPublisher<AuthData, AuthError> {
        let subject = PassthroughSubject<AuthData, AuthError>()
        authSubject = subject
        controller.delegate = self
        controller.performRequests()
        currentNonce = nonce
        return subject.eraseToAnyPublisher()
    }
}

extension AppleSignInController: ASAuthorizationControllerDelegate {
    public func didCompleteWith(credential: AppleIDCredential) {
        guard let appleIDToken = credential.identityToken,
              let idTokenString = String(data: appleIDToken, encoding: .utf8),
              let currentNonce = currentNonce else {
            authSubject?.send(completion: .failure(.unknown))
            return
        }
        
        authServices.signInWithApple(idToken: idTokenString, nonce: currentNonce) { [weak self] result in
            switch result {
            case let .success(data):
                self?.authSubject?.send(data)
                
            case let .failure(error):
                self?.authSubject?.send(completion: .failure(.firebaseError(error)))
            }
        }
    }
    
    public func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        let appleIDCredential = authorization.credential as? AppleIDCredential
        appleIDCredential.map(didCompleteWith)
    }
    
    public func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        authSubject?.send(completion: .failure(.appleError(error)))
    }
}
