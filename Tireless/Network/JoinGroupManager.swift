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
        userDB.document(userId).collection("Friends").getDocuments { [weak self] querySnapshot, error in
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
                    DispatchQueue.global().async {
                        let semaphore = DispatchSemaphore(value: 0)
                        for document in querySnapshot.documents {
                            if var joinGroup = try? document.data(as: JoinGroup.self, decoder: Firestore.Decoder()) {
                                UserManager.shared.fetchUser(userId: joinGroup.createdUserId) { result in
                                    switch result {
                                    case .success(let user):
                                        joinGroup.createdUser = user
                                        joinGroups.append(joinGroup)
                                    case .failure(let error):
                                        completion(.failure(error))
                                    }
                                    semaphore.signal()
                                }
                            }
                            semaphore.wait()
                        }
                        completion(.success(joinGroups))
                    }
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
        joinGroupDB.document(uuid).collection("JoinUsers").addSnapshotListener { querySnapshot, error in
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
    
    private func setJoinUsersGroupPlan(uuid: String, joinUsers: [String], plan: Plan) {
        for user in joinUsers {
            try? userDB.document(user).collection("Plans").document(uuid).setData(from: plan)
        }
    }
    
    func createGroupPlan(uuid: String, plan: Plan, joinUsers: [String],
                         completion: @escaping (Result<String, Error>) -> Void ) {
        let groupPlanDB = Firestore.firestore().collection("GroupPlans")
        deleteJoinGroup(uuid: uuid) { [weak self] result in
            switch result {
            case .success(let uuid):
                groupPlanDB.document(uuid).setData(["joinUsers": joinUsers])
                self?.setJoinUsersGroupPlan(uuid: uuid, joinUsers: joinUsers, plan: plan)
                completion(.success("Success"))
            case .failure(let error):
                print(error)
            }
        }
    }
}
