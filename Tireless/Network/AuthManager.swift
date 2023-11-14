//
//  AuthManager.swift
//  Tireless
//
//  Created by Hao on 2022/4/27.
//

import Foundation
import FirebaseAuth

public protocol FirebaseAuthType {
    func signInWithApple(credential: OAuthCredential)
    func signUpWithFirebase(email: String, password: String, completion: @escaping (Result<Void, Error>) -> Void)
    func signInWithFirebase(email: String, password: String, completion: @escaping (Result<Void, Error>) -> Void)
    func signOut() throws
}

public final class FirebaseAuthManager: FirebaseAuthType {
    
    enum AuthError: Error {
        case wrongPassword
        case invalidEmail
        case unknown
        case nonResponse
    }
    
    enum CreateError: Error {
        case emailAlreadyInUse
        case invalidEmail
        case unknown
        case nonResponse
    }
    
    private let auth: Auth
    
    public init(auth: Auth) {
        self.auth = auth
    }
    
    public func signInWithApple(credential: OAuthCredential) {
        auth.signIn(with: credential)
    }
    
    public func signUpWithFirebase(email: String, password: String, completion: @escaping (Result<Void, Error>) -> Void) {
        auth.createUser(withEmail: email, password: password) { result, error in
            if let error = error, let errorCode = AuthErrorCode(rawValue: error._code) {
                switch errorCode {
                case .emailAlreadyInUse:
                    completion(.failure(CreateError.emailAlreadyInUse))
                case .invalidEmail:
                    completion(.failure(CreateError.invalidEmail))
                default:
                    completion(.failure(CreateError.unknown))
                }
            } else {
                guard let result = result else {
                    completion(.failure(CreateError.nonResponse))
                    return
                }
                completion(.success(()))
            }
        }
    }
    
    public func signInWithFirebase(email: String, password: String, completion: @escaping (Result<Void, Error>) -> Void) {
        auth.signIn(withEmail: email, password: password) { result, error in
            if let error = error, let errorCode = AuthErrorCode(rawValue: error._code) {
                switch errorCode {
                case .wrongPassword:
                    completion(.failure(AuthError.wrongPassword))
                case .invalidEmail:
                    completion(.failure(AuthError.invalidEmail))
                default:
                    completion(.failure(AuthError.unknown))
                }
            } else {
                guard let result = result else {
                    completion(.failure(AuthError.nonResponse))
                    return
                }
                completion(.success(()))
            }
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
                if let errorCode = AuthErrorCode(rawValue: error._code) {
                    switch errorCode {
                    case .wrongPassword:
                        failure("密碼錯誤")
                    case .invalidEmail:
                        failure("無效的信箱")
                    default:
                        failure("登入失敗")
                    }
                }
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
                if let errorCode = AuthErrorCode(rawValue: error._code) {
                    switch errorCode {
                    case .emailAlreadyInUse:
                        failure("信箱已被使用")
                    case .invalidEmail:
                        failure("無效的信箱")
                    default:
                        failure("註冊失敗")
                    }
                }
            } else {
                guard let result = result else { return }
                success(result)
            }
        }
    }
}
