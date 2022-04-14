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
    static let shared = VideoRecord()
    
    lazy var firestoreDB = Firestore.firestore().collection("shareWall")
    
    var uploadProgress: ((Progress) -> Void)?
    
    func uploadVideo(video: Video, comletion: @escaping (Result<URL, Error>) -> Void) {
        let videoRef = Storage.storage().reference().child("Videos/\(video.video)")
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
}
