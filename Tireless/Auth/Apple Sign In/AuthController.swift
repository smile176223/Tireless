//
//  AuthServices.swift
//  Tireless
//
//  Created by Liam on 2023/11/21.
//

import Combine

public protocol AuthController {
    func authenticate() -> AnyPublisher<AuthData, AuthError>
}
