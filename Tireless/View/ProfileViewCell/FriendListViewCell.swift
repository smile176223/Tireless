//
//  FriendListViewCell.swift
//  Tireless
//
//  Created by Hao on 2022/4/24.
//

import UIKit

class FriendListViewCell: UICollectionViewCell {
    
    @IBOutlet weak var friendImageView: UIImageView!
    
    @IBOutlet weak var friendNameLabel: UILabel!
    
    @IBOutlet weak var friendSetButton: UIView!
    
    var isSetButtonTap: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setuLayout()
    }
    
    private func setuLayout() {
        self.layer.cornerRadius = 15
        friendImageView.layer.cornerRadius = friendImageView.frame.height / 2
    }
    
    @IBAction func setButtonTap(_ sender: UIButton) {
        isSetButtonTap?()
    }
    
}
