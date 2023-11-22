//
//  AuthServices.swift
//  Tireless
//
//  Created by Liam on 2023/11/21.
//

import Combine

public struct AuthData {}

public enum AuthError: Error {
    case appleError(Error)
    case firebaseError(Error)
    case unknown
}

public protocol AuthServices {
    func authenticate() -> AnyPublisher<AuthData, AuthError>
}
