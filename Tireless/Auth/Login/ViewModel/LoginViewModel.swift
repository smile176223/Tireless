//
//  LoginViewModel.swift
//  Tireless
//
//  Created by Liam on 2023/11/23.
//

import Foundation
import Combine

final class LoginViewModel: ObservableObject {

    private let firebaseAuth: FirebaseAuth
    @Published var authError: AuthError?
    @Published var authData: AuthData?
    
    init(firebaseAuth: FirebaseAuth = FirebaseAuthManager()) {
        self.firebaseAuth = firebaseAuth
    }
    
    func signInWithFirebase(email: String, password: String) {
        firebaseAuth.signInWithFirebase(email: email, password: password) { [weak self] result in
            switch result {
            case .success:
                self?.authData = AuthData()

            case let .failure(error):
                self?.authError = .firebaseError(error)
            }
        }
    }
}

