//
//  AuthServices.swift
//  Tireless
//
//  Created by Liam on 2023/11/24.
//

import Foundation
import FirebaseAuth

public protocol AuthServices {
    func signInWithApple(idToken: String, nonce: String, completion: @escaping (Result<AuthData, AuthError>) -> Void)
    func signUpWithFirebase(email: String, password: String, completion: @escaping (Result<AuthData, AuthError>) -> Void)
    func signInWithFirebase(email: String, password: String, completion: @escaping (Result<AuthData, AuthError>) -> Void)
    func signOut() throws
}

public final class FirebaseAuthManager: AuthServices {
    
    private let auth: Auth
    
    public init(auth: Auth = Auth.auth()) {
        self.auth = auth
    }
    
    public func signInWithApple(idToken: String, nonce: String, completion: @escaping (Result<AuthData, AuthError>) -> Void) {
        let credential = OAuthProvider.credential(withProviderID: "apple.com", idToken: idToken, rawNonce: nonce)
        auth.signIn(with: credential) { completion(Self.mapAuthResult(result: $0, error: $1)) }
    }
    
    public func signUpWithFirebase(email: String, password: String, completion: @escaping (Result<AuthData, AuthError>) -> Void) {
        auth.createUser(withEmail: email, password: password) { completion(Self.mapAuthResult(result: $0, error: $1)) }
    }
    
    public func signInWithFirebase(email: String, password: String, completion: @escaping (Result<AuthData, AuthError>) -> Void) {
        auth.signIn(withEmail: email, password: password) { completion(Self.mapAuthResult(result: $0, error: $1)) }
    }
    
    private static func mapAuthResult(result: AuthDataResult?, error: Error?) -> Result<AuthData, AuthError> {
        if let error = error {
            return .failure(.firebaseError(error))
        } else if let result = result {
            return .success(AuthData(email: result.user.email, userId: result.user.uid))
        } else {
            return .failure(.unknown)
        }
    }
    
    public func signOut() throws {
        try auth.signOut()
    }
}
