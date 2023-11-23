//
//  AuthManager.swift
//  Tireless
//
//  Created by Hao on 2022/4/27.
//

import Foundation
import FirebaseAuth

public protocol FirebaseAuth {
    func signInWithApple(idToken: String, nonce: String, completion: @escaping (Result<AuthData, AuthError>) -> Void)
    func signUpWithFirebase(email: String, password: String, completion: @escaping (Result<AuthData, AuthError>) -> Void)
    func signInWithFirebase(email: String, password: String, completion: @escaping (Result<AuthData, AuthError>) -> Void)
    func signOut() throws
}

public final class FirebaseAuthManager: FirebaseAuth {
    
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

class AuthManager {
    static let shared = AuthManager()
    
    private init() {}
    
    var currentUser = String() 
    
    var currentUserData: User?
    
    var blockUsers = [String]()
    
    func signInWithApple(idToken: String, nonce: String, appleName: String,
                         completion: @escaping (Result<AuthDataResult, Error>) -> Void) {
        let firebaseCredential = OAuthProvider.credential(withProviderID: "apple.com",
                                                          idToken: idToken,
                                                          rawNonce: nonce)
        
        Auth.auth().signIn(with: firebaseCredential) { authResult, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let authResult = authResult else {
                return
            }
            completion(.success(authResult))
        }
    }
    
    func getCurrentUser(completion: @escaping (Result<Bool, Error>) -> Void) {
        Auth.auth().addStateDidChangeListener { [weak self] auth, user in
            guard let user = auth.currentUser else {
                self?.currentUser = ""
                completion(.success(false))
                return
            }
            self?.currentUser = user.uid
            UserManager.shared.fetchUser(userId: user.uid) { [weak self] result in
                switch result {
                case .success(let user):
                    self?.currentUserData = user
                    completion(.success(true))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
            UserManager.shared.fetchBlockUser { [weak self] result in
                switch result {
                case .success(let users):
                    self?.blockUsers = users
                    completion(.success(true))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }
    
    func checkCurrentUser() -> Bool {
        if Auth.auth().currentUser != nil {
            return true
        }
        return false
    }
    
    func singOut(completion: @escaping (Result<String, Error>) -> Void) {
        do {
            try Auth.auth().signOut()
            completion(.success("已登出"))
        } catch {
            completion(.failure(error))
        }
    }
    
    func deleteUser(completion: @escaping (Result<String, Error>) -> Void) {
        let needDeleteUser = self.currentUser
        UserManager.shared.deleteUser(userId: needDeleteUser) { result in
            switch result {
            case .success(let string):
                completion(.success(string))
                Auth.auth().currentUser?.delete { error in
                    if let error = error {
                        completion(.failure(error))
                    } else {
                        completion(.success(string))
                    }
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func signInWithFirebase(email: String, password: String,
                            success: @escaping ((AuthDataResult) -> Void),
                            failure: @escaping ((String) -> Void)) {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                failure("error")
            } else {
                guard let result = result else { return }
                success(result)
            }
        }
    }
    
    func signUpWithFirebase(email: String, password: String,
                            success: @escaping ((AuthDataResult) -> Void),
                            failure: @escaping ((String) -> Void)) {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                failure("error")
            } else {
                guard let result = result else { return }
                success(result)
            }
        }
    }
}
