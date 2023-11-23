//
//  FirebaseAuthManagerSpy.swift
//  TirelessTests
//
//  Created by Liam on 2023/11/22.
//

import Foundation
import Tireless

class FirebaseAuthManagerSpy: FirebaseAuth {
    
    enum Message: Equatable {
        case signInWithApple(idToken: String, nonce: String)
        case signUpWithFirebase(email: String, password: String)
        case signInWithFirebase(email: String, password: String)
        case signOut
    }
    
    private(set) var messages = [Message]()
    private var signInWithAppleResult = [(Result<AuthData, AuthError>) -> Void]()
    private var signUpWithFirebaseResult = [(Result<AuthData, AuthError>) -> Void]()
    private var signInWithFirebaseResult = [(Result<AuthData, AuthError>) -> Void]()
    private var signOutResult: Result<Void, Error>?
    
    func signInWithApple(idToken: String, nonce: String, completion: @escaping (Result<AuthData, AuthError>) -> Void) {
        messages.append(.signInWithApple(idToken: idToken, nonce: nonce))
        signInWithAppleResult.append(completion)
    }
    
    func completeSignInWithApple(with error: AuthError, at index: Int = 0) {
        signInWithAppleResult[index](.failure(error))
    }
    
    func completeSignInWithAppleSuccessfully(with data: AuthData, at index: Int = 0) {
        signInWithAppleResult[index](.success(data))
    }
    
    func signUpWithFirebase(email: String, password: String, completion: @escaping (Result<AuthData, AuthError>) -> Void) {
        messages.append(.signInWithFirebase(email: email, password: password))
        signUpWithFirebaseResult.append(completion)
    }
    
    func completeSignUpWithFirebase(with error: AuthError, at index: Int = 0) {
        signUpWithFirebaseResult[index](.failure(error))
    }
    
    func completeSignUpWithFirebaseSuccessfully(with data: AuthData, at index: Int = 0) {
        signUpWithFirebaseResult[index](.success(data))
    }
    
    func signInWithFirebase(email: String, password: String, completion: @escaping (Result<AuthData, AuthError>) -> Void) {
        messages.append(.signUpWithFirebase(email: email, password: password))
        signInWithFirebaseResult.append(completion)
    }
    
    func completeSignInWithFirebase(with error: AuthError, at index: Int = 0) {
        signInWithFirebaseResult[index](.failure(error))
    }
    
    func completeSignInWithFirebaseSuccessfully(with data: AuthData, at index: Int = 0) {
        signInWithFirebaseResult[index](.success(data))
    }
    
    func signOut() throws {
        messages.append(.signOut)
        try signOutResult?.get()
    }
    
    func completeSignOut(with error: Error) {
        signOutResult = .failure(error)
    }
    
    func completeSignOutSuccessfully() {
        signOutResult = .success(())
    }
    
}
