//
//  SignupViewModel.swift
//  Tireless
//
//  Created by Liam on 2023/11/23.
//

import Foundation
import Combine

final class SignupViewModel: ObservableObject {

    private let firebaseAuth: FirebaseAuth
    @Published var authError: AuthError?
    @Published var authData: AuthData?
    
    init(firebaseAuth: FirebaseAuth = FirebaseAuthManager()) {
        self.firebaseAuth = firebaseAuth
    }
    
    func signUpWithFirebase(email: String, password: String, confirmPassword: String) {
        guard password == confirmPassword else {
            authError = .customError("Check password!")
            return
        }
        
        firebaseAuth.signUpWithFirebase(email: email, password: password) { [weak self] result in
            switch result {
            case let .success(data):
                self?.authData = data

            case let .failure(error):
                self?.authError = .firebaseError(error)
            }
        }
    }
}
