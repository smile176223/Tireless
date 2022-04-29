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
    
    lazy var userDB = Firestore.firestore().collection("Users")
    
    func checkUserExist(userId: String, exist: @escaping (() -> Void), notExist: @escaping (() -> Void)) {
        userDB.document(userId).getDocument { documentSnapshot, error in
            guard let documentSnapshot = documentSnapshot else { return }
            if let error = error {
                print(error)
            } else {
                if documentSnapshot.exists == true {
                    exist()
                } else {
                    notExist()
                }
            }
        }
    }
    
    func createUser(user: User, completion: @escaping (Result<String, Error>) -> Void) {
        checkUserExist(userId: user.userId) {
            return
        } notExist: {
            let document = self.userDB.document(user.userId)
            do {
                try document.setData(from: user)
                completion(.success("Sign in Success"))
            } catch {
                completion(.failure(error))
            }
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
    
    func fetchFriends(userId: String, completion: @escaping (Result<[User], Error>) -> Void) {
        userDB.document(userId).collection("Friends").addSnapshotListener { querySnapshot, error in
            guard let querySnapshot = querySnapshot else { return }
            if let error = error {
                completion(.failure(error))
            } else {
                var friends = [Friend]()
                for document in querySnapshot.documents {
                    if let firend = try? document.data(as: Friend.self, decoder: Firestore.Decoder()) {
                        friends.append(firend)
                    }
                }
                let fetchGroup = DispatchGroup()
                var users = [User]()
                for friend in friends {
                    fetchGroup.enter()
                    self.fetchUser(userId: friend.userId) { result in
                        switch result {
                        case .success(let user):
                            users.append(user)
                        case .failure(let error):
                            print(error)
                        }
                        fetchGroup.leave()
                    }
                }
                fetchGroup.notify(queue: DispatchQueue.main) {
                    completion(.success(users.sorted {$0.name < $1.name}))
                }
            }
        }
    }
    
    func deleteUser(userId: String, completion: @escaping (Result<String, Error>) -> Void) {
        let joinDB = Firestore.firestore().collection("JoinGroups")
        let groupPlanDB = Firestore.firestore().collection("GroupPlans")
        userDB.document(userId).delete()
        joinDB.whereField("createdUserId", isEqualTo: userId).getDocuments { querySnapshot, error in
            guard let querySnapshot = querySnapshot else { return }
            if let error = error {
                completion(.failure(error))
                return
            } else {
                for document in querySnapshot.documents {
                    document.reference.delete()
                }
            }
        }
        joinDB.document().collection("JoinUsers").whereField("userId",
                                                             isEqualTo: userId).getDocuments { querySnapshot, error in
            guard let querySnapshot = querySnapshot else { return }
            if let error = error {
                completion(.failure(error))
                return
            } else {
                for document in querySnapshot.documents {
                    document.reference.delete()
                }
            }
        }
        groupPlanDB.whereField("joinUsers", arrayContains: userId).getDocuments { querySnapshot, error in
            guard let querySnapshot = querySnapshot else { return }
            if let error = error {
                completion(.failure(error))
                return
            } else {
                for document in querySnapshot.documents {
                    if var data = try? document.data(as: GroupPlanUser.self, decoder: Firestore.Decoder()) {
                        data.joinUsers.removeAll { joinUsers in
                            return joinUsers == userId
                        }
                        try? document.reference.setData(from: data)
                    }
                }
            }
        }
        completion(.success("success"))
    }
}
