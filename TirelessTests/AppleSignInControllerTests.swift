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
    
    func authenticate() -> AnyPublisher<Auth, AuthError> {
        let nonce = nonceProvider.generateNonce()
        let request = makeRequest(nonce: nonce.sha256)
        let authController = ASAuthorizationController(authorizationRequests: [request])
        return controller.authenticate(authController, nonce: nonce.sha256)
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
        
        _ = sut.authenticate()
        
        XCTAssertEqual(controller.requests.count, 1)
        XCTAssertEqual(controller.requests.first?.requestedScopes, [.fullName, .email])
        XCTAssertEqual(controller.requests.first?.nonce, nonce.sha256)
    }
    
    func test_didCompleteWithError_emitsFailure() {
        let sut = AppleSignInController()
        let spy = PublisherSpy(sut.authenticate(.spy, nonce: "any"))
        
        XCTAssertEqual(spy.events, [])
        
        sut.authorizationController(controller: .spy, didCompleteWithError: NSError(domain: "any", code: 0))
        
        XCTAssertEqual(spy.events, [.error])
    }
    
    private class AppleSignInControllerSpy: AppleSignInController {
        var requests = [ASAuthorizationAppleIDRequest]()
        override func authenticate(_ controller: ASAuthorizationController, nonce: String) -> AnyPublisher<Auth, AuthError> {
            requests.append(contentsOf: controller.authorizationRequests.compactMap { $0 as? ASAuthorizationAppleIDRequest })
            return Empty().eraseToAnyPublisher()
        }
    }
}

private class PublisherSpy<Success, Failure: Error> {
    private var cancellable: Cancellable? = nil
    private(set) var events = [Event]()
    
    enum Event {
        case value
        case finished
        case error
    }
    
    init(_ publisher: AnyPublisher<Success, Failure>) {
        cancellable = publisher.sink(receiveCompletion: { completion in
            switch completion {
            case .failure:
                self.events.append(.error)
                
            case .finished:
                self.events.append(.finished)
            }
        }, receiveValue: { _ in
            self.events.append(.value)
        })
    }
}

public struct Auth {}

public enum AuthError: Error {
    case normal
}

public protocol AuthServices {
    func authenticate() -> AnyPublisher<Auth, AuthError>
}

class AppleSignInController: NSObject {
    
    private var nonceProvider: SecureNonce
    private var authSubject: PassthroughSubject<Auth, AuthError>?
    private var currentNonce: String?
    
    init(nonceProvider: SecureNonce = NonceProvider()) {
        self.nonceProvider = nonceProvider
    }
    
    func authenticate(_ controller: ASAuthorizationController, nonce: String) -> AnyPublisher<Auth, AuthError> {
        let subject = PassthroughSubject<Auth, AuthError>()
        authSubject = subject
        controller.delegate = self
        controller.performRequests()
        currentNonce = nonce
        return subject.eraseToAnyPublisher()
    }
}

extension AppleSignInController: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential,
              let appleIDToken = appleIDCredential.identityToken,
              let idTokenString = String(data: appleIDToken, encoding: .utf8),
              let currentNonce = currentNonce else {
            authSubject?.send(completion: .failure(.normal))
            return
        }
        
        // TODO: Firebase login
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        authSubject?.send(completion: .failure(.normal))
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
        
        _ = sut.authenticate(spy, nonce: "any")
        
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
