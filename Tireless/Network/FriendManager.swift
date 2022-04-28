//
//  FriendManager.swift
//  Tireless
//
//  Created by Hao on 2022/4/28.
//

import Foundation
import Firebase

class FriendManager {
    static let shared = FriendManager()
    
    private init() {}
    
    lazy var userDB = Firestore.firestore().collection("Users")
    
    func searchFriend(name: String, completion: @escaping (Result<[User], Error>) -> Void) {
        userDB.whereField("name", isEqualTo: name).getDocuments { querySnapshot, error in
            guard let querySnapshot = querySnapshot else { return }
            if let error = error {
                completion(.failure(error))
                return
            } else {
                var friends = [User]()
                for document in querySnapshot.documents {
                    if let user = try? document.data(as: User.self, decoder: Firestore.Decoder()) {
                        friends.append(user)
                    }
                }
                completion(.success(friends))
            }
        }
    }
}
