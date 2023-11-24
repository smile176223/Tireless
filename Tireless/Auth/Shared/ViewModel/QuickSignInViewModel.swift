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
    @Published var authError: AuthError?
    @Published var authData: AuthData?
    private var cancellables = Set<AnyCancellable>()
    
    init(appleServices: AuthController) {
        self.appleServices = appleServices
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
    
    func getError() {
        authError = .firebaseError(NSError(domain: "Any error", code: 0))
    }
}

