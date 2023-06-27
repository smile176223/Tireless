//
//  FireStoreClient.swift
//  Tireless
//
//  Created by Hao on 2023/6/27.
//

import Foundation
import Firebase

public enum FireStoreClientResult {
    case success(QuerySnapshot)
    case failure(Error)
}

public class FireStoreClient {
    
    private let store: Firestore
    
    public init(store: Firestore = .firestore()) {
        self.store = store
    }
    
    private struct UnexpectedValueRepresentation: Error {}
    
    public func get(from collection: String, completion: @escaping (FireStoreClientResult) -> Void) {
        store.collection(collection).getDocuments { querySnapshot, error in
            if let error = error {
                completion(.failure(error))
            } else if let querySnapshot = querySnapshot {
                completion(.success(querySnapshot))
            } else {
                completion(.failure(UnexpectedValueRepresentation()))
            }
        }
    }
}
