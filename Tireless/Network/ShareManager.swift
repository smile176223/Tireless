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
    
    func uploadVideo(shareFile: ShareFiles, completion: @escaping (Result<URL, Error>) -> Void) {
        let videoRef = Storage.storage().reference().child("Videos/\(shareFile.shareName)")
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
                completion(.success(downloadURL))
                do {
                    var tempVideo = shareFile
                    tempVideo.shareURL = downloadURL
                    try _ = self.shareWallDB.addDocument(from: tempVideo)
                } catch {
                    print(error)
                }
            }
        }
        uploadTask.observe(.progress) { snapshot in
            guard let progress = snapshot.progress else {
                return
            }
            self.uploadProgress?(progress)
        }
    }
    
    func fetchVideo(completion: @escaping (Result<[ShareFiles], Error>) -> Void) {
        shareWallDB.order(by: "createdTime", descending: true).getDocuments { querySnapshot, error in
            guard let querySnapshot = querySnapshot else { return }
            if let error = error {
                completion(.failure(error))
            } else {
                var videos = [ShareFiles]()
                for document in querySnapshot.documents {
                    if let video = try? document.data(as: ShareFiles.self, decoder: Firestore.Decoder()) {
                        videos.append(video)
                    }
                }
                completion(.success(videos))
            }
        }
    }
    
    func uploadPicture(shareFile: ShareFiles, comletion: @escaping (Result<URL, Error>) -> Void) {
        let videoRef = Storage.storage().reference().child("Pictures/\(shareFile.shareName)")
        _ = videoRef.putFile(from: shareFile.shareURL, metadata: nil) { _, error in
            if let error = error {
                comletion(.failure(error))
                return
            }
            videoRef.downloadURL { url, error in
                if let error = error {
                    comletion(.failure(error))
                }
                guard let downloadURL = url else {
                    return
                }
                comletion(.success(downloadURL))
                do {
                    var tempPicture = shareFile
                    tempPicture.shareURL = downloadURL
                    try _ = self.picturesDB.addDocument(from: tempPicture)
                } catch {
                    print(error)
                }
            }
        }
    }
    
    func fetchPicture(completion: @escaping (Result<[ShareFiles], Error>) -> Void) {
        picturesDB.order(by: "createdTime", descending: true).getDocuments { querySnapshot, error in
            guard let querySnapshot = querySnapshot else { return }
            if let error = error {
                completion(.failure(error))
            } else {
                var shareFiles = [ShareFiles]()
                for document in querySnapshot.documents {
                    if let shareFile = try? document.data(as: ShareFiles.self, decoder: Firestore.Decoder()) {
                        shareFiles.append(shareFile)
                    }
                }
                completion(.success(shareFiles))
            }
        }
    }
}
