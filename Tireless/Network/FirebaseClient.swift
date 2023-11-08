//
//  FirebaseClient.swift
//  Tireless
//
//  Created by Liam on 2023/11/8.
//

import Foundation
import Firebase

public enum FirebaseError: Error {
    case invalidPath
    case dataError
    case parseError
}

public enum FirestoreCollection {
    case plan
    
    var path: String {
        switch self {
        case .plan: return "plan"
        }
    }
}

public protocol HTTPClient {
    func get(from collection: FirestoreCollection, completion: @escaping (Result<[[String: Any]], Error>) -> Void)
    func get(from collection: FirestoreCollection, document: String, completion: @escaping (Result<[String: Any], Error>) -> Void)
}

public final class FirebaseHTTPClient: HTTPClient {
    private let firestore: Firestore
    
    public init(firestore: Firestore) {
        self.firestore = firestore
    }
    
    public func get(from collection: FirestoreCollection, completion: @escaping (Result<[[String: Any]], Error>) -> Void) {
        firestore.collection(collection.path).getDocuments { querySnapshot, error in
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
    
    public func get(from collection: FirestoreCollection, document: String, completion: @escaping (Result<[String: Any], Error>) -> Void) {
        firestore.collection(collection.path).document(document).getDocument { documentSnapshot, error in
            completion(Result(catching: {
                if let error = error {
                    throw error
                } else if let document = documentSnapshot, let data = document.data() {
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
