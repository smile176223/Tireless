//
//  AuthServices.swift
//  Tireless
//
//  Created by Liam on 2023/11/24.
//

import Foundation

public protocol AuthServices {
    func signInWithApple(idToken: String, nonce: String, completion: @escaping (Result<AuthData, AuthError>) -> Void)
    func signUpWithFirebase(email: String, password: String, completion: @escaping (Result<AuthData, AuthError>) -> Void)
    func signInWithFirebase(email: String, password: String, completion: @escaping (Result<AuthData, AuthError>) -> Void)
    func signOut() throws
}
