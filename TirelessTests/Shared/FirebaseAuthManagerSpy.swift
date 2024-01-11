//
//  FirebaseAuthManagerSpy.swift
//  TirelessTests
//
//  Created by Liam on 2023/11/22.
//

import Foundation
import Tireless
import Combine

class FirebaseAuthManagerSpy: AuthServices {
    
    enum Message: Equatable {
        case signIn(source: AuthSource, idToken: String, nonce: String)
        case signIn(email: String, password: String)
        case signUp(email: String, password: String, name: String)
        case signOut
        case signInPublisher(source: AuthSource, idToken: String, nonce: String)
        case signInPublisher(email: String, password: String)
        case signUpPublisher(email: String, password: String, name: String)
        case signOutPublisher
    }
    
    private(set) var messages = [Message]()
    private var signInFromSourceCompletions = [(Result<AuthData, AuthError>) -> Void]()
    private var signInCompletions = [(Result<AuthData, AuthError>) -> Void]()
    private var signUpCompletions = [(Result<AuthData, AuthError>) -> Void]()
    private var signOutCompletions = [(Result<Void, AuthError>) -> Void]()
    
    private var signInFromSourceRequests = [PassthroughSubject<AuthData, AuthError>]()
    private var signInRequests = [PassthroughSubject<AuthData, AuthError>]()
    private var signUpRequests = [PassthroughSubject<AuthData, AuthError>]()
    private var signOutRequests = [PassthroughSubject<Void, AuthError>]()
    
    
    func signIn(from source: AuthSource, idToken: String, nonce: String, completion: @escaping (Result<AuthData, AuthError>) -> Void) {
        messages.append(.signIn(source: source, idToken: idToken, nonce: nonce))
        signInFromSourceCompletions.append(completion)
    }
    
    func completeSignInFromSource(with error: AuthError, at index: Int = 0) {
        signInFromSourceCompletions[index](.failure(error))
    }
    
    func completeSignInFromSourceSuccessfully(with data: AuthData, at index: Int = 0) {
        signInFromSourceCompletions[index](.success(data))
    }
    
    func signIn(email: String, password: String, completion: @escaping (Result<AuthData, AuthError>) -> Void) {
        messages.append(.signIn(email: email, password: password))
        signInCompletions.append(completion)
    }
    
    func completeSignIn(with error: AuthError, at index: Int = 0) {
        signInCompletions[index](.failure(error))
    }
    
    func completeSignInSuccessfully(with data: AuthData, at index: Int = 0) {
        signInCompletions[index](.success(data))
    }
    
    func signUp(email: String, password: String, name: String, completion: @escaping (Result<AuthData, AuthError>) -> Void) {
        messages.append(.signUp(email: email, password: password, name: name))
        signUpCompletions.append(completion)
    }
    
    func completeSignUp(with error: AuthError, at index: Int = 0) {
        signUpCompletions[index](.failure(error))
    }
    
    func completeSignUpSuccessfully(with data: AuthData, at index: Int = 0) {
        signUpCompletions[index](.success(data))
    }
    
    func signOut(completion: @escaping (Result<Void, AuthError>) -> Void) {
        messages.append(.signOut)
        signOutCompletions.append(completion)
    }
    
    func completeSignOut(with error: AuthError, at index: Int = 0) {
        signOutCompletions[index](.failure(error))
    }
    
    func completeSignOutSuccessfully(at index: Int = 0) {
        signOutCompletions[index](.success(()))
    }
}

extension FirebaseAuthManagerSpy {
    func signInPublisher(from source: AuthSource, idToken: String, nonce: String) -> AnyPublisher<AuthData, AuthError> {
        messages.append(.signInPublisher(source: source, idToken: idToken, nonce: nonce))
        let publisher = PassthroughSubject<AuthData, AuthError>()
        signInFromSourceRequests.append(publisher)
        return publisher.eraseToAnyPublisher()
    }
    
    func completeSignInFormSourcePublisher(with error: AuthError, at index: Int = 0) {
        signInFromSourceRequests[index].send(completion: .failure(error))
    }
    
    func completeSignInFormSourcePublisher(with data: AuthData, at index: Int = 0) {
        signInFromSourceRequests[index].send(data)
        signInFromSourceRequests[index].send(completion: .finished)
    }
    
    func signInPublisher(email: String, password: String) -> AnyPublisher<AuthData, AuthError> {
        messages.append(.signInPublisher(email: email, password: password))
        let publisher = PassthroughSubject<AuthData, AuthError>()
        signInRequests.append(publisher)
        return publisher.eraseToAnyPublisher()
    }
    
    func completeSignInPublisher(with error: AuthError, at index: Int = 0) {
        signInRequests[index].send(completion: .failure(error))
    }
    
    func completeSignInPublisher(with data: AuthData, at index: Int = 0) {
        signInRequests[index].send(data)
        signInRequests[index].send(completion: .finished)
    }
    
    func signUpPublisher(email: String, password: String, name: String) -> AnyPublisher<AuthData, AuthError> {
        messages.append(.signUpPublisher(email: email, password: password, name: name))
        let publisher = PassthroughSubject<AuthData, AuthError>()
        signUpRequests.append(publisher)
        return publisher.eraseToAnyPublisher()
    }
    
    func completeSignUpPublisher(with error: AuthError, at index: Int = 0) {
        signUpRequests[index].send(completion: .failure(error))
    }
    
    func completeSignUpPublisher(with data: AuthData, at index: Int = 0) {
        signUpRequests[index].send(data)
        signUpRequests[index].send(completion: .finished)
    }
    
    func signOutPublisher() -> AnyPublisher<Void, AuthError> {
        messages.append(.signOutPublisher)
        let publisher = PassthroughSubject<Void, AuthError>()
        signOutRequests.append(publisher)
        return publisher.eraseToAnyPublisher()
    }
    
    func completeSignOutPublisher(with error: AuthError, at index: Int = 0) {
        signOutRequests[index].send(completion: .failure(error))
    }
    
    func completeSignOutPublisherSuccessfully(at index: Int = 0) {
        signOutRequests[index].send(Void())
        signOutRequests[index].send(completion: .finished)
    }
}
