//
//  QuickLoginViewModel.swift
//  Tireless
//
//  Created by Liam on 2023/11/21.
//

import Foundation
import Combine

public final class QuickSignInViewModel: ObservableObject {
    private let appleServices: AuthController
    private let firestore: HTTPClient
    @Published public var authError: AuthError?
    @Published public var authData: AuthData?
    @Published public var isLoading: Bool = false
    private var cancellables = Set<AnyCancellable>()
    
    public init(appleServices: AuthController, firestore: HTTPClient = FirestoreHTTPClient()) {
        self.appleServices = appleServices
        self.firestore = firestore
    }
    
    public func signInWithApple() {
        appleServices.authenticate()
            .mapAction { [weak self] in
                self?.isLoading = true
            }
            .flatMap(checkUserExist)
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
    
    private func checkUserExist(_ data: AuthData) -> AnyPublisher<AuthData, AuthError> {
        return firestore.getPublisher(from: .user(id: data.userId))
            .mapToValue(data)
            .catch { [weak self] error -> AnyPublisher<AuthData, AuthError> in
                if let self = self, let error = error as? FirestoreError, case .emptyResult = error {
                    return self.createUser(data)
                } else {
                    return Fail<AuthData, AuthError>(error: .unknown).eraseToAnyPublisher()
                }
            }
            .mapToValue(data)
            .eraseToAnyPublisher()
    }
    
    private func createUser(_ data: AuthData) -> AnyPublisher<AuthData, AuthError> {
        return firestore.postPublisher(from: .user(id: data.userId), param: data.dict)
            .catch { error in
                return Fail<Void, AuthError>(error: .customError("create error"))
            }
            .map { _ in data }
            .eraseToAnyPublisher()
    }
    
    func getError() {
        isLoading = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.isLoading = false
            self.authError = .firebaseError("Any error")
        }
    }
}
