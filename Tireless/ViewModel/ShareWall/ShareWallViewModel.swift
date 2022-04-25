//
//  ShareWallViewModel.swift
//  Tireless
//
//  Created by Hao on 2022/4/15.
//

import Foundation

class ShareWallViewModel {
    
    let shareFilesViewModel = Box([ShareFilesViewModel]())
    
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
    
    func convertVideosToViewModels(from shareFiles: [ShareFiles]) -> [ShareFilesViewModel] {
        var viewModels = [ShareFilesViewModel]()
        for shareFile in shareFiles {
            let viewModel = ShareFilesViewModel(model: shareFile)
            viewModels.append(viewModel)
        }
        return viewModels
    }
    
    func setVideos(_ shareFiles: [ShareFiles]) {
        shareFilesViewModel.value = convertVideosToViewModels(from: shareFiles)
    }
    
}
