//
//  QuickLoginViewModel.swift
//  Tireless
//
//  Created by Liam on 2023/11/21.
//

import Foundation
import Combine

final class QuickSignInViewModel: ObservableObject {
    private let appleServices: AuthController
    private let authServices: AuthServices
    @Published var authError: AuthError?
    @Published var authData: AuthData?
    private var cancellables = Set<AnyCancellable>()
    
    init(appleServices: AuthController, authServices: AuthServices = FirebaseAuthManager()) {
        self.appleServices = appleServices
        self.authServices = authServices
    }
    
    func signInWithApple() {
        appleServices.authenticate()
            .sink { [weak self] completion in
                switch completion {
                case let .failure(error):
                    self?.authError = error
                    
                case .finished:
                    break
                }
            } receiveValue: { [weak self] data in
                self?.authData = data
            }
            .store(in: &cancellables)
    }
    
    func signInWithFirebase(email: String, password: String) {
        authServices.signInWithFirebase(email: email, password: password) { [weak self] result in
            switch result {
            case let .success(data):
                self?.authData = data
                
            case let .failure(error):
                self?.authError = .firebaseError(error)
            }
        }
    }
    
    func getError() {
        authError = .firebaseError(NSError(domain: "Any error", code: 0))
    }
}

