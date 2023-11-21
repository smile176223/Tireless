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
    
    private var nonceProvider: SecureNonce
    private var authSubject: PassthroughSubject<AuthData, AuthError>?
    private var currentNonce: String?
    
    public init(nonceProvider: SecureNonce = NonceProvider()) {
        self.nonceProvider = nonceProvider
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
            authSubject?.send(completion: .failure(.normal))
            return
        }
        
        // TODO: Firebase login
    }
    
    public func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        let appleIDCredential = authorization.credential as? AppleIDCredential
        appleIDCredential.map(didCompleteWith)
    }
    
    public func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        authSubject?.send(completion: .failure(.normal))
    }
}
