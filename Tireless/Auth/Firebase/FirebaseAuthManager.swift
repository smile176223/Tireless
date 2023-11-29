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
    
    public func signUp(email: String, password: String, name: String, completion: @escaping (Result<AuthData, AuthError>) -> Void) {
        auth.createUser(withEmail: email, password: password) { completion(Self.mapAuthResult(name: name, result: $0, error: $1)) }
    }
    
    public func signOut(completion: @escaping (Result<Void, AuthError>) -> Void) {
        do {
            try auth.signOut()
            completion(.success(()))
        } catch {
            completion(.failure(.firebaseError("Sign out error")))
        }
    }
}

extension FirebaseAuthManager {
    private static func mapAuthResult(name: String? = nil, result: AuthDataResult?, error: Error?) -> Result<AuthData, AuthError> {
        if let error = error {
            return .failure(.firebaseError(mapFirebaseError(error)))
        } else if let result = result {
            return .success(AuthData(email: result.user.email, userId: result.user.uid, name: name))
        } else {
            return .failure(.unknown)
        }
    }
    
    private static func mapFirebaseError(_ error: Error) -> String {
        if let errorCode = AuthErrorCode.Code(rawValue: error._code) {
            switch errorCode {
            case .userNotFound:
                return "User not found"
            case .networkError:
                return "Network error"
            case .tooManyRequests:
                return "Too many requests. Please Try again later."
            case .invalidEmail:
                return "Invalid email address"
            case .userDisabled:
                return "User disabled"
            case .wrongPassword:
                return "Wrong password"
            case .invalidCredential:
                return "Invalid credential"
            case .emailAlreadyInUse:
                return "Email address already in use"
            case .weakPassword:
                return "Weak password"
            default:
                return "Unknown error"
            }
        } else {
            return "Unknown error"
        }
    }
}
