//
//  ShareCommentViewModel.swift
//  Tireless
//
//  Created by Hao on 2022/4/30.
//

import Foundation

class ShareCommentViewModel {
    
    let commentsViewModel = Box([CommentsViewModel]())
    
    func fetchData(uuid: String) {
        CommentManager.shared.fetchComments(uuid: uuid) { [weak self] result in
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
