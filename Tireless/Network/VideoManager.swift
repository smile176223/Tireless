//
//  VideoManager.swift
//  Tireless
//
//  Created by Hao on 2022/4/13.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

class VideoManager {
    static let shared = VideoManager()
    
    lazy var firestoreDB = Firestore.firestore().collection("shareWall")
    
    lazy var picturesDB = Firestore.firestore().collection("pictures")
    
    var uploadProgress: ((Progress) -> Void)?
    
    func uploadVideo(video: Video, comletion: @escaping (Result<URL, Error>) -> Void) {
        let videoRef = Storage.storage().reference().child("Videos/\(video.videoName)")
        let uploadTask = videoRef.putFile(from: video.videoURL, metadata: nil) { _, error in
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
                    var tempVideo = video
                    tempVideo.videoURL = downloadURL
                    try _ = self.firestoreDB.addDocument(from: tempVideo)
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
    
    func fetchShareWallVideo(completion: @escaping (Result<[Video], Error>) -> Void) {
        firestoreDB.order(by: "createdTime", descending: true).getDocuments { querySnapshot, error in
            guard let querySnapshot = querySnapshot else { return }
            if let error = error {
                completion(.failure(error))
            } else {
                var videos = [Video]()
                for document in querySnapshot.documents {
                    if let video = try? document.data(as: Video.self, decoder: Firestore.Decoder()) {
                        videos.append(video)
                    }
                }
                completion(.success(videos))
            }
        }
    }
    
    func uploadPicture(picture: Picture, comletion: @escaping (Result<URL, Error>) -> Void) {
        let videoRef = Storage.storage().reference().child("Pictures/\(picture.pictureName)")
        _ = videoRef.putFile(from: picture.pictureURL, metadata: nil) { _, error in
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
                    var tempPicture = picture
                    tempPicture.pictureURL = downloadURL
                    try _ = self.picturesDB.addDocument(from: tempPicture)
                } catch {
                    print(error)
                }
            }
        }
    }
    
    func fetchPicture(completion: @escaping (Result<[Picture], Error>) -> Void) {
        picturesDB.order(by: "createdTime", descending: true).getDocuments { querySnapshot, error in
            guard let querySnapshot = querySnapshot else { return }
            if let error = error {
                completion(.failure(error))
            } else {
                var pictures = [Picture]()
                for document in querySnapshot.documents {
                    if let picture = try? document.data(as: Picture.self, decoder: Firestore.Decoder()) {
                        pictures.append(picture)
                    }
                }
                completion(.success(pictures))
            }
        }
    }
}
