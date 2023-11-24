//
//  FirebaseAuthManagerSpy.swift
//  TirelessTests
//
//  Created by Liam on 2023/11/22.
//

import Foundation
import Tireless

class FirebaseAuthManagerSpy: AuthServices {
    enum Message: Equatable {
        case signIn(source: AuthSource, idToken: String, nonce: String)
        case signIn(email: String, password: String)
        case signUp(email: String, password: String)
        case signOut
    }
    
    private(set) var messages = [Message]()
    private var signInFromSourceCompletions = [(Result<AuthData, AuthError>) -> Void]()
    private var signInCompletions = [(Result<AuthData, AuthError>) -> Void]()
    private var signUpCompletions = [(Result<AuthData, AuthError>) -> Void]()
    private var signOutCompletions = [(Result<Void, AuthError>) -> Void]()
    
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
    
    func signUp(email: String, password: String, completion: @escaping (Result<AuthData, AuthError>) -> Void) {
        messages.append(.signUp(email: email, password: password))
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
