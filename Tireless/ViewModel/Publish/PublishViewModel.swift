//
//  DetectFinishViewModel.swift
//  Tireless
//
//  Created by Hao on 2022/4/14.
//

import Foundation

class PublishViewModel {
    
    func uploadVideo(share: ShareFiles) {
        ShareManager.shared.uploadVideo(shareFile: share) { result in
            switch result {
            case .success(let url):
                print(url)
            case .failure(let error):
                print(error)
            }
        }
    }
}
