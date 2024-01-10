//
//  SignupViewModel.swift
//  Tireless
//
//  Created by Liam on 2023/11/23.
//

import Foundation
import Combine

public final class SignupViewModel: ObservableObject {

    private let authServices: AuthServices
    @Published public var name = ""
    @Published public var email = ""
    @Published public var password = ""
    @Published public var confirmPassword = ""
    @Published public var authError: AuthError?
    @Published public var authData: AuthData?
    @Published public var isLoading: Bool = false
    
    init(authServices: AuthServices = FirebaseAuthManager()) {
        self.authServices = authServices
    }
    
    func signUp() {
        isLoading = true
        guard password == confirmPassword else {
            isLoading = false
            authError = .customError("Check password!")
            return
        }
        
        authServices.signUp(email: email, password: password, name: name) { [weak self] result in
            self?.isLoading = false
            switch result {
            case let .success(data):
                self?.authData = data

            case let .failure(error):
                self?.authError = error
            }
        }
    }
}
