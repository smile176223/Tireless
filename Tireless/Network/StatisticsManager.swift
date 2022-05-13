//
//  StatisticsManager.swift
//  Tireless
//
//  Created by Hao on 2022/5/13.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

class StatisticsManager {
    
    static let shared = StatisticsManager()
    
    private init() {}
    
    lazy var userDB = Firestore.firestore().collection("Users").document(AuthManager.shared.currentUser)
    
    func fetchSquat(completion: @escaping (Result<String, Error>) -> Void) {
        var squatCount = 0
        let group = DispatchGroup()
        
        group.enter()
        let ref = userDB.collection("Plans").whereField("planName", isEqualTo: PlanExercise.squat.rawValue)
        ref.getDocuments { querySnapshot, error in
            guard let querySnapshot = querySnapshot else { return }
            if let error = error {
                completion(.failure(error))
            }
            for document in querySnapshot.documents {
                if let squat = try? document.data(as: Plan.self, decoder: Firestore.Decoder()) {
                    for times in squat.finishTime {
                        if let count = Int(times.planTimes) {
                            squatCount += count
                        }
                    }
                }
            }
            group.leave()
        }
        group.enter()
        let refFinish = userDB.collection("FinishPlans").whereField("planName", isEqualTo: PlanExercise.squat.rawValue)
        refFinish.getDocuments { querySnapshot, error in
            guard let querySnapshot = querySnapshot else { return }
            if let error = error {
                completion(.failure(error))
            }
            for document in querySnapshot.documents {
                if let squat = try? document.data(as: Plan.self, decoder: Firestore.Decoder()) {
                    for times in squat.finishTime {
                        if let count = Int(times.planTimes) {
                            squatCount += count
                        }
                    }
                }
            }
            group.leave()
        }
        group.notify(queue: DispatchQueue.global()) {
            print(squatCount)
        }
    }
}
