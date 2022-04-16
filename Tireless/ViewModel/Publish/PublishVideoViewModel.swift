//
//  DetectFinishViewModel.swift
//  Tireless
//
//  Created by Hao on 2022/4/14.
//

import Foundation

class PublishVideoViewModel {
    
    func uploadVideo(video: Video) {
        VideoManager.shared.uploadVideo(video: video) { result in
            switch result {
            case .success(let url):
                print(url)
            case .failure(let error):
                print(error)
            }
        }
    }
}
