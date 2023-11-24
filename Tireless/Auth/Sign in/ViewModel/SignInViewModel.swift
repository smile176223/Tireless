//
//  SignInViewModel.swift
//  Tireless
//
//  Created by Liam on 2023/11/23.
//

import Foundation
import Combine

public final class SignInViewModel: ObservableObject {

    private let authServices: AuthServices
    @Published public var authError: AuthError?
    @Published public var authData: AuthData?
    
    public init(authServices: AuthServices = FirebaseAuthManager()) {
        self.authServices = authServices
    }
    
    public func signIn(email: String, password: String) {
        authServices.signIn(email: email, password: password) { [weak self] result in
            switch result {
            case let .success(data):
                self?.authData = data

            case let .failure(error):
                self?.authError = error
            }
        }
    }
}

