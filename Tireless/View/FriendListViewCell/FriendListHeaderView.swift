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
    
    var isFindButtonTap: (() -> Void)?
    
    var isReceiveButtonTap: (() -> Void)?
    
    @IBAction func findButtonTap(_ sender: UIButton) {
        isFindButtonTap?()
    }
    
    @IBAction func receiveButtonTap(_ sender: UIButton) {
        isReceiveButtonTap?()
    }
    
}
