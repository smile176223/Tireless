//
//  GroupPlanManager.swift
//  Tireless
//
//  Created by Hao on 2022/4/24.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

class GroupPlanManager {
    static let shared = GroupPlanManager()
    
    lazy var groupPlanDB = Firestore.firestore().collection("GroupPlans")
    
    lazy var userDB = Firestore.firestore().collection("Users")
    
    func fetchFriendsPlan(userId: String, completion: @escaping (Result<[GroupPlans], Error>) -> Void) {
        userDB.document(userId).collection("friends").getDocuments { [weak self] querySnapshot, error in
            guard let querySnapshot = querySnapshot else { return }
            if let error = error {
                print(error)
            } else {
                var friends = [String]()
                for document in querySnapshot.documents {
                    if let friend = try? document.data(as: Friends.self, decoder: Firestore.Decoder()) {
                        friends.append(friend.userId)
                    }
                }
                friends.append(userId)
                if friends.isEmpty == true {
                    return
                }
                self?.fetchPlan(userId: friends) { result in
                    switch result {
                    case .success(let groupPlans):
                        completion(.success(groupPlans))
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
            }
        }
    }
    
    private func fetchPlan(userId: [String], completion: @escaping (Result<[GroupPlans], Error>) -> Void) {
        groupPlanDB.whereField("createdUserId", in: userId).addSnapshotListener { querySnapshot, error in
            guard let querySnapshot = querySnapshot else { return }
            if let error = error {
                completion(.failure(error))
            } else {
                var groupPlans = [GroupPlans]()
                for document in querySnapshot.documents {
                    if let groupPlan = try? document.data(as: GroupPlans.self, decoder: Firestore.Decoder()) {
                        groupPlans.append(groupPlan)
                    }
                }
                completion(.success(groupPlans))
            }
        }
    }
    
    func createGroupPlan(groupPlan: inout GroupPlans, completion: @escaping (Result<String, Error>) -> Void) {
        do {
            let document = Firestore.firestore().collection("GroupPlans").document()
            groupPlan.uuid = document.documentID
            try document.setData(from: groupPlan)
            completion(.success("Success"))
        } catch {
            completion(.failure(error))
        }
    }
}
