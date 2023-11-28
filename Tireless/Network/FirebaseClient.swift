//
//  FirebaseClient.swift
//  Tireless
//
//  Created by Liam on 2023/11/8.
//

import Foundation
import FirebaseFirestore

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

extension NetworkEndpoint {
    func collection(in store: Firestore) -> CollectionReference {
        store.collection(path)
    }
    
    func document(in store: Firestore) -> DocumentReference {
        switch self {
        case let .user(id):
            collection(in: store).document(id)
            
        default:
            collection(in: store).document()
        }
    }
}

public protocol HTTPClient {
    func get(from endpoint: NetworkEndpoint, completion: @escaping (Result<[[String: Any]], Error>) -> Void)
}

public final class FirebaseHTTPClient: HTTPClient {
    private let firestore: Firestore
    
    public init(firestore: Firestore) {
        self.firestore = firestore
    }
    
    public func get(from endpoint: NetworkEndpoint, completion: @escaping (Result<[[String: Any]], Error>) -> Void) {
        endpoint.collection(in: firestore).getDocuments { querySnapshot, error in
            completion(Result(catching: {
                if let error = error {
                    throw error
                } else if let query = querySnapshot {
                    var data: [[String: Any]] = []
                    for document in query.documents {
                        data.append(document.data())
                    }
                    return data
                } else {
                    throw FirebaseError.dataError
                }
            }))
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
