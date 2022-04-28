//
//  FriendManager.swift
//  Tireless
//
//  Created by Hao on 2022/4/28.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

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
    
    func inviteFriend(userId: String) {
        let ref = userDB.document(userId).collection("ReceiveInvite").document(AuthManager.shared.currentUser)
        ref.setData(["userId": AuthManager.shared.currentUser])
        let userRef = userDB.document( AuthManager.shared.currentUser).collection("InviteFriends").document(userId)
        userRef.setData(["userId": userId])
    }
    
    func checkInvite() {
        
    }
    
    func checkReceive(completion: @escaping (Result<[User], Error>) -> Void) {
        let ref = userDB.document(AuthManager.shared.currentUser).collection("ReceiveInvite")
        ref.addSnapshotListener { querySnapshot, error in
            guard let querySnapshot = querySnapshot else { return }
            if let error = error {
                print(error)
            } else {
                var users = [User]()
                for document in querySnapshot.documents {
                    if let user = try? document.data(as: UserId.self, decoder: Firestore.Decoder()) {
                        UserManager.shared.fetchUser(userId: user.userId) { result in
                            switch result {
                            case .success(let user):
                                users.append(user)
                                completion(.success(users))
                            case .failure(let error):
                                completion(.failure(error))
                            }
                        }
                    }
                }
            }
        }
    }
    
    func addFriend() {
        
    }
    
    func deleteFriend(userId: String, completion: @escaping (Result<String, Error>) -> Void) {
        let ref = userDB.document(AuthManager.shared.currentUser).collection("Friends")
        let otherRef = userDB.document(userId).collection("Friends")
        ref.whereField("userId", isEqualTo: userId).getDocuments { querySnapshot, error in
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
        otherRef.whereField("userId", isEqualTo: AuthManager.shared.currentUser).getDocuments { querySnapshot, error in
            guard let querySnapshot = querySnapshot else { return }
            if let error = error {
                completion(.failure(error))
                return
            } else {
                for document in querySnapshot.documents {
                    document.reference.delete()
                }
            }
            completion(.success("Success delete"))
        }
    }
}
