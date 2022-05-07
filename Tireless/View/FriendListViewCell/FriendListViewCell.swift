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
    
    var viewModel: FriendsViewModel?
    
    var isSetButtonTap: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setuLayout()
    }
    
    func setup(viewModel: FriendsViewModel) {
        self.viewModel = viewModel
        layoutCell()
    }
    
    private func layoutCell() {
        friendNameLabel.text = viewModel?.user.name
        friendImageView.loadImage(viewModel?.user.picture)
        if viewModel?.user.picture == "" {
            friendImageView.backgroundColor = .themeBG
            friendImageView.image = UIImage(named: "TirelessLogo")
        }
    }
    
    private func setuLayout() {
        self.layer.cornerRadius = 15
        friendImageView.layer.cornerRadius = friendImageView.frame.height / 2
    }
    
    @IBAction func setButtonTap(_ sender: UIButton) {
        isSetButtonTap?()
    }
    
}