//
//  AuthServices.swift
//  Tireless
//
//  Created by Liam on 2023/11/21.
//

import Combine

public struct AuthData: Equatable {
    public let email: String?
    public let userId: String
    
    public init(email: String?, userId: String) {
        self.email = email
        self.userId = userId
    }
}

public enum AuthError: Error {
    case appleError(Error)
    case firebaseError(Error)
    case customError(String)
    case unknown
}

public protocol AuthServices {
    func authenticate() -> AnyPublisher<AuthData, AuthError>
}
