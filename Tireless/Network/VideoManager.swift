//
//  VideoManager.swift
//  Tireless
//
//  Created by Hao on 2022/4/13.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

enum FirebaseError: Error {
    case documentError
}

enum MainError: Error {
    case youKnowNothingError(String)
}

class VideoManager {
    static let shared = VideoRecord()
    
    lazy var storedb = Firestore.firestore()
    
    func uploadVideo() {
        
    }
}
