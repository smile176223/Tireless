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
    @Published public var email: String = ""
    @Published public var password: String = ""
    @Published public var isLoading: Bool = false
    @Published public var authError: AuthError?
    @Published public var authData: AuthData?
    
    public init(authServices: AuthServices = FirebaseAuthManager()) {
        self.authServices = authServices
    }
    
    public func signIn() {
        isLoading = true
        authServices.signIn(email: email, password: password) { [weak self] result in
            self?.isLoading = false
            
            switch result {
            case let .success(data):
                try? KeychainManager.save(.authData, with: data)
                self?.authData = data

            case let .failure(error):
                self?.authError = error
            }
        }
    }
}
