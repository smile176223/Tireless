//
//  HTTPClientSpy.swift
//  TirelessTests
//
//  Created by Liam on 2023/11/30.
//

import Foundation
import Tireless

class HTTPClientSpy: HTTPClient {
    
    enum Message: Equatable {
        case get(endpoint: NetworkEndpoint)
        case post(endpoint: NetworkEndpoint, param: [String : Any])
        
        static func == (lhs: HTTPClientSpy.Message, rhs: HTTPClientSpy.Message) -> Bool {
            switch (lhs, rhs) {
            case let (.get(lEndpoint), .get(rEndpoint)):
                return lEndpoint == rEndpoint
            case let (.post(lEndpoint, lParam), .post(rEndpoint, rParam)):
                return lEndpoint == rEndpoint && lParam == rParam
            default:
                return false
            }
        }
    }
    
    private(set) var messages = [Message]()
    private var getCompletions = [(Result<Data, Error>) -> Void]()
    private var postCompletions = [(Result<Void, Error>) -> Void]()
    
    func get(from endpoint: NetworkEndpoint, completion: @escaping (Result<Data, Error>) -> Void) {
        messages.append(.get(endpoint: endpoint))
        getCompletions.append(completion)
    }
    
    func completeGet(with error: Error, at index: Int = 0) {
        getCompletions[index](.failure(error))
    }
    
    func completeGetSuccessfully(with data: Data, at index: Int = 0) {
        getCompletions[index](.success(data))
    }
    
    func post(from endpoint: NetworkEndpoint, param: [String : Any], completion: @escaping (Result<Void, Error>) -> Void) {
        messages.append(.post(endpoint: endpoint, param: param))
        postCompletions.append(completion)
    }
    
    func completePost(with error: Error, at index: Int = 0) {
        postCompletions[index](.failure(error))
    }
    
    func completePostSuccessfully(at index: Int = 0) {
        postCompletions[index](.success(()))
    }
}
