//
//  AppleSignInControllerAuthAdapterTests.swift
//  TirelessTests
//
//  Created by Liam on 2023/11/21.
//

import XCTest
import Combine
import AuthenticationServices
@testable import Tireless

class AppleSignInControllerAuthAdapterTests: XCTestCase {
    
    func test_adapter_performsProperRequest() {
        let nonceProvider = ConstantNonceProvider()
        let nonce = nonceProvider.generateNonce()
        let controller = AppleSignInControllerSpy()
        let sut = AppleSignInControllerAuthAdapter(controller: controller, nonceProvider: nonceProvider)
        
        _ = sut.authenticate()
        
        XCTAssertEqual(controller.requests.count, 1)
        XCTAssertEqual(controller.requests.first?.requestedScopes, [.fullName, .email])
        XCTAssertEqual(controller.requests.first?.nonce, nonce.sha256)
    }
    
    func test_didCompleteWithError_emitsFailure() {
        let firebaseSpy = FirebaseAuthManagerSpy()
        let sut = AppleSignInController(authServices: firebaseSpy)
        let spy = PublisherSpy(sut.authenticate(.spy, nonce: "any"))
        
        XCTAssertEqual(spy.events, [])
        
        sut.authorizationController(controller: .spy, didCompleteWithError: NSError(domain: "any", code: 0))
        
        XCTAssertEqual(spy.events, [.error])
    }
    
    func test_didCompleteWithCredential_withInvalidToken_emitsFailure() {
        let firebaseSpy = FirebaseAuthManagerSpy()
        let sut = AppleSignInController(authServices: firebaseSpy)
        let publisher = sut.authenticate(.spy, nonce: "any")
        let spy = PublisherSpy(publisher)
        
        _ = publisher
        sut.didCompleteWith(credential: Credential(
            identityToken: nil,
            user: "any user",
            fullName: PersonNameComponents()))
        
        XCTAssertEqual(spy.events, [.error])
    }
    
    func test_didCompleteWithCredential_withValidCredential_emitsEmpty() {
        let firebaseSpy = FirebaseAuthManagerSpy()
        let sut = AppleSignInController(authServices: firebaseSpy)
        let publisher = sut.authenticate(.spy, nonce: "any")
        let spy = PublisherSpy(publisher)
        
        _ = publisher
        sut.didCompleteWith(credential: Credential(
            identityToken: Data("any token".utf8),
            user: "any user",
            fullName: PersonNameComponents()))
        
        XCTAssertEqual(spy.events, [])
    }
    
    func test_didCompleteWithCredential_validCredential_invokeFirebaseAuthGetError() {
        let firebaseSpy = FirebaseAuthManagerSpy()
        let sut = AppleSignInController(authServices: firebaseSpy)
        let nonce = "any"
        let publisher = sut.authenticate(.spy, nonce: nonce)
        let spy = PublisherSpy(publisher)
        
        _ = publisher
        
        sut.didCompleteWith(credential: Credential(
            identityToken: Data("any token".utf8),
            user: "any user",
            fullName: PersonNameComponents()))
        
        firebaseSpy.completeSignInFromSource(with: .firebaseError(NSError(domain: "any error", code: 0)))
        
        XCTAssertEqual(firebaseSpy.messages, [.signIn(source: .apple, idToken: "any token", nonce: nonce)])
        XCTAssertEqual(spy.events, [.error])
    }
    
    func test_didCompleteWithCredential_validCredential_invokeFirebaseAuthSuccessfully() {
        let firebaseSpy = FirebaseAuthManagerSpy()
        let sut = AppleSignInController(authServices: firebaseSpy)
        let nonce = "any"
        let publisher = sut.authenticate(.spy, nonce: nonce)
        let spy = PublisherSpy(publisher)
        
        _ = publisher
        
        sut.didCompleteWith(credential: Credential(
            identityToken: Data("any token".utf8),
            user: "any user",
            fullName: PersonNameComponents()))
        
        firebaseSpy.completeSignInFromSourceSuccessfully(with: AuthData(email: nil, userId: "any id"))
        
        XCTAssertEqual(firebaseSpy.messages, [.signIn(source: .apple, idToken: "any token", nonce: nonce)])
        XCTAssertEqual(spy.events, [.value])
    }
    
    private class AppleSignInControllerSpy: AppleSignInController {
        var requests = [ASAuthorizationAppleIDRequest]()
        override func authenticate(_ controller: ASAuthorizationController, nonce: String) -> AnyPublisher<AuthData, AuthError> {
            requests.append(contentsOf: controller.authorizationRequests.compactMap { $0 as? ASAuthorizationAppleIDRequest })
            return Empty().eraseToAnyPublisher()
        }
    }
}

private struct Credential: AppleIDCredential {
    var identityToken: Data?
    var user: String
    var fullName: PersonNameComponents?
}

private class ConstantNonceProvider: SecureNonce {
    func generateNonce() -> Nonce {
        return Nonce(raw: "any nonce", sha256: "any sha256 nonce")
    }
}
