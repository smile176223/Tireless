//
//  AuthManager.swift
//  Tireless
//
//  Created by Hao on 2022/4/27.
//

import Foundation
import FirebaseAuth

class AuthManager {
    static let shared = AuthManager()
    
    private init() {}
    
    var currentUser = String()
    
    var currentUserData: User?
    
    func signInWithApple(idToken: String, nonce: String, appleName: String,
                         completion: @escaping (Result<AuthDataResult, Error>) -> Void) {
        let firebaseCredential = OAuthProvider.credential(withProviderID: "apple.com",
                                                          idToken: idToken,
                                                          rawNonce: nonce)
        
        Auth.auth().signIn(with: firebaseCredential) { authResult, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let authResult = authResult else {
                return
            }
            completion(.success(authResult))
        }
    }
    
    func getCurrentUser() {
        Auth.auth().addStateDidChangeListener { auth, user in
            guard let user = auth.currentUser else {
                self.currentUser = ""
                return
            }
            self.currentUser = user.uid
            UserManager.shared.fetchUser(userId: user.uid) { result in
                switch result {
                case .success(let user):
                    self.currentUserData = user
                case .failure(let error):
                    print(error)
                }
            }
        }
    }
    
    func checkCurrentUser() -> Bool {
        if Auth.auth().currentUser != nil {
            return true
        }
        return false
    }
    
    func singOut(completion: @escaping (Result<String, Error>) -> Void) {
        do {
            try Auth.auth().signOut()
            completion(.success("Success sign out"))
        } catch {
            completion(.failure(error))
        }
    }
    
    func deleteUser() {
        let needDeleteUser = self.currentUser
        Auth.auth().currentUser?.delete { error in
            if let error = error {
                print(error)
            } else {
                print("success delete")
                UserManager.shared.deleteUser(userId: needDeleteUser) { result in
                    switch result {
                    case .success(let string):
                        print(string)
                    case .failure(let error):
                        print(error)
                    }
                }
            }
        }
    }
}
