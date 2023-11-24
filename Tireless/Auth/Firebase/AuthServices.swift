//
//  AuthServices.swift
//  Tireless
//
//  Created by Liam on 2023/11/24.
//

import Foundation
import Combine

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
    func signUpWithFirebase(email: String, password: String, completion: @escaping (Result<AuthData, AuthError>) -> Void)
    func signInWithFirebase(email: String, password: String, completion: @escaping (Result<AuthData, AuthError>) -> Void)
    func signOut() throws
}
