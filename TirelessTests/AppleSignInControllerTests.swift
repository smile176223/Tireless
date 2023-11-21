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
        let nonce = nonceProvider.generateNonce()
        let request = makeRequest(nonce: nonce.sha256)
        let authController = ASAuthorizationController(authorizationRequests: [request])
        controller.authenticate(authController, nonce: nonce.sha256)
    }
    
    private func makeRequest(nonce: String) -> ASAuthorizationAppleIDRequest {
        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = nonce
        return request
    }
}

class AppleSignInControllerAuthAdapterTests: XCTestCase {
    
    func test_adapter_performsProperRequest() {
        let nonceProvider = ConstantNonceProvider()
        let nonce = nonceProvider.generateNonce()
        let controller = AppleSignInControllerSpy()
        let sut = AppleSignInControllerAuthAdapter(controller: controller, nonceProvider: nonceProvider)
        
        sut.authenticate()
        
        XCTAssertEqual(controller.requests.count, 1)
        XCTAssertEqual(controller.requests.first?.requestedScopes, [.fullName, .email])
        XCTAssertEqual(controller.requests.first?.nonce, nonce.sha256)
    }
    
    func test_didCompleteWithError_emitsFailure() {
        let sut = AppleSignInController()
        
        var receivedError: Error?
        let cancellable = sut.authPublisher.sink { completion in
            switch completion {
            case let .failure(error):
                receivedError = error
                
            case .finished:
                XCTFail("Should have received completion with error")
            }
        } receiveValue: { _ in
            XCTFail("Should have received completion with error")
        }
        
        sut.authorizationController(controller: .spy, didCompleteWithError: NSError(domain: "any", code: 0))
        
        XCTAssertNotNil(receivedError)
        cancellable.cancel()
    }
    
    private class AppleSignInControllerSpy: AppleSignInController {
        var requests = [ASAuthorizationAppleIDRequest]()
        override func authenticate(_ controller: ASAuthorizationController, nonce: String) {
            requests.append(contentsOf: controller.authorizationRequests.compactMap { $0 as? ASAuthorizationAppleIDRequest })
        }
    }
}

public protocol AuthServices {
    func authenticate()
}

class AppleSignInController: NSObject {
    
    enum AuthError: Error {
        case normal
    }
    
    private var nonceProvider: SecureNonce
    private let authSubject = PassthroughSubject<ASAuthorization, AuthError>()
    private var currentNonce: String?
    
    var authPublisher: AnyPublisher<ASAuthorization, AuthError> {
        authSubject.eraseToAnyPublisher()
    }
    
    init(nonceProvider: SecureNonce = NonceProvider()) {
        self.nonceProvider = nonceProvider
    }
    
    func authenticate(_ controller: ASAuthorizationController, nonce: String) {
        controller.delegate = self
        controller.performRequests()
        currentNonce = nonce
    }
}

extension AppleSignInController: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential,
              let appleIDToken = appleIDCredential.identityToken,
              let idTokenString = String(data: appleIDToken, encoding: .utf8),
              let currentNonce = currentNonce else {
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
        let spy = ASAuthorizationController.spy
        let sut = AppleSignInController()
        
        sut.authenticate(spy, nonce: "any")
        
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
