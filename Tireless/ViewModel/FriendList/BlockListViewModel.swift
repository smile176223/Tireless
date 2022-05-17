//
//  BlockListViewModel.swift
//  Tireless
//
//  Created by Hao on 2022/5/4.
//

import Foundation

class BlockListViewModel {
    let blocksViewModels = Box([BlocksViewModel]())
    
    func fetchBlocks() {
        var blockUsers = [User]()
        if AuthManager.shared.blockUsers.count == 0 {
            self.setBlocks(blockUsers)
        } else {
            DispatchQueue.global().async {
                let semaphore = DispatchSemaphore(value: 0)
                for block in AuthManager.shared.blockUsers {
                    UserManager.shared.fetchUser(userId: block) { result in
                        switch result {
                        case .success(let user):
                            blockUsers.append(user)
                        case .failure(let error):
                            print(error)
                            ProgressHUD.showFailure()
                        }
                        semaphore.signal()
                    }
                    semaphore.wait()
                }
                self.setBlocks(blockUsers)
            }
        }
    }
    
    func removeBlockUser(userId: String) {
        FriendManager.shared.removeBlockUser(userId: userId) { result in
            switch result {
            case .success(let text):
                print(text)
                AuthManager.shared.getCurrentUser { result in
                    switch result {
                    case .success(let bool):
                        print(bool)
                        self.fetchBlocks()
                    case .failure(let error):
                        print(error)
                    }
                }
            case .failure(let error):
                print(error)
            }
        }
    }

    func convertBlocksToViewModels(from blocks: [User]) -> [BlocksViewModel] {
        var viewModels = [BlocksViewModel]()
        for block in blocks {
            let viewModel = BlocksViewModel(model: block)
            viewModels.append(viewModel)
        }
        return viewModels
    }
    
    func setBlocks(_ blocks: [User]) {
        blocksViewModels.value = convertBlocksToViewModels(from: blocks)
    }
}
