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
    
    func createPlan(planManage: inout PlanManage, completion: @escaping (Result<String, Error>) -> Void) {
        do {
            let document = Firestore.firestore().collection("plan").document()
            planManage.uuid = document.documentID
            try document.setData(from: planManage)
            completion(.success("Success"))
        } catch {
            completion(.failure(error))
        }
    }
    
    func fetchPlan(completion: @escaping (Result<[PlanManage], Error>) -> Void) {
        planDB.order(by: "createdTime", descending: true).getDocuments { querySnapshot, error in
            guard let querySnapshot = querySnapshot else { return }
            if let error = error {
                completion(.failure(error))
            } else {
                var planManages = [PlanManage]()
                for document in querySnapshot.documents {
                    if let planManage = try? document.data(as: PlanManage.self, decoder: Firestore.Decoder()) {
                        planManages.append(planManage)
                    }
                }
                completion(.success(planManages))
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
    
    func updatePlan(planManage: PlanManage, completion: @escaping (Result<String, Error>) -> Void ) {
        do {
            try planDB.document(planManage.uuid).setData(from: planManage)
            completion(.success("Success"))
        } catch {
            completion(.failure(error))
        }
    }
}