//
//  StatisticsManager.swift
//  Tireless
//
//  Created by Hao on 2022/5/13.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

class StatisticsManager {
    
    static let shared = StatisticsManager()
    
    private init() {}
    
    lazy var userDB = Firestore.firestore().collection("Users").document(AuthManager.shared.currentUser)
    
    var allPlans = ["Plans", "FinishPlans"]
    
    func fetchStatistics(with planExercise: String, completion: @escaping (Result<Int, Error>) -> Void) {
        var totalCount = 0
        let group = DispatchGroup()
        
        for plan in allPlans {
            group.enter()
            let ref = userDB.collection(plan).whereField("planName", isEqualTo: planExercise)
            ref.getDocuments { querySnapshot, error in
                guard let querySnapshot = querySnapshot else { return }
                if let error = error {
                    completion(.failure(error))
                }
                for document in querySnapshot.documents {
                    if let plan = try? document.data(as: Plan.self, decoder: Firestore.Decoder()) {
                        for times in plan.finishTime {
                            if let count = Int(times.planTimes) {
                                totalCount += count
                            }
                        }
                    }
                }
                group.leave()
            }
        }
        group.notify(queue: DispatchQueue.global()) {
            completion(.success(totalCount))
        }
    }
    
    func fetchDays(completion: @escaping (Result<Int, Error>) -> Void) {
        var daysCount = 0
        let group = DispatchGroup()
        for plan in allPlans {
            group.enter()
            userDB.collection(plan).getDocuments { querySnapshot, error in
                guard let querySnapshot = querySnapshot else { return }
                if let error = error {
                    completion(.failure(error))
                }
                for document in querySnapshot.documents {
                    if let plan = try? document.data(as: Plan.self, decoder: Firestore.Decoder()) {
                        daysCount += plan.finishTime.count
                    }
                }
                group.leave()
            }
        }
        group.notify(queue: DispatchQueue.global()) {
            completion(.success(daysCount))
        }
    }
}
