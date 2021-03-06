//
//  AuthViewModel.swift
//  Tireless
//
//  Created by Hao on 2022/4/26.
//

import Foundation

class AuthViewModel {
    
    var user: User = User(emailAccount: "",
                          userId: "",
                          name: "",
                          picture: "",
                          maxVideoUploadCount: 0)
    
    func getUser(email: String, userId: String, name: String, picture: String) {
        self.user.emailAccount = email
        self.user.userId = userId
        self.user.name = name
        self.user.picture = picture
    }
    
    func createUser() {
        UserManager.shared.createUser(user: user) { result in
            switch result {
            case .success(let success):
                print(success)
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func signInWithFirebase(email: String, password: String) {
        AuthManager.shared.signInWithFirebase(email: email, password: password) { result in
            print(result)
        } failure: { error in
            print(error)
        }
    }
    
    func signUpWithFirebase(email: String,
                            password: String,
                            name: String,
                            success: (() -> Void)?,
                            failure: ((String) -> Void)?) {
        AuthManager.shared.signUpWithFirebase(email: email,
                                              password: password) { authResult in
            self.getUser(email: authResult.user.email ?? "",
                         userId: authResult.user.uid,
                         name: name,
                         picture: "")
            self.createUser()
            success?()
        } failure: { errorText in
            failure?(errorText)
        }
    }
}
