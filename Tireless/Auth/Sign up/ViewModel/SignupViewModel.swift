//
//  SignupViewModel.swift
//  Tireless
//
//  Created by Liam on 2023/11/23.
//

import Foundation
import Combine

final class SignupViewModel: ObservableObject {

    private let authServices: AuthServices
    @Published var authError: AuthError?
    @Published var authData: AuthData?
    
    init(authServices: AuthServices = FirebaseAuthManager()) {
        self.authServices = authServices
    }
    
    func signUp(email: String, password: String, confirmPassword: String) {
        guard password == confirmPassword else {
            authError = .customError("Check password!")
            return
        }
        
        authServices.signUp(email: email, password: password, name: email) { [weak self] result in
            switch result {
            case let .success(data):
                self?.authData = data

            case let .failure(error):
                self?.authError = error
            }
        }
    }
}
