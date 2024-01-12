//
//  UserManager.swift
//  Tireless
//
//  Created by Hao on 2022/4/24.
//

import Foundation
import FirebaseFirestore
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
        userDB.document(userId).addSnapshotListener { querySnapshot, error in
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
                var users = [User]()
                DispatchQueue.global().async {
                    let semaphore = DispatchSemaphore(value: 0)
                    for friend in friends {
                        self.fetchUser(userId: friend.userId) { result in
                            switch result {
                            case .success(let user):
                                users.append(user)
                            case .failure(let error):
                                print(error)
                            }
                            semaphore.signal()
                        }
                        semaphore.wait()
                    }
                    completion(.success(users.sorted {$0.name < $1.name}))
                }
            }
        }
    }
    // Delete Account
    func deleteUser(userId: String, completion: @escaping (Result<String, Error>) -> Void) {
        deleteUserFriends(userId: userId) { result in
            switch result {
            case .success(let string):
                print(string)
                self.userDB.document(userId).delete()
                self.deleteUserShareWall(userId: userId)
                self.deleteUserDataBase(userId: userId) { result in
                    switch result {
                    case .success(let string):
                        completion(.success(string))
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
        
    }
    
    private func deleteUserDataBase(userId: String, completion: @escaping (Result<String, Error>) -> Void) {
        let joinDB = Firestore.firestore().collection("JoinGroups")
        let groupPlanDB = Firestore.firestore().collection("GroupPlans")
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
    
    private func deleteUserShareWall(userId: String) {
        let shareWallDB = Firestore.firestore().collection("shareWall")
        shareWallDB.whereField("userId", isEqualTo: userId).getDocuments { querySnapshot, error in
            guard let querySnapshot = querySnapshot else { return }
            if error != nil {
                return
            } else {
                for document in querySnapshot.documents {
                    document.reference.delete()
                }
            }
        }
    }
    
    // Delete friends
    func deleteUserFriends(userId: String, completion: @escaping (Result<String, Error>) -> Void) {
        let ref = userDB.document(userId).collection("Friends")
        ref.getDocuments { querySnapshot, error in
            guard let querySnapshot = querySnapshot else {
                return
            }
            if let error = error {
                completion(.failure(error))
                return
            } else {
                if querySnapshot.documents.count == 0 {
                    completion(.success("No friends"))
                } else {
                    for doucument in querySnapshot.documents {
                        if let userId = try? doucument.data(as: UserId.self, decoder: Firestore.Decoder()) {
                            FriendManager.shared.deleteFriend(userId: userId.userId) { result in
                                switch result {
                                case .success(let string):
                                    completion(.success(string))
                                case .failure(let error):
                                    completion(.failure(error))
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    // Block User
    func blockUser(blockId: String, completion: @escaping (Result<String, Error>) -> Void) {
        let blockLists = userDB.document(AuthManager.shared.currentUser).collection("BlockLists").document(blockId)
        blockLists.setData(["userId": blockId])
        FriendManager.shared.deleteFriend(userId: blockId) { result in
            switch result {
            case .success(let text):
                completion(.success(text))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func fetchBlockUser(completion: @escaping (Result<[String], Error>) -> Void) {
        let ref = userDB.document(AuthManager.shared.currentUser).collection("BlockLists")
        ref.addSnapshotListener { querySnapshot, error in
                guard let querySnapshot = querySnapshot else { return }
                if let error = error {
                    completion(.failure(error))
                    return
                } else {
                    var blockLists = [String]()
                    for document in querySnapshot.documents {
                        if let blockuser = try? document.data(as: Friend.self, decoder: Firestore.Decoder()) {
                            blockLists.append(blockuser.userId)
                        }
                    }
                    completion(.success(blockLists))
                }
        }
    }
}
