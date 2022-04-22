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
    
    func createPlan(plan: PlanManage, completion: @escaping (Result<String, Error>) -> Void) {
        do {
            try _ = planDB.addDocument(from: plan)
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
}
