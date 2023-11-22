//
//  QuickLoginViewModel.swift
//  Tireless
//
//  Created by Liam on 2023/11/21.
//

import Foundation
import Combine

final class QuickLoginViewModel: ObservableObject {
    private let authServices: AuthServices
    @Published var authError: AuthError?
    @Published var authData: AuthData?
    private var cancellables = Set<AnyCancellable>()
    
    init(authServices: AuthServices) {
        self.authServices = authServices
    }
    
    func signInWithApple() {
        authServices.authenticate()
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
}

