//
//  CommentManager.swift
//  Tireless
//
//  Created by Hao on 2022/4/30.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

class CommentManager {
    
    static let shared = CommentManager()
    
    private init() {}
    
    lazy var shareWallDB = Firestore.firestore().collection("shareWall")
    
    func postComment(uuid: String, comment: Comment, completion: @escaping (Result<String, Error>) -> Void) {
        let ref = shareWallDB.document(uuid).collection("Comments").document()
        do {
            try ref.setData(from: comment)
        } catch {
            print(error)
        }
    }
    
    func fetchComments(uuid: String, completion: @escaping (Result<[Comment], Error>) -> Void) {
        let ref = shareWallDB.document(uuid).collection("Comments").order(by: "createdTime", descending: true)
        ref.addSnapshotListener { querySnapshot, error in
            guard let querySnapshot = querySnapshot else { return }
            if let error = error {
                completion(.failure(error))
            }
            var comments = [Comment]()
            DispatchQueue.global().async {
                let semaphore = DispatchSemaphore(value: 0)
                for document in querySnapshot.documents {
                    if var comment = try? document.data(as: Comment.self, decoder: Firestore.Decoder()) {
                        UserManager.shared.fetchUser(userId: comment.userId) { result in
                            switch result {
                            case .success(let user):
                                comment.user = user
                                if !(ShareManager.shared.blockUsers.contains(comment.userId)) {
                                    comments.append(comment)
                                }
                            case .failure(let error):
                                completion(.failure(error))
                            }
                            semaphore.signal()
                        }
                    }
                    semaphore.wait()
                }
                completion(.success(comments))
            }
        }
    }
}
