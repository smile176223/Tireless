//
//  Publisher+TestHelpers.swift
//  TirelessTests
//
//  Created by Liam on 2023/11/21.
//

import XCTest
import Combine

extension XCTestCase {
    class PublisherSpy<Success, Failure: Error> {
        private var cancellable: Cancellable? = nil
        private(set) var events = [Event]()
        
        enum Event {
            case value
            case finished
            case error
        }
        
        init(_ publisher: AnyPublisher<Success, Failure>) {
            cancellable = publisher.sink(receiveCompletion: { completion in
                switch completion {
                case .failure:
                    self.events.append(.error)
                    
                case .finished:
                    self.events.append(.finished)
                }
            }, receiveValue: { _ in
                self.events.append(.value)
            })
        }
    }
}
