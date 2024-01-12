//
//  Combine+Helpers.swift
//  Tireless
//
//  Created by Liam on 2023/11/30.
//

import Combine

public extension Combine.Publisher {
    func mapAction(_ action: @escaping () -> Void) -> Publishers.Map<Self, Output> {
        map { value in
            action()
            return value
        }
    }
    
    func mapToValue<T>(_ value: T) -> Publishers.Map<Self, T> {
        map { _ in
            return value
        }
    }
}
