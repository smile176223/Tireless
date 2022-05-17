//
//  VideoManager.swift
//  Tireless
//
//  Created by Hao on 2022/4/13.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

class ShareManager {
    static let shared = ShareManager()
    
    lazy var shareWallDB = Firestore.firestore().collection("shareWall")
    
    lazy var picturesDB = Firestore.firestore().collection("pictures")
    
    var uploadProgress: ((Progress) -> Void)?
    
    var blockUsers = [String]()
    
    func uploadVideo(shareFile: ShareFiles, completion: @escaping (Result<String, Error>) -> Void) {
        let videoRef = Storage.storage().reference().child("Videos/\(UUID().uuidString)")
        let uploadTask = videoRef.putFile(from: shareFile.shareURL, metadata: nil) { _, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            videoRef.downloadURL { url, error in
                if let error = error {
                    completion(.failure(error))
                }
                guard let downloadURL = url else {
                    return
                }
//                completion(.success(downloadURL))
                do {
                    var tempFile = shareFile
                    tempFile.shareURL = downloadURL
                    let document = self.shareWallDB.document()
                    tempFile.uuid = document.documentID
                    try document.setData(from: tempFile)
                    completion(.success(tempFile.uuid))
                } catch {
                    print(error)
                }
            }
        }
        uploadTask.observe(.progress) { [weak self] snapshot in
            guard let progress = snapshot.progress else {
                return
            }
            self?.uploadProgress?(progress)
        }
    }
    
    func fetchVideo(completion: @escaping (Result<[ShareFiles], Error>) -> Void) {
        shareWallDB.order(by: "createdTime", descending: true).getDocuments { querySnapshot, error in
            guard let querySnapshot = querySnapshot else { return }
            if let error = error {
                completion(.failure(error))
            } else {
                DispatchQueue.global().async {
                    let semaphore = DispatchSemaphore(value: 0)
                    var videoPosts = [ShareFiles]()
                    for document in querySnapshot.documents {
                        if var videoPost = try? document.data(as: ShareFiles.self, decoder: Firestore.Decoder()) {
                            UserManager.shared.fetchUser(userId: videoPost.userId) { result in
                                switch result {
                                case .success(let user):
                                    videoPost.user = user
                                    if !(AuthManager.shared.blockUsers.contains(videoPost.userId)) {
                                        videoPosts.append(videoPost)
                                    }
                                case .failure(let error):
                                    completion(.failure(error))
                                }
                                semaphore.signal()
                            }
                        }
                        semaphore.wait()
                    }
                    completion(.success(videoPosts))
                }
            }
        }
    }
    
    func deleteVideo(uuid: String, completion: @escaping (Result<String, Error>) -> Void) {
        shareWallDB.whereField("uuid", isEqualTo: uuid).getDocuments { querySnapshot, error in
            guard let querySnapshot = querySnapshot else { return }
            if let error = error {
                completion(.failure(error))
            } else {
                for doucument in querySnapshot.documents {
                    doucument.reference.delete()
                }
                completion(.success("success delete"))
            }
        }
    }
    
    func uploadPicture(imageData: Data, comletion: @escaping (Result<URL, Error>) -> Void) {
        let videoRef = Storage.storage().reference().child("Pictures/\(UUID().uuidString)")
        
        videoRef.putData(imageData, metadata: nil) { (_, error) in
            if let error = error {
                comletion(.failure(error))
            } else {
                videoRef.downloadURL(completion: { (url, error) in
                    guard let url = url else { return }
                    if let error = error {
                        comletion(.failure(error))
                    } else {
                        self.setupPicture(imageURL: url)
                        comletion(.success(url))
                    }
                })
            }
            
        }
    }
    
    func setupPicture(imageURL: URL) {
        let ref = Firestore.firestore().collection("Users").document(AuthManager.shared.currentUser)
        ref.setData(["picture": imageURL.absoluteString], merge: true)
    }
    
}
