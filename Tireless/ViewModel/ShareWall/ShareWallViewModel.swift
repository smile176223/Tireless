//
//  ShareWallViewModel.swift
//  Tireless
//
//  Created by Hao on 2022/4/15.
//

import Foundation

class ShareWallViewModel {
    
    let videoViewModel = Box([VideoViewModel]())
    
    func fetchData() {
        VideoManager.shared.fetchShareWallVideo { [weak self] result in
            switch result {
            case .success(let videos):
                self?.setVideos(videos)
            case .failure(let error):
                print("fetchData.failure: \(error)")
            }
        }
    }
    
    func convertVideosToViewModels(from videos: [Video]) -> [VideoViewModel] {
        var viewModels = [VideoViewModel]()
        for video in videos {
            let viewModel = VideoViewModel(model: video)
            viewModels.append(viewModel)
        }
        return viewModels
    }
    
    func setVideos(_ videos: [Video]) {
        videoViewModel.value = convertVideosToViewModels(from: videos)
    }
    
}
