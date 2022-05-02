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
    
    func deletePlan(userId: String, plan: Plan, completion: @escaping (Result<String, Error>) -> Void ) {
        let ref = userDB.document(userId).collection("Plans")
        ref.document(plan.uuid).delete { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(plan.uuid))
            }
        }
        if plan.planGroup == true {
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
    
    func checkGroupUsersStatus(plan: Plan) {
        groupPlanDB.document(plan.uuid).getDocument(as: GroupPlanUser.self) { result in
            switch result {
            case .success(let users):
                for user in users.joinUsers {
                    self.checkGroupUsers(userId: user, plan: plan)
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    private func checkGroupUsers(userId: String, plan: Plan) {
        userDB.document(userId).collection("Plans").document(plan.uuid).getDocument(as: Plan.self) { result in
            switch result {
            case .success(let plans):
                print(plans)
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func fetchHistoryPlan(userId: String, completion: @escaping (Result<[Plan], Error>) -> Void) {
        userDB.document(userId).collection("FinishPlans").getDocuments { querySnapshot, error in
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
}
