//
//  AuthControllerSpy.swift
//  TirelessTests
//
//  Created by Liam on 2023/11/30.
//

import Combine
import Tireless

class AuthControllerSpy: AuthController {
    
    private(set) var authenticateCallCount = 0
    private var authenticateCompletions = [PassthroughSubject<AuthData, AuthError>]()
    
    func authenticate() -> AnyPublisher<AuthData, AuthError> {
        let publisher = PassthroughSubject<AuthData, AuthError>()
        authenticateCompletions.append(publisher)
        authenticateCallCount += 1
        return publisher.eraseToAnyPublisher()
    }
    
    func completeAuthenticate(with error: AuthError, at index: Int = 0) {
        authenticateCompletions[index].send(completion: .failure(error))
    }
    
    func completeAuthenticateSuccessfully(with data: AuthData, at index: Int = 0) {
        authenticateCompletions[index].send(data)
        authenticateCompletions[index].send(completion: .finished)
    }
}
