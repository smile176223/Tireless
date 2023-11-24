//
//  FirebaseAuthManager.swift
//  Tireless
//
//  Created by Liam on 2023/11/24.
//

import Foundation
import FirebaseAuth

public final class FirebaseAuthManager: AuthServices {
    
    private let auth: Auth
    
    public init(auth: Auth = Auth.auth()) {
        self.auth = auth
    }
    
    public func signIn(from source: AuthSource, idToken: String, nonce: String, completion: @escaping (Result<AuthData, AuthError>) -> Void) {
        let credential = OAuthProvider.credential(withProviderID: source.provider, idToken: idToken, rawNonce: nonce)
        auth.signIn(with: credential) { completion(Self.mapAuthResult(result: $0, error: $1)) }
    }
    
    public func signIn(email: String, password: String, completion: @escaping (Result<AuthData, AuthError>) -> Void) {
        auth.signIn(withEmail: email, password: password) { completion(Self.mapAuthResult(result: $0, error: $1)) }
    }
    
    public func signUp(email: String, password: String, completion: @escaping (Result<AuthData, AuthError>) -> Void) {
        auth.createUser(withEmail: email, password: password) { completion(Self.mapAuthResult(result: $0, error: $1)) }
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
    
    public func signOut(completion: @escaping (Result<Void, AuthError>) -> Void) {
        do {
            try auth.signOut()
            completion(.success(()))
        } catch {
            completion(.failure(.firebaseError(error)))
        }
    }
}
