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
    
    lazy var planDB = Firestore.firestore().collection("plan")
    
    lazy var groupPlanDB = Firestore.firestore().collection("GroupPlans")
    
    func createPlan(personalPlan: inout PersonalPlan, completion: @escaping (Result<String, Error>) -> Void) {
        do {
            let document = Firestore.firestore().collection("plan").document()
            personalPlan.uuid = document.documentID
            try document.setData(from: personalPlan)
            completion(.success("Success"))
        } catch {
            completion(.failure(error))
        }
    }
    
    func fetchPlan(completion: @escaping (Result<[PersonalPlan], Error>) -> Void) {
        planDB.order(by: "createdTime", descending: true).getDocuments { querySnapshot, error in
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
    
    func deletePlan(uuid: String, completion: @escaping (Result<String, Error>) -> Void ) {
        planDB.document(uuid).delete { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(uuid))
            }
        }
    }
    
    func updatePlan(personalPlan: PersonalPlan, completion: @escaping (Result<String, Error>) -> Void ) {
        do {
            try planDB.document(personalPlan.uuid).setData(from: personalPlan)
            completion(.success("Success"))
        } catch {
            completion(.failure(error))
        }
    }
    
    func fetchGroupPlan(completion: @escaping (Result<[GroupPlan], Error>) -> Void) {
        groupPlanDB.order(by: "createdTime", descending: true).getDocuments { querySnapshot, error in
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
}
