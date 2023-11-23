//
//  AuthServices.swift
//  Tireless
//
//  Created by Liam on 2023/11/21.
//

import Combine

public struct AuthData {
    let email: String?
    let userId: String
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
