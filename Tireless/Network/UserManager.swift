//
//  UserManager.swift
//  Tireless
//
//  Created by Hao on 2022/4/24.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift
import FirebaseAuth

class UserManager {
    static let shared = UserManager()
    
    private init() {}
    
    var currentUser = String()
    
    lazy var userDB = Firestore.firestore().collection("Users")
    
    func getCurrentUser() {
        guard let user = Auth.auth().currentUser else {
            currentUser = ""
            return
        }
        currentUser = user.uid
    }
    
    func createUser(user: User, completion: @escaping (Result<String, Error>) -> Void) {
        let document = userDB.document(user.userId)
        do {
            try document.setData(from: user)
            completion(.success("Sign in Success"))
        } catch {
            completion(.failure(error))
        }
    }
    
    func fetchUser(userId: String, completion: @escaping (Result<User, Error>) -> Void) {
        userDB.document(userId).getDocument { querySnapshot, error in
            guard let querySnapshot = querySnapshot else { return }
            if let error = error {
                completion(.failure(error))
            } else {
                if let user = try? querySnapshot.data(as: User.self, decoder: Firestore.Decoder()) {
                    completion(.success(user))
                }
            }
        }
    }
    
    func fetchFriends(userId: String, completion: @escaping (Result<[Friends], Error>) -> Void) {
        userDB.document(userId).collection("Friends").getDocuments { querySnapshot, error in
            guard let querySnapshot = querySnapshot else { return }
            if let error = error {
                completion(.failure(error))
            } else {
                var friends = [Friends]()
                for document in querySnapshot.documents {
                    if let firend = try? document.data(as: Friends.self, decoder: Firestore.Decoder()) {
                        friends.append(firend)
                    }
                }
                completion(.success(friends))
            }
        }
    }
}
