//
//  AppleSignInControllerTests.swift
//  TirelessTests
//
//  Created by Liam on 2023/11/21.
//

import XCTest
import Tireless
import Combine
import AuthenticationServices

final class AppleSignInController: NSObject {
    
    enum AuthError: Error {
        case normal
    }
    
    typealias ControllerFactory = ([ASAuthorizationAppleIDRequest]) -> ASAuthorizationController
    private let controllerFactory: ControllerFactory
    private var nonceProvider: SecureNonce
    private let authSubject = PassthroughSubject<ASAuthorization, AuthError>()
    
    var authPublisher: AnyPublisher<ASAuthorization, AuthError> {
        authSubject.eraseToAnyPublisher()
    }
    
    init(controllerFactory: @escaping ControllerFactory = ASAuthorizationController.init, nonceProvider: SecureNonce = NonceProvider()) {
        self.controllerFactory = controllerFactory
        self.nonceProvider = nonceProvider
    }
    
    func authenticate() {
        let request = makeRequest()
        let authController =  controllerFactory([request])
        authController.delegate = self
        authController.performRequests()
    }
    
    private func makeRequest() -> ASAuthorizationAppleIDRequest {
        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = nonceProvider.generateNonce().sha256
        return request
    }
}

extension AppleSignInController: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential,
              let appleIDToken = appleIDCredential.identityToken,
              let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
            authSubject.send(completion: .failure(.normal))
            return
        }
        
        // TODO: Firebase login
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        authSubject.send(completion: .failure(.normal))
    }
}

final class AppleSignInControllerTests: XCTestCase {

    func test_authenticate_performsProperRequest() {
        let spy = ASAuthorizationController.spy
        let sut = AppleSignInController(controllerFactory: { requests in
            spy
        })
        
        sut.authenticate()
        
        XCTAssertTrue(spy.delegate === sut, "sut is delegate")
        XCTAssertEqual(spy.performRequestsCallCount, 1)
    }
}

extension ASAuthorizationController {
    static var spy: Spy {
        let dummyRequest = ASAuthorizationAppleIDProvider().createRequest()
        return Spy(authorizationRequests: [dummyRequest])
    }
    
    class Spy: ASAuthorizationController {
        private(set) var performRequestsCallCount = 0
        
        override func performRequests() {
            performRequestsCallCount += 1
        }
    }
}
