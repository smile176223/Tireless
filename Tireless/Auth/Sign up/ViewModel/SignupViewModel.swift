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
    private let firestore: HTTPClient
    @Published public var name = ""
    @Published public var email = ""
    @Published public var password = ""
    @Published public var confirmPassword = ""
    @Published public var authError: AuthError?
    @Published public var authData: AuthData?
    @Published public var isLoading: Bool = false
    private var cancellables = Set<AnyCancellable>()
    
    public init(authServices: AuthServices = FirebaseAuthManager(), firestore: HTTPClient = FirestoreHTTPClient()) {
        self.authServices = authServices
        self.firestore = firestore
    }
    
    public func signUp() {
        isLoading = true
        guard password == confirmPassword else {
            isLoading = false
            authError = .customError("Check password!")
            return
        }
        
        authServices.signUpPublisher(email: email, password: password, name: name)
            .flatMap(createUser)
            .sink { [weak self] completion in
                switch completion {
                case let .failure(error):
                    self?.isLoading = false
                    self?.authError = error
                    
                case .finished:
                    break
                }
            } receiveValue: { [weak self] data in
                self?.isLoading = false
                self?.authData = data
            }
            .store(in: &cancellables)

    }
    
    private func createUser(_ data: AuthData) -> AnyPublisher<AuthData, AuthError> {
        return firestore.postPublisher(from: .user(id: data.userId), param: data.dict)
            .catch { error in
                return Fail<Void, AuthError>(error: .customError("create error"))
            }
            .map { _ in data }
            .map { UserItem(id: $0.userId, email: $0.email ?? "", name: $0.name ?? "", picture: nil) }
            .map(saveUser)
            .map { _ in data }
            .eraseToAnyPublisher()
    }
    
    private func saveUser(_ user: UserItem) -> UserItem {
        try? KeychainManager.save(.userItem, with: user)
        return user
    }
}
