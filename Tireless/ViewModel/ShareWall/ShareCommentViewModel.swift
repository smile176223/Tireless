//
//  ShareCommentViewModel.swift
//  Tireless
//
//  Created by Hao on 2022/4/30.
//

import Foundation

class ShareCommentViewModel {
    
    let comments = Box([Comment]())
    
    var shareFile: ShareFiles

    init(shareFile: ShareFiles) {
        self.shareFile = shareFile
    }
    
    func fetchData() {
        CommentManager.shared.fetchComments(uuid: shareFile.uuid) { [weak self] result in
            switch result {
            case .success(let comments):
                self?.comments.value = comments
            case .failure:
                ProgressHUD.showFailure()
            }
        }
    }
    
    func sendComment(comment: String, needLogin: (() -> Void)?) {
        if AuthManager.shared.checkCurrentUser() {
            let commentText = Comment(userId: AuthManager.shared.currentUser,
                                      content: comment,
                                      createdTime: Date().millisecondsSince1970)
            CommentManager.shared.postComment(uuid: shareFile.uuid,
                                              comment: commentText) { result in
                switch result {
                case .success:
                    return
                case .failure:
                    ProgressHUD.showFailure()
                }
            }
        } else {
            needLogin?()
        }
    }
    
    func blockUser(userId: String) {
        UserManager.shared.blockUser(blockId: userId) { result in
            switch result {
            case .success:
                ProgressHUD.showSuccess(text: "封鎖成功")
            case .failure:
                ProgressHUD.showFailure(text: "封鎖失敗")
            }
        }
    }
}
