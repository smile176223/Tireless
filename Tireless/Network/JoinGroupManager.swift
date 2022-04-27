//
//  GroupPlanManager.swift
//  Tireless
//
//  Created by Hao on 2022/4/24.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

class JoinGroupManager {
    static let shared = JoinGroupManager()
    
    private init() {}
    
    lazy var joinGroupDB = Firestore.firestore().collection("JoinGroups")
    
    lazy var userDB = Firestore.firestore().collection("Users")
    
    func fetchFriendsPlan(userId: String, completion: @escaping (Result<[JoinGroup], Error>) -> Void) {
        userDB.document(userId).collection("friends").getDocuments { [weak self] querySnapshot, error in
            guard let querySnapshot = querySnapshot else { return }
            if let error = error {
                print(error)
            } else {
                var friends = [String]()
                for document in querySnapshot.documents {
                    if let friend = try? document.data(as: Friend.self, decoder: Firestore.Decoder()) {
                        friends.append(friend.userId)
                    }
                }
                friends.append(userId)
                if friends.isEmpty == true {
                    return
                }
                self?.fetchPlan(userId: friends) { result in
                    switch result {
                    case .success(let joinGroup):
                        completion(.success(joinGroup))
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
            }
        }
    }
    
    private func fetchPlan(userId: [String], completion: @escaping (Result<[JoinGroup], Error>) -> Void) {
        joinGroupDB.whereField("createdUserId", in: userId).order(
            by: "createdTime", descending: true).addSnapshotListener { querySnapshot, error in
                guard let querySnapshot = querySnapshot else { return }
                if let error = error {
                    completion(.failure(error))
                } else {
                    var joinGroups = [JoinGroup]()
                    for document in querySnapshot.documents {
                        if let joinGroup = try? document.data(as: JoinGroup.self, decoder: Firestore.Decoder()) {
                            joinGroups.append(joinGroup)
                        }
                    }
                    completion(.success(joinGroups))
                }
            }
    }
    
    func createJoinGroup(joinGroup: inout JoinGroup, completion: @escaping (Result<String, Error>) -> Void) {
        do {
            let document = Firestore.firestore().collection("JoinGroups").document()
            joinGroup.uuid = document.documentID
            try document.setData(from: joinGroup)
            completion(.success("Success"))
        } catch {
            completion(.failure(error))
        }
    }
    
    func joinGroupPlan(uuid: String, completion: @escaping (Result<String, Error>) -> Void) {
        
        let document = joinGroupDB.document(uuid).collection("JoinUsers").document(AuthManager.shared.currentUser)
        document.setData(["userId": AuthManager.shared.currentUser]) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success("Success"))
            }
        }
    }
    
    func fetchPlanJoinUser(uuid: String, completion: @escaping (Result<[User], Error>) -> Void) {
        joinGroupDB.document(uuid).collection("JoinUsers").getDocuments { querySnapshot, error in
            guard let querySnapshot = querySnapshot else { return }
            if let error = error {
                print(error)
            } else {
                var joinUsers = [User]()
                for document in querySnapshot.documents {
                    if let joinUser = try? document.data(as: UserId.self, decoder: Firestore.Decoder()) {
                        UserManager.shared.fetchUser(userId: joinUser.userId) { result in
                            switch result {
                            case .success(let user):
                                joinUsers.append(user)
                                completion(.success(joinUsers))
                            case .failure(let error):
                                completion(.failure(error))
                            }
                        }
                    }
                }
            }
        }
    }
    
    func leaveJoinGroup(uuid: String, userId: String, completion: @escaping (Result<String, Error>) -> Void ) {
        joinGroupDB.document(uuid).collection("JoinUsers").document(userId).delete { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(uuid))
            }
        }
    }
    
    func deleteJoinGroup(uuid: String, completion: @escaping (Result<String, Error>) -> Void ) {
        joinGroupDB.document(uuid).delete { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(uuid))
            }
        }
    }
    
    func startJoinGroup(uuid: String, groupPlan: GroupPlan, completion: @escaping (Result<String, Error>) -> Void ) {
        let groupPlanDB = Firestore.firestore().collection("GroupPlans")
        deleteJoinGroup(uuid: uuid) { [weak self] result in
            switch result {
            case .success(let uuid):
                do {
                    try groupPlanDB.document(uuid).setData(from: groupPlan)
                    self?.setJoinUsersGroupPlan(uuid: uuid, joinUsers: groupPlan.joinUserId)
                    completion(.success("Success"))
                } catch {
                    completion(.failure(error))
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    private func setJoinUsersGroupPlan(uuid: String, joinUsers: [String]) {
        let document = userDB.document(AuthManager.shared.currentUser).collection("GroupPlans").document()
        document.setData(["GroupPlanId": uuid])
        for user in joinUsers {
            userDB.document(user).collection("GroupPlans").document().setData(["GroupPlanId": uuid])
        }
    }
}
