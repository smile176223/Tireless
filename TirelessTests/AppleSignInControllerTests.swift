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

final class AppleSignInControllerAuthAdapter: AuthServices {
    
    private let controller: AppleSignInController
    private let nonceProvider: SecureNonce
    
    init(controller: AppleSignInController, nonceProvider: SecureNonce) {
        self.controller = controller
        self.nonceProvider = nonceProvider
    }
    
    func authenticate() {
        let request = makeRequest()
        let authController = ASAuthorizationController(authorizationRequests: [request])
        controller.authenticate(authController)
    }
    
    private func makeRequest() -> ASAuthorizationAppleIDRequest {
        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = nonceProvider.generateNonce().raw
        return request
    }
}

class AppleSignInControllerAuthAdapterTests: XCTestCase {
    
    func test_adapter_performsProperRequest() {
        let nonceProvider = ConstantNonceProvider()
        let nonce = nonceProvider.generateNonce().raw
        let controller = AppleSignInControllerSpy()
        let sut = AppleSignInControllerAuthAdapter(controller: controller, nonceProvider: nonceProvider)
        
        sut.authenticate()
        
        XCTAssertEqual(controller.requests.count, 1)
        XCTAssertEqual(controller.requests.first?.requestedScopes, [.fullName, .email])
        XCTAssertEqual(controller.requests.first?.nonce, nonce)
    }
    
    private class AppleSignInControllerSpy: AppleSignInController {
        var requests = [ASAuthorizationAppleIDRequest]()
        override func authenticate(_ controller: ASAuthorizationController) {
            requests.append(contentsOf: controller.authorizationRequests.compactMap { $0 as? ASAuthorizationAppleIDRequest })
        }
    }
}

public protocol AuthServices {
    func authenticate()
}

class AppleSignInController: NSObject, AuthServices {
    
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
    
    func authenticate(_ controller: ASAuthorizationController) {
        
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
        request.nonce = nonceProvider.generateNonce().raw
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

private class ConstantNonceProvider: SecureNonce {
    func generateNonce() -> Nonce {
        return Nonce(raw: "any nonce", sha256: "any sha256 nonce")
    }
}

class AppleSignInControllerTests: XCTestCase {

    func test_authenticate_performsProperRequest() {
        let nonceProvider = ConstantNonceProvider()
        let nonce = nonceProvider.generateNonce().raw
        let spy = ASAuthorizationController.spy
        var receivedRequests = [ASAuthorizationAppleIDRequest]()
        let sut = AppleSignInController(controllerFactory: { requests in
            receivedRequests += requests
            return spy
        }, nonceProvider: nonceProvider)
        
        sut.authenticate()
        
        XCTAssertEqual(receivedRequests.count, 1)
        XCTAssertEqual(receivedRequests.first?.requestedScopes, [.fullName, .email])
        XCTAssertEqual(receivedRequests.first?.nonce, nonce)
        XCTAssertTrue(spy.delegate === sut)
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
