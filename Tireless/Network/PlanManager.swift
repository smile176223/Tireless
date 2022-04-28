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
    
    func createPlan(userId: String, personalPlan: inout PersonalPlan,
                    completion: @escaping (Result<String, Error>) -> Void) {
        do {
            let document = userDB.document(userId).collection("Plans").document()
            personalPlan.uuid = document.documentID
            try document.setData(from: personalPlan)
            completion(.success("Success"))
        } catch {
            completion(.failure(error))
        }
    }
    
    func fetchPlan(userId: String, completion: @escaping (Result<[PersonalPlan], Error>) -> Void) {
        let ref = userDB.document(userId).collection("Plans")
        ref.order(by: "createdTime", descending: true).addSnapshotListener { querySnapshot, error in
            guard let querySnapshot = querySnapshot else { return }
            if let error = error {
                completion(.failure(error))
            } else {
                var personalPlans = [PersonalPlan]()
                for document in querySnapshot.documents {
                    if let personalPlan = try? document.data(as: PersonalPlan.self, decoder: Firestore.Decoder()) {
                        personalPlans.append(personalPlan)
                    }
                }
                completion(.success(personalPlans))
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
    
    func updatePlan(userId: String, personalPlan: PersonalPlan,
                    completion: @escaping (Result<String, Error>) -> Void ) {
        do {
            let ref = userDB.document(userId).collection("Plans")
            try ref.document(personalPlan.uuid).setData(from: personalPlan)
            completion(.success("Success"))
        } catch {
            completion(.failure(error))
        }
    }
    
    func fetchGroupPlan(completion: @escaping (Result<[GroupPlan], Error>) -> Void) {
        groupPlanDB.order(by: "createdTime", descending: true).addSnapshotListener { querySnapshot, error in
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
    
    func finishPlan(userId: String, personalPlan: PersonalPlan, completion: @escaping (Result<String, Error>) -> Void) {
        let ref = userDB.document(userId).collection("FinishPersonalPlans").document(personalPlan.uuid)
        do {
            try ref.setData(from: personalPlan)
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
}
