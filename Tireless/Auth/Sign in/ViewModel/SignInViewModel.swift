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
    private let firestore: HTTPClient
    @Published public var email: String = ""
    @Published public var password: String = ""
    @Published public var isLoading: Bool = false
    @Published public var authError: AuthError?
    @Published public var authData: AuthData?
    
    public init(authServices: AuthServices = FirebaseAuthManager(), firestore: HTTPClient = FirestoreHTTPClient()) {
        self.authServices = authServices
        self.firestore = firestore
    }
    
    public func signIn() {
        isLoading = true
        authServices.signIn(email: email, password: password) { [weak self] result in
            self?.isLoading = false
            
            switch result {
            case let .success(data):
                self?.authData = data

            case let .failure(error):
                self?.authError = error
            }
        }
    }
    
    private func fetchUser(_ data: AuthData) -> AnyPublisher<AuthData, AuthError> {
        return firestore.getPublisher(from: .user(id: data.userId))
            .tryMap(UserMapper.map)
            .map(saveUser)
            .map { AuthData(email: $0.email, userId: $0.id, name: $0.name) }
            .catch { _ in Fail<AuthData, AuthError>(error: .unknown).eraseToAnyPublisher() }
            .eraseToAnyPublisher()
    }
    
    private func saveUser(_ user: UserItem) -> UserItem {
        try? KeychainManager.save(.userItem, with: user)
        return user
    }
}
