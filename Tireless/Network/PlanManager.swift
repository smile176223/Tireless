//
//  PlanManager.swift
//  Tireless
//
//  Created by Hao on 2022/4/22.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

class PlanManager {
    static let shared = PlanManager()
    
    private init() {}
    
    lazy var userDB = Firestore.firestore().collection("Users")
    
    lazy var groupPlanDB = Firestore.firestore().collection("GroupPlans")
    
    func createPlan(userId: String, plan: inout Plan,
                    completion: @escaping (Result<String, Error>) -> Void) {
        do {
            let document = userDB.document(userId).collection("Plans").document()
            plan.uuid = document.documentID
            try document.setData(from: plan)
            completion(.success("Success"))
        } catch {
            completion(.failure(error))
        }
    }
    
    func fetchPlan(userId: String, completion: @escaping (Result<[Plan], Error>) -> Void) {
        let ref = userDB.document(userId).collection("Plans")
        ref.order(by: "createdTime", descending: true).addSnapshotListener { querySnapshot, error in
            guard let querySnapshot = querySnapshot else { return }
            if let error = error {
                completion(.failure(error))
            } else {
                var plans = [Plan]()
                for document in querySnapshot.documents {
                    if let plan = try? document.data(as: Plan.self, decoder: Firestore.Decoder()) {
                        plans.append(plan)
                    }
                }
                completion(.success(plans))
            }
        }
    }
    
    func deletePlan(userId: String, uuid: String, completion: @escaping (Result<String, Error>) -> Void ) {
        let ref = userDB.document(userId).collection("Plans")
        ref.document(uuid).delete { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(uuid))
            }
        }
    }
    
    func updatePlan(userId: String, plan: Plan,
                    completion: @escaping (Result<String, Error>) -> Void) {
        do {
            let ref = userDB.document(userId).collection("Plans")
            try ref.document(plan.uuid).setData(from: plan)
            completion(.success("Success"))
        } catch {
            completion(.failure(error))
        }
    }
    
    func fetchGroupPlan(completion: @escaping (Result<[GroupPlan], Error>) -> Void) {
        let ref = groupPlanDB.whereField("joinUserId", arrayContains: AuthManager.shared.currentUser)
        ref.order(by: "createdTime", descending: true).addSnapshotListener { querySnapshot, error in
            guard let querySnapshot = querySnapshot else { return }
            if let error = error {
                completion(.failure(error))
            } else {
                var groupPlans = [GroupPlan]()
                for document in querySnapshot.documents {
                    if let groupPlan = try? document.data(as: GroupPlan.self, decoder: Firestore.Decoder()) {
                        groupPlans.append(groupPlan)
                    }
                }
                completion(.success(groupPlans))
            }
        }
    }
    
    func finishPlan(userId: String, plan: Plan, completion: @escaping (Result<String, Error>) -> Void) {
        let ref = userDB.document(userId).collection("FinishPlans").document(plan.uuid)
        do {
            try ref.setData(from: plan)
            completion(.success("Success"))
        } catch {
            completion(.failure(error))
        }
    }
    
    func modifyPlan(planUid: String, times: String,
                    completion: @escaping (Result<String, Error>) -> Void) {
        let ref = userDB.document(AuthManager.shared.currentUser).collection("Plans")
        ref.whereField("uuid", isEqualTo: planUid).getDocuments { querySnapshot, error in
            guard let querySnapshot = querySnapshot else { return }
            if let error = error {
                completion(.failure(error))
            } else {
                for document in querySnapshot.documents {
                    ref.document(document.documentID).setData(["planTimes": times], merge: true)
                }
            }
        }
    }
    
    func updateGroupPlan(userId: String,
                         groupPlan: GroupPlan,
                         finishTime: FinishTime,
                         completion: @escaping (Result<String, Error>) -> Void) {
        
    }
    
    func finishGroupPlan(userId: String,
                         groupPlan: GroupPlan,
                         completion: @escaping (Result<String, Error>) -> Void) {
        let ref = Firestore.firestore().collection("FinishGroupPlans")
        do {
            try ref.document(groupPlan.uuid).setData(from: groupPlan)
            completion(.success("Success"))
        } catch {
            completion(.failure(error))
        }
    }
}
