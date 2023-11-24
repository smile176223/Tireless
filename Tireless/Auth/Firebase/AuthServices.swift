//
//  AuthServices.swift
//  Tireless
//
//  Created by Liam on 2023/11/24.
//

import Foundation
import Combine

public struct AuthData: Equatable {
    public let email: String?
    public let userId: String
    
    public init(email: String?, userId: String) {
        self.email = email
        self.userId = userId
    }
}

public enum AuthError: Error {
    case appleError(String)
    case firebaseError(String)
    case customError(String)
    case unknown
}

public enum AuthSource {
    case apple
    case google
    case twitter
    
    var provider: String {
        switch self {
        case .apple: "apple.com"
        case .google: "google.com"
        case .twitter: "twitter.com"
        }
    }
}

public protocol AuthServices {
    func signIn(from source: AuthSource, idToken: String, nonce: String, completion: @escaping (Result<AuthData, AuthError>) -> Void)
    func signIn(email: String, password: String, completion: @escaping (Result<AuthData, AuthError>) -> Void)
    func signUp(email: String, password: String, completion: @escaping (Result<AuthData, AuthError>) -> Void)
    func signOut(completion: @escaping (Result<Void, AuthError>) -> Void)
}
