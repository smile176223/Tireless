//
//  FirebaseClient.swift
//  Tireless
//
//  Created by Liam on 2023/11/8.
//

import Foundation
import FirebaseFirestore
import Combine

public enum FirebaseError: Error {
    case invalidPath
    case dataError
    case parseError
}

public enum NetworkEndpoint {
    case user(id: String)
    
    var path: String {
        switch self {
        case .user: return "Users"
        }
    }
}

private extension NetworkEndpoint {
    func collection(in store: Firestore) -> CollectionReference {
        store.collection(path)
    }
    
    func document(in store: Firestore) -> DocumentReference {
        switch self {
        case let .user(id):
            collection(in: store).document(id)
        }
    }
}

public protocol HTTPClient {
    func get(from endpoint: NetworkEndpoint, completion: @escaping (Result<Data, Error>) -> Void)
    func post(from endpoint: NetworkEndpoint, param: [String: Any], completion: @escaping (Result<Void, Error>) -> Void)
}

public extension HTTPClient {
    func getPublisher(from endpoint: NetworkEndpoint) -> AnyPublisher<Data, Error> {
        return Deferred {
            Future { completion in
                self.get(from: endpoint, completion: completion)
            }
        }
        .eraseToAnyPublisher()
    }
    
    func postPublisher(from endpoint: NetworkEndpoint, param: [String: Any]) -> AnyPublisher<Void, Error> {
        return Deferred {
            Future { completion in
                self.post(from: endpoint, param: param, completion: completion)
            }
        }
        .eraseToAnyPublisher()
    }
}

public final class FirebaseHTTPClient: HTTPClient {
    private let firestore: Firestore
    
    public init(firestore: Firestore = Firestore.firestore()) {
        self.firestore = firestore
    }
    
    public func get(from endpoint: NetworkEndpoint, completion: @escaping (Result<Data, Error>) -> Void) {
        endpoint.document(in: firestore).getDocument { querySnapshot, error in
            completion(Result(catching: {
                if let error = error {
                    throw error
                } else if let documentData = querySnapshot?.data() {
                    let data = try JSONSerialization.data(withJSONObject: documentData, options: [])
                    return data
                } else {
                    throw FirebaseError.dataError
                }
            }))
        }
    }
    
    public func post(from endpoint: NetworkEndpoint, param: [String: Any], completion: @escaping (Result<Void, Error>) -> Void) {
        let document = endpoint.document(in: firestore)
        document.setData(param) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
}

public struct FirestoreParser {
    
    public static func parse<T: Decodable>(_ documentData: [String: Any], type: T.Type) throws -> T {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: documentData, options: [])
            let decoder = JSONDecoder()
            return try decoder.decode(T.self, from: jsonData)
        } catch {
            throw FirebaseError.parseError
        }
    }
}
