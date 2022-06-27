//
//  FriendListHeaderView.swift
//  Tireless
//
//  Created by Hao on 2022/5/12.
//

import UIKit

class FriendListHeaderView: UITableViewHeaderFooterView {
    
    @IBOutlet weak var findFriendsButton: UIButton!
    
    @IBOutlet weak var receiveInviteButton: UIButton!
    
    var findButtonTapped: (() -> Void)?
    
    var receiveButtonTapped: (() -> Void)?
    
    @IBAction func findButtonTap(_ sender: UIButton) {
        findButtonTapped?()
    }
    
    @IBAction func receiveButtonTap(_ sender: UIButton) {
        receiveButtonTapped?()
    }
    
}
