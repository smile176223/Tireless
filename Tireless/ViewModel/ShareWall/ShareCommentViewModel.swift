//
//  ShareCommentViewModel.swift
//  Tireless
//
//  Created by Hao on 2022/4/30.
//

import Foundation

class ShareCommentViewModel {
    
    let commentsViewModel = Box([CommentsViewModel]())
    
    var shareFile: ShareFiles

    init(shareFile: ShareFiles) {
        self.shareFile = shareFile
    }
    
    func fetchData() {
        CommentManager.shared.fetchComments(uuid: shareFile.uuid) { [weak self] result in
            switch result {
            case .success(let comments):
                self?.setComments(comments)
            case .failure(let error):
                print("fetchData.failure: \(error)")
            }
        }
    }
    
    func convertCommentsToViewModels(from comments: [Comment]) -> [CommentsViewModel] {
        var viewModels = [CommentsViewModel]()
        for comment in comments {
            let viewModel = CommentsViewModel(model: comment)
            viewModels.append(viewModel)
        }
        return viewModels
    }
    
    func setComments(_ comments: [Comment]) {
        commentsViewModel.value = convertCommentsToViewModels(from: comments)
    }
    
}
