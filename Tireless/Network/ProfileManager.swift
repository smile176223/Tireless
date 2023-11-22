//
//  ProfileManager.swift
//  Tireless
//
//  Created by Hao on 2022/5/7.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

class ProfileManager {
    
    static let shared = ProfileManager()
    
    private init() {}
    
    lazy var userDB = Firestore.firestore().collection("Users")
    
    func changeUserName(name: String, completion: @escaping (Result<String, Error>) -> Void) {
        let ref = userDB.document(AuthManager.shared.currentUser)
        var userData = AuthManager.shared.currentUserData
        userData?.name = name
        do {
            try ref.setData(from: userData)
            completion(.success("Success"))
        } catch {
            completion(.failure(TirelessError.firebaseError))
        }
    }
}
