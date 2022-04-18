//
//  ShareWallViewModel.swift
//  Tireless
//
//  Created by Hao on 2022/4/15.
//

import Foundation

class ShareWallViewModel {
    
    let shareViewModel = Box([ShareViewModel]())
    
    func fetchData() {
        ShareManager.shared.fetchVideo { [weak self] result in
            switch result {
            case .success(let videos):
                self?.setVideos(videos)
            case .failure(let error):
                print("fetchData.failure: \(error)")
            }
        }
    }
    
    func convertVideosToViewModels(from shareFiles: [ShareFiles]) -> [ShareViewModel] {
        var viewModels = [ShareViewModel]()
        for shareFile in shareFiles {
            let viewModel = ShareViewModel(model: shareFile)
            viewModels.append(viewModel)
        }
        return viewModels
    }
    
    func setVideos(_ shareFiles: [ShareFiles]) {
        shareViewModel.value = convertVideosToViewModels(from: shareFiles)
    }
    
}
