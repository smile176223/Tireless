//
//  FirebaseAuthManagerSpy.swift
//  TirelessTests
//
//  Created by Liam on 2023/11/22.
//

import Foundation
import Tireless

class FirebaseAuthManagerSpy: FirebaseAuth {
    
    enum Message {
        case signInWithApple(idToken: String, nonce: String)
        case signUpWithFirebase(email: String, password: String)
        case signInWithFirebase(email: String, password: String)
        case signOut
    }
    
    private(set) var messages = [Message]()
    private var signInWithAppleResult = [(Result<Void, Error>) -> Void]()
    private var signUpWithFirebaseResult = [(Result<Void, Error>) -> Void]()
    private var signInWithFirebaseResult = [(Result<Void, Error>) -> Void]()
    private var signOutResult: Result<Void, Error>?
    
    func signInWithApple(idToken: String, nonce: String, completion: @escaping (Result<Void, Error>) -> Void) {
        messages.append(.signInWithApple(idToken: idToken, nonce: nonce))
        signInWithAppleResult.append(completion)
    }
    
    func completeSignInWithApple(with error: Error, at index: Int) {
        signInWithAppleResult[index](.failure(error))
    }
    
    func completeSignInWithAppleSuccessfully(at index: Int) {
        signInWithAppleResult[index](.success(()))
    }
    
    func signUpWithFirebase(email: String, password: String, completion: @escaping (Result<Void, Error>) -> Void) {
        messages.append(.signInWithFirebase(email: email, password: password))
        signUpWithFirebaseResult.append(completion)
    }
    
    func completeSignUpWithFirebase(with error: Error, at index: Int) {
        signUpWithFirebaseResult[index](.failure(error))
    }
    
    func completeSignUpWithFirebaseSuccessfully(at index: Int) {
        signUpWithFirebaseResult[index](.success(()))
    }
    
    func signInWithFirebase(email: String, password: String, completion: @escaping (Result<Void, Error>) -> Void) {
        messages.append(.signUpWithFirebase(email: email, password: password))
        signInWithFirebaseResult.append(completion)
    }
    
    func completeSignInWithFirebase(with error: Error, at index: Int) {
        signInWithFirebaseResult[index](.failure(error))
    }
    
    func completeSignInWithFirebaseSuccessfully(at index: Int) {
        signInWithFirebaseResult[index](.success(()))
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
