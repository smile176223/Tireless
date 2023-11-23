//
//  SignInViewModel.swift
//  Tireless
//
//  Created by Liam on 2023/11/23.
//

import Foundation
import Combine

public final class SignInViewModel: ObservableObject {

    private let firebaseAuth: FirebaseAuth
    @Published public var authError: AuthError?
    @Published public var authData: AuthData?
    
    public init(firebaseAuth: FirebaseAuth = FirebaseAuthManager()) {
        self.firebaseAuth = firebaseAuth
    }
    
    public func signInWithFirebase(email: String, password: String) {
        firebaseAuth.signInWithFirebase(email: email, password: password) { [weak self] result in
            switch result {
            case let .success(data):
                self?.authData = data

            case let .failure(error):
                self?.authError = error
            }
        }
    }
}

