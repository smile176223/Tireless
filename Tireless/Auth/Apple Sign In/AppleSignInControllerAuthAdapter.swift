//
//  AppleSignInControllerAuthAdapter.swift
//  Tireless
//
//  Created by Liam on 2023/11/21.
//

import Foundation
import Combine
import AuthenticationServices

public final class AppleSignInControllerAuthAdapter: AuthServices {
    
    private let controller: AppleSignInController
    private let nonceProvider: SecureNonce
    
    public init(controller: AppleSignInController, nonceProvider: SecureNonce) {
        self.controller = controller
        self.nonceProvider = nonceProvider
    }
    
    public func authenticate() -> AnyPublisher<AuthData, AuthError> {
        let nonce = nonceProvider.generateNonce()
        let request = makeRequest(nonce: nonce.sha256)
        let authController = ASAuthorizationController(authorizationRequests: [request])
        return controller.authenticate(authController, nonce: nonce.raw)
    }
    
    private func makeRequest(nonce: String) -> ASAuthorizationAppleIDRequest {
        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = nonce
        return request
    }
}
